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
   * DataEntryRowSelectSpEdReferringParty */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectSpEdReferringParty:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectSpEdReferringParty(): base()
	  {	     
      _selectTitle                        = "Referring Party";
      _dataPrivate                        = true;
      _dataURL                            = "sped_referring_parties.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "SpEd Referring Parties";
      _nounSingular                       = "SpEd Referring Party";
      
      _entryAllowedFn                     = null;

      _entryNotAllowedReplacementValueFn  = null;

    }

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_SPED_REFERRING_PARTY_CODE;

      base.Render(writer);
    }
  }
}
