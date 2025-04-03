try
{
    Add-Type -AssemblyName Microsoft.VisualBasic

    Write-Host "starting user creation" -ForegroundColor Cyan

    # Get first and last name
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

    # Create SamAccountName
    $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()

    # Check the validity of the SamAccountName
    if ($SamAccountName -match '[^a-zA-Z0-9-_]') {
        Write-Host "SamAccountName contains invalid characters!" -ForegroundColor Red
        Exit
    }

    $DomainName = "domolia.local"
    $Email = "$FirstName.$LastName@$DomainName".ToLower()
    $UserPrincipalName = $Email

    # Use the CN=Users container
    $OUPath = "CN=Users,DC=Domolia,DC=local"
    Write-Host "You entered the following OUPath: $OUPath" -ForegroundColor Yellow

    # Create a secure password
    $SecurePwd = ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force

    # Users informations
    $UserParams = @{
        Name               = "$FirstName $LastName"
        GivenName          = $FirstName
        Surname            = $LastName
        SamAccountName     = $SamAccountName
        UserPrincipalName  = $UserPrincipalName
        EmailAddress       = $Email
        Path               = $OUPath  # Use the CN=Users container
        Enabled            = $true
        PasswordNeverExpires = $false
        AccountPassword    = $SecurePwd
        ChangePasswordAtLogon = $true
    }

    # Create the user
    Try {
        Write-Host "Creating user $FirstName $LastName ($SamAccountName)..." -ForegroundColor Yellow
        New-ADUser @UserParams
        Write-Host "User $FirstName $LastName created successfully!" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while creating the user: $_" -ForegroundColor Red
        Exit
    }

    # add the user to the group
    $GroupName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the group to add the user to (leave empty if none):", "User Creation", "")
    if (-not [string]::IsNullOrWhiteSpace($GroupName)) {
        # Check if the group exists
        if (-not (Get-ADGroup -Filter {Name -eq $GroupName})) {
            Write-Host "Group '$GroupName' does not exist!" -ForegroundColor Red
            Exit
        }
        # Add the user to the group
        Try {
            Add-ADGroupMember -Identity $GroupName -Members $SamAccountName
            Write-Host "User added to group $GroupName successfully!" -ForegroundColor Green
        } Catch {
            Write-Host "An error occurred while adding the user to the group: $_" -ForegroundColor Red
            Exit
        }
    } else {
        Write-Host "No group provided. User was not added to any group." -ForegroundColor Yellow
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}