$script:test = 5

function Print-LocalSuccess ()
{
	Write-Output $MyInvocation.MyCommand.Name
}

function global:Print-GlobalSuccess ()
{
	Write-Output $MyInvocation.MyCommand.Name
}