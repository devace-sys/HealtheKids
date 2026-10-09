using System;
using MBA;

namespace Spedmon
{

  public class UserAllCYBHIProgramHealthManage : WebUI
  {


    public UserAllCYBHIProgramHealthManage() : base(
		                                        CYBHIProgramHealthStats.BODY_ID_MANAGE
                                              , CYBHIProgramHealthStats.SEL_LABEL_MANAGE
                                              , @"user_all_cybhi_program_health_manage.css"
                                              , @""
                                              , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD){}

    public bool   isPcalStaff            = false;
    public string clientName             = "";
    public bool   showClientName         = false;
    public bool   showNoDrillDownMessage = false;
	protected void Page_Load(object sender, EventArgs e)
    {

      this.includeBackgroundLayer = true;

      isPcalStaff = rd.wu.usr.pcalStaff;

  	  var ctrlClientID = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient; 
      
	  /* preselect clientid if passed */
	  
      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

      if (!String.IsNullOrEmpty(clientIDStr)) {

        ctrlClientID.selectValue                       = clientIDStr;
        ctrlClientID.entryInitiallyHidden              = true;
        ctrlClientID.entryAllowed                      = false;
        ctrlClientID.applyCybhiConsortiumLeadException = true;        
      
        var client     = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        clientName     = client.name;             
        showClientName = true;

        if (CYBHIProgramHealthStats.userCanDrillDown(uInfo,clientIDStr) == false) {
          showNoDrillDownMessage = true;
        }

      }

    }
  }
}