;var MBA = (MBA || {});

function createElementFromHTML(htmlString) {
  var div = document.createElement('div');
  div.innerHTML = htmlString.trim();

  // Change this to div.childNodes to support multiple top-level nodes.
  return div.firstChild;
}


let $diaBulkSetDate =
   createElementFromHTML(
     '<div id="diaBulkSetDate" title="Bulk Update The Distributed Date">' +
       '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +

           '<h5>Select or enter the Distributed Date</h5>' +
         '</div>' +

         '<div id="data-entry-123" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<input type="date" id="bulkDistributionDate" name="distributionDate" class="data-entry-row-input w-90" />' +
         '</div>' +
       '</div>' +

     '</div>');


let $diaDepositDateClientInvoice =
   createElementFromHTML(
     '<div id="diaRemoveExceptionClientInvoice" title="Update the Deposit Date">' +
       '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' +
         '<div  class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +

           '<h5>Select or enter the Deposit Date</h5>' +

         '</div>' +
         '<div  class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<input type="date" id="depositDate" name="depositDate" class="data-entry-row-input" />' +
         '</div>' +

         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
           '<h5>Select or enter the Date of Distribution for Partner Shares</h5>' +

         '</div>' +

         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<input type="date" id="distributionDate" name="distributionDate" class="data-entry-row-input" />' +
         '</div>' +

       '</div>' +
       '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' +


         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
         '</div>' +

         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                           ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +  // empty div, empty col on the left.
         '</div>' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
            '<h5>Distribution Notes</h5>'  +
         '</div>' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                                ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<textarea type="text" id="distributionNotes" name="distributionNotes" title="Distribution Notes"' +
                                ' class="w-100 c" ></textarea>' +
         '</div>' +

       '</div>' +
      '</div>');


