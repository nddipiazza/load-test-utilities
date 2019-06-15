import-module ActiveDirectory
$fullName = "Jack Robinson20"
$givenName = "Jack20"
$surName = "Robinson20"
$samAccountName = "jack.robinson20"
$userPrincipalName = "jack.robinson20@fusionis.life"
$path = "CN=Users,DC=fusionis,DC=life"
$password = "Start12345" | ConvertTo-SecureString -AsPlainText -Force
New-ADUser -Name $fullName -GivenName $givenName -Surname $surName -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -Path $path -AccountPassword $Password -Enabled $true