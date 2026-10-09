using System;
using System.Text;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{
    /**************************************************************************
     * DataEntryRowSaveOrEdit
    /**
     * 
     ****************************************************************************/
    public class DataEntryRowSaveOrEdit : DataEntryRow
    {
        public DataEntryRowSaveOrEdit() : base()
        {
        }

        protected int?   _saveType                                = null;
        protected string _recID                                   = null;
        protected string _editDelManageLink                       = null;
        protected bool   _includeSaveAndProceedButton             = true;
        protected bool   _includeButtonManageSupportingDocuments  = false;
        protected bool   _includeSecondarySaveButton              = false;
        protected bool   _autoProceedOnSave                       = true;
        protected bool   _includeCancelButton                     = true;
        protected bool   _showAuditHistory                        = false;
        protected string _auditHistoryHTML                        = "";
        protected string _secondarySaveButtonOnClick              = "";
        protected string _secondarySaveButtonLabel                = "";
        protected string _manageSupportingDocumentsLabel          = "Manage Supporting Documents";
        protected string _cancelButtonLabel                       = "Cancel";
        protected bool   _setRowLabelToAttestStatement            = true;
        protected bool   _useDefaultAdditionalRowClass            = true;

        protected string  _attestStatement                        = Messages.ATTEST_STATEMENT;
        protected string  _saveAndProceedButtonLabelForNew        = @"Save & Proceed";
        protected string  _saveAndProceedDiagTitleForNew          = @"Save New";        
        protected string  _saveAndProceedButtonLabelForEdit       = @"Save Changes & Proceed";
        protected string  _saveAndProceedDiagTitleForEdit         = @"Save Changes";


        public string editDelManageLink { get { return _editDelManageLink; } set { _editDelManageLink = value; } }
        public int? saveType { get { return _saveType; } set { _saveType = value; } }
        public string recID { get { return _recID; } set { _recID = value; } }
        public bool includeSaveAndProceedButton { get { return _includeSaveAndProceedButton; } set { _includeSaveAndProceedButton = value; } }
        public bool includeButtonManageSupportingDocuments { get { return _includeButtonManageSupportingDocuments; } set { _includeButtonManageSupportingDocuments = value; } }
        public bool includeSecondarySaveButton { get { return _includeSecondarySaveButton; } set { _includeSecondarySaveButton = value; } }
        public bool includeCancelButton { get { return _includeCancelButton; } set { _includeCancelButton = value; } }
        public bool autoProceedOnSave { get { return _autoProceedOnSave; } set { _autoProceedOnSave = value; } }
        public bool showAuditHistory  { get { return _showAuditHistory;  } set { _showAuditHistory = value;  } }
        public string manageSupportingDocumentsOnClick { get; set; }
        public string auditHistoryHTML { get { return _auditHistoryHTML; } set { _auditHistoryHTML = value; } }
        public string secondarySaveButtonOnClick { get { return _secondarySaveButtonOnClick; } set { _secondarySaveButtonOnClick = value; } }
        public string secondarySaveButtonLabel { get { return _secondarySaveButtonLabel; } set { _secondarySaveButtonLabel = value; } }
        public string manageSupportingDocumentsLabel { get { return _manageSupportingDocumentsLabel; } set { _manageSupportingDocumentsLabel = value; } }
        public string cancelButtonLabel { get { return _cancelButtonLabel; } set { _cancelButtonLabel = value; } }
        public bool setRowLabelToAttestStatement { get { return _setRowLabelToAttestStatement;} set { _setRowLabelToAttestStatement = value; } }
        public bool useDefaultAdditionalRowClass {  get { return _useDefaultAdditionalRowClass;} set { _useDefaultAdditionalRowClass = value;} }
        public string  attestStatement                  { get { return _attestStatement;}                  set { _attestStatement = value; }}
        public string  saveAndProceedButtonLabelForNew  { get { return _saveAndProceedButtonLabelForNew;}  set { _saveAndProceedButtonLabelForNew  = value; }}
        public string  saveAndProceedDiagTitleForNew    { get { return _saveAndProceedDiagTitleForNew;}    set { _saveAndProceedDiagTitleForNew    = value; }}
        public string  saveAndProceedButtonLabelForEdit { get { return _saveAndProceedButtonLabelForEdit;} set { _saveAndProceedButtonLabelForEdit = value; }}
        public string  saveAndProceedDiagTitleForEdit   { get { return _saveAndProceedDiagTitleForEdit;}   set { _saveAndProceedDiagTitleForEdit   = value; }}

        /***************************************************************************
         * Render */
        /**
         * 
         * 
         ***************************************************************************/

        protected override void Render(HtmlTextWriter writer)
        {
            // Generate div for audit history
            
            if (_showAuditHistory)
            {
                writer.Write(@"<div class=""ui-spedmon-data-entry-audit-content-container"">" + _auditHistoryHTML + @"</div>");
                this._additionalOnDocReady = "$.fn.setupDataEntryRowSaveEditAuditTable ();";
            }

            // the ID for the secondary save button if it needs to be rendered

            var _secondarySaveButtonID = Util.createUniqueID(this.ID);
            
            /* Override standard classes */
            
            if (_useDefaultAdditionalRowClass) this._additionalRowClass = @"ui-spedmon-data-entry-row-save-or-edit";
            this._colLabelBSClasses = " col-xs-12 col-sm-12 col-md-12";
            this._colEntryBSClasses = " col-xs-12 col-sm-12 col-md-12";

            if (_setRowLabelToAttestStatement) this.rowLabel = _attestStatement;

            if (!_saveType.HasValue) _saveType = Constants.SAVE_TYPE_NEW;
            if (String.IsNullOrWhiteSpace(_recID)) _recID = _recID = @"";

            addHiddenInput(Constants.PARM_SAVE_TYPE, Constants.PARM_SAVE_TYPE, _saveType.Value.ToString());
            addHiddenInput(Constants.PARM_REC_ID, Constants.PARM_REC_ID, _recID);
            addHiddenInput(Constants.PARM_VALIDATE_REC, Constants.PARM_VALIDATE_REC, "1");
            addHiddenInput(Constants.PARM_EDIT_DEL_REASON, Constants.PARM_EDIT_DEL_REASON, "");
            addHiddenInput(Constants.PARM_EDIT_DEL_MANAGE_LINK, Constants.PARM_EDIT_DEL_MANAGE_LINK, _editDelManageLink);


            var cancelButton = new MBA.ButtonConfirm();
            cancelButton.ID = "butcancel";
            cancelButton.icon = "ui-icon-close";
            cancelButton.text = _cancelButtonLabel;

            var manageSupportingDocsButton = new MBA.Button();
            if (_includeButtonManageSupportingDocuments)
            {
                manageSupportingDocsButton.ID      = "butmanagesupportingdocs";
                manageSupportingDocsButton.icon    = "ui-icon-paperclip";
                manageSupportingDocsButton.text    = _manageSupportingDocumentsLabel;
                manageSupportingDocsButton.onclick = manageSupportingDocumentsOnClick;
            }

            var saveAndProceedButton = new MBA.Button();
            saveAndProceedButton.ID = "butsave";
            saveAndProceedButton.icon = "ui-icon-play";

            // create a secondary save button and set its functionality if needed

            var secondarySaveButton = new MBA.Button();
            if (_includeSecondarySaveButton)
            {
                secondarySaveButton.ID = _secondarySaveButtonID;
                secondarySaveButton.icon = "ui-icon-play";
                secondarySaveButton.text = _secondarySaveButtonLabel;
                secondarySaveButton.title = _secondarySaveButtonLabel;
                secondarySaveButton.onclick = _secondarySaveButtonOnClick;
            }

            var validateThenSaveDiag = new DataEntryRowSaveOrEditValidateThenSaveDialog();
            
            if (_saveType.Value == Constants.SAVE_TYPE_NEW)
            {
                saveAndProceedButton.text = _saveAndProceedButtonLabelForNew;
                validateThenSaveDiag.title = _saveAndProceedDiagTitleForNew;

                if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
                {
                    cancelButton.onclick = "$.spedmonWebUI.dataEntry.doGoHome()";
                    saveAndProceedButton.onclick = "$.spedmonWebUI.dataEntry.openValidateThenSaveDialog('gohome', null, " + Util.netBoolToJSBool(_autoProceedOnSave) + ")";
                }
                else
                {
                    cancelButton.onclick = "$.spedmonWebUI.dataEntry.doClose()";
                    saveAndProceedButton.onclick = "$.spedmonWebUI.dataEntry.openValidateThenSaveDialog('close', null, " + Util.netBoolToJSBool(_autoProceedOnSave) + ")";
                }
            }
            else
            {

                saveAndProceedButton.text = _saveAndProceedButtonLabelForEdit;
                validateThenSaveDiag.title = _saveAndProceedDiagTitleForEdit;

                if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
                {
                    cancelButton.onclick = "$.spedmonWebUI.dataEntry.doGoList()";
                    saveAndProceedButton.onclick = "$.spedmonWebUI.dataEntry.openValidateThenSaveDialog('golist', null, " + Util.netBoolToJSBool(_autoProceedOnSave) + ")";
                }
                else
                {
                    cancelButton.onclick = "$.spedmonWebUI.dataEntry.doClose()";
                    saveAndProceedButton.onclick = "$.spedmonWebUI.dataEntry.openValidateThenSaveDialog('close', null, " + Util.netBoolToJSBool(_autoProceedOnSave) + ")";
                }
            }

            if (_includeCancelButton)                     this.Controls.Add(cancelButton);
            if (_includeButtonManageSupportingDocuments)  this.Controls.Add(manageSupportingDocsButton);
            if (_includeSaveAndProceedButton)             this.Controls.Add(saveAndProceedButton);                        
            if (_includeSecondarySaveButton)              this.Controls.Add(secondarySaveButton);
                                                    
            this.Controls.Add(validateThenSaveDiag);
            base.Render(writer);

            return;
        }
    }
}
