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
   * DataEntryRowSelectUser */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectUser : DataEntryRowSelectPerson
    {
    public DataEntryRowSelectUser(): base()
	{	     
      _selectTitle                        = "Last Name, First Name";
      _dataPrivate                        = true;
      _dataURL                            = "users.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasManageFiles                     = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _nounPlural                         = "Users";
      _nounSingular                       = "User";      
  }
    
  protected string  _ctrlIdClientID   = null;
  
  public string  ctrlIdClientID  { get { return _ctrlIdClientID; }  set {_ctrlIdClientID = value;}}  
  
  protected override void Render(HtmlTextWriter writer)
  {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))      _entityControlID                = @"userid";
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))       _ctrlIdClientID                 = @"clientid";

      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);

      base.Render(writer);
    }
  }
}
