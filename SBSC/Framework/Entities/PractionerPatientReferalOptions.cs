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
    * PractionerPatientReferalOption */
   /**
    * 
    * 
    ***************************************************************************/
    public class PractionerPatientReferalOption : Entity
    {
       public long      id;  
	   public long      clientID;

       public long      userIDForAllRoutineNotifications1;
	   public long      userIDForAllRoutineNotifications2;
	   public long      userIDForAllRoutineNotifications3;
	   public long      userIDForAllUrgentNotifications1;
	   public long      userIDForAllUrgentNotifications2;
	   public long      userIDForAllUrgentNotifications3;
	   public long      userIDForAllCrisisNotifications1;
	   public long      userIDForAllCrisisNotifications2;
	   public long      userIDForAllCrisisNotifications3;
       public string    englishYesMessageTemplate;
       public string    spanishYesMessageTemplate;
       public string    englishNoMessageTemplate;
       public string    spanishNoMessageTemplate;

       public string    personNameForAllRoutineNotifications1;
	   public string    personNameForAllRoutineNotifications2;
	   public string    personNameForAllRoutineNotifications3;
	   public string    personNameForAllUrgentNotifications1;
	   public string    personNameForAllUrgentNotifications2;
	   public string    personNameForAllUrgentNotifications3;
	   public string    personNameForAllCrisisNotifications1;
	   public string    personNameForAllCrisisNotifications2;
	   public string    personNameForAllCrisisNotifications3;

       public DateTime  created;
       public long      createdBy;
       public DateTime  lastModified;
       public long      lastModifiedBy;
    }

   /**************************************************************************
    * PractionerPatientReferalOptions */
   /**
    * 
    * 
    ***************************************************************************/
    public class PractionerPatientReferalOptions: Entities
    {

        public const string URL_WEB_SVC                        = @"practitioner_patient_referal_options.asmx";
        public const string URL_SAVE_REFERAL_OPTION            = URL_WEB_SVC + @"/save";
        public const string URL_LOAD_REFERAL_OPTION            = URL_WEB_SVC + @"/loadreferaloptions";

        /***************************************************************************
         * URL_MANAGE_REFERRALL_OPTIONS */
        /**
         * 
         **************************************************************************/
        public static string URL_MANAGE_REFERRALL_OPTIONS (string clientID)
        {
            return MBA.HttpApplication.createLink(  PractitionerPatientReferrals.URL_USER_REF_OPTION_MANAGE
                                                   , true
                                                   , new NameValue(Constants.PARM_CLIENT_ID, clientID)
                                                   , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                   );
        }

        /***************************************************************************
         * URL_SAVE_REFERAL_OPTION_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_REFERAL_OPTION_BASE()
        {
            return MBA.HttpApplication.createLink(PractionerPatientReferalOptions.URL_SAVE_REFERAL_OPTION, true);
        }

        /***************************************************************************
         * URL_LOAD_REFERAL_OPTION_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_LOAD_REFERAL_OPTION_BASE()
        {
            return MBA.HttpApplication.createLink(PractionerPatientReferalOptions.URL_LOAD_REFERAL_OPTION, true);
        }

        /***************************************************************************
         * userCanAccessManageScreen */
        /**
         **************************************************************************/

        public static bool userCanAccessManageScreen (RequestResponse rd)
        {
            if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) {
              return true;
            }
            else if (rd.wu.usr.roleID == Constants.ROLE_CYBHI_CORDINATOR_ID) { 
              return true;
            }
            else if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
                if (rd.wu.pr.isAParaProfessional == true) return false;          
                if (rd.wu.pr.deptHead            == true) return true;
                return false;
            }
            return false;
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
                                                       , string userIDForAllRoutineNotifications1
                                                       , string userIDForAllRoutineNotifications2
                                                       , string userIDForAllRoutineNotifications3
                                                       , string userIDForAllUrgentNotifications1
                                                       , string userIDForAllUrgentNotifications2
                                                       , string userIDForAllUrgentNotifications3
                                                       , string userIDForAllCrisisNotifications1
                                                       , string userIDForAllCrisisNotifications2
                                                       , string userIDForAllCrisisNotifications3
                                                       , string englishYesMessageTemplate
                                                       , string spanishYesMessageTemplate
                                                       , string englishNoMessageTemplate
                                                       , string spanishNoMessageTemplate
                                                       , string active
                                                       , string editDelReason
                                                       , string validateRec
                                                       , string saveType)
        {

            var parms = new List<SqlParameter>();

            string saveSproc = "PRACTITIONER_PATIENT_REFERRAL_OPTIONS_SAVE";

            long vClientID                              = Validate.reqClientID(uInfo, clientID);
            object vUserIDForAllRoutineNotifications1   = Validate.optInteger(userIDForAllRoutineNotifications1, @"Invalid userIDForAllRoutineNotifications1",true);
            object vUserIDForAllRoutineNotifications2   = Validate.optInteger(userIDForAllRoutineNotifications2, @"Invalid userIDForAllRoutineNotifications2", true);
            object vUserIDForAllRoutineNotifications3   = Validate.optInteger(userIDForAllRoutineNotifications3, @"Invalid userIDForAllRoutineNotifications3", true);
            object vUserIDForAllUrgentNotifications1    = Validate.optInteger(userIDForAllUrgentNotifications1, @"Invalid userIDForAllUrgentNotifications1", true);
            object vUserIDForAllUrgentNotifications2    = Validate.optInteger(userIDForAllUrgentNotifications2, @"Invalid userIDForAllUrgentNotifications2", true);
            object vUserIDForAllUrgentNotifications3    = Validate.optInteger(userIDForAllUrgentNotifications3, @"Invalid userIDForAllUrgentNotifications3", true);
            object vUserIDForAllCrisisNotifications1    = Validate.optInteger(userIDForAllCrisisNotifications1, @"Invalid userIDForAllCrisisNotifications1", true);
            object vUserIDForAllCrisisNotifications2    = Validate.optInteger(userIDForAllCrisisNotifications2, @"Invalid userIDForAllCrisisNotifications2", true);
            object vUserIDForAllCrisisNotifications3    = Validate.optInteger(userIDForAllCrisisNotifications3, @"Invalid userIDForAllCrisisNotifications3", true);
            string vEnglishYesMessageTemplate            = Validate.optString(englishYesMessageTemplate, @"Invalid englishYesMessageTemplate");
            string vSpanishYesMessageTemplate            = Validate.optString(spanishYesMessageTemplate, @"Invalid spanishYesMessageTemplate");
            string vEnglishNoMessageTemplate             = Validate.optString(englishNoMessageTemplate, @"Invalid englishNoMessageTemplate");
            string vSpanishNoMessageTemplate             = Validate.optString(spanishNoMessageTemplate, @"Invalid spanishNoMessageTemplate");


            parms.Add(Database.SqlParm("@clientID",                             SqlDbType.BigInt,   vClientID,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllRoutineNotifications1",    SqlDbType.BigInt,   vUserIDForAllRoutineNotifications1,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllRoutineNotifications2",    SqlDbType.BigInt,   vUserIDForAllRoutineNotifications2,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllRoutineNotifications3",    SqlDbType.BigInt,   vUserIDForAllRoutineNotifications3,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllUrgentNotifications1",     SqlDbType.BigInt,   vUserIDForAllUrgentNotifications1,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllUrgentNotifications2",     SqlDbType.BigInt,   vUserIDForAllUrgentNotifications2,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllUrgentNotifications3",     SqlDbType.BigInt,   vUserIDForAllUrgentNotifications3,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllCrisisNotifications1",     SqlDbType.BigInt,   vUserIDForAllCrisisNotifications1,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllCrisisNotifications2",     SqlDbType.BigInt,   vUserIDForAllCrisisNotifications2,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userIDForAllCrisisNotifications3",     SqlDbType.BigInt,   vUserIDForAllCrisisNotifications3,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@englishYesMessageTemplate",            SqlDbType.VarChar,   vEnglishYesMessageTemplate,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spanishYesMessageTemplate",            SqlDbType.VarChar,   vSpanishYesMessageTemplate,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@englishNoMessageTemplate",             SqlDbType.VarChar,   vEnglishNoMessageTemplate,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spanishNoMessageTemplate",             SqlDbType.VarChar,   vSpanishNoMessageTemplate,      ParameterDirection.Input));

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
            
            string viewUDF = "PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @active)";

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
           
                            
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, "-1", canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
        * load */
        /**
         * 
         ***************************************************************************/
        public static PractionerPatientReferalOption load(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID)
        {
            return (PractionerPatientReferalOption)Entities.load(connSpedmon, log, uInfo, typeof(PractionerPatientReferalOption),
            delegate {
            return PractionerPatientReferalOptions.view(   connSpedmon
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
            so.entity = PractionerPatientReferalOptions.load(connSpedmon, log, uInfo, clientID);
            return so;
        }
    }
}