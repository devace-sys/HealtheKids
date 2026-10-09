<%@ Page Language="C#" CodeBehind="user_all_pat_save_2.aspx.cs" Inherits="Spedmon.UserAllPatientSave2" %>

<%//#####################################################################################################%>
<%//                                           Markup                                                    %>
<%//#####################################################################################################%>

<%//#############################################################################%>
<%//       Hidden Fields (Needed to interface with various components)           %>
<%//#############################################################################%>

<Spedmon:HiddenInput ID="patid" name="patid" title="record id" runat="server"/>
<Spedmon:HiddenInput ID="pracid"   name="pracid"   title="pracid"   runat="server" />
<Spedmon:HiddenInput ID="groupid"  name="groupid"  title="groupid"  runat="server" />
<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
<Spedmon:HiddenInput ID="dos" name="dos" title="dos" runat="server" />
<Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid"  title="Select Plan from IEP" runat="server" />
<Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" runat="server" />
<Spedmon:HiddenInput ID="siteid" name="siteid" title="siteid" runat="server" />
<Spedmon:HiddenInput ID="recid" name="recid" title="recid" runat="server" />
<Spedmon:HiddenInput ID="savetype" name="savetype" title="savetype" runat="server" />

<%//#############################################################################%>
<%//                              Main Container                                 %>
<%//#############################################################################%>

<div class="container-fluid">

<div class="row">

<%//#############################################################################%>
<%//                                 Col Left                                    %>
<%//#############################################################################%>

<div id="r1-cl">

<%//#############################################################################%>
<%//                      Select Client (PCAL ONLY)                              %>
<%//#############################################################################%>

<div>
<Spedmon:DataEntryRowSelectClient ID="selectClient" rowLabel= "Client" dataEntryRowRenderAs="FIELD" runat="server"/>
</div>

<%//#############################################################################%>
<%//                             Profile                                         %>
<%//#############################################################################%>

<section id="profile"></section> <!-- profile -->

</div> <!-- left col -->

<%//#############################################################################%>
<%//                    Col Right (Edits Only)                                   %>
<%//#############################################################################%>

<div id="r1-cr">

