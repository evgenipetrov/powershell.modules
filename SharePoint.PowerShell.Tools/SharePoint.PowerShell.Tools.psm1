<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.144
	 Created on:   	10/9/2017 6:56 AM
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	SharePoint.PowerShell.Tools.psm1
	-------------------------------------------------------------------------
	 Module Name: SharePoint.PowerShell.Tools
	===========================================================================
#>



<#
	.SYNOPSIS
		Copy a SharePoint library
	
	.DESCRIPTION
		This commandlet can copy a sharepoint library. The copy can be between 2 different webs or even site collections.
	
	.PARAMETER SourceWeb
		A description of the SourceWeb parameter.
	
	.PARAMETER DestinationWeb
		A description of the DestinationWeb parameter.
	
	.PARAMETER SourceLibraryTitle
		A description of the SourceLibraryTitle parameter.
	
	.PARAMETER DestinationLibraryTitle
		A description of the DestinationLibraryTitle parameter.
	
	.EXAMPLE
				PS C:\> Copy-SPTLibrary -SourceWeb 'Value1' -SourceLibraryTitle 'Value2' -DestinationLibraryTitle 'Value3'
	
	.NOTES
		Additional information about the function.
#>
function Copy-SPTLibrary {
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]$SourceWebUrl,
		[Parameter(Mandatory = $true)]
		[String]$SourceLibraryTitle,
		[Parameter(Mandatory = $false)]
		[String]$DestinationWebUrl,
		[Parameter(Mandatory = $true)]
		[String]$DestinationLibraryTitle,
        [String[]]$FolderList,
		[switch]$Overwrite,
		[string]$LogFilePath
	)
	
	if ($DestinationWebUrl -eq $null) {
		$DestinationWebUrl = $SourceWebUrl
	}
	
	$web1 = Get-SPWeb -Identity $SourceWebUrl
	$sourceList = $web1.Lists[$SourceLibraryTitle]
	
	$web2 = Get-SPWeb -Identity $DestinationWebUrl
	$destinationList = $web2.Lists[$DestinationLibraryTitle]
	
	:outer foreach ($item in $sourceList.Items) {
    
        $sourceFolder = ((Remove-ArrayMemberAtIndex -array ($item.File.ParentFolder.Url.ToString().Split('/')) -index 0) -join '/')

        foreach($folder in $FolderList){
            $matchString = "^$folder"
            if ("/$sourceFolder" -notmatch $matchString){ continue outer }
        }

		$targetFolders = $web2.Lists[$DestinationLibraryTitle].Folders | Select-Object -ExpandProperty Url
		
		$shouldCreateParentFolder = $true
		
		if ($sourceFolder -eq "") {
			$shouldCreateParentFolder = $false
		}
		else {
			foreach ($folder in $targetFolders) {
				$destinationFolder = ((Remove-ArrayMemberAtIndex -array ($folder.Split('/')) -index 0) -join '/')
				$targetFolder = $null
				if ($sourceFolder -eq $destinationFolder) {
					$shouldCreateParentFolder = $false
                    $targetFolder = $folder
					break
				}
			}
		}
		
		if ($shouldCreateParentFolder) {
            
            $folderArray = $sourceFolder.Split('/')
            $destinationAbsoluteFolder = $destinationList.RootFolder.ToString()
            foreach ($folder in $folderArray){
                $destinationAbsoluteFolder += "/" + $folder
                $createdFolder = $web2.Folders.Add($destinationAbsoluteFolder)
			    $message = "Folder '$($createdFolder.Url)' was not found in the destination library. Created."
			    Write-Verbose -Message $message
			    if ($LogFilePath -ne $null) {
				    Log-Message -Message $message -FilePath $LogFilePath
			    }
            }
		}

		$file = $item.File
		$binary = $file.OpenBinary()
        $fileUrl = $targetFolder + "/" + $item.File.Name	

		if ($Overwrite) {
			$createdFile = $web2.Files.Add($fileUrl, $binary, $true)
			$message = "Copied file: '$($createdFile.Url)' onto target file (if existed) with 'Overwrite' flag."
			Write-Warning -Message $message
			if ($LogFilePath -ne $null) {
				Log-Message -Message $message -FilePath $LogFilePath
			}
		}
		else {
			try {
				$createdFile = $web2.Files.Add($item.File.Url, $binary)
				$message = "Copied file: '$($createdFile.Url)'"
				Write-Verbose -Message $message
				if ($LogFilePath -ne $null) {
					Log-Message -Message $message -FilePath $LogFilePath
				}
			}
			catch {
				$message = "Destination file: $($item.File.Url) already exists. You did not specify 'Overwrite' flag, so nothing was copied."
				Write-Error -Message $message
				if ($LogFilePath -ne $null) {
					Log-Message -Message $message -FilePath $LogFilePath
				}
			}
		}
	}
}



Export-ModuleMember -Function Copy-SPTLibrary



