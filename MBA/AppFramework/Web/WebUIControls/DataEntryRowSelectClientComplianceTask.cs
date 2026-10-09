using System;
using System.Web.UI;


namespace MBA
{
    public class DataEntryRowSelectClientComplianceTask : DataEntryRowSelectEntity
    {
        public DataEntryRowSelectClientComplianceTask() : base()
        {
            _selectTitle = "Task";
            _dataPrivate = true;
            _dataURL = "client_compliance_tasks.asmx/viewSel";
            _hasDataSource = false;
            _hasAddNew = false;
            _hasEditSelected = false;
            _hasViewNotes = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural = "Client Compliance Tasks";
            _nounSingular = "Client Compliance Task";

            _entryAllowedFn = null;

            _entryNotAllowedReplacementValueFn = null;

        }


        protected override void Render(HtmlTextWriter writer)
        {            
            base.Render(writer);
        }
    }
}

