<%@ Page Language="C#" CodeBehind="user_all_caseload_and_patient_group_mgmt.aspx.cs" Inherits="Spedmon.UserAllCaseloadAndPatientGroupMgmt" %>

<%//##################################################################################################################%>
<%//#                                                Dialogs   %>
<%//##################################################################################################################%>

<div id="dialgMgmSvcResponsibilitiesRestViewContainer" title="<%=Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTitle%>" class="d-none">

  <div class="alert alert-success">
  <%=Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportInstructions%>
  </div>
  
  <div id="dialgMgmSvcResponsibilitiesRestView"></div>
</div>

<%//##################################################################################################################%>
<%//#                                            Data Entry Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">

  <div class="row">

      <%//-----------------------------------------------------------------------------%>
      <%// Select Client and Select Practitioner %>
      <%//-----------------------------------------------------------------------------%>

      <div class="col-12">
        <div class="d-flex justify-content-start align-items-center flex-wrap">

              <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
              </Spedmon:DataEntryRowSelectClient>

            <Spedmon:DataEntryRowSelectPractitioner
                ID                     = "selectPractitioner"
                rowLabel               = "Practitioner"
                dataEntryRowRenderAs   = "FIELD"
                showEditSelected       = "true"
                runat                  = "server">
            </Spedmon:DataEntryRowSelectPractitioner>

         </div> <!-- containing element-->
        </div> <!-- col -->

  </div> <!-- row -->

  <div class="row"> 
    
       <%//-----------------------------------------------------------------------------%>
       <%// Disable Compliance Calc %>
       <%//-----------------------------------------------------------------------------%>

        <div class="col-10">
        <div class="d-flex justify-content-start align-items-center flex-wrap">
          <script>
              function updateDisableComplianceCalcStatusMessage(oldval, newval) {
                  if (newval == 'No') {
                      $('#disableComplianceStatusMessage').removeClass('alert-warning');
                      $('#disableComplianceStatusMessage').addClass('alert-info');                      
                      $('#disableComplianceStatusMessage').html('Click Yes to temporarily disable progress calculations for faster updates and changes.');
                  } else {
                      $('#disableComplianceStatusMessage').removeClass('alert-info');
                      $('#disableComplianceStatusMessage').addClass('alert-warning');
                      $('#disableComplianceStatusMessage').html('Progress calculations are temporarily disabled. Minutes expected, satisfied, missing, etc will not be displayed.');
                  }
              };  
          </script>
          <Spedmon:SelectYesOrNo ID="disablecompliancecalc" name="disablecompliancecalc" title="Temporarily Disable Progress Calculations" onSelectValue="function(oldval,newval){updateDisableComplianceCalcStatusMessage(oldval,newval);return true;}" runat="server" />
          
          <span id="disableComplianceStatusMessage" class="alert alert-info" style="font-size:.90rem">
              Click Yes to temporarily disable progress calculations for faster updates and changes.
          </span>
        </div>
        </div> <!-- col -->

        <%//-----------------------------------------------------------------------------%>
        <%// Manage Calendars and Breaks %>
        <%//-----------------------------------------------------------------------------%>

        <div class="col-2">
         <div class="d-flex justify-content-end align-items-start flex-wrap">            
            <Spedmon:LinkInternal
                 ID         = "gotomanagecalsandbreaks"
                 title      = "Click here to manage your organization's school calendars and breaks"
                 label      = "Manage Calendars & Breaks"
                 faClass    = "fa fa-calendar"
                 openNew    = "true"
                 urlPrivate = "true"
                 subWindow  = "true"
                 runat      = "server" />
         </div> <!-- containing element -->
       </div> <!-- col -->


  </div> <!-- row-->

  <div class="row mt-1">

<%//-----------------------------------------------------------------------------%>
<%// Import/Export/Bulk Options %>
<%//-----------------------------------------------------------------------------%>

<div class="col-12">
    <div class="mba-cmd-tbar">
    <Spedmon:DataEntryButtonCommandToolbar
        ID            ="butDoManageScheduledSvcs"
        runat         ="server"
        cssClass      ="ml-20 mba-cmd-tbar-primary-action"
        onclick       ="doManageScheduledServices()"
        label         ="Manage Scheduled Services For All My Students"
        title         ="Click here to manage scheduled services for all students on my caseload"
        faIcon        ="fas fa-calendar-alt"
     />
    <div>
      <Spedmon:DataEntryButtonCommandToolbar
          ID            ="butDoManageCalpadPrefs"
          runat         ="server"
          style         ="PRIMARY"
          size          ="SMALL"
          cssClass      ="mba-cmd-tbar-btn mba-cmd-tbar-btn-primary"
          onclick       ="doManageCalpadCodePrefs()"
          faIcon        ="fas fa-filter" />
      <Spedmon:DataEntryButtonCommandToolbar
          ID            ="butDoImportCaseload"
          runat         ="server"
          style         ="SUCCESS"
          size          ="SMALL"
          cssClass      ="mba-cmd-tbar-btn mba-cmd-tbar-btn-success"
          onclick       ="launchDataFileUploadScreen()"
          label         ="Import My Caseload"
          title         ="Click here for options to add students to my caseload using a Excel or CSV file from a student data or special ed system"
          faIcon        ="fas fa-file-import" />
      <Spedmon:DataEntryButtonCommandToolbar
          ID            ="butDoUpdatePlanInfo"
          runat         ="server"
          style         ="WARNING"
          size          ="SMALL"
          cssClass      ="mba-cmd-tbar-btn mba-cmd-tbar-btn-warning"
          onclick       ="doUpdateCaseloadPlanInfo()"
          label         ="Update Plan Info"
          title         ="Click here for options to update any IEP/IFSP plans I am tracking on my caseload with the latest plan data available in SpEdCare"
          faIcon        ="fas fa-edit" />
      <Spedmon:DataEntryButtonCommandToolbar
          ID            ="butDoClearCaseload"
          runat         ="server"
          style         ="DANGER"
          size          ="SMALL"
          cssClass      ="mba-cmd-tbar-btn mba-cmd-tbar-btn-danger"
          onclick       ="doClearCaseload()"
          label         ="Clear Caseload"
          title         ="Click here for options to clear all students from my caseload"
          faIcon        ="fas fa-trash" />
    </div>
    </div> <!-- containing element -->
</div> <!-- col -->  
      
