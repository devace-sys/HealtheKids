<%@ Page Language="C#" CodeBehind="user_all_my_organization.aspx.cs" Inherits="Spedmon.UserAllMyOrganization"%>

<div id="my-organization-rows" class="container-fluid">    
       
<%//-----------------------------------------------------------------------------%>
<%// Select Client                                                               %>
<%// (Practi-Cal staff only)                                                     %>
<%//-----------------------------------------------------------------------------%>

<div class="row">
<div class="col-12">

  <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        entryInitiallyHidden = "false"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
  </Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Various tabs                                                                %>
<%//-----------------------------------------------------------------------------%>

<div class="row">
<div class="col-12">
<div id="my-organization-tabs">

<%/****************************
   * Tabs nav
   ****************************/%>
<ul>
  <li><a href = "#tab-school-years">School Years</a></li>
  <li><a href = "#tab-school-breaks">School Breaks</a></li>
</ul> 

<%/****************************
   * School Years 
   ****************************/%>

 <div id="tab-school-years">

   <div id="restviewschoolyears"></div>
        
 </div>

 <%/****************************
    * School Breaks 
    ****************************/%>

  <div id="tab-school-breaks">
              <datalist id="common-break-names">
              <option value="Labor Day"></option>
              <option value="Thanksgiving"></option>
              <option value="Christmas"></option>
              <option value="President's Day"></option>
              <option value="Lincoln's Birthday"></option>
              <option value="Veteran's Day"></option>
              <option value="Spring Break"></option>
              <option value="Memorial Day"></option>
              <option value="4th of July"></option>
              <option value="Snow Day"></option>
              <option value="Teacher Day"></option>
              <option value="School Site Year"></option>
              </datalist>
    
	<div id="restviewschoolbreaks"></div>
    
        
  </div>

</div> <!-- tabs -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<script type="text/javascript">
  $(document).ready(function () {

     let $myOrganizationRows    = $('#my-organization-rows');
     let restViewSchoolYearsID  = 'restviewschoolyears';
     let restViewSchoolBreaksID = 'restviewschoolbreaks';


     $($myOrganizationRows).on('spedmoninputdata', function (e) {
         let $restViewSchoolYears  = $('#' + restViewSchoolYearsID);
         let $restViewSchoolBreaks = $('#' + restViewSchoolBreaksID);
         MBA.ClientSchoolSessionAcademicYearsCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($restViewSchoolYears);
         MBA.ClientSchoolSessionBreaksCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($restViewSchoolBreaks);
     });

     /* Setup tabs */

     /*$("#my-organization-tabs").tabs();
     $('#my-organization-tabs').addClass('data-entry-row-tabs');
     */

     $("#my-organization-tabs").MBA_Tabs({});

     /* Setup school years */

     let optsForSchoolSessionAcademicYears = {};

     optsForSchoolSessionAcademicYears.PARM_NAME_CLIENT_ID              = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; 
     optsForSchoolSessionAcademicYears.PARM_NAME_ACTIVE                 = '<%=Spedmon.Constants.PARM_ACTIVE%>';
     optsForSchoolSessionAcademicYears.containerCtrlID                  = 'tab-school-years';
     optsForSchoolSessionAcademicYears.sessionTimeOutUrl                = '<%=MBA.Credential.generateSessionExpiredLink()%>';
     optsForSchoolSessionAcademicYears.baseUrlView                      = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_VIEW()%>';
     optsForSchoolSessionAcademicYears.defaultPageRowOrder              = '<%=Spedmon.ClientSchoolSessionAcademicYear.DEFAULT_PAGING_ORDER%>';
     optsForSchoolSessionAcademicYears.baseUrlAddNew                    = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_SAVE_INLINE()%>';
     optsForSchoolSessionAcademicYears.baseUrlEdit                      = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_SAVE_INLINE()%>'
     optsForSchoolSessionAcademicYears.baseUrlDelete                    = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_DELETE_INLINE()%>';
     optsForSchoolSessionAcademicYears.baseURLCompanyFiscalYearsViewSel = '<%=Spedmon.CompanyFiscalYears.URL_REST_VIEW_SEL2()%>';

     MBA.ClientSchoolSessionAcademicYearsCommon.fnSetup (restViewSchoolYearsID, optsForSchoolSessionAcademicYears);

     /* Setup breaks */

     let optsForSchoolSessionBreaks = {};

     optsForSchoolSessionBreaks.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
     optsForSchoolSessionBreaks.PARM_NAME_ACTIVE    = '<%=Spedmon.Constants.PARM_ACTIVE%>';
     optsForSchoolSessionBreaks.containerCtrlID     = 'tab-school-breaks';
     optsForSchoolSessionBreaks.sessionTimeOutUrl   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
     optsForSchoolSessionBreaks.baseUrlView         = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_VIEW()%>';
     optsForSchoolSessionBreaks.defaultPageRowOrder = '<%=Spedmon.ClientSchoolSessionBreak.DEFAULT_PAGING_ORDER%>';
     optsForSchoolSessionBreaks.baseUrlAddNew       = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_SAVE_INLINE()%>';
     optsForSchoolSessionBreaks.baseUrlEdit         = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_SAVE_INLINE()%>'
     optsForSchoolSessionBreaks.baseUrlDelete       = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_DELETE_INLINE()%>';
     optsForSchoolSessionBreaks.baseURLSchoolSessionAcademicYearSel = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_VIEW_SEL_INLINE()%>';      
     optsForSchoolSessionBreaks.baseURLClientSiteSel                = '<%=Spedmon.Sites.URL_REST_VIEW_SEL_INLINE()%>';

     MBA.ClientSchoolSessionBreaksCommon.fnSetup (restViewSchoolBreaksID, optsForSchoolSessionBreaks);
      
    });
</script>
