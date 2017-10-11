<div id="postForm">
<form action="../cas_login_chk.cfm" method="post" id="postForm" name="postSSOForm">
    <cfoutput>
        <input type="hidden" name="modstat" value="#session.ssoModstat#"/>
        <input type="hidden" name="PID" value="#session.ssoPID#"/>
        <input type="hidden" name="PIN" value="#session.ssoPIN#"/>
    </cfoutput>
    <input type="submit"/>
</form>
</div>
<script type="text/javascript">
    document.postSSOForm.submit();
</script>