</div> <!-- row -->
  
  <div class="row mt-1">

     <%//-----------------------------------------------------------------------------%>
     <%// Service Record Entry Options %>
     <%//-----------------------------------------------------------------------------%>

     <div class="col-12">      
        <div class="mba-action-cards">         
            <Spedmon:DataEntryButtonCard ID="reviewmissingassessments" 
                cardAccentStyle ="blue"    
                cardIcon        ="fas fa-clipboard-list" 
                onclick         ="gotoReviewAssessments()" 
                label           ="Record Upcoming IEP(s) and Missing Assessements" 
                runat           ="server" />
            
            <Spedmon:DataEntryButtonCard ID="recordservices"
                cardAccentStyle ="teal" 
                cardIcon        ="fas fa-users"  
                onclick         ="gotoRecordSvcs()" 
                label           ="Record Services for My Caseload or Selected Groups" 
                runat           ="server" />
            
            <Spedmon:DataEntryButtonCard ID="recordservicesfordos"
                cardAccentStyle ="green" 
                cardIcon        ="fas fa-calendar-day" 
                onclick         ="gotoRecordSvcsForDos()" 
                label           ="Record My Scheduled Services for the Selected Date of Service" 
                runat           ="server" />

             <Spedmon:DataEntryBoxDate ID="dos" name="dos" 
                title           ="Enter Date of Service" 
                label           ="Date of Service" 
                setValueToToday ="true" 
                runat           ="server" />
        </div><!-- containing element -->
    </div><!-- col --> 
  </div> <!-- row -->
    
  <div class="row mt-1">
    
    <%//-----------------------------------------------------------------------------%>
    <%// CDE Compliance Summary %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
      <div class="d-flex justify-content-start align-items-center flex-wrap">
        <div id="cdecompliancesummary"></div>
      </div> <!-- containing element -->
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// What Minutes to Use %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-8">
      <div class="d-flex justify-content-end align-items-center flex-wrap">
          <Spedmon:RadioBox 
           ID                                  = "useminsperfreqassigned" 
           name                                = "useminsperfreqassigned" 
           title                               = "Show Totals and Percentages For" 
           renderLabel                         = "true" 
           additionalCssClassNameForContainer  = "modern2021"            
           runat                               = "server" />            
      </div> <!-- containing element -->
    </div> <!-- col -->
  </div> <!-- row -->

  <div class="row mt-3"> <%/* id="restViewRow"*/%>
    
    <%//-----------------------------------------------------------------------------%>
    <%// Rest View (For caseload) %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-12">
      <div id="restView">
      </div>
    </div> <!-- col -->
  </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;
    let $cdeComplianceSummaryWidget = null;
    let $gotoManageCalsAndBreaksCtrl = null;
    let $butDoUpdatePlanInfo = null;
    let toolTipOriginalDoUpdatePlanInfo = '';
    let expectedSvcStatsLoaded = false;

    const GRP_NAME_ELEMENT_CLASS = 'mba-prac-grp-name'; /* name of class for group name header */
    const PARM_NAME_CLIENT_ID = '<%=MBA.Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_ACTIVE = '<%=MBA.Constants.PARM_ACTIVE%>';
    const PARM_NAME_PRAC_ID = '<%=MBA.Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PAT_ID = '<%=MBA.Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_SPED_SVC_CODE = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_ORP_DOC_ID = '<%=Constants.PARM_ORP_DOC_ID%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_START_DATE = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_SVC_TRACKING_CLASS = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_REF_SCREEN = '<%=Constants.PARM_REF_SCREEN%>';
    const PARM_DATE_RANGE = '<%=Constants.PARM_DATE_RANGE%>';
    const PARM_NAME_CASELOAD_GROUP_ID = '<%=MBA.Constants.PARM_CASELOAD_GROUP_ID%>';
    const PARM_NAME_USE_MINS_PER_FREQ_ASSIGNED = '<%=Constants.PARM_USE_MINS_PER_FREQ_ASSIGNED%>';
    const PARM_NAME_TERM = '<%=MBA.Constants.PARM_SEARCH_TERM%>';
    const PARM_NAME_REC_ID = '<%=Constants.PARM_REC_ID%>';
    const PARM_NAME_ORG_ID = 'organizationID';
    const PARM_NAME_OWNER_ID = 'ownerID';
    const PARM_NAME_GRP_ID = 'groupID';
    const PARM_NAME_ENTITY_ID = 'entityID';

    const PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID = '<%=Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID%>';
    const PARM_NAME_DISABLE_COMPLIANCE_CALC                           = '<%=Constants.PARM_DISABLE_COMPLIANCE_CALC%>';

    /***********************************************************************************************************
     *
     *                                                    UTILITY
     *
     ***********************************************************************************************************/

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function openManagePracPatScheduledSvcMgmtScreen(clientid, pracid, patid, ppesid, useRestViewOpen, refreshView) {
        if (!clientid) return;
        if (!pracid) return;

        let urlBase = '<%=Spedmon.PractitionerPatientScheduledServices.URL_MANAGE_BASE()%>'
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, pracid));
        if (patid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, patid));
        if (ppesid) parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID, ppesid));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);

        if (useRestViewOpen === true) {
            let _rvwOpts = {};
            _rvwOpts.url = reqUrl;
            _rvwOpts.windowName = null;
            _rvwOpts.refreshView = refreshView;
            return $($restViewCtrl).MBA_RestView('openWindow', _rvwOpts);
        }
        else {
            return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
        }
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function openPatientEditScreen(clientid, patid, patScreenTabID) {
        if (!clientid) return;
        if (!patid) return;
        let urlBase = '<%=patEditUrlBase%>' + patid;
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', clientid));
        if (patScreenTabID) parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_TAB_TO_OPEN%>', patScreenTabID));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function getClientAndPracSelections() {

        let entitySelectionsObj = {};
        let cltid = $('#' + PARM_NAME_CLIENT_ID).val();
        let prcid = $('#' + PARM_NAME_PRAC_ID).val();

        entitySelectionsObj[PARM_NAME_CLIENT_ID] = cltid;
        entitySelectionsObj[PARM_NAME_PRAC_ID] = prcid;
        entitySelectionsObj.selectionsOK = false;

        if (!cltid || cltid == 0 || cltid == '0') {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50).mbaHighlight({ color: '#fcf75e', duration: 500 });
            return entitySelectionsObj;
        }

        if (!prcid || prcid == 0 || prcid == '0') {
            $('#pracid_all_cont').effect("shake", { distance: 7, times: 4 }, 50).mbaHighlight({ color: '#fcf75e', duration: 500 });
            return entitySelectionsObj;
        }

        entitySelectionsObj.selectionsOK = true;
        return entitySelectionsObj;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn) {
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, entitySelectionsObj[PARM_NAME_CLIENT_ID]));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, entitySelectionsObj[PARM_NAME_PRAC_ID]));
        let pvtUrlOut = MBA.ComponentCommon.fnBuildUrl(pvtUrlIn, 1, parms);
        return pvtUrlOut;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

    /***********************************************************************************************************
     *
     *                                               Launchers
     *
     ***********************************************************************************************************/
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
    function doManageScheduledServices() {
        let entitySelectionsObj = getClientAndPracSelections();
        if (entitySelectionsObj.selectionsOK == false) return;
        let cltid = entitySelectionsObj[PARM_NAME_CLIENT_ID];
        let prcid = entitySelectionsObj[PARM_NAME_PRAC_ID];
        openManagePracPatScheduledSvcMgmtScreen(cltid, prcid, null, null, false, false);
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
    function launchDataFileUploadScreen() {
        let entitySelectionsObj = getClientAndPracSelections();
        let pvtUrlIn = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_SAVE_NEW_IMPORT_SUB_PAGE_BASE()%>';
        if (entitySelectionsObj.selectionsOK == false) return;
        let pvtUrlOut = buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn);
        $.spedmonWebUI.openNewWindow(
            pvtUrlOut, 'practitioner-caseload-file-upload', updateAdditionalViewParameterValuesAndRequestViewFromServer
        );
        return;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function doManageCalpadCodePrefs() {
        let entitySelectionsObj = getClientAndPracSelections();
        if (entitySelectionsObj.selectionsOK == false) return;
        MBA.PractitionerSpedSvcsMgmt.openDialg();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function doClearCaseload() {
        let entitySelectionsObj = getClientAndPracSelections();
        if (entitySelectionsObj.selectionsOK == false) return;
        let reqURL = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_DELETE_ALL_BASE()%>'
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = entitySelectionsObj[PARM_NAME_CLIENT_ID];
        reqDataObj[PARM_NAME_PRAC_ID] = entitySelectionsObj[PARM_NAME_PRAC_ID];
        let reqDataJSON = JSON.stringify(reqDataObj);
        let _clearMyCaseloadContent = '<div class="alert alert-danger text-center">Are you sure you wish to clear your caseload?<br>ALL your rows (plans) will be REMOVED!<br>ALL recurring schedules related to those rows will also be REMOVED!<br>No other records or data related to the students currently on your caseload will be changed.<br><strong>If you proceed this CANNOT be undone.</strong></div></div>';
        let _fnClearMyCaseloadProceed = function () {
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
                .then(responseData => {
                    $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                    return;
                })
                .catch(responseData => {
                    return;
                });
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Request Submitted', 'Clear request has been submitted.  Your caseload will be cleared shortly and your view will be automatically refreshed.', {});
        };
        MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Clear My Caseload?', _clearMyCaseloadContent, {}, _fnClearMyCaseloadProceed, null);
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function doUpdateCaseloadPlanInfo() {
        let entitySelectionsObj = getClientAndPracSelections();
        let pvtUrlIn = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_PAGE_UPDATE_CASELOAD_BASE()%>';
        if (entitySelectionsObj.selectionsOK == false) return;
        let pvtUrlOut = buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn);
        let _updateMyCaseloadPlanInfoContent = '<div class="alert alert-warning text-center">Do you wish to update your caseload plan information with the latest plan data available in SpEdCare?<br>Only IEP/IFSP plans will be updated. Any related recurring schedules will remain unchanged.<br><strong>If you proceed this cannot be undone.<strong></div>';
        let _fnUpdateMyCaseloadPlanInfoProceed = function () {
            $($butDoUpdatePlanInfo).removeClass(MBA.RestViewCommon.CONST_CSS_CLASSES.animationPulse);
            $($butDoUpdatePlanInfo).attr('title', toolTipOriginalDoUpdatePlanInfo);
            $.spedmonWebUI.openNewWindow(
                pvtUrlOut, 'practitioner-caseload-update-plans', updateAdditionalViewParameterValuesAndRequestViewFromServer
            );
        };
        MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Update My Caseload Plan Info?', _updateMyCaseloadPlanInfoContent, {}, _fnUpdateMyCaseloadPlanInfoProceed, null);
        return;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function doGetExpectedServiceStats() {
        let entitySelectionsObj = getClientAndPracSelections();
        if (entitySelectionsObj.selectionsOK == false) return;
        let reqURL = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_GET_EXPECTED_SERVICE_STATS_BASE()%>'
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = entitySelectionsObj[PARM_NAME_CLIENT_ID];
        reqDataObj[PARM_NAME_PRAC_ID] = entitySelectionsObj[PARM_NAME_PRAC_ID];
        let reqDataJSON = JSON.stringify(reqDataObj);
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butDoUpdatePlanInfo);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butDoUpdatePlanInfo, $waitingIcon);
                let ppcesStats = responseData.rawData.data;

                if (ppcesStats.numOfPlanUpdates > 0) {


                    $($butDoUpdatePlanInfo).css('overflow', 'visible');
                    $($butDoUpdatePlanInfo).parent().css('overflow', 'visible');

                    $($butDoUpdatePlanInfo).addClass(MBA.RestViewCommon.CONST_CSS_CLASSES.bellNotification);

                    $($butDoUpdatePlanInfo).attr('data-count', ppcesStats.numOfPlanUpdates);

                    let tt = 'UPDATES ARE AVAILABLE! ' + toolTipOriginalDoUpdatePlanInfo;
                    $($butDoUpdatePlanInfo).attr('title', tt);
                } else {
                    $('.mba-cmd-tbar-bell-notification').remove();
                    $($butDoUpdatePlanInfo).removeClass(MBA.RestViewCommon.CONST_CSS_CLASSES.bellNotification);

                    $($butDoUpdatePlanInfo).removeClass(MBA.RestViewCommon.CONST_CSS_CLASSES.animationPulse);
                    $($butDoUpdatePlanInfo).attr('title', toolTipOriginalDoUpdatePlanInfo);
                }
                return;
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butDoUpdatePlanInfo, $waitingIcon);
                return;
            });

    };

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function gotoRecordSvcsForDos() {
        /* Date query string cleanup/conversion courtesey of: https://stackoverflow.com/a/35856320 */
        let $dos = $('#dos');
        let entitySelectionsObj = getClientAndPracSelections();
        let pvtUrlIn = '<%=caseloadSvcRecURL%>';
        if (entitySelectionsObj.selectionsOK == false) return;
        let pvtUrlOut = buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn);
        let url = pvtUrlOut + '&<%=Constants.PARM_DOS%>=' + $dos.val().replace(/(\d\d)\/(\d\d)\/(\d{4})/, "$3-$1-$2");
        $.spedmonWebUI.openURL(url, 0);
    }
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function gotoReviewAssessments() {
        let entitySelectionsObj = getClientAndPracSelections();
        let pvtUrlIn = '<%=assessmentSvcRecURL%>';
        if (entitySelectionsObj.selectionsOK == false) return;
        let pvtUrlOut = buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn);
        $.spedmonWebUI.openURL(pvtUrlOut, 0);
    }
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function gotoRecordSvcs() {
        let entitySelectionsObj = getClientAndPracSelections();
        let pvtUrlIn = '<%=svcRecURL%>';
        if (entitySelectionsObj.selectionsOK == false) return;
        let pvtUrlOut = buildPvtUrlWithClientPracSelections(entitySelectionsObj, pvtUrlIn);
        $.spedmonWebUI.openURL(pvtUrlOut, 0);
    }
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

