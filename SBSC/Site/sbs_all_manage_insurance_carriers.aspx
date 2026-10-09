<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_manage_insurance_carriers.aspx.cs" Inherits="Spedmon.SBSAllManageInsuranceCarriers" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRows" class="container-fluid">
 
  <%//-----------------------------------------------------------------------------%>
  <%// Rest View %>
  <%//-----------------------------------------------------------------------------%>

  <div id="restViewContainerRow" class="row mt-3">
    <div class="col-12">
      <div id="restView"></div>
    </div> <!--col -->
  </div> <!--row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript"> 

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_ACTIVE = '1';

        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('restViewContainerRow', 1);
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = true;
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.InsuranceCarriers.URL_VIEW_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.InsuranceCarriers.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.InsuranceCarrier.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'carrierCode'
            , label: 'Carrier Code'
            , toolTip: 'Carrier Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'carrierCode'
            , saveUsing: 'carriercode'
            , showMore: false
            , styleAttrValueForCellValue: 'width:5em'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'carrierName'
            , label: 'Carrier Name'
            , toolTip: 'Carrier Name'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'name'
            , saveUsing: 'name'
            , showMore: false
            , styleAttrValueForCellValue: 'width:15em'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'ohcCode'
            , label: 'OHC Code'
            , toolTip: 'Other Health Care Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'ohcCode'
            , saveUsing: 'ohccode'
            , showMore: false
            , styleAttrValueForCellValue: 'width:4em'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        let plantypecodeFieldOptions = {}; 

        plantypecodeFieldOptions.selections = [
              { name: 'HMO', value: 'HMO' }
            , { name: 'PPO', value: 'PPO' }
            , { name: 'TPI', value: 'TPI' }
            , { name: 'PDP', value: 'PDP' }
            , { name: 'MAP', value: 'MAP' }
            , { name: 'TPD', value: 'TPD' }
            , { name: 'TPM', value: 'TPM' }
            , { name: 'TPP', value: 'TPP' }
            , { name: 'MSP', value: 'MSP' }
        ];

        opts.fieldDefinitions.push({
            name: 'planTypeCode'
            , label: 'Plan Type Code'
            , toolTip: 'plan type code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: plantypecodeFieldOptions
            , sortUsing: 'planTypeCode'
            , saveUsing: 'plantypecode'
            , showMore: false
            , styleAttrValueForCellValue: 'width:7em'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'planSupportedByCYBHI'
            , label: 'Plan Supported By CYBHI'
            , toolTip: 'Plan Supported By CYBHI'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: 'planSupportedByCYBHI'
            , saveUsing: 'plansupportedbycybhi'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        let usstateFieldOptions = {};

        usstateFieldOptions.selections = [
              { name: 'Alabama (AL)', value: 'AL' }
            , { name: 'Alaska (AK)', value: 'AK' }
            , { name: 'Arizona (AZ)', value: 'AZ' }
            , { name: 'Arkansas (AR)', value: 'AR' }
            , { name: 'California (CA)', value: 'CA' }
            , { name: 'Colorado (CO)', value: 'CO' }
            , { name: 'Connecticut (CT)', value: 'CT' }
            , { name: 'Delaware (DE)', value: 'DE' }
            , { name: 'District Of Columbia (DC)', value: 'DC' }
            , { name: 'Florida (FL)', value: 'FL' }
            , { name: 'Georgia (GA)', value: 'GA' }
            , { name: 'Hawaii (HI)', value: 'HI' }
            , { name: 'Idaho (ID)', value: 'ID' }
            , { name: 'Illinois (IL)', value: 'IL' }
            , { name: 'Indiana (IN)', value: 'IN' }
            , { name: 'Iowa (IA)', value: 'IA' }
            , { name: 'Kansas (KS)', value: 'KS' }
            , { name: 'Kentucky (KY)', value: 'KY' }
            , { name: 'Louisiana (LA)', value: 'LA' }
            , { name: 'Maine (ME)', value: 'ME' }
            , { name: 'Maryland (MD)', value: 'MD' }
            , { name: 'Massachusetts (MA)', value: 'MA' }
            , { name: 'Michigan (MI)', value: 'MI' }
            , { name: 'Minnesota (MN)', value: 'MN' }
            , { name: 'Mississippi (MS)', value: 'MS' }
            , { name: 'Missouri (MO)', value: 'MO' }
            , { name: 'Montana (MT)', value: 'MT' }
            , { name: 'Nebraska (NE)', value: 'NE' }
            , { name: 'Nevada (NV)', value: 'NV', }
            , { name: 'New Hampshire (NH)', value: 'NH' }
            , { name: 'New Jersey (NJ)', value: 'NJ' }
            , { name: 'New Mexico (NM)', value: 'NM' }
            , { name: 'New York (NY)', value: 'NY' }
            , { name: 'North Carolina (NC)', value: 'NC'}
            , { name: 'North Dakota (ND)', value: 'ND' }
            , { name: 'Ohio (OH)', value: 'OH' }
            , { name: 'Oklahoma (OK)', value: 'OK' }
            , { name: 'Oregon (OR)', value: 'OR' }
            , { name: 'Pennsylvania (PA)', value: 'PA' }
            , { name: 'Rhode Island (RI)', value: 'RI' }
            , { name: 'South Carolina (SC)', value: 'SC' }
            , { name: 'South Dakota (SD)', value: 'SD' }
            , { name: 'Tennessee (TN)', value: 'TN' }
            , { name: 'Texas (TX)', value: 'TX' }
            , { name: 'Utah (UT)', value: 'UT' }
            , { name: 'Vermont', value: 'VT' }
            , { name: 'Virginia', value: 'VA' }
            , { name: 'Washington', value: 'WA' }
            , { name: 'West Virginia', value: 'WV' }
            , { name: 'Wisconsin', value: 'WI' }
            , { name: 'Wyoming', value: 'WY' }
        ];

        opts.fieldDefinitions.push({
            name: 'usState'
            , label: 'US State'
            , toolTip: 'US State'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: usstateFieldOptions
            , sortUsing: 'usState'
            , saveUsing: 'usstate'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    };

    $(document).ready(function () {
        $restViewCtrl = $('#restView');
        initView();
    });

</script>