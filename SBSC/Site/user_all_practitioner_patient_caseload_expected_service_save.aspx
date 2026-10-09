<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_caseload_expected_service_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientCaseloadExpectedServiceSave" %>

<%//##################################################################################################################%>
<%//#                                                Dialogs   %>
<%//##################################################################################################################%>

<div id="dialgMgmSvcResponsibilitiesRestViewContainer" title="<%=Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTitle%>" class="d-none">

  <div class="alert alert-success">
  <%=Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportInstructions%>
  </div>
  
  <div id="dialgMgmSvcResponsibilitiesRestView"></div>
</div>

<%if (clientAndPracAreOK == true){%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="practitioner_patient_caseload_expected_services.asmx/save" useBootstrapFluid="true" runat="server">

  <%//-----------------------------------------------------------------------------%>
  <%// Select Student %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSelectPatient
    ID                    = "selectPatient" 
    rowLabel              = "Student" 
    preSelectedDataSource = "ALL_PATIENTS"
    showEditSelected      = "true"
    showAddNew            = "true"
    runat                 = "server">
  </Spedmon:DataEntryRowSelectPatient>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Select Service Tracking Class %>
  <%//-----------------------------------------------------------------------------%>
 
  <Spedmon:DataEntryRow id="selectServiceTrackingClass" rowLabel="Tracking Service Delivery<br>Based On" runat="server">
    <Spedmon:DataEntryBoxSelect ID="svctrackingclass" name="svctrackingclass" label="Service Tracking Type" title="Select what you are tracking" fireSpedmonInput="true" runat="server" />
  </Spedmon:DataEntryRow>

  <%//-----------------------------------------------------------------------------%>
  <%// Select SpEd Plan, Order, or Service %>
  <%//-----------------------------------------------------------------------------%>
 
  <Spedmon:DataEntryRow id="selectPlanOrderOrService" rowLabel="Select Plan, Order, or Service" runat="server">

      <%/*-------------- If we are tracking by SpEd plan these options are displayed  --------------*/%>
      <%/* doManageCalpadCodePrefs()*/%>

      <span id="spedserviceoptions">
        <p class="alert alert-light m-0 p-0 mb-4" style="line-height:1.3em;">
        Please note that plans and service codes are limited to either the codes you entered in <Spedmon:DataEntryButton ID="butDoManageCalpadPrefs" style="LINK" size="SMALL" cssClass="m-0 p-0" onclick="doManageCalpadCodePrefs()" runat="server" /> <%/*Note: Label and title set in code behind*/%> or codes associated with your practice family.
        If you have not entered any codes then the practice family codes are used.  If you are unable to find a particular plan for the selected student please uncheck the Show Current Plans Only? option and try again.
        If you are still unable to find a plan then it is likely we have not received this plan in your districts student data updates and you can manually enter the plan data by selecting the desired service code.
        </p>          

        <Spedmon:CheckBox ID="showcurrentonly" name="showcurrentonly" title="Show Current Plans Only?" labelIsSpan="true" inlineLabel="Current Plans Only?" inlineLabelCss="mr-2" value="true" runat="server" />
        <br /><br />
        <Spedmon:ComboBox ID="promisedserviceid" name="promisedserviceid" onSelect="onPromisedServiceSelection(event, ui);" displayInline="true" inlineLabel="SpEd Service" labelIsSpan="true" inlineLabelCss="mr-2" title="Select Plan from IEP" dataPrivate="true" dataParms="[{id:'clientid'},{id:'pracid'},{id:'patid'},{id:'showcurrentonly'}]" dataURL="practitioner_patient_caseload_expected_services.asmx/viewSelSpEdPlansAndSpEdSvcCodes" runat="server" />
        <Spedmon:HiddenInput ID="spedservicecode" name="spedservicecode" title="spedservicecode" runat="server" />
                        
      </span>
      
      <%/*-------------- If we are tracking by orp document these options are displayed  --------------*/%>
      
      <span id="orpdocoptions">

        <Spedmon:ComboBox ID="orpdocid" name="orpdocid" onSelect="onOrpDocSelection(event, ui);" displayInline="true" inlineLabel="Order or Prescription" labelIsSpan="true" inlineLabelCss="mr-2" title="Order" dataPrivate="true" dataParms="[{id:'clientid'},{id:'pracid'},{id:'patid'}]" dataURL="orp_documents.asmx/viewSelOnlyOrdersAndProfiles" runat="server" />

        <Spedmon:DataEntryButton 
          ID                 = "doAddOrpDoc" 
          faIcon             = "fas fa-plus mba-rest-view mba-rest-view-ctrl-icon"
          onclick            = "openAddNewOrderScreen();"             
          iconOnly           = "true"
          assignBsCssClasses = "false"     
          title              = "Click here to add a new order"
          runat              = "server" />

        <Spedmon:DataEntryButton 
          ID                 = "doEditOrpDoc" 
          faIcon              = "fas fa-pencil-alt mba-rest-view mba-rest-view-ctrl-icon"
          onclick             = "openEditOrderScreen();"             
          iconOnly            = "true"
          assignBsCssClasses  = "false"     
          title               = "Click here to edit order"
          runat               = "server" />

      </span>

      <%/*-------------- If we are tracking by service selection these options are displayed  --------------*/%>

      <span id="nameidopts">
        
        <Spedmon:HiddenInput ID="dos"               name="dos"                title="dos"               runat ="server"/>
        <Spedmon:HiddenInput ID="isiep"             name ="isiep"             title="isiep"             runat ="server" />
        <Spedmon:HiddenInput ID="altmodalitynameid" name ="altmodalitynameid" title="altmodalitynameid" runat ="server" />
        
        <Spedmon:DataEntryBoxSelect ID="svcnameslistdatasourceid" name="svcnameslistdatasourceid" label="Plan Type" title="Select what type of plan this service is part of" fireSpedmonInput="true" runat="server" />
        
        <Spedmon:SelectYesOrNo ID="viatelehealth" name="viatelehealth" title="Will this service be delivered primarily via Telehealth?" runat="server" />
                
        <Spedmon:DataEntryRowSelectService 
          ID                                = "selectService" 
          rowLabel                          = "Service?" 
          dataEntryRowRenderAs              = "FIELD"            
          promptForAdditionalServiceDetails = "false"      
          selectCtrlOnSelect                = "onSvcNameIDSelection(event, ui);"
          runat                             = "server">  
        </Spedmon:DataEntryRowSelectService>
              
      </span> <!-- nameidopts -->

      <Spedmon:DataEntryButton 
        ID                  = "butDoClearCurSel" 
        faIcon              = "fas fa-times mba-rest-view mba-rest-view-ctrl-icon caseload-remove-svc-icon"
        assignBsCssClasses  = "false"
        iconOnly            = "true"
        onclick             = "clearServiceTermValues()"             
        title               = "Click here to clear current selection"
        runat               = "server" />

  </Spedmon:DataEntryRow>
      
  <%//-----------------------------------------------------------------------------%>
  <%// Start and End Date, Freq and Mins Per Freq %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow id="selectServiceTerms" rowLabel="Dates, Frequency, and Duration" runat="server">
    <Spedmon:DataEntryBoxDate ID="startdate" name="startdate" label="Plan Start Date" runat="server" />
    <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" label="Plan End Date" runat="server" />      
    <Spedmon:ComboBox ID="spedfreqcode" name="spedfreqcode" title="Plan Frequency" dataPrivate="true" dataURL="sped_service_frequencies.asmx/viewSel" runat="server" displayInline="true" inlineLabel="Frequency" labelIsSpan="true" inlineLabelCss="mr-2" />
    <Spedmon:DataEntryBoxNumber ID="minsperfreq" name="minsperfreq" min="0" label="Duration" size="4" runat="server" />  
    <br />
    <Spedmon:DataEntryBoxDate ID="startdateassigned" name="startdateassigned" required="false" label="Start Date I Am Responsible For" size="13" runat="server" />
    <Spedmon:DataEntryBoxNumber ID="minsperfreqassigned" min="0" name="minsperfreqassigned" required="false" label="Duration I Am Responsible For" size="13" runat="server" />
    <Spedmon:HiddenInput ID="userprovidedsvcterms" name="userprovidedsvcterms" title="userprovidedsvcterms" runat="server"/>

  </Spedmon:DataEntryRow>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Additional info about plan  %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow id="additionalInfo" rowLabel="Additional Info" runat="server">
    <div></div>
    <div id="svcdetails">

    </div>     
  </Spedmon:DataEntryRow>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Related Scheduled Services  %>
  <%//-----------------------------------------------------------------------------%>
  
  <Spedmon:DataEntryRow id="relatedScheduledServices" rowLabel="Related Scheduled Services" runat="server">
    <Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" noSubmit="true" runat="server" />
    <Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid" title="practitionerpatientcaseloadexpectedserviceid" runat="server" />
    <div id="restViewPPSS"></div>
  </Spedmon:DataEntryRow>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Save or Edit %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit" 
    editDelManageLink                = "caseloadandgroupmgmtlink"
    runat                            = "server"> 

    <Spedmon:HiddenInput    ID="clientid"                  name="clientid"                  title="clientid"                  runat="server" />
    <Spedmon:HiddenInput    ID="pracid"                    name="pracid"                    title="pracid"                    runat="server" />
    <Spedmon:HiddenInput    ID="hassvcdetails"             name="hassvcdetails"             title="hassvcdetails"             runat="server" />
    <Spedmon:HiddenTextArea ID="svcdetailsjson"            name="svcdetailsjson"            title="svcdetailsjson"            runat="server" />
      
  </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">
    let $clientid                  = null;
    let $pracid                    = null;
    let $patid                     = null;
    let $promisedserviceid         = null;
    let $svctrackingclass          = null;
    let $spedservicecode           = null;
    let $orpdocid                  = null;
    let $nameid                    = null;
    let $spedfreqcode              = null;
    let $startdate                 = null;
    let $enddate                   = null;
    let $minsperfreq               = null;
    let $startdateassigned         = null;
    let $minsperfreqassigned       = null;
    let $userprovidedsvcterms      = null;
    let $hassvcdetails             = null;
    let $svcdetailsjson            = null;
    let $divSvcDetailsHTML         = null;
    let $spedServiceOptions        = null;
    let $orpDocOptions             = null;
    let $nameIDOptions             = null;    

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function doManageCalpadCodePrefs() {
        MBA.PractitionerSpedSvcsMgmt.openDialg();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function openPatientEditScreen (patScreenTabID) {
        let clientid = $($clientid).val();
        if (!clientid) return;
        let patid = $($patid).val();
        if (!patid) return;
        let urlBase = '<%=patEditUrlBase%>' + patid;
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_TAB_TO_OPEN%>', patScreenTabID));        
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);                
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function openAddNewOrderScreen() {
        let patid = $($patid).val();
        if (!patid) return;
        $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null, null, null, patid, null, null);
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function openEditOrderScreen() {
        let patid = $($patid).val();
        if (!patid) return;
        let recID = $($orpdocid).val();
        if (!recID || recID == 0) {
            return;
        }
        let reqUrl = '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>' + recID;
        var fnEntryTest = function () { return true; };
        var fnExitTest = function () { return true; };
        var fnResume = function () { return true; };

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , reqUrl
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for you to finish editing order');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function generatePromisedServiceDetailsHTML (hasSvcDetailsStr, svcDetailsJSON) {
        let svcDetailsObj = $.spedmonWebUI.generatePromisedServiceDetailsHTML(hasSvcDetailsStr, svcDetailsJSON, true, false);
        return svcDetailsObj;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearSpEdServiceSelection() {
        $($promisedserviceid).spedmonSelectBox_clear();
        $($spedservicecode).val('');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearOrpDocSelection() {
        $($orpdocid).spedmonSelectBox_clear();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearSpEdFreqCode() {
        $($spedfreqcode).spedmonSelectBox_clear();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearSvcNameIDSelection() {
        $($nameid).spedmonSelectBox_clear();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function updateSvcDetailsHTML() {
        let hasSvcDetails = $($hassvcdetails).val();
        let svcDetailsJSON = $($svcdetailsjson).val();
        
        let svcDetailsObj = generatePromisedServiceDetailsHTML(hasSvcDetails, svcDetailsJSON);

        $($divSvcDetailsHTML).children().remove();

        $($divSvcDetailsHTML).append(svcDetailsObj.svcDetailsHTML);
        if (svcDetailsObj.numRowsCtr > 1) {
            let $addInfoLbl = $('#additionalInfo').find('div.ui-spedmon-data-entry-col-label').first();
            let $addInfoInstructions = $('<p>Please note that this plan has multiple delivery details.  If you are not responsible for all of the minutes shown above you can click one of the buttons in the minutes column to select the portion of the plan you are responsible for.  SpEdCare will update the minutes shown above.</p>');
            $($addInfoLbl).append($addInfoInstructions);

            $($divSvcDetailsHTML).find('td.svc-detail-duration')
                .wrapInner('<button type="button" class="btn btn-primary btn-sm" title="Click here to select the duration I am responsible for"></button>')
                .on('click', function (e) {
                    let numMins = $(this).text();
                    $($minsperfreqassigned).MBA_DataEntryBox('setValue', numMins);
                });
        }
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function lockServiceTermValues() {        
        $($spedfreqcode).spedmonSelectBox_disable();
        $($minsperfreq).MBA_DataEntryBox('lock');
        $($startdate).MBA_DataEntryBox('lock');
        $($enddate).MBA_DataEntryBox('lock');
        $($userprovidedsvcterms).val('N');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function unLockServiceTermValues() {
        $($spedfreqcode).spedmonSelectBox_enable();
        $($minsperfreq).MBA_DataEntryBox('unlock');
        $($startdate).MBA_DataEntryBox('unlock');
        $($enddate).MBA_DataEntryBox('unlock');
        $($userprovidedsvcterms).val('Y');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function setServiceTermValues (spEdFreqCode, spEdFreqName, minsPerFreq, startDate, endDate, hasSvcDetails, svcDetailsJSON, lockTerms) {
        $($spedfreqcode).val(spEdFreqCode);
        $('#spedfreqcode_selection').val(spEdFreqName);
        $($minsperfreq).MBA_DataEntryBox('setValue', minsPerFreq);
        $($startdate).MBA_DataEntryBox('setValue', startDate);
        $($enddate).MBA_DataEntryBox('setValue', endDate);
        $($startdateassigned).MBA_DataEntryBox('setValue', startDate);
        $($minsperfreqassigned).MBA_DataEntryBox('setValue', minsPerFreq);
        $($hassvcdetails).val(hasSvcDetails);
        $($svcdetailsjson).val(svcDetailsJSON);
        updateSvcDetailsHTML();
        if (lockTerms == 'Yes') lockServiceTermValues(); else unLockServiceTermValues();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearServiceTermValues() {
        clearSpEdServiceSelection();
        clearOrpDocSelection();
        clearSvcNameIDSelection();
        clearSpEdFreqCode();        
        $($minsperfreq).MBA_DataEntryBox('clearValue');
        $($startdate).MBA_DataEntryBox('clearValue');
        $($enddate).MBA_DataEntryBox('clearValue');
        $($startdateassigned).MBA_DataEntryBox('clearValue');
        $($minsperfreqassigned).MBA_DataEntryBox('clearValue');
        $($hassvcdetails).val('N');
        $($svcdetailsjson).val('{}');
        updateSvcDetailsHTML();
        unLockServiceTermValues();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function onPromisedServiceSelection(event, ui) {
        clearOrpDocSelection();
        clearSvcNameIDSelection();
        setServiceTermValues(ui.item.recData1, ui.item.recData7, ui.item.recData3, ui.item.recData4, ui.item.recData5, ui.item.recData9, ui.item.recData10, ui.item.recData11);
        $($spedservicecode).val(ui.item.recData6);        
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function onOrpDocSelection(event, ui) {
        clearSpEdServiceSelection();
        clearSvcNameIDSelection();
        setServiceTermValues(ui.item.recData11, ui.item.recData7, ui.item.recData8, ui.item.recData9, ui.item.recData10, 'N', '{}','Y');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function onSvcNameIDSelection(event, ui) {
        clearSpEdServiceSelection();
        clearOrpDocSelection();
        //setServiceTermValues();
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function onSvcTrackingClassSelection(e, clearServiceTerms) {
        
        let _stc = $($svctrackingclass).val();
        if (clearServiceTerms == true) clearServiceTermValues();
        if (_stc == '100') {
          $($spedServiceOptions).show();
          $($orpDocOptions).hide();
          $($nameIDOptions).hide();
          $($startdateassigned).MBA_DataEntryBox('show');
          $($minsperfreqassigned).MBA_DataEntryBox('show');          
        }
        else if (_stc == '200') {
          $($spedServiceOptions).hide();
          $($orpDocOptions).show();
          $($nameIDOptions).hide();
          $($startdateassigned).MBA_DataEntryBox('hide');
          $($minsperfreqassigned).MBA_DataEntryBox('hide');
        }
        else if (_stc == '300') {
            $($spedServiceOptions).hide();
            $($orpDocOptions).hide();
            $($nameIDOptions).show();
            $($startdateassigned).MBA_DataEntryBox('hide');
            $($minsperfreqassigned).MBA_DataEntryBox('hide');
        }
        else {
            $($spedServiceOptions).show();
            $($orpDocOptions).hide();
            $($nameIDOptions).hide();
            $($startdateassigned).MBA_DataEntryBox('show');
            $($minsperfreqassigned).MBA_DataEntryBox('show');
        }
        return;
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function clearSvcTrackingClassSelection() {
        $($svctrackingclass).MBA_DataEntryBox('setValue', '100');
    };
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>
    function getExpectedSvcCtrlRefs() {
        $clientid = $('#<%=Constants.PARM_CLIENT_ID%>');
        $pracid = $('#<%=Constants.PARM_PRACTITIONER_ID%>');
        $patid = $('#<%=Constants.PARM_PATIENT_ID%>');
        $promisedserviceid = $('#promisedserviceid');
        $spedservicecode = $('#spedservicecode');
        $orpdocid = $('#orpdocid');
        $nameid = $('#nameid');
        $spedServiceOptions = $('#spedserviceoptions');
        $orpDocOptions = $('#orpdocoptions');
        $nameIDOptions = '#nameidopts';
        $divSvcDetailsHTML = $('#svcdetails');
        $svctrackingclass = $('#svctrackingclass');
        $spedfreqcode = $('#spedfreqcode');
        $startdate = $('#startdate');
        $enddate = $('#enddate');
        $minsperfreq = $('#minsperfreq');
        $startdateassigned = $('#startdateassigned');
        $minsperfreqassigned = $('#minsperfreqassigned');
        $userprovidedsvcterms = $('#userprovidedsvcterms');
        $hassvcdetails = $('#hassvcdetails');
        $svcdetailsjson = $('#svcdetailsjson');
        return;
    };

    <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
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

            , '<%=Constants.PARM_CLIENT_ID%>'
            , '<%=Constants.PARM_PRACTITIONER_ID%>'
      );
    };

   <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPPSS (containerCtrlID, ctrlID) {

      let ppssOptsObj = {};

      ppssOptsObj.PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
      ppssOptsObj.PARM_NAME_PRACTITIONER_ID = '<%=Constants.PARM_PRACTITIONER_ID%>';
      ppssOptsObj.PARM_NAME_PATIENT_ID = '<%=Constants.PARM_PATIENT_ID%>';
      ppssOptsObj.PARM_NAME_ACTIVE = '<%=Constants.PARM_ACTIVE%>';
      ppssOptsObj.PARM_NAME_REC_ID = '<%=Constants.PARM_REC_ID%>';
      ppssOptsObj.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID = '<%=Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID%>';

      ppssOptsObj.containerCtrlID     = containerCtrlID;
      ppssOptsObj.sessionTimeOutUrl   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
      ppssOptsObj.baseUrlView         = '<%=Spedmon.PractitionerPatientScheduledServices.URL_REST_VIEW_BASE()%>'
      ppssOptsObj.defaultPageRowOrder = '<%=Spedmon.PractitionerPatientScheduledService.DEFAULT_PAGING_ORDER%>';
      ppssOptsObj.baseUrlAddNew       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_ADD_NEW_BASE()%>';
      ppssOptsObj.baseUrlEdit         = '<%=Spedmon.PractitionerPatientScheduledServices.URL_EDIT_BASE()%>';
      ppssOptsObj.baseUrlDelete       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_SVC_DELETE_INLINE_BASE()%>';
      ppssOptsObj.baseUrlReport       = '<%=Spedmon.PractitionerPatientScheduledServices.URL_WEB_REPORT_BASE()%>';
      ppssOptsObj.defaultReportNumber = '1';

      MBA.PractitionerPatientScheduledServicesManageCommon.fnSetup(ctrlID, ppssOptsObj);
    };

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    $(window).on('load', function () {

        getExpectedSvcCtrlRefs();

        <%if (saveType == Constants.SAVE_TYPE_NEW) {%>
          clearSvcTrackingClassSelection();
          clearServiceTermValues();
          
        <%} else if (saveType == Constants.SAVE_TYPE_EDIT) {%>
          $($patid).spedmonSelectBox_disable();          
          <%if (lockServiceTerms == true){%>
            lockServiceTermValues();
          <%}%>
          initPPSS('relatedScheduledServices', 'restViewPPSS');
        <%} else {%>
        <%}%>
        onSvcTrackingClassSelection(null,false);
        updateSvcDetailsHTML();
        $($svctrackingclass).on('change', function (e) { onSvcTrackingClassSelection(e, true); });
        initCalpadCodePrefs();
    });
<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

</script>
<%} /* client and prac are ok */ else {%>
<div class="alert alert-danger text-center">Please select a practitioner</div>
<%}%>

