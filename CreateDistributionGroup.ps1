Import-Module ActiveDirectory
# Import ActiveDirectory library

Add-Type -AssemblyName Microsoft.VisualBasic
# Import a .NET library to display pop-ups

$groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Create a new distribution group", "default")
# Create and display a pop-up with a title, a text and an input set by default as 'default'

if ($groupName -eq "") {
    return
}

$groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
# Get infos about a group with the name

if ($groupExist) {
    Write-Host "Error! Failed to create distribution group '$groupName'."
    # Write a message in terminal
    return
}

$groupUnit = [Microsoft.VisualBasic.Interaction]::InputBox("Group unit:", "Create a new distribution group", "default")
# Create and display a pop-up with a title, a text and an input set by default as 'default'

if ($groupUnit -eq "") {
    return
}

$groupUnitExist = Get-ADOrganizationalUnit -Filter 'Name -eq $groupUnit' -ErrorAction SilentlyContinue
# Get infos about a organizational unit with the name

if (-not $groupUnitExist) {
    Write-Host "Error! Failed to create distribution group '$groupName'."
    # Write a message in terminal
    return
}

$domain = (Get-ADDomain).DistinguishedName
$unitPath = "OU=$groupUnit,$domain"
# Unit path must have the name of the unit and the domain name

while ($groupScope -ne "1" -and $groupScope -ne "2" -and $groupScope -ne "3") {
    $groupScope = [Microsoft.VisualBasic.Interaction]::InputBox("Group scope:`n`n1 - Global `n2 - Universal `n3 - DomainLocal", "Create a new distribution group", "1")
    # Create and display a pop-up with a title, a text and an input set by default as '1'
}

if ($groupScope -eq "") {
    return
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

$groupDescription = [Microsoft.VisualBasic.Interaction]::InputBox("Description:", "Create a new distribution group", "No description.")
# Create and display a pop-up with a title, a text and an input set by default as '1'

if ($groupDescription -eq "") {
    return
}

try {
    New-ADGroup -Name $groupName `
        -GroupCategory Distribution `
        -Path $unitPath `
        -GroupScope $groupScope `
        -Description $groupDescription
    # Create a new distribution group
    # ` is a \n
}
catch {
    Write-Host "Error! Failed to create distribution group '$groupName'."
    # Write a message in terminal
    return
}

Write-Host "Distribution group '$groupName' successfully created."
# Write a message in terminal