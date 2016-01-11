PowerShell (200) - Tricks and common mistakes
=============================================

Adżenda
------
Part 1
------
1. PowerShell consoles and IDEs
2. Scripts and functions
3. Scopes
4. Remoting (Session and Invoke-Command)
Part 2
------
5. Error handling
6. Performance test
7. Modules
8. Microsoft.PowerShell_profile.ps1
9. Integration
10. .NET Cmdlets
11. Other useful tricks

PowerShell consoles and IDEs
----------------------------

- Windows PowerShell
- ComEmu
- Windows PowerShell ISE
- PowerGUI

Scripts and functions
---------------------

Strings and functions:
```ps
	function MultilineString() {
		@"
		Some long ass
		muliline text
"@
	}
	
	function MultilineEscapeString() {
		"Some long ass `nmuliline text"
	}
	
	function SimpleFun() {
		"Hello " + $MyInvocation.MyCommand
	}
	
	function InnerFunCommonError() {
		"Hello $MyInvocation.MyCommand"
	}
	
	function InnerFun() {
		"Hello `$ $($MyInvocation.MyCommand)"
	}
	
	function FormatFun() {
		 "Hello {0} {1}" -f $MyInvocation.MyCommand, 5
		 5
	}
	
	function HostFun() {
		Write-Host $("Hello {0}" -f $MyInvocation.MyCommand)	
	}
	
	function VerboseFun {
		[CmdletBinding()]
		Param()
		Write-Verbose $("Hello {0}" -f $MyInvocation.MyCommand)	
	}
	
	SimpleFun
	InnerFunCommonError
	InnerFun
	FormatFun
	HostFun
	VerboseFun
	VerboseFun -Verbose
	
	$a = SimpleFun
	$a
	
	$a = HostFun
	$a
	
	$a = VerboseFun -Verbose
	$a

	$VerbosePreference = "Continue"
	VerboseFun
	$VerbosePreference = "SilentlyContinue"
	VerboseFun
	
	"sdfsadf" | Out-File "Fun.log"
	HostFun | Out-File "Fun.log"
```

Conversions:
```ps
	5 -eq 5
	5 -eq "5"
	"5" -eq 5
	
	5 -eq "05"
	"05" -eq 5
	
	$i = 33
	$j = "033"
	switch ($i){
		33 { "First" }
		"33" { "Second" }
		$j { "Third" }
	}
```

Script blocks:
```ps
	{$PWD.Path; "Some output text"}
	&{$PWD.Path; "Some output text"}

	$f = {$PWD.Path; "Some output text"}	
	&$f
```

Function output:
```ps
	function Do-Something{
		Write-Verbose "Done something"
		return 0
	}
	function Get-SomeData{
		"Getting some data"
		Do-Something | Write-Verbose
		return 5	
	}
	
	Do-Something
	
	$a = Get-SomeData
	$a.Length
```

Function documentation:
```ps
	<# 
	.SYNOPSIS 
		Prints files bigger then 1MB 
	#>
	function GetBigFiles{
		Get-ChildItem | ? Length -gt 1MB
	}	

	Get-Help GetBigFiles
	
	Get-Help about_comment_based_help
```

Pipe function:
```ps
	function Get-FilesNames(){
		begin { Write-Verbose "Start processing files" }
		process {
			$_.Name
			$count += 1
		}
		end { Write-Verbose "Processed $count files" }
	}

	$VerbosePreference = "Continue"
	ls | ? Name -match "Fu.+"
```


Scopes
------

Local function scope:
```ps
	$a = 5

	function Set-ATo8($p){
		"`$a before assignment: $a"
		$a = 8
		"`$a after assignment: $a"
		"`$a after assignment: $:a"
		$script:a = 7
		$p = 10
		"`$script:a after assignment: $script:a"
	}
	$ps =6
	Set-ATo8 $ps
	$p
	"`$a after function: $a"
```

Run script:
```ps
	.\Scope_Functions.ps1
	$test
	Print-LocalSuccess
	Print-GlobalSuccess
```

Load script:
```ps
	$test = 7;
	. .\Scope_Functions.ps1
	$test
	Print-LocalSuccess
	Print-GlobalSuccess
```

Remoting (Session and Invoke-Command)
-------------------------------------

Invoke-Command scope and session:
```ps
	. .\Scope_Functions.ps1
	
	Invoke-Command -ScriptBlock {
		Write-Output "Remote command"
		Print-LocalSuccess
		Print-GlobalSuccess
	}
	
	Enable-PSRemoting -Force -SkipNetworkProfileCheck
	$session = New-PSSession
	
	Invoke-Command -Session $session -ScriptBlock {
		Write-Output "Remote command"
		Print-LocalSuccess
		Print-GlobalSuccess
	}
	# Send script to session
	Invoke-Command -Session $session -FilePath .\Scope_Functions.ps1
	
	Invoke-Command -Session $session -ScriptBlock {
		Write-Output "Remote command"
		Print-LocalSuccess
		Print-GlobalSuccess
	}
