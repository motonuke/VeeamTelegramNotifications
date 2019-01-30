[CmdletBinding()] 
param(
	[Parameter(Mandatory=$false)][string]$PreScript,
	[Parameter(Mandatory=$false)][string]$PostScript
	)

####################
# Import Functions #
####################
Import-Module "$PSScriptRoot\Helpers"

# Get the config from our config file
$config = (Get-Content "$PSScriptRoot\config\conf.json") -Join "`n" | ConvertFrom-Json

# Should we log?
if($config.debug_log) {
	Start-Logging "$PSScriptRoot\log\debug.log"
	"`n"
	get-date
	"`n"
}

# Add Veeam commands
Add-PSSnapin VeeamPSSnapin

# Running PreScript, if specified
$PreArgs = "-file $PreScript"
if ($PreScript) {write-output "Found PreScript, executing before starting main script"
				# Start-Process -FilePath "powershell" -Verb runAs -ArgumentList $PreArgs -WindowStyle hidden}
				powershell.exe -file $PreScript}

# Get Veeam job from parent process
$parentpid = (Get-WmiObject Win32_Process -Filter "processid='$pid'").parentprocessid.ToString()
$parentcmd = (Get-WmiObject Win32_Process -Filter "processid='$parentpid'").CommandLine
$job = Get-VBRJob | ?{$parentcmd -like "*"+$_.Id.ToString()+"*"}
# Get the Veeam session
$session = Get-VBRBackupSession | ?{($_.OrigJobName -eq $job.Name) -and ($parentcmd -like "*"+$_.Id.ToString()+"*")}
# Store the ID and Job Name
if ($session) {
	$Id = '"' + $session.Id.ToString().ToString().Trim() + '"'
	$JobName = '"' + $session.OrigJobName.ToString().Trim() + '"'
	# Build argument string
	$powershellArguments = "-file $PSScriptRoot\TelegramVeeamAlertSender.ps1", "-JobName $JobName", "-Id $Id"

	# Start a new new script in a new process with some of the information gathered her
	# Doing this allows Veeam to finish the current session so information on the job's status can be read
	Start-Process -FilePath "powershell" -Verb runAs -ArgumentList $powershellArguments -WindowStyle hidden
	} else {
	write-output "VBR Job Session not found, exiting script (script should be executed as part of a VBR Job)"
	}

# Running PostScript, if specified
$PostArgs = "-file $PostScript"
if ($PostScript) {write-output "Found PostScript, executing after main script exits"
				# Start-Process -FilePath "powershell" -Verb runAs -ArgumentList $PostArgs -WindowStyle hidden}
				powershell.exe -file $PostScript}
				
If (!$session -and $config.debug_log) {Stop-Transcript}
