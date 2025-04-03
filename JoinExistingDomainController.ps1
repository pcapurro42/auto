try
{
    #required for popup
    Add-Type -AssemblyName Microsoft.VisualBasic
    Write-Host "checking AD installation" -ForegroundColor Cyan
    #Try if ad is installed
    $adFeature = Get-WindowsFeature -Name AD-Domain-Services
    if (-Not $adFeature.Installed) {
        Write-Host "AD not installed ! Start ADPackageInstallor.ps1 before." -ForegroundColor Red
        Exit
    }
    #ask information to join domain
    $DomainName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain address to join:", "Domain Configuration", "Domolia.local")
    if ([string]::IsNullOrWhiteSpace($DomainName)) {
        Write-Host "Domain address is required!" -ForegroundColor Red
        Exit
    }
    $AdminUser = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain admin username:", "Domain Admin Credentials", "AdminDomolia")
    if ([string]::IsNullOrWhiteSpace($AdminUser)) {
        Write-Host "Admin username is required!" -ForegroundColor Red
        Exit
    }
    $AdminPwd = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the password for domain admin:", "Domain Admin Credentials", "")
    if ([string]::IsNullOrWhiteSpace($AdminPwd)) {
        Write-Host "Admin password is required!" -ForegroundColor Red
        Exit
    }
    $SecurePwd = ConvertTo-SecureString $AdminPwd -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ($AdminUser, $SecurePwd)

    #try to join
    Write-Host "starting server promotion" -ForegroundColor Cyan
    Try {
        Install-ADDSDomainController `
            -DomainName $DomainName `
            -Credential $Credentials `
            -InstallDNS `
            -Force

        Write-Host "Install finish ! Your computer will restart in 10 sec" -ForegroundColor Green
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } Catch {
        Write-Host "An error occurred during the promotion process: $_" -ForegroundColor Red
        Exit
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
