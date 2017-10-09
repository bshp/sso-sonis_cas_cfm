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
