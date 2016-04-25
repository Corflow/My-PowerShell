while($true)
{
Test-Connection www.google.com |
 select @{n='Time';E={[dateTime]::Now}}, @{N='Destination';E={$_.address}}, @{N='Time(ms)';E={$_.ResponseTime}}, IPV4Address, Replysize | Format-Table
}

while($true)
{
     test-connection google.com -count 1 |
     select @{N='Time';E={[dateTime]::Now}},
          @{N='Destination';E={$_.address}},
          replysize,
          @{N='Time(ms)'; E={$_.ResponseTime}}
}