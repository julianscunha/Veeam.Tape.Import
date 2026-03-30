#07/2022 - Versão 1.0
#Descrição: script importa automaticamente fita para o Free Pool caso esteja vazio.
#Recomendado incluir no Schedule Task

#Escreva o nome da Library aqui
$library = "New-AWS Gateway-VTL 0100"
#Digite o local de armazenamento do arquivo de controle
$path = "c:\temp\tape.log"

#>>> Não mexer daqui em diante
$tape = Get-VBRTapeMedium -MediaPool "Free"
Start-VBRTapeInventory -Medium $tape
Start-Sleep -Seconds 10
Get-VBRTapeLibrary -name $library | Get-VBRTapeMediaPool -Name "Free" > $path
$capacity = cat $path | Select-String -Pattern 'Capacity' -CaseSensitive -SimpleMatch
$number = $capacity -replace '\D+(\d+)','$1'

if ($number -gt 0) {
	Write-Host "Tem fita no Free Pool."
} else {
	Import-VBRTapeMedium -Library $library
	Start-Sleep -Seconds 10
	Get-VBRTapeMedium -MediaPool “Unrecognized” | Move-VBRTapeMedium -MediaPool “Free”
}
# para futuras versões - Mover fitas expiradas para o free pool
# $free = Get-VBRTapeMedium -Library $library | ?{$_.IsExpired}
# Move-VBRTapeMedium -Medium $free -MediaPool "Free"
