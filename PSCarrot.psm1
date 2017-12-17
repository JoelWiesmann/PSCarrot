########################################################################################
# PSCarrot, by Joel Wiesmann, 2017, joel.wiesmann@workflowcommander.ch
#########################################################################################

if ($Host.Name -eq 'Windows PowerShell ISE Host') {
  Write-Warning 'Using PSCarrot with the ISE causes hanging connections if you do not properly'
  Write-Warning 'close the connection before closing the ISE. In case this happens to you, you'
  Write-Warning 'can force-close the connection.'
}