using System;
using System.Web;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * UserAllImportFromPatientGoalRecords */
    /**
     *
     **************************************************************************/

    public class UserAllImportFromPatientGoalRecords : WebUI
    {
        public UserAllImportFromPatientGoalRecords() : base(Util.createUniqueID()
                                                            , ImportFromPatientGoalRecords.SEL_LABEL_IMPORT
                                                            , @"user_all_import_from_patient_goal_records.css"
                                                            , @""
                                                            , Constants.ROLE_ADMIN
                                                          ) { }


        public string structuredDataProfileSet = String.Empty;


        /***************************************************************************
         * Page_Load */
        /**
         *
         **************************************************************************/

        protected void Page_Load(object sender, EventArgs e)
        {

            /*###########################################################################
             # Get control references
             ###########################################################################*/

            var ctrlClientID = findControlRecu(this.Page, "selectClient")as MBA.DataEntryRowSelectClient;


            /*###########################################################################
             # Get structured data profile set
             ###########################################################################*/

            structuredDataProfileSet = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(ImportFromPatientGoalRecords.STRUCTURED_DATA_IMPORT_PROFILES_FILE);


            /*###########################################################################
             # Get parameters
             ###########################################################################*/

            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);


            /*###########################################################################
             # Preselect client if passed
             ###########################################################################*/

            if (!String.IsNullOrEmpty(clientIDStr))
            {

                var client = Clients.load(dbConnApp, log, uInfo, clientIDStr);
                ctrlClientID.selectName = client.name;
                ctrlClientID.selectValue = clientIDStr;
            }

        }

    }

}