<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.144
	 Created on:   	10/10/2017 6:17 AM
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	PowerShell.Helper.Tools.psm1
	-------------------------------------------------------------------------
	 Module Name: PowerShell.Helper.Tools
	===========================================================================
#>

function Remove-ArrayMembersAtIndex {
	param (
		[object[]]$array,
		[int]$index
	)
	
	[System.Collections.Generic.List[System.Object]]$genericList = $array
	foreach ($i in $index) {
		$genericList.RemoveAt($i)
	}
	
	[array]$output = $genericList
	Write-Output $output
}

Export-ModuleMember -Function Remove-ArrayMembersAtIndex



