<%@ Page Language="C#" CodeBehind="rpt_custom_service_journal_view_html.aspx.cs" Inherits="Spedmon.rpt_custom_service_journal_view_html" %>

<Spedmon:WebCustomReportStyleContentAll id="styleAll" runat="server">
  
  body                {width:95%;margin:0 auto;font-family: "Times New Roman", Times, serif;}
  table               {width:95%;margin:0 auto;border:1px solid black;border-collapse:collapse;}
  thead               {display: table-header-group;}
  tfoot               {display: table-header-group;}
  th,td               {padding-left:1em;font-size:smaller;}
  th                  {background-color:black;color:white;}
  table thead tr th   {border:1px solid Teal;}
  table thead tr th   {text-align:left;line-height:2em;}

  table tbody tr th   {border:1px solid Teal;}
  table tbody tr td   {border:1px solid Teal;}
  table tbody tr th   {text-align:left;}
  table tbody tr td   {text-align:left;}
  
  table tbody tr.odd  {background-color:White;}
  table tbody tr.even {background-color:Linen;}
  table caption       {font-weight:bold;padding:1em;font-size:larger;}
  table tfoot         {height:0;display:none;}
  
  div#report {
    width:100%;
  }
  
  div#report-data h1 {
    text-align:center;
    margin:0;
    Color:Black;
  }  
  
  div#report-data h2 {
    text-align:center;
    margin:0;
    text-size:smaller;
    color:Red;
  }
  
  div#report-data h3 {
    text-align:center;
    margin:0;
    text-size:smaller;
    color:Teal;
  }
  

  div#patient-data table {   
  }
  
  div#patient-data table tbody tr th {
    width:20%;
  }
  div#patient-data table tbody tr td {
    width:80%;
  }
  
  div#journal-entries table {
  }
  
  div#rendering-pracs table {
  }

  div#rendering-pracs th, div#rendering-pracs td {
    border: 1px solid #bbb;
  }
  
  div#supervising-pracs-manual td {
    line-height:3em;
  }
  
  div#supervising-pracs-notice-container {
    width:100%;
    margin-top:1em;
  }    
  
  div#supervising-pracs-notice {
    width:90%;
    display:block;
    margin:0 auto;
    border:2px solid Black;
    padding:1em;
    background-color: Yellow;
    font-size:larger;
    font-weight:bold;
    text-align:center;
  }
  
</Spedmon:WebCustomReportStyleContentAll>


<Spedmon:WebCustomReportStyleContentScreen id="styleScreen" runat="server">    

</Spedmon:WebCustomReportStyleContentScreen>

<Spedmon:WebCustomReportStyleContentPrint id="stylePrint" runat="server">
  
@page { 
  size: 8.5in 11in landscape;
}

table {
  width:95%;
}
      
</Spedmon:WebCustomReportStyleContentPrint>

<div id="report">

<div id="report-data">
  <h1><%=ClientName%></h1>
  <h1><%=ReportName%></h1>
  <h2><%=ReportConfidential%></h2>
  <h3><%=ReportGeneratedOn%></h3>
</div>

<div id="patient-data">
  <table>
    <caption>Patient and Services Data</caption>
    <tbody>
      <tr><th>Patient:</th><td><%=PatientName%></td></tr>
      <tr><th>Date of Service:</th><td><%=DateOfService%> (<%=PatientAttendance%>)</td></tr>
      <tr><th>Service Description:</th><td><%=ServiceDescription%></td></tr>
      <tr><th>Expected Outcomes:</th><td><%=ExpectedOutcomes%></td></tr>
    </tbody>
  </table>
</div>

<div id="journal-entries">
  <%=ReportPartEntriesEvery15%>
</div>

<div id="rendering-pracs">
  <%=ReportPartEntriesRenderingPracSigs%>
</div>

<%if (NumSupervisingPracs > 0) {%>

  <div id="supervising-pracs-electronic">
    <%=ReportPartEntriesSupervisingPracSigs%> 
  </div> 

  <%if (NumSupervisingPracsNotes > 0) {%>
    <div id="supervising-pracs-notes-electronic">
      <%=ReportPartEntriesSupervisingPracsNotes%> 
    </div> 
  <%}%>

<%} else { 

if (ElectronicApproval == false) {
  if (NumRenderingPracs > 0) {%>

<div id="supervising-pracs-manual">  

  <div id="supervising-pracs-notice-container">
  <div id="supervising-pracs-notice">
  This journal was not approved electronically via SpEdCare.<br />
  Please provide it to the supervisor to sign manually and keep in the district records.
  </div>
  </div>
  
  <table>
    <caption>Supervising Practitioners</caption>
    <thead>
      <tr>
        <th>Supervising Practitioner Name <br/><sub>(Please Print)</sub></th>
        <th>Title</th>
        <th>Approved<br/><sub>(Yes or No)</sub></th>
        <th>Supervising Practitioner Signature</th>
        <th>Date</th>
      </tr>
    </thead>
    <tbody>
    <%for (long i = 0;i<NumRenderingPracs;i++){%>                  
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr> 
    <%}%>
    </tbody>
  </table>
</div>

<%}}}%>

</div>