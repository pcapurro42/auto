try
{
    Add-Type -AssemblyName Microsoft.VisualBasic

    Write-Host "Starting user information retrieval process" -ForegroundColor Cyan

    # Retrieve the username
    $UserName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the account name of the user:", "Retrieve User Information", "")
    if ([string]::IsNullOrWhiteSpace($UserName)) {
        Write-Host "Account name is required!" -ForegroundColor Red
        Exit
    }

    # Retrieve the attribute to filter
    $AttributeFilter = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the attribute(s) to filter (e.g., 'givenName, emailAddress'):", "Retrieve User Information", "")
    if ([string]::IsNullOrWhiteSpace($AttributeFilter)) {
        Write-Host "Attribute filter is empty, retrieving all attributes!" -ForegroundColor Yellow
        $AttributeFilter = "*"  # Retrieve all attributes if no filter is given
    }

    # Try to get the user details
    Try {
        $User = Get-ADUser -Identity $UserName -Properties $AttributeFilter -ErrorAction Stop
    } Catch {
        Write-Host "User $UserName not found!" -ForegroundColor Red
        Exit
    }

    # Display the user information
    Write-Host "Information for user: $UserName" -ForegroundColor Yellow
    if ($AttributeFilter -eq "*") {
        # Display all available properties
        $User | Format-List *
    } else {
        # Display only the requested attributes
        $User | Select-Object $AttributeFilter | Format-List
    }

    Write-Host "User information retrieval process completed." -ForegroundColor Green
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
