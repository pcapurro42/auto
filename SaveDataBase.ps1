try
{
    #required for form and popup
    Add-Type -AssemblyName Microsoft.VisualBasic
    Add-Type -AssemblyName System.Windows.Forms

    #create a dialog for select csv file
    Write-Host "starting database backup" -ForegroundColor Cyan
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $SaveFileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $SaveFileDialog.Title = "Select where to save the CSV file"
    $SaveFileDialog.FileName = "AD_Backup.csv"
    $Result = $SaveFileDialog.ShowDialog()
    #check if user select a file
    if ($Result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($SaveFileDialog.FileName)) {
        Write-Host "Invalid file ! Try again !" -ForegroundColor Red
        Exit
    }
    $CsvPath = $SaveFileDialog.FileName
    #check if is a csv file
    if (-Not ($CsvPath -match "\.csv$")) {
        Write-Host "Invalid file format ! Please select a CSV file." -ForegroundColor Red
        Exit
    }
    #select separator
    $Delimiter = [Microsoft.VisualBasic.Interaction]::InputBox("Which separator (, or ;) ?", "CSV Separator", ",")
    if ($Delimiter -ne "," -and $Delimiter -ne ";") {
        Write-Host "Invalid separator ! Choose Only , or ;" -ForegroundColor Red
        Exit
    }
    #ask zhich atribute user want to save
    $Attributes = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the attributes to save:", "Attributes Selection", "Name,SamAccountName,EmailAddress,Title")
    $AttributeList = $Attributes -split "," | ForEach-Object { $_.Trim() }
    Try {
        Write-Host "Fetching users from Active Directory..." -ForegroundColor Cyan
        $Users = Get-ADUser -Filter * -Property $AttributeList | Select-Object $AttributeList
        #check if forest have user
        if ($Users.Count -eq 0) {
            Write-Host "No users found in Active Directory!" -ForegroundColor Red
            Exit
        }
        Write-Host "Saving users to $CsvPath..." -ForegroundColor Yellow
        $Users | Export-Csv -Path $CsvPath -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
        Write-Host "Users successfully saved!" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while retrieving user information: $_" -ForegroundColor Red
        Exit
    }
    #create file for group
    $GroupCsvPath = $CsvPath -replace "\.csv$", "_groups.csv"
    Try {
        Write-Host "Fetching groups from Active Directory..." -ForegroundColor Cyan
        $Groups = Get-ADGroup -Filter * -Property Name, Description | Select-Object Name, Description
        if ($Groups.Count -eq 0) {
            Write-Host "No groups found in Active Directory!" -ForegroundColor Red
            Exit
        }
        Write-Host "Saving groups to $GroupCsvPath..." -ForegroundColor Yellow
        $Groups | Export-Csv -Path $GroupCsvPath -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
        Write-Host "Groups successfully saved!" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while retrieving group information: $_" -ForegroundColor Red
        Exit
    }

    Write-Host "Database backup completed successfully!" -ForegroundColor Cyan
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
