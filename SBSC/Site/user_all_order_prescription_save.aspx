<%@ Page Language="C#" CodeBehind="user_all_order_prescription_save.aspx.cs" Inherits="Spedmon.UserAllOrderPrescriptionSave" %>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="servicejournalsprescribedorders.asmx/saveOrderOrProfile" useBootstrapFluid="true" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// New Form Data if available                                                  %>
<%//                                                                             %>
<%//                                                                             %>
<%// Note: This div is initially hidden, but will be displayed as needed in the  %>
<%// script section on "document ready"                                          %>
<%//-----------------------------------------------------------------------------%>

<div class="row new-form-data-prompt-cont rounded mb-1 p-2 d-none">
    <div class="col-12 d-flex justify-content-center align-items-center flex-wrap">

      <h6 class="font-weight-bold">An updated version of the form questions exists for the selected service (<%=po.orpDocStdName%>). Would you like to update this order to use the updated form questions?</h6>
      
      <button type="button" class="btn btn-info ml-2" onclick="previewUpdatedFormData()">
          Preview
      </button>
      
      <button type="button" class="btn btn-success ml-2" onclick="updateFormData()">
          Update
      </button>


    </div>
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Pre Selected Info %>
<%//-----------------------------------------------------------------------------%>

<div class="row">
<div class="col-4 d-flex justify-content-start">
  <h6 class="font-weight-bold"><%=orpDocStdNameDisplay%></h6>
</div>
<div class="col-4 d-flex justify-content-center">
    <h6 class="font-weight-bold"><%=patNameDisplay%></h6>
</div>
<div class="col-4 d-flex justify-content-end">
    <h6 class="font-weight-bold"><%=referenceDataDisplay%></h6>
</div> <!--col-->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                    = "selectPatient" 
    rowLabel              = "Patient" 
    entityControlID       = "patid"  
    preSelectedDataSource = "ALL_PATIENTS"
    showAddNew            = "true" 
    showEditSelected      = "true"
    onSpedmonInputData    = "showOrHideNoteCritAndRenderPracs(e);"
    runat                 = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner Discipline Family %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitionerDisciplineFamily 
    ID                  = "selectDispFamily" 
    rowLabel            = "Discipline Family" 
    entityControlID     = "groupserviceclassnameid"
    onSpedmonInputData  = "showOrHideNoteCritAndRenderPracs(e);"
    runat               = "server">
</Spedmon:DataEntryRowSelectPractitionerDisciplineFamily>

<%//-----------------------------------------------------------------------------%>
<%// Select Prescribed or Ordered Service %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectOrpServiceName
    ID                 = "selectOrpServiceName" 
    rowLabel           = "Prescribed or Ordered Service"
    entityControlID    = "orpdocstdnameselid"    
    selectCtrlOnSelect = "prePopulateTemplateTextFields(event,ui)"   
    runat              = "server">
</Spedmon:DataEntryRowSelectOrpServiceName>

<%//-----------------------------------------------------------------------------%>
<%// Earliest date that this service will be provided %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterStartDate" rowLabel="Earliest Date This Service Will Begin" runat="server">
  
  <Spedmon:DateBox 
    ID              = "effectivedate" 
    name            = "effectivedate" 
    title           = "mm/dd/yyyy" 
    numMonths       = "1" 
    showOK          = "false"
    runat           = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Service End Date %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterEndDate" rowLabel="Plan End Date" runat="server">

<Spedmon:DateBox 
    ID              = "enddate" 
    name            = "enddate" 
    title           = "mm/dd/yyyy"
    useDefaultValue = "false" 
    numMonths       = "1" 
    showOK          = "false"
    runat           = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Diagnosis %>
<%// Note: We are currently hiding this row for all users. %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Diagnosis" entryAllowed="false" runat="server">
  <Spedmon:NoteAreaBox ID="diagnosis" name="diagnosis" maxlen="4000" showOKButton="false" title="Enter diagnosis" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// MD Orders %>
<%// Note: We are currently hiding this row for all users. %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="MD Orders" entryAllowed="false"  runat="server">
  <Spedmon:NoteAreaBox ID="mdorders" name="mdorders" maxlen="4000" title="Enter MD Orders" showOKButton="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Service Description %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterServiceDescription" rowLabel="Service Description" runat="server">

<div class="d-inline-flex">
<span>
  <Spedmon:DataEntryRowFormBuilderRenderBox ID="formBuilderAnswersJSONForOrder" name="formBuilderAnswersJSONForOrder" runat="server"></Spedmon:DataEntryRowFormBuilderRenderBox>
</span>
 
<%if (hasCarePlanAccess == true){%>
<span class="ml-2 align-self-center">
  <Spedmon:LinkInternal
           ID         = "gotomanagecareplans"
           title      = "Click here to manage care plans"
           label      = "Manage Care Plans"
           faClass    = "fas fa-notes-medical"
           openNew    = "true"
           subWindow  = "true"
           urlPrivate = "true"            
           runat      = "server" />
  </span>
<%}%>
</div>


