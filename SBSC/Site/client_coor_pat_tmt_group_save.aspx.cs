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
   * SBSAllPatTmtGroupSave */
  /**
   * Saves a treatment group
   * 
   * Note: For treatment groups, edit is a seperate page.
   ***************************************************************************/   

  public class clientcoorpattmtgroupsave : WebUI
  {   
    public clientcoorpattmtgroupsave() : base("patient_group_save",WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_ADD),"","",Constants.ROLE_CLIENT_BO){}
    
    public int saveType = Constants.SAVE_TYPE_NEW;
     
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
      
      /*-------------------------------
       * Locate steps
       *------------------------------*/ 

      Steps ctrlSteps = findControlRecu(this.Page, "save") as Steps;

      /*-------------------------------
       * Locate save type and set its
       * value to new
       *------------------------------*/ 

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")   as WebUIControlDataField;            
      
      ctrlSaveType.value = saveType.ToString();
      
      
      WebUIControlDataField ctrlEffDate     = findControlRecu(this.Page, "tmteffdate")     as WebUIControlDataField;

      if (saveType == Constants.SAVE_TYPE_NEW)
      {
        /*-------------------------------
         * Locate and hide effective date
         *------------------------------*/ 
       
        ctrlEffDate.inlineLabel = "";
        ctrlEffDate.hidden      = true;
      }
      
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/ 
       
        PatientGroup pg = PatientGroups.load(dbConnApp, log, uInfo, recid);
               
        /*-------------------------------
         * Locate step controls
         *------------------------------*/ 
		
        Step ctrlStep2  = findControlRecu(this.Page,"step2")  as Step;
        Step ctrlStep3  = findControlRecu(this.Page,"step3")  as Step;
        Step ctrlStep4  = findControlRecu(this.Page,"step4")  as Step;
        Step ctrlStep5  = findControlRecu(this.Page,"step5")  as Step;
        Step ctrlStep6  = findControlRecu(this.Page,"step6")  as Step;        
        Step ctrlStep7  = findControlRecu(this.Page,"step7")  as Step;
        Step ctrlStep9  = findControlRecu(this.Page,"step9")  as Step;
	
        /*-------------------------------
         * Locate entity steps
         *------------------------------*/ 
        
		StepSelectPractitioner ctrlStep1 = findControlRecu(this.Page, "step1") as StepSelectPractitioner;
        StepSelectPatient      ctrlStep8 = findControlRecu(this.Page, "step8") as StepSelectPatient;

       /*-------------------------------
        * Locate data controls
        *------------------------------*/ 
       
       WebUIControlDataField ctrlRecID       = findControlRecu(this.Page, "recid")        as WebUIControlDataField;               
       WebUIControlDataField ctrlClientID    = findControlRecu(this.Page, "clientid")     as WebUIControlDataField;    
       WebUIControlDataField ctrlName        = findControlRecu(this.Page, "name")         as WebUIControlDataField;
       WebUIControlDataField ctrlDescription = findControlRecu(this.Page, "description")  as WebUIControlDataField;
       WebUIControlDataField ctrlStartDate   = findControlRecu(this.Page, "startdate")    as WebUIControlDataField;
       WebUIControlDataField ctrlStartTime   = findControlRecu(this.Page, "starttime")    as WebUIControlDataField;
       WebUIControlDataField ctrlGrpMtg2     = findControlRecu(this.Page, "grpmtg2")      as WebUIControlDataField;
       WebUIControlDataField ctrlGrpMtg3     = findControlRecu(this.Page, "grpmtg3")      as WebUIControlDataField;
       WebUIControlDataField ctrlGrpMtg4     = findControlRecu(this.Page, "grpmtg4")      as WebUIControlDataField;
       WebUIControlDataField ctrlGrpMtg5     = findControlRecu(this.Page, "grpmtg5")      as WebUIControlDataField;
       WebUIControlDataField ctrlGrpMtg6     = findControlRecu(this.Page, "grpmtg6")      as WebUIControlDataField;
       WebUIControlDataField ctrlNumMins     = findControlRecu(this.Page, "nummins")      as WebUIControlDataField;

       
       /*-------------------------------
        * Load record id 
        *------------------------------*/ 

       ctrlRecID.value       = pg.id.ToString();

       /*-------------------------------
        * Load labels and data into 
        * steps and data controls
        *------------------------------*/ 
       
       ctrlClientID.value     = pg.clientID.ToString();

       ctrlStep1.label        = pg.pracName;
       ctrlStep1.selectvalue  = pg.pracID.ToString();
	   
       ctrlStep2.label        = pg.name;
       ctrlName.value         = pg.name; 
             
       ctrlStep3.label       = pg.description;
       ctrlDescription.value = pg.description;
    
       ctrlStep4.label        = pg.startDateStr;
       ctrlStartDate.value    = pg.startDateStr;
       ctrlStartDate.hidden   = true;
       ctrlStep4.instructions = "Start date cannot be changed";
       
       ctrlStep5.label       = pg.startTimeStr;
       ctrlStartTime.value   = pg.startTimeStr;
       
       ctrlStep6.label       = pg.grpMtgsStr;
       
       ctrlGrpMtg2.value     = Util.netBoolToJSBool(pg.grpMtg2);
       ctrlGrpMtg3.value     = Util.netBoolToJSBool(pg.grpMtg3);
       ctrlGrpMtg4.value     = Util.netBoolToJSBool(pg.grpMtg4);
       ctrlGrpMtg5.value     = Util.netBoolToJSBool(pg.grpMtg5);
       ctrlGrpMtg6.value     = Util.netBoolToJSBool(pg.grpMtg6);
       
       ctrlStep7.label       = pg.numMins.ToString();
       ctrlNumMins.value     = pg.numMins.ToString();
       
       /*-------------------------------
        * Load labels and data 
        * into entity steps
        *------------------------------*/ 
               
       
       ctrlStep8.multiSelectLoad   = true;         // Tell control we want to load multi values
       ctrlStep8.multiSelectNames  = pg.patNames;
       ctrlStep8.multiSelectValues = pg.patIDsStr;
       ctrlStep8.label             = pg.patNames; 

       /*-------------------------------
        * Set title and 1st step
        *------------------------------*/ 
        
       this.subTitle = WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_EDIT);        
       ctrlSteps.firstStep = 8; // step - 1
      }
           
    }
  }
}
