if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
Add-Type -AssemblyName Microsoft.VisualBasic

Write-Host "starting user attribute modification process" -ForegroundColor Cyan
$UserName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name of the user:", "Edit User Attribute", "")
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
$AttributeName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the attribute name to modify :", "Edit User Attribute", "")
if ([string]::IsNullOrWhiteSpace($AttributeName)) {
    Write-Host "Attribute name is required!" -ForegroundColor Red
    Exit
}
$NewValue = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the new value for the attribute $AttributeName:", "Edit User Attribute", "")
if ([string]::IsNullOrWhiteSpace($NewValue)) {
    Write-Host "New value is required!" -ForegroundColor Red
    Exit
}
Try {
    Set-ADUser -Identity $UserName -Replace @{$AttributeName = $NewValue}
    Write-Host "Attribute $AttributeName for user $UserName has been updated to '$NewValue' successfully" -ForegroundColor Green
} Catch {
    Write-Host "An error occurred while modifying the attribute: $_" -ForegroundColor Red
}
