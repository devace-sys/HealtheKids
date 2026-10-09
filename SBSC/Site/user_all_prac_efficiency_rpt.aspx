<%@ Page Language="C#" CodeBehind="user_all_prac_efficiency_rpt.aspx.cs" Inherits="Spedmon.UserAllPracEfficiencyRpt" %>

<%//##################################################################################################################%>
<%//# Dashboard  %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid"> 
    
    <div class="row">

       <%//-----------------------------------------------------------------------------%>
       <%// Select End Date (As of Date) %>
       <%//-----------------------------------------------------------------------------%>

        <div class="col-auto">
           <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" title="As of Date" label="As of Date" setValueToToday="true" runat="server" />
        </div> <!-- col -->
        
        <%//-----------------------------------------------------------------------------%>
        <%// Blank cells notice %>
        <%//-----------------------------------------------------------------------------%>
 
        <div class="col-auto">
            <div class="alert alert-info">
            Please Note: <br />Blank cells indicate that<br /> the column is Non Applicable.
            </div> 
        </div> <!-- col -->

        <%//-----------------------------------------------------------------------------%>
        <%// Select Client %>
        <%// (Practi-Cal staff only) %>
        <%//-----------------------------------------------------------------------------%>
    
        <div class="col-auto">
            <Spedmon:DataEntryRowSelectClient
                ID              = "selectClient" 
                entityControlID = "clientid"                
                rowLabel        = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat           = "server">
            </Spedmon:DataEntryRowSelectClient>
        </div> <!-- col -->
        
        <%//-----------------------------------------------------------------------------%>
        <%// Select Reporting Group %>
        <%// (Non practitioner users only) %>
        <%//-----------------------------------------------------------------------------%>

        <div class="col-auto">
            <Spedmon:DataEntryRowSelectPractitionerReportingGroup
                ID                   = "selectReportingGroup" 
                rowLabel             = "Reporting Group"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectPractitionerReportingGroup>
        </div> <!-- col -->
        
        <%//-----------------------------------------------------------------------------%>
        <%// Select Practitioner %>
        <%// (Non practitioner users only) %>
        <%//-----------------------------------------------------------------------------%>

       <div class="col-auto">
            <Spedmon:DataEntryRowSelectPractitioner
                ID                                 = "selectPrac"
                rowLabel                           = "Practitioner"
                dataEntryRowRenderAs               = "FIELD"                
                entryNotAllowedUseReplacementValue = "false"
                runat                              = "server">
            </Spedmon:DataEntryRowSelectPractitioner>                      
        </div> <!-- col -->

    </div> <!-- row -->
    
    <%//-----------------------------------------------------------------------------%>
    <%// Rest View %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row"> 
      <div class="col-12">
        <div id="restviewpraceff"></div>
      </div> <!-- col -->
    </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows  = null;
    let $restViewCtrlPracEff = null;

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function getNameValueObjects() {
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_RPT_GROUP_ID%>", $("#<%=Constants.PARM_RPT_GROUP_ID%>"   ).val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_PRACTITIONER_ID%>", $("#<%=Constants.PARM_PRACTITIONER_ID%>").val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_END_DATE%>", $("#<%=Constants.PARM_END_DATE%>").val())
        ];
        return reqData;
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let reqDataObjs = getNameValueObjects();
        $.each(reqDataObjs, function (rdoIdx, reqDataObj) {
            $($restViewCtrlPracEff).MBA_RestView('additionalParameterDefinitionForViewSet', reqDataObj);
        });
        $($restViewCtrlPracEff).MBA_RestView('requestViewFromServer', 1);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initRestViewPracEff() {

            let opts = {};

            opts.hasColTitleReplacements    = true;
            opts.sessionTimeOutUrl          = '<%=MBA.Credential.generateSessionExpiredLink()%>';
            opts.requestViewOnLoad          = false;
            opts.enableSortControls         = true;
            opts.enableRowNumbers           = true;
            opts.enableRowControls          = true;
            opts.loadModeView = 'rest';
            opts.baseUrlView                = '<%=Spedmon.PractitionersEfficiency.URL_REST_VIEW()%>';
            opts.baseUrlViewHasParameters   = true;
            opts.defaultPageRowOrder        = '<%=Spedmon.PractitionerEfficiency.DEFAULT_PAGING_ORDER%>';
            opts.enableReports              = true;
            opts.enableReportHtml           = true;
            opts.enableReportXls            = true;
            opts.enableReportPdf            = false;
            opts.loadModeReport             = 'mbawebreport';
            opts.baseUrlReport              = '<%=Spedmon.ServicesByPracRpt.URL_ASHX_BASE()%>';
            opts.baseUrlReportHasParameters = true;
            opts.defaultReportNumber        = '<%=Spedmon.ServicesByPracRptTypes.EFFICIENCY.GetValueAsString()%>';

            opts.enableRowControlShowAdditionalInfo = true;

            opts.fieldDefinitions = [];
            opts.additionalInfoFieldDefinitions = [];

            opts.fieldDefinitions.push({
                name: 'reportingGroup'
              , label: 'Reporting Group'
              , toolTip: 'Reporting Group'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: true
              , isRecID: false
              , dataType: 'text'
              , sortUsing: 'reportingGroup'
            });

            opts.fieldDefinitions.push({
                name: 'pracName'
                , label: 'Practitioner'
                , toolTip: 'Last, First Name'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'text'
                , sortUsing: 'pracName'
            });
        
        opts.fieldDefinitions.push({
                  name: 'numSvcsWithoutNotes'
                , label: 'Number<br>of<br>Service<br>Records<br>Without<br>Notes'
                , toolTip: 'Number of service records entered without public notes'
                , visible: true
                , editable: false
                , saveable: false
                , sortable: true
                , isRecID: false
                , dataType: 'number'
                , sortUsing: 'numSvcsWithoutNotes'
        });
        
        opts.fieldDefinitions.push({
            name: 'c1'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:'c1'
        });

        opts.fieldDefinitions.push({
            name: 'c2'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement:true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing:'c2'
        });

        opts.fieldDefinitions.push({
              name: 'c3'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c3'
        });

        opts.fieldDefinitions.push({
            name: 'c4'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c4'
        });

        opts.fieldDefinitions.push({
            name: 'c5'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c5'
        });

        opts.fieldDefinitions.push({
              name: 'c6'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c6'
        });

        opts.fieldDefinitions.push({
            name: 'c7'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c7'
        });

        opts.fieldDefinitions.push({
            name: 'c8'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c8'
        });

        opts.fieldDefinitions.push({
            name: 'c9'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c9'
        });

        opts.fieldDefinitions.push({
            name: 'c10'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c10'
        });

        opts.fieldDefinitions.push({
            name: 'c11'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c11'
        });

        opts.fieldDefinitions.push({
            name: 'c12'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c12'
        });

        opts.fieldDefinitions.push({
            name: 'c13'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c13'
        });

        opts.fieldDefinitions.push({
            name: 'c14'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c14'
        });

        opts.fieldDefinitions.push({
            name: 'c15'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c15'
        });

        opts.fieldDefinitions.push({
            name: 'c16'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c16'
        });

        opts.fieldDefinitions.push({
            name: 'c17'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c17'
        });

        opts.fieldDefinitions.push({
            name: 'c18'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c18'
        });

        opts.fieldDefinitions.push({
            name: 'c19'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c19'
        });

        opts.fieldDefinitions.push({
            name: 'c20'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c20'
        });

        opts.fieldDefinitions.push({
            name: 'c21'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c21'
        });

        opts.fieldDefinitions.push({
            name: 'c22'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c22'
        });

        opts.fieldDefinitions.push({
            name: 'c23'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c23'
        });

        opts.fieldDefinitions.push({
            name: 'c24'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c24'
        });

        opts.fieldDefinitions.push({
            name: 'c25'
            , label: ''
            , toolTip: ''
            , hasColTitleReplacement: true
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'c25'
        });

        /**************** Additional info ****************/

        opts.additionalInfoFieldDefinitions.push({
            name: 'pracName'
            , label: 'Practitioner'
            , toolTip: 'Last, First Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pracName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'disciplineGroup'
            , label: 'Discipline'
            , toolTip: 'Discipline Group'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'disciplineGroup'
        });


        opts.additionalInfoFieldDefinitions.push({
            name: 'practiceFamily'
            , label: 'Practice Family'
            , toolTip: 'Practice Family'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'practiceFamily'
        });

        /*************** Cell tweaks ***************/

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {
                /* Add practitioner discipline group below name */
                if (fieldDefinition.name === 'pracName') {
                    $($newCellValue).append($('<br><sup>' + rowData.disciplineGroup + '</sup>'));
                }
            }
             /* Return cell new as required */
             return newCell;
         };

        $($restViewCtrlPracEff).MBA_RestView(opts);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {
        $dataManagementRows  = $('#dataManagementRows');
        $restViewCtrlPracEff = $('#restviewpraceff');

        initRestViewPracEff();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });
</script>