let $diaDateCollectedClientInvoice =
   createElementFromHTML(
     '<div id="diaRemoveExceptionClientInvoice" title="Update the Collected Date">' +
       '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
           '<h5>Select or enter the Collected Date</h5>' +
         '</div>' +
         '<div id="data-entry-123" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<input type="date" id="dateCollected" name="dateCollected" class="data-entry-row-input w-90" />' +
         '</div>' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
           '<h5>Amount Paid</h5>'  +
         '</div>' +

         '<div id="data-entry-123" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<span>$ </span><input type="text" id="amountPaid" name="amountPaid" title="Amount Paid" ' +
                                ' value = "0" class="w-90 currencyInput data-entry-row-input" />' +
         '</div>' +

       '</div>' +
       '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' + 
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
         '</div>' +

         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                           ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +  // empty div, empty col on the left.
         '</div>' +
         '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +
           '<h5>Balance</h5>'  +
         '</div><div id="data-entry-1234" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                                ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +
           '<span>$ </span><input type="text" id="balanceAmount" name="balanceAmount" title="Balance"' +
                                ' class="w-90 currencyInput data-entry-row-input" readonly="readonly"></div>' +
         '</div>' +
       '</div>');

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientInvoicesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.ClientInvoicesCommon = (function ($)
{


'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME           = 'Invoices Common Methods';
const _THIS_NS             = 'mba-client-invoices'
const _JQ_DATA_NAME        = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE      = 'data-' + _THIS_NS;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS  = {
     PARM_NAME_CLIENT_ID   : 'clientid'
  ,  PARM_NAME_DATE_RANGE  : 'daterange'
  ,  PARM_NAME_INVOICE_PAID: 'invoicepaid'
  ,  containerCtrlID       : ''
  ,  sessionTimeOutUrl     : ''
  ,  baseUrlView           : ''
  ,  defaultPageRowOrder   : ''
  ,  baseUrlAddNew         : ''
  ,  baseUrlEdit           : ''
  ,  baseUrlDelete         : '' 


  ,  urlGetTotals          : ''

  ,  reportBaseUrl         : ''

  ,  baseUrlBulkEdit       : ''

     //
  ,  isPcalStaff           : false
  ,  showClientName        : true
  ,  showConsultantName    : false

  ,  allowBulkEdit         : false

  ,  userCanSeePartnerData: false

  ,  showBasicInvoiceData : true

  ,  showDistBreakdownsDollarAmounts: false  // NOTE: a bit spaghettiish... I can't think of any reason we would have 1 enabled and not the other.  maybe fix later
  ,  calcShares                     : false

  ,  fnOnAfterCreate : function(elem, dataObj, $cols) { return; }
  ,  fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMe
 * @private
 * @summary      Gets reference to original elemementid
 * @description  Gets reference to original elemementid
 * @param  {Object}  elem  Element reference
 */

let _fnGetMe = function (elementid) { 
  return $('#' + elementid); 
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataObj
 * @private
 * @summary      Gets reference to data object
 * @description  Gets reference to the jQuery data object associated with this element
 * @param  {Object}  $me  Element reference
 */
 
let _fnGetDataObj = function ($me)  { 
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _THIS_NAME +' is required');
  return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetDataObj
 * @private
 * @summary      Sets value of data object
 * @description  Sets value of data object
 * @param  {Object}  $me      Element reference
 * @param  {Object}  dataObj  Data obj for this lib
 */

let _fnSetDataObj = function ($me, dataObj) {
  $($me).data(_JQ_DATA_NAME, dataObj);
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _createRestView = function ($me, optsIn) 
{
   
    let opts = optsIn;
    
    opts.sessionTimeOutUrl          = optsIn.sessionTimeOutUrl;
    opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
    opts.enableSortControls         = true;
    opts.enableRowNumbers           = false; /* Turn off row numbers */
    opts.enableRowControls          = true;
    opts.enableRowControlRecAddNew  = false;
    opts.enableRowControlRecEdit = false;

    if (optsIn.isPcalStaff == true) { opts.enableRowControlRecEdit = true; }

    opts.enableRowControlRecDelete = false;
    
    opts.loadModeView               = 'rest';
    opts.baseUrlView                = optsIn.baseUrlView;
    opts.baseUrlViewHasParameters   = true;
    opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;
    
    opts.saveModeAddNew             = 'inline';
    opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
    opts.baseUrlAddNewHasParameters = true;
    
    opts.saveModeEdit               = 'inline';
    opts.baseUrlEdit                = optsIn.baseUrlEdit;
    opts.baseUrlEditHasParameters   = true;
    
    opts.saveModeDelete             = 'inline';
    opts.baseUrlDelete              = optsIn.baseUrlDelete;
    opts.baseUrlDeleteHasParameters = true;

    if  (opts.allowBulkEdit)
      opts.enableRowControlMarkRow = true ;

    opts.enableReports    = true;
    opts.enableReportHtml = true;
    opts.enableReportXls  = true;
    opts.enableReportPdf  = false;

    opts.loadModeReport             = 'mbawebreport';
    opts.baseUrlReport              = optsIn.reportBaseUrl;
    opts.baseUrlReportHasParameters = true;
    opts.defaultReportNumber        = '1';

    opts.fieldDefinitions = [];
    opts.additionalControlDefinitionsForBodyRows = new Map();
    
    opts.fieldDefinitions.push({
         name: 'id'
       , isRecID: true
       , saveable: true
       , saveUsing: 'recid'
    });

    opts.fieldDefinitions.push({
        name: 'clientID'
        , label: 'Client ID'
        , toolTip: 'Client ID'
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , saveUsing: 'clientid'
        , sortUsing: ''
        , additionalCssClassesForCol: 'px-2'
    });

    if (optsIn.isPcalStaff == true) {
        
	        if (optsIn.showClientName == true) {
	            opts.fieldDefinitions.push({
	                name: 'clientName'
	                , label: 'Client'
	                , toolTip: 'Client'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: true
	                , isRecID: false
	                , dataType: 'text'
	                , saveUsing: ''
	                , sortUsing: 'clientName'

	            });
	        }   //  end-if showClientName

	        if (opts.showConsultantName == true) {
	            opts.fieldDefinitions.push({
	                name: 'consultant'
	                , label: 'Consultant'
	                , toolTip: 'Consultant'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'text'
	                , saveUsing: ''
	                , sortUsing: 'consultant'
	                , additionalCssClassesForCol: 'px-2'
	            });
	        }  //  end-if showConsultantName


	        if (optsIn.userCanSeePartnerData == true) {
                 if (!(optsIn.isCybhiDistScreen))  
	            opts.fieldDefinitions.push({
	                name: 'revenueCode'
	                , label: 'Revenue<br>Code'
	                , toolTip: 'Revenue Code'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: true
	                , isRecID: false
	                , dataType: 'text'
	                , saveUsing: ''
	                , sortUsing: 'revenueCode'
	                , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'revenueProgram'
	                , label: 'Revenue<br>Program'
	                , toolTip: 'Revenue Program'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: true
	                , isRecID: false
	                , dataType: 'text'
	                , saveUsing: ''
	                , sortUsing: 'revenueProgram'
	                , additionalCssClassesForCol: 'px-2'
	            });


	        }  //  end-if userCanSeePartnerData

    } //  end-if pcallStaff


    opts.fieldDefinitions.push({
        name: 'invoiceNum'
        , label: 'Invoice<br>Number'
        , toolTip: 'Invoice Number'
        , visible: true
        , editable: false
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , saveUsing: 'invoicenum'
        , sortUsing: 'invoiceNum'
        , additionalCssClassesForCol: 'px-2'
    });

    
    opts.fieldDefinitions.push({   //  hidden
         name: 'invoiceAmt'
         , label: 'Amount'
         , toolTip: 'Amount'
         , visible: false
         , editable: false
         , saveable: false
         , sortable: false
         , isRecID: false
         , dataType: 'hidden'     //
         , saveUsing: ''
         , sortUsing: ''
    });

    opts.fieldDefinitions.push({
        name: 'amountPaid'
        , label: 'Amount Paid'
        , toolTip: 'AmountPaid'
        , visible: false
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , saveUsing: ''
        , sortUsing: ''
    });

    // if (opts.showBasicInvoiceData) {

    opts.fieldDefinitions.push({                //  NOT hidden
	        name: 'invoiceAmt'

	        , label: 'Amount Invoiced'
                           +  '<br/><span id="invoiceAmtColSum"></span>'

	        , toolTip: 'Amount Invoiced'

	        , visible:  (  optsIn.inclPartner1Col ||
                  opts.showBasicInvoiceData  )  //  if showBasicInvoiceData  OR  showBasicInvoiceData

	        , editable: false
	        , saveable: true
	        , sortable: true
	        , isRecID: false
	        , dataType: 'usd'
	        , saveUsing: 'invoiceamt'
	        , sortUsing: 'invoiceAmt'

            , additionalCssClassesForCol: 'px-2'
    });


	    opts.fieldDefinitions.push({
	        name: 'invoiceDateStr'
	        , label: 'Date<br>Invoiced'
	        , toolTip: 'Date Invoiced'

	        , visible: opts.showBasicInvoiceData

	        , editable: false
	        , saveable: true
	        , sortable: true
	        , isRecID: false
	        , dataType: 'date'
	        , saveUsing: 'invoicedate'
	        , sortUsing: 'invoiceDate'
            , additionalCssClassesForCol: 'px-2'
	    });

	    opts.fieldDefinitions.push({
	        name: 'dateCollectedStr'
	        , label: 'Date<br>Collected'
	        , toolTip: 'Date Collected'

	        //, visible: opts.showBasicInvoiceData
            , visible: true

	        , editable: false
	        , saveable: true
	        , sortable: true
	        , isRecID: false
	        , dataType: 'date'
	        , saveUsing: 'datecollected'
	        , sortUsing: 'dateCollected'
            , additionalCssClassesForCol: 'px-2'
	    });
  

	    opts.fieldDefinitions.push({
	            name: 'depositDateStr'
	            , label: 'Deposit<br>Date'
	            , toolTip: 'Deposit Date'

	            , visible: optsIn.userCanSeePartnerData

	            , editable: false
	            , saveable: false
	            , sortable: false
	            , isRecID: false
	            , dataType: 'date'
	            , saveUsing: 'depositdate'
	            , sortUsing: 'depositDate'
                , additionalCssClassesForCol: 'px-2'
	        });



                    opts.fieldDefinitions.push({
	              name: 'distributedDateStr'
	              , label: 'Distributed Date'
	              , toolTip: ''

  	              , visible: ( !opts.showDistBreakdownsDollarAmounts && opts.userCanSeePartnerData && opts.showDistBreakdownsDollarAmounts ) 

	              , editable: false
	              , saveable: false
	              , sortable: false
	              , isRecID: false
	              , dataType: 'date'
	              , saveUsing: ''
	              , sortUsing: ''
                  , additionalCssClassesForCol: 'px-2'
	          });


        //debugger;

                  if ( optsIn.userCanSeePartnerData
                        && ( optsIn.inclPartner1Col  ||  opts.showDistBreakdownsDollarAmounts )
                  ) {

	               opts.fieldDefinitions.push({
	            name: 'spEdCareShare'

	            , label: 'SpEdCare<br/>Share<br/>' +
                             '<span id="spedCareShareColSum"></span>'

	            , toolTip: 'SpEdCare Share'
	            , visible: false   // ???
	            , editable: false
	            , saveable: true
	            , sortable: false
	            , isRecID: false
	            , dataType: 'usd'
	            , saveUsing: 'spedcareshare'
	            , sortUsing: 'spEdCareShare'
                , additionalCssClassesForCol: 'px-2'
	            });

     
	            opts.fieldDefinitions.push({
	            name: 'pcalShare'

	            , label: 'Practi-Cal<br>Share<br/>' +
                            '<span id="practiCalShareColSum"></span>'

	            , toolTip: 'Practi-Cal Share'
	            , visible: false
	            , editable: false
	            , saveable: true
	            , sortable: false
	            , isRecID: false
	            , dataType: 'usd'
	            , saveUsing: 'pcalshare'
	            , sortUsing: 'pcalShare'
                , additionalCssClassesForCol: 'px-2'
	            });

                // debugger;

                if (!(optsIn.isCybhiDistScreen) ) { 


	            opts.fieldDefinitions.push({
	                name: 'accountingFee'

	                , label: 'Accounting<br>Fee<br/>' +
                                '<span id="acctFeeColSum"></span>'

	                , toolTip: 'Account Fee'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

                }

                  }

                  if ( optsIn.userCanSeePartnerData && optsIn.inclPartner1Col ) {

        	        opts.fieldDefinitions.push({
	                name: 'revShare'

	                , label: 'Rev Share<br/>' +
                                '<span id="revShareColSum"></span>'

	                , toolTip: 'Rev Share'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

        	        opts.fieldDefinitions.push({
	                name: 'partner1Share'

	                , label: 'Partner 1<br>Share<br/>' +
                                '<span id="partner1ShareColSum"></span>'

	                , toolTip: 'Partner 1 Share'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

        	        opts.fieldDefinitions.push({
	                name: 'partner2Share'

	                , label: 'Partner 2<br>Share<br/>' +
                                '<span id="partner2ShareColSum"></span>'

	                , toolTip: 'Partner 2 Share'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });
                   }        // end-if userCanSeePartnerData AND inclPartn1Col
         
                   else if ( optsIn.userCanSeePartnerData && opts.showDistBreakdownsDollarAmounts ) {
                                                      // TODO!! figure out the difference between opts. and optsIn.
                                                      //        this may require additnl testing, bugfixing, code cleanup


	            opts.fieldDefinitions.push({
	                name: 'partnerRevenue'

	                , label: 'LEA BOP<br>Revenue<br/>' +
                                '<span id="partnerRevenueShareColSum"></span>'

	                , toolTip: 'LEA BOP Revenue'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });


	            opts.fieldDefinitions.push({
	                name: 'partnerShareRevenue'

	                , label: 'Partner Share<br>Revenue<br/>' +
                                '<span id="partnerShareRevenueColSum"></span>'  // NOT TO BE CONFUSED WITH partnerRevenueShareColSum

	                , toolTip: 'Partner Share Revenue'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'csbaShare'

	                , label: 'CSBA<br>Share<br/>' +
                                '<span id="csbaShareColSum"></span>'

	                , toolTip: 'CSBA Share'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'lbaShare'

	                , label: 'LBA<br>Share<br/>' +
                                '<span id="lbaShareColSum"></span>'

	                , toolTip: 'LBA Share'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'mbaShare'
	                , label: 'MBA<br/>Share<br/>' +
                                  '<span id="mbaShareColSum"></span>'

	                , toolTip: 'MBA Share'

	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'mbaBba'

	                , label: 'MBA BBA/DG<br/>' +
                                '<span id="mbaBbaColSum"></span>'

	                , toolTip: 'MBA BBA'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

                if  ( opts.showDistBreakdownsDollarAmounts  ) 
                 

		            opts.fieldDefinitions.push({
		                name: 'spEdCarePartners'

		                , label: 'SpEdCare<br>Share<br/>' +
	                                '<span id="spedcarePartnersShareColSum"></span>'

		                , toolTip: 'SpEdCare Partners Share'
		                , visible: true
		                , editable: false
		                , saveable: false
		                , sortable: false
		                , isRecID: false
		                , dataType: 'usd'
		                , saveUsing: ''
		                , sortUsing: ''
	                    , additionalCssClassesForCol: 'px-2'
		            });

	            opts.fieldDefinitions.push({
	                name: 'spEdCareBba'

	                , label: 'SpEdCare BBA/DG<br/>' +
                                '<span id="spedCareBbaColSum"></span>'

	                , toolTip: 'spEdCare BBA'
	                , visible: true
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

	            opts.fieldDefinitions.push({
	                name: 'partner2Share'

	                , label: 'Partner 2<br>Share<br/>' +
                                '<span id="partner2ShareColSum"></span>'

	                , toolTip: 'Partner 2 Share'
	                , visible: false
	                , editable: false
	                , saveable: false
	                , sortable: false
	                , isRecID: false
	                , dataType: 'usd'
	                , saveUsing: ''
	                , sortUsing: ''
                    , additionalCssClassesForCol: 'px-2'
	            });

                    opts.fieldDefinitions.push({
	              name: 'distributedDateStr'

	              , label: 'Distributed Date' 
           

	              , toolTip: ''

  	              , visible: optsIn.userCanSeePartnerData  

	              , editable: false
	              , saveable: false
	              , sortable: false
	              , isRecID: false
	              , dataType: 'date'
	              , saveUsing: ''
	              , sortUsing: ''
                  , additionalCssClassesForCol: 'px-2'
	          });

              }   // ...

    // debugger;

    if (optsIn.isPcalStaff == true) {

        if  ( opts.inclRetentionCol )
          opts.fieldDefinitions.push({
              name: 'clientRetention'
              , label: 'Client<br/>Retention'
              , toolTip: 'Client Retention'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: false
              , isRecID: false
              , dataType: 'text'
              , saveUsing: 'clientRetention'
              , sortUsing: 'clientRetention'
          });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
        });

        //
        opts.fieldDefinitions.push({
            name: 'distributionNotes'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: ''
        });



    } /* pcal staff*/

    opts.fnOnAfterCreate            = optsIn.fnOnAfterCreate;
    opts.fnOnResponseViewFromServer = optsIn.fnOnResponseViewFromServer;

    opts.additionalControlDefinitionsForHeadRows = new Map();
    if (opts.allowBulkEdit)
      opts.additionalControlDefinitionsForHeadRows.set('bulkMarkDistDate', {
	        defType: 'userprovided'
	        , name: 'bulkMarkDistDate'
	        , toolTip: 'Click here to bulk mark the distribution paid date.'
	        , cssClass: 'fas fa-calendar-check bulk-edit-btn btn'
	        , handlerFn: function (uiActionObj) {

                // alert('hi');

	            // debugger; 

                openBulkSetDateDialog( uiActionObj, opts );

                return uiActionObj;
	        }
	        , initiallyHidden: false
      });


    opts.additionalControlDefinitionsForBodyRows = new Map();
    if ( opts.userCanSeePartnerData && opts.showBasicInvoiceData ) {                       //
        // Date collected
        opts.additionalControlDefinitionsForBodyRows.set('collectedDateUpdate', {
            defType: 'userprovided'
            , name: 'collectedDateUpdate'
            , toolTip: 'Click here to Update the Collection Date'
            , cssClass: 'fas fa-dollar-sign text-success'
            , handlerFn: function (uiActionObj) {
                openInvoiceClientInvoiceDialog( uiActionObj, opts, false, optsIn.pmtInfoUrl  );
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        // Date deposited (note: added a date deposited field)

        opts.additionalControlDefinitionsForBodyRows.set('depositDateUpdate', {
            defType: 'userprovided'
            , name: 'depositDateUpdate'
            , toolTip: 'Click here to Update the Deposit Date'
            , cssClass: 'fas fa-calendar-check text-primary'
            , handlerFn: function (uiActionObj) {

                openInvoiceClientInvoiceDialog( uiActionObj, opts, true, optsIn.depositInfoUrl  );

                return uiActionObj;
            }
            , initiallyHidden: false
        });
    }
    /* Create the rest view */

    $($me).MBA_RestView(opts);
	return;
};

    function openBulkSetDateDialog(uiActionObj, opts) {

        //debugger;

        initDiaDepositDateClientInvoice();
        initDiaDateCollectedClientInvoice();

        initDiaBulkSetDate();

///

        var dialog = $diaBulkSetDate ;
        $(dialog).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , open: function (event, ui) {          
                
            }
            , close: function (event, ui) {
                initDiaDepositDateClientInvoice();
                initDiaDateCollectedClientInvoice();  //

                initDiaBulkSetDate();
            }
            , buttons: [
                { text: "Cancel", click: function () { $(dialog).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        //
                        doBulkUpdateMulti(uiActionObj, dialog, opts);
                    }
                }
            ]
        };

        $(dialog).dialog(diaOpts);
    };

    /**************************************************************************************************************************/


    let doBulkUpdateMulti = function (uiActionObj, dialog, opts) {   //
        
        // let dataObj = _fnGetDataObj(uiActionObj.me);

        let _recIDs = '';
        _recIDs = MBA.RestViewCommon.fnGetMarkedRowsRecordIDsAsCsvStr(uiActionObj.me);

        if (_recIDs == '') return;

        let VALUE_CLIENT_ID = $('#' + opts.PARM_NAME_CLIENT_ID ).val();

        let _reqObj = {};
        _reqObj.recids   = _recIDs;
        _reqObj.clientid = VALUE_CLIENT_ID;
        _reqObj.distbpaid = $('#bulkDistributionDate').val();
        
        let _requestDataJSON = JSON.stringify(_reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
          opts.baseUrlBulkEdit   ,
          _requestDataJSON  ,
          opts.sessionExpiredUrl )
            .then(responseData => {
                $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer', 1);

                //
                $(dialog).dialog('close');

                // let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');
                // MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);

            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Update Record(s)', err.message, {});
            });
    };

    /**************************************************************************************************************************/

    // TODO: function name (existing code) is a bit mis-named.  Consider refactoring later
    function openInvoiceClientInvoiceDialog(uiActionObj, opts, isInvoiceUpdate, postUrl) {

        initDiaDepositDateClientInvoice();
        initDiaDateCollectedClientInvoice();  //

        initDiaBulkSetDate();

///

        var dialog = isInvoiceUpdate ? $diaDepositDateClientInvoice : $diaDateCollectedClientInvoice;
        $(dialog).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , open: function (event, ui) {

                // debugger;
                if (!isInvoiceUpdate) {
                    // row data from uiActioObj
                    var amtPaid = uiActionObj.whatFieldNameValues.amountPaid == 0 ? uiActionObj.whatFieldNameValues.invoiceAmt : uiActionObj.whatFieldNameValues.amountPaid;
                    $('#amountPaid').val(amtPaid);

                    // debugger;

                    FormatMoney($('#amountPaid'));

                    // row data from uiActioObj
                    UpdateBalnceAmount(uiActionObj.whatFieldNameValues.invoiceAmt, $('#amountPaid').val());

                    // currency input formatter
                    $('input.currencyInput').on("change", function (event) {

                        //validate and format the input
                        FormatMoney($(this));
                    });

                    $('#amountPaid').change(function (event) {
                        UpdateBalnceAmount(uiActionObj.whatFieldNameValues.invoiceAmt, $(this).val());
                    });
                }




            }
            , close: function (event, ui) {
                initDiaDepositDateClientInvoice();
                initDiaDateCollectedClientInvoice();  //

                initDiaBulkSetDate();
            }
            , buttons: [
                { text: "Cancel", click: function () { $(dialog).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        //
                        sendInvoiceUpdateFromDialog(uiActionObj, opts, isInvoiceUpdate, postUrl);
                    }
                }
            ]
        };

        $(dialog).dialog(diaOpts);

        // debugger;


          
        if ( isInvoiceUpdate ) {

          // debugger;
          
          if ( uiActionObj.whatFieldNameValues.depositDateStr ) { 
            var now = new Date(uiActionObj.whatFieldNameValues.depositDateStr);    // todo: fix UGLY UGLY code here
            var day = ("0" + now.getDate()).slice(-2);
            var month = ("0" + (now.getMonth() + 1)).slice(-2);
            var depositDate = now.getFullYear() + "-" + (month) + "-" + (day);
            $('#depositDate').val(depositDate);
          }

          if ( uiActionObj.whatFieldNameValues.distributedDateStr ) { 

            var now = new Date(uiActionObj.whatFieldNameValues.distributedDateStr);    // todo: fix UGLY UGLY code here
            var day = ("0" + now.getDate()).slice(-2);
            var month = ("0" + (now.getMonth() + 1)).slice(-2);
            var distributedDate = now.getFullYear() + "-" + (month) + "-" + (day);
            $('#distributionDate').val(distributedDate);

          }

          $('#distributionNotes').val(
            uiActionObj.whatFieldNameValues.distributionNotes
          );

        }

        if (!isInvoiceUpdate && uiActionObj.whatFieldNameValues.dateCollectedStr) {
            var now = new Date(uiActionObj.whatFieldNameValues.dateCollectedStr);
            var day = ("0" + now.getDate()).slice(-2);
            var month = ("0" + (now.getMonth() + 1)).slice(-2);
            var collectedDate = now.getFullYear() + "-" + (month) + "-" + (day);
            $('#dateCollected').val(collectedDate);
        }

    }
/**************************************************************************************************************************/

    function sendInvoiceUpdateFromDialog(uiActionObj, opts, isInvoiceUpdate, postUrl) {

        let reqObj = {};
        var dialog = isInvoiceUpdate ? $diaDepositDateClientInvoice : $diaDateCollectedClientInvoice;

        var depositDate =    $('#depositDate').val();
        var dateCollected =  $('#dateCollected').val();  // .val() returns undef if the elem does not exist

        reqObj.amountpaid =  $('#amountPaid').val();
        reqObj.distributionnotes =  $('#distributionNotes').val();
        reqObj.distributeddate  =  $('#distributionDate').val();

        reqObj.recid = uiActionObj.recordID;
        reqObj.clientid = uiActionObj.whatFieldNameValues.clientID;
        reqObj.patid = uiActionObj.whatFieldNameValues.patID;
        reqObj.depositdate = depositDate;
        reqObj.datecollected = dateCollected;

        reqObj.savetype = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;


        let reqJSON = JSON.stringify(reqObj);
          // stringify auto-removes undef key-vals from the obj

        

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod( postUrl, reqJSON, null )
            .then(responseData => {
                $(dialog).dialog('close');
                MBA.RestViewCommon.fnRefreshCurrentViewFromServer($('#' + uiActionObj.dataObj.meID));
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaDepositDateClientInvoice();
                initDiaDateCollectedClientInvoice();

                initDiaBulkSetDate();
            })
            .catch(responseData => {

            });

    };
 /**************************************************************************************************************************/

    function initDiaBulkSetDate() {
        $('input',     $diaDateCollectedClientInvoice).val('');
        $('textarea',  $diaDateCollectedClientInvoice).val('');

        $('input',  $diaBulkSetDate).val('');

        $($diaBulkSetDate).dialog('destroy');
        $($diaBulkSetDate).hide();
    };

    function initDiaDepositDateClientInvoice() {

        $('input',     $diaDepositDateClientInvoice).val('');
        $('textarea',  $diaDepositDateClientInvoice).val('');

        $('input',  $diaBulkSetDate).val('');

        $($diaDepositDateClientInvoice).dialog('destroy');
        $($diaDepositDateClientInvoice).hide();
    };

    function initDiaDateCollectedClientInvoice() {
        $('input',     $diaDateCollectedClientInvoice).val('');
        $('textarea',  $diaDateCollectedClientInvoice).val('');

        $('input',  $diaBulkSetDate).val('');

        $($diaDateCollectedClientInvoice).dialog('destroy');
        $($diaDateCollectedClientInvoice).hide();
    };

    function UpdateBalnceAmount(invoiceAmount, amountPaid) {

        // debugger;

        var invoiceValNoComma = invoiceAmount.replace(/,/g, '').replace(/\$/g, '');

        var inputValNoComma = amountPaid.replace(/,/g, '').replace(/\$/g, '');
        var p = parseFloat( invoiceValNoComma - inputValNoComma).toFixed(2).split(".");

        var formattedInput = p[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + "." + p[1];

        if (formattedInput == 'NaN.undefined')
            formattedInput = 0;
        $(this).val(formattedInput);
        $('#balanceAmount').val(formattedInput);
    };
    function FormatMoney($me) {
        var inputVal = $($me).val();

        // debugger;

        if (inputVal) {
            var inputValNoComma = inputVal.replace(/,/g, '').replace(/\$/g, '');
            var p = parseFloat(inputValNoComma).toFixed(2).split(".");
            var formattedInput = p[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + "." + p[1];

            if (formattedInput == 'NaN.undefined')
                formattedInput = 0;
            $($me).val(formattedInput);
        }
    };
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me, opts) 
{
    let dataObj = _fnGetDataObj($me);
    let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val(); 

    let VALUE_DISTRIBUTION_PAID = ($('#' + dataObj.opts.PARM_NAME_DISTRIBUTION_PAID).length > 0)
        ? $('#' + dataObj.opts.PARM_NAME_DISTRIBUTION_PAID).val()
        : ''; // for cases where date range doesn't exist
    
    let VALUE_DATE_RANGE = ($('#' + dataObj.opts.PARM_NAME_DATE_RANGE).length > 0)
        ? $('#' + dataObj.opts.PARM_NAME_DATE_RANGE).val()
        : ''; // for cases where date range doesn't exist

    //let VALUE_DISTB_PAID_DATE_RANGE = ($('#distbpaiddaterange').length > 0)   // NOTE: hardcoding fieldname here, oh well
    //    ? $('#distbpaiddaterange').val()
    //    : ''; // for cases where date range doesn't exist


    let VALUE_INV_COLL_DATE_RANGE = ($('#invcolldaterange').length > 0)   // NOTE: hardcoding fieldname here, oh well
        ? $('#invcolldaterange').val()
        : ''; // for cases where date range doesn't exist

    let VALUE_INVOICE_PAID = ($('#' + dataObj.opts.PARM_NAME_INVOICE_PAID).length > 0)
        ? $('#' + dataObj.opts.PARM_NAME_INVOICE_PAID).val()
        : ''; // for cases where date range doesn't exist
    
    let NV_CLIENT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID   , VALUE_CLIENT_ID);
    let NV_DATE_RANGE   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_DATE_RANGE  , VALUE_DATE_RANGE);
    let NV_INVOICE_PAID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_INVOICE_PAID, VALUE_INVOICE_PAID);

    let NV_DISTRIBUTION_PAID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_DISTRIBUTION_PAID, VALUE_DISTRIBUTION_PAID);

    // let NV_DISTB_PAID_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject( 'distbpaiddaterange' ,  VALUE_DISTB_PAID_DATE_RANGE );  // hardcoding here...


    let NV_COLL_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject( 'invcolldaterange' ,  VALUE_INV_COLL_DATE_RANGE );  // hardcoding here...


    let NV_CALC_SHARES = MBA.RestViewCommon.fnCreateNameValueObject( "calcshares", opts.calcShares );

    let NV_INCL_PARTN1  = MBA.RestViewCommon.fnCreateNameValueObject( "inclpartner1col",  opts.inclPartner1Col );
    let NV_INCL_CYBHI   = MBA.RestViewCommon.fnCreateNameValueObject( "inclcybhirows",    opts.inclCybhiRows );

    let NV_INCL_CYBHI_ONLY   = MBA.RestViewCommon.fnCreateNameValueObject( "inclcybhirowsonly", 
      ( opts.inclCybhiRowsOnly ? opts.inclCybhiRowsOnly : 0 ) );


    let NV_IS_CYBHI_DISTSCREEN = MBA.RestViewCommon.fnCreateNameValueObject( "iscybhidistscreen", opts.isCybhiDistScreen);
      // this is used only for the dynamic show/hide logic in the .viewTbl() method; not used in the .viewObjects() (or .view() )

    let NV_INCL_RETNTN   = MBA.RestViewCommon.fnCreateNameValueObject( "inclretentioncol",    opts.inclRetentionCol );



    let NV_SHOW_CLIENTNAME = MBA.RestViewCommon.fnCreateNameValueObject( "showclientname", opts.showClientName );
    let NV_SHOW_CONSULTANTNAME = MBA.RestViewCommon.fnCreateNameValueObject( "showconsultantname", opts.showConsultantName );

//    let NV_USER_CANSEEPARTNER = MBA.RestViewCommon.fnCreateNameValueObject(  "userCanSeePartnerData" ...


    let NV_SHOW_BASIC_INVOICEDATA = MBA.RestViewCommon.fnCreateNameValueObject(  "showbasicinvoicedata" , opts.showBasicInvoiceData );
    let NV_SHOW_DISBREAKDOWNS_DOLLR_AMTS = MBA.RestViewCommon.fnCreateNameValueObject( "showdistbreakdownsdollaramounts", opts.showDistBreakdownsDollarAmounts );

    
    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID     );
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE    );
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_INVOICE_PAID  );

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DISTRIBUTION_PAID  );


    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_COLL_DATE_RANGE  );


    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CALC_SHARES   );

    $(dataObj.restViewCtrl).MBA_RestView( 'additionalParameterDefinitionForViewSet', NV_INCL_PARTN1    );

    $(dataObj.restViewCtrl).MBA_RestView( 'additionalParameterDefinitionForViewSet', NV_INCL_CYBHI       );

    $(dataObj.restViewCtrl).MBA_RestView( 'additionalParameterDefinitionForViewSet', NV_INCL_CYBHI_ONLY   );

    $(dataObj.restViewCtrl).MBA_RestView( 'additionalParameterDefinitionForViewSet', NV_INCL_RETNTN     );


    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SHOW_CLIENTNAME       );
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SHOW_CONSULTANTNAME   );

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SHOW_BASIC_INVOICEDATA          );
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SHOW_DISBREAKDOWNS_DOLLR_AMTS   );

    if ( typeof( opts.isCybhiDistScreen ) !== "undefined")
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_CYBHI_DISTSCREEN   );

    $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);


    var must_prep_params_for_get_totals = [
      NV_CLIENT_ID, NV_DATE_RANGE, NV_INVOICE_PAID, NV_DISTRIBUTION_PAID, NV_COLL_DATE_RANGE, NV_CALC_SHARES,
      NV_INCL_PARTN1, NV_INCL_CYBHI, NV_INCL_CYBHI_ONLY, NV_INCL_RETNTN
    ];

    var prepd_params = {};
    $.each( must_prep_params_for_get_totals, function( k, v) {
       prepd_params[ v.name ] = ( typeof( v.value ) !== "undefined" ? v.value : "") ;

             // NOTE: we're not using  (  v.value  !== "undefined" ? v.value : "") 
             //       because we need v.value = false to evaluate as false, not empty-string.
             //       we want v.value = *undefined* to evaluate as empty string.
    });

     prepd_params = JSON.stringify(  prepd_params ); 
     

     if ( opts.urlGetTotals )
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod( opts.urlGetTotals, prepd_params, null)
            .then(responseData => {

                var rrD = responseData.rawData.data[0];

                $('#invoiceAmtColSum').text(
                   rrD.invoiceAmtStr
                );
                
                
                $('#acctFeeColSum').text(
                   rrD.accountingFeeStr
                );
                
                $('#lbaShareColSum').text(
                   rrD.lbaShareStr
                );

                $('#mbaBbaColSum').text(
                   rrD.mbaBbaStr
                );

                $('#mbaDgColSum').text(
                   rrD.mbaDgStr
                );

                $('#mbaShareColSum').text(
                   rrD.mbaShareStr
                );

                $('#revShareColSum').text(
                   rrD.revShareStr
                );

                $('#partner1ShareColSum').text(
                   rrD.partner1ShareStr
                );

                $('#partner2ShareColSum').text(
                   rrD.partner2ShareStr
                );  //

                $('#partnerRevenueShareColSum').text(
                   rrD.partnerRevenueStr
                );

                $('#partnerShareRevenueColSum').text(
                   rrD.partnerShareRevenueStr
                );

                $('#practiCalShareColSum').text(
                   rrD.pcalShareStr
                );

                $('#spedCareBbaColSum').text(
                   rrD.spEdCareBbaStr
                );

                $('#spedCareDgColSum').text(
                   rrD.spEdCareDgStr
                );

                $('#spedcarePartnersShareColSum').text(
                   rrD.spEdCarePartnersStr
                );

                $( '#spedCareShareColSum' ).text(
                   rrD.spEdCareShareStr
                );

                $('#mbaShareColSum').text(
                   rrD.mbaShareStr
                );

                $('#csbaShareColSum').text(
                   rrD.csbaShareStr
                );

                $('#clientRetentionColSum').text(   // TODO - fix?
                   rrD.clientRetentionStr
                );                

            })
            .catch(responseData => {

                $.spedmonWebUI.dialogMessage('problem finding column sums', responseData.message, null, 400, 200, null, null, null);

            });



    


};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  
let _fnSetup = function (elementid, optsIn)
{
  
  let $me = _fnGetMe(elementid);	  
  	    
  /* See if we have created an instance of this plugin already for this element.  If so get out. */
 
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (dataObj) return; 

  /* Define the data object we will save later */
	  
  dataObj = {}; 
	  
  /* Store reference to elem */
	  
  dataObj.me = $me;

  /* Merge default options and options passed in. */

  //debugger;
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  
  dataObj.opts = opts;
  
  /* Create rest view */
  
  let $restViewCtrl  = $me;
  dataObj.restViewCtrl  = $restViewCtrl;
  _createRestView ($restViewCtrl, opts);

  /* Get reference to container control to listen for events on */
  
  let $containerCtrl = $('#' + opts.containerCtrlID);
  dataObj.containerCtrl = $containerCtrl;
  
  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj);
  
  /* Wire up events */
  
  $($containerCtrl).on('spedmoninputdata', function(e) {
    _updateAdditionalViewParameterValuesAndRequestViewFromServer ($me, opts);
  });

  //


  _updateAdditionalViewParameterValuesAndRequestViewFromServer($me, opts);

  initDiaDepositDateClientInvoice();
  initDiaDateCollectedClientInvoice();  //

  initDiaBulkSetDate();
   
}; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
      fnSetup: _fnSetup
    , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
};

})(jQuery);

