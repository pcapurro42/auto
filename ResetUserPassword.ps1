try
{
    Add-Type -AssemblyName Microsoft.VisualBasic

    Write-Host "starting password reset process" -ForegroundColor Cyan

    # Ask for the user's account name
    $UserName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name of the user:", "Password Reset", "")
    if ([string]::IsNullOrWhiteSpace($UserName)) {
        Write-Host "Account name is required!" -ForegroundColor Red
        Exit
    }

    # Try to find the user in Active Directory
    Try {
        $User = Get-ADUser -Identity $UserName -ErrorAction Stop
    } Catch {
        Write-Host "User $UserName not found!" -ForegroundColor Red
        Exit
    }

    # Ask for the new password
    $NewPassword = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the new password for the user:", "Password Reset", "")
    if ([string]::IsNullOrWhiteSpace($NewPassword)) {
        Write-Host "New password is required" -ForegroundColor Red
        Exit
    }

    # Convert the password to secure format
    $SecurePwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force

    # Try to reset the password and force password change at next logon
    Try {
        Set-ADAccountPassword -Identity $UserName -NewPassword $SecurePwd -Reset -ErrorAction Stop
        Set-ADUser -Identity $UserName -ChangePasswordAtLogon $true -ErrorAction Stop
        Write-Host "Password reset successful for $UserName! He will need to change it at the next login." -ForegroundColor Green
    } Catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Exit
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}