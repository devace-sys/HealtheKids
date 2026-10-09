;var MBA = (MBA || {});


/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.RestViewCommon
 * @memberof     MBA
 * @summary      Static methods used by rest view
 * @description  Static methods used by rest view
 * @requires     jQuery, jQueryUI, Font Awesome
 */

MBA.RestViewCommon = (function ($) {

'use strict';

/*################################################################################################
  #
  #                                          Constants
  #
  ################################################################################################*/

const CONST_DATA_NAME                = 'mba-rest-view';
const CONST_DATA_NAME_ROW_DATA       = 'mba-rest-view-row-data';

const CONST_LOAD_MODE_REST           = 'rest';
const CONST_LOAD_MODE_MBA_WEB_REPORT = 'mbawebreport';
const CONST_LOAD_MODE_MBA_VIEW_SEL   = 'mbaviewsel';
const CONST_LOAD_MODE_CUSTOM         = 'custom';

const CONST_SAVE_MODE_INLINE         = 'inline';
const CONST_SAVE_MODE_INWINDOW       = 'inwindow';
const CONST_SAVE_MODE_CUSTOM         = 'custom';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const CONST_REGEX_STATE_PATTERN = /^\[\d{1,}\]/i;
const CONST_REGEX_CODE_PATTERN  = /\d{1,}/;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const SECTIONS = {
    TABLE: 100
  , CURRENT_STATUS: 200
  , PAGING_CONTROLS:300
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const SUB_SECTIONS = {
	THEAD: 101
  , TBODY_NEW: 102
  , TBODY_EXISTING: 103
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const ROW_TYPE = {
	HEADER_ROW: 1
  , NEW_ROW: 2
  , CLONED_ROW: 3
  , EXISTING_ROW: 4
  , PRELOADED_ROW: 5 /* This is to support the data-grid control*/
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const CTRL_OP_CLASSES = {

	  SORT_ASC: 100
	, SORT_DESC: 110

	, ADD_NEW_START:200
	, ADD_NEW_PROCEED:210
    , ADD_NEW_CANCEL:220

	, EDIT_START: 300
	, EDIT_PROCEED:310
	, EDIT_CANCEL:320

	, DELETE_START:400
	, DELETE_PROCEED:410
	, DELETE_CANCEL: 420

	, CLONE_START: 500
	, CLONE_PROCEED:510
	, CLONE_CANCEL:520

	, UNDELETE_START: 600
	, UNDELETE_PROCEED: 610
	, UNDELETE_CANCEL: 620

	, REPORT_HTML: 900
	, REPORT_XLS: 910
	, REPORT_PDF: 920

	, MANAGE_FILES_FOR_TABLE: 1000
	, MANAGE_FILES_FOR_ROW: 1100
	, SHOW_ADDITIONAL_INFO_FOR_ROW: 2000
	, SEND_MESSAGE_FOR_TABLE: 3000
	, SEND_MESSAGE_FOR_ROW: 3100
	, ACTION_NOTIFICATIONS_FOR_ROW: 4000 /* For data grid */
	, COPY_DOWN: 5000                    /* For data grid */
	, ACTION_ITEMS_FOR_ROW: 6000
	, MARK_ROW: 7000
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const REPORT_FORMATS = {
	HTML: { reportFormat:2, downloadFile:false}
  , XLS: { reportFormat:3, downloadFile:true}
  , PDF: { reportFormat:4, downloadFile:true}
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const POSITION_USER_DEFINED_CONTROLS = {
	  BEFORE_BUILT_IN: 1
	, AFTER_BUILT_IN : 2
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const RETURN_CODES = {
	  SUCCESS:  0
	, INFO:     1
	, WARNING:  2
	, CRITICAL: 3
	, ERROR:    4
	, ABORT_OR_CANCEL: 5
	, SESSION_EXPIRE:  12
	, PASSWORD_LOCK:   14
	, DUP_RECORD:      20
	, REDIRECT:        50
	, FATAL:           99
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Data-* attribute names */

const CONST_ATTR_NAME_FOR_REC_ID                 = 'data-mba-rest-view-rec-id';
const CONST_ATTR_NAME_FOR_ACTIVE_FLAG            = 'data-mba-rest-view-rec-active';
const CONST_ATTR_NAME_FOR_CAN_EDIT_FLAG          = 'data-mba-rest-view-rec-can-edit';
const CONST_ATTR_NAME_FOR_CAN_DELETE_FLAG        = 'data-mba-rest-view-rec-can-delete';
const CONST_ATTR_NAME_FOR_CAN_UNDELETE_FLAG      = 'data-mba-rest-view-rec-can-undelete';

const CONST_ATTR_NAME_UI_ELEMENT_TYPE             = 'data-mba-rest-view-ui-element-type';
const CONST_ATTR_NAME_CTRL_DEF_NAME               = 'data-mba-rest-view-ctrl-def-name';
const CONST_ATTR_NAME_CTRL_DEF_TYPE               = 'data-mba-rest-view-ctrl-def-type';
const CONST_ATTR_NAME_CTRL_OP_CLASS               = 'data-mba-rest-view-ctrl-op-class';
const CONST_ATTR_NAME_FIELD_NAME                  = 'data-mba-rest-view-field-name';
const CONST_ATTR_NAME_ROW_IDX                     = 'data-mba-rest-view-row-idx';
const CONST_ATTR_NAME_COL_IDX                     = 'data-mba-rest-view-col-idx';
const CONST_ATTR_NAME_SORT_USING                  = 'data-mba-rest-view-sort-using';
const CONST_ATTR_NAME_SORT_DIR                    = 'data-mba-rest-view-sort-dir';
const CONST_ATTR_NAME_SAVE_USING                  = 'data-mba-rest-view-save-using';
const CONST_ATTR_NAME_ALT_VALUE                   = 'data-mba-rest-view-alt-value'
const CONST_ATTR_NAME_FIELD_EDIT_STATE            = 'data-mba-rest-view-field-edit-state';
const CONST_ATTR_NAME_ROW_TYPE                    = 'data-mba-rest-view-row-type';
const CONST_ATTR_NAME_ROW_COUNTER                 = 'data-mba-rest-view-row-counter';
const CONST_ATTR_NAME_ROW_CONTROLS                = 'data-mba-rest-view-row-controls';
const CONST_ATTR_NAME_ROW_NOTIFICATIONS           = 'data-mba-rest-view-row-notifications';
const CONST_ATTR_NAME_JUMP_TO_PAGE                = 'data-mba-rest-view-jump-to-page';
const CONST_ATTR_NAME_CELL                        = 'data-mba-rest-view-cell';
const CONST_ATTR_NAME_PLUGIN_MKUP_FOR_FIELD_NAME  = 'data-mba-rest-view-plugin-mkup-for-field-name';
const CONST_ATTR_NAME_TOOL_TIP                    = 'title'; /* TODO: This is temporarily the title attribute*/
const CONST_ATTR_NAME_MAP_KEY                     = 'data-mba-data-grid-data-map-key';
const CONST_ATTR_NAME_ROW_MARKED                  = 'data-mba-rest-view-row-marked';
const CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE = 'data-mba-rest-view-row-open-for-edit-or-delete';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Data-* attribute values */

const CONST_ATTR_VALUE_BUILT_IN                       = 'builtin';
const CONST_ATTR_VALUE_USER_PROVIDED                  = 'userprovided';
const CONST_ATTR_VALUE_UI_ELEMENT_TYPE_CTRL           = 'control';
const CONST_ATTR_VALUE_UI_ELEMENT_TYPE_FIELD_VALUE    = 'fieldvalue';
const CONST_ATTR_VALUE_EDIT_STATE_LOCKED              = 'locked';
const CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED            = 'unlocked';
const CONST_ATTR_VALUE_MARKED_TRUE                    = '1';
const CONST_ATTR_VALUE_MARKED_FALSE                   = '0';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Parameter names */

const CONST_PARM_NAME_PAGE_ROW_ORDER = 'pageOrder';
const CONST_PARM_PAGE_NUMBER         = 'pagenumber';
const CONST_PARM_PAGE_SIZE           = 'pagesize';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Event names */


const CONST_EVENT_NAME_EDIT_CANCEL  = 'restvieweditcancel';
const CONST_EVENT_NAME_EDIT_PROCEED = 'restvieweditproceed';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Selectors */

const SELECTOR_MARKED_ROW                  = 'tr[' + CONST_ATTR_NAME_ROW_MARKED + '= "' + CONST_ATTR_VALUE_MARKED_TRUE + '"]';
const SELECTOR_ROW_IN_EDIT_OR_DELETE_STATE = 'tr[' + CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE + '= "' + CONST_ATTR_VALUE_MARKED_TRUE + '"]';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*#################################################################################################
  #                                     Built In Data Types
  #################################################################################################*/

const CONST_BUILT_IN_DATA_TYPES = {
	text: {
		      defType: CONST_ATTR_VALUE_BUILT_IN
		    , name: 'text'
			, cssClass: 'mba-rest-view-data-type-text'
		    , dataTypeOptions: {}
  		    , fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputText(fieldDefinition, hasValue, value);
		    }
		    , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj);}
		}
	, number: {
		      defType: CONST_ATTR_VALUE_BUILT_IN
		    , name: 'number'
			, cssClass: 'mba-rest-view-data-type-number'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputNumber(fieldDefinition, hasValue, value);
			}
		    , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, usd: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'usd'
			, cssClass: 'mba-rest-view-data-type-usd'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				let _vin = value;
				if (hasValue) _vin = _fnFormatNumberToUSD(value);
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, _vin);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputUSD (fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) {
				if (uiActionObj.e.type == 'change')
				{
				  let inputVal = $(uiActionObj.whatElement).val();
				   if (inputVal) {
						let formattedInput = MBA.ComponentCommon.fnChangeNumberToUSD(inputVal);
						$(uiActionObj.whatElement).val(formattedInput);
					}
				}
				if (uiActionObj.e.type == 'click') {
					$(uiActionObj.whatElement).select();
				}

				return _fnHandleCellValueAction(uiActionObj);
			}
		}
		, date: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'date'
			, cssClass: 'mba-rest-view-data-type-date'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputDate(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, time: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'time'
			, cssClass: 'mba-rest-view-data-type-time'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputTime(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, datetime: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'datetime'
			, cssClass: 'mba-rest-view-data-type-datetime'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				if (hasValue) {
					let _rptDatePart = MBA.ComponentCommon.fnFormatDateTimeToRptDate(value);
					let _rptTimePart = MBA.ComponentCommon.fnFormatDateTimeToRptTime(value);
					let _rptDateTime = _rptDatePart + ' ' + _rptTimePart;
					return _fnRenderCellValueSpan(fieldDefinition, hasValue, _rptDateTime);
				}
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputDateTime(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
	    , email: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'email'
			, cssClass: 'mba-rest-view-data-type-email'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueAnchorEmail (fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputEmail(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }
	   , url: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'url'
		, cssClass: 'mba-rest-view-data-type-url'
		, dataTypeOptions: {}
		, fnRenderField: function (fieldDefinition, hasValue, value) {
			return _fnRenderCellValueAnchorUrl(fieldDefinition, hasValue, value);
		}
		, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
			return _fnRenderCellValueInputUrl(fieldDefinition, hasValue, value);
		}
		, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }
		, phone: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'phone'
			, cssClass: 'mba-rest-view-data-type-phone'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueAnchorTel(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputPhone(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		  }
		, ratio: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'ratio'
			, cssClass: 'mba-rest-view-data-type-ratio'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputText(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
	    , percent: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		  , name: 'percent'
		  , cssClass: 'mba-rest-view-data-type-percent'
		  , dataTypeOptions: {}
		  , fnRenderField: function (fieldDefinition, hasValue, value) {
			return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
		  }
		  , fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
			  return _fnRenderCellValueInputText(fieldDefinition, hasValue, value);
		  }
		  , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }

	    , yesno: {
		      defType: CONST_ATTR_VALUE_BUILT_IN
		    , name: 'yesno'
			, cssClass: 'mba-rest-view-data-type-yesno'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
			  return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSelectYesNo(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, yesnounknown: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'yesnounknown'
			, cssClass: 'mba-rest-view-data-type-yesnounknown'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSelectYesNoUnknown(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}

		, selectoption: {
			defType: CONST_ATTR_VALUE_BUILT_IN
		  , name: 'selectoption'
		  , cssClass: 'mba-rest-view-data-type-select-option'
		  , dataTypeOptions: {
				selections: []
		  }

		  , fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSelectOption(fieldDefinition, hasValue, value);
		  }
		  , fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
			  return _fnRenderCellValueSelectOption(fieldDefinition, hasValue, value);
		   }
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, autocomplete: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'autocomplete'
			, cssClass: 'mba-rest-view-data-type-autocomplete'
			, dataTypeOptions: {
				baseUrl: ''
				, loadMode: CONST_LOAD_MODE_MBA_VIEW_SEL
				, getInitialSelectedNameFrom: ''
				, fnOnOpen: function (event, ui, $acObj) {
					return;
                }
				, fnOnSelect:function(event, ui) {
					return;
				}
				, fnModifyRequestNvps: function (requestNvps) {
					return requestNvps;
				}
				, fnModifyResponseSelRecs(requestNvps, SelRecs) {
					return SelRecs;
				}
				, fnModifyRenderItem($ul, item, $li) {
					return $li;
                }
			}
			, fnRenderField: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			  return _fnRenderCellValueAutoComplete(fieldDefinition, hasValue, value, rowData, dataObj, newRow);
		    }
		    , fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			  return _fnRenderCellValueAutoComplete(fieldDefinition, hasValue, value, rowData, dataObj, newRow);
		    }
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	      }
 	    , lastfirst: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'lastfirst'
			, cssClass: 'mba-rest-view-data-type-lastfirst'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputText(fieldDefinition, hasValue, value);
			 }
			  , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		  }
		, notes: {
			 defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'notes'
			, cssClass: 'mba-rest-view-data-type-notes'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueTextArea(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
		       return _fnRenderCellValueTextArea(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }

		, textarea: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'textarea'
			, cssClass: 'mba-rest-view-data-type-textarea'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueTextArea(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
		       return _fnRenderCellValueTextArea(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
	    , string: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'string'
			, cssClass: 'mba-rest-view-data-type-string'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputText(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }
	    , pre: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'pre'
			, cssClass: 'mba-rest-view-data-type-pre'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValuePre (fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValuePre(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
        }
	    , jsondata: {
			  defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'jsondata'
			, cssClass: 'mba-rest-view-data-type-json-data'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueJsonData(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
		       return _fnRenderCellValueJsonData(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	    }
		 , checkbox: {
			defType: CONST_ATTR_VALUE_BUILT_IN
		  , name: 'checkbox'
		  , cssClass: 'mba-rest-view-data-type-checkbox'
		  , dataTypeOptions: {}
		  , fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputCheckbox(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputCheckbox(fieldDefinition, hasValue, value);
			 }
			 , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		 }
	    , fieldset: {
			defType: CONST_ATTR_VALUE_BUILT_IN
		  , name: 'fieldset'
		  , cssClass: 'mba-rest-view-data-type-fieldset'
		  , dataTypeOptions: { }
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueFieldSet(fieldDefinition, hasValue, value);
			}
		    , fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueFieldSet(fieldDefinition, hasValue, value);
			}
		 , handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, radiooption: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'radiooption'
			, cssClass: 'mba-rest-view-data-type-radio-option'
			, dataTypeOptions: {
				radioOptionName:''
			  , radioOptionText: ''
			  , radioOptionValue: ''
			  , bindToThisCtrl:null
			}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputRadioOption(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputRadioOption(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}

   		, hidden: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'hidden'
			, cssClass: 'mba-rest-view-data-type-hidden'
			, dataTypeOptions: {}
			, fnRenderField: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputHidden(fieldDefinition, hasValue, value);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
				return _fnRenderCellValueInputHidden(fieldDefinition, hasValue, value);
			}
			, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
		}
		, button: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'button'
			, cssClass: 'mba-rest-view-data-type-button'
			, dataTypeOptions: {
				faIconClass: 'fas fa-edit'
				, fnOnClick: function (uiActionObj) {
					return uiActionObj;
				}
			}
			, fnRenderField: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
				return _fnRenderCellControlButton(fieldDefinition, rowData, dataObj, newRow);
			}
			, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
				return _fnRenderCellControlButton(fieldDefinition, rowData, dataObj, newRow);
			}
			, handlerFn: function (uiActionObj) {

				if (uiActionObj.e.type == 'click') {
					if (!uiActionObj.fieldDefinition.dataTypeOptions) return uiActionObj;
					let _ocf = uiActionObj.fieldDefinition.dataTypeOptions.fnOnClick;
					if (!_ocf) return uiActionObj;
					return _ocf(uiActionObj);
				};
				return _fnHandleCellValueAction(uiActionObj);
			}
		}
	, checkboxselectionsjson: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'checkboxselectionsjson'
		, cssClass: 'mba-rest-view-data-type-check-box-selections-json'
		, dataTypeOptions: {
			  legend: ''
			, showLegend: false
			, selections: []
		}
		, fnRenderField: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			return _fnRenderCellValueCheckBoxSelectionsJson(fieldDefinition, hasValue, value,rowData,dataObj,newRow);
		}
		, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			return _fnRenderCellValueCheckBoxSelectionsJson(fieldDefinition, hasValue, value, rowData, dataObj, newRow);
		}
		, handlerFn: function (uiActionObj) {


			return _fnHandleCellValueAction(uiActionObj);
		}
	}
	, autocompletemultiple: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'autocompletemultiple'
		, cssClass: 'mba-rest-view-data-type-autocomplete-multiple'
		, dataTypeOptions: {
			  baseUrl: ''
			, sessionExpiredURL:''
			, fnOnOpen: function (event, ui, $acObj) {
				return;
			}
			, fnOnSelect: function (event, ui) {
				return;
			}
			, fnModifyRequestNvps: function (requestNvps) {
				return requestNvps;
			}
			, fnModifyResponseSelRecs(requestNvps, SelRecs) {
				return SelRecs;
			}
			, fnModifyRenderItem($ul, item, $li) {
				return $li;
			}
		}
		, fnRenderField: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			return _fnRenderCellValueAutoCompleteMultiple(fieldDefinition, hasValue, value, rowData, dataObj, newRow);
		}
		, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
			return _fnRenderCellValueAutoCompleteMultiple(fieldDefinition, hasValue, value, rowData, dataObj, newRow);
		}
		, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	}
	, emptydiv: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'emptydiv'
		, cssClass: 'mba-rest-view-data-type-empty-div'
		, dataTypeOptions: {}
		, fnRenderField: function (fieldDefinition, hasValue, value) {
			return _fnRenderCellValueDiv(fieldDefinition, hasValue, value);
		}
		, fnRenderFieldIfEditable: function (fieldDefinition, hasValue, value) {
			return _fnRenderCellValueDiv(fieldDefinition, hasValue, value);
		}
		, handlerFn: function (uiActionObj) { return _fnHandleCellValueAction(uiActionObj); }
	}
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*#################################################################################################
  #                   Sets of toggle values for various built in control types
  #################################################################################################*/

const CONTROL_CSS_CLASS_UNSELECTED       = 'mba-rest-view-unselected';
const CONTROL_CSS_CLASS_SELECTED         = 'mba-rest-view-selected'
const CONTROL_MARK_ROW_TOOLTIP_MARK      = 'This row IS NOT selected. Click here to select this row.';
const CONTROL_MARK_ROW_TOOLTIP_UNMARK    = 'This row IS selected. Click here to unselect this row.';
const CONTROL_CSS_CLASS_MARK_ROW_ICON    = 'mba-rest-view-mark-row-icon';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*#################################################################################################
  #                                  Built In Control Types
  #################################################################################################*/


