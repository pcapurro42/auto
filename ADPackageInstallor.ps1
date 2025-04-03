Try
{
    Write-Host "Install started" -ForegroundColor Cyan
    #Start install AD
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

    #VERIF IF OK
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
    #install dependence
    Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature -Verbose
    #verif if ok
    $rsatFeature = Get-WindowsFeature -Name RSAT-AD-Tools
    if ($rsatFeature.Installed) 
    {
        Write-Host "Tool installed  !" -ForegroundColor Green
    } else 
    {
        Write-Host "Tools install failed !" -ForegroundColor Yellow
    }
    Write-Host "Installed succesfully !" -ForegroundColor Cyan
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}

