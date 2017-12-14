########################################################################################
# PSCarrot, by Joel Wiesmann, 2017, joel.wiesmann@workflowcommander.ch
#########################################################################################
 
<#
  .SYNOPSIS
    Pulls message(s) from a MQRabbit queue.

  .DESCRIPTION
    Get-Carrot pulls message(s) from a MQRabbit queue. Allows to auto-acknowledge.

  .EXAMPLE
    Get-Carrot -con $queCon -queue 'MyDemoQueue'
    Pulls all messages from the queue and auto-acknowledges. 

    Get-Carrot -con $queCon -queue 'MyDemoQueue' -fetch 50 -autoAck $false
    Pulls up to 50 messages but does not autoacknowledge. 
#>

function Get-Carrot {
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [Parameter(Mandatory)]
    [string]$queue,
    [bool]  $autoAck  = $true,
    [int]   $fetch    = 0,
    [int]   $prefetch = $fetch
  )

  if (! $con.IsOpen) {
    throw('Carrot connection is not opened (anymore).')
  }

  $model = $con.CreateModel() 
  $model.BasicQos(0, $prefetch, $true)
  
  $msgCounter = 0

  while($true) {
    Write-Verbose ('Fetching Msg ' + ($msgcounter + 1))
    $msgObject = $model.BasicGet($queue, $autoAck)
     
    # If message was empty there are no more messages - quit loop
    if (-not $msgObject) {
      Write-Verbose('Retrieved complete queue with ' + $msgCounter + ' items.')
      break
    }
          
    $msgBody = [System.Text.Encoding]::Default.GetString($msgObject.Body)
    # Add decoded message body and queue name to response
    $msgObject | Add-Member Message $msgBody -PassThru | Add-Member Queue $queue -PassThru

    # Increment message counter and exit if fetch is reached
    $msgCounter++

    if ($msgCounter -eq $fetch) {
      Write-Verbose('Retrieved ' + $msgCounter + ' items - there might be more. Exiting.')
      break
    }
  }

  $model.Close()
}