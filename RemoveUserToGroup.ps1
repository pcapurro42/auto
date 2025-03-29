Import-Module ActiveDirectory
# Import ActiveDirectory library

Add-Type -AssemblyName Microsoft.VisualBasic
# Import a .NET library to display pop-ups

$userExist = ""

while (-not $userExist) {

    $userName = [Microsoft.VisualBasic.Interaction]::InputBox("User name:", "Remove a user from a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($userName -eq "") {
        return
    }

    $userExist = Get-ADUser -Filter {SamAccountName -eq $userName}
    # Check if a user exist by searching the name
}

$groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Remove a user from a group", "default")
# Create and display a pop-up with a title, a text and an input set by default as 'none'

if ($groupName -eq "") {
    return
}

$groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
# Get infos about a group with the name

if (-not $groupExist) {
    Write-Host "Error! Failed to remove a user from group '$groupName'."
    # Write a message in terminal
    return
}

$isMember = Get-ADGroupMember $groupName | Where-Object { $_.SamAccountName -eq $userName }

if (-not $isMember) {
    Write-Host "Error! Failed to remove a user from group '$groupName'."
    # Write a message in terminal
    return
}

try {
    Remove-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false
    # Remove the member of a group
    # Skip the confirmation
}
catch {
    Write-Host "Error! Failed to remove a user from group '$groupName'."
    # Write a message in terminal
    return
}

Write-Host "User '$userName' successfully removed from '$groupName'."
# Write a message in terminal