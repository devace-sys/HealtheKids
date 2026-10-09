<%@Page Language="C#" CodeBehind="sbs_all_smartsheet.aspx.cs" Inherits="Spedmon.sbs_all_smartsheet" %>

<%=smartSheetTableStr%>

<script>
  $(function() {
    $('table.smartsheet').dataTable({"bJQueryUI":true,"bInfo":false,"bPaginate":false,"sScrollY": 200,"sScrollX": "100%","sScrollXInner": "110%"});
  });
</script>
