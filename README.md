# Veeam Backup and Restore Notifications for Telegram

Sends notifications from Veeam Backup & Restore to a Telegram bot

---

## Powershell Notes

Please setup this script to run locally, PS Remoting has not been tested.

#### 1. Setup the script

Clone or download the Repo to a local directory. 

Edit your config file. You must replace the webhook field with your own webhook.
 ```PowerShell
notepad.exe C:\VeeamScripts\VeeamSlackNotifications\config\conf.json
```
You may also need to set your PowerShell execution policy to Unrestricted.
```PowerShell
Set-ExecutionPolicy Unrestricted
```
If you don't want to do that, replace the script path in section 5 below with the following
```PowerShell
Powershell.exe -ExecutionPolicy Bypass -File C:\VeeamScripts\VeeamSlackNotifications\SlackNotificationBootstrap.ps1
```
Unblock the script files  if you're still having issues after setting the PowerShell execution policy. The reason you may need to do this is Windows often blocks execution of downloaded scripts.
```PowerShell
Unblock-File C:\VeeamScripts\VeeamSlackNotifications\SlackNotificationBootstrap.ps1
Unblock-File C:\VeeamScripts\VeeamSlackNotifications\SlackVeeamAlertSender.ps1
Unblock-File C:\VeeamScripts\VeeamSlackNotifications\Helpers\Helpers.psm1
```
#### 2. How to use the script

I needed the ability to run more than 1 script for certain jobs, so I've added a [optional] PreScript and PostScript option that allows additional scripts to be ran as part of the Veeam Job Notification script option.

```PowerShell
.\TelegramNotificationBootstrap.ps1 -PreScript "path_to_pre_script" -PostScript "path_to_post_script"
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
