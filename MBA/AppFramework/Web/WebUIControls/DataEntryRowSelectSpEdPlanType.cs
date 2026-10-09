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
   * DataEntryRowSelectSpEdPlanType */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectSpEdPlanType:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectSpEdPlanType(): base()
	  {	     
      _selectTitle                        = "Plan Type";
      _dataPrivate                        = true;
      _dataURL                            = "sped_plan_types.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "SpEd Plan Types";
      _nounSingular                       = "SpEd Plan Type";
      
      _entryAllowedFn                     = null;

      _entryNotAllowedReplacementValueFn  = null;

    }

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_SPED_PLAN_TYPE_CODE;

      base.Render(writer);
    }
  }
}
