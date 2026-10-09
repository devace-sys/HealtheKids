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
// 

namespace Spedmon
{
    /***************************************************************************
     * UserAllPatientAllergySave */
    /**
     *
 	 ***************************************************************************/

    public class UserAllPatientAllergySave : WebUI
    {

        public UserAllPatientAllergySave() : base ( @"user_all_patient_allergy_save"
                                                    , PatientAllergies.SEL_LABEL_ADD_NEW
                                                    , @""
                                                    , @""
                                                    , Constants.ROLE_ALL_PCAL_AND_CLIENT )
        { }

        public int      saveType           = Constants.SAVE_TYPE_NEW;
        public bool     clientAndPatAreOK = true;

        protected void Page_Load(object sender, EventArgs e)
        {
                
            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);            
            string clientid  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);            
            string patid     = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
			
            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;
            
            /*###########################################################################
              # Validate required references (client and prac)
              ###########################################################################*/
            
            clientAndPatAreOK = true;

            try
            { 
              int vClientID = Spedmon.Validate.reqClientID (uInfo, clientid);
              int vPatID    = Spedmon.Validate.reqPatID    (uInfo, patid);
              clientid      = vClientID.ToString();
              patid         = vPatID.ToString();
            }
            catch
            {
              clientAndPatAreOK = false;
            }
            
            if (clientAndPatAreOK == false) return;

            /*###########################################################################
              # Get references to data entry controls 
              ###########################################################################*/
            
            var ctrlClientID      = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)       as MBA.HiddenInput;
            var ctrlPatID         = findControlRecu(this.Page, Constants.PARM_PATIENT_ID)      as MBA.HiddenInput;            
            var ctrlAllergyID     = findControlRecu(this.Page, @"allergyid")                   as MBA.ComboBox;
            var ctrlIsPriority    = findControlRecu(this.Page, @"ispriority")                  as MBA.SelectYesOrNo;
            var ctrlNotes         = findControlRecu(this.Page, @"notes")                       as MBA.DataEntryBoxTextArea;
            var ctrlSaveOrEdit    = findControlRecu(this.Page, "saveOrEdit")                   as MBA.DataEntryRowSaveOrEdit;
                                   
            /*###########################################################################
              # Set recid and save type
              ###########################################################################*/

            ctrlSaveOrEdit.recID    = recid;
            ctrlSaveOrEdit.saveType = saveType;
                     
            /*###########################################################################
              # Add New
              ###########################################################################*/

            if (saveType == Constants.SAVE_TYPE_NEW) {
               
              /*------------------------------------*/
              /* Use passed in client and pat id    */
              /*------------------------------------*/

              ctrlClientID.value  = clientid;
              ctrlPatID.value     = patid;     

              /*------------------------------------*/
              /* Set defaults for priority & notes  */
              /*------------------------------------*/
  
              ctrlIsPriority.setValue(false);
              ctrlNotes.value = @"";

            
            }

            /*###########################################################################
              # Edit
              ###########################################################################*/

            else if (saveType == Constants.SAVE_TYPE_EDIT) {

                /*------------------------------------*/
                /* Change page title                  */
                /*------------------------------------*/

                this.subTitle =  PatientAllergies.SEL_LABEL_EDIT;

                /*------------------------------------*/
                /* Load previously saved record       */
                /*------------------------------------*/

                var rec = PatientAllergies.load (dbConnApp,log,uInfo,clientid,patid,recid);

                /*------------------------------------*/
                /* Set values                         */
                /*------------------------------------*/

                ctrlClientID.value       = rec.clientID.ToString();            
    			ctrlPatID.value          = rec.patID.ToString();
                ctrlAllergyID.value      = rec.allergyID.ToString();
                ctrlAllergyID.selectName = rec.allergyName;
                ctrlIsPriority.setValue(rec.isPriority);
                ctrlNotes.value = rec.notes;
            }

            else {
            
            }


      }
  }
}