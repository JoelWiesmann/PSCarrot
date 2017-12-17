
@{
  RootModule = 'PSCarrot.psm1'
  ModuleVersion = '1.0.0'
  GUID = '82697cb4-cb12-4ed7-a218-c08e3e788ccd'
  Author = 'Joel Wiesmann (joel.wiesmann@workflowcommander.ch)'
  CompanyName = 'WorkflowCommander GmbH'
  Copyright = '(c) 2017 WorkflowCommander GmbH. All rights reserved.'
  Description = 'Client for RabbitMQ for sending / receiving messages.'
  PowerShellVersion = '3.0'

  RequiredAssemblies = @(
    'lib\RabbitMQ.Client.dll'
  )

  TypesToProcess = @(
  )
  
  FormatsToProcess = @(
  )
  
   NestedModules = @(
    'modules\newCarrotConnection.psm1',
    'modules\sendCarrot.psm1',
    'modules\getCarrot.psm1',
    'modules\confirmCarrot.psm1',
    'modules\testCarrotConnection.psm1'
  )

  FunctionsToExport = @('*')
  VariablesToExport = @()
  AliasesToExport = @()
}
