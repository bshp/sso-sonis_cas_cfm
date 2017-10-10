<div id="postForm">
<form action="../cas_login_chk.cfm" method="post" id="postForm" name="postSSOForm">
        <input type="hidden" name="modstat" value="<cfoutput>#session.ssoModstat#</cfoutput>"/>
        <input type="hidden" name="PID" value="<cfoutput>#session.ssoPID#</cfoutput>"/>
        <input type="hidden" name="PIN" value="<cfoutput>#session.ssoPIN#</cfoutput>"/>
    <input type="submit"/>
</form>
</div>
<script type="text/javascript">
    document.postSSOForm.submit();
</script>
