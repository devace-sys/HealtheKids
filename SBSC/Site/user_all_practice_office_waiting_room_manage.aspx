<%@ Page Language="C#" CodeBehind="user_all_practice_office_waiting_room_manage.aspx.cs" Inherits="Spedmon.UserAllPracticeOfficeWaitingRoomManage"%>

<%if (this.pageInitIsOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
<Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server" />
<Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                             Data Entry                                                          %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<div id="datamanagerowsrestviewvisits" class="container-fluid">

  <div class="row mt-2">

    <div class="col-6">       
    
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
     <%// Filter By Logged In Prac (visible to pracs only) %>
     <%// Note: Visible to pracs only %>
     <%//-----------------------------------------------------------------------------%>

        <%if (this.isPrac == true) {%>
          <div style="margin-left:1em;display:inline-block">
          <Spedmon:SelectYesOrNo
              ID               = "filtertomyassigned"
              title            = "My Patients Only?"
              firedataselected = "true"
              renderLabel      = "true"
              value            = "No"                            
              onSelectValue    = "function(oldval,newval){ doFilterWaitingRoomByPrac(newval); return true;}"
              runat            = "server" />
          </div>
        <%}%>

    </div> <!-- col -->


     <%//-----------------------------------------------------------------------------%>
     <%// Auto refresh option %>
     <%//-----------------------------------------------------------------------------%>

    <div class="col-4">

    <div class="d-flex justify-content-center">
         
        <Spedmon:SelectYesOrNo 
            ID               = "autorefresh" 
            title            = "Auto Refresh" 
            firedataselected = "false" 
            renderLabel      = "true"
            value            = "Yes"
            runat            = "server" />
        

        <Spedmon:DataEntryButton 
            ID                 = "refreshnow" 
            title              = "Refresh Now" 
            fireSpedmonInput   = "false" 
            assignBsCssClasses = "false" 
            iconOnly           = "true" 
            faIcon             = "fas fa-sync"
            onclick            = "refreshWaitingRoomList()"
            runat              = "server" />      
          </div> 
       </div> <!-- col -->

      <div class="col-2">

       <div class="d-flex justify-content-end">
      
       <Spedmon:LinkInternal 
           ID         = "gotomanagecompletedvisits" 
           title      = "Click Here to Review Completed Visits" 
           label      = "Review Completed Visits"
           faClass    = "fa fa-link"               
           openNew    = "false"  
           subWindow  = "false"
           urlPrivate = "true"
           runat      = "server" />
        </div>
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

    function refreshWaitingRoomList() {
      MBA.PracticeOfficeVisitsCommon.fnRefreshViewIfUserIsNotActivelyManagingRows(WAITING_ROOM_PRACTICE_OFFICE_VISITS_REST_VIEW_ID);
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function autoRefreshWaitingRoomList() {
        let _arv = $('#autorefresh').val();
        if (_arv == 'Yes') {
            MBA.PracticeOfficeVisitsCommon.fnRefreshViewIfUserIsNotActivelyManagingRows(WAITING_ROOM_PRACTICE_OFFICE_VISITS_REST_VIEW_ID);
        }
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function doFilterWaitingRoomByPrac (newVal) {
        if (newVal == 'Yes') {
            $('#pracid').val('<%=pracIDStr%>');
        } else {
            $('#pracid').val('');
        }
    };

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
            , whatPage:2
            , dataSourceValueForVisits: '2' /* Default all.  1= all , 2 = waiting room only */
            , containerCtrlID: 'datamanagerowsrestviewvisits'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PracticeOfficeVisits.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'id asc'
            , baseUrlAddNew:'<%=Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PracticeOfficeVisits.URL_SVC_DELETE_INLINE_BASE()%>'
            , baseUrlPatIDSel: '<%=Spedmon.Patients.URL_SVC_VIEW_SEL2_BASE()%>'
            , baseUrlPracticeOfficeVisitReasonIDSel: '<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracIDSel: '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>'
            , baseUrlPatientVisitManage : '<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>'
            , showAddNew:true
            , showStartVisit:true            
            , showEdit: true
            , showDelete:true
            , showPatientRelatedColumns: true
            , showWaitingRelatedFields: true
            , showVisitRelatedFields: false
            , canEditPat: true
            , canEditPrac: true
            , canEditVisitReason: true
            , canEditVisitResolution: false
            , allowFilterByPracID: true
            , completedValue: 'N'
            , fnCreateNewRowAfter:function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
                if (!rowData) return $newRow;  /* Quick way to skip header rows */
                return $newRow;
            }
            , fnOKToAddNew : function (uiActionObj) {
                let VALUE_SITE_ID = $('#<%=Constants.PARM_SITE_ID%>').val();
                if (VALUE_SITE_ID == '') {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Select A Site', 'You must have a site selected before you can add a patient to the queue.<br><br>You can bookmark the site you selected by clicking the <i class="ui-spedmon-data-entry-fa-icon fas fa-bookmark"></i> icon after you select a site and SpEdCare will remember this selection for future use.', {});
                    return false;
                }
                return true;
            }

        };

        MBA.PracticeOfficeVisitsCommon.fnSetup(WAITING_ROOM_PRACTICE_OFFICE_VISITS_REST_VIEW_ID, practiceOfficeVisitsOptsObj);

        setInterval(autoRefreshWaitingRoomList, 30000); /* TODO: This is temporary until we setup something better */

    });
</script>
<%}%>