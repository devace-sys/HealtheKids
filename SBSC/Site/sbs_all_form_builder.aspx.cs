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
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{
    /***************************************************************************
     * SbsAllFormBuilder */
    /**
     *
     ***************************************************************************/

    public class SbsAllFormBuilder : WebUI
    {
      public int svcID;

      public SbsAllFormBuilder() : base (@"sbs_all_form_builder"
                                               , ""
                                               , @""
                                               , @""
                                               , Constants.ROLE_SBS_ALL )
      {} 
   
    
                                        
    protected void Page_Load(object sender, EventArgs e)
    {      	    
      
      /*###########################################################################
        # Get parameters passed on URL
        ###########################################################################*/      
      
      int.TryParse(MBA.HttpApplication.getParameter("svcID"), out svcID);

    }
  }
}