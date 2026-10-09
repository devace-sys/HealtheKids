using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;


namespace Spedmon
{
  /***************************************************************************
   * SbsMgmtCybhi835Posting */
  /**
   * 
   ***************************************************************************/


  public class SbsMgmtCybhi835Posting : WebUI

  {

    public SbsMgmtCybhi835Posting() : base(  Util.createUniqueID()
                                              , @"CYBHI Posting"
                                              , @""
                                              , @"components/js-mba-x12-common.js"
										      , Constants.ROLE_SBS_ALL) { }
    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
    }
	
  }
}