/***********************************************************************************************************
 *
 *                                         PATIENT GROUP MANAGEMENT
 *
 ***********************************************************************************************************/


<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function launchGrpRestViewDia(e, grpUI) {

        /*************************************************************
         * launchGrpRestViewDia
         *
         * function which renders a rest view inside a dialog for
         * editing groups
         * ***********************************************************/

        /************************************************************************************************************
         * Groups Rest View
         * **********************************************************************************************************/
        let $grpDataManagementRows = null;
        let $grpRestViewCtrl = null;

        const PARM_NAME_CLIENT_ID = '<%=MBA.Constants.PARM_CLIENT_ID%>';
        const PARM_NAME_ACTIVE = '<%=MBA.Constants.PARM_ACTIVE%>';
        const PARM_NAME_PRAC_ID = '<%=MBA.Constants.PARM_PRACTITIONER_ID%>';
        const PARM_NAME_GROUP_ID = '<%=MBA.Constants.PARM_GROUP_ID%>';
        const PARM_NAME_TERM = '<%=MBA.Constants.PARM_SEARCH_TERM%>';

        function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

            let VALUE_CLIENT_ID                  = $('#' + PARM_NAME_CLIENT_ID).val();
            let VALUE_PRAC_ID                    = $('#' + PARM_NAME_PRAC_ID).val();
            let VALUE_GROUP_ID                   = grpUI.item.id;
            let VALUE_TERM                       = '';
            let VALUE_ACTIVE                     = '1';
          
            let NV_CLIENT_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
            let NV_PRAC_ID                    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
            let NV_GROUP_ID                   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_ID, VALUE_GROUP_ID);
            let NV_TERM                       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_TERM, VALUE_TERM);
            let NV_ACTIVE                     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

            /* Note: Don't use a loop here, keep it unrolled for performance reasons */

            $($gotoManageCalsAndBreaksCtrl).MBA_Link('requestDataParameterSetOrUpdate', NV_CLIENT_ID);

            $($grpRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
            $($grpRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
            $($grpRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_ID);
            $($grpRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TERM);
            $($grpRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

            $($grpRestViewCtrl).MBA_RestView('requestViewFromServer', 1);

        };


        function initGrpView() {
            
            let opts = {};
            opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
            opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
            opts.enableSortControls = true;
            opts.enableRowNumbers = true;
            opts.enableRowControls = true;
            opts.enableRowControlRecAddNew = false;
            opts.enableRowControlRecEdit = false;
            opts.enableRowControlRecDelete = false;

            opts.saveModeAddNew = 'inwindow';
            opts.baseUrlAddNew = '';
            opts.baseUrlAddNewHasParameters = true;

            opts.saveModeEdit = 'inwindow';
            opts.baseUrlEdit = '';
            opts.baseUrlEditHasParameters = true;

            opts.saveModeDelete = 'inline';
            opts.baseUrlDelete = '';
            opts.baseUrlDeleteHasParameters = false;

            opts.loadModeView = 'rest';
            opts.baseUrlView = '<%=Spedmon.PractitionerPatientGroupMembers.URL_REST_VIEW_BASE()%>';
            opts.baseUrlViewHasParameters = true;
            opts.defaultPageRowOrder = '<%=Spedmon.PractitionerPatientGroupMember.DEFAULT_PAGING_ORDER%>';

            opts.enableReports = false;
            opts.enableReportHtml = false;
            opts.enableReportXls = false;
            opts.enableReportPdf = false;

            /* Setup additional row controls */

            opts.additionalControlDefinitionsForBodyRows = new Map();

            opts.fieldDefinitions = [];

            opts.fieldDefinitions.push({
                name: 'id'
                , isRecID: true
                , saveable: false
                , saveUsing: 'recid'
            });

            opts.fieldDefinitions.push({
                name: 'name'
                , label: 'Patient Name'
                , toolTip: 'Patient Name'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'lastfirst'
                , saveUsing: ''
                , sortUsing: 'name'
            });

            opts.fieldDefinitions.push({
                name: 'dobStr'
                , label: 'Date Of<br>Birth'
                , toolTip: 'Date of Birth'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , saveUsing: ''
                , sortUsing: 'dobStr'
            });


            opts.fieldDefinitions.push({
                name: 'siteName'
                , label: 'Site'
                , toolTip: 'Site Name'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , saveUsing: ''
                , sortUsing: 'siteName'
            });

            opts.fieldDefinitions.push({
                name: 'minsIndStr'
                , label: 'Individual<br>Minutes'
                , toolTip: 'Individual Minutes'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , saveUsing: ''
                , sortUsing: 'minsIndStr'
            });

            opts.fieldDefinitions.push({
                name: 'minsGrpStr'
                , label: 'Group<br>Minutes'
                , toolTip: 'Group Minutes'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , saveUsing: ''
                , sortUsing: 'minsGrpStr'
            });

            opts.fieldDefinitions.push({
                name: 'patID'
                , label: 'Patient ID'
                , toolTip: 'Patient ID'
                , visible: false
                , editable: false
                , saveable: false
                , sortable: false
                , isRecID: false
                , dataType: 'hidden'
                , saveUsing: ''
                , sortUsing: 'patID'
            });


            /*###############################################################################################
                #
                #                                  Row hooks
                #
                ################################################################################################*/


            opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
                if (!rowData) return $newRow;

                return $newRow;
            };

            // convert Prac and Pat names to an anchor

            opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
                return $newCell;
            };

            /* Add delete functionality (couldn't use the rest view delete because we need a custom ajax parameter name for rec id) */
            opts.additionalControlDefinitionsForBodyRows.set('removePatFromGroup', {
                defType: 'userprovided'
                , name: 'removePatFromGroup'
                , toolTip: 'Remove Patient From Group'
                , cssClass: 'fas fa-trash-alt'
                , handlerFn: function (uiActionObj) {

                    // function to run if user clicks yes when asked to confirm delete
                    function onYes() {
                        // set up values for asmx method params
                        var $row     = $(uiActionObj.whatRow);
                        let groupID =  grpUI.item.id;
                        let pracID   = $('#' + PARM_NAME_PRAC_ID).val();
                        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
                        let patID    = uiActionObj.recordID;

                        // send ajax to approve the service reocrd
                        let reqUrl = '<%=Spedmon.PractitionerPatientGroupMembers.GEN_URL_ASMX_DELETE()%>'
                        let reqData = {};
                        reqData[PARM_NAME_ORG_ID]    = clientID;
                        reqData[PARM_NAME_OWNER_ID]  = pracID;
                        reqData[PARM_NAME_GRP_ID]    = groupID;
                        reqData[PARM_NAME_ENTITY_ID] = patID;
                        reqData = JSON.stringify(reqData);

                        // send ajax request
                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                            .then(responseData => {
                                $($grpRestViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                                $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                            })
                            .catch(responseData => {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            });
                    }

                    // launch confirm dialog
                    $.spedmonWebUI.dialogConfirm("Please Confirm", 'Are you sure you want to remove this patient from this group?'
                        , onYes, function () { });

                    return uiActionObj;
                }
                , initiallyHidden: false
            });


            /* Create the rest view */
            $($grpRestViewCtrl).MBA_RestView(opts);

        }


        /***********************************************************************************************
        * _addPatToGrp
        *
        * Send Ajax to add a selected patient to the group on patient select
        *
        * This is a closure function
        * *********************************************************************************************/
        function _addPatToGrp(patID, patName) {

            // set ajax params
            let groupID  = grpUI.item.id;
            let pracID   = $('#' + PARM_NAME_PRAC_ID).val();
            let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
            let strObj = [];

            // send ajax to approve the service reocrd
            let reqUrl = '<%=Spedmon.PractitionerPatientGroupMembers.GEN_URL_ASMX_SAVE()%>'
            let reqData = {};
            reqData[PARM_NAME_ORG_ID]     = clientID;
            reqData[PARM_NAME_OWNER_ID]   = pracID;
            reqData[PARM_NAME_GRP_ID]     = groupID;
            reqData[PARM_NAME_ENTITY_ID]  = patID;
            reqData['entityID_selection'] = patName;
            reqData['recID']              = '';
            reqData['saveType'] = 1;

            reqData = JSON.stringify(reqData);

            $($grpRestViewCtrl).MBA_RestView('showOverlayMessage', 'Adding the patient');
            // send ajax request
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {

                    let jsonData = JSON.parse(responseData.rawData.jsonData);
                    strObj.push({ id: jsonData.caseloadExpectedSvcEntryIdOut, patID: patID });

                    let getGrpDataReqUrl = '<%=Spedmon.PractitionerPatientGroups.GEN_URL_ASMX_VIEW_ENTITY()%>';
                    let getGrpDataReqData = JSON.stringify({
                        '<%=Constants.PARM_CLIENT_ID%>': clientID
                        , '<%=Constants.PARM_PRACTITIONER_ID%>': pracID
                        , '<%=Constants.PARM_REC_ID%>': groupID
                    });
                    $($grpRestViewCtrl).MBA_RestView('showOverlayMessage', 'Loading Group Data');
                    // send ajax request
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(getGrpDataReqUrl, getGrpDataReqData, null)
                        .then(responseData => {
                            let grpData = responseData.rawData.entity;
                            fnCreateServiceScheduled(grpData, strObj, $grpRestViewCtrl);
                            $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                        });
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                });
        }

        /***********************************************************************************************
        * Render elements and initiate dialog
        *
        * *********************************************************************************************/
        // variable to hold bs container and row col layout
        $grpDataManagementRows = $(
              '<div class="container-fluid mt-3">'

            +   '<div class="row">'
            +       '<div class="col-12 d-flex justify-content-center">'
            +           '<h4 class="' + GRP_NAME_ELEMENT_CLASS + '">' + grpUI.item.label + '</h4>'
            +       '</div>'
            +   '</div>'

            +   '<div class="row">'
            +       '<div class="col-12 d-flex">'
            +       '</div>'
            +   '</div>'

            +   '<div class="row mt-2">'
            +       '<div class="col-12">'
            +       '</div>'
            +   '</div>'

            + '</div>');

        // patient select which is then appended to the col-12  in the first row of the bs layout
        let $patLbl = $('<label class="mr-3">Add Patient to Group: </label>');
        let $patSel = $('<input name="patID" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');

        // rest view div which is then appended to the col-12 in the second row in bs layout
        $grpRestViewCtrl = $('<div></div>');

        $grpDataManagementRows.find('.row:nth-child(2) .col-12').append($patLbl).append($patSel);
        $grpDataManagementRows.find('.row:nth-child(3) .col-12').append($grpRestViewCtrl);

        // initiate rest view
        initGrpView();

        // create and render dialog
        $grpDataManagementRowsDia = $('<div></div>');

        $grpDataManagementRowsDia.append($grpDataManagementRows).dialog({
            width: $(window).width() / 1.2
            , height: $(window).height() / 1.2
            , resizable: true
            , modal: true
            , title: 'Group View'
            , show: {
                effect: 'fade'
              , direction: 'center'
              , complete: function () {
                    // call selectbox on pat selection
                    var patSelUrl = '<%=MBA.HttpApplication.createLink(Spedmon.Patients.URL_SVC_VIEW_SEL, true)%>';
                    var patSelNVP = [
                          { name: "clientid", value: $('#' + PARM_NAME_CLIENT_ID).val() }
                        , { name: "pracid", value: $('#' + PARM_NAME_PRAC_ID).val() }
                        , { name: "dos", value: "" }
                        , { name: "patdatasource", value: "0" }
                    ];

                  $patSel.spedmonSelectBox({ dataParmType: "DOM", singleSelectClearAfterSelection: true, selectAll: true, selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX), onSelect: function (event, ui) { _addPatToGrp(ui.item.id, ui.item.label); }, ajaxopts: { url: (patSelUrl), data: "", namevalues: (patSelNVP), getnamevaluesfn: null } });
                }
            }
            , hide: {
                  effect: 'slide'
                , direction: 'left'
            }
            , close: function (event, ui) { $grpDataManagementRows.remove(); }
        });

        $($grpDataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

        /*****************************************************
         * append buttons for top left of rest view headers
         * ***************************************************/

        /*************************************************** EDIT GROUP ********************************************************/

        // group edit icon and callback
        let $editGrpIcon = $('<i class="fas mba-rest-view fa-pencil-alt ml-2" title="Edit Group"></i>');

        $editGrpIcon.on("click", function () {
            // set ajax params

            let groupID  = grpUI.item.id;
            let pracID   = $('#' + PARM_NAME_PRAC_ID).val();
            let clientID = $('#' + PARM_NAME_CLIENT_ID).val();

            // send ajax to approve the service reocrd
            let getGrpDataReqUrl = '<%=Spedmon.PractitionerPatientGroups.GEN_URL_ASMX_VIEW_ENTITY()%>'
            let getGrpDataReqData = JSON.stringify({
                  '<%=Constants.PARM_CLIENT_ID%>'       : clientID
                , '<%=Constants.PARM_PRACTITIONER_ID%>' : pracID
                , '<%=Constants.PARM_REC_ID%>'          : groupID
            });

            // send ajax request
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(getGrpDataReqUrl, getGrpDataReqData, null)
                .then(responseData => {
                    //launchAddEditGrpDia(2, responseData.rawData.entity);
                    let $rows = $($grpRestViewCtrl).MBA_RestView('getCurrentRenderedBodyRows');
                    let strObj = [];
                    $rows.each(function () {
                        let $row = $(this);
                        let patID = $row.attr("data-mba-rest-view-rec-id");
                        strObj.push({ id: groupID, patID: patID });
                    });
                    fnManageNewOrExistingGrp(strObj, 2, groupID);
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                });
        });

        // append to rest view
        $grpRestViewCtrl.find('th.mba-rest-view.mba-rest-view-row-controls').append($editGrpIcon);

        /****************************************************************************************************************************/

        /************************************************ DELETE GROUP **************************************************************/

        // group delete icon and callback
        let $delGrpIcon = $('<i class="fas mba-rest-view fa-trash-alt ml-2" title="Delete Group"></i>');

        $delGrpIcon.on("click", function () {

            // function to run if user clicks yes when asked to confirm delete
            function onYes() {
                // set ajax params
                let groupID  = grpUI.item.id;
                let pracID   = $('#' + PARM_NAME_PRAC_ID).val();
                let clientID = $('#' + PARM_NAME_CLIENT_ID).val();

                // send ajax to approve the service reocrd
                let delGrpDataReqUrl = '<%=Spedmon.PractitionerPatientGroups.GEN_URL_ASMX_DELETE()%>'
                let delGrpDataReqData = JSON.stringify({
                      'organizationID': clientID
                    , 'ownerID'       : pracID
                    , 'groupID'       : groupID
                });

                // send ajax request
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(delGrpDataReqUrl, delGrpDataReqData, null)
                    .then(responseData => {
                        $grpDataManagementRowsDia.dialog('close'); // $grpDataManagementRowsDia is set to remove on dialog close
                        $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                    })
                    .catch(responseData => {
                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    });
            }

            // launch confirm dialog
            $.spedmonWebUI.dialogConfirm("Please Confirm", 'Are you sure you want to remove this group and its members?'
                , onYes, function () { });
        });

        $grpRestViewCtrl.find('th.mba-rest-view.mba-rest-view-row-controls').append($delGrpIcon);

    }
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

