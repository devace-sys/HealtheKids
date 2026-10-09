<%@Page Language="C#" CodeBehind="help.aspx.cs" Inherits="Spedmon.help" %>

<%/************************/%>
<%/* Help                 */%>
<%/* Help Page            */%>
<%/************************/%>

<%=needMoreHelpContactContent%>

<div class="container-fluid">
  <div class="row">
      <div class="col-12 col-lg-2">
        <aside>
          <%=sectionsTOC%>
        </aside>
      </div>

      <div class="col-12 col-lg-10">
        <div>
          <%=sectionsContent%>
        </div>
      </div>
  </div>
</div>

<script type="text/javascript" charset="utf-8">


; (function ($) {

});

})(jQuery);
</script>
