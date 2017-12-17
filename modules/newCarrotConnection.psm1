<#
  .SYNOPSIS
    Create new connection to RabbitMQ.

  .DESCRIPTION
    New-CarrotConnection creates new connection to RabbitMQ to send and retrieve messages.

  .NOTES
    PSCarrot by Joel Wiesmann, https://github.com/JoelWiesmann/PSCarrot

  .EXAMPLE
    $queCon = New-CarrotConnection
    Creates new connection to localhost RabbitMQ server using default (guest/guest) credentials. 
#>
 
function New-CarrotConnection {
  [CmdletBinding(DefaultParameterSetName='URI')]

  Param (
    [Parameter(ParameterSetName='NonURI')]
    [string]       $HostName    = 'localhost',
    [Parameter(ParameterSetName='NonURI')]
    [int]          $Port        = 5672,
    [Parameter(ParameterSetName='NonURI')]
    [PSCredential] $Credential,
    [Parameter(ParameterSetName='NonURI')]
    [string]       $VirtualHost = '/',
    [Parameter(ParameterSetName='URI')]
    [string]       $URI         = 'amqp://guest:guest@localhost:5672/',
    [int]          $safeWait    = 100
  )

  $connectionFactory = New-Object RabbitMQ.Client.ConnectionFactory
 
  if ($PSCmdlet.ParameterSetName -eq 'NonURI') {
    if ($Credential) {
      $UserName = $Credential.UserName
      $Password = $Credential.GetNetworkCredential().Password
    } 
    else {
      $UserName = 'guest'
      $Password = 'guest'
    }

    $connectionFactory.HostName    = $HostName
    $connectionFactory.Port        = $Port
    $connectionFactory.UserName    = $UserName
    $connectionFactory.Password    = $Password
    $connectionFactory.VirtualHost = $VirtualHost
  } 
  else {
    $connectionFactory.Uri         = $URI
  }

  try {
    $connection = $connectionFactory.CreateConnection()
  } 
  catch {
    throw $_
  }

  $connection | `
    Add-Member channel ($connection.CreateModel()) -PassThru | `
    Add-Member safeWait $safeWait -PassThru | `
    Add-Member -Type ScriptMethod -Name recover -Value { $this.channel = $this.CreateModel() } -PassThru 
}
