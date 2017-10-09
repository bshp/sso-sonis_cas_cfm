<!---

   Copyright 2017 Jason A. Everling

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.



    For Connecting CAS SSO to SonisWeb

    By: Jason A. Everling
    Email: jeverling@bshp.edu
--->
<html>
<head>
    <link rel="stylesheet" type="text/css" href="css/styles.css">
</head>
<body>
<cfset session.uid = session.cfcas.getUsername()>
<cfset sonisds = "#SonisDS_Name#">
<cfquery name="getAffiliation" datasource="#sonisds#">
        SELECT TOP 1 modstat FROM vw_ssoLogin WHERE nmldap = #session.uid# ORDER BY modstat DESC
</cfquery>
<cfquery name="getAttributes" datasource="#sonisds#">
        SELECT #prefix#id AS soc_sec, #prefix#disabled AS disabled, #prefix#pin AS pin FROM vw_ssoLogin WHERE #prefix#ldap = #session.uid#
</cfquery>
<cfquery name="getProfiles" datasource="#sonisds#">
    SELECT multiprof, modstat FROM vw_ssoLogin WHERE nmldap = #session.uid#
</cfquery>
<cfif isDefined("form.submit")>
    <!--- clear current session vars --->
    <cfset session.bshpStatus = "">
    <cfset session.bshpAffiliation = "">
    <cfset session.bshpPrefix = "">
    <!--- set new vars based on preferred submission --->
    <cfif isDefined("form.submit") eq "Faculty">
        <cfset session.bshpStatus = "FA">
        <cfset session.bshpAffiliation = "faculty">
        <cfset session.bshpPrefix = "nm">
        <cfinclude template="../common/qry_login_reset_UP.cfm">
        <cfset session.module = 'FAC'>
        <cfset session.cur_module = 'faculty'>
        <cfset client.accessstring = 'H O M E'>
        <cfset client.loginpage = 'facsect.cfm'>
        <cfset client.sepcolor = '81b7ff'>
        <cfset form.pin = '#getAttributes.pin#'>
        <cfset form.pid = '#getAttributes.soc_sec#'>
        <cfset act='LI'>
        <cfset DESC='Faculty Access LI Succeeded'>
        <cfinclude template="../common/log.cfm">
        <cflocation url="facopts.cfm" addtoken="No">
    </cfif>
    <cfif isDefined("form.submit") eq "Staff">
        <cfset session.bshpStatus = "ADMN">
        <cfset session.bshpAffiliation = "staff">
        <cfset session.bshpPrefix = "sec">
        <cfinclude template="../common/qry_login_reset_UP.cfm">
        <cfset session.module = 'ADMIN'>
        <cfset session.cur_module = 'administrator'>
        <cfset client.accessstring = 'A D M I N I S T R A T I O N'>
        <cfset client.addr_search = '4'>
        <cfset client.nmtasklist = 'LDP,ANS,AWD,BDT,CHG,CRD,DSL,EWL,HOS,OGR,MPL,OBC,COV,OCR,OLV,OPR,ORH,OTC,OWL,PFC,POV,ADN,ADS,SSN,TMG,VRC,PAS,VME,VMP,WHD'>
        <cfset session.PREF_LANG = 'en_US'>
        <cfset client.loginpage = 'admnsect.cfm'>
        <cfinclude template="../common/randomizer.cfm">
        <cfset sc = #randnum#>
        <cfset Session.sec_id = #sc#>
        <!--- <cfset Session.sec_id = #getAttributes.soc_sec#> --->
        <cflocation url = "../#client.s_page##trim(client.s_list)#" addtoken = "No">
    </cfif>
    <!--- Not submitted yet --->
