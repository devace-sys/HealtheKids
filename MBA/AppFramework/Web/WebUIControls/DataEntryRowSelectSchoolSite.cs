using System;
using System.Web.UI;

namespace MBA
{
    public class DataEntryRowSelectSchoolSite : DataEntryRowSelectEntity
    {
        public DataEntryRowSelectSchoolSite() : base()
        {
            _selectTitle = "Site";
            _dataPrivate = true;
            _dataURL = "sites.asmx/viewSel";
            _hasDataSource = false;
            _hasAddNew = false;
            _hasEditSelected = false;
            _hasViewNotes = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural = "Sites";
            _nounSingular = "Site";
            _entryAllowedFn = null;
            _entryNotAllowedReplacementValueFn = null;
            _hasSaveSelectionAsDefault = true;
        }

        protected string _ctrlIdClientID = null;
        public string ctrlIdClientID { get { return _ctrlIdClientID; } set { _ctrlIdClientID = value; } }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_SITE_ID;
            if (String.IsNullOrWhiteSpace(_ctrlIdClientID)) _ctrlIdClientID = Constants.PARM_CLIENT_ID;

            /* Add data parm control ids (datasource is handled by base class) */

            this._dataParameterControlIDs.Add(_ctrlIdClientID);

            base.Render(writer);
        }
    }
}
