<#
    .SYNOPSIS
    Check the connection & channel.

    .DESCRIPTION
    If the connection is down or the channel was closed due to an exception, this will throw an exception to catch. The
    safeWait value can be configured in New-CarrotConnection while the switch here can be used to artificially wait - this
    is useful if the test is done right after an action (like acknowledging messages) as there might be some miliseconds 
    between the sending of messages and the closure of the channel due to issues. Alternatively an event can be registered
    using Register-ObjectEvent however this will make the usage too complex for most scenarios.

    .NOTES
    PSCarrot by Joel Wiesmann, https://github.com/JoelWiesmann/PSCarrot

    .EXAMPLE
    Test-CarrotConnection -con $carrotConnection
#>
function Test-CarrotConnection {
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [switch]$safewait = $false
  )

  if ($safewait) {
    Start-Sleep -Milliseconds ($con.safeWait)
  }

  if (! $con.IsOpen) {
    throw('Connection was closed: ' + $con.CloseReason.ReplyText)
  }
  
  if (! $con.channel.IsOpen) {
    throw('Channel was closed: ' + $con.channel.CloseReason.ReplyText)
  }
}