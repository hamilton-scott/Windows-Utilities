##This script will prompt you for a text file, import the names of a device and add them to a group that you specify.  There is no need for a GUID/Device ID/Azure Device ID, or anything else. Just displayname. 

###################################################################################
#                       Adjust these variables accordingly                        #
###################################################################################
$azgroup = "AzureAD/Entra Group Name Here"

###################################################################################

#lets check to see if we have the Azure AD module installed...

if (Get-Module -ListAvailable -Name Azuread) {
    Write-Host "AzureAD Module exists, loading"
	Import-Module Azuread 
	} 
else {
    #no module, does user hae admin rights?
    Write-Host "AzureAD Module does not exist please install`r`n with install-module azuread" -ForegroundColor Red
	
		if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
		[Security.Principal.WindowsBuiltInRole] "Administrator")) {
			Write-Host "Insufficient permissions to install module. Please run as an administrator and try again." -ForegroundColor DarkYellow
            return(0)
		    }
		else {
		    Write-Host "Attempting to install Azure AD module" -ForegroundColor Cyan
		    Install-Module AzureAD -Confirm:$False -Force
        }
	
}
#This might not be necessary? 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
# OK, lets pick the file..
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.txt)|*.txt|TextFile (*.txt)|*.txt'
}
$null = $FileBrowser.ShowDialog()
$machines = get-content $FileBrowser.FileName


#ok, if we got here, we must have the Azure AD module installed, lets connect...
Connect-AzureAD
write-host "Getting Object ID of group.." -ForegroundColor Green
$objid = (get-azureadgroup -Filter "DisplayName eq '$azgroup'" ).objectid
write-host "Getting group members (We dont want duplicates!).." -ForegroundColor Cyan
$members = Get-AzureADGroupMember -ObjectId $objid -all $true | select displayname

foreach ($machine in $machines) {


    $refid = Get-AzureADDevice -Filter "DisplayName eq '$machine'" 
    ############################################
    foreach($ref in $refid){ #just in case there are stale AZ AD objects throwing multiple matches!
    $result = $null
    $result =  ($members -match $machine) #is it already in the group?
    if(!$result){
        try{
            Write-host "Adding " $ref.displayname -ForegroundColor Cyan
            Add-AzureADGroupMember -ObjectId $objid -RefObjectId $ref.objectid
            }
        catch{
            write-host "An error occured for " $ref.displayname  -ForegroundColor Red
            }
        }
        else
        {
            write-host $machine " is already a member" -ForegroundColor Green
        }
    }
}
