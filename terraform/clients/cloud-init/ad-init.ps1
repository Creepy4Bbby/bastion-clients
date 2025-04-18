<powershell>
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "efrei.local" 
  -SafeModeAdministratorPassword (ConvertTo-SecureString "SuperSecure123!" -AsPlainText -Force) 
  -Force
</powershell>