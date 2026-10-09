<%@ Page Language="C#" CodeBehind="user_all_practitioner_caseload_data_update.aspx.cs" Inherits="Spedmon.UserAllPractitionerCaseloadDataUpdate" %>

<%//-----------------------------------------------------------------------------%>
<%// Inform user about plan updates %>
<%//-----------------------------------------------------------------------------%>

<div id="caseloadUpdateStatus" class="alert alert-warning text-center">
</div>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="practitioner_patient_caseload_expected_services.asmx/savemultiple" runat="server">

  <%//-----------------------------------------------------------------------------%>
  <%// Data Grid New Services %>
  <%//-----------------------------------------------------------------------------%>

  <div class="row mt-2">
     <div class="col-auto">
       <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
       <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />
       <div id="dataGridNewSvcsContainer">
       </div>
     </div> <!-- col -->
  </div> <!-- row -->

  <%//-----------------------------------------------------------------------------%>
  <%// Save %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSaveOrEdit
        ID="saveOrEdit"
        runat="server">
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID   = '<%=Constants.PARM_PRACTITIONER_ID%>';
    let caseloadUpdates           = {};
    let $ctrlDgSvcs               = null;
    let $ctrlCaseloadUpdateStatus = null;
    let $ctrlSaveOrEdit           = null;

    <%/*---------------------------------------------------------------------------------------------------------------------*/%>

    function initDataGrid(newSvcs) {

        <%//#########################################%>
        <%//# Basics  %>
        <%//#########################################%>

        let opts = {};

        opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
        opts.enableSortControls        = false;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = false;
        opts.enableRowControlRecDelete = false;
        opts.enableRowControlDeleteAll = false;
        opts.enableRowControlRecClone  = false;
        opts.hasCopyForAll             = true;

        opts.saveModeAddNew = 'inlineunlockedfields';
        opts.saveModeEdit   = 'inline';
        opts.saveModeDelete = 'inlineunlockedfields';
        opts.saveModeClone  = 'inlineunlockedfields';

        opts.jsonInputHtml = '<textarea id="newsvcsjson" name="newsvcsjson" class="d-none" ></textarea>';
        opts.fieldDefinitions = [];
       
        <%//#########################################%>
        <%//# Field Definitions %>
        <%//#########################################%>

        <%//-----------------------------------------------------------------------------%>
        <%// Selected  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name: 'selected'
            , label: 'Add<br>to<br>Caseload?'
            , toolTip: 'Select if you wish to add this plan to your caseload'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: 'selected'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Patient ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name: 'patID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patID'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Patient Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Student<br>Last, First'
            , toolTip: 'Student'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patName'
            , saveUsing: 'patName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Service Code  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name: 'spEdServiceCode'
            , label: 'CALPADS<br>Code'
            , toolTip: 'CALPADS code'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'spEdServiceCode'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Service Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'spEdServiceName'
            , label: 'Service Name'
            , toolTip: 'SpEd Service Name'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceName'
            , saveUsing: 'spEdServiceName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Start Date %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name: 'startDateStr'
            , label: 'Plan<br>Start<br>Date'
            , toolTip: 'Services Start on'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'startDateStr'
            , sortUsing: 'startDate'
        });

        opts.fieldDefinitions.push({
              name: 'startDate'
            , label: 'Start Date'
            , toolTip: 'Services Start on'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'startDate'
            , sortUsing: 'startDate'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// End Date %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'endDateStr'
            , label: 'Plan<br>End<br>Date'
            , toolTip: 'Services End on'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'endDateStr'
            , sortUsing: 'endDate'
        });

        opts.fieldDefinitions.push({
            name: 'endDate'
            , label: 'End Date'
            , toolTip: 'Services End on'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'endDate'
            , sortUsing: 'endDate'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Frequency Code  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'spEdFreqCode'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdFreqCode'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Frequency Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'spEdFreqName'
            , label: 'Plan<br>Frequency'
            , toolTip: 'Frequency that services is provided'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdFreqName'
            , saveUsing: 'spEdFreqName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Minutes Per Frequency %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Duration <sub>(minutes)</sub>'
            , toolTip: 'Minutes per frequency'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'minsPerFreq'
            , sortUsing: 'minsPerFreq'            
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Frequency Code  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'spEdFreqCode'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdFreqCode'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Has Svc Lines Details  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'hasSvcLinesDetails'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasSvcLinesDetails'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Svc Lines Details JSON  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'svcLinesDetailsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'svcLinesDetailsJSON'
            , showMore: false
        });

        <%//#########################################%>
        <%//# Define creation complete handler       %>
        <%//#########################################%>

        opts.fnCreateComplete = function () {          
            $ctrlDgSvcs.MBA_DataGrid('preloadInlineUnlockedRows', newSvcs);
            $($ctrlSaveOrEdit).show();
        };

        <%//#########################################%>
        <%//# Create Grid %>
        <%//#########################################%>

        $ctrlDgSvcs.MBA_DataGrid(opts);

    }

    <%/*---------------------------------------------------------------------------------------------------------------------*/%>

    function getUpdates() {
      $ctrlCaseloadUpdateStatus.html('<p>Please wait updating caseload.  Do not close this window. <i class="fa fa-spinner fa-spin"></i></p>');
      let pracID     = $('#' + PARM_NAME_PRAC_ID).val();
      let clientID   = $('#' + PARM_NAME_CLIENT_ID).val();
      let reqURL     = '<%=Spedmon.PractitionerPatientCaseloadExpectedServices.URL_UPDATE_PLAN_INFO_ALL_BASE()%>'
      let reqDataObj = {};
      reqDataObj[PARM_NAME_CLIENT_ID] = clientID;
      reqDataObj[PARM_NAME_PRAC_ID] = pracID;
      let reqDataJSON = JSON.stringify(reqDataObj);
      MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
        .then(responseData => {            
            $($ctrlCaseloadUpdateStatus).html('');
            $($ctrlCaseloadUpdateStatus).removeClass('alert-warning');
            $($ctrlCaseloadUpdateStatus).addClass('alert-success');
            caseloadUpdates = JSON.parse(responseData.rawData.jsonData);
            let updateStatusMkup = ''
            updateStatusMkup = updateStatusMkup + '<p>' + caseloadUpdates.numUpdates + ' of the existing plans on your caseload have been updated.</p>';
            updateStatusMkup = updateStatusMkup + '<p>' + caseloadUpdates.numAutoAdds + ' new plans have been automatically added to your caseload.</p>';

            if (caseloadUpdates.hasNewSvcs == 1) {
                updateStatusMkup = updateStatusMkup + '<p>There are additional plans that can be added to your caseload.  Please select the plans you wish to add below and click Save & Proceed.</p>';
                initDataGrid(caseloadUpdates.newSvcs);
            }
            else {
                updateStatusMkup = updateStatusMkup + '<p>There are no additional plans available at this time that can be added to your caseload.</p>';
            }
            $($ctrlCaseloadUpdateStatus).html(updateStatusMkup);

            return;
        })
        .catch(responseData => {
            $($ctrlCaseloadUpdateStatus).html('<p>An unexpected problem has occurred.  Please try again.</p>');
            return;
        });
    };

    <%/*---------------------------------------------------------------------------------------------------------------------*/%>

    $(function () {
        $ctrlCaseloadUpdateStatus = $('#caseloadUpdateStatus');
        $ctrlSaveOrEdit           = $('#saveOrEdit');
        $ctrlDgSvcs               = $('#dataGridNewSvcsContainer');
        $($ctrlSaveOrEdit).hide();
        getUpdates();
    });


</script>