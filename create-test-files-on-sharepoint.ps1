Add-PSSnapin Microsoft.SharePoint.PowerShell 

# Set the variables
$WebURL = "http://win-d9fm7ip9r36/sites/awesome-computers-inc"
$DocLibName = "Shared Documents"

# Get a variable that points to the folder
$Web = Get-SPWeb $WebURL
$List = $Web.GetFolder($DocLibName)
$Files = $List.Files

For ($i=500001; $i -le 600000; $i++) {
    $FilePath = "c:\lucidworks\testdir\File_1_$i.txt"
    echo "file $i" > $FilePath

	# Get just the name of the file from the whole path
	$FileName = $FilePath.Substring($FilePath.LastIndexOf("\")+1)

	# Load the file into a variable
	$File= Get-ChildItem $FilePath

	# Upload it to SharePoint
	$Files.Add($DocLibName +"/" + $FileName,$File.OpenRead(),$false)
}
$web.Dispose()
