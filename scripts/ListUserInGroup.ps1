try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Group name:", "List users of a group", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupName -eq "") {
        Exit
    }

    $groupExist = ""
    $groupExist = Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to list users from group '$groupName'."
        # Write a message in terminal
        Exit
    }

    try {

        $users = Get-ADGroupMember $groupName -ErrorAction Stop | Where-Object { $_.objectClass -eq "user" } | Select-Object -ExpandProperty SamAccountName
        # Get infos about a group
        # Redirecting the infos to Where object which filter only the objects of type 'user'
        # Select only the names of the users

        foreach ($userName in $users) {
            Write-Host "- $userName"
            # Write a user name in terminal
        }
    }
    catch {

        Write-Host "Error! Failed to list users from group '$groupName'."
        # Write a message in terminal
        Exit
    }
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
