Param(
	[String]$JobName,
	[String]$Id
)

####################
# Import Functions #
####################
Import-Module "$PSScriptRoot\Helpers"

# Get the config from our config file
$config = (Get-Content "$PSScriptRoot\config\conf.json") -Join "`n" | ConvertFrom-Json

# Log if enabled in config
if($config.debug_log) {
	Start-Logging "$PSScriptRoot\log\debug.log"
}

# Add Veeam commands
Add-PSSnapin VeeamPSSnapin

# Get the session
$session = Get-VBRBackupSession | ?{($_.OrigJobName -eq $JobName) -and ($Id -eq $_.Id.ToString())}

# Wait for the session to finish up
while ($session.IsCompleted -eq $false) {
	Write-LogMessage 'Info' 'Session not finished Sleeping...'
	Start-Sleep -m 200
	$session = Get-VBRBackupSession | ?{($_.OrigJobName -eq $JobName) -and ($Id -eq $_.Id.ToString())}
}

# Save same session info
$Status = $session.Result
$JobName = $session.Name.ToString().Trim()
$JobType = $session.JobTypeString.Trim()
[Float]$JobSize = $session.BackupStats.DataSize
[Float]$TransfSize = $session.BackupStats.BackupSize
$job = Get-VBRJob -Name $session.JobName
$vms = $job.GetObjectsInJob()
$vms = $vms.name
$service = $config.service_name


# Report job/data size in B, KB, MB, GB, or TB depending on completed size.
## Job size
If([Float]$JobSize -lt 1KB) {
    [String]$JobSizeRound = [Float]$JobSize
    [String]$JobSizeRound += ' B'
}
ElseIf([Float]$JobSize -lt 1MB) {
    [Float]$JobSize = [Float]$JobSize / 1KB
    [String]$JobSizeRound = [math]::Round($JobSize,2)
    [String]$JobSizeRound += ' KB'
}
ElseIf([Float]$JobSize -lt 1GB) {
    [Float]$JobSize = [Float]$JobSize / 1MB
    [String]$JobSizeRound = [math]::Round($JobSize,2)
    [String]$JobSizeRound += ' MB'
}
ElseIf([Float]$JobSize -lt 1TB) {
    [Float]$JobSize = [Float]$JobSize / 1GB
    [String]$JobSizeRound = [math]::Round($JobSize,2)
    [String]$JobSizeRound += ' GB'
}
ElseIf([Float]$JobSize -ge 1TB) {
    [Float]$JobSize = [Float]$JobSize / 1TB
    [String]$JobSizeRound = [math]::Round($JobSize,2)
    [String]$JobSizeRound += ' TB'
}
### If no match then report in bytes
Else{
    [String]$JobSizeRound = [Float]$JobSize
    [String]$JobSizeRound += ' B'
}
## Transfer size
If([Float]$TransfSize -lt 1KB) {
    [String]$TransfSizeRound = [Float]$TransfSize
    [String]$TransfSizeRound += ' B'
}
ElseIf([Float]$TransfSize -lt 1MB) {
    [Float]$TransfSize = [Float]$TransfSize / 1KB
    [String]$TransfSizeRound = [math]::Round($TransfSize,2)
    [String]$TransfSizeRound += ' KB'
}
ElseIf([Float]$TransfSize -lt 1GB) {
    [Float]$TransfSize = [Float]$TransfSize / 1MB
    [String]$TransfSizeRound = [math]::Round($TransfSize,2)
    [String]$TransfSizeRound += ' MB'
}
ElseIf([Float]$TransfSize -lt 1TB) {
    [Float]$TransfSize = [Float]$TransfSize / 1GB
    [String]$TransfSizeRound = [math]::Round($TransfSize,2)
    [String]$TransfSizeRound += ' GB'
}
ElseIf([Float]$TransfSize -ge 1TB) {
    [Float]$TransfSize = [Float]$TransfSize / 1TB
    [String]$TransfSizeRound = [math]::Round($TransfSize,2)
    [String]$TransfSizeRound += ' TB'
}
### If no match then report in bytes
Else{
    [String]$TransfSizeRound = [Float]$TransfSize
    [String]$TransfSizeRound += ' B'
}

# Job duration
$Duration = $session.Info.EndTime - $session.Info.CreationTime
$TimeSpan = $Duration
$Duration = '{0:00}h {1:00}m {2:00}s' -f $TimeSpan.Hours, $TimeSpan.Minutes, $TimeSpan.Seconds

# Switch on the session status
switch ($Status) {
    None {$emoji = ':thought _ balloon: '}
    Warning {$img = $config.warn_img}
    Success {$img = $config.success_img}
    Failed {$img = $config.fail_img}
    Default {$emoji = ''}
}

# Build the details string
$details = "`n" + "VMs in this Job" + ": " + [String]$vms + "`n" + "Backup Size - " + [String]$JobSizeRound + " / Transferred Data - " + [String]$TransfSizeRound + " / Dedup Ratio - " + [String]$session.BackupStats.DedupRatio + " / Compress Ratio - " + [String]$session.BackupStats.CompressRatio + " / Duration - " + $Duration

# Build the payload
$slackJSON = @{}
$slackJSON.text = '******* VEEAM REPORT *******' + "`n" + '**Job:** ' + $JobName + "`n" + '**Status:** ' + $Status + "`n" + '**Details:** '  + $details


$MyToken = $config.mytoken
$chatid = $config.chatid
$message = $slackJSON.text
$URI = "https://api.telegram.org/bot$($MyToken)/sendMessage?chat_id=$($chatID)&text=$($Message)"

$Request = Invoke-RestMethod -Uri $URI
