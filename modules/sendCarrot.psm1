<#
  .SYNOPSIS
    Send a message to an RabbitMQ Exchange.

  .DESCRIPTION
    Send-Carrot sends a message to an RabbitMQ exchange that will forward it accordingly.

  .NOTES
    PSCarrot by Joel Wiesmann, https://github.com/JoelWiesmann/PSCarrot

  .EXAMPLE
    Send-Carrot -con $connection -exchange 'DefaultExchange' -payload 'hello world'
    Sends 'hello world' to the DefaultExchange.
#>
function Send-Carrot {
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [Parameter(Mandatory)]
    [string]$exchange,
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$payload,
    [hashtable]$properties = @{ 'contentType' = 'text/plain' },
    [string]$routingKey  = ''
  )
  
  begin {
    try { Test-CarrotConnection -con $con } catch { throw $_ }

    $model = $con.channel

    # If there are any properties specified, set them dynamically.
    $props = $model.CreateBasicProperties()
    foreach($key in $properties.GetEnumerator()) {
      # Support tables (especially for headers)
      if ($key.value -is [hashtable]) {
        $params = New-Object 'System.Collections.Generic.Dictionary[string,object]'
        foreach ($htKey in $key.value.getEnumerator()) {
          $params.Add($key.value.($htkey.name), $htKey.value)
        }
        $props.($key.name) = $params
      }
      else {
        $props.($key.name) = $key.value
      }
    }
    
    $msgcount = 0
  }

  process {
    $messageBodyBytes = [Text.Encoding]::UTF8.GetBytes($payload)

    $model.BasicPublish($exchange,
      $routingKey, 
      $false,
      $props,
      $messageBodyBytes
    )

    if ($model.CloseReason) {
      throw('Sending message failed: ' + $model.CloseReason.ReplyText)
    }

    $msgcount++
  }
  
  end {
    try { Test-CarrotConnection -con $con -safewait } catch { throw $_ }
    Write-Verbose ('Sent ' + $msgcount + ' messages to ' + $exchange + '.')
  }
}