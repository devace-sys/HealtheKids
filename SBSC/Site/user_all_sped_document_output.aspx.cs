using System;
using System.Collections.Generic;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * UserAllSpEdDocumentOutput */
    /**
     * 
     ***************************************************************************/


    public class UserAllSpEdDocumentOutput : WebUI

    {

        public UserAllSpEdDocumentOutput() : base(  Util.createUniqueID()
                                                  , @""
                                                  , @"user_all_sped_document_output.css"
                                                  , @"user_all_sped_document_output.js"
                                                  , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        

        public SpEdDocumentTemplate spEdDocTemplate { get; set; }
        public Client               client          { get; set; }
        public Patient              pat             { get; set; }
        public string documentName                  { get; set;}

        public string formBuilderQuestionsJSON { get; set;}
        public string formBuilderAnswersJSON   { get; set;}
        public string clientInfoJSON           { get; set;}
        public string patInfoJSON              { get; set;}
        public bool   formBuilderDataLoaded    { get; set;}

        protected void Page_Load(object sender, EventArgs e)
        {
            documentName             = @"";
            formBuilderQuestionsJSON = @"{}";
            formBuilderAnswersJSON   = @"{}";
            clientInfoJSON           = @"{}";
            patInfoJSON              = @"{}";
            formBuilderDataLoaded    = false;

            string dataSourceStr = MBA.HttpApplication.getParameter(Constants.PARM_DATA_SOURCE);
            string clientIDStr   = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string recIDStr      = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            
            int dataSourceVal    = 0;
            int recIDVal         = 0;
      
            if (!int.TryParse(dataSourceStr, out dataSourceVal)) return;
            if (!int.TryParse(recIDStr,      out recIDVal))      return;

            if (dataSourceVal == SpEdDocumentTemplates.SPED_DOCUMENT_DATA_SOURCE_DOCUMENT_TEMPLATE)
            { 
              spEdDocTemplate          = SpEdDocumentTemplates.load(dbConnApp,log,uInfo,recIDVal.ToString());
              documentName             = spEdDocTemplate.name;
              formBuilderQuestionsJSON = spEdDocTemplate.formBuilderContentJSON;
              formBuilderAnswersJSON   = @"{}";
              clientInfoJSON           = @"{}";
              patInfoJSON              = @"{}";
              formBuilderDataLoaded    = true;
            }

            else if (dataSourceVal == SpEdDocumentTemplates.SPED_DOCUMENT_DATA_SOURCE_PATIENT_CURRENT_OR_WIP_SPED_DATA)
            { 
              spEdDocTemplate = SpEdDocumentTemplates.getCurrentIEPTemplate(dbConnApp,log,uInfo,clientIDStr);
              client = Clients.load(dbConnApp,log,uInfo,clientIDStr);
              pat    = Patients.load(dbConnApp,log,uInfo,recIDStr);
              documentName             = client.name + @" - " + pat.name + @" - " + pat.CSIS;
              formBuilderQuestionsJSON = spEdDocTemplate.formBuilderContentJSON;
              formBuilderAnswersJSON   = @"{}";
              clientInfoJSON           = MBA.JSON.toJSONString(client);
              patInfoJSON              = MBA.JSON.toJSONString(pat);
              formBuilderDataLoaded    = true;
            }
            else
            {
              documentName             = @"";
              formBuilderDataLoaded    = false;            
            }

            this.subTitle = documentName;

        }
  }
}
