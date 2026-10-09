using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MBA;

namespace Spedmon
{
    public class UserAllSvcRecVisionHearingScreen : WebUI
    {
        public UserAllSvcRecVisionHearingScreen() : base(@"user_all_svc_rec_vision_hearing_screen"
                                                    , ServiceRecords.SEL_LABEL_VISION_HEARING_SCREEN
                                                    , @"user_all_svc_rec_vision_hearing_screen.css"
                                                    , @"user_all_svc_rec_vision_hearing_screen.js"
                                                    , Constants.ROLE_SVC_REC_VISION_HEARING_MASS_SCREEN)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
     
            /*###########################################################################
              # Get control references
              ###########################################################################*/    
     
            //var ctrlSelectClient                       = findControlRecu (this.Page, "selectClient")                       as MBA.DataEntryRowSelectClient;
            //var ctrlSelectVisionPractitioner           = findControlRecu (this.Page, "SelectVisionPractitioner")           as MBA.DataEntryRowSelectPractitioner;
            //var ctrlSelectHearingPractitioner          = findControlRecu (this.Page, "selectHearingPractitioner")          as MBA.DataEntryRowSelectPractitioner;
            //var ctrlSelectIndividualPatient            = findControlRecu (this.Page, "selectIndividualPatient")            as MBA.DataEntryRowSelectPatient;
            //var ctrlSelectServiceType                  = findControlRecu (this.Page, "selectServiceType")                  as MBA.DataEntryRow;

            var ctrlEnterSvcNotes                      = findControlRecu (this.Page, "enterSvcNotes")                      as MBA.DataEntryRow;
            var ctrlSelectReference                    = findControlRecu (this.Page, "selectReference")                    as MBA.DataEntryRow;
            var ctrlServiceTypesJSON                   = findControlRecu(this.Page, "servicetypesjson")                    as MBA.HiddenTextArea;
            var ctrlSaveOrEdit                         = findControlRecu (this.Page, "saveOrEdit")                         as MBA.DataEntryRowSaveOrEdit;
   
            /*###########################################################################
            # Set save type and rec id
            ###########################################################################*/          

            ctrlSaveOrEdit.saveType = Constants.SAVE_TYPE_NEW;
            ctrlSaveOrEdit.recID    = "";

           /*###########################################################################
             # hide fields based on role
             ###########################################################################*/

            if (uInfo.pcalStaff == false)
            {
              ctrlSelectReference.entryInitiallyHidden = true;
              ctrlEnterSvcNotes.entryInitiallyHidden   = false;
            }
           
            else
            {
              ctrlSelectReference.entryInitiallyHidden = false;
              ctrlEnterSvcNotes.entryInitiallyHidden   = true;
       
            }

            /*########################################################################### 
              # Initiate fields
              ###########################################################################*/

            ctrlServiceTypesJSON.value = "{\"vision\":false, \"hearingthreshold\":false, \"hearingpuretone\":false}";
            
           // ctrlSelectVisionPractitioner.entryAllowed                        = true;
           // ctrlSelectVisionPractitioner.entryNotAllowedUseReplacementValue  = false;
           // ctrlSelectHearingPractitioner.entryAllowed                       = true;
           // ctrlSelectHearingPractitioner.entryNotAllowedUseReplacementValue = false;

           
        }
    }
}