<%if(saveTypeVal == Constants.SAVE_TYPE_EDIT) {%>

<%//#############################################################################%>
<%//                 Status Bar and Patient Options                              %>
<%//#############################################################################%>

<div class="d-block mb-3">

<%//=============================================================================%>
<%//                                Status Bar                                   %>
<%//=============================================================================%>

<div class="d-inline-block">
  <div id="patientTopBannerContainer"></div>
</div> <!-- status bar -->

<%//=============================================================================%>
<%//                    Option Controls for Patient                              %>
<%//=============================================================================%>

<div class="d-inline-block ml-3">
<%if (canStartNewVisit == true) {%>
<Spedmon:DataEntryButton ID="mgn_pat_butStartVisit" cssClass="d-inline-block" assignBsCssClasses="true" style="SUCCESS" size="SMALL" iconOnly="false" faIcon="fa fa-plus-circle" title="Start A New Visit" label="Start A New Visit" onclick="doStartPracticeOfficeVisit()" runat="server"/>
<%}%>

<%if(canReferPatient == true){%>
<Spedmon:DataEntryButton ID="btn_for_pat_ref" cssClass="ml-1 d-inline-block" assignBsCssClasses="true" style="PRIMARY" size="SMALL" iconOnly="false" faIcon="fas fa-people-arrows" label="Create/Manage Referrals" onclick="doReferrPatient()" runat="server" />
<%}%>

<%if (isPCalStaff == true) {%>
<Spedmon:DataEntryButton ID="btn_edit_iep" 
    cssClass="ml-1 d-inline-block" 
    assignBsCssClasses="true" 
    style="INFO" 
    size="SMALL" 
    iconOnly="false" 
    faIcon="fas fa-graduation-cap" 
    label="IEP Writer" 
    onclick="openIEPEditPage()"
    runat="server" />
<%}%>

</div> <!-- option controls -->

</div> <!-- Bar and options -->
     
<%//#############################################################################%>
<%//                               Tabs                                          %>
<%//#############################################################################%>

<div id="pattabs">
<ul>         
  <li><a href="#tab-medical-history">Medical History</a></li>
  <li><a href="#tab-contacts">Contacts</a></li>
  <li><a href="#tab-insurance-carriers">Insurance</a></li>
  <li><a href="#tab-services">Orders & Prescriptions</a></li>
  <li><a href="#tab-promised-services">IEP Related Services</a></li>
  <li><a href="#tab-goals">Goals</a></li>
  <li><a href="#tab-transportation">Transportation</a></li>
  <li><a href="#tab-documentation">Documentation</a></li>
  <li><a href="#tab-files">Files</a></li>            
  <li><a href="#tab-communications">Communications
      <span id="communicationsMessagesBadge" class="communications-tab-badge"><%=communicationsMessagesCount %></span>
      </a></li>															   
</ul>

<%//=============================================================================%>
<%//                           Medical History                                   %>
<%//=============================================================================%>

<div id="tab-medical-history">      
<div class="container-fluid">

<div class="row">

<%//---------------------------------%>
<%// Known Health Problems           %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientknownhealthproblems" class="col-3">
<div id="restviewpatientknownhealthproblems" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->

<%//---------------------------------%>
<%// Allergies                       %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientallergies" class="col-3">
<div id="restviewpatientallergies" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->

<%//---------------------------------%>
<%// Diagnoses                       %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientdiagnoses" class="col-6">
<div id="restviewpatientdiagnoses" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->

<%//---------------------------------%>
<%// Care Notes Component            %>
<%//---------------------------------%>

<% if (canUsePreCareNotes == true) { %>
<div class="row tab-subsection-divider">
<div id="manageviewpatientcarenotes" class="col-12 my-4 p-4">
<div id="patientcarenotescomponent"></div>
</div>
</div><!-- care notes row -->
<%}%>

<%//---------------------------------%>
<%// Practice Office Visits          %>
<%//---------------------------------%>

<% if (canViewVisitHistory == true) { %>                        
<div class="row tab-subsection-divider">   
<div class="col-12">        

<div class="manage-patient-label">Visit History</div>
</div>
<div id="manageviewvisitscontainer" class="col-12 my-4 p-4">
<div id="visitscomponentview" >                                    
</div>
</div> <!-- col -->
</div><!-- practice office visits row -->
<%}%>

<%//---------------------------------%>
<%// Medication Adminstration        %>
<%//---------------------------------%>

<%if (canAdministerOrdersOrPx == true) { %>                        
<div class="row tab-subsection-divider">  
<div class="manage-patient-label">Order or Prescriptions </div>
<div id="managevieworderorpxcontainer" class="col-12 my-4 p-4">                                
<div id="orderorpxcomponentview">                                    
</div>
</div>
</div> <!-- orders or px row -->
<%}%>

<%//---------------------------------%>
<%// Record Scheduled Services       %>
<%//---------------------------------%>

<%if (canRecordScheduledServices == true) { %>
<div class="row tab-subsection-divider">    
<div id="scheduledservicesforpracandpatondoscont" class="col-12 my-2 p-2">    
<div id="scheduledservicesforpracandpatondosview">                                    
</div>
</div>
</div> <!-- scheduled service record row-->
<%}%>

<%//---------------------------------%>
<%// Vital Signs                     %>
<%//---------------------------------%>

<% if (canAdministerVitalSigns == true) {%>
<div class="row tab-subsection-divider">  
<div class="manage-patient-label">Vital Signs</div>
<div id="manageviewvitalsignscontainer" class="col-12 my-4 p-4">                               
<div id="vitalsignscomponentview">                                     
</div>
</div>
</div> <!-- vital signs row -->
<%}%>
</div> <!-- container -->
</div> <!-- tab -->
  
<%//=============================================================================%>
<%//                         Contacts  %>
<%//=============================================================================%>

<div id="tab-contacts">      
<div class="container-fluid">
        <div id="datamanagerowsrestviewpatientpersons" class="row">
        <div class="col-12">
        <div id="restviewpatientpersons"></div>
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- contacts -->

<%//=============================================================================%>
<%//                      Insurance Carriers  %>
<%//=============================================================================%>

<div id="tab-insurance-carriers">
           <div id="dataManagementRowsForInsuranceCarriers" class="container-fluid">
                <div id="restViewOrdersInsuranceCarriers" class="row mt-2">
                    <div class="col-12">
                        <div id="insuranceCarriersRestView"></div>
                    </div> <!-- col -->
                </div> <!--row -->
            </div>
</div>

<%//=============================================================================%>
<%//                    Orders and Prescriptions %>
<%//=============================================================================%>

<div id="tab-services">
        <div class="container-fluid">
        <div id="datamanagerowsrestviewordersorprescriptions" class="row">
        <div class="col-12">
        <div id="restviewordersorprescriptions"></div> <!-- restview -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
</div> <!-- orders and prescriptions -->
        
<%//=============================================================================%>
<%//             IEP Related Services (Promised Services) %>
<%//=============================================================================%>

<div id="tab-promised-services">      
        <div class="container-fluid">
        <%if(saveTypeVal == Constants.SAVE_TYPE_EDIT) {%>
        <div class="row">
          <div class="col-12">
            <table class="table table-sm">
            <thead>           
            <tr>
              <th>Case Manager</th>
              <th>Disability 1</th>
              <th>Disability 2</th>
              <th>Last Eval Date</th>
              <th>Last IEP Date</th>
              <th>Next IEP Date</th>
              <th>Exited SpEd Date</th>
            </tr>
            </thead>
            <tbody>
              <tr>
                <td><%=p.spEdCaseManagerName%></td>
                <td><%=p.spEdDisability1CodeAndName%></td>
                <td><%=p.spEdDisability2CodeAndName%></td>
                <td><%=p.spEdLastEvalDateYMD%></td>
                <td><%=p.spEdLastAnnualIEPDateYMD%></td>
                <td><%=p.spEdNextAnnualIEPDateYMD%></td>
                <td><%=p.spEdExitedSpEdDateYMD%></td>
              </tr>
            </tbody>
             </table>
            </div> <!-- col-->  
        </div> <!-- row-->
        <%}%>
            
        <div id="datamanagerowsrestviewpatientpromisedservices" class="row mt-2">
        <div class="col-12">
        <div id="restviewpatientpromisedservices"></div><!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
</div> <!-- iep related services -->

<%//=============================================================================%>
<%//              Transportation  %>
<%//=============================================================================%>

<div id="tab-transportation">

            <Spedmon:HiddenTextArea ID="recTransportationJSON" name="recTransportationJSON" title="recTransportationJSON" runat="server" />

            <div id="transportationFieldsCont">
                <div>
                    
                </div>

                <Spedmon:Button title="Add a New Stop" ID="addNewStopBut" runat="server">
                    <i class="fas fa-building fa-2x fa-stack-1x"></i>
                    <i class="fa fa-plus fa-2x fa-stack-1x fa-sm"></i>
                </Spedmon:Button>
            </div>

            <i id="addNewTransportation" class="fa fa-plus" title="Add New Record"></i>

            <table id="tblRecsTransportationJSON" class="tblRecsJSON">
                <thead>
                <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th>Pick Up Location</th>
                    <th>Drop Off Location</th>
                    <th>Route Name</th>
                    <th>Miles</th>
                    <th>Days</th>
                </tr>
                </thead>
                <tbody id="tblRecsTransportationJSONBody" class="tblRecsJSONBody">
                </tbody>
            </table>

</div>

<%//=============================================================================%>
<%//                           Goals  %>
<%//=============================================================================%>

<div id="tab-goals">
<div id="dataManagementRowsForGoals" class="container-fluid">

                <%//-----------------------------------------------------------------------------%>
                <%// Instructions %>
                <%//-----------------------------------------------------------------------------%>

                <div class="mb-3 font-weight-bold">Any edits to an existing goal will update all previously recorded service records. If you do not want the goal updated for saved records, create a new goal. Deleting a goal will not affect saved service records.</div>

                <%//-----------------------------------------------------------------------------%>
                <%// Rest View %>
                <%//-----------------------------------------------------------------------------%>

                <div id="restViewOrdersPrescriptionsRow" class="row mt-2">
                    <div class="col-12">
                        <div id="goalsRestView"></div>
                    </div> <!-- col -->
                </div> <!--row -->

        </div>
</div>

<%//=============================================================================%>
<%//                          Service Records  %>
<%//=============================================================================%>

<div id ="tab-documentation">
        <div id="datamanagerowsrestviewservicerecords" class="container-fluid">
        <div class="row">
        <div class="col-12">
        <div id="restviewservicerecords"></div> <!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
</div> <!-- services and documentation -->

<%//=============================================================================%>
<%//                              Files  %>
<%//=============================================================================%>

<div id ="tab-files">
        <div id="datamanagerowsrestviewstoredfiles" class="container-fluid">
        <div class="row">
        <div class="col-12">
        <!-- <Spedmon:HiddenTextArea ID="recFileJSON" name="recFileJSON" title="recFileJSON" runat="server" /> -->
        <div id="restviewstoredfiles"></div><!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- files -->   
<%//=============================================================================%>
<%//                              Communications  %>
<%//=============================================================================%>
<div id="tab-communications" class="patient-communications-tab">
    <div id="datamanagerowscommunications" class="container-fluid patient-communications-container">
        <div class="row">
            <div class="col-12">
                <fieldset class="patient-notifications-fieldset mt-3">
                    <legend class="patient-notifications-legend">
                        <span class="patient-notifications-icon">
                            <i class="fas fa-bell"></i>
                        </span>

                        <span class="patient-notifications-title-wrap">
                            <span class="patient-notifications-title">
                                Messages
                            </span>
                        </span>
                    </legend>
                    <div class="patient-notifications-fieldset-body">
                        <div class="mba-portal-messages-widget">
                            <Spedmon:ParentPortalMessagesWidget ID="spedmonPatientNotificationsAndMessages" title="Notifications & Messages" runat="server" />
                        </div>
                    </div>
                </fieldset>
            </div> <!-- col -->
        </div> <!-- row -->
    </div> <!-- container -->
</div> <!-- communications -->
		
</div> <!-- tabs -->
<%}%>
</div> <!-- right -->
</div> <!-- row -->
</div> <!-- container -->

