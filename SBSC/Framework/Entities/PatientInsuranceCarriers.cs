
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * PatientInsuranceCarrier */
    /**
     * 
     *************************************************************************/

    public class PatientInsuranceCarrier /*: Entity*/
    {
        public const string DEFAULT_PAGING_ORDER = @"patName asc, patID desc, insuranceCarrierName asc, id desc";

        public long     id;
	    public int      clientID;
        public int      patID;
        public string   patName;
        public DateTime dob;
        public string   dobStr;
        public string   ssid;

        public long     insuranceCarrierID; 
        public string   insuranceCarrierName;
	    public string   beneficiaryLastName;
	    public string   beneficiaryFirstName;
        public string   beneficiaryID;

        public string   policyHolderName;
        public string   policyGroupID;
        public bool     planSupportedByCYBI;
        public bool     expiredOrInvalid;
        public bool     cybhiRegisteredWithTpa;

        public bool     primaryCarrier;
    }

    /***************************************************************************
     * PatientInsuranceCarriers */
    /**
     * 
     *************************************************************************/

    public class PatientInsuranceCarriers:Entities
    {

        public const string URL_WEB_SERVICE                  = @"patient_insurance_carriers.asmx";
        public const string URL_PAGE_MANAGE                  = @"user_all_patient_insurance_carriers_manage.aspx";
        public const string MENU_LNK_USER_ALL_MANAGE         = "userallpatinscarriersmgmtlnk";
        public const string PAGE_ID_USER_ALL_MANAGE          = "userallpatinscarriersmgmtpage";
        public const string PAGE_MANAGE_SEL_LABEL            = "Manage All Patient Insurance Carriers";
        public const string URL_REST_PATCARRIER_SAVE_INLINE  = URL_WEB_SERVICE + @"/saveinline";
        public const string URL_REST_PATCARRIER_DELETE       = URL_WEB_SERVICE + @"/deleteinline";
        public const string URL_REST_PATCARRIER_DELETE_MULTI = URL_WEB_SERVICE + @"/deletemultiinline";        
        public const string URL_PATIENT_CARRIERS_REST_VIEW   = "api/v1/patientinsurancecarriers";
        
	    public static string URL_REST_PATCARRIER_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink( URL_REST_PATCARRIER_SAVE_INLINE, true);
        }

        public static string URL_PATIENT_CARRIERS_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PATIENT_CARRIERS_REST_VIEW, true);
        }

        public static string URL_REST_PATCARRIER_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_PATCARRIER_DELETE, true);
        }

        public static string URL_REST_PATCARRIER_DELETE_MULTI_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_PATCARRIER_DELETE_MULTI, true);
        }
      
        public static string URL_PAGE_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PAGE_MANAGE, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
		                              , DetailsLog   log
									  , UserInfo     uInfo
                                      , int          recViewType
                                      , bool         pagedOrTop
                                      , string       idx
                                      , string       canEdit
                                      , string       clientID
									  , string       patID
                                      , string       active
                                      , defineCols   dc )
        {
            // TODO: Modify to support the parms added to the view udf 
            //, @planSupportedByCYBI    bit
            //, @hasCarrierSelection    bit

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.optClientID (uInfo, clientID);
            var vPatID    = Validate.optPatID    (uInfo, patID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",    SqlDbType.BigInt, vPatID,    ParameterDirection.Input));
          
            string viewUDF = "dbo.PATIENT_INSURANCE_CARRIERS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, null, null, @active, @recID)";
            
            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<PatientInsuranceCarrier> viewList(SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo
                                                      , string clientID
                                                      , string patID
                                                      , string active)

        {
            var recs = new List<PatientInsuranceCarrier>();

            ReturnDB rd = PatientInsuranceCarriers.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, "", clientID, patID, active, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(PatientInsuranceCarrier));
            foreach (var o in slo)
            {
                recs.Add((PatientInsuranceCarrier)o);
            }
            return recs;
        }

        /***************************************************************************
         * viewObjects */
        /**
         * 
         *************************************************************************/

        public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                  , DetailsLog   log
                                                  , UserInfo     uInfo
                                                  , bool         pageObjectList
                                                  , string       pageOrder
                                                  , string       idx
                                                  , string       active
                                                  , string       clientID
                                                  , string       patID )
        {

            /* Default page order */
            
            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientInsuranceCarrier.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
               pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientInsuranceCarrier)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientInsuranceCarriers.view (  connSpedmon
                                                                                    , log
                                                                                    , uInfo
                                                                                    , Entities.REC_VIEW_OBJECTS
                                                                                    , pageObjectList
                                                                                    , idx
                                                                                    , "" /*canEdit*/
                                                                                    , clientID
                                                                                    , patID                                                                                    
                                                                                    , active
                                                                                    , dc);
                                          });

        }
        
        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , string        clientID
                                              , string        patID
                                              , string        insuranceCarrierID
                                              , string        beneficiaryLastName
                                              , string        beneficiaryFirstName
                                              , string        beneficiaryID
                                              , string        policyHolderName
                                              , string        policyGroupID
                                              , string        expiredOrInvalid
                                              , string        cybhiRegisteredWithTpa
                                              , string        primaryCarrier
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID  )
        {

            string saveSproc = @"PATIENT_INSURANCE_CARRIERS_SAVE";

            string dupRecMsg = @"Entry already exists";  

            var vClientID               = Validate.reqClientID (uInfo, clientID);
            var vPatID                  = Validate.reqPatID    (uInfo, patID);
            var vInsuranceCarrierID     = Validate.optIntegerReturnNullIfValueIsZero (insuranceCarrierID,   @"Please select a valid insurer");
            var vBeneficiaryLastName    = Validate.optString (beneficiaryLastName,    @"Invalid beneficiary last name");  /* 60 max */
            var vBeneficiaryFirstName   = Validate.optString (beneficiaryFirstName,   @"Invalid beneficiary first name"); /* 35 max */
            var vBeneficiaryID          = Validate.optString (beneficiaryID,          @"Invalid beneficiary id"); /* 80 max*/
            var vExpiredOrInvalid       = Validate.reqFlag   (expiredOrInvalid,       @"Expired or invalid?", true );
            var vCybhiRegisteredWithTpa = Validate.reqFlag   (cybhiRegisteredWithTpa, @"Cybhi registered with TPA", true);
            var vPrimaryCarrier         = Validate.reqFlag   (primaryCarrier,         @"Invalid primary carrier flag", true);
            var vPolicyHolderName       = Validate.optString (policyHolderName,       @"Invalid policy holder name");
            var vPolicyGroupID          = Validate.optString (policyGroupID,          @"Invalid policy group ID");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",               SqlDbType.Int,     vClientID,               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                  SqlDbType.Int,     vPatID,                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@insuranceCarrierID",     SqlDbType.BigInt,  vInsuranceCarrierID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@beneficiaryLastName",    SqlDbType.VarChar, vBeneficiaryLastName,    ParameterDirection.Input, 60));
            parms.Add(Database.SqlParm("@beneficiaryFirstName",   SqlDbType.VarChar, vBeneficiaryFirstName,   ParameterDirection.Input, 35));
            parms.Add(Database.SqlParm("@beneficiaryID",          SqlDbType.VarChar, vBeneficiaryID,          ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@policyHolderName",       SqlDbType.VarChar, vPolicyHolderName,       ParameterDirection.Input, 512));
            parms.Add(Database.SqlParm("@policyGroupID",          SqlDbType.VarChar, vPolicyGroupID,          ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@expiredOrInvalid",       SqlDbType.Bit,     vExpiredOrInvalid,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiRegisteredWithTpa", SqlDbType.Bit,     vCybhiRegisteredWithTpa, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@primaryCarrier",         SqlDbType.Bit,     vPrimaryCarrier,         ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


        
        /***************************************************************************
         * delete */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord delete (
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , string clientID
            , string editDelReason
            , string validateRec
            , string recID) 
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.reqClientID(uInfo, clientID);

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENT_Insurance_Delete", ref parms);
        }


        /***************************************************************************
         * deleteMulti */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord deleteMulti(
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        clientID
            , string        editDelReason
            , string        validateRec
            , string        recIDs )
        {

            var parms = new List<SqlParameter>();

            var vClientID = Validate.reqClientID(uInfo, clientID);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            
            return Entities.recordOpMulti (  connSpedmon
                                           , log
                                           , uInfo
                                           , editDelReason
                                           , validateRec                                           
                                           , recIDs  
                                           , "PATIENT_Insurance_Delete_Multi" 
                                           , true 
                                           , ref parms);
        }

    }

}
