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
using System.Collections.Generic;

namespace Spedmon
{
    /***************************************************************************
     * UserAllCarePlanSave */
    /**
     *
     ***************************************************************************/

    public class UserAllCarePlanSave : WebUI
    {
      public string   ordersEditUrl         = ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW;
      public string   profilesEditUrl       = ServiceJournals.URL_COOR_SAVE_SERVICE_DESCRIPTION;
      public string   patientPersonsSaveUrl = PatientPersons.URL_USER_ALL_SAVE;
      public MBA.User userInfo            = new MBA.User();
      public string   userPrevSignature = "";
      public string   patCarePlansJSON = "";
      public Patient  selectedPat; 
      public string   patID;
      public bool     patHasPlan = false;

      public UserAllCarePlanSave() : base (     @"user_all_care_plan_save"
                                               , "Manage Care Plan"
                                               , @"user_all_care_plan_save.css"
                                               , @"user_all_care_plan_save.js"
                                               , Constants.ROLE_CARE_PLAN_WRITER)
      {} 
   
    
                                        
    protected void Page_Load(object sender, EventArgs e)
    {      	    
      
       /*###########################################################################
         # Get client id and practitioner id from user data
         ###########################################################################*/
            
        var clientIDVal = uInfo.userClientID;
        var clientid    = clientIDVal.ToString();

        // if patient id is passed 
        patID       = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

        /*###########################################################################
        # Get control references
        ###########################################################################*/

        DataEntryRowSelectClient  ctrlClientid                     = findControlRecu (this.Page, "selectClient"   )  as MBA.DataEntryRowSelectClient;
        DataEntryRowSelectPatient ctrlSelectPatient                = findControlRecu (this.Page, "selectPatient")  as MBA.DataEntryRowSelectPatient;

        /*###########################################################################
         # Load data into controls
         ###########################################################################*/

        // for staff check if patient passed in
        if (!String.IsNullOrEmpty(patID) && patID != "0")
        {
            // load patient and client
            selectedPat = Patients.load(dbConnApp, log, uInfo, patID);
            Client  c = Clients.load (dbConnApp, log, uInfo, selectedPat.clientID.ToString());
            
            // load patient's careplans
            List<PlanWriterPlanJSON> patCarePlansList = PlanWriterPlans.viewListJSON(dbConnApp, log, uInfo, selectedPat.clientID.ToString(), patID, "Y");

            // if patient has any plans, set the patHasPlan flag
            if (patCarePlansList.Count > 0)
            {
                patHasPlan = true;
            }

            // set control values
            ctrlClientid.selectValue  = selectedPat.clientID.ToString();
            ctrlClientid.selectName   = c.name;
            ctrlSelectPatient.selectValue  = selectedPat.id.ToString();
            ctrlSelectPatient.selectName   = selectedPat.name;
        }
        else if (clientIDVal != 0) {
            ctrlClientid.selectValue  = clientid;

            /*###########################################################################
            # Paid service access check
            ###########################################################################*/
            PlanWriterRecords.validateClientAccessForPage (  dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientid
                                                        , Response
                                                        , Context );
        }

        /*###########################################################################
          # Load the logged in user's info (to be used in the plan participants table)
          ###########################################################################*/

        userInfo = Users.load(dbConnApp, log, uInfo, uInfo.useridStr);

        /*###########################################################################
          # Load the logged in user's previous signature (to be used in the plan participants table)
          ###########################################################################*/
        try { 
            userPrevSignature = UserSignatures.loadN(dbConnUser, log, uInfo, 0, userInfo.id.ToString(), null, null).signatureBase64;
        } catch (Exception err) { 
            userPrevSignature = "";
        }
    }
  }
}