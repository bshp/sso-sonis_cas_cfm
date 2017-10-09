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

<cfset sonisds = "datasourceName">

<cfquery name="getAffiliation" datasource="#sonisds#">
    SELECT TOP 1 RTRIM(modstat) AS modstat FROM vw_ssoLogin WHERE nmldap = '#session.uid#' ORDER BY modstat DESC
</cfquery>

<cfquery name="getProfiles" datasource="#sonisds#">
    SELECT RTRIM(multiprof) AS multiprof, RTRIM(modstat) AS modstat FROM vw_ssoLogin WHERE nmldap = '#session.uid#'
</cfquery>

<cfset session.bshpModstat = getAffiliation.modstat>

<cfif isDefined("form.submit")>
    <!--- clear current session vars --->
    <cfset session.bshpStatus = "">
    <cfset session.bshpAffiliation = "">
    <cfset session.bshpPrefix = "">
    <!--- set new vars based on preferred submission --->
    <cfif (form.submit) eq "Faculty">
        <cfset session.bshpStatus = "FA">
        <cfset session.bshpAffiliation = "faculty">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfif (form.submit) eq "Staff">
        <cfset session.bshpStatus = "ADMN">
        <cfset session.bshpAffiliation = "staff">
        <cfset session.bshpPrefix = "sec">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.bshpPrefix#id) AS soc_sec, RTRIM(#session.bshpPrefix#disabled) AS disabled, RTRIM(#session.bshpPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.bshpPrefix#ldap = '#session.uid#'
    </cfquery>
    <cfset session.bshpPID = getAttributes.soc_sec >
    <cfset session.bshpPIN = getAttributes.pin >
    <cfset session.bshpModStat = session.bshpStatus >
    <div id="postForm">
        <form action="../cas_login_chk.cfm" method="post" id="postForm" name="postSSOForm">
            <input type="hidden" name="modstat" value="<cfoutput>#session.bshpModstat#</cfoutput>"/>
            <input type="hidden" name="PID" value="<cfoutput>#session.bshpPID#</cfoutput>"/>
            <input type="hidden" name="PIN" value="<cfoutput>#session.bshpPIN#</cfoutput>"/>
            <input type="submit"/>
        </form>
    </div>
    <script type="text/javascript">
        document.postSSOForm.submit();
    </script>
    <!--- Not submitted yet --->
<cfelse>
    <cfif session.bshpModstat eq "FA">
        <cfset session.bshpStatus = "FA">
        <cfset session.bshpAffiliation = "faculty">
        <cfset session.bshpPrefix = "nm">
    <cfelseif session.bshpModstat eq "ST">
        <cfset session.bshpStatus = "ST">
        <cfset session.bshpAffiliation = "student">
        <cfset session.bshpPrefix = "nm">
    <cfelseif session.bshpModstat eq "SF">
        <cfset session.bshpStatus = "ADMN">
        <cfset session.bshpAffiliation = "staff">
        <cfset session.bshpPrefix = "sec">
    <cfelse>
        <cfset session.bshpStatus = "TBD">
        <cfset session.bshpAffiliation = "none">
        <cfset session.bshpPrefix = "nm">
    </cfif>
    <cfquery name="getAttributes" datasource="#sonisds#">
        SELECT RTRIM(#session.bshpPrefix#id) AS soc_sec, RTRIM(#session.bshpPrefix#disabled) AS disabled, RTRIM(#session.bshpPrefix#pin) AS pin
        FROM vw_ssoLogin WHERE #session.bshpPrefix#ldap = '#session.uid#'
    </cfquery>
    <cfif session.bshpAffiliation eq "none">
        <div id="notice">
            <p>Your account does not yet include Sonis access. Students, contact the registrar's office. Faculty or Staff, contact the IS Department</p>
        </div>
    <!--- does not have multiprofiles, just log them in --->
    <cfelseif getAttributes.disabled eq "0" and getProfiles.multiprof eq "0">
        <cfset session.bshpPID = getAttributes.soc_sec >
        <cfset session.bshpPIN = getAttributes.pin >
        <cfset session.bshpModStat = session.bshpStatus >
        <div id="postForm">
            <form action="../cas_login_chk.cfm" method="post" id="postForm" name="postSSOForm">
                <input type="hidden" name="modstat" value="<cfoutput>#session.bshpModstat#</cfoutput>"/>
                <input type="hidden" name="PID" value="<cfoutput>#session.bshpPID#</cfoutput>"/>
                <input type="hidden" name="PIN" value="<cfoutput>#session.bshpPIN#</cfoutput>"/>
                <input type="submit"/>
            </form>
        </div>
        <script type="text/javascript">
            document.postSSOForm.submit();
        </script>
    <cfelseif getAttributes.disabled eq "1">
        <div id="notice">
            <p>Your account has been locked for your own security, please <a href="https://support.bshp.edu">submit a ticket to have it unlocked.</a></p>
        </div>
    <!--- has profiles so give them the option --->
    <cfelseif getProfiles.multiprof eq "1">
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
    <cfelse>
        <div id="notice">
            <p>Unable to determine your status, please <a href="https://support.bshp.edu">submit a ticket</a></p>
        </div>
    </cfif>
</cfif>
</body>
</html>
