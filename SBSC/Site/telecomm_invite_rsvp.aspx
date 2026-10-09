<%@Page Language     = "C#" 
  AutoEventWireup    = "true" 
  formRSVPControlID  = "formrsvp"
  CodeBehind         = "telecomm_invite_rsvp.aspx.cs"
  Inherits           = "Spedmon.telecommInviteRsvp"
%>

<div id="page" class="page container"> <%/* Page grid */%>

<%/*###################################### Header ######################################*/%>

<header id="pageheader" class="pageheader row">
<section class="col-12">
<div class="container"> <%/* Header content grid */%>

<div class="row"> <%/* Header content grid - Row 1 */%>

<!-- ################### Logo and title ################### -->
  <div class="col-6">
    <img id="app-logo" class="pagelogo" alt="logo" src="web-ui-3\mba\css\app-icons\HYQueue-logo.svg">
  </div> <!-- col -->
  <div class="col-6">
  </div> <!-- col -->

  <div class="col-12">    
    <div id="systemstatus">
      <%=statusMessage%>
    </div>    
  </div> <!--col -->

</div> <!-- row -->
</div> <!-- Header content container -->
</section> <!-- col -->
</header> <!-- row -->

<%/*###################################### Main ###################################### */%>

<main id="pagemain" class="pagemain row" role="main"> <%/* Page grid - Row 2 */%>

<section class="col-12"> <%/* Page grid - Row 2 - Column 1 */%>
<div class="container"> <%/* Main content grid */%> 


<%/*###################################### 
    # Main Content Outside Room 
    ######################################*/%>

<div class="row"> <%/* Main content grid (outside) - Row 1 */%>

<!-- ################### Join form ################### -->

<section class="col-12">
<Spedmon:TeleCommFormRSVP ID="formrsvp" runat="server"/>  
</section> <%/* Main content grid (outside) - Row 1 - Col 1*/%>

</div> <%/* Main content grid (outside) - Row 1 */%>



</div> <%/* Main content grid */%> 
</section> <%/* Page grid - Row 2 - Column 1 */%>
</main> <%/* Page grid - Row 2 */%>


</div> <!--container -->

<div id="browsernotsupported" style="display:none"></div>
<ul id="sessionlog" style="display:none"></ul>
