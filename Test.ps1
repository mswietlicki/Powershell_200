Get-Location

Get-ChildItem

Get-Alias ls


function VerboseFun {
	[CmdletBinding()]
	Param()
	Write-Verbose $("Hello {0}" -f $MyInvocation.MyCommand)	
}
	
VerboseFun -Verbose

Invoke-Command -ScriptBlock {
	Write-Output "Remote command"
}

try {
    Get-ChildItem 'C:\Windows\System32' -Recurse -ErrorAction Stop | Select Name | Out-File 'C:\temp\files.txt' -Append
}catch {
    $_.Exception.Message | Out-File 'C:\temp\files.txt'
    Continue
}


