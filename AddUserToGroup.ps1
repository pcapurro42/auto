Import-Module ActiveDirectory
# Import ActiveDirectory library

Add-Type -AssemblyName Microsoft.VisualBasic
# Import a .NET library to display pop-ups

$userExist = ""

while (-not $userExist) {

    $userName = [Microsoft.VisualBasic.Interaction]::InputBox("User name:", "Add a user to a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($userName -eq "") {
        return
    }

    $userExist = Get-ADUser -Filter {SamAccountName -eq $userName}
    # Get infos about a user with the name
}

$groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Add a user to a group", "default")
# Create and display a pop-up with a title, a text and an input set by default as 'default'

if ($groupName -eq "") {
    return
}

$groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
# Get infos about a group with the name

if (-not $groupExist) {
    Write-Host "Error! Failed to add a user to group '$groupName'." -ErrorAction SilentlyContinue
    # Write a message in terminal
    return
}

try {
    Add-ADGroupMember -Identity $groupName -Members $userName
    # Add a user to a group
}
catch {
    Write-Host "Error! Failed to add a user to group '$groupName'."
    # Write a message in terminal
    return
}

Write-Host "User '$userName' successfully added to '$groupName'."
# Write a message in terminal