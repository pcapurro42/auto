if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
Add-Type -AssemblyName Microsoft.VisualBasic

Write-Host "starting password reset process" -ForegroundColor Cyan
$UserName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name of the user:", "Password Reset", "")
if ([string]::IsNullOrWhiteSpace($UserName)) {
    Write-Host "Account name is required!" -ForegroundColor Red
    Exit
}
Try {
    $User = Get-ADUser -Identity $UserName -ErrorAction Stop
} Catch {
    Write-Host "User $UserName not found!" -ForegroundColor Red
    Exit
}
$NewPassword = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the new password for the user:", "Password Reset", "")
if ([string]::IsNullOrWhiteSpace($NewPassword)) {
    Write-Host "New password is required" -ForegroundColor Red
    Exit
}
$SecurePwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force
Try {
    Set-ADAccountPassword -Identity $UserName -NewPassword $SecurePwd -Reset
    Set-ADUser -Identity $UserName -ChangePasswordAtLogon $true
    Write-Host "Password reset successful for $UserName! he will need to change it at the next login." -ForegroundColor Green
} Catch {
    Write-Host "Error : $_" -ForegroundColor Red
}
