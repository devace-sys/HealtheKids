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
     * DataEntryRowSelectClientRep */
    /**
     * 
     *************************************************************************/
    public class DataEntryRowSelectClientRep : DataEntryRowSelectEntity
    {
        // constructor
        public DataEntryRowSelectClientRep() : base()
        {
            _selectTitle             = "Client Rep";
            _dataPrivate             = true;
            _dataURL                 = "clientReps.asmx/viewSel";
            _hasDataSource           = false;
            _hasAddNew               = false;
            _hasEditSelected         = false;
            _hasViewNotes            = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource   = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural              = "Client Reps";
            _nounSingular            = "Client Rep";

            _entryAllowedFn = null;

            _entryNotAllowedReplacementValueFn = null;

        }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_REP_ID;
            if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_REP_ID;

            base.Render(writer);
        }
    }
}
