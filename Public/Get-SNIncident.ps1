<#
.Synopsis
   Retrieves a list of ServiceNow Incidents
.DESCRIPTION
   Returns a listing of ServiceNow incidents, with support for filtering based on State of Incident
.EXAMPLE
   Get-SNIncident | select -First 2


number            : INC0000001
Opened            : 2014-10-30 18:24:13
Priority          : Critical
short_description : Can't read email
State             : Closed
category          : network
active            : false
caller_id         : @{link=https://foxdeploylab.service-now.com/api/now/table/sys_user/5137153cc611227c000bbd1bd8cd2005; value=5137153cc611227c000bbd1bd8cd2005}
assignment_group  : @{link=https://foxdeploylab.service-now.com/api/now/table/sys_user_group/d625dccec0a8016700a222a0f7900d06; value=d625dccec0a8016700a222a0f7900d06}

number            : INC0000002
Opened            : 2014-10-19 22:30:06
Priority          : Critical
short_description : Unable to get to network file shares
State             : On Hold
category          : network
active            : true
caller_id         : @{link=https://foxdeploylab.service-now.com/api/now/table/sys_user/5137153cc611227c000bbd1bd8cd2005; value=5137153cc611227c000bbd1bd8cd2005}
assignment_group  : @{link=https://foxdeploylab.service-now.com/api/now/table/sys_user_group/287ebd7da9fe198100f92cc8d1d2154e; value=287ebd7da9fe198100f92cc8d1d2154e}
#>
function Get-SNIncident
{
    [CmdletBinding()]
    [Alias()]
    [OutputType('ServiceNow.Automation.Object.Incident')]
    Param
    (
        # To filter on the state of an incident, provide a value here
        [Parameter(Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("New", "In Progress", "On Hold","Closed")]
        $State    ,
        [Parameter(Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("dev", "lab","prod")]
        [string]$environment    
    )

    Begin
    {
       
        switch ($environment)
        {
            'dev' {
                    # Eg. User name="admin", Password="admin" for this code sample.
                    $user = "Stephen@foxdeploy.com"
                    $pass = '' #yourPWHere

                    $url = 'https://foxdeploydev.service-now.com/api/now/table/incident'
                    }
            'lab' {
                    # Eg. User name="admin", Password="admin" for this code sample.
                    $user = "Stephen@foxdeploy.com"
                    $pass = '' #yourPWHere

                    $url = 'https://foxdeploylab.service-now.com/api/now/table/incident'
                    }
            'prod'{}
            
        }


        

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
       

        try   {$results = Invoke-RestMethod -Uri $url -Headers $headers -ContentType 'application/json' -ErrorAction Stop -Method Get}
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