const CONST_BUILT_IN_CONTROL_TYPES = {

     /* Sorts */

	 colsortasc: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'colsortasc'
		, cssClass: 'fas fa-chevron-up'
		, handlerFn: function (uiActionObj) { return _fnChangePageRowOrderFromSortUIAction(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to sort in ascending order'
		, ctrlOpClass: CTRL_OP_CLASSES.SORT_ASC
	}

	, colsortdesc: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'colsortdesc'
		, cssClass: 'fas fa-chevron-down'
		, handlerFn: function (uiActionObj) { return _fnChangePageRowOrderFromSortUIAction(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to sort in descending order'
		, ctrlOpClass: CTRL_OP_CLASSES.SORT_DESC
	}

    /* Reports */

	, reportHTML: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reportHTML'
		, cssClass: 'fa fa-print'
		, handlerFn: function (uiActionObj) { return _fnRequestExportWebReportDocumentHtml(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to display the data in a seperate window'
		, ctrlOpClass: CTRL_OP_CLASSES.REPORT_HTML
	}

	, reportXLS: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reportXLS'
		, cssClass: 'fa fa-file-excel'
		, handlerFn: function (uiActionObj) { return _fnRequestExportWebReportDocumentXls(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to download a Excel export of this data'
		, ctrlOpClass: CTRL_OP_CLASSES.REPORT_XLS
	}

	, reportPDF: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reportPDF'
		, cssClass: 'fa fa-file-pdf'
		, handlerFn: function (uiActionObj) { return _fnRequestExportWebReportDocumentPdf(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to download a PDF export of this data'
		, ctrlOpClass: CTRL_OP_CLASSES.REPORT_PDF
	}

	, manageFilesForTable: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'manageFilesForTable'
		, cssClass: 'fa fa-folder'
		, handlerFn: function (uiActionObj) { return uiActionObj; }
		, initiallyHidden: false
		, toolTip: 'Click here to manage files'
		, ctrlOpClass: CTRL_OP_CLASSES.MANAGE_FILES_FOR_TABLE
	}


	/* Supporting row ops */

	, manageFilesForRow: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'manageFilesForRow'
		, cssClass: 'fa fa-folder'
		, handlerFn: function (uiActionObj) {
			return uiActionObj;
		}
		, initiallyHidden: false
		, toolTip: 'Click here to manage files'
		, ctrlOpClass: CTRL_OP_CLASSES.MANAGE_FILES_FOR_ROW
	}

	, showAdditionalInfoForRow: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'showAdditionalInfoForRow'
		, cssClass: 'fa fa-info-circle'
		, handlerFn: function (uiActionObj) {
			return _fnShowAdditionalInfoForRow(uiActionObj);
		}
		, initiallyHidden: false
		, toolTip: 'Click here to show additional information'
		, ctrlOpClass: CTRL_OP_CLASSES.SHOW_ADDITIONAL_INFO_FOR_ROW
	}

	, sendMessageForRow: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'sendMessageForRow'
		, cssClass: 'fas fa-comment mba-messages-widget-class'
		, handlerFn: function (uiActionObj) {
			return uiActionObj;
		}
		, initiallyHidden: false
		, toolTip: 'Click here to send a message'
		, ctrlOpClass: CTRL_OP_CLASSES.SEND_MESSAGE_FOR_ROW
	}

	, actionItemsForRow: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'actionItemsForRow'
		, cssClass: 'fas fa-bell'
		, handlerFn: function (uiActionObj) {
			return uiActionObj;
		}
		, initiallyHidden: false
		, toolTip: 'Click here to view action items'
		, ctrlOpClass: CTRL_OP_CLASSES.ACTION_ITEMS_FOR_ROW
	}

	, markRow: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'markRow'
		, cssClass: 'fas fa-check ' + CONTROL_CSS_CLASS_MARK_ROW_ICON + ' ' + CONTROL_CSS_CLASS_UNSELECTED
		, handlerFn: function (uiActionObj) {
			return _fnMarkRow(uiActionObj);
		}
		, initiallyHidden: false
		, toolTip: CONTROL_MARK_ROW_TOOLTIP_MARK
		, ctrlOpClass: CTRL_OP_CLASSES.MARK_ROW
	}

	/* Add new inline */

	, recaddnewinlinestart: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recaddnewinlinestart'
		, cssClass: 'fa fa-plus'
		, handlerFn: function (uiActionObj) { return _fnAddNewInlineStart(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to add a new record'
		, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_START
	}

	, recaddnewinlineproceed: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recaddnewinlineproceed'
		, cssClass: 'fa fa-save'
		, handlerFn: function (uiActionObj) { return _fnAddNewInlineProceed(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to save this record'
		, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_PROCEED
	}
	, recaddnewinlinecancel: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recaddnewinlinecancel'
		, cssClass: 'fa fa-times'
		, handlerFn: function (uiActionObj) { return _fnAddNewInlineCancel(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to exit saving this record'
		, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_CANCEL
	}

	/* Clone inline */

	, reccloneinlinestart: {
		 defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reccloneinlinestart'
		, cssClass: 'fa fa-copy'
		, handlerFn: function (uiActionObj) { return _fnCloneInlineStart(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to clone this record'
		, ctrlOpClass: CTRL_OP_CLASSES.CLONE_START
	}
	, reccloneinlineproceed: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reccloneinlineproceed'
		, cssClass: 'fa fa-save'
		, handlerFn: function (uiActionObj) { return _fnCloneInlineProceed(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to save this record'
		, ctrlOpClass: CTRL_OP_CLASSES.CLONE_PROCEED
	}
	, reccloneinlinecancel: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'reccloneinlinecancel'
		, cssClass: 'fa fa-times'
		, handlerFn: function (uiActionObj) { return _fnCloneInlineCancel(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to exit saving this record'
		, ctrlOpClass: CTRL_OP_CLASSES.CLONE_CANCEL
	}

    /* Edit inline */

	, receditinlinestart: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'receditinlinestart'
		, cssClass: 'fa fa-pencil-alt'
		, handlerFn: function (uiActionObj) { return _fnEditInlineStart(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to edit this record'
		, ctrlOpClass: CTRL_OP_CLASSES.EDIT_START
    }
	, receditinlineproceed: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'receditinlineproceed'
		, cssClass: 'fa fa-save'
		, handlerFn: function (uiActionObj) { return _fnEditInlineProceed(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'Click here to save changes to this record'
		, ctrlOpClass: CTRL_OP_CLASSES.EDIT_PROCEED
	}
	, receditinlinecancel: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'receditinlinecancel'
		, cssClass: 'fa fa-times'
		, handlerFn: function (uiActionObj) { return _fnEditInlineCancel(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'Click here to exit without saving changes'
		, ctrlOpClass: CTRL_OP_CLASSES.EDIT_CANCEL
	}

    /* Delete inline */

	, recdeleteinlinestart: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recdeleteinlinestart'
		, cssClass: 'fa fa-trash-alt'
		, handlerFn: function (uiActionObj) { return _fnDeleteInlineStart(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to delete this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.DELETE_START
	}
	, recdeleteinlineproceed: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recdeleteinlineproceed'
		, cssClass: 'fa fa-trash'
		, handlerFn: function (uiActionObj) { return _fnDeleteInlineProceed(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'Yes. Go ahead and delete this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.DELETE_PROCEED
	}
	, recdeleteinlinecancel: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recdeleteinlinecancel'
		, cssClass: 'fa fa-times'
		, handlerFn: function (uiActionObj) { return _fnDeleteInlineCancel(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'No. Do NOT delete this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.DELETE_CANCEL
	}

	/* Undelete inline */

	, recundeleteinlinestart: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recundeleteinlinestart'
		, cssClass: 'fa fa-trash-restore-alt'
		, handlerFn: function (uiActionObj) { return _fnUnDeleteInlineStart(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to restore this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.UNDELETE_START
	}

	, recundeleteinlineproceed: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recundeleteinlineproceed'
		, cssClass: 'fa fa-trash-restore'
		, handlerFn: function (uiActionObj) { return _fnUnDeleteInlineProceed(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'Yes. Go ahead and restore this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.UNDELETE_PROCEED
	}

	, recundeleteinlinecancel: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recundeleteinlinecancel'
		, cssClass: 'fa fa-times'
		, handlerFn: function (uiActionObj) { return _fnUnDeleteInlineCancel(uiActionObj); }
		, initiallyHidden: true
		, toolTip: 'No. Do NOT restore this record.'
		, ctrlOpClass: CTRL_OP_CLASSES.UNDELETE_CANCEL
	}

	/* Add new in window */

	, recaddnewinwindow: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recaddnewinwindow'
		, cssClass: 'fa fa-plus'
		, handlerFn: function (uiActionObj) { return _fnAddNewInWindow(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to add a new record'
		, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_START
	}

	/* Edit in window */

	, receditinwindow: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'receditinwindow'
		, cssClass: 'fa fa-pencil-alt'
		, handlerFn: function (uiActionObj) { return _fnEditInWindow(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to edit this record'
		, ctrlOpClass: CTRL_OP_CLASSES.EDIT_START
	}

    /* Add new custom */

	, recaddnewcustom: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recaddnewcustom'
		, cssClass: 'fa fa-plus'
		, handlerFn: function (uiActionObj) { return uiActionObj.dataObj.opts.handlerFnAddNewCustom(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to add a new record'
		, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_START
	}

   /* Clone custom */

	, recclonecustom: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recclonecustom'
		, cssClass: 'fa fa-copy'
		, handlerFn: function (uiActionObj) { return uiActionObj.dataObj.opts.handlerFnCloneCustom(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to clone this record'
		, ctrlOpClass: CTRL_OP_CLASSES.CLONE_START
	}

    /* Edit custom */

	, receditcustom: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'receditcustom'
		, cssClass: 'fa fa-pencil-alt'
		, handlerFn: function (uiActionObj) { return uiActionObj.dataObj.opts.handlerFnEditCustom(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to edit this record'
		, ctrlOpClass: CTRL_OP_CLASSES.EDIT_START
	}

    /* Delete custom */

	, recdeletecustom: {
		  defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recdeletecustom'
		, cssClass: 'fa fa-trash-alt'
		, handlerFn: function (uiActionObj) { return uiActionObj.dataObj.opts.handlerFnDeleteCustom(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to delete this record'
		, ctrlOpClass: CTRL_OP_CLASSES.DELETE_START
	}

	/* Undelete custom */

	, recundeletecustom: {
		defType: CONST_ATTR_VALUE_BUILT_IN
		, name: 'recundeletecustom'
		, cssClass: 'fa fa-trash-restore-alt'
		, handlerFn: function (uiActionObj) { return uiActionObj.dataObj.opts.handlerFnUnDeleteCustom(uiActionObj); }
		, initiallyHidden: false
		, toolTip: 'Click here to undelete this record'
		, ctrlOpClass: CTRL_OP_CLASSES.UNDELETE_START
	}



};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*#################################################################################################
  #                                           CSS Classes
  #################################################################################################*/

const CSS_CLASS_VISIBLE_TD_TH = 'mba-rest-view-visible-tbl-td-or-th';  /* Used in specific checks */
const CSS_CLASS_COL_TOP       = 'mba-rest-view-col-top';
const CSS_CLASS_COL_LABEL     = 'mba-rest-view-col-label';
const CSS_CLASS_COL_CONTROLS  = 'mba-rest-view-col-ctrls';
const CSS_CLASS_SORT_CONTROLS = 'mba-rest-view-col-sort-ctrls';
const CSS_CLASS_CTRL_ICON     = 'mba-rest-view-ctrl-icon';

// make sure this matches the proper class names from the CSS_CLASSES object

const SELECTOR_COL_LABEL         = 'span.' + CSS_CLASS_COL_LABEL;
const SELECTOR_COL_SORT_CONTROLS = 'span.' + CSS_CLASS_SORT_CONTROLS;
const SELECTOR_COL_CONTROLS      = 'div.'  + CSS_CLASS_COL_CONTROLS;

const SELECTOR_AUTO_COMPLETE_DROPDOWN_ICON = '.mba-rest-view-autocomplete-dropdown-icon';
const SELECTOR_AUTO_COMPLETE_FIELDSET      = '.mba-rest-view-autocomplete-fieldset';
const SELECTOR_AUTO_COMPLETE_LOADING_ICON  = 'i.mba-rest-view-autocomplete-loading-icon';

const CSS_CLASSES = {
	me: CONST_DATA_NAME
  , container: CONST_DATA_NAME               + ' mba-rest-view-container'
  , controlSection: CONST_DATA_NAME          + ' mba-rest-view-control-section'
  , tableContainer: CONST_DATA_NAME          + ' mba-rest-view-table-container'
  , table: CONST_DATA_NAME                   + ' mba-rest-view-table'
  , tableCaption: CONST_DATA_NAME            + ' mba-rest-view-table-caption'
  , tableHeader: CONST_DATA_NAME             + ' mba-rest-view-table-header'
  , tableBodyNew: CONST_DATA_NAME            + ' mba-rest-view-table-body-new'
  , tableBody: CONST_DATA_NAME               + ' mba-rest-view-table-body'
  , ctrlButtonsRadioGroup: CONST_DATA_NAME   + ' mba-rest-view-ctrl-buttons-radio-group'
  , ctrlButton: CONST_DATA_NAME              + ' mba-rest-view-ctrl-button'
  , ctrlIcon: CONST_DATA_NAME                + ' ' + CSS_CLASS_CTRL_ICON
  , row: CONST_DATA_NAME                     + ' mba-rest-view-row'
  , rowCtr: CONST_DATA_NAME                  + ' mba-rest-view-row-ctr'
  , rowCtrls: CONST_DATA_NAME                + ' mba-rest-view-row-controls'
  , rowNotifications: CONST_DATA_NAME        + ' mba-rest-view-row-notifications'
  , col: CONST_DATA_NAME                     + ' mba-rest-view-col'
  , colTop: CONST_DATA_NAME                  + ' ' + CSS_CLASS_COL_TOP
  , colLabel: CONST_DATA_NAME                + ' ' + CSS_CLASS_COL_LABEL
  , colSortCtrls: CONST_DATA_NAME            + ' ' + CSS_CLASS_SORT_CONTROLS
  , colCtrls: CONST_DATA_NAME                + ' ' + CSS_CLASS_COL_CONTROLS
  , cell: CONST_DATA_NAME                    + ' mba-rest-view-cell'
  , cellValue: CONST_DATA_NAME               + ' mba-rest-view-cell-value'
  , cellSummary: CONST_DATA_NAME             + ' mba-rest-view-cell-summary'
  , cellDetails: CONST_DATA_NAME             + ' mba-rest-view-cell-details'
  , hidden: CONST_DATA_NAME                  + ' mba-rest-view-hidden'
  , visibleTblTdOrTh: CONST_DATA_NAME        + ' ' + CSS_CLASS_VISIBLE_TD_TH
  , messageOverlayContainer: CONST_DATA_NAME    + ' mba-rest-view-message-overlay-container'
  , messageOverlayContent: CONST_DATA_NAME + ' mba-rest-view-message-overlay-content'
  , rowNotificationMessageStandAlone: CONST_DATA_NAME + ' mba-rest-view-row-notification-message-stand-alone'
  , rowNotificationMessages: CONST_DATA_NAME    + ' mba-rest-view-row-notification-messages'
  , rowNotificationMessage: CONST_DATA_NAME     + ' mba-rest-view-row-notification-message'
  , rowNotificationMessageIcon: CONST_DATA_NAME + ' mba-rest-view-row-notification-message-icon'
  , rowNotificationMessageText: CONST_DATA_NAME + ' mba-rest-view-row-notification-message-text'
  , currentStatusContainer: CONST_DATA_NAME     + ' mba-rest-view-current-status-container'
  , dspCurrentStatus: CONST_DATA_NAME           + ' mba-rest-view-dsp-current-status'

  , pageControlsContainer: CONST_DATA_NAME        + ' mba-rest-view-page-controls-container'
  , ctrlInputPageNumber: CONST_DATA_NAME          + ' mba-rest-view-input-page-number'
  , ctrlButtonPrevPage: CONST_DATA_NAME           + ' mba-rest-view-button-page-prev'
  , ctrlButtonNextPage: CONST_DATA_NAME           + ' mba-rest-view-button-page-next'
  , ctrlSpanPageCounter: CONST_DATA_NAME          + ' mba-rest-view-span-page-counter'
  , ctrlJumpPageButtonsContainer: CONST_DATA_NAME + ' mba-rest-view-buttons-jump-page-container'
  , ctrlButtonJumpPage: CONST_DATA_NAME           + ' mba-rest-view-button-jump-page'
  , ctrlSpacerJumpPage: CONST_DATA_NAME           + ' mba-rest-view-jump-page-spacer'
  , ctrlButtonJumpPageCurrent:  'mba-rest-view-button-jump-page-current'
  , fieldSet: CONST_DATA_NAME                     + ' mba-rest-view-fieldset'
  , usdFieldSet: CONST_DATA_NAME                  + ' mba-rest-view-usd-fieldset'
  , usdSymbol: CONST_DATA_NAME                    + ' mba-rest-view-usd-symbol'
  , autoCompleteFieldSet: CONST_DATA_NAME         + ' mba-rest-view-autocomplete-fieldset'
  , autoCompleteDropDownButton: CONST_DATA_NAME   + ' mba-rest-view-autocomplete-dropdown-button'
  , autoCompleteDropDownIcon: CONST_DATA_NAME     + ' mba-rest-view-autocomplete-dropdown-icon'
  , autoCompleteLoadingIcon: CONST_DATA_NAME      + ' mba-rest-view-autocomplete-loading-icon'
  , autoCompleteList: CONST_DATA_NAME             + ' mba-rest-view-autocomplete-list'
  , autoCompleteListItem: CONST_DATA_NAME         + ' mba-rest-view-autocomplete-list-item'
  , autoCompleteListContent: CONST_DATA_NAME + ' mba-rest-view-autocomplete-list-content'
  , radioOptions: CONST_DATA_NAME + ' mba-rest-view-radio-options'
  , radioOption: CONST_DATA_NAME + ' mba-rest-view-radio-option'
  , radioOptionLabel: CONST_DATA_NAME + ' mba-rest-view-radio-option-label'
  , radioOptionText: CONST_DATA_NAME + ' mba-rest-view-radio-option-text'
  , radioOptionValue: CONST_DATA_NAME + ' mba-rest-view-radio-option-value'
  , additionalInfoTable: CONST_DATA_NAME + ' mba-rest-view-additional-info-table'
  , additionalInfoLabel: CONST_DATA_NAME + ' mba-rest-view-additional-info-label'
  , additionalInfoValue: CONST_DATA_NAME + ' mba-rest-view-additional-info-value'
  , scrollView: 'mba-rest-view-scroll'
  , animationPulse: 'mba-rest-view-animation-pulse-infinite'
  , animationHeartbeat: 'mba-rest-view-animation-heartbeat-infinite'
  , animationWiggle: 'mba-rest-view-animation-wiggle-infinite'
  , animationBounce: 'mba-rest-view-animation-bounce-infinite'
  , dataTypes: CONST_BUILT_IN_DATA_TYPES
  , controlTypes: CONST_BUILT_IN_CONTROL_TYPES
  , copyForAllIcon: 'mba-rest-view-copy-for-all-rows'
  , animated: 'mba-rest-view-animated'
  , highlight:'mba-rest-view-highlight'
  , bellNotification: 'mba-rest-view-bell-notification'

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*################################################################################################
  #                             Field Definition Defaults
  #################################################################################################*/

const CONST_TEMPLATE_FIELD_DEFINITION = {
	  name: ''
	, label: ''
	, toolTip: ''
	, visible: true
	, editable: false
	, saveable: false
	, sortable: true
	, isRecID: false
	, isActiveFlag:false
	, dataType: 'text'
	, dataTypeOptions: {}
	, sortUsing: ''
	, saveUsing: ''
	, showMore: false
	/*, fnCreateNewColBefore: function (opts, fieldDefinition, newCol) { }
	, fnCreateNewColAfter: function (opts, fieldDefinition, newCol) { }
	*/
    , hasColControls: false
	, additionalColControls: []
	, hasCustomCopyForAll: false /* data grid only */
	, copyForAllOptions: {}      /* data grid only */
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*################################################################################################
  #                             Control Definition Defaults
  #################################################################################################*/

const CONST_TEMPLATE_CONTROL_DEFINITION = {
	defType: CONST_ATTR_VALUE_USER_PROVIDED
  , name: ''
  , cssClass: 'fa'
  , handlerFn: function (uiActionObj) { return uiActionObj; }
  , initiallyHidden: false
  , toolTip: ''
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*################################################################################################
  #                                 Plugin Option Defaults
  #################################################################################################*/

const CONST_DEFAULT_OPTIONS = {

	  fieldDefinitions: []
	, hasColTitleReplacements: false
	, additionalCellValueFieldDefinitions: []
    , additionalControlDefinitionsForHeadRows:null
	, additionalControlDefinitionsForBodyRows: null
	, sessionTimeOutUrl:''
	, numOfJumpPages: 5
	, enableScrollView: false
	, scrollViewUseCustomHeight: false
	, scrollViewCustomHeight:'25em'
	, positionUserDefinedControlsInHead: POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN
	, positionUserDefinedControlsInBodyExisting: POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN
	, enableSortControls: true
	, enableRowNumbers: true
	, enableRowControls: false
	, enableRowNotifications: false
	, enableRowControlMarkRow: false
	, enableRowControlRecAddNew: false
	, enableRowControlSendMessageForRow : false
    , enableRowControlManageFilesForRow : false
	, enableRowControlShowAdditionalInfo: false
	, enableRowControlRecClone: false
	, enableRowControlRecEdit: false
	, enableRowControlRecDelete: false
	, enableRowControlRecUnDelete: false
	, autoShowHideDeleteUnDelete:false
	, enableMarkRowWithoutControl:false
	, enableReports: false
	, enableReportHtml: true
	, enableReportXls: true
	, enableReportPdf: false
	
	, defaultPageRowOrder: ''
	, pageSize:''
	, requestViewOnLoad: true
	, fnBeforeDrawTableBodyRows: function (elem, returnData, $me, dataObj) { return returnData; }
	, fnCreateNewRowBefore: function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return newRow; }
	, fnCreateNewRowAfter: function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return newRow; }
	, fnNewRowBeforeAppendToBodyExisting: function (newRow, rowData, opts) { return newRow; }
	, fnCreateNewColBefore: function (newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition) { return newCol; }
    , fnCreateNewColAfter: function (newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition) { return newCol; }
	, fnCreateNewCellBefore: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData) { return newCell; }
	, fnCreateNewCellAfter: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs) { return newCell; }
	, fnBeforeRequestViewFromServer: function (elem, pageNumber, $me, dataObj) { return; }
	, fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
	, loadModeView: CONST_LOAD_MODE_REST
	, baseUrlView: ''
	, baseUrlViewHasParameters: true
	, handlerFnViewCustom: function () { }
	, recIDNameForView: 'recid'
	, additionalParameterDefinitionsForView: null
	, ajaxOptionsView: { method: 'GET', type: 'GET', dataType: 'JSON' }

	, saveModeAddNew: CONST_SAVE_MODE_CUSTOM
	, baseUrlAddNew:''
	, baseUrlAddNewHasParameters: true
	, recIDNameForAddNew: 'recid'
	, saveTypeNameForAddNew: 'savetype'
    , saveTypeValueForAddNew:'1'
	, additionalParameterDefinitionsForAddNew: null
	, ajaxCallAddNew: function (url, data) { }
	, ajaxOptionsAddNew: { method: 'POST', type: 'POST', processData: false, contentType: 'application/json; charset=UTF-8' }
	, handlerFnAddNewCustom: function (uiActionObj) { return uiActionObj; }

	, saveModeClone: CONST_SAVE_MODE_CUSTOM
	, baseUrlClone: ''
	, baseUrlCloneHasParameters: true
	, recIDNameForClone: 'recid'
	, saveTypeNameForClone: 'savetype'
	, saveTypeValueForClone: '1'
	, additionalParameterDefinitionsForClone: null
	, ajaxCallClone: function (url, data) { }
	, ajaxOptionsClone: { method: 'POST', type: 'POST', processData: false, contentType: 'application/json; charset=UTF-8' }
	, handlerFnCloneCustom: function (uiActionObj) { alert('No handler defined'); return uiActionObj; }

	, saveModeEdit: CONST_SAVE_MODE_CUSTOM
	, baseUrlEdit:''
	, baseUrlEditHasParameters: true
	, recIDNameForEdit: 'recid'
	, saveTypeNameForEdit: 'savetype'
	, saveTypeValueForEdit: '2'
	, additionalParameterDefinitionsForEdit: null
	, ajaxCallEdit: function (url, data) { }
	, ajaxOptionsEdit: { method: 'POST', type: 'POST', processData: false, contentType: 'application/json; charset=UTF-8' }
	, handlerFnEditCustom: function (uiActionObj) { alert('No handler defined'); return uiActionObj; }
	, refreshViewAfterInlineEditProceed: false

	, saveModeDelete: CONST_SAVE_MODE_CUSTOM
	, baseUrlDelete:''
	, baseUrlDeleteHasParameters: true
	, recIDNameForDelete: 'recid'
	, saveTypeNameForDelete: 'savetype'
	, saveTypeValueForDelete: '3'
	, additionalParameterDefinitionsForDelete: null
	, ajaxCallDelete: function (url, data) {}
	, ajaxOptionsDelete: { method: 'POST', type: 'POST', processData: false, contentType: 'application/json; charset=UTF-8' }
	, handlerFnDeleteCustom: function (uiActionObj) { alert('No handler defined'); return uiActionObj; }

	, saveModeUnDelete: CONST_SAVE_MODE_CUSTOM
	, baseUrlUnDelete: ''
	, baseUrlUnDeleteHasParameters: true
	, recIDNameForUnDelete: 'recid'
	, saveTypeNameForUnDelete: 'savetype'
	, saveTypeValueForUnDelete: '6'
	, additionalParameterDefinitionsForUnDelete: null
	, ajaxCallUnDelete: function (url, data) { }
	, ajaxOptionsUnDelete: { method: 'POST', type: 'POST', processData: false, contentType: 'application/json; charset=UTF-8' }
	, handlerFnUnDeleteCustom: function (uiActionObj) { alert('No handler defined'); return uiActionObj; }

	, loadModeReport: CONST_LOAD_MODE_MBA_WEB_REPORT
	, baseUrlReport: ''
	, baseUrlReportHasParameters: true
	, defaultReportNumber:''
	, additionalParameterDefinitionsForReport: null
	, useAdditionalParametersFromViewForReport: true

	, fnModifyRowDataBeforeAddNew: function (uiActionObj, rowDataIn) { return rowDataIn; }
	, fnAddRowControlDefBefore: function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefIn, rowCtrlIdx, rowData) { return rowCtrlDefIn; }
	, fnOnRowMarked: function (uiActionObj, markedRows) { return uiActionObj; }
	, fnAddNewInlineProceedBefore: function (uiActionObj, $saveableFields) { return uiActionObj; }
	, autoHidePageControls: false
	, showCaption: false
	, caption: ''
	, fnOnAfterDrawTableBodyRows: function (elem, $me, dataObj) { return; }
	, fnOnAfterCreate: function (elem, dataObj, $visibleCols) { return; }
	, fnOnEditInlineStart: function (uiActionObj, butRefsObj) { return; }
	, fnCreateAdditionalInfoCellValueAfter: function ($addInfoVal, rowData, additionalInfoFieldDefinition) { return $addInfoVal; }
	, fnOKToAddNew: function (uiActionObj) { return true; }
	, fnOKToEdit: function (uiActionObj) { return true; }
	, fnOnAddNewInlineStart: function (uiActionObj) { return; }
	, fnAddNewInlineProceedAfter: function (uiActionObj, responseData, success) { return; }
	, fnEditInlineProceedAfter: function (uiActionObj, responseData, success) { return; }
	, fnOnAddNewInlineCancel: function (uiActionObj) { return; }
	, fnOnEditInlineCancel: function (uiActionObj) { return; }
};

/*################################################################################################
  #
  #                                         Utility
  #
  #################################################################################################*/

/**
 * @function     _createNewUUID
 * @private
 * @summary      Generates a unique identifier
 * @description  Generates a unique identifier
 */

let _createNewUUID = function() {
  let dt = new Date().getTime();
  let uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      let r = (dt + Math.random() * 16) % 16 | 0;
      dt = Math.floor(dt / 16);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
  return uuid;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFormatNumbertoUSD
 * @private
 * @summary      Returns a string representation of value formatted as USD
 * @description  Returns a string representation of value formatted as USD
 */

let _fnFormatNumberToUSD = function (value) {
  return '$' + MBA.ComponentCommon.fnChangeNumberToUSD(value);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFlagValueToTrueFalse
 * @private
 * @summary      Returns true if valueIn matches a typical bi-state value
 * @description  Returns true if valueIn matches a typical bi-state value
 */

let _fnFlagValueToTrueFalse = function (valueIn) {

  if (     (valueIn === '1')
		|| (valueIn === 'y')
		|| (valueIn === 'Y')
		|| (valueIn === true)
		|| (valueIn === 'true')
		|| (valueIn === 'on')
		|| (valueIn === 'On')
		|| (valueIn === 'Yes')
		|| (valueIn === 'yes')
	) {
	    return true;
	};
	return false;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHasValue
 * @private
 * @summary      Tests if valueIn has a value
 * @description  Tests if valueIn has a value
 */

let _fnHasValue = function (valueIn) {

  let _hasValue = true;
  if ((typeof valueIn === 'undefined') || (valueIn === null)) {
		_hasValue = false;
  }
  return _hasValue;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAreValuesSame
 * @private
 * @summary      Tests if value1 is same as value2
 * @description  Tests if value1 is same as value2
 */

let _fnAreValuesSame = function (value1, value2) {
  let _v1 = '' + value1;
  let _v2 = '' + value2;
  if (_v1 === _v2) return true;
  return false;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnBuildUrl
 * @private
 * @summary      Builds a uri encoded url
 * @description  Builds a url encoded url
 */

let _fnBuildUrl = function (baseURL, baseHasParameters, parameters) {
  let url = baseURL;
  if (!parameters) parameters = [];
  if (baseHasParameters === false) url = url + '?ts=1';
  $.each(parameters, function (parmIdx, parameter) {
    url = url + '&' + encodeURIComponent(parameter.name) + '=' + encodeURIComponent(parameter.value);
  });
  return url;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDetailsStrToDetailObj
 * @private
 * @summary      Extracts details from response into an object
 * @description  Extracts details from response into an object
 */

let _fnDetailStrToDetailObj = function (detailStr, defaultCode) {
  let detailObj = { code: (defaultCode), msg: (detailStr) };
  if (CONST_REGEX_STATE_PATTERN.test(detailStr) === true) {
     let stateCodeContainer = CONST_REGEX_STATE_PATTERN.exec(detailStr);    // Extract code container [x]
     detailObj.code = CONST_REGEX_CODE_PATTERN.exec(stateCodeContainer)[0]; // Extract code itself x
	 detailObj.msg = detailStr.replace(CONST_REGEX_STATE_PATTERN, "");      // Remove code container from detail leaving just detail text
  }
  return detailObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNameValueObj
 * @private
 * @summary      Generic utility function to create object containing name and value
 * @description  Generic utility function to create object containing name and value
 * @param  {Object}  name
 * @parm   {Object} value;
 */

let _fnCreateNameValueObj = function (name, value) {
  let nvo = {};
  nvo.name = name;
  nvo.value = value;
  return nvo;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetFieldValueFields
 * @private
 * @summary      Gets field value fields
 * @description  Gets field value fields
 */

let _fnGetFieldValueFields = function (rowOrCellRef) {
  let $fieldValueFields = $(rowOrCellRef).find('*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + '="' + CONST_ATTR_VALUE_UI_ELEMENT_TYPE_FIELD_VALUE +'"]');
  return $fieldValueFields;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetFieldValue
 * @private
 * @summary      Gets value of $field based on attributes and element
 * @description  Gets value of $field based on attributes and element
 */

let _fnGetFieldValue = function ($field) {
	let fv = null;
	let av = $($field).attr(CONST_ATTR_NAME_ALT_VALUE);

	/* If the field has no alt value then extract data based on element */
	if (!av) {
		if      ($($field).is('input'))    fv = $($field).val();
		else if ($($field).is('textarea')) fv = $($field).val();
		else if ($($field).is('select'))   fv = $($field).val();
		else if ($($field).is('span'))     fv = $($field).text();
		else if ($($field).is('div'))      fv = $($field).text();
		else if ($($field).is('pre'))      fv = $($field).text();
		else fv = null;
	}
	/* If there is an alternative value... such as we use in autocomplete, use it instead of the normal value */
	else {
		fv = av;
	}
	return fv;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetFieldNameValues
 * @private
 * @summary      Finds all elements that have the field value atrribute and puts their name value pairs in an array
 * @description  Finds all elements that have the field value atrribute and puts their name value pairs in an array
 */

let _fnGetFieldNameValues = function (rowOrCellRef) {
  let $fieldValueFields =	_fnGetFieldValueFields(rowOrCellRef);
  let fnvs = [];
  $.each($fieldValueFields, function (fi, $field) {
	let fn = $($field).attr(CONST_ATTR_NAME_FIELD_NAME);
	let fv = _fnGetFieldValue($field);
	fnvs[fn] = fv;
  });
  return fnvs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetSavableFields
 * @private
 * @summary      Gets saveable fields
 * @description  Gets saveable fields
 */

let _fnGetSaveableFields = function (rowOrCellRef) {
  let $saveableFields = $(rowOrCellRef).find('*[' + CONST_ATTR_NAME_SAVE_USING + ']');
  return $saveableFields;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindSaveableFieldRefInSaveableFieldsBySaveUsingName
 * @private
 * @summary      Finds saveable field reference by saveUsingName in $savableFields
 * @description  Finds saveable field reference by saveUsingName in $savableFields
 */

let _fnFindSaveableFieldRefInSaveableFieldsBySaveUsingName = function ($saveableFields, saveUsingName) {
	let _saveableFieldRef = null;
	$saveableFields.each(function (_idx) {
		if ($($saveableFields[_idx]).attr(CONST_ATTR_NAME_SAVE_USING) == saveUsingName) {
			_saveableFieldRef = $saveableFields[_idx];
			return;
        }
	});
	return _saveableFieldRef;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnPutSaveableFieldsInMap
 * @private
 * @summary      Puts saveableFields in a map keyed by saveUsing attribute
 * @description  Puts saveableFields in a map keyed by saveUsing attribute
 */

let _fnPutSaveableFieldsInMap = function ($saveableFields) {
  let sfMap = new Map();
  $.each($saveableFields, function (fi, $field) {
    let fn = $($field).attr(CONST_ATTR_NAME_SAVE_USING);
	sfMap.set(fn, $field);
  });
  return sfMap;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOpenWindow
 * @private
 * @summary      Opens url in new window
 * @description  Opens url in new window
 */

let _fnOpenWindow = function (elem, url, windowName, refreshView = false) {

	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);

    /* If no window name is passed we create one */

	if (!windowName) windowName   = '' + _createNewUUID();

	var windowObj = null;
	let createNewWindow = false;

    /* Have we opened this window already */
	if (dataObj.newWindows.has(windowName)) {
		windowObj = dataObj.newWindows.get(windowName);
		/* If not then we will need to create a new one*/
		if (!windowObj) {
			createNewWindow = true;
		}
		/* If so then see if its still open */
		else {
			/* If its closed then we need to create a new one */
			if (windowObj.closed === true) createNewWindow = true;
		}
	}
	/* We have not opened this window so we need to create a new one */
	else {
	    createNewWindow = true;
	}

	/* If we need to create a new window, do it */

	if (createNewWindow === true) {
		let w = Math.floor((window.innerWidth * .90));
		let h = window.innerHeight; /* Note: Chrome requires this. */
		let wos = 'width=' + w + ',height=' + h + ',scrollbars=1,top=1,left=1,menubar=1,toolbar=0';
		windowObj = window.open(url, windowName, wos);
	}

	windowObj.addEventListener('beforeunload', function (e) {
		if (refreshView === true) {
			_fnRefreshCurrentViewFromServer(elem);
		}
	}, { once: true });

	dataObj.newWindows.set(windowName, windowObj);
	_fnSaveDataObj($me, dataObj);
	windowObj.focus();

    return windowObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOpenTab
 * @private
 * @summary      Opens url in new tab
 * @description  Opens url in new tab
 */

let _fnOpenTab = function (elem, url, windowName, refreshView = false) {

	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);

    /* If no window name is passed we create one */

	if (!windowName) windowName   = '' + _createNewUUID();

	var windowObj = null;
	let createNewWindow = false;

    /* Have we opened this window already */
	if (dataObj.newWindows.has(windowName)) {
		windowObj = dataObj.newWindows.get(windowName);
		/* If not then we will need to create a new one*/
		if (!windowObj) {
			createNewWindow = true;
		}
		/* If so then see if its still open */
		else {
			/* If its closed then we need to create a new one */
			if (windowObj.closed === true) createNewWindow = true;
		}
	}
	/* We have not opened this window so we need to create a new one */
	else {
	    createNewWindow = true;
	}

	/* If we need to create a new window, do it */

	if (createNewWindow === true) {
		windowObj = window.open(url, windowName);
	}

	windowObj.addEventListener('beforeunload', function (e) {
		if (refreshView === true) {
			_fnRefreshCurrentViewFromServer(elem);
		}
	}, { once: true });

	dataObj.newWindows.set(windowName, windowObj);
	_fnSaveDataObj($me, dataObj);
	windowObj.focus();

    return windowObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGotoUrl
 * @private
 * @summary      Redirects to url
 * @description  Redirects to url
 */

let _fnGotoUrl = function (elem, url) {
	let $me     = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	window.location.assign(url);
    return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSessionExpiredRedirect
 * @private
 * @summary      Redirects user to time out url
 * @description  Redirects user to time out url
 * @param  {Object}  elem   Element reference
 *
 */

let _fnSessionExpiredRedirect = function (elem) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	let url = dataObj.opts.sessionTimeOutUrl
	window.location.assign(url);
	return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForViewSet
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForViewSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForView.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForAddNewSet
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForAddNewSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForAddNew.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForClone
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForCloneSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForClone.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForEditSet
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForEditSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForEdit.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForDeleteSet
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForDeleteSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForDelete.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAdditionalParameterDefinitionForUnDeleteSet
 * @private
 * @summary      Sets or updates
 * @description  Sets or updates
 * @param  {Object}  elem             Element reference
 *
 */

let _fnAdditionalParameterDefinitionForUnDeleteSet = function (elem, parameterNameValueObj) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.opts.additionalParameterDefinitionsForUnDelete.set(parameterNameValueObj.name, parameterNameValueObj.value);
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindFieldDefinition
 * @private
 * @summary      Finds field definition in options by name
 * @description  Finds field definition in options by name
 */

let _fnFindFieldDefinition = function (elem, name) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	let _fnIsFieldName = function (obj) {
		return (obj.name === name);
	};
	return dataObj.opts.fieldDefinitions.find(_fnIsFieldName);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnChangeFieldDefinitionMemberNameValue
 * @private
 * @summary      Finds field definition in options by name and replaces a given memberNames value with memberValue
 * @description  Finds field definition in options by name and replaces a given memberNames value with memberValue
 */

let _fnChangeFieldDefinitionMemberNameValue = function (elem, name, memberName, memberValue) {
	let $me        = _fnGetMe(elem);
	let dataObj    = _fnGetDataObj($me);
	let _fnIsFieldName = function (obj) { return (obj.name === name); };
	let fldIdx = dataObj.opts.fieldDefinitions.findIndex(_fnIsFieldName);
	if (fldIdx != -1) {
		let fldDef = dataObj.opts.fieldDefinitions[fldIdx];
		fldDef[memberName] = memberValue;
		dataObj.opts.fieldDefinitions[fldIdx] = fldDef;
		_fnSaveDataObj($me, dataObj);
	}
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindColumnCells
 * @private
 * @summary      Finds rendered column th and td elements by field definition name
 * @description  Finds rendered column th and td elements by field definition name
 */

let _fnFindColumnCells = function (elem, name) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	let objCellRefs = {};
	let attrSel = '[' + CONST_ATTR_NAME_FIELD_NAME + '="' + name + '"]';
	let thSel = 'tr th' + attrSel;
	let tdSel = 'tr td' + attrSel;
	objCellRefs.theadCells    = $(dataObj.thead).find(thSel);
	objCellRefs.tbodyCells    = $(dataObj.tbody).find(tdSel);
	objCellRefs.tbodyNewCells = $(dataObj.tbodyNew).find(tdSel);
	return objCellRefs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindCellByNameInWhatFieldCells
 * @private
 * @summary      Finds a cell in whatFieldCells by field definition name
 * @description  Finds a cell in whatFieldCells by field definition name
 */

let _fnFindCellByNameInWhatFieldCells = function (whatFieldCells, name) {
	let fieldCell = null;
	$.each(whatFieldCells, function (fcIdx, whatFieldCell) {
		let fldName = $(whatFieldCell).attr(CONST_ATTR_NAME_FIELD_NAME);
		if (fldName == name) {
		  fieldCell = whatFieldCell;
		  return false;
        }
	});
	return fieldCell;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetHeaderColMinWidth
 * @private
 * @summary      Set header column min width
 * @description  Set header column min width
 */

let _fnSetHeaderColMinWidth = function ($col, minWidth) {

	let $colTop       = $($col).children('div.' + CSS_CLASS_COL_TOP)[0];
	let $colLabel     = $($colTop).children(SELECTOR_COL_LABEL)[0];
	let $colSortCtrls = $($colTop).children(SELECTOR_COL_SORT_CONTROLS)[0];

	/* No minWidth provided, calculate what it might be*/

	if (!_fnHasValue(minWidth)) {

		let colWidth = 10;
		if ($colLabel)     colWidth = colWidth + $($colLabel).outerWidth();
		if ($colSortCtrls) colWidth = colWidth + $($colSortCtrls).outerWidth();
		minWidth = Math.floor(colWidth);
	}
	let styleAttrVal = 'min-width:' + minWidth + 'px';
	$($col).attr('style', styleAttrVal);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnShowColumn
 * @private
 * @summary      Show entire column by field definition name
 * @description  Show entire column by field definition name
 */

let _fnShowColumn = function (elem, name) {
	_fnChangeFieldDefinitionMemberNameValue(elem, name, 'visible', true);
	let objCellRefs = _fnFindColumnCells(elem, name);
	$(objCellRefs.theadCells).removeClass(CSS_CLASSES.hidden);
	$(objCellRefs.theadCells).addClass(CSS_CLASSES.visibleTblTdOrTh);
	$(objCellRefs.theadCells).each(function (idx, $col) {
	  _fnSetHeaderColMinWidth($col);
	});
	$(objCellRefs.tbodyCells).removeClass(CSS_CLASSES.hidden);
	$(objCellRefs.tbodyNewCells).removeClass(CSS_CLASSES.hidden);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHideColumn
 * @private
 * @summary      Hide entire column by field definition name
 * @description  Hide entire column by field definition name
 */

let _fnHideColumn = function (elem, name) {
	_fnChangeFieldDefinitionMemberNameValue(elem, name, 'visible', false);
	let objCellRefs = _fnFindColumnCells(elem, name);
	$(objCellRefs.theadCells).addClass(CSS_CLASSES.hidden);
	$(objCellRefs.theadCells).removeClass(CSS_CLASSES.visibleTblTdOrTh);
	$(objCellRefs.tbodyCells).addClass(CSS_CLASSES.hidden);
	$(objCellRefs.tbodyNewCells).addClass(CSS_CLASSES.hidden);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnChangeColumnLabel
 * @private
 * @summary      Change label of column that has field definition name to newLabel and tooltip to newToolTip.
 * @description  Change label of column that has field definition name to newLabel and tooltip to newToolTip.
 */

let _fnChangeColumnLabel = function (elem, name, newLabel, newToolTip) {
	_fnChangeFieldDefinitionMemberNameValue(elem, name, 'label', newLabel);
	_fnChangeFieldDefinitionMemberNameValue(elem, name, 'toolTip', newToolTip);

	let objCellRefs = _fnFindColumnCells(elem, name);
	$(objCellRefs.theadCells).each(function (idx, $col) {
	  let $label = $($col).find(SELECTOR_COL_LABEL)[0];
	  $($label).html(newLabel);
	  $($label).attr(CONST_ATTR_NAME_TOOL_TIP, newToolTip);
	});
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindAdditionalCellValueFieldDefinition
 * @private
 * @summary      Finds additional cell value field definition in options by name
 * @description  Finds additional cell value field definition in options by name
 */

let _fnFindAdditionalCellValueFieldDefinition = function (elem, name) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  let _fnIsFieldName = function (obj) {
		return (obj.name === name);
  };
  return dataObj.opts.additionalCellValueFieldDefinitions.find(_fnIsFieldName);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @function     _fnFindHeaderControlInThead
 * @private
 * @summary      Find and return reference to header control by name
 * @description  Find and return reference to header control by name
 */

let _fnFindHeaderControlInThead = function ($thead, name) {
  let _sel = 'tr > th[' + CONST_ATTR_NAME_ROW_CONTROLS + '] > button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="' + name + '"]';
  return $($thead).find(_sel);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindHeaderControl
 * @private
 * @summary      Find and return reference to header control by name
 * @description  Find and return reference to header control by name
 */

let _fnFindHeaderControl = function (elem, name) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  return _fnFindHeaderControlInThead(dataObj.thead, name);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnShowControl
 * @private
 * @summary      Unhides $ctrl
 * @description  Unhides $ctrl
 */

let _fnShowControl = function ($ctrl) {
  $($ctrl).removeClass(CSS_CLASSES.hidden);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHideControl
 * @private
 * @summary      Hides $ctrl
 * @description  Hides $ctrl
 */

let _fnHideControl = function ($ctrl) {
  $($ctrl).addClass(CSS_CLASSES.hidden);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindRowControl
 * @private
 * @summary      Find and return reference to row control by name
 * @description  Find and return reference to row control by name
 */

let _fnFindRowControl = function ($tr, name) {
  let _sel = 'td[' + CONST_ATTR_NAME_ROW_CONTROLS + '] > button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="' + name + '"]';
  return $($tr).find(_sel);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindIconInControl
 * @private
 * @summary      Find and return reference to icon markup in $ctrl
 * @description  Find and return reference to icon markup in $ctrl
 */

let _fnFindIconInControl = function ($ctrl) {
	return $($ctrl).find('i.' + CSS_CLASS_CTRL_ICON);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnReplaceIconImageInControl
 * @private
 * @summary      Finds icon in $ctrl and replaces oldCssClasses with newCssClasses
 * @description  Finds icon in $ctrl and replaces oldCssClasses with newCssClasses
 */

let _fnReplaceIconImageInControl = function ($ctrl, oldCssClasses, newCssClasses) {
	let $ctrlIcon = _fnFindIconInControl($ctrl);
	$($ctrlIcon).removeClass(oldCssClasses);
	$($ctrlIcon).addClass(newCssClasses);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetHeaderControlToolTip
 * @private
 * @summary      Sets $headerCtrl tool tip to a new value
 * @description  Sets $headerCtrl tool tip to a new value
 */

let _fnSetHeaderControlToolTip = function ($headerCtrl, value) {
  $($headerCtrl).attr(CONST_ATTR_NAME_TOOL_TIP, value);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetRowControlToolTip
 * @private
 * @summary      Sets $rowCtrls tool tip to a new value
 * @description  Sets $rowCtrls tool tip to a new value
 */

let _fnSetRowControlToolTip = function ($rowCtrl, value) {
  $($rowCtrl).attr(CONST_ATTR_NAME_TOOL_TIP, value);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetCurrentRenderedRows
 * @private
 * @summary      Gets current rendered rows
 * @description  Gets current rendered rows
 */
 
let _fnGetCurrentRenderedBodyRows = function (elem) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  return $(dataObj.tbody).find('tr');
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHighlightRowControl
 * @private
 * @summary      Add or remove highlight from $rowCtrl
 * @description  Add or remove highlight from $rowCtrl
 */

let _fnHighlightRowControl = function ($rowCtrl, remove) {
	if (remove === false) {
        $($rowCtrl).addClass(CSS_CLASSES.highlight);
	}
	else {
		$($rowCtrl).removeClass(CSS_CLASSES.highlight);
	}
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetRowType
 * @private
 * @summary      Returns type of row
 * @description  Returns type of row
 */

let _fnGetRowType = function ($row) {
  let rowType = $($row).attr(CONST_ATTR_NAME_ROW_TYPE);
  return '' + rowType;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnIsRowExistingRow
 * @private
 * @summary      Returns type of row
 * @description  Returns type of row
 */

let _fnIsRowExistingRow = function ($row) {
	let rowType = _fnGetRowType($row);
	if (rowType === '' + ROW_TYPE.EXISTING_ROW) return true;
	return false;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHighlightRow
 * @private
 * @summary      Add or remove highlight from $row
 * @description  Add or remove highlight from $row
 */

let _fnHighlightRow = function ($row, remove) {

	if (remove === false) {
        $($row).addClass(CSS_CLASSES.highlight);		
	}
	else {
		$($row).removeClass(CSS_CLASSES.highlight);
	}
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAnimateRowControlInfinite
 * @private
 * @summary      Add or remove animationName from $rowCtrl
 * @description  Add or remove animationName from $rowCtrl
 */

let _fnAnimateRowControlInfinite = function ($rowCtrl, animationName, highlight, remove) {

	let animationClass = '';

	if      (animationName == 'pulse')     animationClass = CSS_CLASSES.animationPulse;
	else if (animationName == 'heartbeat') animationClass = CSS_CLASSES.animationHeartbeat;
	else if (animationName == 'wiggle')    animationClass = CSS_CLASSES.animationWiggle;
	else if (animationName == 'bounce')    animationClass = CSS_CLASSES.animationBounce;
	else return;

	if (remove === false) {
		if (highlight === true) $($rowCtrl).addClass(CSS_CLASSES.highlight);
		$($rowCtrl).addClass(animationClass);
	}
	else {
		$($rowCtrl).removeClass(CSS_CLASSES.highlight);
		$($rowCtrl).removeClass(animationClass);
	}
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetCurrentRenderedRowsRecordIDs
 * @private
 * @summary      Gets associated record ids for rows that are currently loaded (current page)
 * @description  Gets associated record ids for rows that are currently loaded (current page)
 */

let _fnGetCurrentRenderedRowsRecordIDs = function (elem) {
	let $loadedRows = _fnGetCurrentRenderedBodyRows(elem);
	let _recIDs = new Array();
	$.each($loadedRows, function (mrIdx, $loadedRow) {
		let _recID = $($loadedRow).attr(CONST_ATTR_NAME_FOR_REC_ID);
		if (_recID) _recIDs.push(_recID);
	});
	return _recIDs;
};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetCurrentRenderedRowsRecordIDsAsCsvStr
 * @private
 * @summary      Gets associated record ids for rows that are currently loaded (current page) and return as a csv string
 * @description  Gets associated record ids for rows that are currently loaded (current page) and return as a csv string
 */

let _fnGetCurrentRenderedRowsRecordIDsAsCsvStr = function (elem) {
	let _recIDs = _fnGetCurrentRenderedRowsRecordIDs(elem);
	return _recIDs.join(",");
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnIsRowMarked
 * @private
 * @summary      Tests if $row is marked.
 * @description  Tests if $row is marked.  Returns true, false, or null
 */

let _fnIsRowMarked = function ($row) {
		
  let markRowState = $($row).attr(CONST_ATTR_NAME_ROW_MARKED);

	
  if (markRowState === CONST_ATTR_VALUE_MARKED_TRUE) {
    return true;
  }
  else if (markRowState === CONST_ATTR_VALUE_MARKED_FALSE) {
    return false;
  }
  else {
	return null;
  }
  return null;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindMarkedRowsInTBody
 * @private
 * @summary      Finds rows that are marked
 * @description  Finds rows that are marked
 */

let _fnFindMarkedRowsInTBody = function ($tbody) {
  return $($tbody).find(SELECTOR_MARKED_ROW);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMarkedRows
 * @private
 * @summary      Gets rows that are marked
 * @description  Gets rows that are marked
 */

let _fnGetMarkedRows = function (elem) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  return _fnFindMarkedRowsInTBody(dataObj.tbody);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMarkedRowsRecordIDs
 * @private
 * @summary      Gets record ids for rows that are marked
 * @description  Gets record ids for rows that are marked
 */

let _fnGetMarkedRowsRecordIDs = function (elem) {
  let $markedRows = _fnGetMarkedRows(elem);
	let _recIDs = new Array();
	$.each($markedRows, function (mrIdx, $markedRow) {
		let _recID = $($markedRow).attr(CONST_ATTR_NAME_FOR_REC_ID);
		_recIDs.push(_recID);
	});
	return _recIDs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMarkedRowsRecordIDsAsCsvStr
 * @private
 * @summary      Gets record ids for rows that are marked and return as a csv string
 * @description  Gets record ids for rows that are marked and return as a csv string
 */

let _fnGetMarkedRowsRecordIDsAsCsvStr = function (elem) {
	let  _recIDs = _fnGetMarkedRowsRecordIDs(elem);
	return _recIDs.join(",");
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnMarkMarkedRows
 * @private
 * @summary      Unmark all marked rows
 * @description  Unmark all marked rows
 */

let _fnUnMarkMarkedRows = function (elem) {
  let $markedRows = _fnGetMarkedRows(elem);
  let $markedRowCtrlButs = $($markedRows).find('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="markRow"]');
  $($markedRowCtrlButs).click(); /* TODO: Implement better solution */
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindRowsInEditOrDeleteStateInTBody
 * @private
 * @summary      Finds rows that are in an edit or delete state
 * @description  Finds rows that are in and edit or delete state
 */

let _fnFindRowsInEditOrDeleteStateInTBody = function ($tbody) {
  return $($tbody).find(SELECTOR_ROW_IN_EDIT_OR_DELETE_STATE);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnIsUserActivelyManagingRows
 * @private
 * @summary      Returns true if the user is actively managing rows.
 * @description  Returns true if the user is actively managing rows.  Applies to inline add new, edit, inline delete, and marking
 */

let _fnIsUserActivelyManagingRows = function (elem) {
	let $me     = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	let $tbody = dataObj.tbody;
	let $tbodyNew = dataObj.tbodyNew;

	let numRows = 0;
	numRows = numRows + $($tbodyNew).find('tr').length;
	numRows = numRows + _fnFindRowsInEditOrDeleteStateInTBody($tbody).length;
	numRows = numRows + _fnFindMarkedRowsInTBody($tbody).length;
	if (numRows == 0) return false;
	return true;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindExistingRowByRecordID
 * @private
 * @summary      Find existing row by record id
 * @description  Finds existing row by record id
 */

let _fnFindExistingRowByRecordID = function (elem, recordID) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  let $tbody  = dataObj.tbody;
  let _rowWithRecIDSelector = 'tr [' + CONST_ATTR_NAME_FOR_REC_ID + '="' + recordID + '"]';
  return $($tbody).find(_rowWithRecIDSelector);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*################################################################################################
  #
  #                       Saving/Loading State and Getting Instance Data
  #
  #################################################################################################*/

/**
 * @function     _fnLoadDataObj
 * @private
 * @summary      Loads saved data object that has instance data
 * @description  Loads saved data object that has instance data
 * @param  {Object}  $me
 */

let _fnLoadDataObj = function ($me) {
   return $($me).data(CONST_DATA_NAME);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSaveDataObj
 * @private
 * @summary      Save data object we are using to store data about instances of this component
 * @description  Save data object we are using to store data about instances of this component
 * @param  {Object}  $me
 * @parm   {Object}  dataObj;
 */

let _fnSaveDataObj = function ($me,dataObj) {
  $($me).data(CONST_DATA_NAME, dataObj);
  return _fnLoadDataObj($me);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMe
 * @private
 * @summary      Gets reference to original elemement
 * @description  Gets reference to original elemement
 * @param  {Object}  elem  Element reference
 */

let _fnGetMe = function (elem) { return $(elem); }

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataObj
 * @private
 * @summary      Gets reference to data object
 * @description  Gets reference to the jQuery data object associated with this element
 * @param  {Object}  $me  Element reference
 */

let _fnGetDataObj = function ($me)  {
  let dataObj = $($me).data(CONST_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
  return dataObj;
}

/*################################################################################################
  #
  #                         Event Identification and Delegation
  #
  #################################################################################################*/

/**
 * @function     _fnIdentifyUIActionAndCallHandler
 * @private
 * @summary      Identifies what user interface element had action and call its handler.  Handlers can add additiona data to the object
 * @description
 * @param  {Object}  e  jQueryEvent
 */

  let _fnIdentifyUIActionAndCallHandler = function (e, elem, whatSection, whatSubSection, whatContextElement, CONST_DEF_BUILT_IN_CONTROL_TYPES) {

  let uiActionObj = {};

  uiActionObj.e                  = e;
  uiActionObj.elem               = elem;
  uiActionObj.me                 = _fnGetMe(elem);
  uiActionObj.dataObj            = _fnGetDataObj(uiActionObj.me);
  uiActionObj.whatSection        = whatSection;
  uiActionObj.whatSubSection     = whatSubSection;
  uiActionObj.whatContextElement = whatContextElement;
  uiActionObj.whatElement        = $(e.target).closest('[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']')[0];

  if (!uiActionObj.whatElement) return uiActionObj;

  uiActionObj.uiElementType = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_UI_ELEMENT_TYPE);

  if (uiActionObj.whatSection === SECTIONS.TABLE)
  {
    uiActionObj.whatCellOrCol = $(uiActionObj.whatElement).closest(uiActionObj.whatContextElement)[0];
	uiActionObj.whatRow = $(uiActionObj.whatElement).closest('tr')[0];
    uiActionObj.fieldName     = $(uiActionObj.whatCellOrCol).attr(CONST_ATTR_NAME_FIELD_NAME);
	uiActionObj.recordID = null;
	uiActionObj.whatFieldCells = null;
	uiActionObj.whatFieldCellsInputValues = new Map();
	uiActionObj.whatFieldNameValues = null;

	if (uiActionObj.whatSubSection === SUB_SECTIONS.THEAD)
	{
	  uiActionObj.notificationsCol = $(uiActionObj.whatRow).children('th[' + CONST_ATTR_NAME_ROW_NOTIFICATIONS + ']')[0];
      uiActionObj.whatFieldCells = $(uiActionObj.whatRow).children('th[' + CONST_ATTR_NAME_FIELD_NAME + ']');
	  uiActionObj.notificationsCol = $(uiActionObj.whatRow).children('th[' + CONST_ATTR_NAME_ROW_NOTIFICATIONS + ']')[0];
	}
	else if (uiActionObj.whatSubSection === SUB_SECTIONS.TBODY_NEW) {
	  uiActionObj.notificationsCol = $(uiActionObj.whatRow).children('td[' + CONST_ATTR_NAME_ROW_NOTIFICATIONS + ']')[0];
	  uiActionObj.whatFieldCells = $(uiActionObj.whatRow).children('td[' + CONST_ATTR_NAME_FIELD_NAME + ']');
	}
	else if (uiActionObj.whatSubSection === SUB_SECTIONS.TBODY_EXISTING)
	{
	  uiActionObj.notificationsCol = $(uiActionObj.whatRow).children('td[' + CONST_ATTR_NAME_ROW_NOTIFICATIONS + ']')[0];
	  uiActionObj.whatFieldCells = $(uiActionObj.whatRow).children('td[' + CONST_ATTR_NAME_FIELD_NAME + ']');
	  uiActionObj.recordID = '' + $(uiActionObj.whatRow).attr(CONST_ATTR_NAME_FOR_REC_ID);
	}
	else
	{

	}

	uiActionObj.whatFieldNameValues = _fnGetFieldNameValues(uiActionObj.whatRow);

	  /* TODO: This only finds the first input in a cell and relies on the name being in the td.  This needs to be
	  refactored to find all inputs and get the names from the inputs themselves.*/
	$.each(uiActionObj.whatFieldCells, function (fcIdx, fieldCell) {
	  let fldName = $(fieldCell).attr(CONST_ATTR_NAME_FIELD_NAME);
	  let fldElemVal = '';
	  if (!fldName) return;
	  let fldElem = $(fieldCell).find(':input')[0];
	  if (fldElem) fldElemVal = $(fldElem).val();
	  uiActionObj.whatFieldCellsInputValues.set(fldName, fldElemVal);
	});
  } /* Table */

  let handlerFn = null;

  /* Element is a control*/

  if (uiActionObj.uiElementType === CONST_ATTR_VALUE_UI_ELEMENT_TYPE_CTRL) {

    uiActionObj.uiElementCtrlName    = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_CTRL_DEF_NAME);
	uiActionObj.uiElementCtrlDefType = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_CTRL_DEF_TYPE);

    /* Built in control */

	if (uiActionObj.uiElementCtrlDefType === CONST_ATTR_VALUE_BUILT_IN) {
		handlerFn = CONST_DEF_BUILT_IN_CONTROL_TYPES[uiActionObj.uiElementCtrlName].handlerFn;
    }

    /* User defined */

	else if (uiActionObj.uiElementCtrlDefType === CONST_ATTR_VALUE_USER_PROVIDED) {
		if (uiActionObj.whatSubSection === SUB_SECTIONS.THEAD) {
			handlerFn = uiActionObj.dataObj.opts.additionalControlDefinitionsForHeadRows.get(uiActionObj.uiElementCtrlName).handlerFn;
		}
		else if (uiActionObj.whatSubSection === SUB_SECTIONS.TBODY_NEW) {
			handlerFn = uiActionObj.dataObj.opts.additionalControlDefinitionsForBodyRows.get(uiActionObj.uiElementCtrlName).handlerFn;
		}
		else if (uiActionObj.whatSubSection === SUB_SECTIONS.TBODY_EXISTING) {
			handlerFn = uiActionObj.dataObj.opts.additionalControlDefinitionsForBodyRows.get(uiActionObj.uiElementCtrlName).handlerFn;
		}
		else {
			handlerFn = null;
        }
	}

	else {
	}

  } /* Element is a control */

  /* Element is a field */

  else if (uiActionObj.uiElementType === CONST_ATTR_VALUE_UI_ELEMENT_TYPE_FIELD_VALUE) {

	  uiActionObj.uiElementCtrlName    = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_CTRL_DEF_NAME);
	  uiActionObj.uiElementCtrlDefType = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_CTRL_DEF_TYPE);
	  uiActionObj.fieldValueFieldName  = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_FIELD_NAME);

	  /* Built in field */

	  if (uiActionObj.uiElementCtrlDefType === CONST_ATTR_VALUE_BUILT_IN) {

	      /* Get all savable fields for the row */

		  uiActionObj.saveableFields      = _fnGetSaveableFields(uiActionObj.whatRow);
		  uiActionObj.saveableFieldsMap   = _fnPutSaveableFieldsInMap(uiActionObj.saveableFields);

 	      /* Find field definition (columns we defined in opts) */
		  uiActionObj.fieldDefinition = _fnFindFieldDefinition(elem, uiActionObj.fieldValueFieldName);

  	      /* If its not a field def used in the column defs, see if its an additional cell value one registered*/

		  if (typeof uiActionObj.fieldDefinition === 'undefined') {
		    uiActionObj.fieldDefinition = _fnFindAdditionalCellValueFieldDefinition(elem, uiActionObj.fieldValueFieldName);
		  }

		  /* If the field definition exists but it does not have a handler function defined, use the default from our built in data types */

		  if (typeof uiActionObj.fieldDefinition.handlerFn === 'undefined') {
		    handlerFn = CONST_BUILT_IN_DATA_TYPES[uiActionObj.uiElementCtrlName].handlerFn;

		  }

		  /* Otherwise use the one provided */

		  else {
		    handlerFn = uiActionObj.fieldDefinition.handlerFn;
		  }

	  }

	  /* User defined */

	  else if (uiActionObj.uiElementCtrlDefType === CONST_ATTR_VALUE_USER_PROVIDED) {
        /* TODO: Add support */
	  }

	  else {
	  }

  }

  else {

  }

  /* If handler function is not defined return */

  if (typeof handlerFn === 'undefined') return uiActionObj;
  if (!handlerFn)                return uiActionObj;

  /* Call handler if defined.  Handler must return uiActionObj */

  return handlerFn(uiActionObj);


  return uiActionObj;
}

/*################################################################################################
  #
  #                             Web Report Export Routines
  #
  #################################################################################################*/

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestExportWebReportDocument
 * @private
 * @summary      Base method for export
 * @description  Base method for export
 */

let _fnRequestExportWebReportDocument = function (uiActionObj, reportFormat = 2, reportNumber = -1, downloadFile = true) {

    /* Get our stored data */

	let $me           = _fnGetMe(uiActionObj.elem);
	let dataObj       = _fnLoadDataObj($me);
	let rptRequestUid = _createNewUUID();

	let parameters = [];

	if (reportNumber === -1) reportNumber = dataObj.opts.defaultReportNumber;

	parameters.push(_fnCreateNameValueObj('reptform', reportFormat));
	parameters.push(_fnCreateNameValueObj('reptnumber', reportNumber));
	parameters.push(_fnCreateNameValueObj('reptpaging', '0'));
	parameters.push(_fnCreateNameValueObj('reptcolsonly', '0'));
	parameters.push(_fnCreateNameValueObj('repteditview', ''));
	parameters.push(_fnCreateNameValueObj('reptreqguid', rptRequestUid));

	if (dataObj.opts.useAdditionalParametersFromViewForReport === true) {
	  dataObj.opts.additionalParameterDefinitionsForView.forEach(function (value, key) {
		parameters.push(_fnCreateNameValueObj(key, value));
	  });
	} else {
	  dataObj.opts.additionalParameterDefinitionsForReport.forEach(function (value, key) {
		  parameters.push(_fnCreateNameValueObj(key, value));
	  });
    }

	let rptRequestUrl      = _fnBuildUrl(dataObj.opts.baseUrlReport, true, parameters);
	let rptRequestFileName = rptRequestUrl.substr(rptRequestUrl.lastIndexOf('/') + 1); /* Extracts just filename */

	if (downloadFile === true) {

		/* Download link method courtesy of https://stackoverflow.com/a/43523297 */

		let dLink = document.createElement('a');
		dLink.href     = rptRequestUrl;
		dLink.download = rptRequestFileName;
		dLink.click();

     	/* We sent a uid to the server and a cookie with a name of uid and value of file will be set when the download is ready */

		let $dNotice = _fnRenderRowNotificationMessageStandAlone('Please wait, generating file.');
		$dNotice.attr('id', rptRequestUid);
		$dNotice.addClass(CSS_CLASSES.animationPulse);
		$(uiActionObj.notificationsCol).append($dNotice);
		uiActionObj.dLink = dLink;

		let dTimer = null;
		let dTimerFn = function () {
			let dCookiesStr = document.cookie;
			if (!dCookiesStr) return;
			let dCookies = dCookiesStr.split('; ');
			if (!dCookies) return;
			let rptResponseCookie = dCookies.find(row => row.startsWith(rptRequestUid + '='));
			if (!rptResponseCookie) return;
			let rptResponseValStr = rptResponseCookie.split('=')[1];
			if (rptResponseValStr) {
			  $($dNotice).remove();
			  window.clearInterval(dTimer);
			}
		}
		dTimer = window.setInterval(dTimerFn, 1000);
		uiActionObj.dTimer = dTimer;
	}

	else {
	  let newWindow = _fnOpenWindow(uiActionObj.elem, rptRequestUrl, null, false);
	  uiActionObj.newWindow = newWindow;
	}
	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestExportWebReportDocumentHtml
 * @private
 * @summary      Base method for export
 * @description  Base method for export
 */

let _fnRequestExportWebReportDocumentHtml = function (uiActionObj) {
  let reportNumber = -1;
  return _fnRequestExportWebReportDocument(uiActionObj, REPORT_FORMATS.HTML.reportFormat, reportNumber, REPORT_FORMATS.HTML.downloadFile)
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestExportWebReportDocumentXls
 * @private
 * @summary      Base method for export
 * @description  Base method for export
 */

let _fnRequestExportWebReportDocumentXls = function (uiActionObj) {
	let reportNumber = -1;
	return _fnRequestExportWebReportDocument(uiActionObj, REPORT_FORMATS.XLS.reportFormat, reportNumber, REPORT_FORMATS.XLS.downloadFile)
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestExportWebReportDocumentPdf
 * @private
 * @summary      Base method for export
 * @description  Base method for export
 */

let _fnRequestExportWebReportDocumentPdf = function (uiActionObj) {
	let reportNumber = -1;
	return _fnRequestExportWebReportDocument(uiActionObj, REPORT_FORMATS.PDF.reportFormat, reportNumber, REPORT_FORMATS.PDF.downloadFile)
}

/*################################################################################################
  #
  #                                         AJAX Routines
  #
  #################################################################################################*/


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxCallRestView
 * @private
 * @summary      Call one of our REST view methods
 * @description  Call one of our REST view methods
 */

let _fnAjaxCallRestView = function (elem, pageNumber) {

  return new Promise((resolve, reject) => {

      let responseData = {};
      responseData.type            = null;
      responseData.status          = null;
      responseData.message         = null;
      responseData.details         = new Array();
	  responseData.hasRecords      = null;
	  responseData.recordsTotal    = null;
	  responseData.recordsPaged    = null;
	  responseData.pageCount       = null;
	  responseData.pageSize        = null;
	  responseData.pageNumber      = null;
	  responseData.pageOrder       = null;
	  responseData.recordsReturned = null;
	  responseData.recordsFiltered = null;
	  responseData.data            = null;

	  if (!pageNumber)     { responseData.status = RETURN_CODES.ERROR; responseData.message = "Page number required"; reject(responseData); };
	  if (pageNumber <= 0) { responseData.status = RETURN_CODES.ERROR; responseData.message = "Page number invalid"; reject(responseData); };

	  /* Get our stored data */

	  let $me     = _fnGetMe(elem);
	  let dataObj = _fnLoadDataObj($me);

	  /* Build URL */

	  let parameters = [];
	  parameters.push(_fnCreateNameValueObj(CONST_PARM_PAGE_NUMBER, pageNumber));
	  parameters.push(_fnCreateNameValueObj(CONST_PARM_NAME_PAGE_ROW_ORDER, dataObj.currentPageRowOrder));
	  parameters.push(_fnCreateNameValueObj(CONST_PARM_PAGE_SIZE, dataObj.opts.pageSize));

	  dataObj.opts.additionalParameterDefinitionsForView.forEach(function (value, key) {
		  parameters.push(_fnCreateNameValueObj(key, value));
	  });

	  let urlToGetFrom = _fnBuildUrl(dataObj.opts.baseUrlView, true, parameters);

	  let reqOpts = {};

	  reqOpts.method   = 'GET';
	  reqOpts.type     = 'GET';
	  reqOpts.dataType = 'JSON';


	  dataObj.currentViewRequests.forEach(function (viewReq, viewKey) {
		  viewReq.abort();
	  });

	  dataObj.currentViewRequests.clear();

	  let viewRequestKey = _createNewUUID();

	  let req = $.ajax(urlToGetFrom, reqOpts)
		         .done(function (data, textStatus, jqXHR) {

			        responseData.status   = data.status;
			        responseData.message = data.message;

			      if (data.details) {
				    $.each(data.details, function (i, detailStr) {
					    let detailObj = _fnDetailStrToDetailObj(detailStr, data.status);
					    responseData.details.push(detailObj);
				    });
			     }

			  responseData.type             = data.objectFullName;
			  responseData.hasRecords       = data.hasRecords;
			  responseData.recordsReturned  = data.recordsReturned;
			  responseData.recordsTotal     = data.recordsTotal;
			  responseData.recordsFiltered  = data.recordsFiltered;
			  responseData.recordsPaged     = data.recordsPaged;
		      responseData.pageCount        = data.pageCount;
			  responseData.pageSize         = data.pageSize;
			  responseData.pageNumber       = data.pageNumber;
			  responseData.pageOrder        = data.pageOrder;
			  responseData.data = data.data;

			  if (responseData.status === RETURN_CODES.SESSION_EXPIRE) _fnSessionExpiredRedirect(elem);
			  if (responseData.status != RETURN_CODES.SUCCESS) reject(responseData);
			  resolve(responseData);
		  })
		  .fail(function (jqXHR, textStatus, errorThrown) {
			  responseData.status = RETURN_CODES.ERROR;
			  responseData.message = textStatus;
			  reject(responseData);
		  })
		  .always(function (dataOrjqXHR, textStatus, jqXHROrerrorThrown) {
			  dataObj.currentViewRequests.delete(viewRequestKey);
		  });

	   dataObj.currentViewRequests.set(viewRequestKey, req);
	   _fnSaveDataObj($me, dataObj);
   });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxCallAsmxWebMethod
 * @private
 * @summary      Call one of our ASMX web methods
 * @description  Call one of our ASMX web methods
 */

let _fnAjaxCallAsmxWebMethod = function (elem, urlToPostTo, dataToPost) {

  return new Promise((resolve, reject) => {

      let reqOpts = {};
      reqOpts.method      = 'POST';
	  reqOpts.type        = 'POST';
	  reqOpts.data        = dataToPost;
      reqOpts.processData = false;
      reqOpts.contentType = 'application/json; charset=UTF-8';

      let responseData = {};
      responseData.type    = null;
      responseData.status  = null;
      responseData.message = null;
      responseData.details = new Array();

	  $.ajax(urlToPostTo, reqOpts)
		  .done(function (data, textStatus, jqXHR) {

			  if (data.hasOwnProperty('d')) {
				  /* Provide .NET 3.5 compatibility for web service calls
				   * Courtesy of http://encosia.com/never-worry-about-asp-net-ajaxs-d-again/ */
				  let dataInD = data.d;
				  data = dataInD;
			  }

			  responseData.type    = data.__type;
			  responseData.status  = data.status;
			  responseData.message = data.message;

			  if (data.details) {
				  $.each(data.details, function (i, detailStr) {
					  let detailObj = _fnDetailStrToDetailObj(detailStr, data.status);
					  responseData.details.push(detailObj);
				  });
			  }
			  responseData.rawData = data;
			  if (responseData.status === RETURN_CODES.SESSION_EXPIRE) _fnSessionExpiredRedirect(elem);
			  if (responseData.status != RETURN_CODES.SUCCESS) reject(responseData);
			  resolve(responseData);
		  })
		  .fail(function (jqXHR, textStatus, errorThrown) {
			  responseData.status = RETURN_CODES.ERROR;
			  responseData.message = textStatus;
			  reject(responseData);
		  })
		  .always(function (dataOrjqXHR, textStatus, jqXHROrerrorThrown) {
		  });
   });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderIconBase
 * @private
 * @summary      Render icon base markup
 * @description  Render icon base markup
 */

let _fnRenderIconBase = function () {
  let $newIcon = $('<i></i>');
  return $newIcon;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCtrlIcon
 * @private
 * @summary      Render icon markup
 * @description  Render icon markup
 */

let _fnRenderCtrlIcon = function (cssClass) {
  let $newCtrlIcon = _fnRenderIconBase();
  $newCtrlIcon.addClass(CSS_CLASSES.ctrlIcon);
  $newCtrlIcon.addClass(cssClass);
  return $newCtrlIcon;
}

/*################################################################################################
  #
  #                                     Render Cell Values
  #
  #################################################################################################*/


/**
 * @function     _fnRenderCellValueSpan
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueSpan = function (fieldDefinition, hasValue, value) {
  let $newSpan = $('<span></span>');
  $newSpan.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newSpan.append(value);
  return $newSpan;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueDiv
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueDiv = function (fieldDefinition, hasValue, value) {
  let $newDiv = $('<div></div>');
  $newDiv.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newDiv.append(value);
  return $newDiv;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueAnchorBase
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueAnchorBase = function (fieldDefinition, hasValue, value, newWindow, prefix) {
	if (hasValue === true) {
		let $newAnchor = $('<a></a>');
		$newAnchor.append(value);
		if (newWindow === true) $newAnchor.attr('target', '_blank');
		$newAnchor.attr('href', (prefix + value));
		$newAnchor.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
		return $newAnchor;
	}
	else
		return _fnRenderCellValueSpan(fieldDefinition, hasValue, value);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueAnchorEmail
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueAnchorEmail = function (fieldDefinition, hasValue, value) {
	return _fnRenderCellValueAnchorBase(fieldDefinition, hasValue, value, false, 'mailto:');
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueAnchorTel
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueAnchorTel = function (fieldDefinition, hasValue, value) {
	return _fnRenderCellValueAnchorBase(fieldDefinition, hasValue, value, false, 'tel:');
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueAnchorUrl
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueAnchorUrl = function (fieldDefinition, hasValue, value) {
	return _fnRenderCellValueAnchorBase(fieldDefinition, hasValue, value, true, '');
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueTextArea
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueTextArea = function (fieldDefinition, hasValue, value) {
  let $newTa = $('<textarea></textarea>');
  $newTa.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newTa.append(value);
  return $newTa;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueJsonData
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueJsonData = function (fieldDefinition, hasValue, value) {
  let $newTa = $('<textarea></textarea>');
  if (hasValue === true) $newTa.append(value);
  return $newTa;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueCheckBoxSelectionsJson
 * @private
 * @summary      Generates base markup and calls component code   Returns reference to component container.
 * @description  Generates base markup and calls component code.  Returns reference to component container.
 */

let _fnRenderCellValueCheckBoxSelectionsJson = function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
	let $newTa = $('<textarea></textarea>');
	if (hasValue === true) $newTa.append(value);
	return $newTa;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValuePre
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValuePre = function (fieldDefinition, hasValue, value) {
  let $newPre = $('<pre></pre>');
  $newPre.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newPre.append(value);
  return $newPre;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueFieldSet
 * @private
 * @summary      Generates fieldset as a container for other elements.  Meant to be further defined by user using hooks
 * @description  Generates fieldset as a container for other elements.  Meant to be further defined by user using hooks.
 */

let _fnRenderCellValueFieldSet = function (fieldDefinition, hasValue, value) {
	let $newFldSet = $('<fieldset></fieldset>');
	$newFldSet.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
	return $newFldSet;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueOptionBase
 * @private
 * @summary      Generates base markup for option element
 * @description  Generates base markup for option element
 */

let _fnRenderCellValueOptionBase = function (label, value, selected, hidden, disabled) {
  let $newOption = $('<option></option>');
  $newOption.attr('value', value);
  if (selected === true) $newOption.attr('selected',  'selected');
  if (hidden   === true) $newOption.attr('hidden',    'hidden');  
  if (disabled === true) $newOption.attr('disabled',  'disabled');
	
  $newOption.append(label);
  return $newOption;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderSelectBase
 * @private
 * @summary      Generates base markup for select element
 * @description  Generates base markup for select element
 */

  let _fnRenderSelectBase = function (fieldDefinition, hasValue, value) {
  let $newSelect = $('<select></select>');
  $newSelect.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  return $newSelect;
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueSelectOption
 * @private
 * @summary      Generates select
 * @description  Generates select
 */

let _fnRenderCellValueSelectOption = function (fieldDefinition, hasValue, value) {

	var $newSelect = _fnRenderSelectBase(fieldDefinition, hasValue, value);
	var selectionFound = false;

	$.each(fieldDefinition.dataTypeOptions.selections, function (idx, selection) {

	  let _selected = false;
	  let _hidden   = false;
	  let _disabled = false;

	  if ( hasValue === true ) {
		let _selValStr = '' + selection.value
		let _fldValStr = '' + value;
		  if (_selValStr === _fldValStr) {
			  selectionFound = true;
			  _selected = true;
		  }			  
	  }

	  /* If the selection has the hidden property then use it to set the hidden flag */

	  if (typeof selection.hidden !== 'undefined') {
	    _hidden = selection.hidden;
	  } else {
	    _hidden = false;
	  }

	  /* If the selection has the disabled property then use it to set the disabled flag */

	  if (typeof selection.disabled !== 'undefined') {
	    _disabled = selection.disabled;
	  } else {
		_disabled = false;
	  }

	  $newSelect.append(_fnRenderCellValueOptionBase(selection.name, selection.value, _selected, _hidden, _disabled));
	}); /* selections */

	/* Find first non hidden selection */

	let $firstNotHidden = $($newSelect).find('option:not([hidden])').first();

	/* If we have a value passed but it was not found in the selections then use the first
	 * non hidden selection as the initial value */

	if (hasValue === true) {
		if (selectionFound === false) {
			$($firstNotHidden).attr('selected', 'selected');
        }
	}

	/* If there is no value then select the first non hidden selection as the initial value */

	else if (hasValue === false) {
		
		$($firstNotHidden).attr('selected', 'selected');						
	}
		
	return $newSelect;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueSelectYesNo
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueSelectYesNo = function (fieldDefinition, hasValue, value) {
  let $newSelect = $('<select></select>');
  $newSelect.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  let $optY = _fnRenderCellValueOptionBase('Yes', 'Yes',false, false, false);
  let $optN = _fnRenderCellValueOptionBase('No', 'No',false, false, false);
  if (hasValue === true) {
    if      ((value) === 'Yes') $optY.attr('selected', 'selected');
	else if ((value) === 'No')  $optN.attr('selected', 'selected');
  }
  $newSelect.append($optY);
  $newSelect.append($optN);
  return $newSelect;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueSelectYesNoUnknown
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 */

let _fnRenderCellValueSelectYesNoUnknown = function (fieldDefinition, hasValue, value) {
  let $newSelect = _fnRenderCellValueSelectYesNo(fieldDefinition, hasValue, value);
  let $optU = _fnRenderCellValueOptionBase('Unknown', 'Unknown', false, false);
  if (hasValue === true) {
    if (value === 'Unknown') $optU.attr('selected', 'selected',false);
  }
  $newSelect.append($optU);
  return $newSelect;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputBase
 * @private
 * @summary      Generates base markup
 * @description  Generates base markup
 * @param  {string}  inputType
 * @parm   {bool} hasValue
 * @parm   {string} value
 */

let _fnRenderCellValueInputBase = function (inputType, fieldDefinition, hasValue, value) {
  let $newInput = $('<input/>');
  $newInput.attr('type', inputType);
  if (fieldDefinition) $newInput.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newInput.val(value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputHidden
 * @private
 * @summary      Generates text input
 * @description  Generates text input
 */

let _fnRenderCellValueInputHidden = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('hidden', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputRadioOption
 * @private
 * @summary      Generates radio input
 * @description  Generates radio input
 */

let _fnRenderCellValueInputRadioOption = function (fieldDefinition, hasValue, value) {

  let $newInput = _fnRenderCellValueInputBase('radio', fieldDefinition, true, fieldDefinition.dataTypeOptions.radioOptionValue);
  $newInput.addClass(CSS_CLASSES.radioOptionValue);
  $newInput.attr('name', fieldDefinition.dataTypeOptions.radioOptionName); /* All options in a group must have the name name */
  $($newInput).removeAttr('checked');
  if (hasValue === true) {
	 if (_fnAreValuesSame(value, fieldDefinition.dataTypeOptions.radioOptionValue)) $($newInput).attr('checked', true);
  }

  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputCheckbox
 * @private
 * @summary      Generates text input
 * @description  Generates text input
 */

let _fnRenderCellValueInputCheckbox = function (fieldDefinition, hasValue, value) {

  let $newInput = _fnRenderCellValueInputBase('checkbox', fieldDefinition, hasValue, value);

  /* Set initial value */

  if (_fnFlagValueToTrueFalse(value) === true) {
	$($newInput).attr('checked', true).prop('checked',true);

	$($newInput).val('1');
  }
  else {
	$($newInput).attr('checked',false).prop('checked',false);
    $($newInput).val('0');
  }

  /* Handle changes from user actions  */

  $($newInput).on('change', function (e) {
	if ($(this).is(':checked')) {
	  $(this).val('1')
	}
	else {
	  $(this).val('0');
	}
  });

  /* Handle changes from edit cancel */

  $($newInput).on(CONST_EVENT_NAME_EDIT_CANCEL, function (e) {
    let newVal = $(this).val();
	if (_fnFlagValueToTrueFalse(newVal) === true) {
		$(this).attr('checked', true).prop('checked',true);
		$(this).val('1');
	}
	else {
	  $(this).removeAttr('checked').prop('checked',false);
	  $(this).val('0');
	}
  });

  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputText
 * @private
 * @summary      Generates text input
 * @description  Generates text input
 */

let _fnRenderCellValueInputText = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('text', fieldDefinition, hasValue, value);
  if (fieldDefinition.dataListID) { $($newInput).attr('list', fieldDefinition.dataListID);}
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputDate
 * @private
 * @summary      Generates date input
 * @description  Generates date input
 */

let _fnRenderCellValueInputDate = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('date', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputTime
 * @private
 * @summary      Generates time input
 * @description  Generates time input
 */

let _fnRenderCellValueInputTime = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('time', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputDateTime
 * @private
 * @summary      Generates datetime input
 * @description  Generates datetime input
 * @see          https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime-local
 */

let _fnRenderCellValueInputDateTime = function (fieldDefinition, hasValue, value) {
  let _valueIn = value;
  if (hasValue) {
    _valueIn = MBA.ComponentCommon.fnFormatDateTimeToYYYYMMDDTHHMM(value);
  }
  let $newInput = _fnRenderCellValueInputBase('datetime-local', fieldDefinition, hasValue, _valueIn);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputEmail
 * @private
 * @summary      Generates email input
 * @description  Generates email input
 */

let _fnRenderCellValueInputEmail = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('email', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputUrl
 * @private
 * @summary      Generates url input
 * @description  Generates url input
 */

let _fnRenderCellValueInputUrl = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('url', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputNumber
 * @private
 * @summary      Generates number input
 * @description  Generates number input
 */

let _fnRenderCellValueInputNumber = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('number', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputSearch
 * @private
 * @summary      Generates search input
 * @description  Generates search input
 */

let _fnRenderCellValueInputSearch = function (fieldDefinition, hasValue, value) {
  let $newInput = _fnRenderCellValueInputBase('search', fieldDefinition, hasValue, value);
  return $newInput;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueInputUSD
 * @private
 * @summary      Generates text input for later enhancement to a usd input
 * @description  Generates text input for a later enhancement to a usd input
 */

let _fnRenderCellValueInputUSD = function (fieldDefinition, hasValue, value) {
  let _vin = value;

  try {
  	if (hasValue) _vin = MBA.ComponentCommon.fnChangeNumberToUSD(String(value));
  }
  catch {
  	_vin = value;
  }

  let $newInput = _fnRenderCellValueInputBase('text', fieldDefinition, hasValue, _vin);

  return $newInput;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueAutoComplete
 * @private
 * @summary      Generates autocomplete
 * @description  Generates autocomplete
 */

let _fnRenderCellValueAutoComplete = function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {

	/* Get a value from the member of rowData that contains the the label/selectionName/name */

	let selName = rowData[fieldDefinition.dataTypeOptions.getInitialSelectedNameFrom];

	if (!selName) {
		selName = '';
	}

	/* Create the search input that will be used for autocompletes*/

	let $newInput = _fnRenderCellValueInputText(fieldDefinition, true, selName);

	let selValue = value;
	if (!hasValue) selValue = '';

	$($newInput).attr(CONST_ATTR_NAME_ALT_VALUE, selValue);
	var rowRef = newRow;

	/* If there is a label/name reassign title attribute value to it */

	if (selName != '') {
	  $($newInput).attr('title', selName);
	}

	/* Setup autocomplete functionality using jQuery UI autocomplete plugin */

	let $acObj = null;

	/* TODO: Finish wiring up default dataTypeOpts.*/

	let dataTypeOpts = $.extend({}
		                 , CONST_BUILT_IN_DATA_TYPES.autocomplete.dataTypeOptions
		                 , fieldDefinition.dataTypeOptions);

	$($newInput).autocomplete({

		open: function (event, ui) {
			/* Hook for open */
			dataTypeOpts.fnOnOpen(event, ui, $acObj);
		}
		, select: function (event, ui) {
			$($newInput).attr(CONST_ATTR_NAME_ALT_VALUE, ui.item.id); /* Note: Different than init for entityID*/
			/* Reassign title attribute value to name/label */
			$($newInput).attr('title', ui.item.label);
			/* Hook for selection */
			fieldDefinition.dataTypeOptions.fnOnSelect(event, ui);
		}
		, close: function (event, ui) {
			/* Note: Loading icon has not been rendered yet so thats why we get a ref here.*/
			let $loadingIcon = $($newInput).siblings(SELECTOR_AUTO_COMPLETE_LOADING_ICON)[0];
			$($loadingIcon).hide();
		}
		,source: function (acReqCb, acRspCb) {

			/* Note: Loading icon has not been rendered yet so thats why we get a ref here.*/

			let $loadingIcon = $($newInput).siblings(SELECTOR_AUTO_COMPLETE_LOADING_ICON)[0];
			$($loadingIcon).show();

			/* Get collection of all current savable field name/values for given row reference */

			let _saveableFields = _fnGetSaveableFields(rowRef);
			let _nvpsIn = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields(_saveableFields);

		    /* Add the search term from the autocomplete plugin to this collection */

			_nvpsIn.push(_fnCreateNameValueObj('term', acReqCb.term));

			/* Hook for modifying name value collection being sent to server */

			let _nvpsOut = fieldDefinition.dataTypeOptions.fnModifyRequestNvps(_nvpsIn);

		    /* Create request data JSON string */

			let _reqDataObj = _fnCtrlOpInlineRequestDataObjFromNvpObjs(_nvpsOut);
			let _reqDataStr = JSON.stringify(_reqDataObj);

			/* Use our local method */

			_fnAjaxCallAsmxWebMethod(dataObj.me, fieldDefinition.dataTypeOptions.baseUrl, _reqDataStr)
				.then(responseData => {

				 /* Hook for modifying response */

			     let SelRecs = fieldDefinition.dataTypeOptions.fnModifyResponseSelRecs(_nvpsOut, responseData.rawData.SelRecs);

			     if (!SelRecs) {
					acRspCb([]);
					$($loadingIcon).hide();
					return;
				  }
				  acRspCb(SelRecs);
				  $($loadingIcon).hide();
				})
				.catch(responseData => {
					acRspCb({});
					$($loadingIcon).hide();
				});
		}
	}).data("autocomplete")._renderItem = function ($ul, item) {

	    /* Override how jQuery autocomplete plugin renders its selections */

		let $li = $('<li></li>');
		$($li).addClass(CSS_CLASSES.autoCompleteListItem);
		let $liContent = $('<a></a>');
		$($liContent).addClass(CSS_CLASSES.autoCompleteListContent);
		$($liContent).append(item.label);
		$li.append($liContent);
		$li.data('item.autocomplete', item);
		/* Hook to modify rendered selection item */
		let $fli = fieldDefinition.dataTypeOptions.fnModifyRenderItem($ul,item,$li);
		return $fli.appendTo($ul);
	};

    /* Get reference to ul generated by autocomplete plugin and add the rest-view classes and attributes
	 * User can override style added by jQuery UI for all instances of a widget for a given field name */

	$acObj = $($newInput).autocomplete("widget")[0];
	$($acObj).attr(CONST_ATTR_NAME_PLUGIN_MKUP_FOR_FIELD_NAME, fieldDefinition.name);
	$($acObj).addClass(CSS_CLASSES.autoCompleteList);
	return $newInput;

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnRenderCellValueAutoCompleteMultiple
 * @private
 * @summary      Generates base markup and calls component code   Returns reference to component container.
 * @description  Generates base markup and calls component code.  Returns reference to component container.
 */

let _fnRenderCellValueAutoCompleteMultiple = function (fieldDefinition, hasValue, value, rowData, dataObj, newRow) {
	let $newTa = $('<textarea></textarea>');
	if (hasValue === true) $newTa.append(value);
	return $newTa;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellValueFormBuilderQuestions
 * @private
 * @summary      Generates form builder questions data
 * @description  Generates form builder questions data
 */

let _fnRenderCellValueFormBuilderQuestions = function (fieldDefinition, hasValue, value) {
  let $newFBCont = $('<span></span>');
  let $newFBData = $('<textarea></textarea>');
  $newFBData.addClass(CSS_CLASSES.hidden);
  $newFBData.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
  if (hasValue === true) $newFBData.append(value);
  $newFBCont.append($newFBData);

  let $newShowFormButton = $('<button type="button">Show</button>');
  $newFBCont.append($newShowFormButton);

  /* TODO: Add code to instantiate form builder  */
  return $newFBCont;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCellControlButton
 * @private
 * @summary      Generates a generic button with a custom user onclick callback function
 * @description  Generates a generic button with a custom user onclick callback function
 */

let _fnRenderCellControlButton = function(fieldDefinition, rowData, dataObj, newRow) {
	// define our button and attach the user's onclick callback to it
	let $btn = $('<button type="button" class="' + fieldDefinition.cssClass + ' ' + CSS_CLASSES.ctrlButton + '"></button>');
	$btn.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);


	// define our icon in the button
	let $btnIcon = $('<i class="' + fieldDefinition.dataTypeOptions.faIconClass + '"></i>');

	$btn.append($btnIcon);

	return $btn;

}


/*################################################################################################
  #
  #                         Overlays, Status Messages, and Notifications
  #
  #################################################################################################*/

/**
 * @function     _fnRenderRowNotificationMessages
 * @private
 * @summary      Renders notification messages from details returned from server
 * @description  Renders notification messages from details returned from server
 * @param  {Object}  name
 * @parm   {Object} value;
 */

let _fnRenderRowNotificationMessages = function (details) {
  let $msgs = $('<ul></ul>');
  $msgs.addClass(CSS_CLASSES.rowNotificationMessages);
  $.each(details, function (idx, detail) {
    let $msg = $('<li></li>');
    $msg.addClass(CSS_CLASSES.rowNotificationMessage);
	let $msgIcon = _fnRenderIconBase();
	$msgIcon.addClass(CSS_CLASSES.rowNotificationMessageIcon);
	$msgIcon.addClass('fa fa-exclamation-circle');
	let $msgText = $('<span></span>');
	$msgText.addClass(CSS_CLASSES.rowNotificationMessageText);
	$msgText.html(detail.msg);
	$msg.append($msgIcon)
	$msg.append($msgText);
    $msgs.append($msg);
  });
  return $msgs;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderRowNotificationMessageStandAlone
 * @private
 * @summary      Renders stand alone message for use in row notifications
 * @description  Renders stand alone message for use in row notifications
 * @param  {Object}  name
 * @parm   {Object} value;
 */

let _fnRenderRowNotificationMessageStandAlone = function (messageContent) {

  let $msg = $('<div></div>');
  $msg.addClass(CSS_CLASSES.rowNotificationMessageStandAlone);
  $msg.html(messageContent);
  return $msg;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateStatusContent
 * @private
 * @summary      Updates content in status container
 * @description  Updates content in status container
 * @param  {Object}  elem             Element reference
 * @param  {String}  newStatusContent New content
 *
 */

let _fnUpdateStatusContent = function (elem, newStatusContent) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  $(dataObj.dspCurrentStatus).html(newStatusContent);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateMessageOverlayContent
 * @private
 * @summary      Updates content in message overlay container
 * @description  Updates content in message overlay container
 * @param  {Object}  elem             Element reference
 * @param  {String}  newOverlayContent New content
 *
 */

let _fnUpdateMessageOverlayContent = function (elem, newOverlayContent) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  $(dataObj.messageOverlayContent).html(newOverlayContent);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnShowMessageOverlay
 * @private
 * @summary      Shows message overlay
 * @param  {Object}  elem             Element reference
 * @param  {String}  newOverlayContent New content
 *
 */

let _fnShowMessageOverlay = function (elem) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  $(dataObj.messageOverlayContainer).removeClass(CSS_CLASSES.hidden);
  let currTableWidth = $(dataObj.table).css('width');
  $(dataObj.messageOverlayContainer).css('width', currTableWidth);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHideMessageOverlay
 * @private
 * @summary     Hides message overlay
 * @param  {Object}  elem             Element reference
 *
 */

let _fnHideMessageOverlay = function (elem, hideInMSeconds) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  let _fnDoHide = function () {
    $(dataObj.messageOverlayContainer).addClass(CSS_CLASSES.hidden);
  }
  if (hideInMSeconds)
    setTimeout(_fnDoHide, hideInMSeconds);
  else
    _fnDoHide();
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnClearMessageOverlay
 * @private
 * @summary     Clears message overlay
 * @param  {Object}  elem             Element reference
 *
 */

let _fnClearMessageOverlay = function (elem) {
  _fnUpdateMessageOverlayContent(elem, '');
  return;
};

/*################################################################################################
  #
  #                                 Various Factory Routines
  #
  #################################################################################################*/

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewControlDefinition
 * @private
 * @summary      Factory function.  Generates a new control definition
 * @description  Factory function.  Generates a new control definition
 * @param  {string}    name
 * @param  {string}    cscClass
 * @param  {function}  handlerFn
 */

let _fnCreateNewControlDefinition = function (name, cssClass, handlerFn) {
  let newCtrlDef = $.extend({}, CONST_TEMPLATE_CONTROL_DEFINITION, {});
  newCtrlDef.name      = name;
  newCtrlDef.cssClass  = cssClass;
  newCtrlDef.handlerFn = handlerFn;
  return newCtrlDef;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewFieldDefinition
 * @private
 * @summary      Factory function.  Generates a new field definition
 * @description  Factory function.  Generates a new field definition
 * @param  {string}    name
 * @param  {string}    label
 * @param  {string}    dataType
 * @param  {bool}      sortable
 * @param  {bool}      isRecID
 */

let _fnCreateNewFieldDefinition = function (name, label, dataType, sortable, sortUsing, showMore, isRecID) {
    let newFldDef = $.extend({}, CONST_TEMPLATE_FIELD_DEFINITION, {});
	newFldDef.name      = name;
	newFldDef.label     = label;
	newFldDef.dataType  = dataType;
	newFldDef.sortable  = sortable;
	newFldDef.sortUsing = sortUsing;
	newFldDef.showMore  = showMore;
	newFldDef.isRecID   = isRecID;
    return newFldDef;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderCtrl
 * @private
 * @summary      Creates new control
 * @description  Creates new control
 */

let _fnRenderCtrl = function (ctrlDef, contextualAttrNameValues) {
  let $newCtrl = $('<button type="button"></button>');
  $newCtrl.attr(CONST_ATTR_NAME_UI_ELEMENT_TYPE, CONST_ATTR_VALUE_UI_ELEMENT_TYPE_CTRL);
  $newCtrl.attr(CONST_ATTR_NAME_TOOL_TIP, ctrlDef.toolTip);
  $newCtrl.addClass(CSS_CLASSES.ctrlButton);
  $newCtrl.attr(CONST_ATTR_NAME_CTRL_DEF_NAME,     ctrlDef.name);
  $newCtrl.attr(CONST_ATTR_NAME_CTRL_DEF_TYPE, ctrlDef.defType);
  $newCtrl.attr(CONST_ATTR_NAME_CTRL_OP_CLASS, ctrlDef.ctrlOpClass);
  if (ctrlDef.initiallyHidden === true) $newCtrl.addClass(CSS_CLASSES.hidden);
  $.each(contextualAttrNameValues, function (idx, contextualAttrNameValue) {
    $newCtrl.attr(contextualAttrNameValue.name, contextualAttrNameValue.value);
  });
  let $newCtrlIcon = _fnRenderCtrlIcon(ctrlDef.cssClass);
  $newCtrl.append($newCtrlIcon);
  return $newCtrl;
};

/*################################################################################################
  #
  #                                 Drawing Table Routines
  #
  #################################################################################################*/

/**
 * @function     _fnCreateNewCol
 * @private
 * @summary      Creates new table column
 * @description  Creates new table column
 * @param  {Object}  fieldDefinition  Field definition object
 */

let _fnCreateNewCol = function (rowIdxCtr, colIdxCtr, opts, fieldDefinition) {

  let $newCol = $('<th></th>');

  $newCol = opts.fnCreateNewColBefore($newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition);

  $newCol.attr(CONST_ATTR_NAME_ROW_IDX, rowIdxCtr);
  $newCol.attr(CONST_ATTR_NAME_COL_IDX, colIdxCtr);
  $newCol.attr(CONST_ATTR_NAME_FIELD_NAME, fieldDefinition.name);
  $newCol.attr(CONST_ATTR_NAME_SAVE_USING, fieldDefinition.saveUsing);
  $newCol.addClass(CSS_CLASSES.col);
  if (_fnHasValue(fieldDefinition.additionalCssClassesForCol) === true) $newCol.addClass(fieldDefinition.additionalCssClassesForCol);

  if (fieldDefinition.visible === false)
	$newCol.addClass(CSS_CLASSES.hidden);
  else
	$newCol.addClass(CSS_CLASSES.visibleTblTdOrTh);

  let $newColTop = $('<div></div>');
  $newColTop.addClass(CSS_CLASSES.colTop);
  $newColTop.addClass(CSS_CLASSES.dataTypes[fieldDefinition.dataType].cssClass);
  if (_fnHasValue(fieldDefinition.additionalCssClassesForColTop) === true) $newColTop.addClass(fieldDefinition.additionalCssClassesForColTop);

  let $newColLabel = $('<span></span>');
  $newColLabel.html(fieldDefinition.label);
  $newColLabel.addClass(CSS_CLASSES.colLabel);
  $newColLabel.addClass(CSS_CLASSES.dataTypes[fieldDefinition.dataType].cssClass);
  $newColLabel.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);

  if (_fnHasValue(fieldDefinition.additionalCssClassesForColLabel) === true) $newColLabel.addClass(fieldDefinition.additionalCssClassesForColLabel);

  /* Add label to col top */

  $($newColTop).append($newColLabel);

  /* Add sort controls to col top  */

  if ((fieldDefinition.sortable === true) && (opts.enableSortControls === true)) {

	let $newSortCtrls = $('<span></span>');

	$newSortCtrls.addClass(CSS_CLASSES.colSortCtrls);
	//$newSortCtrls.addClass(CSS_CLASSES.ctrlButtonsRadioGroup);

    let sortUsing   = _fnCreateNameValueObj(CONST_ATTR_NAME_SORT_USING, fieldDefinition.sortUsing);
    let sortDirAsc  = _fnCreateNameValueObj(CONST_ATTR_NAME_SORT_DIR, 'asc');
	let sortDirDesc = _fnCreateNameValueObj(CONST_ATTR_NAME_SORT_DIR, 'desc');

	let sortAscAttrNameVals = [];
	sortAscAttrNameVals.push(sortUsing);
	sortAscAttrNameVals.push(sortDirAsc);

    let sortDescAttrNameVals = [];
	sortDescAttrNameVals.push(sortUsing);
	sortDescAttrNameVals.push(sortDirDesc);

	$newSortCtrls.append(_fnRenderCtrl(CONST_BUILT_IN_CONTROL_TYPES.colsortasc, sortAscAttrNameVals));
	$newSortCtrls.append(_fnRenderCtrl(CONST_BUILT_IN_CONTROL_TYPES.colsortdesc, sortDescAttrNameVals));
	$($newColTop).append($newSortCtrls);

  }

  let $newColCtrls = $('<div></div>')
  $newColCtrls.addClass(CSS_CLASSES.colCtrls);

  $newCol.append($newColTop);
  $newCol.append($newColCtrls);

  $newCol = opts.fnCreateNewColAfter($newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition);

  return $newCol;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnForceAutoCompleteSearch
 * @private
 * @summary      Forces jQuery UI autocomplete to clear input and open all selections
 * @description  Forces jQuery UI autocomplete to clear input and open all selections
 */

let _fnForceAutoCompleteSearch = function ($selInp) {
	$($selInp).val('');
	$($selInp).autocomplete('option', 'minLength', 0);
	$($selInp).autocomplete('close');
	$($selInp).autocomplete('search');
	$($selInp).autocomplete('option', 'minLength', 1);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewCellValue
 * @private
 * @summary      Creates new table cell value
 * @description  Creates new table cell value
 * @param  {object}  fieldDefinition  Field definition object
 * @param  {string}  fieldValue       value to put in cell
 */

 let _fnCreateNewCellValue = function (dataObj, fieldDefinition, fieldValue, rowData, newRow) {

  let $newCellValue = null;
  let hasFieldValue = true;
  if ((typeof fieldValue === 'undefined') || (fieldValue === null)) {
     hasFieldValue = false;
  }

  if (fieldDefinition.editable === true) {
	  $newCellValue = CONST_BUILT_IN_DATA_TYPES[fieldDefinition.dataType].fnRenderFieldIfEditable(fieldDefinition, hasFieldValue, fieldValue, rowData, dataObj, newRow);
	  $newCellValue.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
	  $newCellValue.attr('disabled','');
   }
   else {
      $newCellValue = CONST_BUILT_IN_DATA_TYPES[fieldDefinition.dataType].fnRenderField(fieldDefinition, hasFieldValue, fieldValue, rowData, dataObj, newRow);
   }

   if (_fnHasValue(fieldDefinition.additionalCssClassesForCellValue) === true) $($newCellValue).addClass(fieldDefinition.additionalCssClassesForCellValue);
   if (_fnHasValue(fieldDefinition.styleAttrValueForCellValue) === true) $($newCellValue).attr('style', fieldDefinition.styleAttrValueForCellValue);

   /* ids have to start with a letter */

   let _newCellID = 'mba-' + fieldDefinition.name + '-' + _createNewUUID();
   $newCellValue.attr('id', _newCellID)
   $newCellValue.attr(CONST_ATTR_NAME_FIELD_NAME, fieldDefinition.name);

   if (fieldDefinition.saveable === true) {
     $newCellValue.attr(CONST_ATTR_NAME_SAVE_USING, fieldDefinition.saveUsing);
   }

   $newCellValue.addClass(CSS_CLASSES.cellValue);
   $newCellValue.addClass(CSS_CLASSES.dataTypes[fieldDefinition.dataType].cssClass);
   $newCellValue.attr(CONST_ATTR_NAME_UI_ELEMENT_TYPE, CONST_ATTR_VALUE_UI_ELEMENT_TYPE_FIELD_VALUE);
   $newCellValue.attr(CONST_ATTR_NAME_CTRL_DEF_NAME, CONST_BUILT_IN_DATA_TYPES[fieldDefinition.dataType].name);
   $newCellValue.attr(CONST_ATTR_NAME_CTRL_DEF_TYPE, CONST_BUILT_IN_DATA_TYPES[fieldDefinition.dataType].defType);

   /* If the field has the show more option enabled and there is data to show, we wrap the cell value in a details element and
    * return the combined markup */

  if ((fieldDefinition.showMore === true) && (hasFieldValue === true)) {
    let $newCellDetails = $('<details></details>');
    $($newCellDetails).addClass(CSS_CLASSES.cellDetails);
	let $newCellSummary = $('<summary>Click to Show Or Hide</summary>');
	$($newCellSummary).addClass(CSS_CLASSES.cellSummary);
	$($newCellDetails).append($newCellSummary);
	$($newCellDetails).append($newCellValue);
	return $newCellDetails;
  }

  /* If the field is a usd amount then we have some additional markup to add */

  if ((fieldDefinition.dataType === 'usd') && (fieldDefinition.editable === true))
  {
	   let $newInputCont = $('<fieldset></fieldset>');
	   let $newSymbol = $('<span>$</span>');
	   $($newInputCont).addClass(CSS_CLASSES.usdFieldSet);
	   $newInputCont.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
	   $newInputCont.attr('disabled', '');
	   $($newSymbol).addClass(CSS_CLASSES.usdSymbol);
	   $newInputCont.append($newSymbol);
	   $newInputCont.append($newCellValue);
	  return $newInputCont;
  }

  /* If the field is a radiooption then we have some additional markup to add */

  if (fieldDefinition.dataType === 'radiooption') {
	  let $newOptCont = $('<span></span>');
	  let $newLabel = $('<label></label>');
	  $newLabel.attr('for', $($newCellValue).attr('id'));
	  $newLabel.addClass(CSS_CLASSES.radioOptionLabel);
	  $newLabel.html(fieldDefinition.dataTypeOptions.radioOptionText);
	  $newOptCont.append($newCellValue);
	  $newOptCont.append($newLabel);
	  return $newOptCont;
  }

  /* If the field is an autocomplete then we have some additional markup to add.*/

  if (fieldDefinition.dataType === 'autocomplete') {

	  let $dropDownCtrl = $('<button type="button"></button>');
	  $dropDownCtrl.addClass(CSS_CLASSES.autoCompleteDropDownButton);

	  let $dropDownIcon = _fnRenderIconBase();
	  $($dropDownIcon).addClass(CSS_CLASSES.autoCompleteDropDownIcon);
	  $($dropDownIcon).addClass('fas fa-chevron-down');

	  $dropDownCtrl.append($dropDownIcon);

	  $($dropDownCtrl).click(function (e) {
		  _fnForceAutoCompleteSearch($newCellValue);
	  });

	  let $loadingIcon = $('<i></i>');
	  $($loadingIcon).addClass(CSS_CLASSES.autoCompleteLoadingIcon);
	  $($loadingIcon).addClass('fa fa-spinner fa-spin');
	  $($loadingIcon).hide();

	  let $newAcCont = $('<fieldset></fieldset>');
	  $newAcCont.addClass(CSS_CLASSES.autoCompleteFieldSet);

	  if (fieldDefinition.editable === true) {
		  $newAcCont.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
		  $newAcCont.attr('disabled', '');
	  }

	  $newAcCont.append($newCellValue);
	  $newAcCont.append($dropDownCtrl);
	  $newAcCont.append($loadingIcon);
	  return $newAcCont;
   }

   /* If the field is checkboxselectionsjson then we have a plugin to call and some additional attributes to add */

   if (fieldDefinition.dataType === 'checkboxselectionsjson') {
	   let cbsOpts = fieldDefinition.dataTypeOptions;
	   cbsOpts.additionalChangeEventForHiddenTa = CONST_EVENT_NAME_EDIT_CANCEL;  /* Wires up edit cancel */
	   $($newCellValue).MBA_Check_Box_Selections_JSON(cbsOpts);
	   let _newCdObj = $($newCellValue).MBA_Check_Box_Selections_JSON('getComponentData');
	   let $newCbs = $(_newCdObj.container);
	   /* Add some attributes to containing element... this is what we will add to restview */
	   $newCbs.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
	   if (fieldDefinition.editable === true) {
		  $newCbs.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
		  $newCbs.attr('disabled', '');
	   }
	   else {
		  $newCbs.attr('disabled', '');
       }
	   return $newCbs;
	 }

	 /* If the field is autocompletemultiple then we have a plugin to call and some additional attributes to add */

	 if (fieldDefinition.dataType === 'autocompletemultiple') {
		 let acMultiOpts = fieldDefinition.dataTypeOptions;
		 acMultiOpts.additionalChangeEventForHiddenTa = CONST_EVENT_NAME_EDIT_CANCEL;  /* Wires up edit cancel */
		 acMultiOpts.fnGetRequestNvps = function () {
			 let _rowRef         = newRow;
			 let _saveableFields = _fnGetSaveableFields(_rowRef);
			 let _nvpsIn         = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields(_saveableFields);
			 return _nvpsIn;
		 };
		 $($newCellValue).MBA_Autocomplete_Multiple(acMultiOpts);
		 let _newCdObj = $($newCellValue).MBA_Autocomplete_Multiple('getComponentData');
		 let $newAcMulti = $(_newCdObj.container);
		 /* Add some attributes to containing element... this is what we will add to restview */
		 $newAcMulti.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
		 if (fieldDefinition.editable === true) {
			 $newAcMulti.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
			 $newAcMulti.attr('disabled', '');
		 }
		 else {
			 $newAcMulti.attr('disabled', '');
		 }
		 return $newAcMulti;
     }

	 /* If the field is a checkbox then we might have additional markup to add */

	 if (fieldDefinition.dataType === 'checkbox') {

		 /* If options are present*/

		 if (fieldDefinition.dataTypeOptions) {

			 /* If the option is to render a label inline */

			 if (fieldDefinition.dataTypeOptions.renderLabelInline === true) {
				 let $newCbCont = $('<label></label>');
				 $($newCbCont).addClass('mba-rest-view-data-type-checkbox-inline-cont');
				 let $newLblTxt = $('<span>' + fieldDefinition.label + '</span>')
				 $($newLblTxt).addClass('mba-rest-view-data-type-checkbox-inline-lbl');
				 
				 $($newCellValue).removeClass('mba-rest-view-data-type-checkbox');
				 $($newCellValue).addClass('mba-rest-view-data-type-checkbox-inline-ctrl');

				 $newCbCont.attr('for', $($newCellValue).attr('id'));
				 $newCbCont.append($newLblTxt);
				 $newCbCont.append($newCellValue);
				 $newCbCont.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);
				 if (fieldDefinition.editable === true) {
					 $newCbCont.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
					 $newCbCont.attr('disabled', '');
				 }
				 else {
					 $newCbCont.attr('disabled', '');
				 }
				 return $newCbCont;
             }
       }
		 
	 }

	 /* Otherwise just return the cell value */

  return $newCellValue;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewCell
 * @private
 * @summary      Creates new table cell
 * @description  Creates new table cell
 * @param  {object}  fieldDefinition  Field definition object
 * @param  {string}  fieldValue       value to put in cell
 */

let _fnCreateNewCell = function (subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData) {
  let $newCell = $('<td></td>');
  $newCell = dataObj.opts.fnCreateNewCellBefore($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData);
  $newCell.attr(CONST_ATTR_NAME_CELL, '');
  $newCell.attr(CONST_ATTR_NAME_ROW_IDX, rowIdxCtr);
  $newCell.attr(CONST_ATTR_NAME_COL_IDX, colIdxCtr);
  $newCell.attr(CONST_ATTR_NAME_FIELD_NAME, fieldDefinition.name);
  $newCell.addClass(CSS_CLASSES.cell);
  if (_fnHasValue(fieldDefinition.additionalCssClassesForCell) === true) $newCell.addClass(fieldDefinition.additionalCssClassesForCell);
  let $newCellValue = _fnCreateNewCellValue(dataObj, fieldDefinition, fieldValue, rowData, newRow);
  $newCell.append($newCellValue);

  /* Take care of visibility */

	if (fieldDefinition.visible === false) {
		$newCell.addClass(CSS_CLASSES.hidden);
	}
	else {
		$newCell.addClass(CSS_CLASSES.visibleTblTdOrTh);
	}
	if (!fieldDefinition.additionalCellValueFieldDefinitions) fieldDefinition.additionalCellValueFieldDefinitions = [];
	let addCellValRefs = [];
	let addCellValRefsMap = new Map();

	$.each(fieldDefinition.additionalCellValueFieldDefinitions, function (fdIdx, addFldDef) {
		let addFldVal = '' + rowData[addFldDef.name];
		let $addCellValue = _fnCreateNewCellValue(dataObj, addFldDef, addFldVal, rowData, newRow);
		addCellValRefs.push($addCellValue);
		addCellValRefsMap.set(addFldDef.name, $addCellValue);
		$($newCell).append($addCellValue);
	 });

	$newCell = dataObj.opts.fnCreateNewCellAfter($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);

 return $newCell;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewRow
 * @private
 * @summary      Creates new table header or body row
 * @description  Creates new table header or body row
 * @param  {object}  opts           Options object
 * @param  {string}  rowCtrVal      Row counter value
 * @param  {array}   rowCtrlDefs    Row control definitions
 */

let _fnCreateNewRow = function (section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData, rowKey) {

	if (!rowCtrVal) rowCtrVal = '';
	let $newRow = $('<tr></tr>');

	$newRow = opts.fnCreateNewRowBefore($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData);

    /* Add class and attr */

	$($newRow).addClass(CSS_CLASSES.row);
	$($newRow.attr(CONST_ATTR_NAME_ROW_TYPE, rowtype));
	if (rowKey) $($newRow.attr(CONST_ATTR_NAME_MAP_KEY, rowKey));

	/* Add tracking attribute for detection if row is unlocked for edit or delete */

	$($newRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_FALSE);

	/* If row marking is enabled add the attribute we use to track the row mark state*/

	if (((opts.enableRowControlMarkRow === true) || (opts.enableMarkRowWithoutControl === true)) && (subsection === SUB_SECTIONS.TBODY_EXISTING) && (rowtype === ROW_TYPE.EXISTING_ROW))
	{
	  $($newRow).attr(CONST_ATTR_NAME_ROW_MARKED, CONST_ATTR_VALUE_MARKED_FALSE);
	}

    /* Add row numbers col */

	if (opts.enableRowNumbers === true) {
	  let $newRowCtr = $(thTemplate);
	  $newRowCtr.addClass(CSS_CLASSES.rowCtr);
	  $newRowCtr.addClass(CSS_CLASSES.visibleTblTdOrTh);
	  $newRowCtr.append(rowCtrVal);
	  $newRowCtr.attr(CONST_ATTR_NAME_ROW_COUNTER,"1");
	  $newRow.append($newRowCtr);
	}

    /* Add controls col */

	if (opts.enableRowControls === true) {
	  let $newRowCtrls = $(thTemplate);
	  $newRowCtrls.addClass(CSS_CLASSES.rowCtrls);
	  $newRowCtrls.addClass(CSS_CLASSES.visibleTblTdOrTh);
	  let rowCtrlCount = 0;
	  $.each(rowCtrlDefs, function (rowCtrlIdx, rowCtrlDefIn) {
		let rowCtrlDefOut = opts.fnAddRowControlDefBefore($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefIn, rowCtrlIdx, rowData);
		$newRowCtrls.append( _fnRenderCtrl(rowCtrlDefOut,[]) );
		rowCtrlCount++;
	  });
	  $newRowCtrls.attr(CONST_ATTR_NAME_ROW_CONTROLS, '' + rowCtrlCount);
	  $newRow.append($newRowCtrls);
	}

    /* Add notifications col*/

	if ((opts.enableRowNotifications === true) || (opts.enableRowControls === true)) {
	  let $newRowNotifications = $(thTemplate);
	  $newRowNotifications.addClass(CSS_CLASSES.rowNotifications);
	  $newRowNotifications.addClass(CSS_CLASSES.visibleTblTdOrTh);
	  $newRowNotifications.attr(CONST_ATTR_NAME_ROW_NOTIFICATIONS, "0");
	  $newRow.append($newRowNotifications);
	}

	$newRow = opts.fnCreateNewRowAfter($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData);

	return $newRow;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnInitColsThatHaveColTitleReplacements
 * @private
 * @summary     Initialize columns that have column title replacements
 * @description  Initialize columns that have column title replacements
 * @param  {object}  elem         Control
 */

let _fnInitColsThatHaveColTitleReplacements = function (elem) {
  let $me     = _fnGetMe(elem);
  let dataObj = _fnLoadDataObj($me);
  if (dataObj.opts.hasColTitleReplacements === true) {
	for (let fldNameToReplaceLabel in dataObj.opts.colTitleReplacements) {
	  _fnChangeColumnLabel(elem, fldNameToReplaceLabel, '', '');
	  _fnHideColumn(elem, fldNameToReplaceLabel);
	}
	dataObj = _fnLoadDataObj($me);
  }
  return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDrawTableBodyRows
 * @private
 * @summary      Draws rows in table body
 * @description  Draws rows in table body
 * @param  {object}  elem         Control
 * @param  {object}  returnData   Data returned from server
 */

let _fnDrawTableBodyRows = function (elem, returnData) {

  let $me = _fnGetMe(elem);
  let dataObj = _fnLoadDataObj($me);

  /* Code injection hook */

  returnData = dataObj.opts.fnBeforeDrawTableBodyRows(elem,returnData,$me,dataObj);

  /* Remove previous rows */

  $(dataObj.tbody).html('');

  /* Init colums that have col title replacements (if any) */

  dataObj = _fnInitColsThatHaveColTitleReplacements(elem);

  /* No rows? */

  if (dataObj.hasRecords === false) {
	 _fnShowMessageOverlay(elem);
	 _fnUpdateStatusContent(elem, 'No records found');
	 _fnUpdateMessageOverlayContent(elem, 'No records found');
	 _fnHideMessageOverlay(elem, 1500);
	 _fnClearMessageOverlay(elem);
	 return;
  }

  let rowNumCtr = dataObj.currentPageRecNumStart;
  let rowIdxCtr = 1;
  let rowCtrls = [];

  /* User provided controls (add before) */

  if (dataObj.opts.positionUserDefinedControlsInBodyExisting === POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN) {
    dataObj.opts.additionalControlDefinitionsForBodyRows.forEach(function (value, key) {

    //  debugger ;

	  rowCtrls.push(value);
    });
  }

  /* Mark row */

  if (dataObj.opts.enableRowControlMarkRow === true) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.markRow);
  }

  /* Send message for row  */

  if (dataObj.opts.enableRowControlSendMessageForRow === true) {
    rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.sendMessageForRow);
  }

  /* Manage files for row  */

  if (dataObj.opts.enableRowControlManageFilesForRow === true) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.manageFilesForRow);
  }

  /* Show additional info */

  if (dataObj.opts.enableRowControlShowAdditionalInfo === true) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.showAdditionalInfoForRow);
  }

  /* Clone controls */

  if (dataObj.opts.enableRowControlRecClone === true) {

    if (dataObj.opts.saveModeClone === CONST_SAVE_MODE_INLINE) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reccloneinlinestart);
	}
	else if (dataObj.opts.saveModeClone === CONST_SAVE_MODE_CUSTOM) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recclonecustom);
	}
  }

  /* Edit controls */

  if (dataObj.opts.enableRowControlRecEdit === true) {

    if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_INLINE) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlinestart);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlineproceed);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlinecancel);
	}
	else if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_INWINDOW) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinwindow);
    }
	else if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_CUSTOM) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditcustom);
	}
  }

  /* Delete controls */

  if (dataObj.opts.enableRowControlRecDelete === true) {

    if (dataObj.opts.saveModeDelete === CONST_SAVE_MODE_INLINE) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlinestart);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlineproceed);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlinecancel);
	 }
	 else if (dataObj.opts.saveModeDelete === CONST_SAVE_MODE_CUSTOM) {
	   rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeletecustom);
	 }
   }

   /* UnDelete controls */

   if (dataObj.opts.enableRowControlRecUnDelete === true) {
     if (dataObj.opts.saveModeUnDelete === CONST_SAVE_MODE_INLINE) {
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlinestart);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlineproceed);
	  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlinecancel);
	 }
	 else if (dataObj.opts.saveModeUnDelete === CONST_SAVE_MODE_CUSTOM) {
	   rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeletecustom);
	 }
   }

   /* User provided controls (add after) */

	if (dataObj.opts.positionUserDefinedControlsInBodyExisting === POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN) {
		dataObj.opts.additionalControlDefinitionsForBodyRows.forEach(function (value, key) {

     // debugger ;

			rowCtrls.push(value);
		});
	}


  /* Define selectors*/

 let delUnDelCtrlSelectorStart = 'button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '=';
 let delCtrlStartSelector      = delUnDelCtrlSelectorStart + '' + CTRL_OP_CLASSES.DELETE_START + ']';
 let unDelCtrlStartSelector    = delUnDelCtrlSelectorStart + '' + CTRL_OP_CLASSES.UNDELETE_START + ']';

  /* Handle col title replacements */

  if (dataObj.opts.hasColTitleReplacements === true) {
	  let firstRow = returnData.data[0];
	  for (let fldNameToReplaceLabel in dataObj.opts.colTitleReplacements) {
		  let fldfNameThatHasReplacement = dataObj.opts.colTitleReplacements[fldNameToReplaceLabel];
		  let newLabel = firstRow[fldfNameThatHasReplacement];
		  if (newLabel != '') {
			  let newLabelWithBreaks = newLabel.replace(/ /g, '<br>');
			  _fnChangeColumnLabel(elem, fldNameToReplaceLabel, newLabelWithBreaks, newLabel);
			  _fnShowColumn(elem, fldNameToReplaceLabel);
		  }
	  }
	  dataObj = _fnLoadDataObj($me);
  };

  /* For each object returned */

  $.each(returnData.data, function (rowDatIdx, rowData) {

    /* Generate new row and any row control cells */

	let $newRow = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.TBODY_EXISTING, ROW_TYPE.EXISTING_ROW, dataObj.opts, '<td></td>', rowNumCtr, rowCtrls, rowData);

	// save row data with the row
	$($newRow).data(CONST_DATA_NAME_ROW_DATA, rowData);

	/* Render the field specific cells and append to new row */

	let colIdxCtr = 1;
	$.each(dataObj.opts.fieldDefinitions, function (fldDefIdx, fieldDefinition) {
	  let fldName    = fieldDefinition.name;
	  let fieldValue = rowData[fldName];

      /* If this is the recID field then we put the rec id in an attribute and we skip rendering this cell */

      if (fieldDefinition.isRecID === true) {
		$($newRow).attr(CONST_ATTR_NAME_FOR_REC_ID, fieldValue);
		return; /* This is the same as a "continue" */
	  }

	  if (fieldDefinition.isActiveFlag === true) {
		 $($newRow).attr(CONST_ATTR_NAME_FOR_ACTIVE_FLAG, fieldValue);
		return; /* This is the same as a "continue" */
	  }

	  if (fieldDefinition.isCanEditFlag === true) {
		 $($newRow).attr(CONST_ATTR_NAME_FOR_CAN_EDIT_FLAG , fieldValue);
		 return; /* This is the same as a "continue" */
	  }

	  if (fieldDefinition.isCanDeleteFlag === true) {
		$($newRow).attr(CONST_ATTR_NAME_FOR_CAN_DELETE_FLAG, fieldValue);
		return; /* This is the same as a "continue" */
	  }

	  if (fieldDefinition.isCanUnDeleteFlag === true) {
		$($newRow).attr(CONST_ATTR_NAME_FOR_CAN_UNDELETE_FLAG, fieldValue);
		return; /* This is the same as a "continue" */
	  }

      /* Otherwise create the cell */

	  let $newCell = _fnCreateNewCell(SUB_SECTIONS.TBODY_EXISTING, ROW_TYPE.EXISTING_ROW, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, $newRow, rowData);
	  $($newRow).append($newCell);
	  colIdxCtr++;
	});

    /* Auto show hide delete/undelete options */

	if (dataObj.opts.autoShowHideDeleteUnDelete === true) {
		let isRecActive = _fnFlagValueToTrueFalse($($newRow).attr(CONST_ATTR_NAME_FOR_ACTIVE_FLAG));
		if (isRecActive === true) {
			$($newRow).find(unDelCtrlStartSelector).remove();
		}
		else if (isRecActive === false) {
			$($newRow).find(delCtrlStartSelector).remove();
		}
		else {

        }
	}

    /* Code injection hook */

	$newRow = dataObj.opts.fnNewRowBeforeAppendToBodyExisting ($newRow, rowData, dataObj.opts);

    /* Add the row to the body */
    $(dataObj.tbody).append($newRow);
	rowNumCtr++;
	rowIdxCtr++;

  });

  /* Return to the top of the table */

  dataObj.tableContainer.scrollTop(0);

  /* Update status */

  let newStatusContent = 'Displaying ' + dataObj.currentPageRecNumStart + ' to ' + dataObj.currentPageRecNumEnd + ' of ' + dataObj.recordsTotal + ' records available.'
  _fnUpdateStatusContent(elem, newStatusContent);
  _fnHideMessageOverlay(elem);
  _fnClearMessageOverlay(elem);

  /* Code hook for after body rows drawn */

  dataObj.opts.fnOnAfterDrawTableBodyRows(elem, $me, dataObj);

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewPageJumpButton
 * @private
 * @summary      Creates button that jumps to a given pageNum
 * @description  Creates button that jumps to a given pageNum
 */

let _fnCreateNewPageJumpButton = function (label, pageNum) {
   let $pageJumpButton = $('<button type="button">' + label + '</button>');
   $($pageJumpButton).addClass(CSS_CLASSES.ctrlButtonJumpPage);
   $($pageJumpButton).attr(CONST_ATTR_NAME_JUMP_TO_PAGE, pageNum);
  return $pageJumpButton;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewPageJumpButtonSpacer
 * @private
 * @summary      Creates spacer that goes between jump button groups
 * @description  Creates spacer that goes between jump button groups
 */

let _fnCreateNewPageJumpButtonSpacer = function () {
  let $spacer = $('<span>...</span>');
  $($spacer).addClass(CSS_CLASSES.ctrlSpacerJumpPage);
  return $spacer;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDrawPagingControls
 * @private
 * @summary      Draws paging controls
 * @description  Draws paging controls
 * @param  {object}  dataObj      Data object stored with $me
 * @param  {object}  returnData   Data returned from server
 */

let _fnDrawPagingControls = function (elem, responseData) {

  let $me = _fnGetMe(elem);
  let dataObj = _fnLoadDataObj($me);

  /* Set page number input to actual page number returned */

  $(dataObj.ctrlPageNumber).val(dataObj.currentPageNumber);
  $(dataObj.ctrlPageNumber).attr('max', dataObj.pagesTotal);
  $(dataObj.ctrPageCount).html(dataObj.pagesTotal);

  /* Get previous and next pages with respect to current page */

  let prevPage = dataObj.currentPageNumber - 1;
  let nextPage = dataObj.currentPageNumber + 1;
  if (prevPage < 1)                  prevPage = 1;
  if (nextPage > dataObj.pagesTotal) nextPage = dataObj.pagesTotal;

  /* Reset previous and next page nunbers for previous next page buttons */

  $(dataObj.ctrlPrevPage).attr(CONST_ATTR_NAME_JUMP_TO_PAGE, prevPage);
  $(dataObj.ctrlNextPage).attr(CONST_ATTR_NAME_JUMP_TO_PAGE, nextPage);

  /* Clear out "jump to page" buttons */

  $(dataObj.pageJumpButtonsContainer).html('');

  /* Auto hide page controls */

  if (dataObj.opts.autoHidePageControls == true) {

	  $(dataObj.currentStatusContainer).removeClass(CSS_CLASSES.hidden);
	  $(dataObj.pageCtrlsContainer).removeClass(CSS_CLASSES.hidden);
	  if (   (dataObj.hasRecords === false)
		  || (dataObj.pagesTotal == 1)
		  || (dataObj.pagesTotal == 0))
	  {
		$(dataObj.currentStatusContainer).addClass(CSS_CLASSES.hidden);
        $(dataObj.pageCtrlsContainer).addClass(CSS_CLASSES.hidden);
	  }
  }

  if (dataObj.hasRecords === false) {
    return;
  }

  /* Compute page groups */

  let pageGroups = new Array();
  let whatPageGroup = null;

  if (dataObj.opts.numOfJumpPages > 0)
  {
    let numPageGroups = (((dataObj.pagesTotal / dataObj.opts.numOfJumpPages) | 0 /* | 0 converts to int*/)
	   		        + (((dataObj.pagesTotal % dataObj.opts.numOfJumpPages) > 0) ? 1 : 0));


    let pageGroupNum = 0;
    for (pageGroupNum = 1; pageGroupNum <= numPageGroups; pageGroupNum++) {
      let pageGroupObj = {};
	   pageGroupObj.pageGroupNum = pageGroupNum;
	   pageGroupObj.endPage = (pageGroupNum * dataObj.opts.numOfJumpPages);
	   pageGroupObj.startPage = ((pageGroupObj.endPage - dataObj.opts.numOfJumpPages) + 1);
	   pageGroups.push(pageGroupObj);
	}
    let _fnFind = function (element) {
		  return ((dataObj.currentPageNumber >= element.startPage) && (dataObj.currentPageNumber <= element.endPage));
	};
	whatPageGroup = pageGroups.find(_fnFind);
  }

  /* Determine if we show or hide the goto first/last page buttons */

  let showGotoFirst = false;
  let showGotoLast = false;
  if (whatPageGroup.pageGroupNum > 1) showGotoFirst = true;
  if (dataObj.currentPageNumber < dataObj.pagesTotal) showGotoLast = true;

  /* Show goto first page button if it should be shown */

  if (showGotoFirst === true) {
    $(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButton(1, 1));
	$(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButtonSpacer());
  }

  $(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButton('<', prevPage));

  let pageIdx = 0;
  for (pageIdx = whatPageGroup.startPage; pageIdx <= whatPageGroup.endPage; pageIdx++) {
    if (pageIdx > dataObj.pagesTotal) break;
	let $pageJumpButton = _fnCreateNewPageJumpButton(pageIdx, pageIdx);
	if (pageIdx === dataObj.currentPageNumber) {
	  $pageJumpButton.addClass(CSS_CLASSES.ctrlButtonJumpPageCurrent)
	}
	$(dataObj.pageJumpButtonsContainer).append($pageJumpButton);
  }

  $(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButton('>', nextPage));

  /* Show goto last page button if it should be shown */

  if (showGotoLast === true) {
	$(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButtonSpacer());
    $(dataObj.pageJumpButtonsContainer).append(_fnCreateNewPageJumpButton(dataObj.pagesTotal, dataObj.pagesTotal));
  }

  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHandleCellValueAction
 * @private
 * @summary      Handles cell value actions
 * @description  Handles cell value actions
 */

let _fnHandleCellValueAction = function (uiActionObj) {

	if (!uiActionObj.fieldDefinition.dataTypeOptions) return uiActionObj;
	let _hf = uiActionObj.fieldDefinition.dataTypeOptions.fnHandleCellValueAction;
	if (!_hf) return uiActionObj;
    return _hf(uiActionObj);
}


/*################################################################################################
  #
  #                                  Common Inline Op Routines
  #
  #################################################################################################*/

/**
 * @function     _fnCtrlOpInlineGetEditableFields
 * @private
 * @summary      Gets fields that are editable in given row
 * @description  Gets fields that are editable in given row
 */

let _fnCtrlOpInlineGetEditableFields = function (uiActionObj, whatRow) {
  if (!whatRow) { whatRow = uiActionObj.whatRow; }
  let $editableFields = $(whatRow).find('*[' + CONST_ATTR_NAME_FIELD_EDIT_STATE + ']');
  return $editableFields;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineUnlockEditableFields
 * @private
 * @summary      Unlocked fields flagged as editable
 * @description  Unlocked fields flagged as editable
 */

let _fnCtrlOpInlineUnlockEditableFields = function (uiActionObj,whatRow, animate = true) {
	let flds = $(_fnCtrlOpInlineGetEditableFields(uiActionObj, whatRow)).attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED).removeAttr('disabled');
	if (animate == true) {
		$(flds).addClass(CSS_CLASSES.animated);
    }
	return flds;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineUnlockEditableField
 * @private
 * @summary      Unlock field flagged as editable
 * @description  Unlock field flagged as editable
 */

let _fnCtrlOpInlineUnlockEditableField = function (fld, animate = true) {
	let fldOut = $(fld).attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED).removeAttr('disabled');
	if (animate == true) $(fldOut).addClass(CSS_CLASSES.animated);
	return fldOut;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineLockEditableFields
 * @private
 * @summary      Locked fields flagged as editable
 * @description  Locked fields flagged as editable
 */

let _fnCtrlOpInlineLockEditableFields = function (uiActionObj,whatRow) {
	return $(_fnCtrlOpInlineGetEditableFields(uiActionObj, whatRow))
		.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED)
		.attr('disabled', '')
		.autocomplete('close')
		.removeClass(CSS_CLASSES.animated);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineLockEditableField
 * @private
 * @summary      Lock field flagged as editable
 * @description  Lock field flagged as editable
 */

let _fnCtrlOpInlineLockEditableField = function (fld) {
	return $(fld)
		.attr(CONST_ATTR_NAME_FIELD_EDIT_STATE, CONST_ATTR_VALUE_EDIT_STATE_LOCKED)
		.attr('disabled', '')
		.autocomplete('close')
		.removeClass(CSS_CLASSES.animated);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineGetSavableFields
 * @private
 * @summary      Gets saveable fields
 * @description  Gets saveable fields
 */

let _fnCtrlOpInlineGetSaveableFields = function (uiActionObj) {
  let $saveableFields = _fnGetSaveableFields(uiActionObj.whatRow);
  return $saveableFields;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineGetNameValuePairsFromSaveableFields
 * @private
 * @summary      Gets array of name value pair objects from savable fields
 * @description  Gets array of name value pair objects from savable fields
 */

let _fnCtrlOpInlineGetNameValuePairsFromSaveableFields = function ($saveableFields) {
  let nvps = [];
	$.each($saveableFields, function (fi, $field) {
		let fn  = $($field).attr(CONST_ATTR_NAME_SAVE_USING);
		let fv  = _fnGetFieldValue($field);
	    nvps.push(_fnCreateNameValueObj(fn, fv));
  });
  return nvps;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCtrlOpInlineRequestDataObjFromNvpObjs
 * @private
 * @summary      Takes array of name value pair objects and creates an object out of them
 * @description  Takes array of name value pair objects and creates an object out of them
 */

let _fnCtrlOpInlineRequestDataObjFromNvpObjs = function (nvpObjs) {
  let requestDataObj = {};
  $.each(nvpObjs, function (idx, nvpObj) {
	requestDataObj[nvpObj.name] = '' + nvpObj.value; /* Note each value is converted to a string */
  });
  return requestDataObj;
}



/*################################################################################################
  #
  #                                  "For Row" Handlers
  #
  #################################################################################################*/

/**
 * @function     _fnShowAdditionalInfoForRow
 * @private
 * @summary      Shows additional info in a dialog
 * @description  Shows additional info in a dialog
 */

let _fnShowAdditionalInfoForRow = function (uiActionObj) {

  let additionalInfoFieldDefinitions = uiActionObj.dataObj.opts.additionalInfoFieldDefinitions;	
  let rowData                        = $(uiActionObj.whatRow).data(CONST_DATA_NAME_ROW_DATA);
  let $addInfoContent = $('<table></table>');
  $($addInfoContent).addClass(CSS_CLASSES.additionalInfoTable);

  $.each(additionalInfoFieldDefinitions, function (fdIdx, additionalInfoFieldDefinition) {
    let $addInfoLbl = $('<th>' + additionalInfoFieldDefinition.label + '</th>');
	$($addInfoLbl).addClass(CSS_CLASSES.additionalInfoTable);
	let $addInfoVal = $('<td>' + rowData[additionalInfoFieldDefinition.name] + '</td>');
    $($addInfoVal).addClass(CSS_CLASSES.additionalInfoValue);
	$addInfoVal = uiActionObj.dataObj.opts.fnCreateAdditionalInfoCellValueAfter($addInfoVal, rowData, additionalInfoFieldDefinition);	  
	let $addInfoRow = $('<tr></tr>');
	$addInfoRow.append($addInfoLbl);
	$addInfoRow.append($addInfoVal);
	$addInfoRow.attr('title', additionalInfoFieldDefinition.toolTip);
    $addInfoContent.append($addInfoRow);
  });

	let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
	let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

	let _diaOpts = {};
	_diaOpts.show     = { effect: 'slide', direction: 'left' };
    _diaOpts.position = { my: 'center', at: 'center', of: window };
	_diaOpts.width = vw;
	_diaOpts.height = vh;

  MBA.ComponentCommon.fnCreateOneTimeInfoDialog('Additional Info', $addInfoContent, _diaOpts);
  return uiActionObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnMarkRow
 * @private
 * @summary      Marks or unmarks row
 * @description  Marks or unmarks row
 */

let _fnMarkRow = function (uiActionObj) {

	let $butMarkRow  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MARK_ROW + '"]')[0];
	let $iconMarkRow = $($butMarkRow).children('i.' + CONTROL_CSS_CLASS_MARK_ROW_ICON)[0];

	let markRowState = $(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_MARKED);

	$($iconMarkRow).removeClass(CONTROL_CSS_CLASS_UNSELECTED);
	$($iconMarkRow).removeClass(CONTROL_CSS_CLASS_SELECTED);
	
	/* Toggle to UNSELECTED */
	if (markRowState === CONST_ATTR_VALUE_MARKED_TRUE) {
		$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_MARKED, CONST_ATTR_VALUE_MARKED_FALSE);
		//_fnAnimateRowControlInfinite($butMarkRow, 'pulse', false, true);
		$($butMarkRow).attr(CONST_ATTR_NAME_TOOL_TIP, CONTROL_MARK_ROW_TOOLTIP_MARK);
		$($iconMarkRow).addClass(CONTROL_CSS_CLASS_UNSELECTED);
	}
	/* Toggle to SELECTED */
	else if (markRowState === CONST_ATTR_VALUE_MARKED_FALSE) {
		$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_MARKED, CONST_ATTR_VALUE_MARKED_TRUE);
		//_fnAnimateRowControlInfinite($butMarkRow, 'pulse', false, false);
		$($butMarkRow).attr(CONST_ATTR_NAME_TOOL_TIP, CONTROL_MARK_ROW_TOOLTIP_UNMARK);
		$($iconMarkRow).addClass(CONTROL_CSS_CLASS_SELECTED);
	}
	else {

	}
	let _markedRows = _fnFindMarkedRowsInTBody(uiActionObj.dataObj.tbody);
	uiActionObj = uiActionObj.dataObj.opts.fnOnRowMarked(uiActionObj, _markedRows);
    return uiActionObj;
};


/*################################################################################################
  #
  #                                  Add New (Inline) Routines
  #
  #################################################################################################*/

/**
 * @function     _fnAddNewInlineStart
 * @private
 * @summary      Starts add new
 * @description  Starts add new
 */

let _fnAddNewInlineStart = function (uiActionObj) {

	if (uiActionObj.dataObj.opts.fnOKToAddNew(uiActionObj) === false) {
	  return uiActionObj;
	}

	let rowCtrls = [];
	rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewinlineproceed);
	rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewinlinecancel);

	let rowData = {};
	rowData = uiActionObj.dataObj.opts.fnModifyRowDataBeforeAddNew(uiActionObj, rowData);
	let $newRow   = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.TBODY_NEW, ROW_TYPE.NEW_ROW, uiActionObj.dataObj.opts, '<td></td>', '', rowCtrls, rowData);
	let colIdxCtr = 1;

	$.each(uiActionObj.dataObj.opts.fieldDefinitions, function (fldDefIdx, fieldDefinition) {

		/* If this is the recID field then we skip rendering this cell */

		if (fieldDefinition.isRecID === true) {

			return; /* This is the same as a "continue" */
		}

   	    /* Same with active flag */
		if (fieldDefinition.isActiveFlag === true) return;

		/* Otherwise create the cell */

		let $newCell = _fnCreateNewCell(SUB_SECTIONS.TBODY_NEW, ROW_TYPE.NEW_ROW, uiActionObj.dataObj, '', colIdxCtr, fieldDefinition, '', $newRow, rowData);
		$($newRow).append($newCell);
		colIdxCtr++;
	});

	uiActionObj.newRow = $newRow;
	$(uiActionObj.dataObj.tbodyNew).append($newRow);
	_fnCtrlOpInlineUnlockEditableFields(uiActionObj, uiActionObj.newRow);

	/* Call hook */
	uiActionObj.dataObj.opts.fnOnAddNewInlineStart(uiActionObj);

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddNewInlineCancel
 * @private
 * @summary      Cancel add new in progress
 * @description  Cancel add new in progress
 */

let _fnAddNewInlineCancel = function (uiActionObj) {
  let $wRow = $(uiActionObj.whatRow);
  $($wRow).remove();
  /* Call hook */
  uiActionObj.dataObj.opts.fnOnAddNewInlineCancel(uiActionObj);
  return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddNewInlineProceed
 * @private
 * @summary      Saves new
 * @description  Saves new
 */

let _fnAddNewInlineProceed = function (uiActionObj) {

	let $fields = _fnCtrlOpInlineGetSaveableFields(uiActionObj);

	/* Before proceed we can make changes to the saveable fields (by ref) if setup in opts. */

	uiActionObj = uiActionObj.dataObj.opts.fnAddNewInlineProceedBefore(uiActionObj, $fields);

	let nvpObjs = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields($fields);

	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.recIDNameForAddNew, ""));
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.saveTypeNameForAddNew, uiActionObj.dataObj.opts.saveTypeValueForAddNew));

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForAddNew.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	let url = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlAddNew, uiActionObj.dataObj.opts.baseUrlAddNewHasParameters, null);
	let $wRow = $(uiActionObj.whatRow);

	/* Send add new request */

	let dataToPost = JSON.stringify(_fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs));
	let _me = uiActionObj.dataObj.me;
	_fnAjaxCallAsmxWebMethod(uiActionObj.elem, url, dataToPost)
		.then(responseData => {
			$(uiActionObj.notificationsCol).html('');
			$($wRow).remove();
			_fnRefreshCurrentViewFromServer(_me);
			uiActionObj.dataObj.opts.fnAddNewInlineProceedAfter(uiActionObj,responseData,true);
		})
		.catch(responseData => {
			$(uiActionObj.notificationsCol).html('');
			let $msgs = _fnRenderRowNotificationMessages(responseData.details);
			$(uiActionObj.notificationsCol).html($msgs);
			uiActionObj.dataObj.opts.fnAddNewInlineProceedAfter(uiActionObj, responseData, false);
		});

	return uiActionObj;
}

/*################################################################################################
  #
  #                               Clone Existing (Inline) Routines
  #
  #################################################################################################*/

/**
 * @function     _fnCloneInlineStart
 * @private
 * @summary      Starts clone
 * @description  Starts clone
 */

let _fnCloneInlineStart = function (uiActionObj) {

  let $originalCells = $(uiActionObj.whatRow).find('*[' + CONST_ATTR_NAME_CELL + ']');
  let $clonedCells   = $($originalCells).clone();

  let rowCtrls = [];
  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reccloneinlineproceed);
  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reccloneinlinecancel);

  let rowData = $(uiActionObj.whatRow).data(CONST_DATA_NAME_ROW_DATA);

  let $newRow = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.TBODY_EXISTING, ROW_TYPE.CLONED_ROW, uiActionObj.dataObj.opts, '<td></td>', '', rowCtrls, rowData);
  $newRow.append($clonedCells);
  $(uiActionObj.whatRow).after($newRow);

  uiActionObj.clonedRow = $newRow;
  _fnCtrlOpInlineUnlockEditableFields(uiActionObj, uiActionObj.clonedRow);

  /* handle any passed in functions */

  $.each($clonedCells, function (idx, obj) {
  	let clonedFieldName = $(obj).attr(CONST_ATTR_NAME_FIELD_NAME);
  	let $newCellValue = $(obj).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '=' + clonedFieldName + ']'
  		+ ', select[' + CONST_ATTR_NAME_FIELD_NAME + '=' + clonedFieldName + ']'
  		+ ', textarea[' + CONST_ATTR_NAME_FIELD_NAME + '=' + clonedFieldName + ']');


  	let clonedFieldDefinition = uiActionObj.dataObj.opts.fieldDefinitions.find(elem => elem.name == clonedFieldName);
  	let clonedFieldValue = $newCellValue.val();

  	// autocomplete is handled differently
  	if (clonedFieldDefinition.dataType === 'autocomplete') {
  		$newCellValue = $(obj).find('fieldset' + SELECTOR_AUTO_COMPLETE_FIELDSET);
  	}

  	if (!clonedFieldDefinition.additionalCellValueFieldDefinitions) clonedFieldDefinition.additionalCellValueFieldDefinitions = [];
  	let addCellValRefs = [];
  	let addCellValRefsMap = new Map();

  	$.each(clonedFieldDefinition.additionalCellValueFieldDefinitions, function (fdIdx, addFldDef) {
  		let $addCellValue = $(obj).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '=' + addFldDef.name + ']');
  		addCellValRefs.push($addCellValue);
  		addCellValRefsMap.set(addFldDef.name, $addCellValue);
  	});

  	let rowIdxCtr = $(obj).attr(CONST_ATTR_NAME_ROW_IDX);
  	let colIdxCtr = $(obj).attr(CONST_ATTR_NAME_COL_IDX);

	// increment row index by 1 as this is a clone of the original placed right below the original
    if (rowIdxCtr) {
		let parsedRowIdxCtr = parseInt(rowIdxCtr);
		rowIdxCtr = (isNaN(parsedRowIdxCtr)) ? '' : ++parsedRowIdxCtr;
    }
  	obj = uiActionObj.dataObj.opts.fnCreateNewCellAfter(obj, SUB_SECTIONS.TBODY_NEW, ROW_TYPE.CLONED_ROW, uiActionObj.dataObj, rowIdxCtr, colIdxCtr, clonedFieldDefinition, clonedFieldValue, $newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);
  });


  // handle autocomplete
  $.each($originalCells, function (idx, obj) {
	let $autocompleteField = $(obj).find('fieldset' + SELECTOR_AUTO_COMPLETE_FIELDSET);
  	if ($autocompleteField.length > 0) {

			// get cloned autocomplete field
			let $clonedInput = $($clonedCells[idx]).find('fieldset' + SELECTOR_AUTO_COMPLETE_FIELDSET)
				.find('input[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="autocomplete"]');

			// change the id so we don't have 2 elements with the same id
			//$clonedInput.attr('id', $clonedInput.attr('id') + );

			let autocompleteFieldName = $($clonedInput).attr('data-mba-rest-view-field-name');
			let autocompleteFieldDefinition = uiActionObj.dataObj.opts.fieldDefinitions.find(x => x.name == autocompleteFieldName);

			let autocompleteOpts = {

				select: function (event, ui) {
					$($clonedInput).attr(CONST_ATTR_NAME_ALT_VALUE, ui.item.id); /* Note: Different than init for entityID*/
					/* Hook for selection */
					autocompleteFieldDefinition.dataTypeOptions.fnOnSelect(event, ui);
				}
				, source: function (acReqCb, acRspCb) {

					/* Get collection of all current savable field name/values for given row reference */
					let _saveableFields = _fnGetSaveableFields(uiActionObj.clonedRow);
					let _nvpsIn = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields(_saveableFields);

					/* Add the search term from the autocomplete plugin to this collection */
					_nvpsIn.push(_fnCreateNameValueObj('term', acReqCb.term));

					/* Hook for modifying name value collection being sent to server */

					let _nvpsOut = autocompleteFieldDefinition.dataTypeOptions.fnModifyRequestNvps(_nvpsIn);

					/* Create request data JSON string */

					let _reqDataObj = _fnCtrlOpInlineRequestDataObjFromNvpObjs(_nvpsOut);
					let _reqDataStr = JSON.stringify(_reqDataObj);
					/* Use our local method */
					_fnAjaxCallAsmxWebMethod(uiActionObj.dataObj.me, autocompleteFieldDefinition.dataTypeOptions.baseUrl, _reqDataStr)
						.then(responseData => {
							/* Hook for modifying response */
							let SelRecs = autocompleteFieldDefinition.dataTypeOptions.fnModifyResponseSelRecs(_nvpsOut, responseData.rawData.SelRecs);
							if (!SelRecs) {
								acRspCb([]);
								return;
							}
							acRspCb(SelRecs);
						})
						.catch(responseData => {
							acRspCb({});
						});
				}
			};

			$($clonedInput).autocomplete('destroy').autocomplete(autocompleteOpts)._renderItem = function ($ul, item) {
				/* Override how jQuery autocomplete plugin renders its selections */
				let $li = $('<li></li>');
				$($li).addClass(CSS_CLASSES.autoCompleteListItem);
				let $liContent = $('<a></a>');
				$($liContent).addClass(CSS_CLASSES.autoCompleteListContent);
				$($liContent).append(item.label);
				$li.append($liContent);
				$li.data('item.autocomplete', item);
				/* Hook to modify rendered selection item */
				let $fli = autocompleteFieldDefinition.dataTypeOptions.fnModifyRenderItem($ul, item, $li);

				/* Get reference to ul generated by autocomplete plugin and add the rest-view classes and attributes
				* User can override style added by jQuery UI for all instances of a widget for a given field name */
				$ul.attr(CONST_ATTR_NAME_PLUGIN_MKUP_FOR_FIELD_NAME, autocompleteFieldDefinition.name);
				$ul.addClass(CSS_CLASSES.autoCompleteList);
				return $fli.appendTo($ul);
			};

			// force autocomplete when dropdown icon is clicked
			let $clonedInputDropdownIcon = $($clonedInput).parents('fieldset' + SELECTOR_AUTO_COMPLETE_FIELDSET).find(SELECTOR_AUTO_COMPLETE_DROPDOWN_ICON);
			$clonedInputDropdownIcon.on("click", function (e) { _fnForceAutoCompleteSearch($clonedInput); });
  	}
  });

  return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCloneInlineCancel
 * @private
 * @summary      Cancel clone in progress
 * @description  Cancel clone in progress
 */

let _fnCloneInlineCancel = function (uiActionObj) {
	let $wRow = $(uiActionObj.whatRow);
	$($wRow).remove();
	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCloneInlineProceed
 * @private
 * @summary      Saves new clone
 * @description  Saves new clone
 */

let _fnCloneInlineProceed = function (uiActionObj) {

	let $fields = _fnCtrlOpInlineGetSaveableFields(uiActionObj);
	let nvpObjs = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields($fields);
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.recIDNameForClone, ""));
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.saveTypeNameForClone, uiActionObj.dataObj.opts.saveTypeValueForClone));

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForClone.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	let url     = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlClone, uiActionObj.dataObj.opts.baseUrlCloneHasParameters, null);
	let $wRow = $(uiActionObj.whatRow);

	/* Send clone request */

	let dataToPost = JSON.stringify(_fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs));
	let _me = uiActionObj.dataObj.me;
	_fnAjaxCallAsmxWebMethod(uiActionObj.elem, url, dataToPost)
		.then(responseData => {
			$(uiActionObj.notificationsCol).html('');
			$($wRow).remove();
			_fnRefreshCurrentViewFromServer(_me);
		})
		.catch(responseData => {
			$(uiActionObj.notificationsCol).html('');
			let $msgs = _fnRenderRowNotificationMessages(responseData.details);
			$(uiActionObj.notificationsCol).html($msgs);
		});

	return uiActionObj;
}

/*################################################################################################
  #
  #                                  Edit (Inline) Routines
  #
  #################################################################################################*/

/**
 * @function     _fnEditInlineGetButtonRefs
 * @private
 * @summary      Gets references to button controls
 * @description  Gets references to button controls
 */

let _fnEditInlineGetButtonRefs = function (uiActionObj) {
   let butRefsObj = {}

   butRefsObj.start = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="receditinlinestart"]')[0];
   butRefsObj.proceed = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="receditinlineproceed"]')[0];
   butRefsObj.cancel = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="receditinlinecancel"]')[0];
   butRefsObj.clone  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.CLONE_START + '"]');
   butRefsObj.delete = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.DELETE_START + '"]');
   butRefsObj.undelete = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.UNDELETE_START + '"]');

   butRefsObj.manageFilesForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MANAGE_FILES_FOR_ROW + '"]');
   butRefsObj.showAdditionalInfoForRow = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SHOW_ADDITIONAL_INFO_FOR_ROW + '"]');
   butRefsObj.sendMessageForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SEND_MESSAGE_FOR_ROW + '"]');
   butRefsObj.markRow                  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MARK_ROW + '"]');

   butRefsObj.userDefined = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_TYPE + '="' + CONST_ATTR_VALUE_USER_PROVIDED + '"]');

   return butRefsObj;
}

/**
	* @function     _fnCtrlOpInlineAreEditableFieldsInState
	* @private
	* @summary      Returns a true or false if the editable fields in whatRow are in whatState
	* @description   Returns a true or false if the editable fields in whatRow are in whatState
	*/

let _fnCtrlOpInlineAreEditableFieldsInState = function (uiActionObj, whatRow, whatState) {

	let $editableFields = _fnCtrlOpInlineGetEditableFields(uiActionObj, whatRow);
	let whatStateCount = 0;

	$.each($editableFields, function (idx, $editableField) {
		if ($($editableField).attr(CONST_ATTR_NAME_FIELD_EDIT_STATE) == whatState) whatStateCount++;
	});
	if (whatStateCount > 0) return true;
	return false;
}

/**
	* @function     _fnCtrlOpInlineAreEditableFieldsLocked
	* @private
	* @summary      Returns a true or false if the editable fields in whatRow are currently locked
	* @description    Returns a true or false if the editable fields in whatRow are currently locked
	*/
let _fnCtrlOpInlineAreEditableFieldsLocked = function (uiActionObj, whatRow) {
	return _fnCtrlOpInlineAreEditableFieldsInState(uiActionObj, whatRow, CONST_ATTR_VALUE_EDIT_STATE_LOCKED);
};

/**
	* @function     _fnCtrlOpInlineAreEditableFieldsUnLocked
	* @private
	* @summary      Returns a true or false if the editable fields in whatRow are currently unlocked
	* @description    Returns a true or false if the editable fields in whatRow are currently unlocked
	*/

let _fnCtrlOpInlineAreEditableFieldsUnlocked = function (uiActionObj, whatRow) {
	return _fnCtrlOpInlineAreEditableFieldsInState(uiActionObj, whatRow, CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED);
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEditInlineGetNameValuePairsWithReferenceFromEditableFields
 * @private
 * @summary      Gets array of name value pair objects from editable fields with an additional reference field
 * @description  Gets array of name value pair objects from editable fields with an additional reference field
 */

let _fnEditInlineGetNameValuePairsWithReferenceFromEditableFields = function ($editableFields) {
  let nvps = [];
  $.each($editableFields, function (fi, $field) {
	let fn  = $($field).attr(CONST_ATTR_NAME_SAVE_USING);
	let fv  = $($field).val();
	let afv = $($field).attr(CONST_ATTR_NAME_ALT_VALUE);
	let hasAfv = _fnHasValue(afv);
	let nvpWithRef    = _fnCreateNameValueObj(fn, fv);
	nvpWithRef.hasAfv = hasAfv;
	nvpWithRef.afv    = afv;
	nvpWithRef.fieldReference = $field;
	nvps.push(nvpWithRef);
  });
  return nvps;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEditInlineStart
 * @private
 * @summary      Starts edit
 * @description  Starts edit
 */

let _fnEditInlineStart = function (uiActionObj) {

	/* Determine if OK to edit */

	if (uiActionObj.dataObj.opts.fnOKToEdit(uiActionObj) === false) {
		return uiActionObj;
	}

	/* Flag row as being in edit or delete state */
	$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_TRUE);

	/* Fetch reference to editable fields and capture their CURRENT name/values and alt field vals */

	let $editableFields                 = _fnCtrlOpInlineGetEditableFields(uiActionObj);
	let editableFieldNameValuesWithRefs = _fnEditInlineGetNameValuePairsWithReferenceFromEditableFields($editableFields);

	/* Pass them along with uiActionObj in case they are needed */

	uiActionObj.whatRowEditableFieldNameValuesWithRefs = editableFieldNameValuesWithRefs

    /* And save them in the row data in case we need to restore them because the user cancelled */

	let rowDataObj = {};
	rowDataObj.editableFieldNameValuesWithRefs = editableFieldNameValuesWithRefs;
	$(uiActionObj.whatRow).data(CONST_DATA_NAME_ROW_DATA, rowDataObj);

    /* Get row control buttons */

	let butRefsObj = _fnEditInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.delete).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.undelete).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).addClass(CSS_CLASSES.hidden);

    /* Unlock editable fields */

	_fnCtrlOpInlineUnlockEditableFields(uiActionObj);

	/* Call hook */

	uiActionObj.dataObj.opts.fnOnEditInlineStart(uiActionObj, butRefsObj);

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEditInlineCancel
 * @private
 * @summary      Cancel edit in progress
 * @description  Cancel edit in progress
 */

let _fnEditInlineCancel = function (uiActionObj) {

	/* Retrieve row data */

	let rowDataObj = $(uiActionObj.whatRow).data(CONST_DATA_NAME_ROW_DATA);

    /* Restore previous values */

	$.each(rowDataObj.editableFieldNameValuesWithRefs, function (idx, editableFieldNameValueWithRef) {
		let fldRef  = editableFieldNameValueWithRef.fieldReference;
		let prevVal = editableFieldNameValueWithRef.value;
		$(fldRef).val(prevVal);
		/* If the field has an alt value restore it a well */
		if (editableFieldNameValueWithRef.hasAfv === true) {
		  let afv = editableFieldNameValueWithRef.afv;
		  $(fldRef).attr(CONST_ATTR_NAME_ALT_VALUE, afv);
		}
		/* Trigger an edit cancel event on this editable field */
		$(fldRef).trigger(CONST_EVENT_NAME_EDIT_CANCEL);
	});

    /* Clear row notifications */

	$(uiActionObj.notificationsCol).html('');

    /* Get row control buttons */

	let butRefsObj = _fnEditInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.delete).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.undelete).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);

    /* Lock editable fields */

	_fnCtrlOpInlineLockEditableFields(uiActionObj);

	/* Remove row flag as being in edit or delete state */
	$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_FALSE);

	/* Call hook */
	uiActionObj.dataObj.opts.fnOnEditInlineCancel(uiActionObj);

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEditInlineProceed
 * @private
 * @summary      Saves edit
 * @description  Saves edit
 */

let _fnEditInlineProceed = function (uiActionObj) {

	let butRefsObj = _fnEditInlineGetButtonRefs(uiActionObj);
	let $fields    = _fnCtrlOpInlineGetSaveableFields(uiActionObj);
	let nvpObjs    = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields($fields);
	let url        = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlEdit, uiActionObj.dataObj.opts.baseUrlEditHasParameters, null);
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.recIDNameForEdit, uiActionObj.recordID));
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.saveTypeNameForEdit, uiActionObj.dataObj.opts.saveTypeValueForEdit));

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForEdit.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	/* Send edit request */

	let dataToPost = JSON.stringify(_fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs));

	_fnAjaxCallAsmxWebMethod(uiActionObj.elem, url, dataToPost)
		.then(responseData => {

		    /* Trigger edit proceed event on each editable field */

			let rowDataObj = $(uiActionObj.whatRow).data(CONST_DATA_NAME_ROW_DATA);
			$.each(rowDataObj.editableFieldNameValuesWithRefs, function (idx, editableFieldNameValueWithRef) {
			  $(editableFieldNameValueWithRef.fieldReference).trigger(CONST_EVENT_NAME_EDIT_PROCEED);
			});

			$(uiActionObj.notificationsCol).html('');
			$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.delete).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.undelete).removeClass(CSS_CLASSES.hidden);

			$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);

			$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);
			_fnCtrlOpInlineLockEditableFields(uiActionObj);

			/* Remove row flag as being in edit or delete state */

			$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_FALSE);

			if (uiActionObj.dataObj.opts.refreshViewAfterInlineEditProceed === true) _fnRefreshCurrentViewFromServer(uiActionObj.elem);

			/* Call hook */

			uiActionObj.dataObj.opts.fnEditInlineProceedAfter(uiActionObj, responseData, true);
		})
		.catch(responseData => {
			$(uiActionObj.notificationsCol).html('');
			let $msgs = _fnRenderRowNotificationMessages(responseData.details);
			$(uiActionObj.notificationsCol).html($msgs);
			/* Call hook */
			uiActionObj.dataObj.opts.fnEditInlineProceedAfter(uiActionObj, responseData, false);
		});

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*################################################################################################
  #
  #                                  Delete (Inline) Routines
  #
  #################################################################################################*/

/**
 * @function     _fnDeleteInlineGetButtonRefs
 * @private
 * @summary      Gets references to button controls
 * @description  Gets references to button controls
 */

let _fnDeleteInlineGetButtonRefs = function (uiActionObj) {

  let butRefsObj = {}

   /* This operations related controls */

   butRefsObj.start   = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recdeleteinlinestart"]')[0];
   butRefsObj.proceed = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recdeleteinlineproceed"]')[0];
   butRefsObj.cancel  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recdeleteinlinecancel"]')[0];

   /* Other ops (just the starts for the other rec ops)*/

   butRefsObj.clone    = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.CLONE_START + '"]');
   butRefsObj.edit     = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.EDIT_START + '"]');
   butRefsObj.undelete = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.UNDELETE_START + '"]');

   butRefsObj.manageFilesForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MANAGE_FILES_FOR_ROW + '"]');
   butRefsObj.showAdditionalInfoForRow = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SHOW_ADDITIONAL_INFO_FOR_ROW + '"]');
   butRefsObj.sendMessageForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SEND_MESSAGE_FOR_ROW + '"]');
   butRefsObj.markRow                  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MARK_ROW + '"]');

   /* All user defined */

   butRefsObj.userDefined = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_TYPE + '="' + CONST_ATTR_VALUE_USER_PROVIDED + '"]');

   return butRefsObj;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDeleteInlineStart
 * @private
 * @summary      Starts edit
 * @description  Starts edit
 */

let _fnDeleteInlineStart = function (uiActionObj) {

	/* Flag row as being in edit or delete state */

	$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_TRUE);

	/* Get row control buttons */

	let butRefsObj = _fnDeleteInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.edit).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.undelete).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).addClass(CSS_CLASSES.hidden);
	let $msg = _fnRenderRowNotificationMessageStandAlone('Are you sure?');
	$(uiActionObj.notificationsCol).append($msg);
	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDeleteInlineCancel
 * @private
 * @summary      Cancel delete in progress
 * @description  Cancel delete in progress
 */

let _fnDeleteInlineCancel = function (uiActionObj) {

	let butRefsObj = _fnDeleteInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.edit).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.undelete).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);
	$(uiActionObj.notificationsCol).html('');

	/* Remove row flag as being in edit or delete state */

	$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_FALSE);

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDeleteInlineProceed
 * @private
 * @summary      Saves edit
 * @description  Saves edit
 */

let _fnDeleteInlineProceed = function (uiActionObj) {

	let butRefsObj = _fnDeleteInlineGetButtonRefs(uiActionObj);

	let url = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlDelete, uiActionObj.dataObj.opts.baseUrlDeleteHasParameters, null);

	let nvpObjs = [];
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.recIDNameForDelete,    uiActionObj.recordID));
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.saveTypeNameForDelete, uiActionObj.dataObj.opts.saveTypeValueForDelete));

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForDelete.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	/* Send delete request */

	let dataToPost = JSON.stringify(_fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs));

	_fnAjaxCallAsmxWebMethod(uiActionObj.elem, url, dataToPost)
		.then(responseData => {
			$(uiActionObj.notificationsCol).html('');
			$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.edit).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.undelete).removeClass(CSS_CLASSES.hidden);

			$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);

			$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);

			/* Remove row flag as being in edit or delete state */

			$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_ROW_IN_EDIT_OR_DELETE_STATE, CONST_ATTR_VALUE_MARKED_FALSE);

			_fnRefreshCurrentViewFromServer(uiActionObj.elem);
		})
		.catch(responseData => {
			$(uiActionObj.notificationsCol).html('');
			let $msgs = _fnRenderRowNotificationMessages(responseData.details);
			$(uiActionObj.notificationsCol).html($msgs);
		});

	return uiActionObj;

}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*################################################################################################
  #
  #                                  UnDelete (Inline) Routines
  #
  #################################################################################################*/

/**
 * @function     _fnUnDeleteInlineGetButtonRefs
 * @private
 * @summary      Gets references to button controls
 * @description  Gets references to button controls
 */

let _fnUnDeleteInlineGetButtonRefs = function (uiActionObj) {

  let butRefsObj = {}

   /* This operations related controls */

   butRefsObj.start   = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recundeleteinlinestart"]')[0];
   butRefsObj.proceed = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recundeleteinlineproceed"]')[0];
   butRefsObj.cancel  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_NAME + '="recundeleteinlinecancel"]')[0];

   /* Other ops (just the starts for the other rec ops)*/

   butRefsObj.clone    = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.CLONE_START + '"]');
   butRefsObj.edit     = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.EDIT_START + '"]');
   butRefsObj.delete   = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.DELETE_START + '"]');

   butRefsObj.manageFilesForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MANAGE_FILES_FOR_ROW + '"]');
   butRefsObj.showAdditionalInfoForRow = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SHOW_ADDITIONAL_INFO_FOR_ROW + '"]');
   butRefsObj.sendMessageForRow        = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.SEND_MESSAGE_FOR_ROW + '"]');
   butRefsObj.markRow                  = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '="' + CTRL_OP_CLASSES.MARK_ROW + '"]');

   /* All user defined */

   butRefsObj.userDefined = $(uiActionObj.whatCellOrCol).children('button[' + CONST_ATTR_NAME_CTRL_DEF_TYPE + '="' + CONST_ATTR_VALUE_USER_PROVIDED + '"]');

   return butRefsObj;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnDeleteInlineStart
 * @private
 * @summary      Starts undelete
 * @description  Starts undelete
 */

