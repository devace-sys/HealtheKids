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
   * SBSAllRecurringServicesEditDelete */
  /**
   * 
   ***************************************************************************/

  public class SBSAllRecurringServicesEditDelete : WebUI
  {
    
    public SBSAllRecurringServicesEditDelete() : base("recurring_services_edit_delete", WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_OPS), "", "recurringservices.js", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    
      /*-------------------------------
       * Look up default values for
       * school year and start/end
       * dates
       *------------------------------*/ 
       
      Steps                 ctrlSteps   = findControlRecu(this.Page, "editdelete")   as Steps;
      Step                  ctrlStep1   = findControlRecu(this.Page, "step1")        as Step;
      ComboBox              ctrlFYID    = findControlRecu(this.Page, "fiscalyearid") as ComboBox;         
      
      ClientAttendanceYear  yr          = ClientAttendanceYears.loadNRecord(dbConnApp, log, uInfo,0);                
      
      ctrlStep1.label = yr.name;  
      ctrlFYID.value  = yr.id.ToString();
      ctrlSteps.firstStep = 1;
      
    }
  }
}
