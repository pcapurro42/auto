try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "List information(s) about a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupName -eq "") {
        Exit
    }

    $groupExist = ""
    $groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to list information(s) about group '$groupName'."
        # Write a message in terminal
        Exit
    }

    $property = [Microsoft.VisualBasic.Interaction]::InputBox("Group property (optionnal):", "List information(s) about a group", "none")
    # Create and display a pop-up with a title, a text and an input set by default as 'none'

    try {
        $infos = Get-ADGroup $groupName -Properties * -ErrorAction Stop
        # Get every property of the group

        if ($property -eq "" -or $property -eq "none") {

            $infos.PSObject.Properties | ForEach-Object {
            # Iterate on every property

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
