#
# Module manifest for module 'SpotlightManager'
#
# Created by: Aslak Tangen (aslakt@gmail.com)
#
# Created on: 23.08.2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'SpotlightManager.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '0e33e940-02f3-4955-ad65-5bddeb018321'

# Author of this module
Author = 'Aslak Tangen'

# Copyright statement for this module
Copyright = 'No copyright'

# Description of the functionality provided by this module
Description = 'Supplies commandlets for managing Spotlight pictures.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Functions to export from this module
FunctionsToExport = @(
    'Save-Spotlight',
    "Import-SpotlightPictures"
)
}

