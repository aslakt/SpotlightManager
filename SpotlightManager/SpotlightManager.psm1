Function Export-LocalSpotlightPictures {
    Param ( 
            [Parameter(Position = 0, Mandatory = $False)]
            [string]$Path = ($env:TEMP + "\Spotlighter" + (Get-Date -Format -dd-MM))
        )

    $counter = 0

    If (!(Test-Path $Path))
	{
        New-Item $Path -ItemType Directory | Out-Null
    }

    (Get-ChildItem $env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets).ForEach(
		{
			Copy-Item -Path $_.FullName -Destination "$Path\Spotlight$counter.jpg"
			$counter++
		}
	)
}

Function Get-FileMetaData {
    Param([string[]]$folder)
    ForEach ($sFolder in $folder)
	{
        $a = 0
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.namespace($sFolder)

        ForEach ($File in $objFolder.items())
		{ 
            $FileMetaData = New-Object PSOBJECT
            For ($a ; $a  -le 266; $a++)
			{ 
				If ($objFolder.getDetailsOf($File, $a))
				{
					$hash += @{ $($objFolder.getDetailsOf($objFolder.items, $a)) = $($objFolder.getDetailsOf($File, $a)) }
					$FileMetaData | Add-Member $hash
					$hash.clear() 
				}
            }
            $a=0
            $FileMetaData
        }
    }
}

Function Import-SpotlightPictures {
    Param ( 
            [Parameter(Position = 0, Mandatory = $True)]
            [string]$Source = "",
            [Parameter(Position = 1, Mandatory = $False)]
            [string]$Destination = "$env:USERPROFILE\OneDrive\Pictures\Spotlight"
        )
		
    $Hashes = (Get-ChildItem $Destination -Filter "Spotlight???.jpg" | Get-FileHash)
    $counter = $Hashes.Count()
	
    (Get-FileMetaData -folder $Source).ForEach(
		{
			If ($_.Dimensions -eq "1920 x 1080")
			{
				If ($Hashes.Hash -ne $null)
				{
					If (!($Hashes.Hash.Contains( (Get-FileHash $_.Path).Hash ) ))
					{
						While (Test-Path ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg"))
						{
							$counter++
						}
						Copy-Item $_.Path -Destination ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg")
						$counter++
					}
				}
				Else 
				{
					If (!($Hashes.Hash.Contains( (Get-FileHash $_.Path).Hash ) ))
					{
						While (Test-Path ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg"))
						{
							$counter++
						}
						Copy-Item $_.Path -Destination ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg")
						$counter++
					}
				}
			}
		}
	)
}

Function Save-Spotlight {
    [cmdletbinding()]
    Param ( 
            [Parameter(Position = 0, Mandatory = $False)]
            [string]$TempPath = ($env:TEMP + "\Spotlighter" + (Get-Date -Format -dd-MM)),
            [Parameter(Position = 1, Mandatory = $False)]
            [string]$Destination = "$env:USERPROFILE\OneDrive\Pictures\Spotlight"
        )

    Export-LocalSpotlightPictures -Path $TempPath
	
    If (Test-Path $TempPath)
	{
        Write-Verbose "Exported local Spotlight resources to $TempPath"
        Write-Verbose "Verifying Spotlight pictures..."
        Import-SpotlightPictures -Source $TempPath -Destination $Destination
        Write-Verbose "Imported Spotlight pictures from $TempPath to $Destination"
        Remove-Item -Path $TempPath -Recurse -Force
        Write-Host "Operation completed"
    } 
	Else
	{
        Throw "Error exporting local Spotlight resources to $TempPath"
    }
}
