Function Export-LocalSpotlightPictures {
    Param ( 
            [Parameter(Position = 0, Mandatory = $False)]
            [string]$Path = ($env:TEMP + "\Spotlighter" + (Get-Date -Format -dd-MM))
        )

    $counter = 0

    If (!(Test-Path $Path))
	{
        New-Item $Path -ItemType Directory | Out-Null
		Write-Verbose "Created directory: $Path"
    }

    (Get-ChildItem $env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets).ForEach(
		{
			$verboseout = Copy-Item -Path $_.FullName -Destination "$Path\Spotlight$counter.jpg" -PassThru
			Write-Verbose "Exported file from appdata to temporary path: $verboseout"
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
	
	If (!(Test-Path $Destination))
	{
        New-Item $Destination -ItemType Directory | Out-Null
		Write-Verbose "Created directory: $Destination"
    }
	
	$DestinationFiles = Get-ChildItem $Destination
	If ($DestinationFiles -ne $null)
	{
		$Hashes = ($DestinationFiles | Get-FileHash)
		$counter = $Hashes.Count
	}
	Else
	{
		$Hashes = $null
		$counter = 0
	}

	$FileCopied = ""
	
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
						If ((Copy-Item $_.Path -Destination ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg") -PassThru) -ne $null)
						{
							$FileCopied = $FileCopied + ("Spotlight" + $counter.ToString("000") + ".jpg`n")
							Write-Verbose ("Saved Spotlight picture: $Destination\" + ("Spotlight" + $counter.ToString("000") + ".jpg"))
							$counter++
						}
					}
				}
				Else 
				{
					While (Test-Path ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg"))
					{
						$counter++
					}
					If ((Copy-Item $_.Path -Destination ("$Destination\Spotlight" + $counter.ToString("000") + ".jpg") -PassThru) -ne $null)
					{
						$FileCopied = $FileCopied + ("$Destination\" + ("Spotlight" + $counter.ToString("000") + ".jpg`n"))
						Write-Verbose ("Saved Spotlight picture: $Destination\" + ("Spotlight" + $counter.ToString("000") + ".jpg"))
						$counter++
					}
				}
			}
		}
	)
	return $FileCopied
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
        $EventLog = (Import-SpotlightPictures -Source $TempPath -Destination $Destination)
		If ($EventLog -ne "")
		{
			$EventLog = "Save-Spotlight Log:`n`n" + $EventLog
		}
		Else
		{
			$EventLog = "Save-Spotlight Log:`n`nNo files saved."
		}
		$ev = Get-EventLog -LogName Application -Source "Spotlight Manager" -ErrorAction SilentlyContinue
		If ($ev -eq $null)
		{
			try
			{
				New-EventLog -LogName Application -Source "Spotlight Manager"
			}
			catch
			{
				Write-Host "Unable to write to the Event Log. Run the script as administrator once."
				Write-Verbose $EventLog
			}
		}
		Else
		{
			Write-EventLog -LogName Application -Source "Spotlight Manager" -EntryType Information -EventId 1 -Message $EventLog
		}
        Remove-Item -Path $TempPath -Recurse -Force
    } 
	Else
	{
        Throw "Error exporting local Spotlight resources to $TempPath"
    }
}
