<%@ Page Language="C#" CodeBehind="user_all_service_records_view.aspx.cs" Inherits="Spedmon.UserAllServiceRecordsView" %>
 
<div id="servicerecords"></div>

<script>


/* Setup */

$(document).ready(function () {    

    let opts = {};
    opts.baseUrlView               = '<%=restViewURL%>';
    opts.baseUrlViewHasParameters  = true;
    opts.defaultPageRowOrder       = 'dos desc';
    opts.enableSortControls        = true;
    opts.enableRowNumbers          = true;
    opts.enableRowControls         = false;

    opts.fieldDefinitions = [];
    opts.fieldDefinitions.push({ name: 'id', isRecID:true});
    opts.fieldDefinitions.push({ name: 'dosStr', label: 'Date', visible: true, sortable:true, isRecID: false, dataType:'date', sortUsing:'dos' });
    opts.fieldDefinitions.push({ name: 'startTimeStr', label: 'Start<br>Time', visible: true, sortable: false, isRecID: false, dataType: 'time', sortUsing: 'startTimeVal', showMore: false });
    opts.fieldDefinitions.push({ name: 'endTimeStr', label: 'End<br>Time', visible: true, sortable: false, isRecID: false, dataType: 'time', sortUsing: 'endTimeVal', showMore: false });
    opts.fieldDefinitions.push({ name: 'svcName', label: 'Service Provided', visible: true, sortable: true, isRecID: false, dataType: 'string', sortUsing: 'svcName', showMore: false });
    opts.fieldDefinitions.push({ name: 'pracName', label: 'Provided By<br>Last, First', visible: true, sortable: true, isRecID: false, dataType: 'lastfirst', sortUsing: 'pracName', showMore: false});
    opts.fieldDefinitions.push({ name: 'numMins_tripsMiles', label: 'Minutes or<br>Trips/Miles', visible: true, sortable: true, isRecID: false, dataType: 'ratio', sortUsing: 'numMins', showMore: false});
    opts.fieldDefinitions.push({ name: 'isIFSPorIEPStr', label: 'Part<br>Of<br>IEP', visible: true, sortable: true, sortUsing:'isIFSPorIEP', isRecID: false, dataType: 'yesno', showMore: false });
    opts.fieldDefinitions.push({ name: 'attendanceStatusSelectionName', label: 'Attendance<br>Status', visible: true, sortable: true, sortUsing:'attendanceStatusSelectionName', isRecID: false, dataType: 'string', showMore: false });
    opts.fieldDefinitions.push({ name: 'notes', label: 'Notes', visible: true, sortable: false, isRecID: false, dataType: 'notes', showMore: true });
    
    $('#servicerecords').MBA_RestView(opts);



});

</script>