#Get public and private function definition files.
    $PublicFunction  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *tests* -ErrorAction SilentlyContinue )
    $PrivateFunction = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude *tests* -ErrorAction SilentlyContinue )
    
#Dot source the files
    Foreach($import in @($PublicFunction + $PrivateFunction))
    {
        "importing $import"
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

#region Define ServiceNow Object TypeData
$Common = @{
    MemberType="NoteProperty"
    TypeName = "ServiceNow.Automation.Object.Incident"
    Value=$null

}

Update-TypeData @Common -MemberName number
Update-TypeData @Common -MemberName sys_id
Update-TypeData @Common -MemberName CreatedBy
Update-TypeData @Common -MemberName State
Update-TypeData @Common -MemberName IncidentURL
Update-TypeData @Common -MemberName u_assignment_group
Update-TypeData @Common -MemberName u_short_description
Update-TypeData @Common -MemberName Link
#endregion
  
Export-ModuleMember -Function $PublicFunction.Basename