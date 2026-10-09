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
     * DataEntryRowSelectSELPA */
    /**
     * 
     *************************************************************************/
    public class DataEntryRowSelectSELPA : DataEntryRowSelectEntity
    {
        // constructor
        public DataEntryRowSelectSELPA() : base()
        {
            _selectTitle             = "SELPA";
            _dataPrivate             = true;
            _dataURL                 = "selpas.asmx/viewSel";
            _hasDataSource           = false;
            _hasAddNew               = false;
            _hasEditSelected         = false;
            _hasViewNotes            = false;
            _dataSourceParameterName = null;
            _preSelectedDataSource   = null;
            _saveDataSourceSelectedAsPreference = false;
            _nounPlural              = "SELPAS";
            _nounSingular            = "SELPA";

            _entryAllowedFn = delegate (ref RequestResponse rd) {
               if (rd.wu.usr.userGroupID == Constants.USER_GROUP_SBSC) return true;      
               return false;
            };
          
            _entryNotAllowedReplacementValueFn = delegate (ref RequestResponse rd) {
              
             if (rd.wu.usr.roleID == Constants.ROLE_SELPA_USER_ID) {
                 _selectValue = rd.wu.usr.selpaCode.ToString();
                 _selectName = rd.wu.usr.selpaName;
              }

              if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) {
                _selectValue = rd.wu.usr.selpaCode.ToString();
                 _selectName = rd.wu.usr.selpaName;
              }
              return true;
           };
        
        }

        protected override void Render(HtmlTextWriter writer)
        {

            /* Use default control ids if nothing was provided */

            if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID              = Constants.PARM_SELPA_CODE;
            if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_SELPA_CODE;

            base.Render(writer);
        }
    }
}
