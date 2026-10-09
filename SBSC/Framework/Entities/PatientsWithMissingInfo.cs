using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientWithMissingInfo */
    /**
     * Represents an student that has some key info missing
     ***************************************************************************/
	public class PatientWithMissingInfo : Entity
    {
        public static string DEFAULT_PAGING_ORDER = "hasCurrentInfoRequestWaitingForReview desc, hasCurrentInfoRequest asc, patName asc";

        public long     clientID;
        public long     patID;
        public string   patName;
        public string   dobStr;
        public string   ssid;
        public string   siteName;
        public string   studentID;
        public string   grade;
        public int      numSvcRecs;

        public bool     missingAddressInfo;
        public string   missingAddressInfoStr;
        public bool     missingInsuranceInfo;
        public string   missingInsuranceInfoStr;
        public bool     missingFerpaConsent;
        public string   missingFerpaConsentStr;
        public bool     missingPGEmails;
        public string   missingPGEmailsStr;
        public bool     missingMcalParentConsent;
        public string   missingMcalParentConsentStr;

        public bool     hasInsuranceButPlanIsNotSupportedByCYBHI;

        public bool     hasCurrentInfoRequest;
        public bool     hasCurrentInfoRequestWaitingForReview;

        public long     currentInfoRequestID;  
        public string   currentInfoRequestPublicToken;
        public bool     currentInfoRequestRequestSent;
        public DateTime currentInfoRequestSentOn;
        public string   currentInfoRequestSentOnStr;
        public string   currentInfoRequestSentToJSON;
        public bool     currentInfoRequestResponseReceived;  
        public DateTime currentInfoRequestResponseReceivedOn;
        public string   currentInfoRequestResponseReceivedOnStr;        
        public string   currentInfoRequestResponsePolicyHolderFirstName;
        public string   currentInfoRequestResponsePolicyHolderLastName;
        public string   currentInfoRequestResponsePolicyNumber;
        public string   currentInfoRequestResponseGroupNumber;
        public string   currentInfoRequestResponseInsuranceCarrierName;
        public string   currentInfoRequestResponseInsuranceCarrierOtherName;
        public string   currentInfoRequestResponseResponderName;        
        public bool     currentInfoRequestResponseResponderConsent;
        public string   currentInfoRequestResponseResponderConsentStr;
        public bool     currentInfoRequestResponseHasResponderSignatureImgData;
        public string   currentInfoRequestResponseResponderSignatureImgData;        
        public bool     currentInfoRequestResponseNoInsuranceOptionSelected;
        public bool     currentInfoRequestResponseOtherInsuranceOptionSelected;
        
        public bool     hasPreviousInfoRequestThatRequiredReview;
        public long     prevInfoRequestThatRequiredReviewID;
        public DateTime prevInfoRequestResponseReceivedOn;
        public string   prevInfoRequestResponseReceivedOnStr;        
        public string   prevInfoRequestResponsePolicyHolderFirstName;
        public string   prevInfoRequestResponsePolicyHolderLastName;
        public string   prevInfoRequestResponsePolicyNumber;
        public string   prevInfoRequestResponseGroupNumber;
        public string   prevInfoRequestResponseInsuranceCarrierName;
        public string   prevInfoRequestResponseInsuranceCarrierOtherName;
        public string   prevInfoRequestResponseResponderName;        
        public bool     prevInfoRequestResponseResponderConsent;
        public string   prevInfoRequestResponseResponderConsentStr;
        public bool     prevInfoRequestResponseHasResponderSignatureImgData;
        public string   prevInfoRequestResponseResponderSignatureImgData;        
        public bool     prevInfoRequestResponseNoInsuranceOptionSelected;
        public bool     prevInfoRequestResponseOtherInsuranceOptionSelected;

    }

    /***************************************************************************
     * PatientsWithMissingInfo  */
    /**
     * Primarily view methods as any action method is taken care of by 
	 * info requests
     ***************************************************************************/
	
	public class PatientsWithMissingInfo : Entities
    {
	    public const string MENU_ID_MANAGE    = @"managepatientswithmissinginfolnk";
        public const string BODY_ID_MANAGE    = @"managepatientswithmissinginfobody";        
        public const string SEL_LABEL_MANAGE  = @"Manage Patients With Missing Info";
        public const string URL_MANAGE        = @"user_all_manage_patients_with_missing_info.aspx";
        public const string SEL_LABEL_RPT     = @"Patients With Missing Info";
        public const string URL_REST_VIEW     = @"api/v1/patientswithmissinginfo";        
        public const string URL_WEB_REPORT    = @"patients_with_missing_info.ashx";
        public const string URL_SVC_BASE      = @"patients_with_missing_info.asmx";
        public const string URL_SVC_GET       = URL_SVC_BASE + "/get";

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * Returns the base URL for the REST view
         ***************************************************************************/
		 
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * Returns the base URL for the manage screen
         ***************************************************************************/
		
        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_MANAGE, true);
        }

        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         * Returns the base URL for the web report endpoint
         ***************************************************************************/

        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(URL_WEB_REPORT, true);           
        }
        
        /***************************************************************************
         * URL_SVC_GET_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_GET_BASE()
        {
            return MBA.HttpApplication.createLink(PatientsWithMissingInfo.URL_SVC_GET, true);
        }

        /***************************************************************************
         * load */
        /**
         * Outputs data for a single patient
         * 
         * Note: This calls the view method and the view method takes care of
         * enforcing the client id.
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static PatientWithMissingInfo load (
             SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo   uInfo
            , string     clientID
            , string     patID )
        {
            return (PatientWithMissingInfo)Entities.load (connSpedmon, log, uInfo, patID, typeof(PatientWithMissingInfo),
            delegate { return PatientsWithMissingInfo.view (
                connSpedmon
                , log
                , uInfo
                , Entities.REC_VIEW_LOAD
                , false
                , patID
                , ""    /* can edit */
                , ""    /* active */
                , clientID    /* client id*/
                , patID /* pat id */
                , "0"   /* data source = 0 (all pats in district) */
                , ""    /* missing insurance */
                , ""    /* missing  address */
                , ""    /* missing ferpa */
                , ""    /* missing pg emails */
                , ""    /* missingPGMcalConsent */
                , "" /* has current info request */
                , "" /* has info request requiring review */
                , "" /* has previous info request requiring review */ 
                , false
                , null ); });
        }

        /***************************************************************************
         * get */
        /**
         * Gets missing info record
         *
         * Note: This calls the load method which calls the view method and the 
         * view method takes care of enforcing the client id.
         * 
         * @return            ReturnObject
         ***************************************************************************/

        public static ReturnObject get ( 
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo            
            , string       clientID
            , string       patID )
        {

            var so      = new ReturnObject();
            var objType = typeof(PatientWithMissingInfo);

            so.hasRecord = false;
            so.objectFullName = objType.FullName;
            
            PatientWithMissingInfo pat = null;

            try { 
              pat = load(connSpedmon,log,uInfo,clientID, patID);
            } 
            catch
            {
                so.hasRecord = false;
                return so;
            }                
            so.hasRecord = true;                
            so.data      = pat;;            
            return so;
        }
   
        /***************************************************************************
         * view */
        /**
         * Base view method
         * 
         * @return ReturnDB
         ***************************************************************************/
   
        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        canEdit
                                     , string        active
                                     , string        clientID
                                     , string        patID
                                     , string        dataSource
                                     , string        missingInsuranceInfo
                                     , string        missingAddressInfo
                                     , string        missingFerpaConsent
                                     , string        missingPGEmails
                                     , string        missingPGMcalConsent
                                     , string        hasCurrInfoRqst
                                     , string        hasCurrInfoRqstReqRvw
                                     , string        hasPrevInfoRqstThatReqRvw
                                     , bool          limitToPatientsWithMissingInfo
                                     , defineCols dc)
        {
            string viewUDF = "dbo.Patients_With_Missing_Info_View (@userID, @userGroup, @userRank, @clientID, @patID, @source, @missingInsuranceInfo, @missingAddressInfo, @missingOrNoFerpaConsent, @missingPGEmails, @missingMcalParentConsent, @hasCurrentInfoRequest, @hasCurrentInfoRequestWaitingForReview, @hasPreviousInfoRequestThatRequiredReview, @limitToPatsWithMissingInfo)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * corresponding database
             * parameters
             *----------------------------*/

            Object vClientID                  = Validate.optClientID (uInfo, clientID);
            Object vPatID                     = Validate.optInteger (patID, Messages.INVALID_PAT_ID);
            int    vSource                    = Validate.reqInteger (dataSource,Messages.INVALID_DATA_SOURCE,true);
            Object vMissingInsuranceInfo      = Validate.optFlag (missingInsuranceInfo,      Messages.INVALID_FLAG);
            Object vMissingAddressInfo        = Validate.optFlag (missingAddressInfo,        Messages.INVALID_FLAG);
            Object vMissingFerpaConsent       = Validate.optFlag (missingFerpaConsent,       Messages.INVALID_FLAG);
            Object vMissingPGEmails           = Validate.optFlag (missingPGEmails,           Messages.INVALID_FLAG);
            Object vMissingPGMcalConsent      = Validate.optFlag (missingPGMcalConsent,      Messages.INVALID_FLAG);

            Object vHasCurrentInfoRequest                 = Validate.optFlag (hasCurrInfoRqst,           Messages.INVALID_FLAG);
            Object vHasCurrentInfoRequestWaitingForReview = Validate.optFlag (hasCurrInfoRqstReqRvw,     Messages.INVALID_FLAG);
            Object vHasPrevInfoRqstThatReqRvw             = Validate.optFlag (hasPrevInfoRqstThatReqRvw, Messages.INVALID_FLAG);
             
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                    SqlDbType.BigInt,  vPatID,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@source",                   SqlDbType.TinyInt, vSource,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@missingInsuranceInfo",     SqlDbType.Bit,     vMissingInsuranceInfo,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@missingAddressInfo",       SqlDbType.Bit,     vMissingAddressInfo,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@missingOrNoFerpaConsent",  SqlDbType.Bit,     vMissingFerpaConsent,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@missingPGEmails",          SqlDbType.Bit,     vMissingPGEmails,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@missingMcalParentConsent", SqlDbType.Bit,     vMissingPGMcalConsent,  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasCurrentInfoRequest",                    SqlDbType.Bit,    vHasCurrentInfoRequest,                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasCurrentInfoRequestWaitingForReview",    SqlDbType.Bit,    vHasCurrentInfoRequestWaitingForReview,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasPreviousInfoRequestThatRequiredReview", SqlDbType.Bit,    vHasPrevInfoRqstThatReqRvw,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@limitToPatsWithMissingInfo",               SqlDbType.Bit,    limitToPatientsWithMissingInfo,          ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and returns
             * the results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
         * viewObjects */
        /**
         * Returns a list of PatientWithMissingInfo objects
         ***************************************************************************/
		 
        public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                                 , DetailsLog  log
                                                 , UserInfo    uInfo
                                                 , bool        pageObjectList
                                                 , string      pageOrder
                                                 , string      idx
                                                 , string      active
                                                 , string      clientID
                                                 , string      patID
                                                 , string      dataSource
                                                 , string      missingInsuranceInfo
                                                 , string      missingAddressInfo
                                                 , string      missingFerpaConsent
                                                 , string      missingPGEmails
                                                 , string      missingPGMcalConsent
                                                 , string      hasCurrInfoRqst
                                                 , string      hasCurrInfoRqstReqRvw
                                                 , string      hasPrevInfoRqstThatReqRvw ) 
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientWithMissingInfo.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            /* Call the base method to retrieve objects */

            return Entities.viewObjects ( connSpedmon
                                         , log
                                         , uInfo
                                         , typeof(PatientWithMissingInfo)
                                         , pageObjectList
                                         , pageOrder
                                         , delegate {
                                            return PatientsWithMissingInfo.view (
                                                  connSpedmon
                                                , log
                                                , uInfo
                                                , Entities.REC_VIEW_OBJECTS
                                                , pageObjectList
                                                , idx
                                                , "" /* canEdit */
                                                , active
                                                , clientID
                                                , patID
                                                , dataSource
                                                , missingInsuranceInfo
                                                , missingAddressInfo
                                                , missingFerpaConsent
                                                , missingPGEmails
                                                , missingPGMcalConsent
                                                , hasCurrInfoRqst
                                                , hasCurrInfoRqstReqRvw
                                                , hasPrevInfoRqstThatReqRvw
                                                , true
                                                , dc );
                                        });
        }


        /***************************************************************************
         * viewTbl */
        /**
         * 
         * @return ReturnDataTable
         ***************************************************************************/
        public static ReturnDataTable viewTbl (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , bool          paged
            , string        pageNumber
            , string        active
            , string        clientID
            , string        patID
            , string        dataSource
            , string        missingInsuranceInfo
            , string        missingAddressInfo
            , string        missingFerpaConsent
            , string        missingPGEmails
            , string        missingPGMcalConsent
            , string        hasCurrInfoRqst
            , string        hasCurrInfoRqstReqRvw
            , string        hasPrevInfoRqstThatReqRvw )
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("patName as [Patient Name]", true);
                ss.addDisplayColumn("dobStr as [Date of Birth]");
                ss.addDisplayColumn("ssid as [SSID]");
                ss.addDisplayColumn("studentID as [Student ID]");
                ss.addDisplayColumn("grade as [Grade]");
                ss.addDisplayColumn("siteName as [Site]");
                
                ss.addDisplayColumn("missingPGEmailsStr as [Missing\nParent/Guardian\nInfo or Emails?]");
                ss.addDisplayColumn("missingAddressInfoStr as [Missing\nAddress\nInfo?]");
                ss.addDisplayColumn("missingInsuranceInfoStr as [Missing\nInsurance\nInfo?]");
                ss.addDisplayColumn("missingFerpaConsentStr as [Missing\nFERPA\nConsent?]");
                ss.addDisplayColumn("missingMcalParentConsentStr as [Missing\nMedi-Cal\nConsent?]");
                ss.addDisplayColumn("currentInfoRequestSentOnStr as [Info\nRequest\nSent On]");
                                      
                ss.addDisplayColumn("patID as [SpEdCare Patient ID]");

                pageroworder = ss.pageRowOrder();
            };

            return Entities.viewTbl (
                  connSpedmon
                , log
                , uInfo
                , paged
                , pageNumber
                , delegate { 
                  return PatientsWithMissingInfo.view (
                          connSpedmon
                        , log
                        , uInfo
                        , Entities.REC_VIEW_TBL
                        , paged
                        , pageNumber
                        , "N"  // canEdit
                        , active
                        , clientID
                        , patID
                        , dataSource
                        , missingInsuranceInfo
                        , missingAddressInfo
                        , missingFerpaConsent
                        , missingPGEmails
                        , missingPGMcalConsent
                        , hasCurrInfoRqst
                        , hasCurrInfoRqstReqRvw
                        , hasPrevInfoRqstThatReqRvw
                        , true
                        , dc );
                }
                , SEL_LABEL_RPT
                , Messages.CONFIDENTIAL);
        }

        /***************************************************************************
         * rptPatsNeedingPossibleFollowup */
        /**
         * 
         * @return ReturnDataTable
         ***************************************************************************/
        public static ReturnDataTable rptPatsNeedingPossibleFollowup (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , bool          paged
            , string        pageNumber
            , string        active
            , string        clientID
            , string        patID
            , string        dataSource )
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("patName as [Patient Name]", true);
                ss.addDisplayColumn("dobStr as [Date of Birth]");
                ss.addDisplayColumn("ssid as [SSID]");
                ss.addDisplayColumn("studentID as [Student ID]");
                ss.addDisplayColumn("grade as [Grade]");
                ss.addDisplayColumn("siteName as [Site]");
                
                ss.addDisplayColumn("missingPGEmailsStr as [Missing\nParent/Guardian\nInfo or Emails?]");
                ss.addDisplayColumn("missingAddressInfoStr as [Missing\nAddress\nInfo?]");
                ss.addDisplayColumn("missingInsuranceInfoStr as [Missing\nInsurance\nInfo?]");
                ss.addDisplayColumn("missingFerpaConsentStr as [Missing\nFERPA\nConsent?]");
                ss.addDisplayColumn("missingMcalParentConsentStr as [Missing\nMedi-Cal\nConsent?]");

                ss.addDisplayColumn("prevInfoRequestResponseReceivedOnStr as [Info\nResponse\nReceived On]");
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(prevInfoRequestResponseNoInsuranceOptionSelected) as [No\nInsurance?]");
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(prevInfoRequestResponseOtherInsuranceOptionSelected) as [Other\nInsurance?]");
                ss.addDisplayColumn("prevInfoRequestResponsePolicyHolderFirstName as [Policy Holder\nFirst Name]");
                ss.addDisplayColumn("prevInfoRequestResponsePolicyHolderLastName as [Policy Holder\nLast Name]");
                ss.addDisplayColumn("prevInfoRequestResponsePolicyNumber as [Policy Number]");
                ss.addDisplayColumn("prevInfoRequestResponseGroupNumber as [Group Number]");
                ss.addDisplayColumn("prevInfoRequestResponseInsuranceCarrierName as [Carrier Name]");
                ss.addDisplayColumn("prevInfoRequestResponseInsuranceCarrierOtherName as [Other Carrier Name]");
                ss.addDisplayColumn("prevInfoRequestResponseResponderName as [Responder Name]");
                ss.addDisplayColumn("prevInfoRequestResponseResponderConsentStr as [FERPA\nConsent\nGiven]");
                ss.addDisplayColumn("patID as [SpEdCare Patient ID]");

                pageroworder = ss.pageRowOrder();
            };

            return Entities.viewTbl (
                  connSpedmon
                , log
                , uInfo
                , paged
                , pageNumber
                , delegate { 
                  return PatientsWithMissingInfo.view (
                          connSpedmon
                        , log
                        , uInfo
                        , Entities.REC_VIEW_TBL
                        , paged
                        , pageNumber
                        , "N"  // canEdit
                        , active
                        , clientID
                        , patID
                        , dataSource
                        , "" // missingInsuranceInfo
                        , "" // missingAddressInfo
                        , "" // missingFerpaConsent
                        , "" // missingPGEmails
                        , "" // missingMCALConsent
                        , "" // hasCurrInfoRequest
                        , "" // hasCurrInfoRequestRequiringReview
                        , "Y" // hasPrevInfoRequestRequiringReview
                        , true
                        , dc );
                }
                , SEL_LABEL_RPT
                , Messages.CONFIDENTIAL);
        }
        
    }
}

