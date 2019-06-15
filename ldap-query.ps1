Write-Output "first_name,last_name,email_address,mailalias"

$root = [ADSI]"LDAP://DC=fusionis,DC=life"
$search = [adsisearcher]$root
$Search.Filter = "(&(objectCategory=person)(whenCreated>=20190219174130.0Z))"
$colResults = $Search.FindAll()

foreach ($i in $colResults)
{
 [string]$i.Properties.Item('givenName'),[string]$i.Properties.Item('sn'),[string]$i.Properties.Item('mail'),[string]$i.Properties.Item('mailNickname') -join ","
}