<#
.Synopsis
   Returns a listing of Groups in ServiceNow
.DESCRIPTION
   Use this cmdlet to retrieve groups in ServiceNow, which will return the Name,Description,ParentGroup,Active,Email and sys_id of all ServiceNow Groups
.EXAMPLE
    Get-SNGroup


name          : IT
description   :
parent        :
active        : true
email         :
sys_id        : 1359e3630cdda9405ac65c2573079a97
sys_mod_count : 3

name          : lab-test-assigment-group
description   :
parent        :
active        : true
email         :
sys_id        : 4702685bdb87260087eafb37bf96190a
sys_mod_count : 0
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
#>
function Get-SNGroup
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # To filter on the state of an incident, provide a value here
        [Parameter(Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("New", "In Progress", "On Hold","Closed")]
        $State        
    )

    Begin
    {

        # Eg. User name="admin", Password="admin" for this code sample.
        $user = "Stephen@foxdeploy.com"
        $pass = '' #yourPWHere

        # Build auth header
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

        # Set proper headers
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/json')
    }
    Process
    {
        
        $url = 'https://foxdeploylab.service-now.com/api/now/table/sys_user_group'

        try   {$results = Invoke-RestMethod -Uri $url -Headers $headers -ContentType 'application/json' -ErrorAction Stop}
        catch {Write-warning "We recieved some sort of error, check credentials and try again";
               return}
        
        Write-Verbose "Retrieved $($results.result.Count )"
    }
    End
    {

       if ($state){
        
        $stateCode = $stateTable.GetEnumerator() | ? Value -eq $state | Select -ExpandProperty Name
        Write-Verbose "user provided a `$state filter, filtering"
        Write-Verbose "value of $state equals $stateCode"
        Write-Debug "test output of filtered `$results here"
        $results.result | ? state -eq $stateCode
        }
       else{
        Write-Debug "test output of unfiltered `$results here"
        
        $results.result | select Name,Description,Parent,Active,email,sys_id,sys_mod_count
                    
        }
    }
}
