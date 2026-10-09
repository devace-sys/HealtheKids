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
    public class DataEntryRowSelectFiscalYear : DataEntryRowSelectEntity
    {
        // control parameters
        protected string _ctrlIdYearsBack    = null;
        protected string _ctrlIdYearsForward = null;
        protected string _ctrlIdYear         = null;
        protected string _yearsBackVal       = "0"; // TODO: Figure out how to send yearsBackVal and yearsForwardVal to company_fiscal_years.asmx/viewSel method. Currently they are hard-coded
        protected string _yearsForwardVal    = "2";
        protected string _yearVal            = DateTime.Now.ToString("yyyy-MM-dd");
        public string ctrlIdYearsBack    { get { return _ctrlIdYearsBack;    } set { _ctrlIdYearsBack = value;    } }
        public string ctrlIdYearsForward { get { return _ctrlIdYearsForward; } set { _ctrlIdYearsForward = value; } }
        public string ctrlIdYear         { get { return _ctrlIdYear;         } set { _ctrlIdYear = value;         } }
        public string yearsBackVal       { get { return _yearsBackVal;       } set { _yearsBackVal = value;       } }
        public string yearsForwardVal    { get { return _yearsForwardVal;    } set { _yearsForwardVal = value;    } }
        public string yearVal            { get { return _yearVal;            } set { _yearVal = value;            } }

        // constructor
        public DataEntryRowSelectFiscalYear() : base()
        {
            _selectTitle = "Year";
            _dataPrivate = true;
            _dataURL = "company_fiscal_years.asmx/viewSel";
            _hasDataSource = false;
            _hasAddNew = false;
            _hasEditSelected = false;
            _hasViewNotes = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural = "Fiscal Years";
            _nounSingular = "Fiscal Year";

            _entryAllowedFn = null;

            _entryNotAllowedReplacementValueFn = null;

        }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_FISCAL_YEAR_ID;
            if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_FISCAL_YEAR_ID;

            if (String.IsNullOrWhiteSpace(_ctrlIdYearsBack))    _ctrlIdYearsBack    = @"yearsback";
            if (String.IsNullOrWhiteSpace(_ctrlIdYearsForward)) _ctrlIdYearsForward = @"yearsforward";
            if (String.IsNullOrWhiteSpace(_ctrlIdYear))         _ctrlIdYear         = @"year";
            
            //this._dataParameterControlIDs.Add(_ctrlIdYearsBack);
            //this._dataParameterControlIDs.Add(_ctrlIdYearsForward);
            //this._dataParameterControlIDs.Add(_ctrlIdYear);

            // todo: add yearsForward, yearsBack and year to web service viewSel and use controls in here to populate
            //writer.Write(@"<input name=""" + _ctrlIdYearsBack    + @""" type=""hidden"" value=""" + _yearsBackVal    + @"""/>");
            //writer.Write(@"<input name=""" + _ctrlIdYearsForward + @""" type=""hidden"" value=""" + _yearsForwardVal + @"""/>");
            //writer.Write(@"<input name=""" + _ctrlIdYear         + @""" type=""hidden"" value=""" + _yearVal         + @"""/>");

            base.Render(writer);
        }
    }
}
