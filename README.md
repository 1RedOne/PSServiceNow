# What's this?

A PowerShell Module containing cmdlets that work with ServiceNow.

## Why?

To provide a scaffolding to build additional ServiceNow features in an easy to scale method.

## Cmdlets Exposed

* Get-SNGroup
* Get-SNIncident
* New-SNIncident
* Update-SNIncident

# How to use


## Get-SNIncident List ServiceNow Incidents

*Returns a listing of ServiceNow incidents, with support for filtering based on State of Incident*

        Get-SNIncident | select -First 2


        number            : INC0000001
        Opened            : 2014-10-30 18:24:13
        Priority          : Critical
        short_description : Can't read email
        State             : Closed
        category          : network
        active            : false
        caller_id         : @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user/5137153cc611227c000bbd1bd8cd2005; value=5137153cc611227c000bbd1bd8cd2005}
        assignment_group  : @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user_group/d625dccec0a8016700a222a0f7900d06; value=d625dccec0a8016700a222a0f7900d06}

        number            : INC0000002
        Opened            : 2014-10-19 22:30:06
        Priority          : Critical
        short_description : Unable to get to network file shares
        State             : On Hold
        category          : network
        active            : true
        caller_id         : @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user/5137153cc611227c000bbd1bd8cd2005; value=5137153cc611227c000bbd1bd8cd2005}
        assignment_group  : @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user_group/287ebd7da9fe198100f92cc8d1d2154e; value=287ebd7da9fe198100f92cc8d1d2154e}

## New-SNIncident Create a ServiceNow Incidents

*Use to create a new incident (ticket) in ServiceNow*


    -------------------------- EXAMPLE 1 --------------------------

        New-SNIncident -priority Low -description "Making a ServiceNow Ticket With PowerShell" -guid "Tester"
        -Verbose -AssignmentGroup 'AppSense'  -scomurl http://www.foxdeploy.com
        Created a new ticket!


        sys_created_by    : sowen
        state             : 1
        severity          : 3
        opened_at         : 2016-10-14 17:34:56
        sys_id            : b6c8d5d0db2ee20087eafb37bf961942
        category          : inquiry
        active            : true
        caller_id         :
        @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user/32547850db6ee20057b1f1fcbf9619f4;
        value=32547850db6ee20057b1f1fcbf9619f4}
        assignment_group  :
        @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user_group/287ebd7da9fe198100f92cc8d1d2154e;
        value=287ebd7da9fe198100f92cc8d1d2154e}
        short_description : Making a ServiceNow Ticket With PowerShell

## Upate-SNIncident 

*Use this cmdlet to update a SN Incident*


        Update-SNIncident -sysid 06b79417db43260057b1f1fcbf961921 -message @{'short_description'="Test123455"}

        number            : INC0010008
        Opened            : 2016-11-17 17:03:47
        Priority          : Planning
        short_description : Test123455
        State             :
        category          : inquiry
        active            : true
        caller_id         :
        @{link=https://FoxDeploylab.service-now.com/api/now/table/sys_user/c30b0c57db87260087eafb37bf9619c3;
                            value=c30b0c57db87260087eafb37bf9619c3}
        assignment_group  :
        sys_id            : 06b79417db43260057b1f1fcbf961921

## Get-SNGroup Get a list of all groups in ServiceNow 
*Use this cmdlet to retrieve groups in ServiceNow, which will return the Name,Description,ParentGroup,Active,Email and sys_id of all ServiceNow Groups*
    
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