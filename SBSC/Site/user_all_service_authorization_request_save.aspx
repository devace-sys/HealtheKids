<%@ Page Language="C#" CodeBehind="user_all_service_authorization_request_save.aspx.cs" Inherits="Spedmon.UserAllServiceAuthorizationRequestSave" %>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Patient Name %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="dataEntryRowPatientName" rowLabel="Patient (Last,First)" runat="server">
    <%=patNameDisplay%>
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Previous Response Notes %>
<%// Note: Only shown if needed %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="prevResponseNotes" rowLabel="Previous Response Notes" runat="server">

  <%=prevRespNotes%>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Service Description %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Request" runat="server">
  <div><%=sar.requestOrResponseScreenSubTitle%></div>
  <div class="p-2 font-weight-bold"><%=svcDescriptionReplacementWarning%></div>
  <Spedmon:NoteAreaBox ID="svcdescription" name="svcdescription" maxlen="7000" title="Enter a short description of the ordered service" showOKButton="false" runat="server"/>
  <Spedmon:DataEntryRowFormBuilderRenderBox ID="formBuilderAnswersJSONForOrder" name="formBuilderAnswersJSONForOrder" showFormBuilderBtnText="View Form Answers" formEditable="true" renderInDialog="false" runat="server"></Spedmon:DataEntryRowFormBuilderRenderBox>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Request Authorization From %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectAuthFrom" rowLabel="Request From" runat="server">

  <Spedmon:SelectRequestServiceAuthorizationFrom 
      id            = "reqsvcauthfromselectionid" 
      name          = "reqsvcauthfromselectionid" 
      title         = "Select One"        
      renderLabel   = "false"
      onSelectValue = "function(oldval,newval){reqSvcAuthFromSelected (oldval,newval); return true;}" 
      runat         = "server"/>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Parent/Guardian %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectParentOrGuardian 
    ID                                  = "selectParentGuardian" 
    rowLabel                            = "Select Parent or Guardian"
    entityControlID                     = "prtgrd1personid"      
    showAddNew                          = "true" 
    showEditSelected                    = "true"
    renderAddressControls               = "true"
    onEditClose                         = "updatePGAddressControlValues();"
    selectCtrlOnSelect                  = "updatePGAddressControlValues();"
    runat                               = "server">
</Spedmon:DataEntryRowSelectParentOrGuardian>

<%//-----------------------------------------------------------------------------%>
<%// ORP  %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectORP 
    ID                                  = "selectORP" 
    rowLabel                            = "ORP Professional"
    entityControlID                     = "orppracid"    
    manageFilesTitleText                = "Click here to manage supporting documents"
    manageFilesHandler                  = "manageSupportingDocuments();"
    renderAddressControls               = "true"
    onEditClose                         = "updateORPAddressControlValues();"
    selectCtrlOnSelect                  = "updateORPAddressControlValues();"
    runat                               = "server">
</Spedmon:DataEntryRowSelectORP>

<%//-----------------------------------------------------------------------------%>
<%// District Contact  %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectUser 
    ID                 = "selectDistrictContact" 
    entityControlID    = "districtcontactuserid"               
    rowLabel           = "District Contact" 
    onEditClose        = "updateDistrictContactAddressControlValues();"
    selectCtrlOnSelect = "updateDistrictContactAddressControlValues();"
    runat              = "server">
</Spedmon:DataEntryRowSelectUser>

<%//-----------------------------------------------------------------------------%>
<%// Files to Include %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectStoredFile
   ID                              = "selectedFilesToIncludeEntryRow"  
   rowLabel                        = "Files to Include With Request (Note: ONLY PDF files are supported at this time)"
   entityControlID                 = "selectedfilelist"
   multiSelect                     = "true"
   multiSelectListTitle            = "Files to Include With Request (PDF files only please)"
   ctrlIdClientID                  = "includefilesclientid"
   ctrlIDPracID                    = "includefilespracid"
   ctrlIdPatID                     = "includefilespatid"
   ctrlIdReferencedEntityID        = "includefilesrefentid"
   ctrlIdFileClass                 = "includefilesfileclass"
   ctrlIdFileNameSpace             = "includefilesfilenamespace"
   ctrlIdFileSource                = "includefilesfilesource"
   runat                           = "server">
   
   <Spedmon:HiddenInput ID="includefilesclientid"       name="clientid"       title="includefilesclientid"      noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilespracid"         name="pracid"         title="includefilespracid"        noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilespatid"          name="patid"          title="includefilespatid"         noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilesrefentid"       name="referencedentityid" title="includefilesrefentid" noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilesfileclass"      name="fileclass"      title="includefilesfileclass"     noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilesfilenamespace"  name="filenamespace"  title="includefilesfilenamespace" noClear="true" noSubmit="true" runat="server" />
   <Spedmon:HiddenInput ID="includefilesfilesource"     name="filesource"     title="includefilesfilesource"    noClear="true" noSubmit="true" runat="server" />
   
   <Spedmon:Button ID="butmanagefiles" title="Click here To Add New Files" onclick="manageFilesToInclude();" runat="server">Manage Library</Spedmon:Button>

