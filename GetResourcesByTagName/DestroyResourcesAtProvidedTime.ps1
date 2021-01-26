#requires -version 2
<#
    .SYNOPSIS
    Destroy/Delete Resources in a Microsoft Azure Subscription using Tags
    .DESCRIPTION
    <Brief description of script>
    .PARAMETER DestroyTagName
        Name of the Tag that will be used to search for resources with the associated tag name
    .PARAMETER DestroyTagValue
        Value of the Tag that will be used to search for resources with the associated tag name
    .PARAMETER LogPath
        Folder path location where the log file will be created
    .INPUTS
    <Inputs if any, otherwise state None>
    .OUTPUTS
    Log file stored in LogPath\<ScriptName>.log
    .NOTES
    Version:        1.0
    Author:         <Name>
    Creation Date:  <Date>
    Purpose/Change: Initial script development

    .EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "$LogPath"
$sLogName = (Get-item $PSCommandPath).Name + ".log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function CheckAzureLogin
{
    Try
    {
        $content = Get-AzSubscription
    }
    Catch
    {
        if ($_ -like "*Run Connect-AzAccount to login*")
        {
            Write-Host "The User is not logged into Azure to Perform this action."
            Log-Write -LogPath $sLogFile -LineValue "The User is not logged into Azure to Perform this action."
            Break
        }
        Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
        Break
    }
}

Function DestroyAzureResources{
  Param(
    $tagName
    $tagValue
  )

  Begin{
    Write-Host "Collection List of Resources and Redsource Groups to Destroy with the Tag Name: $tagName, and Tag value: $tagValue"
    Log-Write -LogPath $sLogFile -LineValue "Collection List of Resources and Redsource Groups to Destroy with the Tag Name: $tagName, and Tag value: $tagValue"
  }

  Process{
    Try{

        $resourceGroups=$(Get-AzResourceGroup -Tag @{"$tagName"="$tagValue"})
        $resources=(Get-AzResource -Tag @{"$tagName"="$tagValue"})

        foreach ($resource in $resources.Id) {
            Write-Host "Deleting Azure Resource: $resource"
            Remove-AzResource -ResourceId $resource -Force
        }

        foreach ($resourceGroup in $resourceGroups.ResourceId) {
            Write-Host "Deleting Azure Resource: $resourceGroup"
            Remove-AzResourceGroup -ResourceId $resourceGroup -Force
        }
    }

    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }

  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
CheckAzureLogin
DestroyAzureResources -LogName $DestroyTagName -LogPath $DestroyTagValue
Log-Finish -LogPath $sLogFile



