function Invoke-FirstAlert{
    @'
        $date = (get-date).Addseconds(-15)
        $event = Get-WinEvent -FilterHashtable @{logname='security'; id=4688; starttime=$date} |Where-Object{$_.message -like '*bcdedit.exe*' -or $_.message -like '*vssadmin.exe*'}
        $num = ($event | select @{Label='filler';Expression={$_.properties.value[7]}}).filler
        stop-process -id ([int]$num) -Force
'@ | Out-File $env:SystemDrive\users\public\desktop\firstAlert.ps1 -Force

    $payload = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file $env:SystemDrive\users\public\desktop\firstAlert.ps1"

    $wmiParams = @{
        Computername = $env:COMPUTERNAME
        ErrorAction = 'Stop'
        NameSpace = 'root\subscription'
    }

    $wmiParams.Class = '__EventFilter'
    $wmiParams.Arguments = @{
        Name = 'ServiceFilter'
        EventNamespace = 'root\CIMV2'
        QueryLanguage = 'WQL'
        Query = "SELECT * FROM WIN32_ProcessStartTrace WHERE ProcessName='bcdedit.exe' or ProcessName='vssadmin.exe'"
    }
    $filterResult = Set-WmiInstance @wmiParams

    $wmiParams.Class = 'CommandLineEventConsumer'
    $wmiParams.Arguments = @{
        Name = 'ServiceConsumer'
        CommandLineTemplate = $Payload
    }
    $consumerResult = Set-WmiInstance @wmiParams

    $wmiParams.Class = '__FilterToConsumerBinding'
    $wmiParams.Arguments = @{
        Filter = $filterResult
        Consumer = $consumerResult
    }
    $bindingResult = Set-WmiInstance @wmiParams
}

function Revoke-FirstAlert{
    Get-WMIObject -Namespace root\Subscription -Class __EventFilter -Filter "Name='ServiceFilter'" | 
        Remove-WmiObject -Verbose

    Get-WMIObject -Namespace root\Subscription -Class CommandLineEventConsumer -Filter "Name='ServiceConsumer'" | 
        Remove-WmiObject -Verbose

    Get-WMIObject -Namespace root\Subscription -Class __FilterToConsumerBinding -Filter "__Path LIKE '%ServiceFilter%'"  | 
        Remove-WmiObject -Verbose
}
