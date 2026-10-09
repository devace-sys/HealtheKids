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
     * SbsAllClaimProceduresServiceFeesUpdate */
    /**
     *
     ***************************************************************************/

    public class SbsAllClaimProceduresServiceFeesUpdate : WebUI
    {

      public SbsAllClaimProceduresServiceFeesUpdate() : base (@"sbs_all_claim_procedures_service_fees_update"
                                                             , Spedmon.ClaimProcedureFees.SEL_LABEL_SERVICE_FEES_UPDATE
                                                             , @""
                                                             , @""
                                                             , Constants.ROLE_SBS_ALL )
      {} 
   
    
                                        
    protected void Page_Load(object sender, EventArgs e)
    {      	    
    }
  }
}