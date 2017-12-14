########################################################################################
# PSCarrot, by Joel Wiesmann, 2017, joel.wiesmann@workflowcommander.ch
#########################################################################################

<#
.Synopsis
   Create new connection to RabbitMQ server.
.DESCRIPTION
   New-RabbitMQConnection creates new connection to RabbitMQ server.
.EXAMPLE
   New-RabbitMQConnection
   Creates new connection to local RabbitMQ server using default credentials. 
#>
function Send-Carrot {
  Param (
    [Parameter(Mandatory)]
    [RabbitMQ.Client.Framing.Impl.AutorecoveringConnection]$con,
    [Parameter(Mandatory)]
    [string]$exchange,
    [Parameter(Mandatory)]
    [string]$payload,
    [string]$contentType = 'text/plain',
    [string]$routingKey  = ''
  )
  
  if (! $con.IsOpen) {
    throw('Carrot RabbitMQ connection is not opened (anymore).')
  }

  $messageBodyBytes = [Text.Encoding]::UTF8.GetBytes($payload)
  
  $model = $con.CreateModel()
  $props = $model.CreateBasicProperties()
  $props.ContentType = $contentType

  $model.BasicPublish($exchange,
                    $routingKey, 
                    $false,
                    $props,
                    $messageBodyBytes
  )

  $model.Close()
}