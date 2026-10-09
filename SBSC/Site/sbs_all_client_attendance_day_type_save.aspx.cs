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

namespace Spedmon
{
  /***************************************************************************
   * SBSAllClientAttendanceDayTypeSave */
  /**
   * Saves an attendance day type
   ***************************************************************************/   

  public class SBSAllClientAttendanceDayTypeSave : WebUI
  {
    public int saveType = 0;
   
    public SBSAllClientAttendanceDayTypeSave() : base("attendance_day_type_save",WebUI.CreatePageSubTitle(ClientAttendanceDayTypes.SEL_LABEL, ClientAttendanceDayTypes.SEL_LABEL_ADD),"","",Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
            
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null) 
        vSaveType = Constants.SAVE_TYPE_NEW;
      
      saveType = (int) vSaveType;

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")   as WebUIControlDataField;      
      Steps                 ctrlSteps    = findControlRecu(this.Page, "save")       as Steps;
      

      ctrlSaveType.value = saveType.ToString();
      
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/ 

        ClientAttendanceDayType adt = ClientAttendanceDayTypes.load(dbConnApp,log,uInfo,recid);
        
        /*-------------------------------
         * Locate step controls
         *------------------------------*/ 

        Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
        Step ctrlStep2 = findControlRecu(this.Page,"step2") as Step;
        Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
        Step ctrlStep4 = findControlRecu(this.Page,"step4") as Step;
        Step ctrlStep5 = findControlRecu(this.Page, "step5") as Step;


       /*-------------------------------
        * Locate data controls
        *------------------------------*/ 

        WebUIControlDataField ctrlRecID     = findControlRecu(this.Page, "recid")              as WebUIControlDataField;
        WebUIControlDataField ctrlClientID  = findControlRecu(this.Page, "clientid")           as WebUIControlDataField;
        WebUIControlDataField ctrlName      = findControlRecu(this.Page, "name")               as WebUIControlDataField;        
        WebUIControlDataField ctrlDesc      = findControlRecu(this.Page, "description")        as WebUIControlDataField;        

        /*-------------------------------
         * Populate step labels
         *------------------------------*/

        ctrlStep2.label = adt.clientName;
        ctrlStep3.label = adt.name;
        ctrlStep4.label = adt.description;
  
        /*-------------------------------
         * Populate data values
         *------------------------------*/

        ctrlRecID.value    = adt.id.ToString();
        ctrlClientID.value = (adt.clientID == 0) ? "" : adt.clientID.ToString();  // Handles case of 0
        ctrlName.value     = adt.name;
        ctrlDesc.value     = adt.description;
        
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(ClientAttendanceDayTypes.SEL_LABEL, ClientAttendanceDayTypes.SEL_LABEL_EDIT);
        
        ctrlSteps.firstStep = 4; // step - 1
      
      }
   
    }
  }
}