</Spedmon:DataEntryRowSelectStoredFile>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit  %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                                     = "saveOrEdit" 
    editDelManageLink                      = "editdelsvcdescrlink"
    runat                                  = "server">

  <!-- The following are permanently hidden, future use, or deprecated fields -->

  <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server"/>
  <Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server"/>
  <Spedmon:HiddenInput ID="svcauthorizationrequesttypeid" name="svcauthorizationrequesttypeid" title="svcauthorizationrequesttypeid" runat="server"/>
  <Spedmon:HiddenInput ID="referencedentityid" name="referencedentityid" title="referencedentityid" runat="server"/>
  <Spedmon:HiddenInput ID="refpracgroupsvcclsnameid" name="refpracgroupsvcclsnameid" title="refpracgroupsvcclsnameid" runat="server"/>    
  <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
  <Spedmon:HiddenInput ID="reqsvcauthmethodselectionid" name="reqsvcauthmethodselectionid" title="reqsvcauthmethodselectionid" value="10" runat="server"/> 
  <Spedmon:HiddenInput ID="prtgrd2personid" name="prtgrd2personid" title="prtgrd2personid" runat="server"/>

</Spedmon:DataEntryRowSaveOrEdit>


</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

var clsHideUntilNeeded = 'ui-spedmon-data-entry-row-input-hide-until-needed';
var $clientid;
var $patid;
var $tkn = '<%=tkn%>';

$(window).on('load', function () {
  $clientid = $('#clientid').val();
  $patid    = $('#patid').val();
});

 /***************************************************************************
  * manageSupportingDocuments */
 /**
  * 
  ***************************************************************************/

 function manageSupportingDocuments() {

        let cid = $('#clientid').val();
        let pid = $('#patid').val();

        if ((cid != '') && (pid != '')) {
            var fileAdditionalDataJSONStr = '{clientid:' + cid + ', patid:' + pid + '}';
            $.spedmonWebUI.fileList('Supporting Documents'
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
        else {
            $.spedmonWebUI.dialogMessage('Please Select a Patient'
                , 'You must select a patient in order to work with any supporting documents.'
                , true
                , 300
                , 300
                , null);
        }
    }; 

/***************************************************************************
 * updatePGAddressControlValues */
/**
 ***************************************************************************/

function updatePGAddressControlValues()
{
  var personid = $('#prtgrd1personid').val();
  var selPerson = $('#selectParentGuardian').data('dataentryrowselectentity');
  var fnReturn = function (returnData) {  
    if (returnData.hasPatientPerson) {
      selPerson.updateEmailValue(returnData.patientPerson.email);
      selPerson.updatePhoneValue(returnData.patientPerson.phone);
    };
  };                
  $.spedmonWebUI.getPatientPersonData($tkn, $clientid, $patid, personid, fnReturn);
}

/***************************************************************************
 * updateORPAddressControlValues */
/**
 ***************************************************************************/

function updateORPAddressControlValues()
{
  var pracid  = $('#orppracid').val();
  var selPrac = $('#selectORP').data('dataentryrowselectentity');
  var fnReturn = function (returnData) {
    if (returnData.hasPractitioner) {
      selPrac.updateEmailValue(returnData.practitioner.email);
      selPrac.updatePhoneValue(returnData.practitioner.phone);
    };
  };        
  $.spedmonWebUI.getPractitionerData($tkn, $clientid, pracid, fnReturn);
}

/***************************************************************************
 * updateDistrictContactAddressControlValues */
/**
 ***************************************************************************/

function updateDistrictContactAddressControlValues()
{ /*
  var pracid  = $('#pracid').val();
  var selDistCont = $('#selectDistrictContact').data('dataentryrowselectentity');
  var fnReturn = function (returnData) {
    if (returnData.hasUser) {
      selDistCont.updateEmailValue(returnData.user.email);
      selDistCont.updatePhoneValue(returnData.user.phone);
    };
  };        
  $.spedmonWebUI.getUserData($tkn, $clientid, pracid, fnReturn);
  */
}

 /***************************************************************************
   * reqSvcAuthFromSelected */
  /**
   * Shows or hides parent guardian selected if needed or not
   * Only applies to requests where the user can select who they are requesting
   * authorization from.
   ***************************************************************************/

 function reqSvcAuthFromSelected(oldval, newval) {
   if (newval == 10) {          
     $('#selectParentGuardian').removeClass(clsHideUntilNeeded);
   }
   else if (newval == 20) {
     $('#selectParentGuardian').addClass(clsHideUntilNeeded);
    }
    else {
      $('#selectParentGuardian').addClass(clsHideUntilNeeded);            
    }
  }


/***************************************************************************
  * manageFilesToInclude */
 /**
  * 
  ***************************************************************************/

 function manageFilesToInclude() {

   let cid  = $('#includefilesclientid').val();
   let prc  = $('#includefilespracid').val();
   let pid  = $('#includefilespatid').val();
   let fcls = $('#includefilesfileclass').val();
   let fnsp = $('#includefilesfilenamespace').val();
   let fsrc = $('#includefilesfilesource').val();

   let fileAdditionalDataJSONStr = '{'
        + ' clientid:"' + cid + '"'
        + ',pracid:"'   + prc + '"'
        + ',patid:"'    + pid + '"'
        + '}';
     
    $.spedmonWebUI.fileList('Files to Include'
                            , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                            , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                            , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                            , 3 /* Record id position */
                            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                            , fcls
                            , '' /* File subclass */
                            , fnsp
                            , fsrc
                            , fileAdditionalDataJSONStr
                            , true
                            , true);
}
  
</script>
