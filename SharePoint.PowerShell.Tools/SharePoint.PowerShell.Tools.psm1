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
		[switch]$Overwrite
	)
	
	if ($DestinationWebUrl -eq $null) {
		$DestinationWebUrl = $SourceWebUrl
	}
	
	$web1 = Get-SPWeb -Identity $SourceWebUrl
	$sourceList = $web1.Lists[$SourceLibraryTitle]
	
	$web2 = Get-SPWeb -Identity $DestinationWebUrl
	$destinationList = $web2.Lists[$DestinationLibraryTitle]
	
	foreach ($item in $sourceList.Items) {
		$file = $item.File
		$binary = $file.OpenBinary()
		
		$sourceFolder = ((Remove-ArrayMemberAtIndex -array ($item.File.ParentFolder.Url.ToString().Split('/')) -index 0) -join '/')
		$targetFolders = $web2.Lists[$DestinationLibraryTitle].Folders | Select-Object -ExpandProperty Url
		
		$shouldCreateParentFolder = $true
		
		if ($sourceFolder -eq "") {
			$shouldCreateParentFolder = $false
		}
		else {
			foreach ($folder in $targetFolders) {
				$destinationFolder = ((Remove-ArrayMemberAtIndex -array ($folder.Split('/')) -index 0) -join '/')
				
				if ($sourceFolder -eq $destinationFolder) {
					$shouldCreateParentFolder = $false
					break
				}
			}
		}
		
		if ($shouldCreateParentFolder) {
			$destinationAbsoluteFolder = $destinationList.RootFolder.ToString() + "/" + $sourceFolder
			$createdFolder = $web2.Folders.Add($destinationAbsoluteFolder)
			Write-Verbose "Folder '$($createdFolder.Url)' was not found in the destination library. Created."
		}
		
		if ($Overwrite) {
			$createdFile = $web2.Files.Add($item.File.Url, $binary, $true)
			Write-Warning "Copied file: '$($createdFile.Url)' onto target file (if existed) with 'Overwrite' flag."
		}
		else {
			try {
				$createdFile = $web2.Files.Add($item.File.Url, $binary)
				Write-Verbose "Copied file: '$($createdFile.Url)'"
			}
			catch {
				Write-Error "Destination file: $($item.File.Url) already exists. You did not specify 'Overwrite' flag, so nothing was copied."
			}
		}
	}
}



Export-ModuleMember -Function Copy-SPTLibrary



