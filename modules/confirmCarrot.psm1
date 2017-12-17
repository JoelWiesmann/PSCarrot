<#
    .SYNOPSIS
    Confirm a message.

    .DESCRIPTION
    Confirms a RabbitMQ message that has been pulled with -autoAck $false before.

    .NOTES
    PSCarrot by Joel Wiesmann, https://github.com/JoelWiesmann/PSCarrot

    .EXAMPLE
    $messages = Get-Carrot -con $carrotConnection -queue demo_queue -autoAck $false
    $messages | Confirm-Carrot -con $carrotConnection
#>

function Confirm-Carrot {
  [CmdletBinding(DefaultParameterSetName='byID')]
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='byCarrot')]
    [RabbitMQ.Client.BasicGetResult]$carrot,
    [Parameter(Mandatory,ValueFromPipeline,ParameterSetName='byID')]
    [int]$deliveryTag
  )

  begin {
    try { Test-CarrotConnection -con $con } catch { throw $_ }

    $model = $con.channel
    $msgCounter = 0
  }

  process{
    if ($PSCmdlet.ParameterSetName -eq 'byCarrot') {
      $deliveryTag = $carrot.DeliveryTag
    }

    try {
      $model.basicAck($deliveryTag, $false)
    }
    catch {
      throw('Acknowledging message with tag ' + $deliveryTag + ' failed: ' + $_)
    }
    
    try { Test-CarrotConnection -con $con -safewait } catch { throw $_ }
    
    $msgCounter++
  }

  end {
    Write-Verbose ('Confirmed ' + $msgCounter + ' messages.')
  }
}
