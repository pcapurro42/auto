try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Create a new group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupName -eq "") {
        Exit
    }

    $groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if ($groupExist) {
        Write-Host "Error! Failed to create group '$groupName'."
        # Write a message in terminal
        Exit
    }

    $groupUnit = [Microsoft.VisualBasic.Interaction]::InputBox("Group unit:", "Create a new group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupUnit -eq "") {
        Exit
    }

    $groupUnitExist = Get-ADOrganizationalUnit -Filter 'Name -eq $groupUnit' -ErrorAction SilentlyContinue
    # Get infos about a unit with the name

    if (-not $groupUnitExist) {
        Write-Host "Error! Failed to create group '$groupName'."
        # Write a message in terminal
        Exit
    }

    $domain = (Get-ADDomain).DistinguishedName
    $unitPath = "OU=$groupUnit,$domain"
    # Unit path must have the name of the unit and the domain name

    while ($groupScope -ne "1" -and $groupScope -ne "2" -and $groupScope -ne "3") {
        $groupScope = [Microsoft.VisualBasic.Interaction]::InputBox("Group scope:`n`n1 - Global `n2 - Universal `n3 - DomainLocal", "Create a new group", "1")
        # Create and display a pop-up with a title, a text and an input set by default as 'default'
    }

    if ($groupScope -eq "") {
        Exit
    }

    if ($groupScope -eq "1") {
        $groupScope = "Global"
    }
    if ($groupScope -eq "2") {
        $groupScope = "Universal"
    }
    if ($groupScope -eq "3") {
        $groupScope = "DomainLocal"
    }

    $groupDescription = [Microsoft.VisualBasic.Interaction]::InputBox("Description:", "Create a new group", "No description.")
    # Create and display a pop-up with a title, a text and an input set by default as ''No description.'

    if ($groupDescription -eq "") {
        Exit
    }

    try {
        New-ADGroup -Name $groupName `
            -GroupCategory Security `
            -Path $unitPath `
            -GroupScope $groupScope `
            -Description $groupDescription
        # Create a new group
    }
    catch {
        Write-Host "Error! Failed to create group '$groupName'."
        # Write a message in terminal
        Exit
    }

    Write-Host "Group '$groupName' successfully created."
    # Write a message in terminal
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
