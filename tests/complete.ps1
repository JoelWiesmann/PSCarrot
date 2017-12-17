# This ps1 contains some test cases that will send / get messages from a queue including
# testing some issues that might appear.

Import-Module PSCarrot -force

$exchange  = 'default'
$queue     = 'default_queue'

$ErrorActionPreference = 'Stop'
$VerbosePreference     = 'SilentlyContinue'

Write-Host -ForegroundColor Blue  'Connecting'
try   { $con = New-CarrotConnection }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'

Write-Host -ForegroundColor Cyan  'Clearing queue..'
try   { $message = Get-Carrot -con $con -queue $queue }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }

Write-Host -ForegroundColor Blue  'Sending message'
try   { Send-Carrot -con $con -exchange $exchange -payload 'Get & autoack test' }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'

Write-Host -ForegroundColor Blue  'Get message w/autoack'
try   { $message = Get-Carrot -con $con -queue $queue }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
if ($message.count -eq 1) { Write-Host -ForegroundColor Green 'Suceeded' }
if ($message.count -ne 1) { Write-Host -ForegroundColor Green 'Message count not reached' }

Write-Host -ForegroundColor Blue  'Sending message with expiration property'
try   { Send-Carrot -con $con -exchange $exchange -payload 'Expiration test' -properties @{ 'expiration' = 1 } }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'

Write-Host -ForegroundColor Blue  'Try to get message from empty queue + wait a sec'
try   { $message = Get-Carrot -con $con -queue $queue; sleep 1 }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
if ($message.count -eq 0) { Write-Host -ForegroundColor Green 'Suceeded (no message)' }
if ($message.count -ne 0) { Write-Host -ForegroundColor Green 'Message count not reached' }

Write-Host -ForegroundColor Blue  'Sending message'
try   { Send-Carrot -con $con -exchange $exchange -payload 'Message to get w/o autoack' }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'

Write-Host -ForegroundColor Blue  'Get message w/o autoack'
try   { $message = Get-Carrot -con $con -queue $queue -autoAck $false }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
if ($message.count -eq 1) { Write-Host -ForegroundColor Green 'Suceeded' }
if ($message.count -ne 1) { Write-Host -ForegroundColor Green 'Message count not reached' }

Write-Host -ForegroundColor Blue  'Disconnect & reconnect...'
try   { $con.close(); $con = New-CarrotConnection }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'

Write-Host -ForegroundColor Blue  'Get message (Redelivered) w/o autoack'
try   { $message = Get-Carrot -con $con -queue $queue -autoAck $false }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
if ($message.count -eq 1) { 
  if ($message.redelivered -eq $true) { Write-Host -ForegroundColor Green 'Suceeded found redelivered message' }
  else { Write-Host -ForegroundColor Red 'Redelivered message not found'}
}
if ($message.count -ne 1) { Write-Host -ForegroundColor Green 'Message count not reached' }

Write-Host -ForegroundColor Blue  'Confirm message'
try   { $oldmessage = $message; $message | Confirm-Carrot -con $con }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Succeeded'

Write-Host -ForegroundColor Blue  'Get message from empty queue'
try   { $message = Get-Carrot -con $con -queue $queue }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
if ($message.count -eq 0) { Write-Host -ForegroundColor Green 'Queue was empty' }
if ($message.count -ne 0) { Write-Host -ForegroundColor Red   'Failed' }

Write-Host -ForegroundColor Blue  'Trying to reconfirm message'
try   { $oldmessage | Confirm-Carrot -con $con }
catch { Write-Host -ForegroundColor Green ('Success (got trapped): ' + $_) }

Write-Host -ForegroundColor Blue  'Disconnect...'
try   { $con.close() }
catch { Write-Host -ForegroundColor Red ('Failed: ' + $_); return }
Write-Host -ForegroundColor Green 'Suceeded'