let _fnUnDeleteInlineStart = function (uiActionObj) {

    /* Get row control buttons */

	let butRefsObj = _fnUnDeleteInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.edit).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.delete).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).addClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).addClass(CSS_CLASSES.hidden);


	let $msg = _fnRenderRowNotificationMessageStandAlone('Are you sure?');
	$(uiActionObj.notificationsCol).append($msg);
	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnDeleteInlineCancel
 * @private
 * @summary      Cancel undelete in progress
 * @description  Cancel undelete in progress
 */

let _fnUnDeleteInlineCancel = function (uiActionObj) {

	let butRefsObj = _fnUnDeleteInlineGetButtonRefs(uiActionObj);

    /* Set appropriate states for the buttons */

	$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
	$(butRefsObj.edit).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.delete).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
	$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);

	$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);
	$(uiActionObj.notificationsCol).html('');

	return uiActionObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnDeleteInlineProceed
 * @private
 * @summary      Saves edit
 * @description  Saves edit
 */

let _fnUnDeleteInlineProceed = function (uiActionObj) {

	let butRefsObj = _fnUnDeleteInlineGetButtonRefs(uiActionObj);

	let url = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlUnDelete, uiActionObj.dataObj.opts.baseUrlUnDeleteHasParameters, null);

	let nvpObjs = [];
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.recIDNameForUnDelete,    uiActionObj.recordID));
	nvpObjs.push(_fnCreateNameValueObj(uiActionObj.dataObj.opts.saveTypeNameForUnDelete, uiActionObj.dataObj.opts.saveTypeValueForUnDelete));

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForUnDelete.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	/* Send delete request */

	let dataToPost = JSON.stringify(_fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs));

	_fnAjaxCallAsmxWebMethod(uiActionObj.elem, url, dataToPost)
		.then(responseData => {
			$(uiActionObj.notificationsCol).html('');
			$(butRefsObj.start).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.cancel).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.proceed).addClass(CSS_CLASSES.hidden);
			$(butRefsObj.edit).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.clone).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.delete).removeClass(CSS_CLASSES.hidden);

			$(butRefsObj.manageFilesForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.showAdditionalInfoForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.sendMessageForRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.markRow).removeClass(CSS_CLASSES.hidden);
			$(butRefsObj.userDefined).removeClass(CSS_CLASSES.hidden);
			_fnRefreshCurrentViewFromServer(uiActionObj.elem);
		})
		.catch(responseData => {
			$(uiActionObj.notificationsCol).html('');
			let $msgs = _fnRenderRowNotificationMessages(responseData.details);
			$(uiActionObj.notificationsCol).html($msgs);
		});

	return uiActionObj;

}

