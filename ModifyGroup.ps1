try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Modify a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupName -eq "") {
        Exit
    }

    $groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to modify group '$groupName'."
        # Write a message in terminal
        Exit
    }

    while ($toModify -ne "1" -and $toModify -ne "2" -and $toModify -ne "3" -and $toModify -ne "") {
        $toModify = [Microsoft.VisualBasic.Interaction]::InputBox("Select an attribute to modify:`n`n1 - Name `n2 - Organisation unit `n3 - Description", "Modify a group", "1")
        # Create and display a pop-up with a title, a text and an input set by default as '1'
    }

    if ($toModify -eq "") {
        Exit
    }

    try {

        if ($toModify -eq "1") {

            $newName = ""
            while ($newName -eq "") {
                $newName = [Microsoft.VisualBasic.Interaction]::InputBox("New group name:", "Modify a group", "default")
                # Create and display a pop-up with a title, a text and an input set by default as 'default'
            }

            $groupExist = Get-ADGroup -Filter "Name -eq '$newName'" -ErrorAction SilentlyContinue
            # Get infos about a group with the name

            if ($groupExist) {
                Write-Host "Failed to modify '$groupName'."
                # Write a message in terminal
                Exit
            }

            Get-ADGroup -Identity $groupName -ErrorAction Stop | Rename-ADObject -NewName $newName -ErrorAction Stop
            Set-ADGroup -Identity $groupName -SamAccountName $newName -ErrorAction Stop
            # Modify both the displayed group name and the other group name
        }
        if ($toModify -eq "2") {

            $newUnit = ""
            while ($newUnit -eq "") {
                $newUnit = [Microsoft.VisualBasic.Interaction]::InputBox("New group unit:", "Modify a group", "default")
                # Create and display a pop-up with a title, a text and an input set by default as 'default'
            }

            $unitExist = Get-ADOrganizationalUnit -Filter "Name -eq '$newUnit'" -ErrorAction SilentlyContinue
            # Get infos about a organizational unit

            if (-not $unitExist) {
                Write-Host "Failed to modify '$groupName'."
                # Write a message in terminal
                Exit 
            }

            $domain = (Get-ADDomain -ErrorAction Stop).DistinguishedName

            $unitPath = (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction Stop).DistinguishedName
            $newUnitPath = "OU=$newUnit,$domain"
            # Unit path must have the name of the unit and the domain name

            Move-ADObject -Identity $unitPath -TargetPath $newUnitPath
            # Modify the organization unit of the group
        }

        if ($toModify -eq "3") {

            $newDescription = ""
            while ($newDescription -eq "") {
                $newDescription = [Microsoft.VisualBasic.Interaction]::InputBox("New group description:", "Modify a group", "No description.")
                # Create and display a pop-up with a title, a text and an input set by default as 'No description.'
            }
            Set-ADGroup -Identity $groupName -Description $newDescription -ErrorAction Stop
            # Modify the description of the name
        }

    }
    catch {
        Write-Host "Failed to modify '$groupName'."
        # Write a message in terminal
        Exit
    }

    Write-Host "Group '$groupName' successfully modified."
    # Write a message in terminal
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
