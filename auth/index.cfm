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

<cfset session.ssoModstat = getAffiliation.modstat>

<cfif isDefined("form.submit")>
    <!--- clear current session vars --->
    <cfset session.ssoStatus = "">
    <cfset session.ssoPrefix = "">
    <!--- set new vars based on preferred submission --->
    <cfif (form.submit) eq "Faculty">
        <cfset session.ssoStatus = "FA">
        <cfset session.ssoPrefix = "nm">
    </cfif>
    <cfif (form.submit) eq "Staff">
        <cfset session.ssoStatus = "ADMN">
        <cfset session.ssoPrefix = "sec">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.ssoPrefix#id) AS soc_sec, RTRIM(#session.ssoPrefix#disabled) AS disabled, RTRIM(#session.ssoPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.ssoPrefix#ldap = '#session.uid#'
    </cfquery>
    <cfset session.ssoPID = getAttributes.soc_sec >
    <cfset session.ssoPIN = getAttributes.pin >
    <cfset session.ssoModStat = session.ssoStatus >
    <cfinclude template="forms/postForm.cfm">
    <!--- Not submitted yet --->
<cfelse>
    <!--- Staff Attributes --->
    <cfif session.ssoModstat eq "SF">
        <cfset session.ssoPrefix = "sec">
        <cfset session.ssoStatus = "ADMN">
    <!--- Student Attributes --->
    <cfelseif session.ssoModstat eq "ST">
        <cfset session.ssoPrefix = "nm">
        <cfset session.ssoStatus = "ST">
    <!--- Faculty Attributes --->
    <cfelseif session.ssoModstat eq "FA">
        <cfset session.ssoPrefix = "nm">
        <cfset session.ssoStatus = "FA">
    <!--- All Other Modstats not valid --->
    <cfelse>
        <cfset session.ssoStatus = "TBD">
        <cfset session.ssoPrefix = "nm">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.ssoPrefix#id) AS soc_sec, RTRIM(#session.ssoPrefix#disabled) AS disabled, RTRIM(#session.ssoPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.ssoPrefix#ldap = '#session.uid#'
    </cfquery>
    <!--- if not faculty, staff, or student, show them unauthorized view --->
    <cfif session.ssoStatus eq "TBD">
        <div id="notice">
            <p>Your account does not yet include Sonis access. Students, contact the registrar's office. Faculty or Staff, contact the IS Department</p>
        </div>
    <cfelseif getAttributes.disabled eq "1">
        <div id="notice">
            <p>Your account has been locked from to many failed login attempts, please <a href="https://support.bshp.edu">submit a ticket to have it unlocked.</a></p>
        </div>
    <!--- does not have multi-profiles, just log them in --->
    <cfelseif getAttributes.disabled eq "0" and getProfiles.multiprof eq "0">
        <cfset session.ssoPID = getAttributes.soc_sec >
        <cfset session.ssoPIN = getAttributes.pin >
        <cfset session.ssoModStat = session.ssoStatus >
        <cfinclude template="forms/postForm.cfm">
    <!--- has multi-profiles so give them the option --->
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
