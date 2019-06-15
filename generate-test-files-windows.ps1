# create a ton of text files on windows.

$ParentFolder=’C:\loadtest’

for ($folderIdx=0;$folderIdx -lt 100;$folderIdx++)
{
	$Folder = "$ParentFolder\folder$folderIdx"
	New-Item -ItemType Directory -Path $Folder

	# Create a series of files
	for ($fileIdx=0;$fileIdx -lt 10000; $fileIdx++)
	{
		# Let’s create a completely random filename
		$filename="$Folder\${fileIdx}.txt"

		# Now we’ll create the file with some content
		Add-Content -Value "${fileIdx}"-Path $filename
	}
}