<cfelse>
    <cfif getAffiliation.modstat eq "FA">
        <cfset session.bshpStatus = "FA">
        <cfset session.bshpAffiliation = "faculty">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfif getAffiliation.modstat eq "ST">
        <cfset session.bshpStatus = "ST">
        <cfset session.bshpAffiliation = "student">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfif getAffiliation.modstat eq "SF">
        <cfset session.bshpStatus = "ADMN">
        <cfset session.bshpAffiliation = "staff">
        <cfset session.bshpPrefix = "sec">
    </cfif>
    <cfif session.bshpAffiliation neq "faculty" or session.bshpAffiliation neq "staff" or session.bshpAffiliation neq "student">
        <div id="notice">
            <p>Your account does not yet include Sonis access. Students, contact the registrar's office. Faculty or Staff, contact the IS Department</p>
        </div>
    </cfif>
    <!--- does not have multiprofiles, just log them in --->
    <cfif getAttributes.disabled eq 0 and getAttributes and getProfiles.multiprof eq 0>
        <cfif getAffiliation.modstat eq "FA">
            <cfinclude template="../common/qry_login_reset_UP.cfm">
            <cfset session.module = 'FAC'>
            <cfset session.cur_module = 'faculty'>
            <cfset client.accessstring = 'H O M E'>
            <cfset client.loginpage = 'facsect.cfm'>
            <cfset client.sepcolor = '81b7ff'>
            <cfset form.pin = '#getAttributes.pin#'>
            <cfset form.pid = '#getAttributes.soc_sec#'>
            <cfset act='LI'>
            <cfset DESC='Faculty Access LI Succeeded'>
            <cfinclude template="../common/log.cfm">
            <cflocation url="facopts.cfm" addtoken="No">
        </cfif>
        <cfif getAffiliation.modstat eq "ST">
            <cfinclude template="./common/qry_login_reset_UP.cfm">
            <cfset session.module = 'STUD'>
            <cfset session.cur_module = 'student'>
            <cfset client.accessstring = 'H O M E'>
            <cfset client.loginpage = 'studsect.cfm'>
            <cfset client.sepcolor = '81b7ff'>
            <cfset form.pin = '#getAttributes.pin#'>
            <cfset form.pid = '#getAttributes.soc_sec#'>
            <cfset act='LI'>
            <cfset DESC='Student Access LI Succeeded'>
            <cfinclude template="../common/log.cfm">
            <cflocation url="studhome.cfm" addtoken="No">
        </cfif>
        <cfif getAffiliation.modstat eq "SF">
            <cfinclude template="../common/qry_login_reset_UP.cfm">
            <cfset session.module = 'ADMIN'>
            <cfset session.cur_module = 'administrator'>
            <cfset client.accessstring = 'A D M I N I S T R A T I O N'>
            <cfset client.addr_search = '4'>
            <cfset client.nmtasklist = 'LDP,ANS,AWD,BDT,CHG,CRD,DSL,EWL,HOS,OGR,MPL,OBC,COV,OCR,OLV,OPR,ORH,OTC,OWL,PFC,POV,ADN,ADS,SSN,TMG,VRC,PAS,VME,VMP,WHD'>
            <cfset session.PREF_LANG = 'en_US'>
            <cfset client.loginpage = 'admnsect.cfm'>
            <cfinclude template="../common/randomizer.cfm">
            <cfset sc = #randnum#>
            <cfset Session.sec_id = #sc#>
            <!--- <cfset Session.sec_id = #getAttributes.soc_sec#> --->
            <!---
            <cflocation url="namesearch1.cfm?List=&T=&X" addtoken="No">
            --->
            <cflocation url = "../#client.s_page##trim(client.s_list)#" addtoken = "No">
        </cfif>
    </cfif>
    <cfif getAttributes.disabled eq 1>
        <div id="notice">
            <p>Your account has been locked for your own security, please <a href="https://support.bshp.edu">submit a ticket to have it unlocked.</a></p>
        </div>
    </cfif>
    <!--- has profiles so give them the option --->
    <cfif getProfiles.multiprof eq 1>
        <div id="choices">
            <div id="multiprofile">
                <p>You have multiple profiles,<br>Select the profile you wish to login as.</p>
            </div>
            <div id="choicePostForm">
                <form action="" method="post" id="profileForm" name="profileForm">
                    <input type="submit" name="submit" value="Faculty">
                    <input type="submit" name="submit" value="Staff">
                </form>
            </div>
        </div>
    </cfif>
    <cfelse>
        <div id="notice">
            <p>Unable to determine your status, please <a href="https://support.bshp.edu">submit a ticket</a></p>
        </div>
</cfif>
</body>
</html>