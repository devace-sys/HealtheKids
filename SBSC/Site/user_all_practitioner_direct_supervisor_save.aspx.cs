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
   * UserAllRmtsParticipationRosterSave */
  /**
   *
   ***************************************************************************/   

  public class UserAllPractitionerDirectSupervisorSave: WebUI
  {
    
    public PractitionerDirectSupervisor pds = new PractitionerDirectSupervisor();
    
    public UserAllPractitionerDirectSupervisorSave() : base( @"user_all_practitioner_direct_supervisor_save"
	                                                 , @""
                                                     , @"practioner_direct_supervisor.css"
                                                     , @"practioner_direct_supervisor.js"
                                                     , Constants.ROLE_PRAC_DIR_SUP_ADMINS){} 
   
    
                                        
    protected void Page_Load(object sender, EventArgs e)
    {      	    
     
      /*###########################################################################
        # Fetch parameters 
        ###########################################################################*/    
      
      string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
      string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string clientid  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            
      /*###########################################################################
        # Client ID is required in all cases
        ###########################################################################*/    

      var clientIDVal = Spedmon.Validate.reqClientID (uInfo, clientid);
      clientid = clientIDVal.ToString();

      /*###########################################################################
        # Determine save type
        ###########################################################################*/    

      Object vSaveType  = Spedmon.Validate.optInteger (savetype,  Messages.INVALID_SAVE_TYPE);
      int    saveType   = Constants.SAVE_TYPE_NEW;
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType  = (int) vSaveType;
      savetype = saveType.ToString();

      /*###########################################################################
        # Get control references
        ###########################################################################*/    
     
      var ctrlSelectClient               = findControlRecu (this.Page,  "selectClient")                       as MBA.DataEntryRowSelectClient;
      var ctrlSelectSupervisedPrac       = findControlRecu (this.Page,  "selectSupervisedPractitioner")       as MBA.DataEntryRowSelectPractitioner;
      var ctrlSelectSupervisingPracs     = findControlRecu (this.Page,  "selectSupervisingPractioners")       as MBA.DataEntryRowSelectPractitioner;
      var ctrlEditSupervisingPracDetails = findControlRecu (this.Page,  "editSupervisingPractionersDetails")  as MBA.DataEntryRow;     
      var ctrlSupervisingPracsDetails    = findControlRecu (this.Page,  "supervisingpracsdetails")            as MBA.HiddenTextArea;
      var ctrlSaveOrEdit                 = findControlRecu (this.Page,  "saveOrEdit")                         as MBA.DataEntryRowSaveOrEdit;
   
      /*###########################################################################
        # Set save type and rec id
        ###########################################################################*/          

      ctrlSaveOrEdit.saveType = saveType;
      ctrlSaveOrEdit.recID    = recid;
      
      /*###########################################################################
        # New Record
        ###########################################################################*/

      if (saveType == Constants.SAVE_TYPE_NEW)
      { 
        
        /*------------------------------------*/
        /* Load initial data           */
        /*------------------------------------*/
       
        pds = PractitionerDirectSupervisors.loadInitialData (dbConnApp,log,uInfo,clientid); 

        /*------------------------------------*/
        /* Allow practitoners to select the   */
        /* supervised practitioner            */
        /*------------------------------------*/

        ctrlSelectSupervisedPrac.entryAllowed                        = true;
        ctrlSelectSupervisedPrac.entryNotAllowedUseReplacementValue  = false;
         
        /*------------------------------------*/
        /* Set subtitle                       */
        /*------------------------------------*/
    
        this.subTitle = WebUI.CreatePageSubTitle (   PractitionerDirectSupervisors.SEL_LABEL
                                                   , PractitionerDirectSupervisors.SEL_LABEL_ADD_NEW
                                                   , pds.clientName);
      }
       
       else if ( saveType == Constants.SAVE_TYPE_EDIT)
       {

         /*------------------------------------*/
         /* Load                               */
         /*------------------------------------*/
      
         pds = PractitionerDirectSupervisors.load(dbConnApp,log,uInfo,clientid,recid); 
       
         /*------------------------------------*/
         /* Hide supervised practitioner and   */
         /* prevent override of data           */
         /*------------------------------------*/

         ctrlSelectSupervisedPrac.entryInitiallyHidden                = true;
         ctrlSelectSupervisedPrac.entryAllowed                        = true;
         ctrlSelectSupervisedPrac.entryNotAllowedUseReplacementValue  = false;

         /*------------------------------------*/
         /* Set subtitle                       */
         /*------------------------------------*/

         this.subTitle = WebUI.CreatePageSubTitle (  PractitionerDirectSupervisors.SEL_LABEL
                                                   , PractitionerDirectSupervisors.SEL_LABEL_EDIT
                                                   , pds.pracName
                                                   , pds.clientName
                                                   );                         

       }

       /*###########################################################################
         # Populate fields
         ###########################################################################*/      
       
       ctrlSelectClient.selectValue         = pds.clientID.ToString();
       ctrlSelectClient.selectName          = pds.clientName;       
       ctrlSelectSupervisedPrac.selectValue = (pds.pracID == 0) ? "" : pds.pracID.ToString();
       ctrlSelectSupervisedPrac.selectName  = pds.pracName;       
       ctrlSupervisingPracsDetails.value    = pds.supervisingPracDetailsJSON;

       /*###########################################################################
         # Prevent entry in these controls
         ###########################################################################*/      

       ctrlSelectClient.entryAllowed = false;
      
    }
  }
}