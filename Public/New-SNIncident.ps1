<#
.Synopsis
   Use to create a new incident (ticket) in ServiceNow
.DESCRIPTION
   This cmdlet is to be used in an automation workflow, linking System Center Operations Manager to ServiceNow, via an Orchestrator Runbook
.EXAMPLE
   New-SNIncident -priority Low -Shortdescription "Making a ServiceNow Ticket With PowerShell" -fulldescription "Additional information goes here" -guid "Tester" -AssignmentGroup 'AppSense' -scomurl http://www.foxdeploy.com
Created a new ticket!

number              : INC0010101
sys_id              : d9b13d92db63220056d4fb37bf9619ec
CreatedBy           : sowen
State               : 1
IncidentURL         : https://foxdeploydev.service-now.com/api/now/table/incident/11b13d92db63220056d4fb37bf9619ed
u_assignment_group  : AppSense
u_short_description : Making a ServiceNow Ticket With PowerShell
Link                : https://foxdeploydev.service-now.com/nav_to.do?uri=incident.do?sys_id=11b13d92db63220056d4fb37bf9619ed
.INPUTS
   Inputs to this cmdlet (if any)
.LINK
   Learn about this integration at 
   https://foxdeploylab.service-now.com/nav_to.do?uri=%2F$restapi.do
.OUTPUTS
   This cmdlet outputs a PowerShell Custom object with the following properties

   number,sys_id,CreatedBy,State,IncidentURL,u_assignment_group,u_short_description,Link
.NOTES
   General notes
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function New-SNIncident
{
    [CmdletBinding()]
    [Alias()]
    [OutputType('ServiceNow.Automation.Object.Incident')]
    Param
    (
        #Provide the full word priority of this incident, choose from "Critical", "High", "Moderate","Low","Planning"
        [Parameter(Position=0,Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Critical", "High", "Moderate","Low","Planning")]
        $priority,
        
        #Provide the desired state of this incident, choose from "New", "In Progress", "On Hold","Closed"
        [Parameter(Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("New", "In Progress", "On Hold","Closed")]
        $State,

        #Provide the desired state of this incident, choose from "New", "In Progress", "On Hold","Closed"
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $guid,

        #Provide a description of the issue, such as "Automatically created ticket, $Alert.Body"
        [Parameter(Position=2,Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ShortDescription,
        
        #Provide a description of the issue, such as "Automatically created ticket, $Alert.Body"
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $FullDescription,

        #This cmdlet defaults to generating tickets as Stephen Owen.  Provide the desired 'caller' username.
        [Parameter(Position=3)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $caller='sowen',

        #Provide the SCOM ticket URL (will be added to incident record)
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $scomurl,

        #Provide the name of the group to which you'd like to assign the ticket.
        $AssignmentGroup        
    )

    Begin
    {

       switch ($priority)
        {
            'Critical' {$priorityCode = 1}
            'High'     {$priorityCode = 2}
            'Moderate' {$priorityCode = 3}
            'Low'      {$priorityCode = 4}
            'Planning' {$priorityCode = 5}
        }

        switch ($State)
        {
            'New'          {$stateCode=1}
            'In Progress'  {$stateCode=2}
            'On Hold'      {$stateCode=3}
            'Closed'       {$stateCode=7}
        }

        # Eg. User name="admin", Password="admin" for this code sample.
        $user = "stephen@foxdeploy.com"
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
        
        $url = 'https://foxdeploydev.service-now.com/api/now/table/u_scom_incident_import'
        $body = @{  "u_priority"=$priorityCode
                    "u_short_description"=$ShortDescription
                    "u_assignment_group"="$AssignmentGroup"
                    "u_scom_guid" = $Guid
                    "u_scom_url" = $scomUrl
                    "u_description" = $FullDescription
                    } | ConvertTo-Json


        try   {$results = Invoke-RestMethod -method Post `
                            -Uri $url `
                            -Headers $headers `
                            -ContentType 'application/json' `
                            -Body $body `
                            -ErrorAction Stop}
        catch {Write-warning "We recieved some sort of error, check credentials and try again";
               Failure
               return}
        
        Write-Verbose "Retrieved $($results.result.Count )"
    }
    End
    {
       Write-Debug "Debug the results of creating an alert"
       #parse result to get the record link
       $url = $results.result.sys_target_sys_id.link
       $newIncident = (Invoke-Restmethod $url -Headers $headers)
       $number = $newIncident.result.number
       $create = $newIncident.result.sys_created_by
       
       $link = "https://foxdeploydev.service-now.com/nav_to.do?uri=incident.do?sys_id=$($newIncident.result.sys_id)"

       if ($results.result){Write-host -ForegroundColor Green "Created a new ticket!"}
       $results.result  | Select @{Name='number';exp={$number}},
                                sys_id,@{Name='CreatedBy';exp={$create}},
                                @{Name='State';exp={$newIncident.result.state}},
                                @{Name='IncidentURL';exp={$url}},
                                u_assignment_group,u_short_description,u_description,
                                @{Name='Link';exp={$link}}
    }
}
