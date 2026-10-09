using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA.Reporting;
using MBA;


namespace Spedmon
{
   /**************************************************************************
    * PatientInfoRequestsPublicFormOption */
   /**
    * 
    * 
    ***************************************************************************/
    public class PatientInfoRequestsPublicFormOption : Entity
    {
       public long      id;  
	   public long      clientID;

       public string    insuranceInfoRequestMessageBodyContentEN;
       public string    insuranceInfoRequestMessageBodyContentES;

       public DateTime  created;
       public long      createdBy;
       public DateTime  lastModified;
       public long      lastModifiedBy;
    }

   /**************************************************************************
    * PatientInfoRequestsPublicFormOptions */
   /**
    * 
    * 
    ***************************************************************************/
    public class PatientInfoRequestsPublicFormOptions: Entities
    {

        public const string URL_WEB_SVC                        = @"patient_info_request_public_form_options.asmx";
        public const string URL_SAVE_REFERAL_OPTION            = URL_WEB_SVC + @"/save";
        public const string URL_LOAD_REFERAL_OPTION            = URL_WEB_SVC + @"/load";

        /***************************************************************************
         * URL_SAVE_REFERAL_OPTION_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_REFERAL_OPTION_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicFormOptions.URL_SAVE_REFERAL_OPTION, true);
        }

        /***************************************************************************
         * URL_LOAD_REFERAL_OPTION_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_LOAD_REFERAL_OPTION_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicFormOptions.URL_LOAD_REFERAL_OPTION, true);
        }

       
        /***************************************************************************
         * save */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveOrReplaceRecord save(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID
                                                       , string insuranceInfoRequestMessageBodyContentEN
                                                       , string insuranceInfoRequestMessageBodyContentES
                                                       , string active
                                                       , string editDelReason
                                                       , string validateRec
                                                       , string saveType)
        {

            var parms = new List<SqlParameter>();

            string saveSproc = "PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_SAVE";

            long vClientID                              = Validate.reqClientID(uInfo, clientID);
            string vinsuranceInfoRequestMessageBodyContentEN = Validate.optString(insuranceInfoRequestMessageBodyContentEN, @"Invalid insuranceInfoRequestMessageBodyContentEN");
            string vinsuranceInfoRequestMessageBodyContentES = Validate.optString(insuranceInfoRequestMessageBodyContentES, @"Invalid insuranceInfoRequestMessageBodyContentES");


            parms.Add(Database.SqlParm("@clientID",                             SqlDbType.BigInt,   vClientID,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@insuranceInfoRequestMessageBodyContentEN",             SqlDbType.VarChar, vinsuranceInfoRequestMessageBodyContentEN,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@insuranceInfoRequestMessageBodyContentES",             SqlDbType.VarChar, vinsuranceInfoRequestMessageBodyContentES,      ParameterDirection.Input));

            ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord(connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveSproc
                                             , ref parms
                                             , delegate () { });

            return so;

        }       

       
        
        /***************************************************************************
         * view */
        /**
         * 
         **************************************************************************/
        protected static ReturnDB view (  SqlConnection connSpedmon
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , int           recViewType
                                        , string        clientID     
                                        , bool          pagedOrTop
                                        , string        canEdit
                                        , string        active
                                        , string        dataSource
                                        , defineCols    dc)
        {
            
            long     vClientID                       = Validate.reqClientID                (uInfo, clientID);
            
            string viewUDF = "PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @active)";

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
           
                            
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, "-1", canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
        * load */
        /**
         * 
         ***************************************************************************/
        public static PatientInfoRequestsPublicFormOption load(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID)
        {
            return (PatientInfoRequestsPublicFormOption)Entities.load(connSpedmon, log, uInfo, typeof(PatientInfoRequestsPublicFormOption),
            delegate {
            return PatientInfoRequestsPublicFormOptions.view(   connSpedmon
                                            , log
                                            , uInfo
                                            , Entities.REC_VIEW_LOAD
                                            , clientID
                                            , false
                                            , ""
                                            , "Y" /* Active */
                                            , ""
                                            , null);
            }
          );
        }

        /***************************************************************************
        * get */
        /**
         *
         **************************************************************************/

        public static ReturnEntity get(SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string clientID)
        {
            var so = new ReturnEntity();
            so.entity = PatientInfoRequestsPublicFormOptions.load(connSpedmon, log, uInfo, clientID);
            return so;
        }
    }
}