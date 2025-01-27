### Connect MS Graph for Unattended Scripts
#https://www.alitajran.com/connect-to-microsoft-graph-powershell/#h-method-3-how-to-connect-to-microsoft-graph-with-client-secret

#### ASK FOR PARAMETRS ####
param ($givenname, $surname, $department)

### Validate givenname and surname
if ($givenname -notmatch '^[a-zA-Z]+$') {
    Write-Output "Invalid givenname. Only letters are allowed."
    exit
}

### Validate surname
if ($surname -notmatch '^[a-zA-Z]+$') {
    Write-Output "Invalid surname. Only letters are allowed."
    exit
}
### GENERATE COMPLEX PASSWORD #####
$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
$length = 10

# Ensure at least one of each required character type
$lower = 'abcdefghijklmnopqrstuvwxyz' | Get-Random
$upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' | Get-Random
$number = '0123456789' | Get-Random
$symbol = '!@#$%^&*()' | Get-Random

# Generate the rest of the password
$remaining = -join ((1..($length - 4)) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })

# Combine and shuffle the password
$password = $lower + $upper + $number + $symbol + $remaining
$password = -join ($password.ToCharArray() | Sort-Object { Get-Random })
#### END GENERATE COMPLEX PASSWORD #####


# Configuration
$ClientId     = 'ClientId'
$TenantId     = 'TenantID'
$ClientSecret = 'Secret'

# Convert the client secret to a secure string
$ClientSecretPass = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force

# Create a credential object using the client ID and secure string
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretPass

try {
# Connect to Microsoft Graph with Client Secret
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome

$PasswordProfile = @{
    Password = $password
    ForceChangePasswordNextSignIn = $true
}

$defaultDomain = (Get-MgDomain | Where-Object { $_.IsDefault -eq 'True' }).id
$displayName   = $givenname + " " + $surname
$MailName      = $givenname + "." + $surname
$upn           = $MailName + "@" + $defaultDomain

# Check if user already exists
$userExists = Get-MgUser -Filter "userPrincipalName eq '$upn'"

if ($userExists) {
    Write-Output "User with UPN $upn already exists."
} else {
    New-MgUser -DisplayName "$displayName" -PasswordProfile $PasswordProfile -AccountEnabled:$true -MailNickname $MailName -UserPrincipalName $upn -GivenName $givenname -Surname $surname -Department $department $ | Out-Null
    
    Write-Output "User $displayName created successfully."

    Disconnect-MgGraph | Out-Null
}
}
catch {
    Write-Output $_.Exception.Message
}