/************************************************************************************************************
 *
 *                                            CASELOAD MANAGEMENT
 *
 ************************************************************************************************************/
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
    function gotoViewEnteredSvcsForPat(uiActionObj) {

        
        let rowData = $(uiActionObj.whatRow).data(MBA.RestViewCommon.DATA_NAME_ROW_DATA);
        let sDateStr = rowData.startDateAssignedStr;
        let eDateStr = rowData.endDateStr;

        let dateRange = '';
        if ((sDateStr == '') && (eDateStr == '')) {
            dateRange = '';
        }
        else if ((sDateStr == '') && (eDateStr != '')) {
            dateRange = '';
        }
        else if ((sDateStr != '') && (eDateStr == '')) {
            dateRange = '';
        }
        else if ((sDateStr != '') && (eDateStr != '')) {
            dateRange = sDateStr + ' - ' + eDateStr;
        }
        else {
            dateRange = '';
        }

        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, uiActionObj.whatFieldNameValues['clientID']));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, uiActionObj.whatFieldNameValues['patID']));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_DATE_RANGE, dateRange));

        let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE_IN_WINDOW_BASE()%>', 1, parms);
        let newWindowName = 'viewsvcsenteredforpat' + uiActionObj.recordID;
        $($restViewCtrl).MBA_RestView("openWindow", {
              url: reqUrl
            , windowName: newWindowName
            , refreshView: false
        });
        return uiActionObj;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

      let VALUE_CLIENT_ID                  = $('#' + PARM_NAME_CLIENT_ID).val();
      let VALUE_PRAC_ID                    = $('#' + PARM_NAME_PRAC_ID).val();
      let VALUE_CASELOAD_GROUP_ID          = $('#' + PARM_NAME_CASELOAD_GROUP_ID).val();
      let VALUE_TERM                       = '';
      let VALUE_ACTIVE                     = '1';
      let VALUE_USE_MINS_PER_FREQ_ASSIGNED = $('#' + PARM_NAME_USE_MINS_PER_FREQ_ASSIGNED).val();
      let VALUE_DISABLE_COMPLIANCE_CALC    = $('#' + PARM_NAME_DISABLE_COMPLIANCE_CALC).val();

        
      let NV_CLIENT_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
      let NV_PRAC_ID                    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
      let NV_CASELOAD_GROUP_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CASELOAD_GROUP_ID, VALUE_CASELOAD_GROUP_ID);
      let NV_TERM                       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_TERM, VALUE_TERM);
      let NV_ACTIVE                     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
      let NV_USE_MINS_PER_FREQ_ASSIGNED = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_USE_MINS_PER_FREQ_ASSIGNED, VALUE_USE_MINS_PER_FREQ_ASSIGNED);
      let NV_REC_ID_EMPTY               = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REC_ID, "");
      let NV_DISABLE_COMPLIANCE_CALCS   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DISABLE_COMPLIANCE_CALC, VALUE_DISABLE_COMPLIANCE_CALC);

      /* Update manage calendar and breaks control with selected client id */

      $($gotoManageCalsAndBreaksCtrl).MBA_Link('requestDataParameterSetOrUpdate', NV_CLIENT_ID);

      /* Note: Don't use a loop here, keep it unrolled for performance reasons */

      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CASELOAD_GROUP_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TERM);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_USE_MINS_PER_FREQ_ASSIGNED);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DISABLE_COMPLIANCE_CALCS);
        
      /* We need these for the add new */

      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRAC_ID);
      
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PRAC_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_REC_ID_EMPTY);

      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PRAC_ID);

      $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function initView() {
        let opts = {};
        opts.sessionTimeOutUrl                  = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad                  = false; /*This is so we can set the initial filters */
        opts.enableSortControls                 = true;
        opts.enableRowNumbers                   = true;
        opts.enableRowControls                  = true;
        opts.enableRowControlRecAddNew          = true; 
        opts.enableRowControlRecEdit            = true; 
        opts.enableRowControlRecDelete          = true; 
        opts.enableRowControlShowAdditionalInfo = false;
        opts.enableRowControlMarkRow            = true;

        opts.positionUserDefinedControlsInBodyExisting = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

        opts.saveModeAddNew             = 'inwindow';
        opts.baseUrlAddNew              = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_USER_ALL_SAVE_NEW_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inwindow';
        opts.baseUrlEdit                = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_USER_ALL_EDIT_EXISTING_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;
        
        opts.loadModeView               = 'rest';
        opts.baseUrlView                = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters   = true;
        opts.defaultPageRowOrder        = '<%=Spedmon.PractitionerPatientCaseloadExpectedService.DEFAULT_PAGING_ORDER%>';

        opts.enableReports              = true;
        opts.enableReportHtml           = true;
        opts.enableReportXls            = true;
        opts.enableReportPdf            = false;
        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '1';

        /*###############################################################################################
          #
          #                            Additional Header Controls
          #
          ###############################################################################################*/
        

        /* ******************************************/
        /* ************ Delete Marked  **************/
        /* ******************************************/
        
        opts.additionalControlDefinitionsForHeadRows = new Map();
        opts.positionUserDefinedControlsInHead = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

        opts.additionalControlDefinitionsForHeadRows.set('deleteMarked', {
            defType: 'userprovided'
            , name: 'deleteMarked'
            , toolTip: 'Click here to remove all selected rows (plans) from my caseload.  Removing these plans will also remove any associated recurring schedules.  No other records or data related to the students will be deleted by removing these plans.'
            , cssClass: 'fa fa-trash-alt'
            , handlerFn: function (uiActionObj) {

                let entitySelectionsObj = getClientAndPracSelections();
                if (entitySelectionsObj.selectionsOK == false) return;
                let _recIDsArr = $($restViewCtrl).MBA_RestView('getMarkedRowsRecordIDs');
                if (_recIDsArr.length == 0) {
                    return uiActionObj;
                };
                let _recIDsStr = _recIDsArr.join();
                
                let _deleteMarkedRowsMsg = '<div class="alert alert-danger text-center">Are you sure you wish to remove all marked rows?<br>If you proceed all marked rows(plans) will be removed.<br>Removing these plans will also remove any associated recurring schedules.<br>No other records or data related to the students will be deleted by removing these rows.<br><strong>If you proceed this CANNOT be undone.</strong></div>';
                let _fnDeleteMarkedRowsCancel = function () {
                    fnResetRestViewValues(uiActionObj);
                    return;
                };
                let _fnDeleteMarkedRowsProceed = function () {
                    let reqURL = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_DELETE_BATCH_BASE()%>';
                    let reqDataObj = {};
                    reqDataObj[PARM_NAME_CLIENT_ID] = entitySelectionsObj[PARM_NAME_CLIENT_ID];
                    reqDataObj[PARM_NAME_PRAC_ID]   = entitySelectionsObj[PARM_NAME_PRAC_ID];
                    reqDataObj['<%=Spedmon.Constants.PARM_REC_ID_MULTI%>'] = _recIDsStr;
                    let reqDataJSON = JSON.stringify(reqDataObj);
                    $($restViewCtrl).MBA_RestView('showOverlayMessage', 'Deleting marked rows');
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
                        .then(responseData => {
                            fnResetRestViewValues(uiActionObj);
                            $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                            return;
                        })
                        .catch(responseData => {
                            $($restViewCtrl).MBA_RestView('hideOverlayMessage');
                            return;
                        });                                 
                }; /* _fnDeleteMarkedRowsProceed*/

                MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Delete Marked Rows?', _deleteMarkedRowsMsg, {}, _fnDeleteMarkedRowsProceed, _fnDeleteMarkedRowsCancel);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForHeadRows.set('usersGroup', {
            defType: 'userprovided'
            , name: 'usersGroup'
            , toolTip: 'Click here to see Patient Groups Management Screen'
            , cssClass: 'fa fa-users'
            , handlerFn: function (uiActionObj) {
                fnManageGroups(uiActionObj); 
            }
            , initiallyHidden: false
        });

        /*###############################################################################################
          #
          #                            Additional Info Field Definitions
          #
          ###############################################################################################*/

        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
            name: 'patName'
            , label: 'Patient Name'
            , toolTip: 'Patient Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'patName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patSSID'
            , label: 'SSID'
            , toolTip: 'Statewide Student Identifier'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patSSID'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Who is the case manager for this patient?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdCaseManagerName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'altFormat'
            , label: 'Alternate Formats'
            , toolTip: 'Accommodations'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'altFormat'
        });
        
        opts.additionalInfoFieldDefinitions.push({
            name: 'serviceDetails'
            , label: 'Additional Details'
            , toolTip: 'Additional information provided in SpEd files from district'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: ''
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patID'
            , label: 'SpEdCare Patient ID'
            , toolTip: 'Patient ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'patID'
        });

        /*###############################################################################################
          #
          #                             Additional info hooks
          #
          ################################################################################################*/

        opts.fnCreateAdditionalInfoCellValueAfter = function ($addInfoVal, rowData, additionalInfoFieldDefinition) {
            if (additionalInfoFieldDefinition.name == 'serviceDetails') {
                let svcDetailsObj = $.spedmonWebUI.generatePromisedServiceDetailsHTML(rowData.hasSvcDetailsStr, rowData.svcDetailsJSON, true, false);
                $addInfoVal = svcDetailsObj.svcDetailsHTML;
            }
            return $addInfoVal;
        };

        /*###############################################################################################
          #
          #                                  Field Definitions
          #
          ################################################################################################*/

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
              name: 'clientID'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'clientID'
        });

        opts.fieldDefinitions.push({
              name: 'pracID'
            , label: 'Practitioner ID'
            , toolTip: 'Practitioner ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'pracID'
        });

        opts.fieldDefinitions.push({
              name: 'patID'
            , label: 'Patient ID'
            , toolTip: 'Patient ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: 'patID'
        });

        opts.fieldDefinitions.push({
            name: 'schedulesExpired'
            , label: 'schedulesExpired'
            , toolTip: 'schedulesExpired'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'schedulesExpired'
            , sortUsing: 'schedulesExpired'
        });
        
        opts.fieldDefinitions.push({
              name: 'patName'
            , label: 'Student Last, First<br>DOB'
            , toolTip: 'Student last, first name and date of birth'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'patName'
        });

        /*
        opts.fieldDefinitions.push({
              name: 'dobStr'
            , label: 'DOB'
            , toolTip: 'Date of Birth'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'dob'
        });
        */

        opts.fieldDefinitions.push({
              name: 'siteName'
            , label: 'Site'
            , toolTip: 'Site Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteName'
        });

        opts.fieldDefinitions.push({
            name: 'planType'
            , label: 'Plan Type'
            , toolTip: 'Plan Type'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'plantype'
            , sortUsing: 'planType'
        });

    
        opts.fieldDefinitions.push({
              name: 'svcTrackingName'
            , label: 'Service Delivery Tracking'
            , toolTip: 'Tracking an IEP/IFSP plan, order, or service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'svcTrackingName'
        });

        opts.fieldDefinitions.push({
              name: 'startDateStr'
            , label: 'Plan<br>Start<br>Date'
            , toolTip: 'Plan Start Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
        });

        opts.fieldDefinitions.push({
              name: 'endDateStr'
            , label: 'Plan<br>End<br>Date'
            , toolTip: 'Plan End Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
        });

        opts.fieldDefinitions.push({
              name: 'numMinsExpected'
            , label: 'Minutes<br>Expected<br>To Date'
            , toolTip: 'Minutes expected per therapy/treatment session in IEP/IFSP'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numMinsExpected'
        });

        opts.fieldDefinitions.push({
              name: 'numMinsApplicable'
            , label: 'Minutes<br>Satisfied<br>To Date'
            , toolTip: 'Minutes recorded that can be applied towards service compliance'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numMinsApplicable'
        });

        opts.fieldDefinitions.push({
              name: 'numMinsDiff'
            , label: 'Minutes<br>Missing<br>To Date'
            , toolTip: 'Remaining minutes that may need to be recorded'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numMinsDiff'
        });

        opts.fieldDefinitions.push({
              name: 'pctExpectedApplicableStr'
            , label: 'Percentage<br>Satisfied<br>To Date'
            , toolTip: 'Percentage of minutes satisfied'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'percent'
            , sortUsing: 'pctExpectedApplicable'
        });

        opts.fieldDefinitions.push({
              name: 'groupID'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'groupID'
        });

        opts.fieldDefinitions.push({
              name: 'svcTrackingClass'
            , label: 'Service Tracking Class'
            , toolTip: 'Service Tracking Class'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'svcTrackingClass'
        });
       
        opts.fieldDefinitions.push({
              name: 'whatActionRequired'
            , label: 'What Action Required'
            , toolTip: 'What Action Required'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'whatActionRequired'
        });

        opts.fieldDefinitions.push({
            name: 'patGroupMembershipJSON'
            , label: 'Group membership'
            , toolTip: 'Group membership'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'jsondata'
        });

        /*###############################################################################################
          #
          #                                          Row hooks
          #
          ################################################################################################*/

        opts.fnCreateNewRowBefore = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            if (subsection === 103 && rowtype === 4) {
                rowCtrlDefs.forEach(function (def) {
                    if (def.name === 'recdeleteinlinestart') {
                        var initialHandler = def.handlerFn;

                        def.handlerFn = function (uiActionObj) {
                            var $btn = $(uiActionObj.whatElement);
                            if ($btn.closest('#restView').length > 0) {
                                return MBA.RestViewCommon.fnMarkRow(uiActionObj);
                            }

                            if (typeof initialHandler === 'function') {
                                return initialHandler(uiActionObj);
                            }
                        };
                    }
                });
            }

            return $newRow;
        };


        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if ((subsection === 103) && (rowtype === 4)) {

                let $checkBtn = $(MBA.RestViewCommon.fnFindRowControl($newRow, "markRow"));
                $checkBtn.hide();

                let $butDelStart = MBA.RestViewCommon.fnFindRowControl($newRow, 'recdeleteinlinestart'); 
                let $butManageGroupMembership = MBA.RestViewCommon.fnFindRowControl($newRow, 'managePatGroupMembership');
                let $icoManageGroupMembership = MBA.RestViewCommon.fnFindIconInControl($butManageGroupMembership);

                MBA.RestViewCommon.fnSetRowControlToolTip($butDelStart, 'Click here to remove this plan from my caseload.  Removing this plan will also remove my recurring scheduled services that are associated with the plan.  No other records or data related to this student will be deleted by removing this row.');
                
                if (rowData.schedulesExpired == true) {
                    let $butManageScheduledServices = MBA.RestViewCommon.fnFindRowControl($newRow, 'manageScheduledServices');
                    MBA.RestViewCommon.fnSetRowControlToolTip($butManageScheduledServices, 'Schedule has expired');
                    MBA.RestViewCommon.fnAnimateRowControlInfinite($butManageScheduledServices, 'heartbeat', true, false);
                }
                
                if (rowData.patGroupMembershipJSON == '[]') {
                    MBA.RestViewCommon.fnSetRowControlToolTip($butManageGroupMembership, 'No group assignments');
                }
                else {
                    let patGroupMembershipObjs = JSON.parse(rowData.patGroupMembershipJSON);

                    if (patGroupMembershipObjs.length >= 1) {
                        let patGroupNames = 'Assigned to';
                        patGroupMembershipObjs.forEach(function (patGroupMembershipObj) {
                            patGroupNames = patGroupNames + ' ' + patGroupMembershipObj.groupName;
                        });
                        $($icoManageGroupMembership).addClass('text-success');
                        MBA.RestViewCommon.fnSetRowControlToolTip($butManageGroupMembership, patGroupNames);
                    }
                }
            }
            return $newRow;
        };

        /*###############################################################################################
          #
          #                                         Cell hooks
          #
          ################################################################################################*/

        /* convert pat names to an anchor */

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'patName') {

                    if (((rowData.svcTrackingClass == 100) || (rowData.svcTrackingClass == 200))) {
                        $($newCellValue).attr('title', 'Review missing services');
                        $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                        $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
                        $($newCellValue).closest('a').on("click", function () {
                            let parms = [];
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, rowData.pracID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, rowData.patID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, rowData.startDateStr));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_END_DATE, rowData.endDateOrCurrentStr));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, '<%=Constants.SPED_ALL_SPED%>'));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, rowData.svcTrackingClass));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REF_SCREEN, '<%=Spedmon.MissingServicesTreatmentsForAPatient.REF_SCREEN_CASELOAD_GROUP%>'));

                            if (rowData.svcTrackingClass == 100) {
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, rowData.spEdServiceCode));
                            }

                            else if (rowData.svcTrackingClass == 200) {
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_GRP_SVC_CLS_NME_ID, rowData.groupSvcClassNameID));
                            }

                            let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_PAGE_MANAGE_BASE()%>', 1, parms);

                            let newWindowName = 'viewmissingtmtsvc-' + rowData.patID;
                            $($restViewCtrl).MBA_RestView("openWindow", {
                                url: reqUrl
                                , windowName: newWindowName
                                , refreshView: true
                            });
                        });
                    }
                    $($newCellValue).append('<br>' + '<sub>DOB : ' + rowData.dobStr + '</sub>');

                } /* patName*/

                else if (fieldDefinition.name === 'svcTrackingName') {
                    
                    let $minsPerFreqAndFreq = $('<sub>' + rowData.minsPerFreqAndSpEdFreqName + '</sub>')

                    if (rowData.svcTrackingClass == 100) {

                        if (rowData.hasSvcDetails == true) {
                            let svcDetailsObj = $.spedmonWebUI.generatePromisedServiceDetailsHTML(rowData.hasSvcDetailsStr, rowData.svcDetailsJSON, false, true);
                            $($minsPerFreqAndFreq).tipso({
                                speed: 200
                                , background: '#ffd60d'
                                , titleBackground: '#333333'
                                , color: 'black'
                                , titleColor: '#ffffff'
                                , titleContent: ''
                                , showArrow: true
                                , position: opts.instructionsPosition
                                , width: '50vw'
                                , maxWidth: '50vw'
                                , delay: 200
                                , hideDelay: 0
                                , animationIn: ''
                                , animationOut: ''
                                , offsetX: 0
                                , offsetY: 0
                                , tooltipHover: true
                                , content: svcDetailsObj.svcDetailsHTML
                                , ajaxContentUrl: null
                                , contentElementId: null
                                , useTitle: false
                                , templateEngineFunc: null
                                , onBeforeShow: null
                                , onShow: null
                                , onHide: null
                            });
                        }
                    }
                    $($newCellValue).append('<br>');
                    if (rowData.hasAssignedMin == true) {
                        let $minsPerFreqResponsible = $('<sub>' + rowData.minsPerFreqAssignedStr + ' Mins Out Of </sub>');
                        $($newCellValue).append($minsPerFreqResponsible);
                    }
                    $($newCellValue).append($minsPerFreqAndFreq);

                } /*svcTrackingName*/

                else if (fieldDefinition.name === 'startDateStr') {

                  if (rowData.hasAssignedStartDate == true) {
                      let $startDateResponsible = $('<sub>' + rowData.startDateAssignedStr + '</sub>');
                      $($newCellValue).append('<br>');
                      $($newCellValue).append($startDateResponsible);
                  }

                } /*startDateStr*/
            }

            /* Return cell new as required */
            return newCell;
        };

        /*###############################################################################################
          #
          #                             Additional Body Row Controls
          #
          ###############################################################################################*/

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* ******************************************/
        /* ********* Manage Groups Svcs **********/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('managePatGroupMembership', {
            defType: 'userprovided'
            , name: 'managePatGroupMembership'
            , toolTip: 'Click here to manage groups for this patient'
            , cssClass: 'fas fa-users'
            , handlerFn: function (uiActionObj) {
                return MBA.RestViewCommon.fnMarkRow(uiActionObj);
            }
            , initiallyHidden: false
        });

        /* ******************************************/
        /* ********* Manage Scheduled Svcs **********/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('manageScheduledServices', {
            defType: 'userprovided'
            , name: 'manageScheduledServices'
            , toolTip: 'Click here to manage scheduled services for this patient'
            , cssClass: 'fas fa-calendar-alt'
            , handlerFn: function (uiActionObj) {
                let cltid = uiActionObj.whatFieldNameValues['clientID'];
                let prcid = uiActionObj.whatFieldNameValues['pracID'];
                let pntid = uiActionObj.whatFieldNameValues['patID'];                
                let ppesid = uiActionObj.recordID;
                let schedulesExpired = MBA.ComponentCommon.fnFlagValueToTrueFalse(uiActionObj.whatFieldNameValues['schedulesExpired']);                
                openManagePracPatScheduledSvcMgmtScreen(cltid, prcid, pntid, ppesid, true, schedulesExpired);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* ******************************************/
        /* ********* Manage Patient Goals ***********/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('managePatientGoals', {
            defType: 'userprovided'
            , name: 'managePatientGoals'
            , toolTip: 'Click here to manage goals for this student'
            , cssClass: 'fa fa-university'
            , handlerFn: function (uiActionObj) {
                let cltid = uiActionObj.whatFieldNameValues['clientID'];
                let patid = uiActionObj.whatFieldNameValues['patID'];
                openPatientEditScreen(cltid, patid, 'tab-goals');                
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* ******************************************/
        /* ******** Manage Patient Record  **********/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('editPatientProfile', {
            defType: 'userprovided'
            , name: 'editPatientProfile'
            , toolTip: 'Click here to edit patient (student) profile'
            , cssClass: 'fa fa-user-edit'
            , handlerFn: function (uiActionObj) {
                let cltid = uiActionObj.whatFieldNameValues['clientID'];
                let patid = uiActionObj.whatFieldNameValues['patID'];
                openPatientEditScreen(cltid, patid, null);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* ******************************************/
        /* *********** View Svcs Entered ************/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('viewSvcsEnteredForPat', {
              defType: 'userprovided'
            , name: 'viewSvcsEnteredForPat'
            , toolTip: 'Click here to view services entered for this student (patient)'
            , cssClass: 'fas fa-eye'
            , handlerFn: function (uiActionObj) {
                return gotoViewEnteredSvcsForPat(uiActionObj);
            }
            , initiallyHidden: false
        });

        /* Tie into response */

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {

            let entitySelectionsObj = getClientAndPracSelections();

            if (entitySelectionsObj.selectionsOK == false) {
                expectedSvcStatsLoaded = false;
                return;                
            }

            $($cdeComplianceSummaryWidget).MBA_ActionItemPercentageBanner('getData');

            /* We only want to load once */

            if (expectedSvcStatsLoaded == false) {
                expectedSvcStatsLoaded = true;
                doGetExpectedServiceStats();                
            }

            fnResetRestViewValues(dataObj);

            return;
        };


        opts.fnOnRowMarked = function (uiActionObj, markedRows) {
            var $thead = uiActionObj.dataObj.thead;
            var rowCtrl = $(uiActionObj.whatElement).attr('data-mba-rest-view-ctrl-def-name'); // 'managePatGroupMembership' o 'recdeleteinlinestart'
            var $delHdr = MBA.RestViewCommon.fnFindHeaderControlInThead($thead, 'deleteMarked');
            var $grpHdr = MBA.RestViewCommon.fnFindHeaderControlInThead($thead, 'usersGroup');
            var $rows = $($restViewCtrl).MBA_RestView('getCurrentRenderedBodyRows');
            var anyMarked = markedRows.length > 0;                
            
            // Show/hide del vs. grp header
            if (rowCtrl === 'managePatGroupMembership') {
                anyMarked ? $delHdr.hide() : $delHdr.show();
            }
            else if (rowCtrl === 'recdeleteinlinestart') {
                anyMarked ? $grpHdr.hide() : $grpHdr.show();
            }

            // Animate just the active header icon
            var $activeHdr = (rowCtrl === 'recdeleteinlinestart' ? $delHdr : $grpHdr);
            MBA.RestViewCommon.fnAnimateRowControlInfinite($activeHdr, 'bounce', false, !anyMarked);

            // Add or remove the check to the grp or del icon
            $rows.each(function () {
                var $row = $(this);
                var marked = $row.attr('data-mba-rest-view-row-marked') === '1';
                var $ctrl = MBA.RestViewCommon.fnFindRowControl($row, rowCtrl);                
                if (marked) {
                    if (!$ctrl.find('.fa-check').length) {                        
                        $ctrl.append('<i class="fas fa-check fa-xs"></i>');
                    }
                } else {
                    $ctrl.find('.fa-check').remove();
                }
                var $grpIcon = $ctrl.find('i.fas.fa-users');
                $grpIcon.toggleClass('text-warning', marked);
            });            

            return uiActionObj;
        };        

        opts.fnMarkRow = function (uiActionObj) {
            return uiActionObj;
        }

        opts.getCurrentRenderedBodyRows = function (uiActionObj) {
            return uiActionObj;
        }

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

        /* Find delete and user group marked control and add an icon */

        let _$hdrCtrlDelMarked = $($restViewCtrl).MBA_RestView('findHeaderControl', 'deleteMarked');
        $(_$hdrCtrlDelMarked).append('<i class="fas fa-check fa-xs"></i>');
        let _$hdrCtrlGrpMarked = $($restViewCtrl).MBA_RestView('findHeaderControl', 'usersGroup');
        $(_$hdrCtrlGrpMarked).append('<i class="fas fa-check fa-xs"></i>');

        
        //MBA.RestViewCommon.fnSetHeaderControlToolTip(_$hdrCtrlDelMarked, 'Click here to remove all marked rows (plans) from my caseload.  Removing these plans will also remove any associated recurring schedules.  No other records or data related to the students will be deleted by removing these plans.');

    }

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 
    /***********************************************************************************************
     *
     *                         Add Patient to an Existing or New Group Inline
     *
     ***********************************************************************************************/

    function fnManageGroups(uiActionObj) {
        let entitySelectionsObj = getClientAndPracSelections();
        if (!entitySelectionsObj.selectionsOK) return;

        let rowCtrl = $(uiActionObj.whatElement).attr('data-mba-rest-view-ctrl-def-name');
        let $rows = $($restViewCtrl).MBA_RestView('getCurrentRenderedBodyRows');
        let pracID = entitySelectionsObj[PARM_NAME_PRAC_ID];
        let clientID = entitySelectionsObj[PARM_NAME_CLIENT_ID];

        let $container = $('<div>', {
            class: 'patient-manage-dialog-content'
        });

        let anyMarked = false;
        let selectedId = null;
        let strObj = [];
        let caseloadExpectedSvcIDJSON = [];


        let $patientInfoSection = $('<div>', {
            class: 'patient-info-section'
        });

        let $sectionTitle = $('<h3>', {
            class: 'section-title',
            text: 'Patient Information'
        });


        const $flex = $('<div>', {
            class: 'patients-flex-container'
        });

        let $grouplist = $('<div>', {
            id: 'grouplist',
            class: 'form-group'
        });


        $rows.each(function () {
            let $row = $(this);
            if ($row.attr('data-mba-rest-view-row-marked') === '1') {
                anyMarked = true;
                let data = $row.data(MBA.RestViewCommon.DATA_NAME_ROW_DATA);
                let list = JSON.parse(data.patGroupMembershipJSON) || [];

                strObj.push({ id: data.id, patID: data.patID });

                let $patientItem = $('<div>', {
                    class: 'patient-item'
                });

                let $patientName = $('<div>', {
                    class: 'patient-name'
                });

                let $checkIcon = $('<i>', {
                    class: 'far fa-check-circle fa-lg me-2',
                    'data-pat-id': data.patID
                });

                let $nameText = $('<span>', {
                    class: 'patient-name-text',
                    text: data.patName
                });

                $patientName.append($checkIcon, $nameText);


                let $tagContainer = $('<div>', {
                    class: 'tag-container'
                });

                if (list.length !== 0) {
                    list.forEach(function (grpmember) {
                        let $badgeWrapper = $('<div>', {
                            class: 'position-relative d-inline-block'
                        });

                        let $deleteIcon = $('<i>', {
                            class: 'fa fa-trash text-danger',
                            title: 'Remove patient from group'
                        }).on('click', function (e) {
                            e.stopPropagation();
                            function fnDeleteMemberFromGroup() {
                                let entitySelectionsObj = getClientAndPracSelections();
                                if (entitySelectionsObj.selectionsOK == false) return;

                                let groupID = grpmember.id;
                                let delGrpDataReqUrl = '<%=Spedmon.PractitionerPatientGroupMembers.GEN_URL_ASMX_DELETE()%>'
                                let delGrpDataReqData = JSON.stringify({
                                    'organizationID': clientID,
                                    'ownerID': pracID,
                                    'groupID': groupID,
                                    'entityID': data.patID
                                });
                                
                                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(delGrpDataReqUrl, delGrpDataReqData, null)
                                    .then(responseData => {
                                        $badgeWrapper.remove();
                                        //$($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                                        return;
                                    })
                                    .catch(responseData => {
                                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                                        return;
                                    });
                            }
                            $.spedmonWebUI.dialogConfirm("Please Confirm", 'Are you sure you want to remove this patient from this group?', fnDeleteMemberFromGroup, function () { });
                        });

                        let $badge = $('<span>', {
                            class: 'group-tag',
                            text: grpmember.groupName
                        });

                        $badgeWrapper.append($deleteIcon, $badge);
                        $tagContainer.append($badgeWrapper);
                    });
                }

                $patientItem.append($patientName, $tagContainer);
                $flex.append($patientItem);
            }
        });


        let $selectSection = $('<div>', {
            class: 'select-section'
        });

        let $selectContainer = $('<div>', {
            class: 'select-container'
        });


        let $grpSel = $('<input>', {
            id: 'groupID',
            name: 'groupID',
            title: 'Select Patient Group To Manage',
            class: 'form-control group-select',
            type: 'text'
        });

        let $btnAddNew = $('<button>', {
            class: 'btn btn-add-new',
            type: 'button'
        }).append('<i class="fas fa-plus"></i>');

        let $badgeNew = $('<span>', {
            class: 'new-badge',
            text: 'Add New'
        });

        $btnAddNew.append($badgeNew);
        $selectContainer.append($grpSel, $btnAddNew);
        $selectSection.append($selectContainer);


        var patSelNVP = [
            { name: "clientid", value: clientID },
            { name: "pracid", value: pracID },
            { name: "term", value: "" }
        ];

        let url = '<%=Spedmon.PractitionerPatientGroups.GEN_URL_VIEW_SEL_BY_CLIENT_PRAC()%>';
        
        $grpSel.spedmonSelectBox({
            dataParmType: "DOM",
            singleSelectClearAfterSelection: true,
            selectAll: true,
            selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),
            onSelect: function (event, ui) {
                if (strObj.length > 0) {
                    fnGroupAddMembersAndServices(event, ui, strObj);
                    $container.dialog('close');
                } else {
                    $container.dialog('close');
                    launchGrpRestViewDia(event, ui);
                }
            },
            ajaxopts: { url: url, data: "", namevalues: patSelNVP, getnamevaluesfn: null }
        });

        if (!anyMarked) {
            $patientInfoSection.append(
                $('<p>', {
                    html: '<em>No patients are currently selected.</em>'
                })
            );
        } else {
            $patientInfoSection.append($sectionTitle, $flex);
        }

        $($btnAddNew).on('click', function () {
            fnManageNewOrExistingGrp(strObj, 1);
            $container.dialog('close');
        });

        $container.append($patientInfoSection, $selectSection, $grouplist);        

        $container.dialog({
            width: $(window).width() / 2,
            height: $(window).height() / 2,
            resizable: true,
            modal: true,
            title: 'Select Patient Group To Manage',
            buttons: {},
            open: function () {
                let $dialog = $(this).closest('.ui-dialog');
                $dialog.addClass('patient-dialog');
                $dialog.find('.ui-dialog-titlebar-close').html('×');
            },
            close: function () {                
                fnResetRestViewValues(uiActionObj);
                $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                $(this).remove();
            }
        });

        return uiActionObj;
    }

    <%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 

    function fnResetRestViewValues(param) {

        var dataObj = param.dataObj || param;
        $($restViewCtrl).MBA_RestView('unMarkMarkedRows');

        var $thead = dataObj.thead;
        var $delHdr = MBA.RestViewCommon.fnFindHeaderControlInThead($thead, 'deleteMarked');
        var $grpHdr = MBA.RestViewCommon.fnFindHeaderControlInThead($thead, 'usersGroup');

        $delHdr.show();
        $grpHdr.show();
        MBA.RestViewCommon.fnAnimateRowControlInfinite($delHdr, 'bounce', true);
        MBA.RestViewCommon.fnAnimateRowControlInfinite($grpHdr, 'bounce', true);

        var controlNames = ['managePatGroupMembership', 'recdeleteinlinestart'];
        var $rows = $($restViewCtrl).MBA_RestView('getCurrentRenderedBodyRows');

        $rows.each(function () {
            var $row = $(this);
            controlNames.forEach(function (ctrlName) {
                var $ctrl = MBA.RestViewCommon.fnFindRowControl($row, ctrlName);

                $ctrl.find('.fa-check').remove();

                $ctrl.find('i.fas.fa-users')
                    .removeClass('text-warning');
            });
        });
    }

 <%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 

    function fnCreateServiceScheduled(grpData, strObj, $restViewActive) {
        let pracID = $('#' + PARM_NAME_PRAC_ID).val();
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        let data = grpData;
        let dataJSON = JSON.stringify(strObj);

        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = clientID;
        reqDataObj[PARM_NAME_PRAC_ID] = pracID;
        reqDataObj["patselectedjson"] = dataJSON;
        reqDataObj["savetype"] = "1";
        reqDataObj["caseloadgrpid"] = data.id;
        reqDataObj["recid"] = "";
        reqDataObj["recurring"] = data.recurring;
        reqDataObj["starttime"] = "";
        reqDataObj["startdate"] = data.startDateYMD;
        reqDataObj["enddate"] = data.endDateYMD;
        reqDataObj["svcnameslistdatasourceid"] = data.svcNamesListDataSourceID;
        reqDataObj["viatelehealth"] = data.viaTeleHealth;
        reqDataObj["nameid"] = data.nameID;
        reqDataObj["nummins"] = data.numMins;
        reqDataObj["mon"] = data.mon;
        reqDataObj["tue"] = data.tue;
        reqDataObj["wed"] = data.wed;
        reqDataObj["thu"] = data.thu;
        reqDataObj["fri"] = data.fri;
        reqDataObj["monstarttime"] = data.monStartTimeStr;
        reqDataObj["tuestarttime"] = data.tueStartTimeStr;
        reqDataObj["wedstarttime"] = data.wedStartTimeStr;
        reqDataObj["thustarttime"] = data.thuStartTimeStr;
        reqDataObj["fristarttime"] = data.friStartTimeStr;
        reqDataObj["notes"] = data.notes;
        
        let reqUrl = '<%=Spedmon.PractitionerPatientScheduledServices.URL_SVC_SAVE_BASE_MULTIPLE()%>';
        let reqDataJSON = JSON.stringify(reqDataObj);

        $($restViewActive).MBA_RestView('showOverlayMessage', 'Creating Schedule Service');

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
            .then(responseData => {
                $($restViewActive).MBA_RestView('unMarkMarkedRows');
                $($restViewActive).MBA_RestView('refreshCurrentViewFromServer');
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

 <%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 

    function fnAddPatientToGroup(grpid, strObj, grpData) {
        let groupID = grpid;
        let pracID = $('#' + PARM_NAME_PRAC_ID).val();
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        let dataStr = JSON.stringify(strObj);

        // send ajax to approve the service record
        let reqUrl = '<%=Spedmon.PractitionerPatientGroupMembers.GEN_URL_ASMX_SAVE_ALL()%>';
        let reqData = {};
        reqData[PARM_NAME_CLIENT_ID] = clientID;
        reqData[PARM_NAME_PRAC_ID] = pracID;
        reqData["groupid"] = groupID;
        reqData["patselectedjson"] = dataStr;

        reqData = JSON.stringify(reqData);
        $($restViewCtrl).MBA_RestView('showOverlayMessage', 'Saving marked patients');

        // send ajax request
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                fnCreateServiceScheduled(grpData, strObj, $restViewCtrl);
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                $($restViewCtrl).MBA_RestView('hideOverlayMessage');
            });

    }

 <%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 

    function fnGroupAddMembersAndServices(event, ui, strObj) {
        
        event.stopPropagation();        
        let groupID = ui.item.id;
        let pracID = $('#' + PARM_NAME_PRAC_ID).val();
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        
        // send ajax to approve the service reocrd
        let getGrpDataReqUrl = '<%=Spedmon.PractitionerPatientGroups.GEN_URL_ASMX_VIEW_ENTITY()%>'
        let getGrpDataReqData = JSON.stringify({
                  '<%=Constants.PARM_CLIENT_ID%>'       : clientID
                , '<%=Constants.PARM_PRACTITIONER_ID%>' : pracID
            , '<%=Constants.PARM_REC_ID%>': groupID
        });

        $($restViewCtrl).MBA_RestView('showOverlayMessage', 'Loading Group Data');

        // send ajax request
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(getGrpDataReqUrl, getGrpDataReqData, null)
            .then(responseData => {
                let grpData = responseData.rawData.entity;
                fnAddPatientToGroup(groupID, strObj, grpData)
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }    

 <%/*-------------------------------------------------------------------------------------------------------------------------------*/%> 

    function fnManageNewOrExistingGrp(strObj, savetype, recid=null) {
        let entitySelectionsObj = getClientAndPracSelections();
        if (!entitySelectionsObj.selectionsOK) return;

        let cltid = entitySelectionsObj[PARM_NAME_CLIENT_ID];
        let prcid = entitySelectionsObj[PARM_NAME_PRAC_ID];
        let patids = strObj;
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, cltid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, prcid));

        if (patids && patids.length > 0) {
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject("patIdsJSON", JSON.stringify(patids)));
        }

        if (savetype == '<%=Spedmon.Constants.SAVE_TYPE_NEW%>') {
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_SAVE_TYPE%>', '<%=Spedmon.Constants.SAVE_TYPE_NEW%>'));
        } else {            
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_SAVE_TYPE%>', '<%=Spedmon.Constants.SAVE_TYPE_EDIT%>'));            
        }
        
        if (recid && savetype == '<%=Spedmon.Constants.SAVE_TYPE_EDIT%>') {
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_REC_ID%>', recid));
        }

        let reqUrl = MBA.ComponentCommon.fnBuildUrl(
            '<%= Spedmon.PractitionerPatientGroups.GEN_URL_SCH_SVC_GROUP_DATA()%>',
            true,
            parms
        );

        MBA.RestViewCommon.fnOpenWindow($($restViewCtrl), reqUrl, "Manage Group", true);
    }


/***********************************************************************************************
 *
 *                                     CDE Compliance
 *
 ***********************************************************************************************/

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function initCdeComplianceSummaryWidget() {
        let opts = {};
        opts.showHeader = false;
        opts.hideStatusSectionWhenNotInUse = true;
        opts.containerNoPadding = true;
        opts.containerNoBoxShadow = true;
        opts.containerNoBorder = true;
        opts.label = 'CDE Implementation';
        opts.bannerTitle = 'CDE Implementation';
        opts.minutesProvidedLabel = 'Minutes Provided';
        opts.minutesExpectedLabel = 'Minutes Expected';
        opts.urlSessionExpiredLink = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestDataUrlBase = '<%=Spedmon.CdeComplianceCommon.WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC()%>';
        opts.requestDataFieldNames = [PARM_NAME_CLIENT_ID, PARM_NAME_PRAC_ID, PARM_NAME_USE_MINS_PER_FREQ_ASSIGNED];
        opts.instructionsEnabled = false;
        opts.fnGenerateTitleAttributeText = function (progressDataObj) {
            return 'All patients on my caseload where a CALPADS service has been assigned\n' +
                progressDataObj.value + '% of expected minutes to date have been provided.\n' +
                'Total number of minutes satisfied to date / expected to date : ' +
                progressDataObj.additionalData2 + ' / ' + progressDataObj.additionalData1;
        };

        $($cdeComplianceSummaryWidget).MBA_ActionItemPercentageBanner(opts);
    }
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

/***********************************************************************************************
 *
 *                            CALPAD Service Code Preferences
 *
 ***********************************************************************************************/

   function initCalpadCodePrefs() {
      MBA.PractitionerSpedSvcsMgmt.initWoptsIn({
            sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlAddNew: '<%=Spedmon.PractitionerPreferenceSpedServices.GEN_URL_ASMX_SAVE()%>'
            , baseUrlDelete: '<%=Spedmon.PractitionerPreferenceSpedServices.GEN_URL_ASMX_DELETE()%>'
            , baseUrlView: '<%=Spedmon.PractitionerPreferenceSpedServices.URL_REST_VIEW_BASE()%>'
            , codeNameOptsBaseUrl: '<%= Spedmon.SpEdServices.URL_VIEW_SEL_BASE() %>'
          }
            , '#dialgMgmSvcResponsibilitiesRestView'
            , '#dialgMgmSvcResponsibilitiesRestViewContainer'

            , '#clientid'
            , '#pracid'

            , PARM_NAME_CLIENT_ID
            , PARM_NAME_PRAC_ID
      );
    };

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

/***********************************************************************************************
 *
 *                           Data Update and Document Ready 
 *
 ***********************************************************************************************/

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
    function updateCaseloadViewAndCdeComplianceWidgetData(e) {
        let entitySelectionsObj = getClientAndPracSelections();
        if (entitySelectionsObj.selectionsOK == false) return;
        updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        return;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    $(window).on('load', function () {

        expectedSvcStatsLoaded = false;

        $cdeComplianceSummaryWidget     = $('#cdecompliancesummary');
        $dataManagementRows             = $('#dataManagementRows');
        $restViewCtrl                   = $('#restView');
        $gotoManageCalsAndBreaksCtrl    = $('#gotomanagecalsandbreaks');
        $butDoUpdatePlanInfo            = $('#butDoUpdatePlanInfo');
        toolTipOriginalDoUpdatePlanInfo = $($butDoUpdatePlanInfo).attr('title');

        initCdeComplianceSummaryWidget();
        initView();
        initCalpadCodePrefs();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
          let whatCtrlID = $(e.target).attr('id');
          if (whatCtrlID == 'groupid') return; /* We do not want to update if the user is managing a patient group */           
          updateCaseloadViewAndCdeComplianceWidgetData(e);          
        });

        updateCaseloadViewAndCdeComplianceWidgetData(null);
    });
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

</script>

