using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using Newtonsoft.Json.Linq;
using MBA;

namespace Spedmon
{
    public class SBSAllSvcRecMultiPracPatSaveAll : WebUI
    {
        public SBSAllSvcRecMultiPracPatSaveAll() : base (   "sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc"
                                                          , ServiceRecords.SEL_LABEL_SVC_REC_SAVE_NEW_ALL
                                                          , "sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.css"
                                                          , ""
                                                          , Constants.ROLE_SBS_ALL)
        { }

        public string attendanceSelectionsJSON          = @"[]";        
        public string urlOrdersPrescriptionsManage      = @"";
        public string dos                               = "";
        public int    svcetrmdeInt                      = 0;
       
        public bool   showSvcsForLeaBop                 = true;
        public bool   showSvcsForLeaBopNonSpEd          = true;
        public bool   showSvcsForCYBHI                  = false;  /* TODO: Enable once we have support added for billing program for qforms */
        public bool   showSvcsForRUHealth               = false;

        public string serviceNamesListDataSourcesJSON   = @"[]";
        

        protected void Page_Load(object sender, EventArgs e)
        {
            this.includeBackgroundLayer = false; /* TODO: Consider change to true when controls that do not have enough contrast are restyled*/
                      
            /*###########################################################################
              # Get control references
              ###########################################################################*/

            var ctrlReference                       = findControlRecu(this.Page, "reference")      as MBA.DataEntryBoxText;
            var ctrlDataEntryRowSelectClient        = findControlRecu(this.Page, "selectClient")   as MBA.DataEntryRowSelectClient;
            var ctrlDosHidden                       = findControlRecu(this.Page, "dosHidden")      as MBA.HiddenInput;
            var ctrlSvcetrmde                       = findControlRecu(this.Page, "svcetrmde")      as MBA.HiddenInput;
                                                     
            /*###########################################################################
              # Get parameters 
              ###########################################################################*/
            
            var clientid  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID); 
            var reference = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_FILE_REFERENCE); 

            /*###########################################################################
              # Preload client if clientid is passed and valid
              ###########################################################################*/

            var clientidval = Spedmon.Validate.optClientID (uInfo, clientid);
            if (clientidval != null) clientid = clientidval.ToString();            

            if (!String.IsNullOrWhiteSpace(clientid)) { 
              var clc = Clients.load(dbConnApp,log,uInfo,clientid);
              ctrlDataEntryRowSelectClient.selectValue = clc.id.ToString();
              ctrlDataEntryRowSelectClient.selectName =  clc.name;
            }

            /*###########################################################################
              # Preload batch file reference if its passed
              ###########################################################################*/
            
            if (!String.IsNullOrWhiteSpace(reference)) {
                reference = reference.Replace(".pdf","");
                ctrlReference.value = reference;
            }
            else {
                ctrlReference.value = "";
            }

            /*###########################################################################
              # Get attendance selections JSON (will be used in data grid) 
              ###########################################################################*/

            attendanceSelectionsJSON = ServiceRecordAttendanceSelections.generateNvpValuesJSON(dbConnApp, log, uInfo);
                  
           /*###########################################################################
             # Set svc record entry mode
             ###########################################################################*/

            svcetrmdeInt = Constants.SVCETRMDE_RECORD_SERVICES;
            ctrlSvcetrmde.value = svcetrmdeInt.ToString();

           /*###########################################################################
             # Set date of service
             ###########################################################################*/

            DateTime dosVal = DateTime.Now;
            dos = dosVal.ToString("yyyy-MM-dd"); /* HTML5 friendly format */
            ctrlDosHidden.value = dos;
                    
           /*###########################################################################
             # Get service name list data sources user can pick from
             ###########################################################################*/

           serviceNamesListDataSourcesJSON = Services.viewJSONOfSvcNameListDataSources (
                showSvcsForLeaBop
              , showSvcsForLeaBopNonSpEd
              , showSvcsForCYBHI
              , showSvcsForRUHealth );

           /*###########################################################################
             # Setup any supporting urls
             ###########################################################################*/

           urlOrdersPrescriptionsManage = MBA.HttpApplication.createLink(  ORPDocuments.URL_USER_ALL_MANAGE
                                                                         , true
                                                                         , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));

            
           
            
        }
    }
}