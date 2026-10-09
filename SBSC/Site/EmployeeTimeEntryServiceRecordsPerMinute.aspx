<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeTimeEntryServiceRecordsPerMinute.aspx.cs" Inherits="Spedmon.EmployeeTimeEntryServiceRecordsPerMinuteViewPage" %>


<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>



<div id="pageRowsContainerWFilters" class="container-fluid">

<div class="row">
<div class="col-12">
  <Spedmon:DateBoxRange id="daterange" name="daterange" title="Entry Date Range" showOK="false" runat="server" />
</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest Views %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-2">

<div class="col-12">

<div id="restViewRptRows"></div> <!-- restview -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $pageRowsContainerWFilters = null;
let $restViewRptRows_ProdPerMin = null;

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
    
  let VALUE_DATE_RANGE = $('#<%=Constants.PARM_DATE_RANGE%>').val();
  let NV_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject('<%=Constants.PARM_DATE_RANGE%>', VALUE_DATE_RANGE);  
  $($restViewRptRows_ProdPerMin).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);
  $($restViewRptRows_ProdPerMin).MBA_RestView('requestViewFromServer', 1);
};

function initViewRptRows()
{

  let opts = {};
  opts.loadModeView               = 'rest';

  opts.baseUrlView                = '<%=Spedmon.TimekeeperAccountabilityRpt.PER_MIN_RPT_REST_VIEW()%>';
  opts.baseUrlViewHasParameters   = true;

  //opts.defaultPageRowOrder       = '';

  opts.sessionTimeOutUrl          = '<%=MBA.Credential.generateSessionExpiredLink()%>';

  opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
  opts.enableSortControls         = true;
  opts.enableRowNumbers           = false;
  opts.enableRowControls          = true;
  opts.enableReports              = true;
  opts.enableReportHtml           = true;
  opts.enableReportXls            = true;
  opts.enableReportPdf            = false;
  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.TimekeeperAccountabilityRpt.URL_WEB_REPORT() %>';
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = '1';

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
          name: 'name'
        , label: 'Name'
        , toolTip: 'Name'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'name'

    });


  opts.fieldDefinitions.push({
          name: 'workDayStr'
        , label: 'Work Day'
        , toolTip: 'Daily time keeper work day'
        , visible: true
        , editable: false
        , saveable: false
        , sortable:  true
        , isRecID:   false
        , dataType: 'date'
        , sortUsing: 'workDay'

    });


  opts.fieldDefinitions.push({
          name: 'startTimeStr'
        , label: 'Start<br>Time'
        , toolTip: 'Start time recorded in daily time keeper'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'startTime'

    });

  opts.fieldDefinitions.push({
          name: 'endTimeStr'
        , label: 'End<br>Time'
        , toolTip: 'End time recorded in daily time keeper'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'endTime'

    });

  opts.fieldDefinitions.push({
          name: 'timeEntryTask'
        , label: 'Time Entry Task'
        , toolTip: 'Daily time keeper task selected'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'timeEntryTask'

    });

  opts.fieldDefinitions.push({
          name: 'timeEntryWorkBatch'
        , label: 'Work Batch'
        , toolTip: 'Work batch file name recorded in daily time keeper'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'timeEntryWorkBatch'
    });

  opts.fieldDefinitions.push({
          name: 'timeEntryNumMins'
        , label: 'Time<br>Entry<br>Minutes'
        , toolTip: 'Number of minutes recorded in Daily Time keeper'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'timeEntryNumMins'
    });

  opts.fieldDefinitions.push({
          name: 'svcRecsNumEntered'
        , label: 'Service<br>Records<br>Entered'
        , toolTip: 'Number of service records entered in SpEdCare on this workday between start and end time'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'svcRecsNumEntered'
    });

  opts.fieldDefinitions.push({
          name: 'entriesPerMinute'
        , label: 'Service<br>Record<br>Entries<br>Per<br>Minute'
        , toolTip: 'Service Record Entries Per Minute Calculated'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'entriesPerMinute'

    });

  opts.fieldDefinitions.push({
          name: 'timeEntryNote'
        , label: 'Time Entry Note'
        , toolTip: 'Note recorded in daily time keeper'
        , visible: true

        , editable: false
        , saveable: false

        , sortable: true
        , isRecID: false
        , dataType: 'text'

        , sortUsing: 'timeEntryNote'
    });

   /* Create the rest view */

   $($restViewRptRows_ProdPerMin).MBA_RestView(opts);

};



$(document).ready(function () {

   $pageRowsContainerWFilters    = $('#pageRowsContainerWFilters');
   $restViewRptRows_ProdPerMin   = $('#restViewRptRows');
   initViewRptRows();

   $($pageRowsContainerWFilters).on('spedmoninput spedmoninputdata', function (e) {
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
   });
   
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>


