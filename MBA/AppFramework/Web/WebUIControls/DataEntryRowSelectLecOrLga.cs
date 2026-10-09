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
     * DataEntryRowSelectLecOrLga */
    /**
     * 
     *************************************************************************/
    public class DataEntryRowSelectLecOrLga : DataEntryRowSelectEntity
    {
        public DataEntryRowSelectLecOrLga() : base()
        {
            _selectTitle = "LEC / LGA";
            _dataPrivate = true;
            _dataURL = "lec_or_lga.asmx/viewSel";
            _hasDataSource = false;
            _hasAddNew = false;
            _hasEditSelected = false;
            _hasViewNotes = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural = "LEC / LGA";
            _nounSingular = "LEC / LGA";

            _entryAllowedFn = null;

            _entryNotAllowedReplacementValueFn = null;

        }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_LEC_OR_LGA_ID;
            if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_LEC_OR_LGA_ID;

            base.Render(writer);
        }
    }
}
