<%@Page Language="C#" CodeBehind="sbs_mgmt_man_pages_content_review.aspx.cs" Inherits="Spedmon.ManPagesContentReview" %>

<Spedmon:WebCustomReportStyleContentAll id="styleAll" runat="server">

 th.date,td.date {text-align:center;background-color:inherit;color:inherit;}
 th.text,td.text {text-align:left;background-color:inherit;color:inherit;}
 th.link,td.link {text-align:center;background-color:inherit;color:inherit;}
 
 header { width:100%;margin:1em;background-color:inherit;color:inherit;}
 header h1 {text-align:center;}
 main { width:95%;margin:0 auto;}
 section { border:1px solid #ccc;width:95%;min-height:90vh;padding:1em;margin:0 auto;background-color:#ccc;}
 table { border:1px solid #000;width:95%;margin:0 auto;background-color:#fff;}
 table thead tr {background-color:#000;color:#fff;}
 div.doc-outer {border:1px solid #000;width:95%;margin:0 auto;background-color:#fff;}
 div.doc-inner {margin:1em;}
 footer { width:100%;margin:1em;}
     
</Spedmon:WebCustomReportStyleContentAll>


<Spedmon:WebCustomReportStyleContentScreen id="styleScreen" runat="server">    
 
 body { width:95vw;}
  
</Spedmon:WebCustomReportStyleContentScreen>

<Spedmon:WebCustomReportStyleContentPrint id="stylePrint" runat="server">
  
@page { 
  size: 8.5in 11in landscape;
}
      
</Spedmon:WebCustomReportStyleContentPrint>

<header>
<h1><%=title%></h1>
</header>

<main role="main">

<%=tocMkupString %>
<br />
<%=contMkupString%>
</main>

<footer>
</footer>

