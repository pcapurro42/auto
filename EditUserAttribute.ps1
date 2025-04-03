try
{
    Add-Type -AssemblyName Microsoft.VisualBasic

    Write-Host "Starting user attribute modification process" -ForegroundColor Cyan

    # Retrieve the username to modify
    $UserName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name of the user:", "Edit User Attribute", "")
    if ([string]::IsNullOrWhiteSpace($UserName)) {
        Write-Host "Account name is required!" -ForegroundColor Red
        Exit
    }

    # Try to get the user details from AD
    Try {
        $User = Get-ADUser -Identity $UserName -Properties *
    } Catch {
        Write-Host "User $UserName not found!" -ForegroundColor Red
        Exit
    }

    # Ask for the attribute to modify
    $AttributeName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the attribute name to modify:", "Edit User Attribute", "")
    if ([string]::IsNullOrWhiteSpace($AttributeName)) {
        Write-Host "Attribute name is required!" -ForegroundColor Red
        Exit
    }

    # Ask for the new value of the attribute
    $NewValue = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the new value for the attribute $AttributeName :", "Edit User Attribute", "")
    if ([string]::IsNullOrWhiteSpace($NewValue)) {
        Write-Host "New value is required!" -ForegroundColor Red
        Exit
    }

    # Map common attribute names to their LDAP equivalents
    $AttributeMap = @{
        'Surname'       = 'sn'
        'GivenName'     = 'givenName'
        'DisplayName'   = 'displayName'
        'EmailAddress'  = 'mail'
        'Title'         = 'title'
        'Department'    = 'department'
        'Manager'       = 'manager'
        'Phone'         = 'telephoneNumber'
        'StreetAddress' = 'streetAddress'
    }

    # Check if the entered attribute name is in the map
    if ($AttributeMap.ContainsKey($AttributeName)) {
        $AttributeName = $AttributeMap[$AttributeName]
    } else {
        Write-Host "The attribute '$AttributeName' is either invalid or not modifiable." -ForegroundColor Red
        Exit
    }

    # Try to update the attribute
    Try {
        # Update the attribute using the mapped name
        Set-ADUser -Identity $UserName -Replace @{ $AttributeName = $NewValue }
        Write-Host "Attribute $AttributeName for user $UserName has been updated to '$NewValue' successfully." -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while modifying the attribute: $_" -ForegroundColor Red
        Exit
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