```

Error handling
--------------

```ps
    $ErrorActionPreference = "Continue"
    
    try {
        Get-ChildItem 'C:\Windows\System32' -Recurse | Select Name | Out-File 'C:\temp\files.txt' -Append
    }catch {
        "asdfasdfasdfasdfasdf"
        $_.Exception.Message #| Out-File 'C:\temp\errors.txt' -Append
    }
    
    try {
        Get-ChildItem 'C:\Windows\System32' -Recurse -ErrorAction Stop | Select Name | Out-File 'C:\temp\files.txt' -Append
    }catch {
        $_.Exception.Message #| Out-File 'C:\temp\errors.txt' -Append
    }
    
    #After exe
    $LASTEXITCODE
```

Performance test
----------------
```ps

    get-process

    cd C:\Users\mswietlicki\OneDrive\Dokumenty\CE
    
	Measure-Command -Expression {
		Get-ChildItem 'C:\Windows\System32' -Recurse -ErrorAction SilentlyContinue |
		 % { "$($_.Name) - $($_.GetHashCode())" } | Out-File files.txt -Append
	}

    Measure-Command -Expression {
		Get-ChildItem 'C:\Windows\System32' -Recurse -ErrorAction SilentlyContinue |
		 % { "{0} - {1}" -f $_.Name, $_.GetHashCode() } | Out-File files.txt -Append
	}

    Measure-Command -Expression {
        $files = Get-ChildItem 'C:\Windows\System32' -Recurse -ErrorAction SilentlyContinue
        $result = ""
        foreach($file in $files){
            $result += "$($file.Name) - $($file.GetHashCode())"
        }
        $result >> files.txt
    }
```

Modules
-------

Working with modules:
```ps
	Import-Module .\SampleModule.psm1 -Verbose
	
	Get-SomeString
	Set-SomeString "Another string"
	Get-SomeString
	Get-Count
	Update-Counter 
	
	Get-Command -Module SampleModule
	Remove-Module SampleModule
```

PowerShell repository
```ps
	Find-Module
	Install-Module Posh-SSH -Force
	Install-Module PowerShellCookbook -Force
	Install-Module Pscx -Force
	
	Get-Command -Module PowerShellCookbook
	
	$env:PSModulePath
	#Install-Module posh-git -Force
```
Modules:
	https://www.powershellgallery.com


Microsoft.PowerShell_profile.ps1
--------------------------------
Runs at the start of every Powershell shell.

Paths:

	%windir%\system32\WindowsPowerShell\v1.0\profile.ps1 
	%windir%\system32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1 
	
	%UserProfile%\My Documents\WindowsPowerShell\profile.ps1 
	%UserProfile%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 

Get current profile path:
	$profile

Integration
-----------

- Windows
- OpenVPN
- Sublime Test 3
- Visual Studio
- AppFabric

.NET Cmdlets
------------

```csharp
	using System.Management.Automation
	
	[Cmdlet(VerbsCommon.Get, "FullPath")]
	public class GetFullPath : PSCmdlet
	{
		[Parameter(Mandatory = true, ValueFromPipeline = true, Position = 0, HelpMessage = "Path to CERecordFile")]
		public string Path { get; set; }
		
		protected override void ProcessRecord()
		{
			Path = GetUnresolvedProviderPathFromPSPath(Path);
	   
			WriteObject(Path);
	
			base.ProcessRecord();
		}
	}
```

Other useful tricks
-------------------

Get all variables:
```ps
	Get-Variable
```

Hashtable as parameters
```ps
	$params = @{
		Path = 'C:\Windows'
		Filter = "*.exe"
	}
	Get-ChildItem @params
```

Custom property
```ps
	ls | select *,@{ n='Size(MB)';e={$_.Length / 1MB} }
```

Default table collumns
```ps
	"$pshome\DotNetTypes.format.ps1xml"
```

```ps
	"$PsHome\powershell.exe"
```

```ps
	Compress-Archive Fun.log Fun.zip
	Expand-Archive Fun.zip
```

```ps
	function Add-EnvPath {
		param($newPath)
	
		if([System.String]::IsNullOrEmpty($newPath)){
			Write-Error "Path must not be null!"
			return -1
		}
	
		if(![System.IO.Directory]::Exists($newPath)){
			Write-Error "Path does not exist!"
			return -1
		}
	
		$path = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
		$path += ";" + $newPath
	
		[Environment]::SetEnvironmentVariable("Path", $path, [System.EnvironmentVariableTarget]::Machine)
	}
```

```ps
	function Start-VPN {
		Stop-Service OpenVPNService
		Start-Service OpenVPNService
		Get-Service OpenVPNService
		Write-Host ""
		$logfile = "C:\Program Files\OpenVPN\log\mswietlicki@cegate40.controlexpert.de.log"
	
		Get-Content $logfile -wait | % { $_; if($_.Contains("Initialization Sequence Completed")) { break } }
	}
```

```ps
	function Encode-Base64 {
		param($path)
	
		$Content = Get-Content -Path $path -Encoding Byte
		return [System.Convert]::ToBase64String($Content)
	}
```

```ps
	function fta { $input | Format-Table -AutoSize }
```


```ps
	$hkcr = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
```

Get-WiFiPasswords:
```ps
	function Get-WiFiPasswords {
		(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize
	}
```

Links
-----

Chocolatey:
https://chocolatey.org

PowerShell Community Extensions:
https://pscx.codeplex.com


PsGet page: 
	http://psget.net