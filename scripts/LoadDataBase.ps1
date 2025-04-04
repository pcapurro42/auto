try
{
    #required for popup and form
    Add-Type -AssemblyName Microsoft.VisualBasic
    Add-Type -AssemblyName System.Windows.Forms

    Write-Host "starting database loading" -ForegroundColor Cyan

    #create dialog for select csv file
    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $FileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $FileDialog.Title = "Select the CSV file to load"
    $Result = $FileDialog.ShowDialog()
    #verif if is a csv file
    if ($Result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrWhiteSpace($FileDialog.FileName)) {
        Write-Host "Invalid file ! Try again !" -ForegroundColor Red
        Exit
    }
    $CsvPath = $FileDialog.FileName
    if (-Not ($CsvPath -match "\.csv$")) {
        Write-Host "Invalid file format ! Please select a CSV file." -ForegroundColor Red
        Exit
    }
    #select a separator
    $Delimiter = [Microsoft.VisualBasic.Interaction]::InputBox("Which separator (, or ;) ?", "CSV Separator", ",")
    if ($Delimiter -ne "," -and $Delimiter -ne ";") {
        Write-Host "Invalid separator ! Choose Only , or ;" -ForegroundColor Red
        Exit
    }
    #stock csv file information in UserDAta
    Try {
        $UserData = Import-Csv -Path $CsvPath -Delimiter $Delimiter -ErrorAction Stop
    } Catch {
        Write-Host "Error loading CSV file: $_" -ForegroundColor Red
        Exit
    }
    #create User if not exist
    foreach ($User in $UserData) {           
        Try {

            $var = $User.SamAccountName
            $UserExists = Get-ADUser -Filter {SamAccountName -eq $var} -ErrorAction SilentlyContinue

            if (-Not $UserExists) {
                Write-Host "Creating user: $($User.Name)..." -ForegroundColor Yellow
                New-ADUser -Name $User.Name `
                        -SamAccountName $User.SamAccountName `
                        -UserPrincipalName $User.UserPrincipalName `
                        -GivenName $User.GivenName `
                        -Surname $User.Surname `
                        -Enabled $true `
                        -PasswordNeverExpires $true `
                        -AccountPassword (ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force) `
                        -ChangePasswordAtLogon $false `
                        -ErrorAction Stop
                Write-Host "User $($User.Name) created successfully!" -ForegroundColor Green
            }
        } Catch {
            Write-Host "An error occurred while creating user $($User.Name): $_" -ForegroundColor Red
            Exit
        }
    }
    Write-Host "Finish for users !" -ForegroundColor Green
    #check if csv file _group exist

    $GroupCsvPath = $CsvPath -replace '\.csv$', '_groups.csv'
    if (Test-Path $GroupCsvPath) {
        Try {
            $GroupData = Import-Csv -Path $GroupCsvPath -Delimiter $Delimiter -ErrorAction Stop
        } Catch {
            Write-Host "Error loading group CSV file: $_" -ForegroundColor Red
            Exit
        }

        $domain = (Get-ADDomain -ErrorAction Stop).DistinguishedName
        $unitPath = "CN=Users,$domain"

        #try to create group if not exist in AD
        foreach ($Group in $GroupData) {
            Try {
                $var = $Group.Name
                $GroupExists = Get-ADGroup -Filter {Name -eq $var} -ErrorAction SilentlyContinue
                if (-Not $GroupExists) {
                    Write-Host "Creating group: $($Group.Name)..." -ForegroundColor Yellow
                    New-ADGroup -Name $var `
                                -GroupScope Global `
                                -Description $Group.Description `
                                -Path $unitPath `
                                -ErrorAction Stop
                    Write-Host "Group $($Group.Name) created successfully!" -ForegroundColor Green
                }
            } Catch {
                Write-Host "An error occurred while creating group $($Group.Name): $_" -ForegroundColor Red
                Exit
            }
        }
    }
    Write-Host "Database loaded successfully !" -ForegroundColor Cyan
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