<Spedmon:NoteAreaBox ID="svcdesc" name="svcdesc" autoSize="true" maxlen="7000" showOKButton="false" title="Enter a short description of the ordered service" runat="server" />

    
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Expected Outcomes %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterExpectedOutcomes" rowLabel="Expected Outcomes" runat="server">
   <Spedmon:NoteAreaBox ID="expectedoutcomes" name="expectedoutcomes" autoSize="true" maxlen="4000" title="Enter Expected Outcomes" showOKButton="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select IEP %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterIEP" rowLabel="What plan type will this service be provided under?" runat="server">
    
    <div class="d-flex align-items-top flex-wrap">

        <%-- select plan type --%>

        <div>
            <select name="iep" ID="iep" title ="Plan Type" class="spedmon-select mr-2 h-100">

                <option disabled selected>-- select an option --</option>
                <option value="1" 
                        <%if (po.iep.HasValue && po.iep.Value == true) { %> selected <%}%>
                >
                    IEP / IFSP
                </option>
                <option value="0"
                    <%if (po.iep.HasValue && po.iep.Value != true) { %> selected <%}%>
                    >Other (IHP, 504, Counseling, etc.)
                </option>

            </select>

            <i id="planTypeInstructionsIcon" class="fas fa-question-circle mr-2" title=""></i>
            <button id="butOpenPromisedServicesTab" type="button" class="btn btn-secondary btn-sm" title="Click here to view IEP/IFSP plans for the selected patient (Related Services).  If no plans are listed then the patient may not have an IEP or we have not received any SpEd data updates for this patient.. ">View IFSP/IEP Plans</button>

        </div>

        <%-- select frequency --%>

        <div class="plantype-extra-field mr-2">
            <Spedmon:ComboBox 
              ID          = "frequency" 
	          name        = "frequency" 	
	          title       = "Frequency" 
	          dataPrivate = "true" 
	          dataURL     = "sped_service_frequencies.asmx/viewSel" 
	          runat       = "server" />
        </div>
    
        <%-- select number of projected minutes --%>

        <div class="plantype-extra-field mr-2">
            <Spedmon:DataEntryBoxNumber ID="projectedminutes" name="projectedminutes" label="Projected Minutes" title="Please enter projected minutes" runat="server"/>
        </div>
        
        <%-- select plan start date --%>

        <div class="plantype-extra-field mr-2">
            <Spedmon:DataEntryBoxDate ID="planstartdate" name="planstartdate" label="Plan Start Date" title="Please enter plan start date"  runat="server"/>
        </div>
        
        <%-- select plan end date --%>

        <div class="plantype-extra-field mr-2">
            <Spedmon:DataEntryBoxDate ID="planenddate" name="planenddate" label="Plan End Date" title="Please enter plan end date"  runat="server"/>
        </div>
    </div>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// ORP %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectORP 
    ID                              = "selectORP" 
    rowLabel                        = "Who is the ORP who has authorized this service?"
    entityControlID                 = "orpPracID"  
    manageFilesTitleText            = "Click here to manage supporting documents"
    manageFilesHandler              = "manageSupportingDocuments()"
    onSpedmonInputData              = "showOrHideAuthDateAndStatus(e);"
    runat                           = "server">
</Spedmon:DataEntryRowSelectORP>
    
<%//-----------------------------------------------------------------------------%>
<%// Authorized Date %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterAuthDate" rowLabel="What is the date that the service was authorized?" runat="server">  

  <Spedmon:DataEntryBoxDate ID="orpauthsvcdate" name="orpauthsvcdate" label="Authorization Date" title= "Select or Enter Date Service Was Authorized" fireSpedmonInput="true" min="1900-01-01" runat="server" />
  <Spedmon:DataEntryBoxDate ID="orpauthexpdate" name="orpauthexpdate" label="Expiration Date"    title= "Select or Enter Date Authorization Expires" min="1900-01-01" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Authorized Status %>
<%//-----------------------------------------------------------------------------%>
    
<Spedmon:DataEntryRow ID="selectCurrAuthStatus" rowLabel="What is the current authorization status for this service?" runat="server">

  <Spedmon:SelectServiceAuthorizationStatusConfirmationResponse 
    ID                         = "svcauthstatusconfirmrespcode" 
    name                       = "svcauthstatusconfirmrespcode"    
    title                      = "Select One" 
    runat                      = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #1 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit1" rowLabel="Note Criteria 1 (Free Form Text Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit1" name="notecrit1" maxlen="500" title="Enter note criteria 1" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #2 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit2" rowLabel="Note Criteria 2 (Free Form Text Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit2" name="notecrit2" maxlen="500" title="Enter note criteria 2" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #3 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit3" rowLabel="Note Criteria 3 (Free Form Text Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit3" name="notecrit3" maxlen="500" title="Enter note criteria 3" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #4 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit4" rowLabel="Note Criteria 4 (Free Form Text Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit4" name="notecrit4" maxlen="500" title="Enter note criteria 4" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #5 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit5" rowLabel="Note Criteria 5 (Yes/No Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit5" name="notecrit5" maxlen="500" title="Enter note criteria 5" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #6 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit6" rowLabel="Note Criteria 6 (Yes/No Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit6" name="notecrit6" maxlen="500" title="Enter note criteria 6" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #7 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit7" rowLabel="Note Criteria 7 (Yes/No Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit7" name="notecrit7" maxlen="500" title="Enter note criteria 7" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #8 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit8" rowLabel="Note Criteria 8 (Numeric Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit8" name="notecrit8" maxlen="500" title="Enter note criteria 8" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #9 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit9" rowLabel="Note Criteria 9 (Numeric Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit9" name="notecrit9" maxlen="500" title="Enter note criteria 9" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Note Criteria #10 %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterNoteCrit10" rowLabel="Note Criteria 10 (Numeric Answer)"  runat="server">