/*################################################################################################
  #
  #                      Add New (InWindow) and Edit (InWindow) Routines
  #
  #################################################################################################*/

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function      _fnAddNewInWindow
 * @private
 * @summary      Saves new
 * @description  Saves new
 */

let _fnAddNewInWindow = function (uiActionObj) {

	let nvpObjs = [];
	uiActionObj.dataObj.opts.additionalParameterDefinitionsForAddNew.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	let url = _fnBuildUrl(uiActionObj.dataObj.opts.baseUrlAddNew
		                  , uiActionObj.dataObj.opts.baseUrlAddNewHasParameters
		                  , nvpObjs);

	let newWindowName = 'new-' + _createNewUUID();
	let newWindow = _fnOpenWindow(uiActionObj.elem, url,newWindowName,true);
	uiActionObj.newWindow = newWindow;

	return uiActionObj;
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function      _fnEditInWindow
 * @private
 * @summary      Saves new
 * @description  Saves new
 */

let _fnEditInWindow = function (uiActionObj) {

	let nvpObjs = [];

	uiActionObj.dataObj.opts.additionalParameterDefinitionsForEdit.forEach(function (value, key) {
		nvpObjs.push(_fnCreateNameValueObj(key, value));
	});

	let url = _fnBuildUrl(  uiActionObj.dataObj.opts.baseUrlEdit
	    	              , uiActionObj.dataObj.opts.baseUrlEditHasParameters
		                  , nvpObjs);

	let rid = uiActionObj.recordID;
	url = url + rid;
	let newWindowName = 'edit-' + rid;
	let newWindow = _fnOpenWindow(uiActionObj.elem, url, newWindowName,true);
	uiActionObj.newWindow = newWindow;
	return uiActionObj;
}

/*################################################################################################
  #
  #                                    View (REST) Routines
  #
  #################################################################################################*/

/**
 * @function    _fnBeforeRequestViewFromServer
 * @private
 * @summary      Optional hook for doing something prior to requesting data
 * @description  Optional hook for doing something prior to requesting data

 * @param  {object}  elem           The element
 * @param  {object}  pageNumber     Page requested

 */

let _fnBeforeRequestViewFromServer = function (elem, pageNumber) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnLoadDataObj($me);
	dataObj.opts.fnBeforeRequestViewFromServer(elem, pageNumber, $me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOnResponseViewFromServer
 * @private
 * @summary      Optional hook for capturing response data
 * @description  Optional hook for capturing response data
 * @param  {object}  elem           The element
 * @param  {object}  responseData   Data returned from server
 */

let _fnOnResponseViewFromServer = function (elem, responseData) {
    let $me     = _fnGetMe(elem);
	let dataObj = _fnLoadDataObj($me);
	dataObj.opts.fnOnResponseViewFromServer(elem, responseData, $me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnProcessResponseViewFromServer
 * @private
 * @summary      Process returned data
 * @description  Process returned data
 * @param  {object}  dataObj      Data object stored with $me
 * @param  {object}  returnData   Data returned from server
 */

let _fnProcessResponseViewFromServer = function (elem, returnData) {

  let $me = _fnGetMe(elem);
  let dataObj = _fnLoadDataObj($me);

  dataObj.recordsPaged       = returnData.recordsPaged;
  dataObj.hasRecords         = returnData.hasRecords;
  dataObj.recordsTotal       = returnData.recordsTotal;
  dataObj.pagesTotal         = returnData.pageCount;
  dataObj.pageSize           = returnData.pageSize;
  dataObj.currentPageNumber  = returnData.pageNumber;
  dataObj.currentPageCount   = returnData.pageCount;

  if (dataObj.hasRecords === true) {
	dataObj.currentPageRowOrder = returnData.pageOrder;
	/* If the records are not paged then treat this as one page that is the size of the records returned */
	if (dataObj.recordsPaged === false) {
		dataObj.pageSize          = dataObj.recordsTotal;
		dataObj.pagesTotal        = 1;
		dataObj.currentPageNumber = 1;
		dataObj.currentPageCount  = 1;
    }
  }
  else {
	/* In cases where no records exist but some may need to be added we need to make sure the page count is a 1 */
	dataObj.currentPageNumber = 1
	dataObj.currentPageCount  = 1
  }

  dataObj.currentPageRecCount    = returnData.recordsReturned;
  dataObj.currentPageRecNumStart = (((dataObj.currentPageNumber - 1) * dataObj.pageSize) + 1);
  dataObj.currentPageRecNumEnd   = ((dataObj.currentPageRecNumStart + dataObj.currentPageRecCount) - 1);

  dataObj = _fnSaveDataObj($me, dataObj);

  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestViewFromServer
 * @private
 * @summary      Get data from server
 * @description  Get data from server
 * @param  {Object}  elem        Element reference
 * @param  {Object}  pageNumber  Page number to retrieve
 */

let _fnRequestViewFromServer = function (elem, pageNumber) {

	_fnBeforeRequestViewFromServer(elem,pageNumber);

	_fnShowMessageOverlay(elem);
	_fnUpdateMessageOverlayContent(elem, 'Requesting data');
	_fnUpdateStatusContent(elem, 'Requesting data');

    /* Make our rest view call */

	_fnAjaxCallRestView(elem, pageNumber)
		.then(responseData => {
		 /* Optional hook to capture response data. */
		 _fnOnResponseViewFromServer(elem, responseData);
		 /* Get our row counts, etc.*/
		 _fnProcessResponseViewFromServer(elem, responseData);		 
	     /* Draw paging controls*/
		 _fnDrawPagingControls(elem, responseData);
		 /* Draw table body (this also hides and clears the overlay*/
		 _fnDrawTableBodyRows(elem, responseData);
		})
		.catch(responseData => {
		  /* Optional hook to capture response data */
		  _fnOnResponseViewFromServer(elem, responseData);
		  if (responseData.message == 'abort') return;
		  _fnUpdateMessageOverlayContent(elem, responseData.message);
		  _fnUpdateStatusContent(elem, responseData.message);
		  _fnHideMessageOverlay(elem, 1500);
		  _fnClearMessageOverlay(elem);
		});


}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRefreshCurrentViewFromServer
 * @private
 * @summary      Get data from server
 * @description  Get data from server
 * @param  {Object}  elem        Element reference
 */

let _fnRefreshCurrentViewFromServer = function (elem) {

  let $me = _fnGetMe(elem);
  let dataObj = _fnLoadDataObj($me);
  let pageNumber = dataObj.currentPageNumber;
  return _fnRequestViewFromServer(elem, pageNumber);
}

/*################################################################################################
  #
  #                                        Sort Handlers
  #
  #################################################################################################*/

/**
 * @function     _fnChangePageRowOrder
 * @private
 * @summary      Changes row order for paging
 * @description
 * @param  {Object}  elem
 */

let _fnChangePageRowOrder = function (elem, newPageRowOrder) {
  let $me = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($me);
  dataObj.currentPageRowOrder = newPageRowOrder;
  _fnSaveDataObj($me, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnChangePageRowOrderFromSortUIAction
 * @private
 * @summary      Changes row order for paging
 * @description
 * @param  {Object}  uiActionObj
 */

let _fnChangePageRowOrderFromSortUIAction = function (uiActionObj) {
	uiActionObj.sortUsing = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_SORT_USING);
	uiActionObj.sortDir   = $(uiActionObj.whatElement).attr(CONST_ATTR_NAME_SORT_DIR);
	uiActionObj.newPageRowOrder = '' + uiActionObj.sortUsing + ' ' + uiActionObj.sortDir;
	_fnChangePageRowOrder(uiActionObj.elem, uiActionObj.newPageRowOrder);
	_fnRequestViewFromServer(uiActionObj.elem, 1);
	return uiActionObj;
}

/*################################################################################################
  #
  #                                  Construction and Teardown
  #
  #################################################################################################*/

/**
 * @function     _fnDestroy
 * @private
 * @summary      Destroy existing instance
 * @description  Destroy existing instance
 * @param  {Object}  elem  Element reference
 */

let _fnDestroy = function (elem) {
  let $me = _fnGetMe(elem);
  let _dataObj = _fnGetDataObj($me);
  $me.removeData(CONST_DATA_NAME);
  $me.html('');
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreate
 * @private
 * @summary      Create new instance
 * @description  Create new instance
 * @param  {Object}  elem    Element reference
 * @param  {Object}  optsIn  Element reference
 */

let _fnCreate = function (elem,optsIn) {

  let $me = _fnGetMe(elem);

  /* See if we have created an instance of this plugin already for this element.  If so get out. */
  if (_fnLoadDataObj($me)) return;

  /* Give element an id if it does not have one */

  let meID = $me.attr('id');

  if (!meID) {
	meID = _createNewUUID();
	$me.attr('id', meID);
  }

  /* Define the data object we will save later */

  let dataObj = {};

  /* Mark element as container for control and store reference to elem */

  dataObj.meID = meID;
  dataObj.me = $me;

  $me.addClass(CSS_CLASSES.me).addClass(CSS_CLASSES.container);

  /* Merge default options and options passed in and store reference to options. */

  let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
  dataObj.opts = opts;

  /* Setup map if not already for additional method parameters */

  if (!dataObj.opts.additionalControlDefinitionsForHeadRows)   dataObj.opts.additionalControlDefinitionsForHeadRows   = new Map();
  if (!dataObj.opts.additionalControlDefinitionsForBodyRows)   dataObj.opts.additionalControlDefinitionsForBodyRows   = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForView)     dataObj.opts.additionalParameterDefinitionsForView     = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForAddNew)   dataObj.opts.additionalParameterDefinitionsForAddNew   = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForEdit)     dataObj.opts.additionalParameterDefinitionsForEdit     = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForDelete)   dataObj.opts.additionalParameterDefinitionsForDelete   = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForUnDelete) dataObj.opts.additionalParameterDefinitionsForUnDelete = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForClone)    dataObj.opts.additionalParameterDefinitionsForClone    = new Map();
  if (!dataObj.opts.additionalParameterDefinitionsForReport)   dataObj.opts.additionalParameterDefinitionsForReport   = new Map();

  /* Setup assoc array for col title replacements */

  if (dataObj.opts.hasColTitleReplacements === true) {
     dataObj.opts.colTitleReplacements = {};
  }

  /* Setup array for registering additonal info field defs*/

  if (!dataObj.opts.additionalInfoFieldDefinitions) {
	 dataObj.opts.additionalInfoFieldDefinitions = [];
  };

  /* Setup array for registering and then searching additional field defs*/

  if (!dataObj.opts.additionalCellValueFieldDefinitions) dataObj.opts.additionalCellValueFieldDefinitions = [];

  $.each(dataObj.opts.fieldDefinitions, function (fdIdx, fldDef) {

	  if (fldDef.additionalCellValueFieldDefinitions) {
		  dataObj.opts.additionalCellValueFieldDefinitions.push(...fldDef.additionalCellValueFieldDefinitions);
	  }

	  if (dataObj.opts.hasColTitleReplacements === true) {
		  if (fldDef.hasColTitleReplacement === true) {
			//dataObj.opts.fieldDefinitions[fdIdx].visible = false;
		    dataObj.opts.colTitleReplacements[fldDef.name] = '_' + fldDef.name + '_col_label'; /* What rowData.fld has label in values */
          }
	  }
  });

  /* Page orders */

  dataObj.defaultPageRowOrder = opts.defaultPageRowOrder;
  dataObj.currentPageRowOrder = opts.defaultPageRowOrder;

  /* Create message overlay */

  let $messageOverlayContent = $('<div></div>');
  $messageOverlayContent.addClass(CSS_CLASSES.messageOverlayContent);

  let $messageOverlayContainer = $('<div></div>');
  $messageOverlayContainer.addClass(CSS_CLASSES.messageOverlayContainer);
  $messageOverlayContainer.addClass(CSS_CLASSES.hidden);
  $messageOverlayContainer.append($messageOverlayContent);

  dataObj.messageOverlayContainer = $messageOverlayContainer;
  dataObj.messageOverlayContent   = $messageOverlayContent;

  /* Create table container */

  let $tableContainer = $('<section></section>');
  $tableContainer.addClass(CSS_CLASSES.tableContainer);
  if (dataObj.opts.enableScrollView == true) {
    $tableContainer.addClass(CSS_CLASSES.scrollView);
	if (dataObj.opts.scrollViewUseCustomHeight == true) {
      $tableContainer.css('min-height', dataObj.opts.scrollViewCustomHeight);
	  $tableContainer.css('height',     dataObj.opts.scrollViewCustomHeight);
	  $tableContainer.css('max-height', dataObj.opts.scrollViewCustomHeight);
	}
  }

  /* Create table */

  let $table = $('<table></table>');
  $table.addClass(CSS_CLASSES.table);

  /* Create table header */

  let $thead = $('<thead></thead>');
  $thead.addClass(CSS_CLASSES.tableHeader);
  if (dataObj.opts.enableScrollView == true) {
    $thead.addClass(CSS_CLASSES.scrollView);
  }

  /* Row controls for header */

  let rowCtrls = [];

  /* User defined controls - If specified include before built in  */

  if (dataObj.opts.positionUserDefinedControlsInHead === POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN) {
     dataObj.opts.additionalControlDefinitionsForHeadRows.forEach(function (value, key) {
	    rowCtrls.push(value);
     });
  }

  /* Add new */

  if (opts.enableRowControlRecAddNew === true) {
		if (opts.saveModeAddNew === CONST_SAVE_MODE_INLINE) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewinlinestart);
		}
		else if (opts.saveModeAddNew === CONST_SAVE_MODE_INWINDOW) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewinwindow);
        }
		else if (opts.saveModeAddNew === CONST_SAVE_MODE_CUSTOM) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewcustom);
		}
		else {
			/* TODO: For expansion */
		}
  }

  /* Reports*/

  if (opts.enableReports === true) {
		if (opts.enableReportHtml === true) rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reportHTML);
		if (opts.enableReportXls === true) rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reportXLS);
		if (opts.enableReportPdf === true) rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reportPDF);
  }

  /* User defined controls - If specified include before after in  */

  if (dataObj.opts.positionUserDefinedControlsInHead === POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN) {
	dataObj.opts.additionalControlDefinitionsForHeadRows.forEach(function (value, key) {
		rowCtrls.push(value);
	});
  }

  /* Cols */

  let $columns = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.THEAD, ROW_TYPE.HEADER_ROW, opts, '<th></th>', '', rowCtrls, null);

  /* Add the field specific columns  */

  let colIdxCtr = 1;

  $.each(opts.fieldDefinitions, function (fieldDefIdx, fieldDefinition) {
	/* We do not render the following columns */
	if (fieldDefinition.isRecID           === true) return;
	if (fieldDefinition.isActiveFlag      === true) return;
    if (fieldDefinition.isCanEditFlag     === true) return;
    if (fieldDefinition.isCanDeleteFlag   === true) return;
	if (fieldDefinition.isCanUnDeleteFlag === true) return;
	let $col = _fnCreateNewCol(1, colIdxCtr, opts, fieldDefinition);
	$($columns).append($col);
	colIdxCtr++;
  });

  dataObj.columns = $columns;
  $thead.append($columns);

  /* Create table body for new or cloned records */

  let $tbodyNew = $('<tbody></tbody>');
  $tbodyNew.addClass(CSS_CLASSES.tableBody);

  /* Create table body for existing records */

  let $tbody = $('<tbody></tbody>');
  $tbody.addClass(CSS_CLASSES.tableBody);


  /* If requested create table caption */

  if (dataObj.opts.showCaption == true) {
	  let $tcaption = $('<caption></caption>');
	  $($tcaption).text(dataObj.opts.caption);
	  $($tcaption).addClass(CSS_CLASSES.tableCaption);
      if (dataObj.opts.enableScrollView == true) {
        $tcaption.addClass(CSS_CLASSES.scrollView);
      }
	  $($table).append($tcaption); /* Caption must be right after table tag */
	  dataObj.tcaption = $tcaption;
  }

  /* Build table and put it in its container */

  $($table).append($thead);
  $($table).append($tbodyNew);
  $($table).append($tbody);
  $($tableContainer).append($table);

  dataObj.table          = $table;
  dataObj.tableContainer = $tableContainer;
  dataObj.thead          = $thead;
  dataObj.tbodyNew       = $tbodyNew;
  dataObj.tbody          = $tbody;

  /* Current status */

  let $currentStatusContainer = $('<section></section>');
  $currentStatusContainer.addClass(CSS_CLASSES.controlSection);
  $currentStatusContainer.addClass(CSS_CLASSES.currentStatusContainer);
  let $dspCurrentStatus = $('<span></span>');
  $dspCurrentStatus.addClass(CSS_CLASSES.dspCurrentStatus);
  dataObj.dspCurrentStatus = $dspCurrentStatus;
  $($currentStatusContainer).append($dspCurrentStatus);
  dataObj.currentStatusContainer = $currentStatusContainer;

  /* Paging controls */

  let $pageCtrlsContainer = $('<section></section>');
  $pageCtrlsContainer.addClass(CSS_CLASSES.controlSection);
  $pageCtrlsContainer.addClass(CSS_CLASSES.pageControlsContainer);

  let $prevPageBut = $('<button type="button"><i class="fa fa-caret-left"></i></button>');
  $($prevPageBut).addClass(CSS_CLASSES.ctrlButtonPrevPage);
  $($prevPageBut).attr(CONST_ATTR_NAME_JUMP_TO_PAGE, "1");

  let $nextPageBut = $('<button type="button"><i class="fa fa-caret-right"></i></button>');
  $($nextPageBut).addClass(CSS_CLASSES.ctrlButtonNextPage);
  $($nextPageBut).attr(CONST_ATTR_NAME_JUMP_TO_PAGE, "1");

  let $ctrlPageNumber = $('<input min="1" max="" type="number" step="1"/>');
  $($ctrlPageNumber).addClass(CSS_CLASSES.ctrlInputPageNumber);
  $($ctrlPageNumber).val(1);

  dataObj.ctrlPrevPage   = $prevPageBut;
  dataObj.ctrlNextPage   = $nextPageBut;
  dataObj.ctrlPageNumber = $ctrlPageNumber;

  let $ctrPageCount = $('<span>?</span>');
  $($ctrPageCount).addClass(CSS_CLASSES.ctrlSpanPageCounter);
  dataObj.ctrPageCount = $ctrPageCount;

  let $pageJumpButtonsContainer = $('<span></span>');
  $($pageJumpButtonsContainer).addClass(CSS_CLASSES.ctrlJumpPageButtonsContainer);
  dataObj.pageJumpButtonsContainer = $pageJumpButtonsContainer;

  $pageCtrlsContainer.append('Page ');
  $pageCtrlsContainer.append($prevPageBut);
  $pageCtrlsContainer.append($ctrlPageNumber);
  $pageCtrlsContainer.append($nextPageBut);
  $pageCtrlsContainer.append(' of ');
  $pageCtrlsContainer.append($ctrPageCount);
  $pageCtrlsContainer.append($pageJumpButtonsContainer);

  dataObj.pageCtrlsContainer = $pageCtrlsContainer;

  /* Add the various sections to our original element*/

  $($me).append($messageOverlayContainer);
  $($me).append($tableContainer);
  $($me).append($currentStatusContainer);
  $($me).append($pageCtrlsContainer);

  /* Create map to track new windows that were opened from this control */

  dataObj.newWindows = new Map();

  /* Create map to track view requests that were opened from this control */

  dataObj.currentViewRequests = new Map();

  /* Save our data object.  This will be used for option calls */

  _fnSaveDataObj($me, dataObj);

  /* Wire up events */

	$($thead).on('click', 'tr > th ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.THEAD, 'th', CONST_BUILT_IN_CONTROL_TYPES); });
	$($tbodyNew).on('click change', 'tr > td ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.TBODY_NEW, 'td', CONST_BUILT_IN_CONTROL_TYPES); });
	$($tbody).on('click change', 'tr > td ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.TBODY_EXISTING, 'td', CONST_BUILT_IN_CONTROL_TYPES); });

  $($ctrlPageNumber).on('change', function (e) {
    let gotoPage = $(this).val();
	_fnRequestViewFromServer(elem, gotoPage);
  });

  $($pageCtrlsContainer).on('click', '*[' + CONST_ATTR_NAME_JUMP_TO_PAGE + ']', function (e) {
	  let gotoPage = $(this).attr(CONST_ATTR_NAME_JUMP_TO_PAGE);
	  _fnRequestViewFromServer(elem, gotoPage);
  });

  /* Calculate and assign min sizes for column head */

  /* Estimate number of controls */

  let minRowCtrlCount    = 0;
  let headerRowCtrlCount = 0;
  let bodyRowCtrlCount   = 0;
  let addOneExtraControl = false;

  headerRowCtrlCount = rowCtrls.length;

  if (opts.enableRowControlRecClone === true) {
	  bodyRowCtrlCount++;
	  addOneExtraControl = true;
   }

   if (opts.enableRowControlRecEdit === true) {
	   bodyRowCtrlCount++;
	   addOneExtraControl = true;
   }

   if (opts.enableRowControlRecDelete === true) {
	   bodyRowCtrlCount++;
	   addOneExtraControl = true;
   }

   if (opts.enableRowControlRecUnDelete === true) {
		bodyRowCtrlCount++;
		addOneExtraControl = true;
   }

   if (opts.enableRowControlManageFilesForRow === true) {
	   bodyRowCtrlCount++;
   }

   if (opts.enableRowControlShowAdditionalInfo === true) {
	   bodyRowCtrlCount++;
   }

   if (opts.enableRowControlSendMessageForRow === true) {
	   bodyRowCtrlCount++;
   }

   if (opts.enableRowNumbers === true) {
       bodyRowCtrlCount++;
   }

   bodyRowCtrlCount = bodyRowCtrlCount + opts.additionalControlDefinitionsForBodyRows.size;

   minRowCtrlCount = headerRowCtrlCount;

   if (bodyRowCtrlCount > headerRowCtrlCount) {
     minRowCtrlCount = bodyRowCtrlCount;
	   if (addOneExtraControl === true) {
	    if (headerRowCtrlCount < 2) minRowCtrlCount++;
	 }
   }


   let estCtrlsWidthInPx = (25 * minRowCtrlCount);
   let minRowCtrlColWidth = Math.ceil(estCtrlsWidthInPx);

   /* Init columns that have col title replacements */

   dataObj = _fnInitColsThatHaveColTitleReplacements(elem);

   /* Auto sizing visible columns */

   let $cols = $($thead).find('th.' + CSS_CLASS_VISIBLE_TD_TH);

   $.each($cols, function (colIdx, $col) {

	  /* Set style for header columns that are control containers */

	  if ($col.hasAttribute(CONST_ATTR_NAME_ROW_CONTROLS)) {
		  let styleAttrVal = 'min-width:' + minRowCtrlColWidth + 'px';
		  $($col).attr('style', styleAttrVal);
		  return;
	  }

	  /* Set style for header columns that are field containers */

	  if ($col.hasAttribute(CONST_ATTR_NAME_FIELD_NAME)) {
		 _fnSetHeaderColMinWidth($col);
		 return;
	  }
  });

  /* Auto hide page controls */

  if (opts.autoHidePageControls == true) {
	$($currentStatusContainer).addClass(CSS_CLASSES.hidden);
    $($pageCtrlsContainer).addClass(CSS_CLASSES.hidden);
  }

  /* After create hook */

  opts.fnOnAfterCreate(elem, dataObj, $cols);

  /* Get first page of data if allowed */

  if (opts.requestViewOnLoad === true) _fnRequestViewFromServer(elem, 1);

};

/*################################################################################################
  #
  #                                         Public Methods
  #
  ################################################################################################*/

return {
	CONST_SECTIONS: SECTIONS
  , CONST_SUB_SECTIONS: SUB_SECTIONS
  , CONST_ROW_TYPE: ROW_TYPE
  , CONST_RETURN_CODES: RETURN_CODES
  , CONST_CSS_CLASSES: CSS_CLASSES
  , EVENT_NAME_EDIT_CANCEL: CONST_EVENT_NAME_EDIT_CANCEL
  , EVENT_NAME_EDIT_PROCEED: CONST_EVENT_NAME_EDIT_PROCEED
  , ATTR_NAME_FIELD_EDIT_STATE: CONST_ATTR_NAME_FIELD_EDIT_STATE
  , ATTR_VALUE_EDIT_STATE_LOCKED: CONST_ATTR_VALUE_EDIT_STATE_LOCKED
  , ATTR_VALUE_EDIT_STATE_UNLOCKED: CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED
  , ATTR_NAME_ALT_VALUE: CONST_ATTR_NAME_ALT_VALUE
  , DATA_NAME_ROW_DATA : CONST_DATA_NAME_ROW_DATA
  , BUILT_IN_DATA_TYPES: CONST_BUILT_IN_DATA_TYPES
  , CONST_CTRL_OP_CLASSES: CTRL_OP_CLASSES
  , CONST_POSITION_USER_DEFINED_CONTROLS: POSITION_USER_DEFINED_CONTROLS
  , fnCreate: _fnCreate
  , fnDestroy: _fnDestroy
  , fnGetDataObj: _fnGetDataObj
  , fnAjaxCallAsmxWebMethod:    _fnAjaxCallAsmxWebMethod
  , fnCreateNewFieldDefinition: _fnCreateNewFieldDefinition
  , fnCreateNewControlDefinition: _fnCreateNewControlDefinition
  , fnCreateNameValueObject: _fnCreateNameValueObj
  , fnAdditionalParameterDefinitionForViewSet: _fnAdditionalParameterDefinitionForViewSet
  , fnAdditionalParameterDefinitionForAddNewSet: _fnAdditionalParameterDefinitionForAddNewSet
  , fnAdditionalParameterDefinitionForCloneSet: _fnAdditionalParameterDefinitionForCloneSet
  , fnAdditionalParameterDefinitionForEditSet: _fnAdditionalParameterDefinitionForEditSet
  , fnAdditionalParameterDefinitionForDeleteSet: _fnAdditionalParameterDefinitionForDeleteSet
  , fnAdditionalParameterDefinitionForUnDeleteSet: _fnAdditionalParameterDefinitionForUnDeleteSet
  , fnRequestViewFromServer: _fnRequestViewFromServer
  , fnOpenWindow: _fnOpenWindow
  , fnOpenTab:_fnOpenTab
  , fnCreateNewCellValue: _fnCreateNewCellValue
  , fnCreateNewCell: _fnCreateNewCell
  , fnCreateNewRow: _fnCreateNewRow
  , fnGetSavableFields: _fnGetSaveableFields
  , fnPutSaveableFieldsInMap: _fnPutSaveableFieldsInMap
  , fnForceAutoCompleteSearch: _fnForceAutoCompleteSearch
  , fnRefreshCurrentViewFromServer: _fnRefreshCurrentViewFromServer
  , fnBuildUrl: _fnBuildUrl
  , fnCreateNewUUID: _createNewUUID
  , fnShowColumn: _fnShowColumn
  , fnHideColumn: _fnHideColumn
  , fnCtrlOpInlineAreEditableFieldsLocked: _fnCtrlOpInlineAreEditableFieldsLocked
  , fnCtrlOpInlineAreEditableFieldsUnlocked: _fnCtrlOpInlineAreEditableFieldsUnlocked
  , fnFindCellByNameInWhatFieldCells: _fnFindCellByNameInWhatFieldCells
  , fnCtrlOpInlineUnlockEditableField: _fnCtrlOpInlineUnlockEditableField
  , fnCtrlOpInlineLockEditableField: _fnCtrlOpInlineLockEditableField
  , fnFlagValueToTrueFalse: _fnFlagValueToTrueFalse
  , fnHasValue: _fnHasValue
  , fnFindFieldDefinition: _fnFindFieldDefinition
  , fnFindAdditionalCellValueFieldDefinition: _fnFindAdditionalCellValueFieldDefinition
  , fnIdentifyUIActionAndCallHandler: _fnIdentifyUIActionAndCallHandler
  , fnRenderCtrl: _fnRenderCtrl
  , fnCtrlOpInlineGetNameValuePairsFromSaveableFields: _fnCtrlOpInlineGetNameValuePairsFromSaveableFields
  , fnCtrlOpInlineUnlockEditableFields: _fnCtrlOpInlineUnlockEditableFields
  , fnCtrlOpInlineGetSaveableFields: _fnCtrlOpInlineGetSaveableFields
  , fnCtrlOpInlineRequestDataObjFromNvpObjs: _fnCtrlOpInlineRequestDataObjFromNvpObjs
  , fnUpdateStatusContent: _fnUpdateStatusContent
  , fnHideMessageOverlay: _fnHideMessageOverlay
  , fnShowMessageOverlay: _fnShowMessageOverlay
  , fnUpdateMessageOverlayContent: _fnUpdateMessageOverlayContent
  , fnClearMessageOverlay: _fnClearMessageOverlay
  , fnGetMarkedRows : _fnGetMarkedRows
  , fnGetMarkedRowsRecordIDs: _fnGetMarkedRowsRecordIDs
  , fnGetMarkedRowsRecordIDsAsCsvStr: _fnGetMarkedRowsRecordIDsAsCsvStr
  , fnUnMarkMarkedRows: _fnUnMarkMarkedRows
  , fnFindHeaderControl: _fnFindHeaderControl
  , fnFindRowControl: _fnFindRowControl
  , fnSetHeaderControlToolTip: _fnSetHeaderControlToolTip
  , fnSetRowControlToolTip: _fnSetRowControlToolTip
  , fnAnimateRowControlInfinite: _fnAnimateRowControlInfinite
  , fnFindHeaderControlInThead: _fnFindHeaderControlInThead
  , fnFindSaveableFieldRefInSaveableFieldsBySaveUsingName: _fnFindSaveableFieldRefInSaveableFieldsBySaveUsingName
  , fnFindExistingRowByRecordID: _fnFindExistingRowByRecordID
  , fnFindIconInControl: _fnFindIconInControl
  , fnReplaceIconImageInControl: _fnReplaceIconImageInControl
  , fnIsUserActivelyManagingRows: _fnIsUserActivelyManagingRows
  , fnMarkRow : _fnMarkRow
  , fnGetCurrentRenderedBodyRows: _fnGetCurrentRenderedBodyRows
  , fnIsRowMarked: _fnIsRowMarked
  , fnHighlightRow: _fnHighlightRow
  , fnHighlightRowControl: _fnHighlightRowControl  
  , fnGetCurrentRenderedRowsRecordIDs: _fnGetCurrentRenderedRowsRecordIDs
  , fnGetCurrentRenderedRowsRecordIDsAsCsvStr: _fnGetCurrentRenderedRowsRecordIDsAsCsvStr
  , fnHideControl: _fnHideControl
  , fnShowControl: _fnShowControl
};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      MBA Rest View
 * @description  MBA Rest View
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

 /* Tie into jQuery namespace */

    $.fn.MBA_RestView = function (methodOrOptions, optionsOrValue)
	{

	  /* These are the supported methods and properties that can be accessed from outside
	   * after an instance is created */

		let _methods = {
			additionalParameterDefinitionForViewSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForViewSet(elem, parameterNameValueObj);
			}
			, additionalParameterDefinitionForAddNewSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForAddNewSet(elem, parameterNameValueObj);
			}
			, additionalParameterDefinitionForCloneSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForCloneSet(elem, parameterNameValueObj);
			}
			, additionalParameterDefinitionForEditSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForEditSet(elem, parameterNameValueObj);
			}
			, additionalParameterDefinitionForDeleteSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForDeleteSet(elem, parameterNameValueObj);
			}
			, additionalParameterDefinitionForUnDeleteSet: function (elem, parameterNameValueObj) {
				return MBA.RestViewCommon.fnAdditionalParameterDefinitionForUnDeleteSet(elem, parameterNameValueObj);
			}
			, requestViewFromServer: function (elem, pageNumber) {
				return MBA.RestViewCommon.fnRequestViewFromServer(elem, pageNumber);
			}
			, refreshCurrentViewFromServer: function (elem) {
				return MBA.RestViewCommon.fnRefreshCurrentViewFromServer(elem);
			}
			, getDataObj: function (elem) {
				return MBA.RestViewCommon.fnGetDataObj(elem);
			}
			, openWindow: function (elem, windowOptionsObj) {
				return MBA.RestViewCommon.fnOpenWindow(elem, windowOptionsObj.url, windowOptionsObj.windowName, windowOptionsObj.refreshView);
			}
			, openTab: function (elem, windowOptionsObj) {
				return MBA.RestViewCommon.fnOpenTab(elem, windowOptionsObj.url, windowOptionsObj.windowName, windowOptionsObj.refreshView);
			}
			, showColumn: function (elem, name) {
				return MBA.RestViewCommon.fnShowColumn(elem, name);
			}
			, hideColumn: function (elem, name) {
				return MBA.RestViewCommon.fnHideColumn(elem, name);
			}
			, getMarkedRows: function (elem) {
				return MBA.RestViewCommon.fnGetMarkedRows(elem);
			}
			, getMarkedRowsRecordIDs: function (elem) {
				return MBA.RestViewCommon.fnGetMarkedRowsRecordIDs(elem);
			}
			, unMarkMarkedRows: function (elem) {
				return MBA.RestViewCommon.fnUnMarkMarkedRows(elem);
			}
			, showOverlayMessage: function (elem, message) {
				MBA.RestViewCommon.fnUpdateMessageOverlayContent(elem, message);
				return MBA.RestViewCommon.fnShowMessageOverlay(elem);
			}
			, hideOverlayMessage: function (elem) {
				return MBA.RestViewCommon.fnHideMessageOverlay(elem, 500);
			}
			, findHeaderControl: function (elem, name) {
				return MBA.RestViewCommon.fnFindHeaderControl(elem, name);
			}
			, findExistingRowByRecordID: function (elem, recordID) {
				return MBA.RestViewCommon.fnFindExistingRowByRecordID(elem, recordID);
			}
			, isUserActivelyManagingRows: function (elem) {
				return MBA.RestViewCommon.fnIsUserActivelyManagingRows(elem);
			}
			, getCurrentRenderedBodyRows: function (elem) {
				return MBA.RestViewCommon.fnGetCurrentRenderedBodyRows(elem);
			}
			, getCurrentRenderedRowsRecordIDs: function (elem) {
				return MBA.RestViewCommon.fnGetCurrentRenderedRowsRecordIDs(elem)
			}
			, getCurrentRenderedRowsRecordIDsAsCsvStr: function (elem) {
				return MBA.RestViewCommon.fnGetCurrentRenderedRowsRecordIDsAsCsvStr(elem);
			}
	  };

	  let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

	  /* Method is create */

	  if ( typeof methodOrOptions === 'object' || !methodOrOptions ) {
        /* Tie into return chain so this can be chained with other methods */
		return this.each ( function() {
		  let elem = this; /* this in this scope is a reference to one of elements in the set */
	      return MBA.RestViewCommon.fnCreate  (elem, methodOrOptions);
        });
	  }

	  /* Method is destroy */

	  else if ( methodOrOptions == 'destroy' ) {
	    /* Tie into return chain so this can be chained with other methods */
		return this.each ( function() {
		  let elem = this; /* this in this scope is a reference to one of elements in the set */
		   return MBA.RestViewCommon.fnDestroy (elem);
        });
      }

	  /* Other methods (these cannot be chained) */

	  else if ( _methods [methodOrOptions] ) {

		if (numOf == 1)
		{
		  let elem = this[0]; /* There is only one element matched so we can proceed */
		  return _methods[ methodOrOptions ]( elem, optionsOrValue );
		}

		else if (numOf > 1)
		{
		  /**/
		  throw new Error('MBA Rest View ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );
		}

		else {
		  throw new Error('MBA Rest View ' +  methodOrOptions + ' cannot be applied since the element was not found.');
		}
	  }

	  /* Cant find the method */

	  else {
	    throw new Error('Method ' +  methodOrOptions + ' is an unknown MBA Rest View method' );
	  }

	}; /* mba_rest_view */

})( jQuery );
