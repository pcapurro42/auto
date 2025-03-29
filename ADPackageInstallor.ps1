if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
Write-Host "Install started" -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

$adFeature = Get-WindowsFeature -Name AD-Domain-Services
if ($adFeature.Installed)
{
    Write-Host "AD Installed !" -ForegroundColor Green
}
else
{
    Write-Host "Fatal Error try again !" -ForegroundColor Red
    Exit
}
Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature -Verbose
$rsatFeature = Get-WindowsFeature -Name RSAT-AD-Tools
if ($rsatFeature.Installed) 
{
    Write-Host "Tool installed  !" -ForegroundColor Green
} else 
{
    Write-Host "Tools install failed !" -ForegroundColor Yellow
}
Write-Host "Installed succesfully !" -ForegroundColor Cyan