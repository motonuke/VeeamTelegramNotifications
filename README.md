# Veeam Backup and Restore Notifications for Slack

Sends notifications from Veeam Backup & Restore to Slack

![Chat Example](https://raw.githubusercontent.com/tigattack/VeeamSlackNotifications/master/asset/img/screens/sh-2.png)

---
[MS Teams version.](https://github.com/tigattack/VeeamTeamsNotifications)
---
## [Discord Setup](https://blog.tiga.tech/veeam-b-r-notifications-in-discord/)

## Slack Setup

Make a scripts directory: `C:\VeeamScripts`

```powershell
# To make the directory run the following command in PowerShell
New-Item C:\VeeamScripts PowerShell -type directory
```

#### Get code

Then clone this repository:

```shell
cd C:\VeeamScripts
git clone https://github.com/tigattack/VeeamSlackNotifications.git
cd VeeamSlackNotifications
git checkout master
```

Or without git:

Download release, there may be later releases take a look and replace the version number with newer release numbers.
Unzip the archive and make sure the folder is called: `VeeamSlackNotifications`
```powershell
Invoke-WebRequest -Uri https://github.com/tigattack/VeeamSlackNotifications/archive/2.1.zip -OutFile C:\VeeamScripts\VeeamSlackNotifications-v1.0.zip
```

#### Extract and clean up
```shell
Expand-Archive C:\VeeamScripts\VeeamSlackNotifications-v2.2.zip -DestinationPath C:\VeeamScripts
Ren C:\VeeamScripts\VeeamSlackNotifications-2.2 C:\VeeamScripts\VeeamSlackNotifications
rm C:\VeeamScripts\VeeamSlackNotifications-v2.2.zip
```

#### Configure the project:
Make a new config file
```shell
cp C:\VeeamScripts\VeeamSlackNotifications\config\vsn.example.json C:\VeeamScripts\VeeamSlackNotifications\config\vsn.json
```
 Edit your config file. You must replace the webhook field with your own Slack url.
 ```shell
notepad.exe C:\VeeamScripts\VeeamSlackNotifications\config\vsn.json
```

Finally open Veeam and configure your jobs. Edit them and click on the <img src="asset/img/screens/sh-3.png" height="20"> button.

Navigate to the "Scripts" tab and paste the following line the script that runs after the job is completed:

```shell
Powershell.exe -File C:\VeeamScripts\VeeamSlackNotifications\SlackNotificationBootstrap.ps1
```

![screen](asset/img/screens/sh-1.png)

---

## Example Configuration:

Below is an example configuration file.

```shell
{
	"webhook": "https://...",
	"channel": "#veeam",
	"service_name": "Veeam B&R",
	"icon_url": "https://raw.githubusercontent.com/tigattack/VeeamSlackNotifications/master/asset/img/icon/VeeamB%26R.png",
	"debug_log": false
}
```