<%//#####################################################################################################%>
<%//                                     Inline Scripts                                                  %>
<%//#####################################################################################################%>

<script>

let $r1_cl               = null;
let $r1_cr               = null;
let initComplete         = false;
let $restViewStoredFiles = null;

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function doReferrPatient() {
    <%if (canReferPatient == true) { %> MBA.ComponentCommon.fnOpenWindow('<%=urlPracPatReferal%>', 'newreferral');<%}%>
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function doStartPracticeOfficeVisit() {
        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(90);
        let $newvisitform = $('<form id="mgn_pat_startnewvisit">');
        let $div = $('<div class="form-group">');
        let $labelVisitReasion = $('<label class="mr-2" for="mgn_pat_practiceofficevisitreasonid">Reason for Visit</label>');
        let $selectVisitReason = $('<select class="form-control" id="mgn_pat_practiceofficevisitreasonid" name="mgn_pat_practiceofficevisitreasonid"></select>');
        let $labelReasonNotes = $('<label class="mr-2" for="mgn_pat_practiceofficevisitreasonnotes">Reason For Visit Notes:</label>');
        let $txtareaReasonNotes = $('<textarea class="form-control" id="mgn_pat_practiceofficevisitreasonnotes" name="mgn_pat_practiceofficevisitreasonnotes" placeholder="Notes here..."></textarea>');

        $div.append($labelVisitReasion, $selectVisitReason, '<br/>', $labelReasonNotes, $txtareaReasonNotes);
        $($newvisitform).append($div);

        let objGoalChartDiaOpts = {
            modal: true
            , width: (vw)
            , height: (vh)
            , open: function (event, ui) {

                let valueGrpSvcClsNmeID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
                let requestObj = {};

                requestObj['<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'] = valueGrpSvcClsNmeID;
                requestObj['<%=Spedmon.Constants.PARM_SEARCH_TERM%>'] = "";

                let requestJSON = JSON.stringify(requestObj);

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>', requestJSON, null)
                    .then(responseData => {
                        $.each(responseData.rawData.SelRecs, function (index, option) {
                            $('#mgn_pat_practiceofficevisitreasonid').append(
                                $('<option>', {
                                    value: option.id,
                                    text: option.value
                                })
                            );
                        });

                    })
                    .catch(err => {
                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                    });
            }
            , buttons: [
                {
                    text: "Close", click: function () {
                        $(this).dialog("close");
                    }
                },
                {
                    text: "Start Visit", click: function () {

                        let valueClientID = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
                                let valuePracID = $('#<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>').val();
                                let valueGrpSvcClsNmeID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
                                let valuePatID = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>').val();
                                let valueSiteID = $('#<%=Spedmon.Constants.PARM_SITE_ID%>').val();
                                let valueReasonNotesID = $('#mgn_pat_practiceofficevisitreasonid').val();
                                let valueReasonForVisitNotes = $('#mgn_pat_practiceofficevisitreasonnotes').val();
                                let valueRecID = $('#<%=Spedmon.Constants.PARM_REC_ID%>').val();

                                let requestObj = {};

                                requestObj['<%=Spedmon.Constants.PARM_CLIENT_ID%>'] = valueClientID;
                                requestObj['<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'] = valueGrpSvcClsNmeID;
                                requestObj['<%=Spedmon.Constants.PARM_SITE_ID%>'] = valueSiteID;
                                requestObj['<%=Spedmon.Constants.PARM_PATIENT_ID%>'] = valuePatID;
                                requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>'] = valueReasonNotesID;
                                requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>'] = valueReasonForVisitNotes;
                                requestObj['<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'] = valuePracID;
                        requestObj['<%=Spedmon.Constants.PARM_SAVE_TYPE%>'] = "1";
                        requestObj['<%=Spedmon.Constants.PARM_REC_ID%>'] = valueRecID;

                        let requestJSON = JSON.stringify(requestObj);
    
                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE()%>', requestJSON, null)
                            .then(responseData => {
                                let _parms = [];
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_CLIENT_ID%>', valueClientID));
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_REC_ID%>', responseData.rawData.recordID));
                             
                                <%if(isSubPage == true){%>
                                  _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_APP_MODE%>', '<%=Spedmon.Constants.AMD_UI_DBS_SUB_PAGE%>'));
                                <%}%>

                                <%if(contentOnly == false){%>
                                  _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_SOURCE%>', '<%=Spedmon.PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE%>'));  /* Patient profile */
                                <%} else {%>
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_SOURCE%>', '<%=Spedmon.PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE_MANAGE_PATIENTS%>'));  /* Patient profile iframe */
                                <%}%>
                                 
                                let _url = MBA.RestViewCommon.fnBuildUrl('<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>', true, _parms);
                                MBA.ComponentCommon.fnGotoURL(_url);
                            })
                            .catch(err => {
                                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                            });
                    }
                }
            ]
        };

        MBA.ComponentCommon.fnCreateOneTimeDialog("<b>Create New Visit</b>", $newvisitform, objGoalChartDiaOpts);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initProfile() {

  let opts = {};

  opts.PARM_NAME_CLIENT_ID       = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
  opts.PARM_NAME_REC_ID          = '<%=Spedmon.Constants.PARM_REC_ID%>';
  opts.PARM_NAME_SAVE_TYPE       = '<%=Spedmon.Constants.PARM_SAVE_TYPE%>';
  opts.PARM_NAME_VALIDATE_REC    = '<%=Spedmon.Constants.PARM_VALIDATE_REC%>';
  opts.PARM_NAME_EDIT_DEL_REASON = '<%=Spedmon.Constants.PARM_EDIT_DEL_REASON%>';
  opts.PARM_NAME_SEARCH_TERM     = '<%=Spedmon.Constants.PARM_SEARCH_TERM%>';
  opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.baseUrlSaveProfile        = '<%=Spedmon.Patients.URL_SVC_SAVE_PROFILE_BASE()%>';
  opts.baseUrlGetProfile         = '<%=Spedmon.Patients.URL_SVC_GET_BASE()%>';
  opts.baseUrlSiteIDSel          = '<%=Spedmon.Sites.URL_SVC_VIEW_SEL()%>';
  opts.baseUrlPreferredContactMethodIDSel = '<%= Spedmon.ContactMethods.URL_VIEW_SEL_BASE()%>';
  opts.isPcalStaff               = <%=isPcalStaffJSBoolStr%>;
  opts.VALUE_SAVE_TYPE           = '<%=saveType%>';
  opts.VALUE_PAT_ID              = '<%=recID%>';
  opts.baseUrlSaveProfilePicture = '<%=Spedmon.PatientProfilePictures.URL_SVC_SAVE_OR_REPLACE_BASE()%>';
  opts.baseUrlGetProfilePicture  = '<%=Spedmon.PatientProfilePictures.URL_SVC_GET_BASE()%>';
  opts.baseUrlDeleteProfilePicture = '';
  opts.enableProfilePictureUpload = true;
  opts.baseUrlFindStudentsWithSSID = '<%=Spedmon.CrossClientPatients.URL_VIEW_SEL_FOR_NEW_RECS_BASE()%>';
  
  opts.fnAfterSaveNew = function (newPatID) {
      let _nvps = [];
      _nvps.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_SAVE_TYPE%>', '2'));
      _nvps.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_REC_ID%>', newPatID));
      let _editPatUrl = MBA.ComponentCommon.fnBuildUrl('<%=patientSaveURL%>', true, _nvps);
      MBA.ComponentCommon.fnGotoURL(_editPatUrl, _nvps);
  };

  opts.fnAfterSaveEdit = function (patID) {
      MBA.StudentStatusBarCommon.fnGetMissingInfoAndUpdateStatusStates('patientTopBannerContainer', initComplete);
  };

  opts.fnBeforeShrink = function () {
     $($r1_cl).removeClass('col-3');
     $($r1_cr).removeClass('col-9');
  };

  opts.fnAfterShrink = function () {
      $($r1_cl).addClass('col-3');
      $($r1_cr).addClass('col-12');
  };

  opts.fnBeforeRestore = function () {
      $($r1_cl).removeClass('col-3');
      $($r1_cr).removeClass('col-12');
  };

  opts.fnAfterRestore = function () {
     $($r1_cl).addClass('col-3');
     $($r1_cr).addClass('col-9');
  };

  opts.relatedRestViewStoredFilesRef = $restViewStoredFiles;

  opts.baseUrlInvitePatientPortal = '<%=Spedmon.Patients.URL_INVITE_PATIENT_TO_PORTAL_BASE()%>';
  opts.baseUrlSaveMessage         = '<%=urlUserMessagesSave%>';
  opts.baseUrlurlRecipientSrc     = '<%=urlRecipientSrc%>';

  MBA.PatientProfileCommon.fnSetup('profile', opts);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPatientStatusBar() {

    let opts = {
         VALUE_CLIENT_ID:'<%=clientID%>'
        ,VALUE_PAT_ID: '<%=recID%>'
        ,PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        ,PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        ,sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        ,baseUrlGetMissingInfo: '<%=Spedmon.PatientsWithMissingInfo.URL_SVC_GET_BASE()%>'
        /*,patientProfileControlID:'profile'*/
      };

    MBA.StudentStatusBarCommon.fnSetup('patientTopBannerContainer', opts);
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initKnownHealthProblemsRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientknownhealthproblems'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PatientKnownHealthProblems.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'<%=Spedmon.PatientKnownHealthProblem.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew:'<%=Spedmon.PatientKnownHealthProblems.URL_SAVE_NEW_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PatientKnownHealthProblems.URL_EDIT_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PatientKnownHealthProblems.URL_DELETE_INLINE_BASE()%>'
            , baseUrlKnownHealthProblemIDSel: '<%=Spedmon.KnownHealthProblems.URL_VIEW_SEL_BASE()%>'
            , showAddNew: true
            , showEdit: true
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

        MBA.PatientKnownHealthProblemsCommon.fnSetup('restviewpatientknownhealthproblems', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initAllergiesRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientallergies'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PatientAllergies.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'<%=Spedmon.PatientAllergy.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew:'<%=Spedmon.PatientAllergies.URL_SAVE_NEW_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PatientAllergies.URL_EDIT_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PatientAllergies.URL_DELETE_INLINE_BASE()%>'
            , baseUrlAllergyIDSel: '<%=Spedmon.Allergies.URL_VIEW_SEL_BASE()%>'
            , showAddNew: true
            , showEdit: true
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

        MBA.PatientAllergiesCommon.fnSetup('restviewpatientallergies', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initDiagnosesRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientdiagnoses'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PatientDiagnoses.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'<%=Spedmon.PatientDiagnosis.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PatientDiagnoses.URL_DELETE_INLINE_BASE()%>'
            , baseUrlDiagnosisIDSel: '<%=Spedmon.ICD10CMCodes.URL_VIEW_SEL_BASE()%>'
            , showAddNew: true
            , showEdit: false
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

        MBA.PatientDiagnosesCommon.fnSetup('restviewpatientdiagnoses', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPatientCareNotes() {

        let optsForPatientCareNotes = {};

        optsForPatientCareNotes.PARM_NAME_CLIENT_ID = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
       optsForPatientCareNotes.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
       optsForPatientCareNotes.PARM_NAME_PAT_ID = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>').val();
       optsForPatientCareNotes.containerCtrlID = 'manageviewpatientcarenotes';
       optsForPatientCareNotes.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
       optsForPatientCareNotes.baseUrlView = '<%=Spedmon.PatientCareNotes.URL_REST_VIEW_BASE()%>';
       optsForPatientCareNotes.defaultPageRowOrder = '<%=Spedmon.PatientCareNote.DEFAULT_PAGING_ORDER%>';
       optsForPatientCareNotes.baseUrlSave = '<%=Spedmon.PatientCareNotes.URL_SAVE_NOTE_BASE()%>';
       optsForPatientCareNotes.baseUrlLoad = '<%=Spedmon.PatientCareNotes.URL_LOAD_NOTE_BASE()%>';

        MBA.PatientCareNotesCommon.fnSetup('patientcarenotescomponent', optsForPatientCareNotes);

    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPracticeOfficeRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_COMPLETED: '<%=Spedmon.Constants.PARM_COMPLETED%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_DATA_SOURCE: '<%=Spedmon.Constants.PARM_DATA_SOURCE%>'
            , dataSourceValueForVisits: '1' /* Default all.  1= all , 2 = waiting room only */
            , containerCtrlID: 'manageviewvisitscontainer'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PracticeOfficeVisits.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PracticeOfficeVisit.DEFAULT_PAGING_ORDER%>'
            , whatPage: 3
            , baseUrlAddNew: ''
            , baseUrlEdit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_END_VISIT_BASE()%>'
            , baseUrlDelete: ''
            , baseUrlPatIDSel: '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>'
            , baseUrlPracticeOfficeVisitReasonIDSel: '<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracIDSel: '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>'
            , baseUrlPatientVisitManage: '<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>'
            , baseUrlPracticeOfficeVisitResolutionIDSel:'<%=Spedmon.PracticeOfficeVisitResolutions.URL_VIEW_SEL_BASE()%>'
            , baseUrlReport: 'URL_WEB_LOAD_BASEURL_WEB_REPORT_BASE()%>'
            , defaultReportNumber: '<%=Spedmon.PracticeOfficeVisitsView.REPT_NUM_VIEW%>'
            , ATTEST_STATEMENT: '<%=MBA.Messages.ATTEST_STATEMENT%>'
            , tkn: '<%=rd.wu.usr.token%>'
            , baseUrlLoadVisit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_LOAD_BASE()%>'
            , formDataJSON: ''
            , showAddNew: false
            , showStartVisit: false
            , showEdit: true
            , completedValue: 'Y'
            , showCaption: false
            , caption: 'Visits'
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '15em'
            , autoHidePageControls: true
            , enableSortControls: false
            , showPatientRelatedColumns: false
            , showWaitingRelatedFields: false
            , showVisitRelatedFields: true
            , canEditPat: false
            , canEditPrac: false
            , canEditVisitReason: false
            , canEditVisitResolution: true
        };

        MBA.PracticeOfficeVisitsCommon.fnSetup('visitscomponentview', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initOrderOrPrescriptionForHSDelivery() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_DOS: '<%=Spedmon.Constants.PARM_DOS%>'
            , PARM_NAME_GROUP_ID: '<%=Spedmon.Constants.PARM_GROUP_ID%>'
            , PARM_NAME_TERM: '<%=Spedmon.Constants.PARM_SEARCH_TERM%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'managevieworderorpxcontainer'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceJournalRecentProcedureEntries.URL_REST_VIEW_OPEN_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.ServiceJournalRecentProcedureEntry.DEFAULT_PAGING_ORDER%>'
            , baseUrlViewSelPatOrdersForDOS: '<%=Spedmon.ServiceJournalsJournalEventSelections.URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY_BASE()%>'
            , baseUrlSaveJournalJournal: '<%=Spedmon.ServiceJournalsJournals.URL_SVC_SAVE_INLINE_BASE()%>'
            , baseUrlSaveJournalEntry: '<%=Spedmon.ServiceJournalsJournalEntries.URL_SVC_SAVE_INLINE_BASE()%>'
            , tkn: '<%=this.rd.wu.usr.token%>'
        };
        MBA.OrdersOrPrescriptionsProvideHSForPatOnDOSCommon.fnSetup('orderorpxcomponentview', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initVitalsMeasurementsForPatOnDOS() {

        let optsForPatientVitalSigns = {};

        optsForPatientVitalSigns.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
       optsForPatientVitalSigns.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
       optsForPatientVitalSigns.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
       optsForPatientVitalSigns.containerCtrlID = 'manageviewvitalsignscontainer';
       optsForPatientVitalSigns.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
       optsForPatientVitalSigns.baseUrlView = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_VIEW_BASE()%>';
       optsForPatientVitalSigns.defaultPageRowOrder = '<%=Spedmon.PatientVitalsMeasurement.DEFAULT_PAGING_ORDER%>';
       optsForPatientVitalSigns.baseUrlAddNew = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
       optsForPatientVitalSigns.baseUrlEdit = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
       optsForPatientVitalSigns.baseUrlDelete = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_DELETE_INLINE_BASE()%>';
       optsForPatientVitalSigns.baseUrlReport = '<%=Spedmon.PatientVitalsMeasurements.URL_WEB_REPORT_BASE()%>';
       optsForPatientVitalSigns.defaultReportNumber = '<%=Spedmon.PatientVitalsMeasurementView.REPT_NUM_VIEW%>';

        MBA.PatientVitalSignsMeasurementCommon.fnSetup('vitalsignscomponentview', optsForPatientVitalSigns);

    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initInsuranceCoverageView() {

        let optsObj = {};

        optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
       optsObj.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
       optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
       optsObj.containerCtrlID = 'restViewOrdersInsuranceCarriers';
       optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
       optsObj.baseUrlView = '<%=Spedmon.PatientInsuranceCarriers.URL_PATIENT_CARRIERS_REST_VIEW_BASE()%>';
       optsObj.defaultPageRowOrder = '<%=Spedmon.PatientInsuranceCarrier.DEFAULT_PAGING_ORDER%>';
       optsObj.baseUrlAddNew = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
       optsObj.baseUrlEdit = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
       optsObj.baseUrlInsuranceCarrierIDSel = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>';
        optsObj.autoHidePageControls = true;
        optsObj.enableScrollView = true;
        optsObj.scrollViewUseCustomHeight = true;
        optsObj.scrollViewCustomHeight = '20em';
        optsObj.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
          MBA.StudentStatusBarCommon.fnGetMissingInfoAndUpdateStatusStates('patientTopBannerContainer', initComplete);
          return;
        };
        MBA.PatientInsuranceCommon.fnSetup('insuranceCarriersRestView', optsObj);

        return;
    }

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPatientGoalsView() {

        let optsObj = {};

        optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
       optsObj.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
       optsObj.PARM_NAME_PAT_GOAL_ID = '<%=Spedmon.Constants.PARM_PATIENT_GOAL_ID%>';
       optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
       optsObj.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>';
       optsObj.PARAM_ROLE_LEA_PROVIDER_ID = '<%=Spedmon.Constants.ROLE_LEA_PROVIDER_ID%>';
       optsObj.containerCtrlID = 'dataManagementRowsForGoals';
       optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
       optsObj.baseUrlView = '<%=Spedmon.PatientGoals.URL_REST_VIEW_BASE()%>';
       optsObj.defaultPageRowOrder = '<%=Spedmon.PatientGoal.DEFAULT_PAGING_ORDER%>';
       optsObj.baseUrlAddNew = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlEdit = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlDelete = '<%=Spedmon.PatientGoals.URL_REST_DELETE_INLINE_BASE()%>'
        optsObj.groupSvcClassNameIDOpts = '<%=Spedmon.GroupsServiceClasses.URL_REST_VIEWSEL_FOR_ORP_DOCS_BASE()%>';
        optsObj.patientGoalsDefaultDates = '<%=Spedmon.PatientGoalsDefaultDates.URL_SVC_VIEW_DEFAULT_DATES_BASE()%>';
        optsObj.baseUrlIndividualGoal = '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>';
        optsObj.roleID = '<%=rd.wu.usr.roleID%>';
        optsObj.baseUrlViewProgress = '<%=urlViewAllPatientGoalsProgress%>';
        optsObj.pracGrpSvcClassNameID = '<%=pracGrpSvcClassNameID%>';
        optsObj.autoHidePageControls = true;
        optsObj.enableScrollView = true;
        optsObj.scrollViewUseCustomHeight = true;
        optsObj.scrollViewCustomHeight = '20em';

        MBA.PatientGoalsCommon.fnSetup('goalsRestView', optsObj);

        return;
    }

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPatientPersonsView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_PERSON_ROLE_ID: '<%=Spedmon.Constants.PARM_PERSON_ROLE_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientpersons'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PatientPersons.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PatientPerson.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlEdit: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlDelete: '<%=Spedmon.PatientPersons.URL_DELETE_INLINE_BASE()%>'
            , baseUrlReport: ''
            , defaultReportNumber: '1'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
            , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) {
                MBA.StudentStatusBarCommon.fnGetMissingInfoAndUpdateStatusStates('patientTopBannerContainer', initComplete);
                return;
            }
            , isPcalStaff:<%=isPcalStaffJSBoolStr%>
			, baseUrlInvitePortal: '<%=Spedmon.PatientPersons.URL_INVITE_PARENT_PORTAL_BASE()%>'
            , currentPage: 1

    };

        MBA.PatientPersonsCommon.fnSetup('restviewpatientpersons', optsObj);
        return;
    }

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initOrdersOrPrescriptionsRestView() {
        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_NAME_ORP_APR_STATE:'<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
            , containerCtrlID: 'datamanagerowsrestviewordersorprescriptions'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ORPDocuments.URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES()%>'
            , defaultPageRowOrder: 'id desc'
            , baseUrlAddNew: '<%=Spedmon.ORPDocuments.URL_ADD_NEW_ORDER_PRESCRIPTION()%>'
            , baseUrlEdit: '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>'
            , baseUrlDelete: '<%=Spedmon.ORPDocuments.URL_DELETE_ORDER_PRESCRIPTION_BASE()%>'
            , baseUrlReport: '<%=Spedmon.ORPDocuments.URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES()%>'
            , defaultReportNumber: '<%=Spedmon.ORPDocumentsViw.REPT_NUM_VIEW_ORDERS_AND_PROFILES%>'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
            , showActive: false
            , showPatientName: false
            , showPracticeName: false
            , showSiteName: false
            , hasCarePlanAccess: true
            , editCarePlanUrl: '<%=Spedmon.PlanWriterPlans.GEN_URL_ASPX_SAVE()%>'
            , svcAuthReqOrderOrPrescriptionUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE()%>'
            , svcAuthReqPatProfileUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE()%>'
            , autoHidePageControls: true
            , fnGetActiveValue: function (dataObj) { return '1'; }
            , fnGetOrpApprovalStateValue: function (dataObj) { return ''; }
        };

        MBA.OrdersOrPrescriptionsCommon.fnSetup('restviewordersorprescriptions', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initPromisedServicesView() {

        let optsObj = {
          PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
        , containerCtrlID: 'datamanagerowsrestviewpatientpromisedservices'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.PatientPromisedServices.URL_REST_VIEW()%>'
        , defaultPageRowOrder: '<%=Spedmon.PatientPromisedService.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew: '<%=Spedmon.PatientPromisedServices.URL_ADD_NEW_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlEdit: '<%=Spedmon.PatientPromisedServices.URL_EDIT_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlDelete: '<%=Spedmon.PatientPromisedServices.URL_REST_DELETE_INLINE()%>'
        , baseUrlReport: ''
        , defaultReportNumber: '1'
        , autoHidePageControls: true
        , enableScrollView: true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
        , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) {
            MBA.StudentStatusBarCommon.fnGetMissingInfoAndUpdateStatusStates('patientTopBannerContainer', initComplete);
                return;
        }

        };

        MBA.PatientPromisedServicesCommon.fnSetup('restviewpatientpromisedservices', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initStoredFilesView() {

    let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
      , PARM_NAME_DATE_RANGE: '<%=Constants.PARM_DATE_RANGE%>'
      , PARM_NAME_FILE_CLASS: '<%=Constants.PARM_FILE_CLASS%>'
      , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
      , PARM_NAME_FILE_ID: '<%=Spedmon.StoredFiles.PARAM_FILE_ID%>'
      , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
      , containerCtrlID: 'datamanagerowsrestviewstoredfiles'
      , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
      , baseUrlView: '<%=Spedmon.StoredFiles.URL_REST_VIEW_BASE()%>'
      , defaultPageRowOrder: '<%=Spedmon.StoredFile.DEFAULT_PAGING_ORDER%>'
      , baseUrlDelete: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DELETE()%>'
      , baseUrlReport: '<%=Spedmon.StoredFiles.URL_WEB_REPORT_BASE()%>'
      , defaultReportNumber: '<%=Spedmon.StoredFilesRpt.REPT_NUM_VIEW%>'
      , autoHidePageControls: true
      , enableScrollView: true
      , scrollViewUseCustomHeight: true
      , scrollViewCustomHeight: '20em'    
      , isPcalStaff:<%=isPcalStaffJSBoolStr%>
      , showPatientName: false
      , webSvcFlagAsNonConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()%>'
      , webSvcFlagAsConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
      , webSvcEnableSharingWithPatientUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()%>'
      , webSvcDisableSharingWithPatientUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()%>'
      , webSvcEnableSharingWithParentUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()%>'
      , webSvcDisableSharingWithParentUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()%>'
      , currUserID: <%=rd.wu.usr.id%>
      , downloadHandlerPrivateBaseUrl: '<%=Spedmon.StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE_BASE()%>'
	  , urlFilesUpload: '<%=Constants.REQUEST_FILE_UPLOAD_PUBLIC%>'														   
      , fnGetFileClassValue: function (dataObj) { return ''; }
      , fnGetDateRangeValue: function (dataObj) { return ''; }
      , showOKToShareWithPatient: true
      , showOKToShareWithParentGuardian: true
       };

        $restViewStoredFiles = MBA.StoredFilesCommon.fnSetup('restviewstoredfiles', optsObj);
        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initServiceRecordsView() {

        let optsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PATIENT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewservicerecords'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: 'dos desc'
            , baseUrlReport: ''
            , defaultReportNumber: '1'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
        };

        MBA.PatientServiceRecordsCommon.fnSetup('restviewservicerecords', optsObj);

        return;
    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initScheduledServicesForPracAndPatOnDos() {

        let optsIn = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PRACTITIONER_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PATIENT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Constants.PARM_ACTIVE%>'
            , PARM_NAME_DOS: '<%=Constants.PARM_DOS%>'
            , PARM_NAME_SAVE_TYPE: '<%=Spedmon.Constants.PARM_SAVE_TYPE%>'
            , PARM_NAME_REC_ID: '<%=Constants.PARM_REC_ID%>'
            , PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID:  '<%=Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID%>'
            , PARM_SVC_NOTES_FB_QUESTIONS: '<%=Constants.PARM_SVC_NOTES_FB_QUESTIONS%>'
            , PARM_SVC_NOTES_FB_ANSWERS: '<%=Constants.PARM_SVC_NOTES_FB_ANSWERS%>'
            , PARM_REF_DATE: '<%=Constants.PARM_REF_DATE%>'
            , PARM_SVC_NAME: '<%=Constants.PARM_SVC_NAME%>'
            , PARM_NOTES: '<%=Constants.PARM_NOTES%>'
            , PARM_HAS_PAT_GOAL_TRACKING_DATA:'<%=Constants.PARM_HAS_PAT_GOAL_TRACKING_DATA%>'
            , PARM_PAT_GOAL_PROGRESS: '<%=Constants.PARM_PAT_GOAL_PROGRESS%>'
            , PARM_GROUP_ID: '<%=Constants.PARM_GROUP_ID%>'
            , PARM_NAME_ID: '<%=Constants.PARM_NAME_ID%>'
            , PARM_VIA_TELEHEALTH: '<%=Constants.PARM_VIA_TELEHEALTH%>'
            , PARM_NAME_TERM: '<%=Constants.PARM_SEARCH_TERM%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_SVC_NAMES_LIST_DATA_SOURCE_ID: '<%=Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID%>'
            , PARM_GRP_SVC_NAME_ID: '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_ORP_APR_STATE: '<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
            , baseUrlViewOrderAndPx: '<%=urlManageOrderAndPx%>'
            , containerCtrlID: 'scheduledservicesforpracandpatondoscont'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: 'dos desc'
            , baseUrlAddNew: '<%=Spedmon.PractitionerPatientScheduledServices.URL_ADD_NEW_BASE()%>'
            , baseUrlEditServiceRec: '<%=Spedmon.PractitionerPatientScheduledServices.URL_EDIT_BASE()%>'
            , baseUrlViewScheduledSvcsOnDosForPat: '<%=Spedmon.ServiceRecordsExpectedEntryRows.URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT_BASE()%>'
            , baseUrlSaveNewServiceRec: '<%=Spedmon.ServiceRecords.URL_SVC_ADD_NEW_INLINE_BASE()%>'
            , svcSelName: '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>'
            , baseUrlViewAllPatientGoalsProgress: '<%=urlViewAllPatientGoalsProgress%>'
            , baseUrlViewPatientGoalsProgress: '<%=urlViewPatientGoalsProgress%>'
            , baseUrlNoteLibExport: '<%=Spedmon.NoteLibrarySavedNotes.URL_EXPORT_NOTE_BASE()%>'
            , saveTypeValueForNew: '<%=Constants.SAVE_TYPE_NEW%>'
            , saveTypeValueForEdit: '<%=Constants.SAVE_TYPE_EDIT%>'
            , tkn: '<%=this.rd.wu.usr.token%>'
            , attendanceSelections: <%=attendanceSelectionsJSON%>   
            , svcPlanTypeSelections: <%=serviceNamesListPlanTypesJSON%>   

        };

        MBA.ScheduledServicesProvidedByPracForPatOnDOSCommon.fnSetup('scheduledservicesforpracandpatondosview', optsIn);

    };

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initTransportation() {

    /* Transportation */

    var optsTransportation = {};

    optsTransportation.RecsTransportationTextAreaSelector = '#recTransportationJSON';
    optsTransportation.RecsTransportationTableSelector    = '#tblRecsTransportationJSON';
    optsTransportation.RecsTransportationTableBodySelector = '#tblRecsTransportationJSONBody';

    optsTransportation.patID    = $('#patid').val();
    optsTransportation.clientID = $('#clientid').val();
    optsTransportation.tkn      = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';

    SpEdCare.recPatTransportation.init(optsTransportation);

    // Event listener for adding a new Transportation record
    $('#addNewTransportation').click(function () {
        SpEdCare.recPatTransportation.addRec();
    });

    // Event listener for adding a new stop in the Transportation tab

    $('#addNewStopBut').click(function () {
        var tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';
            var url = 'user_all_patient_places_save.aspx';
            var cid = $('#clientid').val();
            var pid = $('#patid').val();

            var reqUrl = $.spedmonWebUI.createPrivateURL(tkn, url)
                + '&amd=uidbssub'
                + '&clientid=' + cid
                + '&patid=' + pid;

            var fnEntryTest = function () { return true; };
            var fnExitTest = function () { return true; };
            var fnResume = function () {
                return true;
            };

            $.spedmonWebUI.popupThenResume(fnEntryTest
                , fnExitTest
                , fnResume
                , reqUrl
                , 'Popups Not Supported'
                , 'Please allow popups for SpEdCare'
                , 'Waiting'
                , 'Waiting for you  to finish with patient places');
        });

};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function openIEPEditPage() {
    let _clientID = $('#clientid').val();
    let _patID = $('#patid').val();  
    let urlBase = '<%=Spedmon.Patients.URL_USER_ALL_IEP_SAVE_BASE()%>';
    let parms = [];
    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_CLIENT_ID%>', _clientID));
    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_PATIENT_ID%>', _patID));
    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_REC_ID%>', _patID));
    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_SAVE_TYPE%>', '<%=Spedmon.Constants.SAVE_TYPE_EDIT%>'));
    // Note: second parameter is TRUE, not false
    let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
    return MBA.ComponentCommon.fnOpenWindow(reqUrl, 'iepedit');
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initTabs() {
  $("#pattabs").MBA_Tabs({});      

   <%/* Goto a specific tab specified by query string parameter if needed */
        if (!String.IsNullOrWhiteSpace(tabToOpen)) {%>
    $('a[href="#<%=tabToOpen%>"]').click();
        <%}%>

    <%/* ---------- Goto a specific tab if needed ---------- */%>

    var tabID = sessionStorage.getItem("tabToClickOnLoad");
    if (tabID) {
        sessionStorage.removeItem("tabToClickOnLoad");
        $('a[href="#' + tabID + '"]').click();
    }

};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

$(document).ready(function () {

    $r1_cl = $('#r1-cl');
    $r1_cr = $('#r1-cr');
    initComplete = false;

    <%if(saveTypeVal == Constants.SAVE_TYPE_NEW) {%>
    $($r1_cl).addClass('mba-save-type-new');
    $($r1_cr).addClass('mba-save-type-new');
    $($r1_cl).addClass('col-12');
    $($r1_cr).addClass('d-none');

    initProfile();

    /*
    let lastName   = '';
    let firstName  = '';
    let middleName = '';
    let preferredNickName = '';
    let dobStrYMD         = '';
    let gender            = '';
    let CSIS              = '';

    MBA.PatientProfileCommon.fnPrepopulateFields('profile', lastName, firstName, middleName, preferredNickName, dobStrYMD, gender, CSIS);
    */

    initComplete = true;
    <%}%>

    <%if(saveTypeVal == Constants.SAVE_TYPE_EDIT) {%>
    $($r1_cl).addClass('mba-save-type-edit');
    $($r1_cr).addClass('mba-save-type-edit');
    $($r1_cl).addClass('col-3');
    $($r1_cr).addClass('col-9');

    initStoredFilesView(); /* Has to be before profile init because of stored files ref depend*/
    initProfile();
    initTabs();
    initOrdersOrPrescriptionsRestView();
    initPatientPersonsView();
    initPromisedServicesView();
    initServiceRecordsView();    
    initKnownHealthProblemsRestView();
    initAllergiesRestView();
    initDiagnosesRestView();
    initInsuranceCoverageView();
    initPatientGoalsView();
    initTransportation();

    <%if (canUsePreCareNotes         == true) {%>initPatientCareNotes();<%}%>
    <%if (canViewVisitHistory        == true) {%>initPracticeOfficeRestView();<%}%>
    <%if (canAdministerOrdersOrPx    == true) {%>initOrderOrPrescriptionForHSDelivery();<%}%>
    <%if (canRecordScheduledServices == true) {%>initScheduledServicesForPracAndPatOnDos();<%}%>
    <%if (canAdministerVitalSigns    == true) {%>initVitalsMeasurementsForPatOnDOS();<%}%>

    initPatientStatusBar();
    initComplete = true;
    <%}%>
});

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

</script>