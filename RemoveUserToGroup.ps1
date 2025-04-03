try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $userExist = ""

    while (-not $userExist) {

        $userName = [Microsoft.VisualBasic.Interaction]::InputBox("User name:", "Remove a user from a group", "default")
        # Create and display a pop-up with a title, a text and an input set by default as 'default'

        if ($userName -eq "") {
            Exit
        }

        $userExist = Get-ADUser -Filter {SamAccountName -eq $userName} -ErrorAction Stop
        # Check if a user exist by searching the name
    }

    $groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "Remove a user from a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'none'

    if ($groupName -eq "") {
        Exit
    }

    $groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to remove a user from group '$groupName'."
        # Write a message in terminal
        Exit
    }

    $isMember = Get-ADGroupMember $groupName -ErrorAction Stop | Where-Object { $_.SamAccountName -eq $userName }

    if (-not $isMember) {
        Write-Host "Error! Failed to remove a user from group '$groupName'."
        # Write a message in terminal
        Exit
    }

    try {
        Remove-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false -ErrorAction Stop
        # Remove the member of a group
        # Skip the confirmation
    }
    catch {
        Write-Host "Error! Failed to remove a user from group '$groupName'."
        # Write a message in terminal
        Exit
    }

    Write-Host "User '$userName' successfully removed from '$groupName'."
    # Write a message in terminal
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
