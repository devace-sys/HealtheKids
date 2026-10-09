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
   * DataEntryRowSelectORP */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectORP:DataEntryRowSelectPractitioner
  {
    public DataEntryRowSelectORP(): base()
	  {	     
      _entryAllowed                       = true;
      _entryNotAllowedUseReplacementValue = false;      
      _preSelectedDataSource              = PractitionerDataSource.POTENTIAL_ORP_ONLY;      
      _additionalInformation              = Messages.MSG_PRAC_SELECTION_IS_QUALIFIED_ORP_ONLY;        
      _showAddNew                         = true;
      _showEditSelected                   = true;
      _showManageFiles                    = true;
      _entityIDToUseWithManageFiles       = Constants.PARM_PRACTITIONER_ID;       /* ORP is still a prac */
      _fileClassToUseWithManageFiles      = StoredFiles.FILE_CLASS_PRESCRIPTIONS; /* Default file class */
    }        
	  protected override void Render(HtmlTextWriter writer)
    {     	                                    
      base.Render(writer);
    }
  }
}
