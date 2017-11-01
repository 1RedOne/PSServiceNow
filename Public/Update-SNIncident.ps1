<#
.Synopsis
   Use this cmdlet to update a SN Incident
.DESCRIPTION
   Provide a hashtable @{Key=Value} to update any field in a ServiceNow Incident
.EXAMPLE
Update-SNIncident -sysid 06b79417db43260057b1f1fcbf961921 -message @{'short_description'="Test123455"}


number            : INC0010008
Opened            : 2016-11-17 17:03:47
Priority          : Planning
short_description : Test123455
State             : 
category          : inquiry
active            : true
caller_id         : @{link=https://foxdeploylab.service-now.com/api/now/table/sys_user/c30b0c57db87260087eafb37bf9619c3; 
                    value=c30b0c57db87260087eafb37bf9619c3}
assignment_group  : 
sys_id            : 06b79417db43260057b1f1fcbf961921
.EXAMPLE
Update-SNIncident -sysid 06b79417db43260057b1f1fcbf961921 -message @{'assignment_group'="lab-test-assignment-group"}

>This does not work due to likely permissions reasons as of 11/17, but once this is resolved, we should be able to update the group 
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Update-SNIncident
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
        $sysid,
        $message        
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
        
        Write-Debug "test WebRequest"
        $url = "https://foxdeploylab.service-now.com/api/now/table/incident/$sysid"
        $body = $message | ConvertTo-Json

        try   {$results = Invoke-RestMethod -Uri $url -Headers $headers -ContentType 'application/json' -Body $body -ErrorAction Stop -Method Patch}
        catch {
            failure;
            Write-warning "We recieved some sort of error, check credentials and try again";
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
        
        $results.result | select Number,@{L='Opened';Exp={$_.sys_created_on}},`
            @{L='Priority';Exp={
                        switch ($_.priority)
                        {
                            1 {'Critical'}
                            2 {'High'}
                            3 {'Moderate'}
                            4 {'Low'}
                            5 {'Planning'}
                        }
                      }},short_description,@{L='State';Exp={
                        switch ($_.State)
                        {
                            1{'New'}
                            2{'In Progress'}
                            3{'On Hold'}
                            7{'Closed'}
                        }
                    }},Category,Active,caller_id,assignment_group,sys_id
                    
        }
    }
}
