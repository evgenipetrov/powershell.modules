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

function Remove-ArrayMemberAtIndex {
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

function Log-Message {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Message,
		[string]$FilePath
	)

    $currentTime = Get-Date -format 'yyyy-MM-dd hh:mm:ss'
	
	if ($FilePath -ne $null) {
        $output = "[$currentTime] $message"
		Write-Output $output | Out-File -FilePath $FilePath -Append	
	}
}


Export-ModuleMember -Function Remove-ArrayMemberAtIndex, Log-Message