<Spedmon:TextBox ID="notecrit10" name="notecrit10" maxlen="500" title="Enter note criteria 10" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Practitioners Trained to Render Service %>
<%//-----------------------------------------------------------------------------%>

<%--<Spedmon:DataEntryRowSelectPractitioner 
   ID                              = "selectPracIDs"  
   rowLabel                        = "Who Has Been Trained to Provide This Service for the Patient"
   entityControlID                 = "pracids"    
   preSelectedDataSource           = "ALL_PRACTITIONERS"            
   multiSelect                     = "true" 
   multiSelectDisplayContextLabels = "true" 
   multiSelectListTitle            = "Selected Practitioners"
   multiSelectOnAdd                = "addSelPracDetail(selObj);"
   multiSelectOnRemove             = "removeSelPracDetail(selObj);"        
   runat                           = "server">
</Spedmon:DataEntryRowSelectPractitioner>--%>

<Spedmon:HiddenTextArea name="pracids" ID="pracids" title="pracids" runat="server"></Spedmon:HiddenTextArea>
<Spedmon:HiddenTextArea name="details_pracs_training" ID="details_pracs_training" title="details_pracs_training" runat="server"></Spedmon:HiddenTextArea>

<%//-----------------------------------------------------------------------------%>
<%// Training Dates %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterPracTrainingDetails" rowLabel="Who Has Been Trained to Provide This Service for the Patient?" runat="server">

<%--  <Spedmon:DataGrid 
     ID             = "details_pracs_training" 
     name           = "details_pracs_training"
     title          = "Enter Training Dates"
     classAssembly  = "Spedmon"
     className      = "Spedmon.ServiceJournalPractitionerTrainingDetail"  
     sortRowsByKey  = "false" 
     showControls   = "false"
     runat          = "server"/>--%>
    <div id="details_pracs_training_container"></div>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Auth History %>
<%//-----------------------------------------------------------------------------%>

<div class="ui-spedmon-auth-hist-content-container">
    <%=authHistTbl%>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit" 
    editDelManageLink                = "manageorderseditdeletelink"
    includeSecondarySaveButton       = "true"
    secondarySaveButtonLabel         = "Save & Request E-Authorization"
    secondarySaveButtonOnClick       = "saveNewAndAuthorize (e)"
    runat                            = "server">


<Spedmon:HiddenInput    ID="orpdoctype"                    name ="orpdoctype"               title ="ORP document type"                 noClear="true" runat="server" />
<Spedmon:HiddenTextArea ID="formBuilderQuestionsJSON"      name ="formBuilderQuestionsJSON" title ="formBuilder Questions"                            runat="server" />
<Spedmon:HiddenInput    ID="allowmultipleorders"           name ="allowmultipleorders"      title ="allow multiple orders for service" noClear="true" runat="server" />
<Spedmon:HiddenInput    ID="ordercontextfieldname"         name ="ordercontextfieldname"    title ="context field name"                noClear="true" runat="server" />

<!-- The following are deprecated or future use fields -->

<Spedmon:HiddenInput    ID="noteobsvcmnt"                  name ="noteobsvcmnt"             title="noteobsvcmnt"              value="" noClear="true" runat="server"/>
<Spedmon:HiddenInput    ID="svcname"                       name ="svcname"                  title ="Enter name of the ordered service" noClear="true" runat="server" />
<%--<Spedmon:HiddenInput    ID="iep"                           name ="iep"                      title ="IEP or IFSP?"                      noClear="true" runat="server" />--%>
<Spedmon:HiddenInput    ID="dailyfreq"                     name ="dailyfreq"                title ="Number of Times Daily"             noClear="true" runat="server" />
<Spedmon:HiddenInput    ID="siteaide"                      name ="siteaide"                 title ="Does this patient receive authorized, medically necessary, 1:1 Accompany & Monitoring?" noClear="true" runat="server" />
<Spedmon:HiddenInput    ID="busaide"                       name ="busaide"                  title ="Will the patient have an authorized bus aide?" noClear="true" runat="server" />


</Spedmon:DataEntryRowSaveOrEdit>


