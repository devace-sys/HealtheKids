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
   * SBSAllRecurringServicesOpEnd */
  /**
   * Operation end
   ***************************************************************************/   

  public class SBSAllRecurringServicesOpEnd : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_COPY;
  
    public SBSAllRecurringServicesOpEnd () : base("recurring_services_delete",
                                                 WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_ADD),
                                                 "",
                                                 "recurringservices.js",
                                                 Constants.ROLE_SBS_ALL){}
    
    
    protected void Page_Load(object sender, EventArgs e)
    {    
    
      /*-------------------------------
       * Get parameters
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
                  
      /*-------------------------------
       * Determine save type
       *------------------------------*/ 

      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);   
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_COPY;      
      saveType = (int) vSaveType;               
      
      /*-------------------------------
       * Locate steps container and
       * steps
       *------------------------------*/ 

      Steps ctrlSteps  = findControlRecu(this.Page, "save")   as Steps;
      Step  ctrlStep1  = findControlRecu(this.Page, "step1")  as Step;
      Step  ctrlStep2  = findControlRecu(this.Page, "step2")  as Step;      

      /*-------------------------------
       * Locate controls
       *------------------------------*/ 

      WebUIControlDataField ctrlSaveType        = findControlRecu(this.Page, "savetype")            as WebUIControlDataField;
      WebUIControlDataField ctrlRecID           = findControlRecu(this.Page, "recid")               as WebUIControlDataField;
      WebUIControlDataField ctrlActionURL       = findControlRecu(this.Page, "actionurl")           as WebUIControlDataField;
      DateBox               ctrlEffectiveDate   = findControlRecu(this.Page, "effectivedate")       as DateBox;
      
      /*-------------------------------
       * Set save type
       *------------------------------*/ 

      ctrlSaveType.value = saveType.ToString();
      
      /*-------------------------------
       * Load record
       *------------------------------*/ 
      
      RecurringService rs = RecurringServices.load(dbConnApp,log, uInfo, recid);        
      
      /*-------------------------------
       * Populate values
       *------------------------------*/ 
      
      ctrlRecID.value          = rs.id.ToString();
      ctrlActionURL.value      = MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx",true);        
      ctrlStep1.label          = rs.endDateStr;
      ctrlEffectiveDate.value  = rs.endDateStr;
      
      /*-------------------------------
       * End record and start a new one
       *------------------------------*/ 
       
      if (saveType == Constants.SAVE_TYPE_COPY)
      {
        this.subTitle = WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_COPY);
      }

      /*-------------------------------
       * End record and exit
       *------------------------------*/ 

      else if (saveType == Constants.SAVE_TYPE_DEACTIVATE)
      {
        this.subTitle = WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_DEACTIVATE);
      }                                   
    }
  }
}
