if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
Add-Type -AssemblyName Microsoft.VisualBasic

Write-Host "starting user creation" -ForegroundColor Cyan
$FirstName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter first name:", "User Creation", "")
if ([string]::IsNullOrWhiteSpace($FirstName)) {
    Write-Host "First name is required!" -ForegroundColor Red
    Exit
}
$LastName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter last name:", "User Creation", "")
if ([string]::IsNullOrWhiteSpace($LastName)) {
    Write-Host "Last name is required!" -ForegroundColor Red
    Exit
}

$SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$DomainName = "domolia.local"
$Email = "$FirstName.$LastName@$DomainName".ToLower()
$UserPrincipalName = $Email
$OUPath = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Organization to join :", "User Creation", "")
if ([string]::IsNullOrWhiteSpace($OUPath)) {
    Write-Host "Organization Unit is required!" -ForegroundColor Red
    Exit
}
$GroupName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter group to join :", "User Creation", "")
if ([string]::IsNullOrWhiteSpace($GroupName)) {
    Write-Host "Group name is required!" -ForegroundColor Red
    Exit
}
$SecurePwd = ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force
$UserParams = @{
    Name               = "$FirstName $LastName"
    GivenName         = $FirstName
    Surname           = $LastName
    SamAccountName    = $SamAccountName
    UserPrincipalName = $UserPrincipalName
    EmailAddress      = $Email
    Path              = $OUPath
    Enabled           = $true
    PasswordNeverExpires = $true
    AccountPassword   = $SecurePwd
    ChangePasswordAtLogon = $true
}
Try {
    Write-Host "Creating user $FirstName $LastName ($SamAccountName)..." -ForegroundColor Yellow
    New-ADUser @UserParams
    Write-Host "User $FirstName $LastName created successfully!" -ForegroundColor Green
} Catch {
    Write-Host "An error occurred while creating the user: $_" -ForegroundColor Red
    Exit
}
Try {
    Add-ADGroupMember -Identity $GroupName -Members $SamAccountName
    Write-Host "User added to group $GroupName successfully!" -ForegroundColor Green
} Catch {
    Write-Host "An error occurred while adding the user to the group: $_" -ForegroundColor Red
}
