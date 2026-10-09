using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
  
  /***************************************************************************
   * PatientCurrentMcalBenefits */
  /** 
   ***************************************************************************/
    public class PatientCurrentMcalBenefits : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"name asc";

        public long     clientID;
        public long     patID;
        public DateTime dob;        
        public string   dobStr;        
        public int      patCurrentAge;        
        public string   patStudentID;        
        public string   patSSID;        
        public string   patBIC;        
        public DateTime latestDateMcalElig;        
        public string   latestDateMcalEligStr;        
        public string   latestDateMCALEligStrMoYr;        
        public int      lastEligibleForMcalMonthsAgo;        
        public bool?    currentParentConsentStatusVal;        
        public string   currentParentConsentStatusStr;        
        public DateTime currentParentConsentStatusEffDate;        
        public string   currentParentConsentStatusEffDateStr;        
        public string   currentParentConsentStatusEffDateNotes;        
        public bool     currentParentConsentStatusIsUnknown;        
        public string   pgContacts;
        public int      currentBenefitsStatusCode;
        public string   currentBenefitsStatusName;
        public string   currentSiteName;
        public string   spEdCaseManagerName;
	    public string   altFormat;
	    public bool     hasAltFormat;
    }

    /***************************************************************************
     * PatientsCurrentMcalBenefits */
    /** 
     ***************************************************************************/

    public class PatientsCurrentMcalBenefits : Entities
    {
        public const string SEL_LABEL_MANAGE         = @"Manage Medi-Cal Benefits";
        public const string URL_MANAGE               = @"user_all_patients_current_mcal_benefits_manage.aspx";
        public const string MENU_LNK_USER_ALL_MANAGE = @"patientscurrentmcalbenefitsmanagelnk";
        public const string URL_WEB_REPORT           = @"patients_current_mcal_benefits.ashx";
        public const string URL_REST_VIEW            = @"api/v1/patientscurrentmcalbenefits";
        public const string URL_SVC_BASE             = @"patients_current_mcal_benefits.asmx/";

        public const string MCAL_CURRENT_TAB_ID = @"1";
        public const string MCAL_EXPIRED_TAB_ID = @"2";        
        public const string UNKNOWN_TAB_ID      = @"3";        

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PatientsCurrentMcalBenefits.URL_REST_VIEW, true);
        }        
        
        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientsCurrentMcalBenefits.URL_MANAGE, true);
        }

        /***************************************************************************
        * URL_WEB_REPORT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(PatientsCurrentMcalBenefits.URL_WEB_REPORT, true);

        }

        /***************************************************************************
         * URL_SVC_UPDATE_OUTREACH_NOTES_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_UPDATE_OUTREACH_NOTES_BASE()
        {
          return MBA.HttpApplication.createLink(URL_SVC_BASE + @"updateoutreachnotes", true);
        }

        /***************************************************************************
         * updateOutreachNotes */
        /** 
         ***************************************************************************/
        public static ReturnSaveRecord updateOutreachNotes ( 
            SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string recID, string notes )
        {
          
           /* recID is actually patient id*/

           var parms = new List<SqlParameter>();

           int      vClientID  = Validate.reqClientID  (uInfo, clientID);
           string   vNotes     = Validate.optString    (notes, @"Invalid notes");
      
           parms.Add(MBA.Database.SqlParm("@clientID",      SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
           parms.Add(MBA.Database.SqlParm("@notes",         SqlDbType.VarChar, vNotes,                ParameterDirection.Input, -1));
            
           return recordOp (  connSpedmon
                            , log
                            , uInfo
                            , ""
                            , "0"
                            , recID.ToString()
                            , "[dbo].[PATIENT_MCAL_OUTREACH_NOTES_SAVE]"
                            , ref parms );

        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
        public static ReturnDB view(SqlConnection connSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string clientID
                                 , string currentBenefitStatusCode
                                 , string patID
                                 , string hasAltFormat
                                 , defineCols dc)
        {

            string viewUDF = "dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW (@userID, @userGroup, @userRank, @clientID, @currentBenefitStatusCode, @patID, @recID, @hasAltFormat)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID                 = Validate.optClientID      (uInfo                   , clientID);
            var vCurrentBenefitStatusCode = Validate.optInteger       (currentBenefitStatusCode, @"Invalid status code");
            var vPatID                    = Validate.optInteger       (patID,                    Messages.INVALID_PAT_ID);
            var vHasAltFormat             = Validate.optFlagYNUnknown (hasAltFormat,             Messages.INVALID_FLAG);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                , SqlDbType.BigInt, vClientID                , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@currentBenefitStatusCode", SqlDbType.Int   , vCurrentBenefitStatusCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID"                   , SqlDbType.BigInt, vPatID                   , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasAltFormat"            , SqlDbType.Bit,    vHasAltFormat            , ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string currentBenefitStatusCode
                                                  , string patID
                                                  , string hasAltFormat)
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientCurrentMcalBenefits.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientCurrentMcalBenefits)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientsCurrentMcalBenefits.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , currentBenefitStatusCode
                                                                       , patID
                                                                       , hasAltFormat
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
        * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool paged
                                                   , string pageNumber
                                                   , string canEdit
                                                   , string active
                                                   , string clientID
                                                   , string currentBenefitStatusCode
                                                   , string patID
                                                   , string hasAltFormat
        )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("name                      as [Student Name]", true);
                ss.addDisplayColumn("dobStr                    as [Date of Birth]");
                ss.addDisplayColumn("patStudentID              as [Student ID]");
                ss.addDisplayColumn("patSSID                   as [SSID]");
                ss.addDisplayColumn("currentSiteName           as [School Site]");
                ss.addDisplayColumn("spEdCaseManagerName       as [Case Manager]");
                ss.addDisplayColumn("altFormat                 as [Alternative Format]");
                ss.addDisplayColumn("patBIC                    as [BIC/Member #]");
                ss.addDisplayColumn("currentBenefitsStatusName as [Current\nEligibility\nStatus]");
                ss.addDisplayColumn("latestDateMcalEligStr     as [Last Eligible]");
                ss.addDisplayColumn("pgContacts                as [Parent/Guardian Contacts]");
                ss.addDisplayColumn("notes                     as [Outreach Notes]");
                
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return PatientsCurrentMcalBenefits.view(connSpedmon
                                                      , log
                                                      , uInfo
                                                      , Entities.REC_VIEW_TBL
                                                      , paged
                                                      , pageNumber
                                                      , canEdit
                                                      , active
                                                      , clientID
                                                      , currentBenefitStatusCode
                                                      , patID
                                                      , hasAltFormat
                                                      , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName = SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }

    }
}
