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
   * sbs_all_client_pbs_documentation_save */
  /**
   * 
   ***************************************************************************/   

  public class sbs_all_client_pbs_documentation_save : WebUI
  {

    public int saveType = 0;    
    
    public sbs_all_client_pbs_documentation_save() : base ( 
        @"sbs_all_client_pbs_documentation_save"
      , WebUI.CreatePageSubTitle(   ClientPBSDocumentation.SEL_LABEL
                                  , ClientPBSDocumentation.SEL_LABEL_NEW)
      , ""
      , ""
      , Constants.ROLE_SBS_ALL
    ){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      
      /*###########################################################################
        # Get parameters
        ###########################################################################*/  
      
      string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);   
         
      /*###########################################################################
        # Check over save type
        ###########################################################################*/  

      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);   
      if (vSaveType == null)  vSaveType = Constants.SAVE_TYPE_NEW;      
      saveType = (int) vSaveType;

      /*###########################################################################
        # Find controls
        ###########################################################################*/  

      MBA.Steps                                 ctrlSteps             = findControlRecu(this.Page, "save")                     as MBA.Steps;
      MBA.HiddenInput                           ctrlSaveType          = findControlRecu(this.Page, "savetype")                 as MBA.HiddenInput; 
      MBA.HiddenInput                           ctrlRecID             = findControlRecu(this.Page, "recid")                    as MBA.HiddenInput;                 
      MBA.ComboBox                              ctrlClientID          = findControlRecu(this.Page, "clientid")                 as MBA.ComboBox;
	    MBA.SelectPBSDocumentGroupServiceClass    ctrlGrpSvcClassNameID = findControlRecu(this.Page, "groupServiceClassNameID")  as MBA.SelectPBSDocumentGroupServiceClass;
	    MBA.StepSelectPractitioner                ctrlStep3             = findControlRecu(this.Page, "step3")                    as MBA.StepSelectPractitioner;
      MBA.DateBox                               ctrlStartDate         = findControlRecu(this.Page, "startDate")                as MBA.DateBox;
      MBA.DateBox                               ctrlEndDate           = findControlRecu(this.Page, "endDate")                  as MBA.DateBox;
      MBA.TextAreaBox                           ctrlNotes             = findControlRecu(this.Page, "notes")                    as MBA.TextAreaBox;
      
      /*###########################################################################
        # Set control values used regardless of save type
        ###########################################################################*/  

      /*-------------------------------
       * Save type
       *------------------------------*/ 

      ctrlSaveType.value = saveType.ToString();
      
      /*###########################################################################
        #                                EDIT
        # Load record, set control values, step labels, first step, and page title
        ###########################################################################*/  

      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
       
        /*============================================================
         * Load record and exit if not found
         *============================================================*/
         
        ClientPBSDocumentRecord pbs = ClientPBSDocumentation.load(dbConnApp,log,uInfo,"",recid);
        
        /*============================================================
         * Set control values and step labels for edit
         *============================================================*/

        /*-------------------------------
         * RecID and other hidden inputs
         *------------------------------*/ 

        ctrlRecID.value             = pbs.id.ToString();    
                   
        /*-------------------------------
         * Client ID
         *------------------------------*/ 

        ctrlClientID.value      = pbs.clientID.ToString();
        ctrlClientID.selectName = pbs.clientName;
        ctrlClientID.setParentStepLabel();
                
        /*-------------------------------
         * Group family
         *------------------------------*/ 

        ctrlGrpSvcClassNameID.value = pbs.groupServiceClassNameID.ToString();
        ctrlGrpSvcClassNameID.setParentStepLabel(pbs.groupServiceClassName);
        
        /*-------------------------------
         * ORP
         * 
         * Note: This is a custom step
         * control so the value and label
         * load methods are different.
         *------------------------------*/ 
        
        ctrlStep3.label         = pbs.orpPracName;
        ctrlStep3.selectvalue   = pbs.orpPracID.ToString();

        /*-------------------------------
         * Start Date
         *------------------------------*/ 

        ctrlStartDate.value = pbs.startDateStr;
        ctrlStartDate.setParentStepLabel();
        
        /*-------------------------------
         * End Date
         *------------------------------*/ 

        ctrlEndDate.value   = pbs.endDateStr;
        ctrlEndDate.setParentStepLabel();     

        /*-------------------------------
         * Notes
         *------------------------------*/ 

        ctrlNotes.value     = pbs.notes;
        ctrlNotes.setParentStepLabel();
      
        /*============================================================
         * Set first step and page title
         *============================================================*/
         
         ctrlSteps.firstStep = 5;
         this.subTitle = WebUI.CreatePageSubTitle(  ClientPBSDocumentation.SEL_LABEL
                                                  , ClientPBSDocumentation.SEL_LABEL_EDIT);      
      }

      /*###########################################################################
        #                                NEW
        # Set control values, step labels, first step, and page title
        ###########################################################################*/  
      
      else
      {

        /*============================================================
         * Set control values and step labels for new
         *============================================================*/

        /*============================================================
         * Set first step and page title
         *============================================================*/
         
         ctrlSteps.firstStep = 0;
         this.subTitle = WebUI.CreatePageSubTitle(  ClientPBSDocumentation.SEL_LABEL
                                                  , ClientPBSDocumentation.SEL_LABEL_NEW);
      }
                 
    }
  }
}
