try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $property = [Microsoft.VisualBasic.Interaction]::InputBox("Groups property (optionnal):", "List information(s) about every group", "none")
    # Create and display a pop-up with a title, a text and an input set by default as 'No description.'

    try {
        $groups = Get-ADGroup -Filter * -ErrorAction Stop | Select-Object -ExpandProperty Name
        # Get every name of every group

        foreach($groupName in $groups) {

            Write-Host "$groupName infos:"
            # Write a message in terminal

            $infos = Get-ADGroup $groupName -Properties * -ErrorAction Stop
            # Get properties of every group

            if ($property -eq "" -or $property -eq "none") {
                $infos.PSObject.Properties | ForEach-Object {
                # Iterate on every property

                    # $_ is the current object of the forEach

                    Write-Host "- $($_.Name): '$($_.Value)'"
                    # Write a message in terminal
                }
            }
            else
            {
                $infos.PSObject.Properties | ForEach-Object {
                # Iterate on every property

                    $name = $_.Name
                    $value = $_.Value

                    # $_ is the current object of the forEach

                    if ($name -eq $property) {
                        Write-Host "$($name): '$value'"
                        # Write a message in terminal
                    }
                }
            }

            Write-Host ""
            # Write a '\n' in terminal
        }
    }
    catch {
        Write-Host "Error! Failed to list information(s) about group '$groupName'."
        # Write a message in terminal
        Exit
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
