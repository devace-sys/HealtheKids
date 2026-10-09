<%@ Page Language="C#" CodeBehind="user_all_manage_rmts_activity_code_change_reasons.aspx.cs" Inherits="Spedmon.UserAllManageRmtsActivityCodeChangeReasons"%>

<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <div id="restView"></div>
        </div> <!-- col -->
    </div> <!-- row -->
</div> <!-- container -->



<script type="text/javascript">

    let $restViewCtrl = null;

    function initRestView() {

        let opts = {};

    opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
    opts.enableSortControls = true;
    opts.enableRowNumbers = true;
    opts.enableRowControls = true;
    opts.enableRowControlRecAddNew = true;
    opts.enableRowControlRecEdit = true;
    opts.enableRowControlRecDelete = true;

    opts.enableRowControlShowAdditionalInfo = false;
    opts.additionalInfoFieldDefinitions = [];

    opts.saveModeAddNew = 'inline';
    opts.baseUrlAddNew = '<%=Spedmon.RMTSActivityCodeChangeReasons.URL_REST_SAVE_INLINE()%>';
    opts.baseUrlAddNewHasParameters = true;

    opts.saveModeEdit = 'inline';
    opts.baseUrlEdit = '<%=Spedmon.RMTSActivityCodeChangeReasons.URL_REST_SAVE_INLINE()%>';
    opts.baseUrlEditHasParameters = true;

    opts.saveModeDelete = 'inline';
    opts.baseUrlDelete = '<%=Spedmon.RMTSActivityCodeChangeReasons.URL_REST_DELETE_INLINE()%>';
    opts.baseUrlDeleteHasParameters = true;

    opts.loadModeView = 'rest';
    opts.baseUrlView = '<%=Spedmon.RMTSActivityCodeChangeReasons.URL_REST_VIEW()%>';
    opts.baseUrlViewHasParameters = true;

    opts.loadModeReport = 'mbawebreport';
    opts.baseUrlReport = '<%=Spedmon.RMTSActivityCodeChangeReasons.URL_WEB_REPORT()%>';
    opts.baseUrlReportHasParameters = true;
    opts.defaultReportNumber = <%=Spedmon.RMTSActivityCodeChangeReasonsViw.REPT_NUM_VIEW%>;

    opts.enableReports = true;
    opts.enableReportHtml = true;
    opts.enableReportXls = true;
    opts.enableReportPdf = false;

    opts.fieldDefinitions = [];

        <%//-----------------------------------------------------------------------------%>
        <%// Record id %>
        <%//-----------------------------------------------------------------------------%>

		opts.fieldDefinitions.push({
            name: 'id',
            isRecID: true,
            saveable: false,
            saveUsing: 'recid'
        });
       
		
        <%//-----------------------------------------------------------------------------%>
        <%// Activity Code %>
        <%//-----------------------------------------------------------------------------%>


        let activityCodeOptions = {};

        activityCodeOptions.selections = [
              { name: '2A', value: '2A' }
            , { name: '2Z', value: '2Z' }
            , { name: '8',  value: '8' }
        ];

		 
		opts.fieldDefinitions.push({
              name: 'rmtsCodeValue'
            , label: 'Suggested Activity Code'
            , toolTip: 'Suggested activity code replacement'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: activityCodeOptions
            , sortUsing: 'rmtsCodeValue'
            , saveUsing: 'rmtsActivityCode'
            , showMore: false
        });

		<%//-----------------------------------------------------------------------------%>
        <%// Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Reason For Change'
            , toolTip: 'Reason for change'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'name'
            , saveUsing: 'name'
            , showMore: false
        });

        $($restViewCtrl).MBA_RestView(opts);

    };
 
$(window).on('load', function () {

      $restViewCtrl = $('#restView');
      initRestView();
      $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
  
});
  
</script>