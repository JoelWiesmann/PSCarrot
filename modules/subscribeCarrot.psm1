########################################################################################
# PSCarrot, by Joel Wiesmann, 2017, joel.wiesmann@workflowcommander.ch
#########################################################################################
 
<#
  .SYNOPSIS
    Subscribes a MQRabbit queue.

  .DESCRIPTION
    Subscribe-Carrot .

  .EXAMPLE

#>

function Subscribe-Carrot {
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [Parameter(Mandatory)]
    [string]$queue,
    [Parameter(Mandatory)]
    [string]$sourceIdentifier,
    [Parameter(Mandatory)]
    [scriptblock]$callback
  )
  
  if (! $con.IsOpen) {
    throw('Carrot connection is not opened (anymore).')
  }

  $model    = $con.CreateModel() 
  $consumer = New-Object -TypeName RabbitMQ.Client.Events.EventingBasicConsumer -ArgumentList $model

  $eventHandleBlock = {
    $ch = $args[1]
    $ea = $args[2]
  }

  $action = [ScriptBlock]::Create($eventHandleBlock.ToString() + $callback.ToString())

  Register-ObjectEvent -InputObject $consumer -EventName Received -Action $callback -SourceIdentifier $sourceIdentifier
  
  $consumerTag = $model.BasicConsume($queue, $true, $sourceIdentifier, $false, $false, $null, $consumer);
}
