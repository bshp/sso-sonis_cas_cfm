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

<!--- Set datasourceName to Sonis DS name in CF --->
<cfset sonisds = "datasourceName">
<cfset session.uid = session.cfcas.getUsername()>
<cfset session.bshpModstat = getAffiliation.modstat>
<!---
<cfquery name="getAffiliation" datasource="#sonisds#">
SELECT TOP 1 RTRIM(modstat) AS modstat FROM vw_ssoLogin WHERE nmldap = '#session.uid#' AND modstat IN('FA','SF','ST')
</cfquery>
--->
<cfquery name="getAffiliation" datasource="#sonisds#">
    SELECT TOP 1 RTRIM(modstat) AS modstat FROM vw_ssoLogin WHERE nmldap = '#session.uid#' ORDER BY modstat DESC
</cfquery>

<cfquery name="getProfiles" datasource="#sonisds#">
    SELECT RTRIM(multiprof) AS multiprof, RTRIM(modstat) AS modstat FROM vw_ssoLogin WHERE nmldap = '#session.uid#'
</cfquery>

<cfif isDefined("form.submit")>
    <!--- clear current session vars --->
    <cfset session.bshpStatus = "">
    <cfset session.bshpPrefix = "">
    <!--- set new vars based on preferred submission --->
    <cfif (form.submit) eq "Faculty">
        <cfset session.bshpStatus = "FA">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfif (form.submit) eq "Staff">
        <cfset session.bshpStatus = "ADMN">
        <cfset session.bshpPrefix = "sec">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.bshpPrefix#id) AS soc_sec, RTRIM(#session.bshpPrefix#disabled) AS disabled, RTRIM(#session.bshpPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.bshpPrefix#ldap = '#session.uid#'
    </cfquery>
    <cfset session.bshpPID = getAttributes.soc_sec >
    <cfset session.bshpPIN = getAttributes.pin >
    <cfset session.bshpModStat = session.bshpStatus >
    <cfinclude template="forms/postForm.cfm">
    <!--- Not submitted yet --->
<cfelse>
    <!--- Staff Attributes --->
    <cfif session.bshpModstat eq "SF">
        <cfset session.bshpPrefix = "sec">
        <cfset session.bshpStatus = "ADMN">
    <!--- Student Attributes --->
    <cfelseif session.bshpModstat eq "ST">
        <cfset session.bshpPrefix = "nm">
        <cfset session.bshpStatus = "ST">
    <!--- Faculty Attributes --->
    <cfelseif session.bshpModstat eq "FA">
        <cfset session.bshpPrefix = "nm">
        <cfset session.bshpStatus = "FA">
    <!--- All Other Modstats not valid --->
    <cfelse>
        <cfset session.bshpStatus = "TBD">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.bshpPrefix#id) AS soc_sec, RTRIM(#session.bshpPrefix#disabled) AS disabled, RTRIM(#session.bshpPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.bshpPrefix#ldap = '#session.uid#'
    </cfquery>
    <cfif session.bshpStatus eq "TBD">
        <div id="notice">
            <p>Your account does not yet include Sonis access. Students, contact the registrar's office. Faculty or Staff, contact the IS Department</p>
        </div>
    <cfelseif getAttributes.disabled eq "1">
        <div id="notice">
            <p>Your account has been locked for your own security, please <a href="https://support.bshp.edu">submit a ticket to have it unlocked.</a></p>
        </div>
    <!--- does not have multiprofiles, just log them in --->
    <cfelseif getAttributes.disabled eq "0" and getProfiles.multiprof eq "0">
        <cfset session.bshpPID = getAttributes.soc_sec >
        <cfset session.bshpPIN = getAttributes.pin >
        <cfset session.bshpModStat = session.bshpStatus >
        <cfinclude template="forms/postForm.cfm">
    <!--- has profiles so give them the option --->
    <cfelseif getProfiles.multiprof eq "1">
        <cfinclude template="forms/choiceForm.cfm">
    <!--- needed for any other reason, a catch all --->
    <cfelse>
        <div id="notice">
            <p>Unable to determine your status, please <a href="https://support.bshp.edu">submit a ticket</a></p>
        </div>
    </cfif>
</cfif>
</body>
</html>
