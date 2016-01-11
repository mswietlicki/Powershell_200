
$Script:someString = "Some string"
$Script:setCounter = 0

function Get-SomeString(){
	Write-Output $someString
}

function Set-SomeString($someString){
	$Script:someString = $someString
	Update-Counter
}

function Get-Count(){
	Write-Output $Script:setCounter
}

function Update-Counter(){
	$Script:setCounter += 1
}

#Get-Verb

Export-ModuleMember Get-SomeString
Export-ModuleMember Set-SomeString
Export-ModuleMember Get-Count