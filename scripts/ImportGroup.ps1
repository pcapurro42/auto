try
{
    Import-Module ActiveDirectory
    # Import ActiveDirectory library

    Add-Type -AssemblyName Microsoft.VisualBasic
    # Import a .NET library to display pop-ups

    $groupNameA = [Microsoft.VisualBasic.Interaction]::InputBox("Group A:", "Import users from group A to group B", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupNameA -eq "") {
        Exit
    }

    $groupExist = ""
    $groupExist = Get-ADGroup -Filter "Name -eq '$groupNameA'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to import users from group '$groupNameA'."
        # Write a message in terminal
        Exit
    }

    $groupNameB = [Microsoft.VisualBasic.Interaction]::InputBox("Group B:", "Import users from group A to group B", "default")
    # Create and display a pop-up with a title, a text and an input set by default as 'default'

    if ($groupNameB -eq "") {
        Exit
    }

    $groupExist = ""
    $groupExist = Get-ADGroup -Filter "Name -eq '$groupNameB'" -ErrorAction SilentlyContinue
    # Get infos about a group with the name

    if (-not $groupExist) {
        Write-Host "Error! Failed to import users from group '$groupNameA' to '$groupNameB'."
        # Write a message in terminal
        Exit
    }

    try {

        $users = Get-ADGroupMember $groupNameA -ErrorAction Stop | Where-Object { $_.objectClass -eq "user" } | Select-Object -ExpandProperty SamAccountName
        # Get infos about a group
        # Redirecting the infos to Where object which filter only the objects of type 'user'
        # Select only the names of the users

        foreach ($userName in $users) {
            Add-ADGroupMember -Identity $groupNameB -Members $userName -ErrorAction Stop
            # Adding the current member of groupA to groupB
        }
    }
    catch {

        Write-Host "Error! Failed to import users from group '$groupNameA' to '$groupNameB'."
        # Write a message in terminal
        Exit
    }

    Write-Host "Successfully imported users from '$groupNameA' to '$groupNameB'."
    # Write a message in terminal
}
catch
{
    Write-Host "Error! Unexpected event."
    Exit
}
