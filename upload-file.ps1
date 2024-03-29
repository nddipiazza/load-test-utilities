# This script will extract all of the documents and their versions from a site. It will also
# download all of the list data and document library metadata as a CSV file.
 
Add-PSSnapin Microsoft.SharePoint.PowerShell -erroraction SilentlyContinue
# 
# $destination: Where the files will be downloaded to
# $webUrl: The URL of the website containing the document library for download
# $listUrl: The URL of the document library to download
 
#Where to Download the files to. Sub-folders will be created for the documents and lists, respectively.
$destination = "C:\lucidworks\Export"
 
#The site to extract from. Make sure there is no trailing slash.
$site = "http://172.16.11.133/site-901dd45c-73a4-4e5a-88c6-b45748e573a0"
 
# Function: HTTPDownloadFile
# Description: Downloads a file using webclient
# Variables
# $ServerFileLocation: Where the source file is located on the web
# $DownloadPath: The destination to download to
 
function HTTPDownloadFile($ServerFileLocation, $DownloadPath)
{
	$webclient = New-Object System.Net.WebClient
	$webClient.UseDefaultCredentials = $true
	$webclient.DownloadFile($ServerFileLocation,$DownloadPath)
}
 
function DownloadMetadata($sourceweb, $metadatadestination)
{
	Write-Host "Creating Lists and Metadata"
	$sourceSPweb = Get-SPWeb -Identity $sourceweb
	$metadataFolder = $destination+"\"+$sourceSPweb.Title+" Lists and Metadata"
	$createMetaDataFolder = New-Item $metadataFolder -type directory 
	$metadatadestination = $metadataFolder
 
	foreach($list in $sourceSPweb.Lists)
	{
		Write-Host "Exporting List MetaData: " $list.Title
		$ListItems = $list.Items 
		#$Listlocation = $metadatadestination+"\"+$list.Title+".csv"
		#$ListItems | Select * | Export-Csv $Listlocation  -Force
        $Listlocation = $metadatadestination+"\RoleAssignments-"+$list.Title+".csv"
        $ListItems.RoleAssignments | Select * | Export-Csv $Listlocation  -Force
        echo $ListItems.RoleAssignments.Count roles
	}
}
 
# Function: GetFileVersions
# Description: Downloads all versions of every file in a document library
# Variables
# $WebURL: The URL of the website that contains the document library
# $DocLibURL: The location of the document Library in the site
# $DownloadLocation: The path to download the files to
 
function GetFileVersions($file)
{
	foreach($version in $file.Versions)
	{
		#Add version label to file in format: [Filename]_v[version#].[extension]
		$filesplit = $file.Name.split(".") 
		$fullname = $filesplit[0] 
		$fileext = $filesplit[1] 
		$FullFileName = $fullname+"_v"+$version.VersionLabel+"."+$fileext			
 
		#Can't create an SPFile object from historical versions, but CAN download via HTTP
		#Create the full File URL using the Website URL and version's URL
		$fileURL = $webUrl+"/"+$version.Url
 
		#Full Download path including filename
		$DownloadPath = $destinationfolder+"\"+$FullFileName
 
		#Download the file from the version's URL, download to the $DownloadPath location
		HTTPDownloadFile "$fileURL" "$DownloadPath"
	}
}
 
# Function: DownloadDocLib
# Description: Downloads a document library's files; called GetGileVersions to download versions.
# Credit 
# Used Varun Malhotra's script to download a document library
# as a starting point: http://blogs.msdn.com/b/varun_malhotra/archive/2012/02/13/10265370.aspx
# Variables
# $folderUrl: The Document Library to Download
# $DownloadPath: The destination to download to
function DownloadDocLib($folderUrl)
{
    $folder = $web.GetFolder($folderUrl)
    foreach ($file in $folder.Files) 
	{
        #Ensure destination directory
		$destinationfolder = $destination + "\" + $folder.Url 
        if (!(Test-Path -path $destinationfolder))
        {
            $dest = New-Item $destinationfolder -type directory 
        }
 
        #Download file
        $binary = $file.OpenBinary()
        $stream = New-Object System.IO.FileStream($destinationfolder + "\" + $file.Name), Create
        $writer = New-Object System.IO.BinaryWriter($stream)
        $writer.write($binary)
        $writer.Close()
 
		#Download file versions. If you don't need versions, comment the line below.
		GetFileVersions $file
	}
}
 
# Function: DownloadSite
# Description: Calls DownloadDocLib recursiveley to download all document libraries in a site.
# Variables
# $webUrl: The URL of the site to download all document libraries
function DownloadSite($webUrl)
{
	$web = Get-SPWeb -Identity $webUrl
 
	#Create a folder using the site's name
	$siteFolder = $destination + "\" +$web.Title+" Documents"
	$createSiteFolder = New-Item $siteFolder -type directory 
	$destination = $siteFolder
 
	foreach($list in $web.Lists)
	{
		if($list.BaseType -eq "DocumentLibrary")
		{
			Write-Host "Downloading Document Library: " $list.Title
			$listUrl = $web.Url +"/"+ $list.RootFolder.Url
			#Download root files
			DownloadDocLib $list.RootFolder.Url
			#Download files in folders
			foreach ($folder in $list.Folders) 
			{
    			DownloadDocLib $folder.Url
			}
		}
	}
}
 
#Download Site Documents + Versions
DownloadSite "$site"
 
#Download Site Lists and Document Library Metadata
DownloadMetadata $site $destination