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
   * ClientProvSvcRecHeldForChangeDetails */
  /**
   *
   ***************************************************************************/   

  public class ClientProvSvcRecHeldForChangeDetails: WebUI
  {
    public string svcsHeldTbl = "";
    
    public ClientProvSvcRecHeldForChangeDetails() : base(  "service_records_held_for_change_details",
                                                   WebUI.CreatePageSubTitle(ServiceRecordsApproval.SEL_LABEL, ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISED_REV_SVC_HELD),
                                                   "",
                                                   "",
                                                   Constants.ROLE_LEA_PROVIDER){}
        
    protected void Page_Load(object sender, EventArgs e)
    {      
      
      /*###########################################################################
        # Validate parameters
        ###########################################################################*/          
      
      long   vClientID  = Spedmon.Validate.reqClientID (uInfo, "");
      long   vPracID    = Spedmon.Validate.reqPracID   (uInfo, "");      

      
      /*###########################################################################
        # Reassign parameter values with results of validation
        ###########################################################################*/          

      string clientid  = vClientID.ToString();
      string pracid    = vPracID.ToString();
      
      /*###########################################################################
        # Generate services held table for user interaction
        ###########################################################################*/          

      svcsHeldTbl = ServiceRecordsApprovalSvcRecsToChangeDetails.generateStaticHTMLTable(dbConnApp,log,uInfo,clientid,pracid);
      
    }
  
  }
}