</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

  let $gotoManageCarePlans;
  let $dataEntryRows;

  var clsHideUntilNeeded = 'ui-spedmon-data-entry-row-input-hide-until-needed';
  const $DETAILS_PRACS_TRAINING_DATAGRID = $('#details_pracs_training_container');
  const PARM_NAME_CLIENT_ID  = '<%=Constants.PARM_CLIENT_ID%>';
  const PARM_NAME_PATIENT_ID = '<%=Constants.PARM_PATIENT_ID%>';
  const CONST_ATTR_CLIENT_ID = 'clientID';
  const CONST_ATTR_PRAC_TRAINING_DETAILS = "details_pracs_training";

  /***************************************************************************
   * getKeyEntityData */
  /**
   *
   ***************************************************************************/

  function getKeyEntityData () {
     let ked                     = {};
     ked.clientid                = $('#clientid').val();
     ked.groupserviceclassnameid = $('#groupserviceclassnameid').val();
     ked.patid                   = $('#patid').val();
     ked.orpdocstdnameselid      = $('#orpdocstdnameselid').val();
     return ked;
  }
    /***************************************************************************
     * openPatientPromisedServicesTab */
    /**
     *
     ***************************************************************************/

    function openPatientPromisedServicesTab() {
        let ked = getKeyEntityData();
        if (!ked.clientid) return;
        if (!ked.patid)    return;
        let urlBase = '<%=patEditUrlBase%>' + ked.patid;
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', ked.clientid));
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_TAB_TO_OPEN%>', 'tab-promised-services'));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

  /***************************************************************************
   * saveNewAndAuthorize */
  /**
   *
   ***************************************************************************/

  function saveNewAndAuthorize(e) {
      var raurl = '<%=requestAuthorizationURL%>'; // the url for the record authorization

      // the callback for when the AJAX request saves a record successfully
      var fnDoAuthorize = function (rd) {
          // this is the code that launches the authorize record screen
          var reqSvcAuthUrl = raurl
              + '&amd=uidbssub'
              + '&referencedEntityID=' + (($('#savetype').val() == 1) ? rd.recordID : '<%=orderOrProfileRecID%>')
              + '&svcAuthorizationRequestTypeID=' + (($('#orpdoctype').val() == '3') ? 2 : 1); // we pass 2 for profiles and 1 for orders
          $.spedmonWebUI.gotoURL(reqSvcAuthUrl)
      };
      $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnDoAuthorize, true);
    }

  /***************************************************************************
   * manageSupportingDocuments */
  /**
   * 
   ***************************************************************************/

  function manageSupportingDocuments () {

    let ked = getKeyEntityData();
    let cid = ked.clientid;
    let pid = ked.patid;
      
    if ((cid != '') && (pid != ''))
    {    
      var fileAdditionalDataJSONStr = '{clientid:' + cid + ', patid:' + pid + '}';
      $.spedmonWebUI.fileList (   'Supporting Documents'
                                , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                                , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                                , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                                , 3 /* Record id position */
                                , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                                , '<%=Spedmon.ServiceJournals.VAL_FILE_CLASS_PRESCRIPTIONS%>'
                                , '' /* File subclass */
                                , '<%=Spedmon.ServiceJournals.VAL_FILE_NAMESPACE%>'
                                , '<%=Spedmon.ServiceJournals.VAL_FILE_SOURCE_PRESCRIPTIONS%>'
                                , fileAdditionalDataJSONStr
                                , true
                                , true);
    }
    else
    {      
        $.spedmonWebUI.dialogMessage('Please Select a Patient'
                                    , 'You must select a patient in order to work with any supporting documents.'
                                    , true
                                    , 300
                                    , 300
                                    , null );
    }
  };

  /***************************************************************************
   * handleNewOrderForm */
  /**
   *
   ***************************************************************************/

  function handleNewOrderForm($svcDes,event, ui) {

    // set value of form data json fields and hide service description box if form exists
    // initially show both svc description and form builder and hide them as needed 

    var $formBuilderRenderDialogBtn = $('#' + "<%=ctrlFormBuilderContentJSON.formBuilderRenderDialogBtnID%>");

    $formBuilderRenderDialogBtn.show();
    $svcDes.parent().show();

    /* Has form data */

    if (ui.item.recData6) {
          $svcDes.parent().hide();
          $('#' + "<%=ctrlFormBuilderContentJSON.formBuilderQuestionsJSONID%>").val(ui.item.recData6);
          $('#' + "<%=ctrlFormBuilderContentJSON.name%>").val(""); // reset answers
         $('#formBuilderQuestionsJSON').val(ui.item.recData6);
         spedmonRenderFormBuilderFromJSON('formBuilderAnswersJSONForOrder', true, true);
     } else {
        $formBuilderRenderDialogBtn.hide();
        $('#' + "<%=ctrlFormBuilderContentJSON.formBuilderQuestionsJSONID%>").val("");
        $('#' + "<%=ctrlFormBuilderContentJSON.name%>").val(""); // reset answers
        $('#formBuilderQuestionsJSON').val("");
     }
  }

  /***************************************************************************
   * prePopulateTemplateTextFields */
  /**
   *
   ***************************************************************************/

  function prePopulateTemplateTextFields (event,ui) {    
        
      /* Only new records */

      if ($('#savetype').val() != '1') return;

      /* Put ID in control a bit sooner that normal*/

      $('#orpdocstdnameselid').val(ui.item.id); 

      /* Handle 1:1 services */

      if ((ui.item.id == 1) || (ui.item.id == 2)) {
          $('#orpdoctype').val('3');
          $('#groupserviceclassnameid').val('3');
          $('#enterNoteCrit1').hide();
          $('#enterNoteCrit2').hide();
          $('#enterNoteCrit3').hide();
          $('#enterNoteCrit4').hide();
          $('#enterNoteCrit5').hide();
          $('#enterNoteCrit6').hide();
          $('#enterNoteCrit7').hide();
          $('#enterNoteCrit8').hide();
          $('#enterNoteCrit9').hide();
          $('#enterNoteCrit10').hide();
          $('#selectOrEnterEndDate').hide();
      }
      /* Handle not 1:1 */
      else { 
          $('#orpdoctype').val('2');
          $('#enterNoteCrit1').show();
          $('#enterNoteCrit2').show();
          $('#enterNoteCrit3').show();
          $('#enterNoteCrit4').show();
          $('#enterNoteCrit5').show();
          $('#enterNoteCrit6').show();
          $('#enterNoteCrit7').show();
          $('#enterNoteCrit8').show();
          $('#enterNoteCrit9').show();
          $('#enterNoteCrit10').show();
          $('#selectOrEnterEndDate').show();
      }

      var $svcDes = $('#svcdesc');
      
      $($svcDes).val(ui.item.recData1);
      $('#notecrit1').val(ui.item.recData2);
      $('#notecrit2').val(ui.item.recData3);
      $('#notecrit3').val(ui.item.recData4);
      $('#notecrit4').val(ui.item.recData5);
      $('#notecrit5').val(ui.item.recData9);
      $('#notecrit6').val(ui.item.recData10);
      $('#notecrit7').val(ui.item.recData11);
      $('#notecrit8').val(ui.item.recData12);
      $('#notecrit9').val(ui.item.recData13);
      $('#notecrit10').val(ui.item.recData14);
      $('#allowmultipleorders').val(ui.item.recData7);
      $('#ordercontextfieldname').val(ui.item.recData8);

      $svcDes.change(); /* Change event is needed to resize */

      /* Check for duplicates */

      let ked = getKeyEntityData();

      let urlToPostTo = '<%=Spedmon.ORPDocuments.URL_SERVICE_VIEW_SEL_ORDS_PROF_FOR_CLT_GRP_PAT_SVC_BASE()%>';
      let dataToPost = JSON.stringify(ked);
      var eventPass = event;
      var uiPass = ui;

      MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(urlToPostTo, dataToPost, null)
          .then(function (responseData) {
              let selRecs = responseData.rawData.SelRecs;
              if (selRecs) {
                  
                  let msgTitle = 'Duplicate Order Warning';

                  var fnOnContinue = function () {
                      handleNewOrderForm($svcDes,eventPass, uiPass);
                  };

                  var instructions = '<p>Active ' + ui.item.label + ' orders already exist in SpEdCare for this patient. '
                      + 'If the patient is currently receiving ' + ui.item.label + ' then only one (1) active ' + ui.item.label + ' order for this patient is required.'
                      + '<br><br>'
                      + '<strong>Please select one of the following active orders to edit instead of creating a new (duplicate) ' + ui.item.label + ' order.</strong><br>'
                      + 'If you continue with entering a new ' + ui.item.label + ' order then the active ' + ui.item.label + ' orders for this patient listed below will be deactivated when you save the new order and you will be starting over with the new order.'

                  var continueButtonText = 'Continue With Entering This Duplicate Order';

                  $.spedmonWebUI.dialogDuplicateRecords(msgTitle, instructions, continueButtonText, '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>', selRecs, null, null, fnOnContinue);
                  
              }
              else {
                  handleNewOrderForm($svcDes,eventPass, uiPass);
              }
          });


      return;

  }

  /***************************************************************************
   * showOrHideNoteCritAndRenderPracs */
  /**
   * 
   ***************************************************************************/
           
  function showOrHideNoteCritAndRenderPracs (e) {

      var ked = getKeyEntityData();

      if ((ked.patid) && (ked.groupserviceclassnameid)) {
          $('#selectOrpServiceName').removeClass(clsHideUntilNeeded);
      }
      else {
          $('#selectOrpServiceName').addClass(clsHideUntilNeeded);
      }
      
      if (ked.groupserviceclassnameid) {
          $('#selectORP').removeClass(clsHideUntilNeeded);
      }
      else {
          $('#selectORP').addClass(clsHideUntilNeeded);
      }

      /* Health services */
      if (ked.groupserviceclassnameid == '3') {
          $('#enterNoteCrit1').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit2').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit3').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit4').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit5').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit6').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit7').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit8').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit9').removeClass(clsHideUntilNeeded);
          $('#enterNoteCrit10').removeClass(clsHideUntilNeeded);
          $('#selectPracIDs').removeClass(clsHideUntilNeeded);   
          $('#enterPracTrainingDetails').removeClass(clsHideUntilNeeded);
      }
      else if (ked.groupserviceclassnameid != '3') {

          $('#enterNoteCrit1').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit2').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit3').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit4').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit5').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit6').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit7').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit8').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit9').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit10').addClass(clsHideUntilNeeded);
          $('#selectPracIDs').addClass(clsHideUntilNeeded);
          $('#enterPracTrainingDetails').addClass(clsHideUntilNeeded);
      } else {
          $('#enterNoteCrit1').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit2').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit3').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit4').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit5').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit6').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit7').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit8').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit9').addClass(clsHideUntilNeeded);
          $('#enterNoteCrit10').addClass(clsHideUntilNeeded);

      }

      return; 
  }

  /***************************************************************************
   * showOrHideAuthDateAndStatus */
  /**
   * 
   ***************************************************************************/
           
  function showOrHideAuthDateAndStatus (e) {
      if (e.dataitem.value != "")
      {
          $('#selectOrEnterAuthDate').removeClass(clsHideUntilNeeded);
          $('#selectCurrAuthStatus').removeClass(clsHideUntilNeeded);
      }
      else
      {
          $('#selectOrEnterAuthDate').addClass(clsHideUntilNeeded);
          $('#selectCurrAuthStatus').addClass(clsHideUntilNeeded);      
      }
      return;      
   }

  /***************************************************************************
   * getDgRef */
  /**
   * Gets ref to practitioner details datagrid
   ***************************************************************************/

  function getDgRef()
  {
    var dgObj = $('#details_pracs_training').data('spedmondatagrid');
    return dgObj;
  }

  /**************************************************************************
   * addSelPracDetail() */
  /**
   * Called when a practitioner selction is made (added)
   *
   **************************************************************************/
 
  function addSelPracDetail(selObj)
  {
    if (selObj)
    {
      var dgPracDetails = getDgRef();
      var newArgs  = [];
      var newKey   = selObj.value + ''; /* Create a string version of key */   
      var newName  = selObj.name;
      var newTitle = selObj.contextlabel;
      var newTDate = ''     
      newArgs.push(newName);
      newArgs.push(newTitle);
      newArgs.push(newTDate);
      dgPracDetails.addRowByKeyWithValues (newKey, newArgs);
    }
    return;
  }
  
  /**************************************************************************
   * removeSelPracDetail() */
  /**
   * Called when a practitioner selction is removed
   *
   **************************************************************************/

  function removeSelPracDetail(selObj)
  {
      // TODO - remove this once datagrid is working
      return;
    if (selObj)
    {
      var dgPracDetails = getDgRef();
    
      /* Create string version of practitioner key */
      var existingKey = selObj.value + ''; 
    
      /* Remove practitioner from each grid */
    
      dgPracDetails.removeRowByKey(existingKey);    
    }
   return;
  }
      
  /**************************************************************************
   * getPracDataByIDPromise */
  /**
   *
   **************************************************************************/

  function getPracDataByIDPromise(clientID, pracID)
  {
      var reqUrl = '<%=Spedmon.Practitioners.URL_GET_PRAC_BASE()%>';
      var reqData = JSON.stringify({
            "clientid": clientID
          , "pracid"  : pracID
      });

      return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null);
  }

