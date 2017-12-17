<#
    .SYNOPSIS
    Confirm a message.

    .DESCRIPTION
    Confirms a RabbitMQ message that has been pulled with -autoAck $false before.

    .NOTES
    PSCarrot by Joel Wiesmann, https://github.com/JoelWiesmann/PSCarrot

    .EXAMPLE

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
    if (! $con.IsOpen -or ! $con.channel.IsOpen) {
      throw('Carrot RabbitMQ connection or channel is not opened (anymore).')
    }

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

    if ($model.CloseReason) {
      throw('Acknowledging message with tag ' + $deliveryTag + ' failed: ' + $model.CloseReason.ReplyText)
    }
    
    $msgCounter++
  }

  end {
    Write-Verbose ('Confirmed ' + $msgCounter + ' messages.')
  }
}
