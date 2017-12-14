# PSCarrot
Lightweight RabbitMQ Client for Powershell based on the RabbitMQ DotNet client.

# Installation
After cloning repository / downloading and unpacking ZIP file, unblock all files and load the module. When you see the available PSCarrot cmdlets you're ready.

```powershell
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
```

## Receiving message (PULL)
```powershell
# Read and auto-acknowledge all messages on the default_queue
Get-Carrot -con $connection -queue default_queue

# Read only the top message and do not acknowledge. Messages will remain on the queue and will
# have redelivered flag set to true.
Get-Carrot -con $connection -queue default_queue -fetch 1 -autoAck $false
```

## Receiving Message (PUSH)
This experimental piece is in work.
