#requires -Version 7.0
<#
.SYNOPSIS
    Importa automaticamente uma nova fita para uma Tape Library específica
    somente quando não houver mídia disponível no Free Pool.

.DESCRIPTION
    Fluxo do script:
    1. Conecta ao servidor Veeam
    2. Localiza a Tape Library definida
    3. Verifica se existe ao menos uma fita no Free Pool
    4. Se existir, encerra sem fazer import
    5. Se não existir, executa o import de nova mídia
    6. Executa inventory da library
    7. Valida se a mídia foi reconhecida e enviada ao Free Pool

.NOTES
    Autor  : Juliano Cunha
    Projeto: Veeam.Tape.Import
    Versão : 2.0.0
    Requer : Veeam Backup & Replication Console / PowerShell 7 / VBR v13
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Server = "localhost",

    [Parameter()]
    [string]$LibraryName = "NOME_DA_LIBRARY",

    [Parameter()]
    [string]$LogPath = "C:\Temp\vbr_tape_import.log",

    [Parameter()]
    [switch]$ForceAcceptTlsCertificate
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp [$Level] $Message"

    Write-Host $line

    $logFolder = Split-Path -Path $LogPath -Parent
    if (-not [string]::IsNullOrWhiteSpace($logFolder) -and -not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $LogPath -Value $line
}

function Initialize-Log {
    $logFolder = Split-Path -Path $LogPath -Parent
    if (-not [string]::IsNullOrWhiteSpace($logFolder) -and -not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }

    if (Test-Path -Path $LogPath) {
        Remove-Item -Path $LogPath -Force
    }

    New-Item -Path $LogPath -ItemType File -Force | Out-Null
}

function Connect-ToVBR {
    Write-Log "Validando módulo Veeam.Backup.PowerShell..."
    $module = Get-Module -ListAvailable -Name "Veeam.Backup.PowerShell" | Sort-Object Version -Descending | Select-Object -First 1

    if (-not $module) {
        throw "O módulo 'Veeam.Backup.PowerShell' não foi encontrado neste servidor."
    }

    Import-Module Veeam.Backup.PowerShell -ErrorAction Stop
    Write-Log "Módulo Veeam.Backup.PowerShell importado com sucesso."

    Write-Log "Conectando ao servidor Veeam '$Server'..."
    if ($ForceAcceptTlsCertificate) {
        Connect-VBRServer -Server $Server -ForceAcceptTlsCertificate | Out-Null
    }
    else {
        Connect-VBRServer -Server $Server | Out-Null
    }
    Write-Log "Conexão com o servidor Veeam estabelecida com sucesso." "SUCCESS"
}

function Disconnect-FromVBR {
    try {
        Disconnect-VBRServer | Out-Null
        Write-Log "Sessão com o servidor Veeam encerrada."
    }
    catch {
        Write-Log "Não foi possível encerrar a sessão Veeam: $($_.Exception.Message)" "WARN"
    }
}

function Get-TapeLibraryByName {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Log "Localizando Tape Library '$Name'..."
    $library = Get-VBRTapeLibrary -Name $Name -ErrorAction SilentlyContinue

    if (-not $library) {
        throw "Tape Library '$Name' não encontrada."
    }

    Write-Log "Tape Library encontrada: $($library.Name)." "SUCCESS"
    return $library
}

function Get-FreePool {
    param(
        [Parameter(Mandatory)]
        $Library
    )

    Write-Log "Obtendo Free Pool da library '$($Library.Name)'..."
    $freePool = Get-VBRTapeMediaPool -Library $Library -Name "Free" -ErrorAction SilentlyContinue

    if (-not $freePool) {
        throw "Free Pool não encontrado para a library '$($Library.Name)'."
    }

    Write-Log "Free Pool localizado com sucesso." "SUCCESS"
    return $freePool
}

function Get-FreePoolTapeCount {
    param(
        [Parameter(Mandatory)]
        $FreePool
    )

    $tapes = @(Get-VBRTapeMedium -MediaPool $FreePool -ErrorAction SilentlyContinue)
    $count = $tapes.Count

    Write-Log "Quantidade de fitas no Free Pool: $count"
    return $count
}

function Import-NewTape {
    param(
        [Parameter(Mandatory)]
        $Library
    )

    Write-Log "Nenhuma fita encontrada no Free Pool. Executando import de nova mídia..."
    Import-VBRTapeMedium -Library $Library -Wait | Out-Null
    Write-Log "Import de mídia concluído." "SUCCESS"
}

function Start-LibraryInventory {
    param(
        [Parameter(Mandatory)]
        $Library
    )

    Write-Log "Executando inventory da library '$($Library.Name)'..."
    Start-VBRTapeInventory -Library $Library -Wait | Out-Null
    Write-Log "Inventory concluído com sucesso." "SUCCESS"
}

function Test-UnrecognizedTapeExists {
    param(
        [Parameter(Mandatory)]
        $Library
    )

    $pool = Get-VBRTapeMediaPool -Library $Library -Name "Unrecognized" -ErrorAction SilentlyContinue
    if (-not $pool) {
        Write-Log "Pool 'Unrecognized' não encontrado nesta library."
        return $false
    }

    $tapes = @(Get-VBRTapeMedium -MediaPool $pool -ErrorAction SilentlyContinue)
    if ($tapes.Count -gt 0) {
        Write-Log "Ainda existem $($tapes.Count) fita(s) no pool 'Unrecognized'." "WARN"
        return $true
    }

    Write-Log "Nenhuma fita restante no pool 'Unrecognized'."
    return $false
}

try {
    Initialize-Log
    Write-Log "===== INÍCIO DA EXECUÇÃO ====="
    Write-Log "Servidor Veeam informado : $Server"
    Write-Log "Tape Library informada   : $LibraryName"
    Write-Log "Log file                 : $LogPath"

    Connect-ToVBR

    $library = Get-TapeLibraryByName -Name $LibraryName
    $freePool = Get-FreePool -Library $library

    $freeTapeCount = Get-FreePoolTapeCount -FreePool $freePool

    if ($freeTapeCount -gt 0) {
        Write-Log "Já existe fita disponível no Free Pool. Nenhum import será realizado." "SUCCESS"
        Write-Log "===== FIM DA EXECUÇÃO ====="
        exit 0
    }

    Import-NewTape -Library $library
    Start-LibraryInventory -Library $library

    $freeTapeCountAfterImport = Get-FreePoolTapeCount -FreePool $freePool

    if ($freeTapeCountAfterImport -gt 0) {
        Write-Log "A nova fita foi reconhecida e agora está disponível no Free Pool." "SUCCESS"
        Write-Log "===== FIM DA EXECUÇÃO ====="
        exit 0
    }

    $hasUnrecognized = Test-UnrecognizedTapeExists -Library $library

    if ($hasUnrecognized) {
        throw "O import foi executado, porém a mídia ainda permanece em 'Unrecognized' após o inventory."
    }
    else {
        throw "O import foi executado, porém nenhuma mídia apareceu no Free Pool após o inventory."
    }
}
catch {
    Write-Log "Falha durante a execução: $($_.Exception.Message)" "ERROR"
    Write-Log "===== FIM DA EXECUÇÃO COM ERRO =====" "ERROR"
    exit 1
}
finally {
    Disconnect-FromVBR
}
