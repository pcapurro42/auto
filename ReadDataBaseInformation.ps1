try
{
    Add-Type -AssemblyName Microsoft.VisualBasic

    Write-Host "Starting database information retrieval process" -ForegroundColor Cyan

    # Retrieve the account name to filter the users
    $AccountNameFilter = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name filter (e.g., 'jdoe' or 'domain\*'):", "Retrieve User Information", "")
    if ([string]::IsNullOrWhiteSpace($AccountNameFilter)) {
        Write-Host "Account name filter is required!" -ForegroundColor Red
        Exit
    }

    # Retrieve the attribute to filter (optional)
    $AttributeFilter = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the attribute(s) to filter (e.g., 'givenName, emailAddress'):", "Retrieve User Information", "")
    if ([string]::IsNullOrWhiteSpace($AttributeFilter)) {
        Write-Host "Attribute filter is empty, retrieving all attributes!" -ForegroundColor Yellow
        $AttributeFilter = "*"  # Retrieve all attributes if no filter is given
    }

    # Try to get the user details from AD based on the account name filter for domain
    Try {
        $forestName = (Get-ADForest).Name
        $Users = Get-ADUser -Filter {SamAccountName -like $AccountNameFilter} -Server $forestName -Properties $AttributeFilter -ErrorAction Stop
    } Catch {
        Write-Host "Error retrieving users: $_" -ForegroundColor Red
        Exit
    }

    # Display the user information for each user
    Write-Host "Information retrieval process completed for users matching '$AccountNameFilter'" -ForegroundColor Yellow

    foreach ($User in $Users) {
        Write-Host "Information for user: $($User.SamAccountName)" -ForegroundColor Cyan
        if ($AttributeFilter -eq "*") {
            # Display all available properties
            $User | Format-List *
        } else {
            # Display only the requested attributes
            $User | Select-Object $AttributeFilter | Format-List
        }
    }

    Write-Host "All user information retrieval completed." -ForegroundColor Green
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
