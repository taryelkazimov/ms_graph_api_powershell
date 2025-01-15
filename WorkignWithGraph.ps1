
# Verify installation
Get-InstalledModule Microsoft.Graph
Get-InstalledModule

# To install the v1 module of the SDK in PowerShell Core or Windows PowerShell, run the following command.
Install-Module -Name Microsoft.Graph -Scope AllUsers

# Optionally, you can change the scope of the installation using the -Scope parameter. This requires admin permissions.
Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force

# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0
# Define the Application (Client) ID and Secret
$ApplicationClientId = '<application(client)ID>' # Application (Client) ID
$ApplicationClientSecret = '<secret.value>' # Application Secret Value
$TenantId = 'Tenant_Id' # Tenant ID

# Convert the Client Secret to a Secure String
$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force

# Create a PSCredential Object Using the Client ID and Secure Client Secret
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret
# Connect to Microsoft Graph Using the Tenant ID and Client Secret Credential
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential