# Veeam Backup and Restore Notifications for Slack

Sends notifications from Veeam Backup & Restore to Slack

![Chat Example](https://raw.githubusercontent.com/tigattack/VeeamSlackNotifications/master/asset/img/screens/sh-2.png)

---

## Slack setup

We'll be using PowerShell to get started with this.

Please connect to your Veeam server and open PowerShell as an administrator. I ask that you open PowerShell on your Veeam server as some of the instructions will not work over a remote PS session. You may use a remote PS session and adapt the instructions if you like, but I'm not responsible if you break anything (though that would be quite hard to do with what I'm telling you to do here).

#### 1. Create destination directory

Make a scripts directory: `C:\VeeamScripts`

```PowerShell
New-Item C:\VeeamScripts PowerShell -type directory
```

#### 2. Download the project

There may be later releases so [take a look](https://github.com/tigattack/VeeamSlackNotifications/releases) and replace the version number in the commands below with the latest if applicable.

Download the archive and rename it to something recognisable.
```PowerShell
Invoke-WebRequest -Uri https://github.com/tigattack/VeeamSlackNotifications/archive/2.4.zip -OutFile C:\VeeamScripts\VeeamSlackNotifications-2.4.zip
```
You may recieve an SSL error as in some cases winhttp uses TLS1 by default (depends on a few things), and GitHub appears to no longer accept TLS1. If you receive this error, run the following command and then re-issue the above command.
```PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

#### 3. Extract and clean up
```PowerShell
Expand-Archive C:\VeeamScripts\VeeamSlackNotifications-2.4.zip -DestinationPath C:\VeeamScripts
Ren C:\VeeamScripts\VeeamSlackNotifications-2.4 C:\VeeamScripts\VeeamSlackNotifications
rm C:\VeeamScripts\VeeamSlackNotifications-2.4.zip
```

#### 4. Prepare for use
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

#### 5. Configure in Veeam
Repeat this for each job that you want to be reported into Slack.
* Right click the job and click "Edit".
* Go to the "Storage" section and click on the <img src="asset/img/screens/sh-3.png" height="20"> button.
* Go to the "Scripts" tab and configure as shown below.
![screen](asset/img/screens/sh-1.png)
```PowerShell
Powershell.exe -File C:\VeeamScripts\VeeamSlackNotifications\SlackNotificationBootstrap.ps1
```
