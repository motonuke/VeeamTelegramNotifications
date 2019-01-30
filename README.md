# Veeam Backup and Restore Notifications for Telegram

Sends notifications from Veeam Backup & Restore to a Telegram bot

---

## Powershell Notes

Please setup this script to run locally, PS Remoting has not been tested.

#### 1. Setup the script

Clone or download the Repo to a local directory. 

Edit your config file. You must replace the #### chat_id and #### MyToken with your own information.
 ```PowerShell
notepad.exe C:\VeeamScripts\VeeamTelegramNotifications\config\conf.json
```
You may also need to set your PowerShell execution policy to Unrestricted.
```PowerShell
Set-ExecutionPolicy Unrestricted
```
If you don't want to do that, replace the script path in section 5 below with the following
```PowerShell
Powershell.exe -ExecutionPolicy Bypass -File C:\VeeamScripts\VeeamTelegramNotifications\SlackNotificationBootstrap.ps1
```
Unblock the script files  if you're still having issues after setting the PowerShell execution policy. The reason you may need to do this is Windows often blocks execution of downloaded scripts.
```PowerShell
Unblock-File C:\VeeamScripts\VeeamTelegramNotifications\SlackNotificationBootstrap.ps1
Unblock-File C:\VeeamScripts\VeeamTelegramNotifications\SlackVeeamAlertSender.ps1
Unblock-File C:\VeeamScripts\VeeamTelegramNotifications\Helpers\Helpers.psm1
```
#### 2. How to use the script

I needed the ability to run more than 1 script for certain jobs, so I've added a [optional] PreScript and PostScript option that allows additional scripts to be ran as part of the Veeam Job Notification script option (Veeam doesn't support running more than 1 script per job).

#### Please note, this script will not run stand alone, it relies on an active Veeam Job running to grab that job's stats. The below code is only an example.

```PowerShell
.\TelegramNotificationBootstrap.ps1 -PreScript "c:\path\to\pre_script.ps1" -PostScript "c:\path\to\post_script.ps1"
```

#### 3. Configure in Veeam
Repeat this for each job that you want to be reported into Telegram.
* Right click the job and click "Edit".
* Go to the "Storage" section and click on the <img src="asset/img/screens/sh-3.png" height="20"> button.
* Go to the "Scripts" tab and configure as shown below.
![screen](asset/img/screens/sh-1.png)

```PowerShell
Powershell.exe -File C:\VeeamScripts\VeeamTelegramNotifications\TelegramNotificationBootstrap.ps1 -PostScript "c:\path\to\post_script.ps1"
```
