#Script to compare current IP with old IP and sends Slack notification if different (and do nothing if there was no change).
#We can put this as a scheduled task to run daily.
#ScriptName: IP_change_detection_notification.ps1
mkdir "C:\code"
$slackWebhookUrl = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #put yours here
$ipDetectionUrl = "https://wtfismyip.com/text"
$IPAddFile = "C:\code\IP_change_detection_notification.dat" #absolute path to file that stores the old IP record
$slackOutputFile = "C:\code\IP_change_detection_notification_Slack.txt"
$optionalDebuggingFile = "C:\code\IP_change_detection_notification_debugging.txt"

$Request = Invoke-WebRequest $ipDetectionUrl
$IP_new = ($Request.Content.Trim())
Write-Host "Current IP address: [$IP_new]"

#Check if old IP record exists
If(Test-Path "$IPAddFile")
{
#Get old IP
$IP_old = Get-Content "$IPAddFile"
    #Compare IPs
    if(-not($IP_new -eq $IP_old))
    {
        Write-Host "Old IP address: [$IP_old]"
        $msg = "Your WAN IP has changed to $IP_new (was $IP_old)!"
        Write-Host "$msg"               
        $body = $("{""text"":""$msg""}")
        Write-Host "$body"
        Invoke-RestMethod -Uri $slackWebhookUrl -Method Post -ContentType 'application/json' -Body $body -OutFile $slackOutputFile

        "Notification Sent"     

        #Overwrite and update new IP
        $IP_new |  Out-File $IPAddFile

    }
    else
    {"No change, no notification"}

}
else
{
#Create new, as file not found
$IP_new |  Out-File $IPAddFile
"File created"
}
$(get-date -f yyyy-MM-dd_HH_mm_ss)  |  Out-File $optionalDebuggingFile
#Read-Host -Prompt "Press Enter to exit" #Comment out this line if this script will be run by a cron job. Otherwise, uncomment it so that you can see the results of the script in the console.

#This script was adapted from https://gallery.technet.microsoft.com/scriptcenter/Detect-IP-address-change-aeb51118 by Satyajit
To get the Task Scheduler working:
