using System;
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
     * DataEntryRowSelectFiscalYear */
    /**
     * 
     *************************************************************************/
    public class DataEntryRowSelectRmtsFiscalQuarter : DataEntryRowSelectEntity
    {
        // constructor
        public DataEntryRowSelectRmtsFiscalQuarter() : base()
        {
            _selectTitle = "Quarter";
            _dataPrivate = true;
            _dataURL = "rmts_current_quarters.asmx/viewSel";
            _hasDataSource = false;
            _hasAddNew = false;
            _hasEditSelected = false;
            _hasViewNotes = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural = "Fiscal Quarters";
            _nounSingular = "Fiscal Quarter";

            _entryAllowedFn = null;

            _entryNotAllowedReplacementValueFn = null;

        }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_FY_QUARTER_ID;
            if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_FY_QUARTER_ID;

            base.Render(writer);
        }
    }
}