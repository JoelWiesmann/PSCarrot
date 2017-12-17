# PSCarrot
Lightweight RabbitMQ Client for Powershell based on the RabbitMQ DotNet client. Not intended for administrative tasks (for the moment at least) like exchange/queue creation and binding but sending / receiving / acknowledging messages.  

Use at your own risk :v:

# Installation
After cloning repository / downloading and unpacking ZIP file, get the RabbitMQ.Client.dll. Unblock all files and load the module. When you see the available PSCarrot cmdlets you're ready.

```powershell
# This module currently does only work with the 5.1.0-pre1 release. You can use the nuget package manager or download it manually,
# safe it as .zip and place the RabbitMQ.Client.dll in the lib subfolder of the module.
explorer.exe https://www.nuget.org/packages/RabbitMQ.Client/5.1.0-pre1
Get-ChildItem -Recurse PSCarrot | Unblock-File
Import-Module PSCarrot
Get-Command -Module PSCarrot
```

# Usage

## Connecting
```powershell
# Connect to localhost with guest/guest credentials (like in a fresh or development-zone setup)
$connection = New-CarrotConnection 

# Powershell-ISE might not like it that way.
$connection = New-CarrotConnection -HostName localhost -VirtualHost '/' -Credential (get-credential)
```

## Sending message to exchange
```powershell
# Send a hello world to the MyExchange
Send-Carrot -con $connection -exchange 'MyExchange' -payload 'Hello World'

# Send the same including a routing key
Send-Carrot -con $connection -exchange 'MyExchange' -routingKey 'noTrash' -payload 'Hello World'

# Send message with expiration setting
Send-Carrot -con $connection -exchange default -payload 'I am so expired already!' -properties @{ 'Expiration' = 1 }

# .. with header
Send-Carrot -con $connection -exchange default -payload 'Give headers.' -properties @{ 'Headers' = @{ 'head' = 'off' } }
```

## Receiving message (PULL)
```powershell
# Read and auto-acknowledge all messages on the default_queue
Get-Carrot -con $connection -queue default_queue

# Read only the top message and do not acknowledge. Messages will remain on the queue and will
# have redelivered flag set to true.
Get-Carrot -con $connection -queue default_queue -fetch 1 -autoAck $false
```

## Acknowledge message
```powershell
# Read with autoAck set to false, then Confirm-Carrot to acknowledge messages
$messages = Get-Carrot -con $connection -queue default_queue -autoAck $false
# Do something here.
$messages | Confirm-Carrot -con $connection
```

