<%@Page Language="C#" CodeBehind="sbs_system_admin_telecomm_server.aspx.cs" Inherits="Spedmon.SBSSystemAdminTelecommServer"%>
<h1>Raw Status Data</h1>

<h2>Server Configuration</h2>

<p>If you do not see this populated then something is wrong</p>

<pre>
<code id="configdata">

</code>
</pre>

<h2>Sessions (Meetings)</h2>

<pre>
<code id="sessiondata">
</code>
</pre>

<script>
;(function($){
    var configData = <%=configDataJSON%>;
    var sessionData = <%=sessionsDataJSON%>;
    /* Pretify */
    $('#configdata').html(JSON.stringify(configData, null, 4));
    $('#sessiondata').html(JSON.stringify(sessionData, null, 4));
})(jQuery);

</script>


