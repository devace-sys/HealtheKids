<%@ Page Language="C#" CodeBehind="user_all_practice_office_completed_visits_manage.aspx.cs" Inherits="Spedmon.UserAllPracticeOfficeCompletedVisitsManage"%>

<%if (this.pageInitIsOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                             Data Entry                                                          %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<div id="datamanagerowsrestviewvisits" class="container-fluid">

  <div class="row mt-2">

    <div class="col-12">       
    
    <%//-----------------------------------------------------------------------------%>
    <%// Client  %>
    <%// (Visible to PCAL Staff only) %>
    <%//-----------------------------------------------------------------------------%>
  
    <Spedmon:DataEntryRowSelectClient
       ID                                  = "selectClient" 
       rowLabel                            = "Client" 
       dataEntryRowRenderAs                = "FIELD"
       showClearSelection                  = "true"      
       showSaveSelectionAsDefault          = "true"
       runat                               = "server">
    </Spedmon:DataEntryRowSelectClient>

     <%//-----------------------------------------------------------------------------%>
     <%// Site  %>
     <%//-----------------------------------------------------------------------------%>
  
     <Spedmon:DataEntryRowSelectSchoolSite
         ID                                  = "dataEntryRowSelectSchoolSite" 
         rowLabel                            = "Site" 
         dataEntryRowRenderAs                = "FIELD"
         showClearSelection                  = "true"
         showSaveSelectionAsDefault          = "true"
         runat                               = "server">
      </Spedmon:DataEntryRowSelectSchoolSite>
    
     <%//-----------------------------------------------------------------------------%>
     <%// Practitioner %>
     <%//-----------------------------------------------------------------------------%>

     <Spedmon:HiddenInput id="pracid" name="pracid" title="pracid" runat="server" />
             
     <%//-----------------------------------------------------------------------------%>
     <%// Patient  %>
     <%//-----------------------------------------------------------------------------%>
  
     <Spedmon:DataEntryRowSelectPatient
         ID                                  = "dataEntryRowSelectPat" 
         rowLabel                            = "Patient" 
         dataEntryRowRenderAs                = "FIELD"
         showClearSelection                  = "true"         
         runat                               = "server">
      </Spedmon:DataEntryRowSelectPatient>

    </div> <!-- col -->

  </div> <!-- row -->  
  
  <%//-----------------------------------------------------------------------------%>
  <%// Rest View for Visits  %>
  <%//-----------------------------------------------------------------------------%>

  <div class="row mt-3">
    <div class="col-12">       
      <div id="restviewpracticeofficevisits">
      </div> <!-- restviewvisits -->
    </div> <!-- col -->
  </div> <!-- row -->  
     	 
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const WAITING_ROOM_PRACTICE_OFFICE_VISITS_REST_VIEW_ID = 'restviewpracticeofficevisits';

    
    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    $(window).on('load', function () {

        let practiceOfficeVisitsOptsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_COMPLETED:'<%=Spedmon.Constants.PARM_COMPLETED%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PAT_DATA_SOURCE_VALUE_ALL_PATIENTS: '<%=MBA.PatientDataSource.ALL_PATIENTS.GetValueAsString()%>'
            , PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY: '<%=MBA.PractitionerDataSource.WITHIN_PRACTICE_FAMILY_ONLY.GetValueAsString()%>'
            , PARM_DATA_SOURCE: '<%=Spedmon.Constants.PARM_DATA_SOURCE%>'
            , whatPage: 1
            , dataSourceValueForVisits: '2' /* Default all.  1= all , 2 = waiting room only */
            , containerCtrlID: 'datamanagerowsrestviewvisits'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PracticeOfficeVisits.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: 'id asc'
            , baseUrlAddNew: ''
            , baseUrlEdit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_EDIT_COMPLETED_VISIT_BASE()%>'
            , baseUrlDelete:''
            , baseUrlPatIDSel: '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>'
            , baseUrlPracticeOfficeVisitReasonIDSel: '<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracticeOfficeVisitResolutionIDSel: '<%=Spedmon.PracticeOfficeVisitResolutions.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracIDSel: '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>'
            , baseUrlPatientVisitManage: '<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>'
            , baseUrlReport:'<%=Spedmon.PracticeOfficeVisits.URL_WEB_REPORT_BASE()%>'
            , defaultReportNumber: '<%=Spedmon.PracticeOfficeVisitsView.REPT_NUM_VIEW%>'
            , showAddNew:false
            , showStartVisit:false           
            , showEdit: true
            , showDelete:false
            , showPatientRelatedColumns: true
            , showWaitingRelatedFields: true
            , showVisitRelatedFields: false
            , canEditPat: false
            , canEditPrac: false
            , canEditVisitReason: false
            , canEditVisitResolution: true
            , allowFilterByPracID: true
            , completedValue: 'Y'
            , fnCreateNewRowAfter:function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
                if (!rowData) return $newRow;  /* Quick way to skip header rows */
                return $newRow;
            }
            , tkn: '<%=rd.wu.usr.token%>'
            , fnEditInlineProceedAfter: function(uiActionObj, responseData, success) { return; }
            , fnOnEditInlineCancel: function(uiActionObj) { return; }

        };

        MBA.PracticeOfficeVisitsCommon.fnSetup(WAITING_ROOM_PRACTICE_OFFICE_VISITS_REST_VIEW_ID, practiceOfficeVisitsOptsObj);
       

    });
</script>
<%}%>