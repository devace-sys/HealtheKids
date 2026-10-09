<%@Page Language="C#" CodeBehind="svc_notes_to_save_view.aspx.cs" Inherits="Spedmon.svc_notes_to_save_view"%>

<div data-role="header" data-position="fixed" >
  <a href="<%=homeLink%>" class="ui-btn-right" data-icon="home" data-ajax="false">Back to Home</a>
  <h1>Service Notes</h1>
</div>

<div role="content" class="ui-content">
  <%=req.generateSelectNoteToSaveListView()%>
</div>

<div data-role="footer" data-position="fixed" data-theme="b" style="text-align:center">
  <strong>Please note that you will not be able to enter additional service records until you have completed the notes</strong>
</div>