// purpose: validate data in data grid before a row is saved
// returns true if data is valid and false if it isn't
function validatePracTrainingData(dataObj, uiActionObj) {
    if (!uiActionObj) throw new Error("Invalid data was received from data grid");

    let $notificationCol = $(uiActionObj.notificationsCol);

    if ($notificationCol.length == 0) throw new Error("Invalid data was received from data grid");

    // set up validation fields
    let pracID       = dataObj.find(x => x.name === 'pracID').value;
    let trainingDate = dataObj.find(x => x.name === 'trainingDate').value;

    // check for null
    if (!pracID) {
        $notificationCol.html('').append(MBA.DataGridCommon.fnRenderRowNotificationErrorMessageStandAlone('Please select a practitioner'));
        return false;
    }
    if (!trainingDate) {
        $notificationCol.html('').append(MBA.DataGridCommon.fnRenderRowNotificationErrorMessageStandAlone('Please enter training date'));
        return false;
    }

    // check for repeating prac by looping through the data grid's data map
    let pracIDCount = 0;
    let currentMapKey = uiActionObj.dataMapKey;
    uiActionObj.dataObj.dataMap.forEach(function (mapEntry, mapKey) {
        if (mapEntry.pracID && mapEntry.pracID == pracID && mapKey != currentMapKey) {
            pracIDCount++;
        }
    });
    if (pracIDCount > 0) {
        $notificationCol.html('').append(MBA.DataGridCommon.fnRenderRowNotificationErrorMessageStandAlone('This practitioner is already on the list'));
        return false;
    }

    //no errors
    return true;
  }

  // purpose: populate the training data fields when data is saved into the data grid
  function populatePracTrainingData(dataAsMap) {
      if (!dataAsMap) throw new Error("Invalid data was received from data grid");

      let pracTrainingIdsArr = [];
      let pracTrainingDetailsArr = [];

      dataAsMap.forEach(function (dataObj) {
          pracTrainingIdsArr.push(dataObj.pracID);
          pracTrainingDetailsArr.push({
              'pracID': dataObj.pracID
              , 'trainingDate': dataObj.trainingDate
          });
      });

      $('#pracids').val(pracTrainingIdsArr.join(","));
      $('#' + CONST_ATTR_PRAC_TRAINING_DETAILS).val(JSON.stringify({ "details_pracs_training": pracTrainingDetailsArr }));
  }

  function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
      let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
  
      let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
      $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
  
      $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
  };

  function initPracsTrainingDataGrid() {

      let opts = {};
      opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
      opts.enableSortControls = true;
      opts.enableRowNumbers = true;
      opts.enableRowControls = true;
      opts.enableRowControlRecAddNew = true;
      opts.enableRowControlRecEdit = false;
      opts.saveModeAddNew = 'inlineunlockedfields';
      opts.saveModeEdit = 'inline';
      opts.saveModeDelete = 'inlineunlockedfields';
      opts.enableRowControlRecDelete = true;
      opts.jsonInputHtml = '<textarea id="pracTrainingDataGridTextarea" name="pracTrainingDataGridTextarea" class="d-none"></textarea>';
      opts.fieldDefinitions = [];
      
      <%//-----------------------------------------------------------------------------%>
      <%// Practitioner Name                                                           %>
      <%//-----------------------------------------------------------------------------%>
      
      <%/* Setup autocomplete - Basics */%>
      
      let pracIdOpts = {};
      pracIdOpts.baseUrl                    = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
      pracIdOpts.loadMode                   = 'mbaviewsel';
      pracIdOpts.getInitialSelectedNameFrom = 'pracName';
      
      <%/* Setup autocomplete - Handle Changes in Selection */%>
      
      pracIdOpts.fnOnSelect = function (event, ui) { };
      
      <%/* Setup autocomplete - Customization Hooks  */%>
      
      pracIdOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
      pracIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
      pracIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
          var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
          $($li).children('a').append(ctxt1);
          return $li;            
      };
      pracIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};
      
      <%/* Finally add field def  */%>

      opts.fieldDefinitions.push({
          name: 'pracID'
          , label: 'Practitioner Name'
          , toolTip: 'Practitioner Name'
          , visible: true
          , sortable: true
          , editable: true
          , saveable: true
          , saveUsing: 'pracID'
          , isRecID: false
          , dataType: 'autocomplete'
          , dataTypeOptions: pracIdOpts
          , sortUsing: 'pracName'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'pracName'
          , label: 'Practitioner Name'
          , toolTip: 'Practitioner Name'
          , visible: false
          , sortable: true
          , editable: true
          , saveable: true
          , saveUsing: 'pracName'
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: 'pracName'
          , showMore: false
      });
            
      opts.fieldDefinitions.push({
          name: 'trainingDate'
          , label: 'Training Date'
          , toolTip: 'Training Date'
          , visible: true
          , editable: true
          , saveable: true
          , sortable: true
          , isRecID: false
          , saveUsing: 'trainingDate'
          , dataType: 'date'
      });

      <%//-----------------------------------------------------------------------------%>
      <%// Parameters for our prac dropdowns (hidden) %>
      <%//-----------------------------------------------------------------------------%>

      opts.fieldDefinitions.push({
          name: 'clientID'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'clientid'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'patid'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'patid'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'dos'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'dos'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'groupserviceclassnameid'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'groupserviceclassnameid'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'pracdatasource'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'pracdatasource'
          , showMore: false
      });

      opts.fieldDefinitions.push({
          name: 'active'
          , visible: false
          , sortable: false
          , saveable: true
          , editable: false
          , isRecID: false
          , dataType: 'hidden'
          , sortUsing: ''
          , saveUsing: 'active'
          , showMore: false
      });

      opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
          var clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();

          // preload client ID
          if (fieldDefinition.name === CONST_ATTR_CLIENT_ID) {
              $($newCellValue).val(clientIDVal);
          }

          // load pracName if pracID exists
          if (fieldDefinition.name === "pracID" && fieldValue && fieldValue != 0) {
              getPracDataByIDPromise(clientIDVal, fieldValue).then(function (responseData) {
                  rowData.pracName = responseData.rawData.practitioner.name;
                  $(newRow).find('input[data-mba-rest-view-field-name="pracID"]').val(rowData.pracName);
              }).catch(function (responseData) { console.error(responseData); });
          }
          return $newCell;
      };

      // data save callback
      opts.fnSaveDataAfter = function (dataAsMap, dataAsArr, dataAsJSON, okToWorkWithData) {
          // populate prac training fields from the objects getting saved in data grid
          populatePracTrainingData(dataAsMap);
      };
      
      // data save validation
      // opts.fnAddNewSaveRowBeforeCustomValidation = opts.fnEditSaveRowBeforeCustomValidation = validatePracTrainingData;

      // preload data into datagrid
      let pracTrainingDataVal = $("#" + CONST_ATTR_PRAC_TRAINING_DETAILS).val();
      if (pracTrainingDataVal) {
          try {
              opts.tblDataArr = JSON.parse(pracTrainingDataVal)[CONST_ATTR_PRAC_TRAINING_DETAILS];
          } catch (e) {
              console.log(e);
          }
      }

      /* Create the rest view */
      $DETAILS_PRACS_TRAINING_DATAGRID.MBA_DataGrid(opts);
  
  }

  // show and hide plan type extra fields if selected plan type is "other"

  function showHidePlanTypeExtraFields() {
      let val = $('#iep').val();
      let $extraFields = $('.plantype-extra-field');

      // if select option is "other"
      if (val == 0) {
          $extraFields.show(300);
      } else {
          $extraFields.hide(300);

          // reset field values
          $extraFields.find('input').val('');

          // reset select values to default option
          let $select = $extraFields.find('select');
          $select.val('');
          $select.find('option').removeAttr('selected');
          $select.find('option:nth-child(1)').attr('selected', true);
      }
  }

  // quarterback function to run all operations that need to be run as a result of plan type selection

  function runPlanTypeSelectionOperations() {
      showHidePlanTypeExtraFields();
  }

  // initialize processes and bindings that are needed for plan type dropdown

  function initPlanTypeSelectionProcedures() {
      // add change event to plan type so we can show custom fields when "other" is selected
      $('#iep').on('change', runPlanTypeSelectionOperations);
  
      showHidePlanTypeExtraFields();
  }
    
  // previews the updated version of the form that exists for the selected ORP doc std selection name

  function previewUpdatedFormData() {
    let formData = <%=updatedFormData%>;

    // this is a common form builder function. For function definition refer to the form builder common functions file
    renderFormPreviewDialog(formData);
  }    
        
  // updates the current order's form data to the updated version that exists for the selected ORP doc std selection name
  // and resets the answers

  function updateFormData() {
      $('#' + "<%=ctrlFormBuilderContentJSON.formBuilderQuestionsJSONID%>").val(JSON.stringify(<%=updatedFormData%>));
      $('#' + "<%=ctrlFormBuilderContentJSON.name%>").val(""); // reset answers
      $('#formBuilderQuestionsJSON').val(JSON.stringify(<%=updatedFormData%>));

      // visual updates
      $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });
      $('.new-form-data-prompt-cont').hide(500);
      setTimeout(function () { $('.new-form-data-prompt-cont').remove(); }, 500);
  }    

  // if new form data exists, give user the option to update to the new form data
  function handleNewFormDataForSelectedOrpStdSelName() {

      <%if (updatedFormDataAvailable) {%>
        $('.new-form-data-prompt-cont').removeClass('d-none');
      <%}%>

    }

    function updateAdditionalParameterValues(e) {
        let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, $('#' + PARM_NAME_CLIENT_ID).val());
        let NV_PATIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, $('#' + PARM_NAME_PATIENT_ID).val());
        <%if (hasCarePlanAccess == true){%>
        $($gotoManageCarePlans).MBA_Link('requestDataParameterSetOrUpdate', NV_CLIENT_ID);
        $($gotoManageCarePlans).MBA_Link('requestDataParameterSetOrUpdate', NV_PATIENT_ID);
        <%}%>
    }

  $(function () {

      $dataEntryRows = $('#save');
      <%if (hasCarePlanAccess == true){%>
      $gotoManageCarePlans = $('#gotomanagecareplans');
      <%}%>

      $($dataEntryRows).on('spedmoninput', function (e) {
          
          if (e.target.id == 'orpauthsvcdate') {
              let authDateStr = $('#orpauthsvcdate').val();
              if (!authDateStr) return;
              let authDateVal = new Date(authDateStr);
              let expDateVal = authDateVal.addYears(1);
              let expDateTimeStr = MBA.ComponentCommon.fnFormatDateTimeToYYYYMMDDTHHMM(expDateVal);
              let expDateStr = expDateTimeStr.split('T')[0];                            
              $('#orpauthexpdate').MBA_DataEntryBox('setValue', expDateStr);
              
              return;
          };

      });

      $($dataEntryRows).on('spedmoninputdata', function (e) {
          
          updateAdditionalParameterValues(e);
      });

      $('#butOpenPromisedServicesTab').on('click', function () { openPatientPromisedServicesTab() });

      // make the service description non-editable
      $('#svcdesc').attr('readonly', true);

      // add onClick to the form button
      $('#formBuilderAnswersJSONForOrderRenderFormBuilderQuestionsBtn').on('click',
          function () {
              let formContentForService = $('#' + "<%=ctrlFormBuilderContentJSON.formBuilderQuestionsJSONID%>").val();
              $('#formBuilderQuestionsJSON').val(formContentForService);
          }
      );

      // initialize processes and bindings that are needed for plan type dropdown

      initPlanTypeSelectionProcedures();

      initPracsTrainingDataGrid();

      // if new form data exists, give user the option to update to the new form data

      handleNewFormDataForSelectedOrpStdSelName();

      // add tipso text to the plan type instructions icon

      $('#planTypeInstructionsIcon').tipso({
          speed: 400
          , background: '#ffd60d'
          , titleBackground: '#333333'
          , color: 'black'
          , titleColor: '#ffffff'
          , titleContent: ''
          , showArrow: true
          , position: 'top'
          , width: '50vw'
          , maxWidth: '50vw'
          , delay: 200
          , hideDelay: 0
          , animationIn: ''
          , animationOut: ''
          , offsetX: 0
          , offsetY: 0
          , tooltipHover: true
          , content: 'If the service and minutes are defined in the IEP/IFSP (Typically a CALPADS Code), then select “IEP/IFSP". If minutes are not not included in the IEP, we recommend selecting “Other”. If “Other” is selected, an authorized care plan will need to be in place for compliance purposes.'
          , ajaxContentUrl: null
          , contentElementId: null
          , useTitle: false
          , templateEngineFunc: null
          , onBeforeShow: null
          , onShow: null
          , onHide: null
      });

      updateAdditionalParameterValues(null);


  });

</script>

