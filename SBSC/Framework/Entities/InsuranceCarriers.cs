
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

using MBA;

namespace Spedmon
{
    /***************************************************************************
     * InsuranceCarrier */
    /**
     * 
     *************************************************************************/

    public class InsuranceCarrier : Entity
    {
        public string   carrierCode;
        public string   carrierName;
        public string   ohcCode;        
        public string   planTypeCode;
        public bool     planSupportedByCYBHI;
        public string   usState;

        public const string DEFAULT_PAGING_ORDER = @"carrierName asc";
    }

    /***************************************************************************
     * InsuranceCarriers */
    /**
     * 
     *************************************************************************/

    public class InsuranceCarriers:Entities
    {
        public const string SEL_LABEL           = @"Insurance Carriers";
        public const string SEL_LABEL_MANAGE    = @"Insurance Carriers - Manage";
        public const string URL_MANAGE          = @"sbs_all_manage_insurance_carriers.aspx";
        public const string MENU_ID_MANAGE      = @"insurancecarriersmanage";
        public const string URL_WEB_SERVICE     = @"insurance_carriers.asmx"; 
        public const string URL_VIEW_SEL        = URL_WEB_SERVICE + @"/viewSel";
        public const string URL_VIEW_SAVE       = URL_WEB_SERVICE + @"/saveinline";
        public const string URL_VIEW_DELETE     = URL_WEB_SERVICE + @"/deleteinline";
        public const string URL_REST_VIEW       = @"api/v1/insurancecarriers";
        
        public const int    OPTION_VALUE_OTHER        = -10;
        public const int    OPTION_VALUE_NO_INSURANCE = -20;


        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
        }

        public static string URL_VIEW_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SAVE, true);
        }

        public static string URL_VIEW_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_DELETE, true);
        }

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        /***************************************************************************
         * viewSel */
        /**
         * 
         *************************************************************************/

        public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
        {          

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                /*ss.addDisplayColumn("'Insurance for US State : ' + usState as context1");*/
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return InsuranceCarriers.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top,topSize,"",term, "1", dc); });

        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        canEdit
                                     , string        term 
                                     , string        active                                                                    
                                     , defineCols    dc )
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/
            
            string vTerm = Validate.optString (term, @"Invalid search term");

            var parms = new List<SqlParameter>();
           
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 255));

            string viewUDF = "dbo.INSURANCE_CARRIERS_VIEW (@userID, @userGroup, @userRank, @term, @active, @recID)";            

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
        * delete */
        /**
         * "Delete" record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID)
        {

            string deleteSproc = @"INSURANCE_CARRIERS_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/            

            List<SqlParameter> parms = new List<SqlParameter>();

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string carrierCode
                                              , string name
                                              , string ohcCode
                                              , string planTypeCode
                                              , string planSupportedByCYBHI
                                              , string usState
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            string saveSproc = @"INSURANCE_CARRIERS_SAVE";

            string dupRecMsg = @"Entry already exists";
            
            string vCarrierCode             = Validate.optString(carrierCode,           @"Invalid carrier code");
            string vCarrierName             = Validate.optString(name,                  @"Invalid name");
            string vOhcCode                 = Validate.optString(ohcCode,               @"Invalid code");
            string vPlanTypeCode            = Validate.optString(planTypeCode,          @"Invalid plan type code");
            var    vPlanSupportedByCYBHI    = Validate.optFlag(planSupportedByCYBHI,    Messages.INVALID_FLAG);
            string vUsState                 = Validate.optString(usState,               @"Invalid state id");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@carrierCode",          SqlDbType.VarChar, vCarrierCode,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@name",                 SqlDbType.VarChar, vCarrierName,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ohcCode",              SqlDbType.VarChar, vOhcCode,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@planTypeCode",         SqlDbType.VarChar, vPlanTypeCode,           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@planSupportedByCYBHI", SqlDbType.Bit, vPlanSupportedByCYBHI,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@usState",              SqlDbType.VarChar, vUsState,                ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
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
                                                  , string term)

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = InsuranceCarrier.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                           , log
                                           , uInfo
                                           , typeof(InsuranceCarrier)
                                           , pageObjectList
                                           , pageOrder
                                           , delegate {
                                               return InsuranceCarriers.view (   connSpedmon
                                                                               , log
                                                                               , uInfo
                                                                               , Entities.REC_VIEW_OBJECTS
                                                                               , pageObjectList
                                                                               , idx
                                                                               , ""  /* Can edit */
                                                                               , term
                                                                               , "1" /* Active */
                                                                               , dc );
                                           });

            return rd;
        }
        
        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<InsuranceCarrier> viewList(  SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo                                                      
                                                      , string active)

        {
            var recs = new List<InsuranceCarrier>();
            ReturnDB rd = InsuranceCarriers.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, "", active, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(InsuranceCarrier));
            foreach (var o in slo)
            {
                recs.Add((InsuranceCarrier)o);
            }
            return recs;
        }

        /***************************************************************************
         * generateSelectOptionsMarkup */
        /**
         * 
         ***************************************************************************/
        public static string generateSelectOptionsMarkup( SqlConnection connSpedmon
                                                          , DetailsLog  log
                                                          , UserInfo    uInfo                                                          
                                                          , bool        addOptionForOther        = true
                                                          , bool        addOptionForNoInsurance  = true
                                                          , string      optionLabelSelectCarrier = "Select A Carrier"
                                                          , string      optionLabelOther         = "Other (Not Listed)"
                                                          , string      optionNoInsurance        = "No Insurance" )

        {
            StringBuilder sb = new StringBuilder();
            var recs = viewList(connSpedmon, log, uInfo, "Y");
            sb.AppendFormat(@"<option disabled=""disabled"" selected=""selected"" value="""">{0}</option>",optionLabelSelectCarrier);

            if (addOptionForOther)       sb.AppendFormat(@"<option value=""{0}"">{1}</option>", OPTION_VALUE_OTHER,        optionLabelOther);
            if (addOptionForNoInsurance) sb.AppendFormat(@"<option value=""{0}"">{1}</option>", OPTION_VALUE_NO_INSURANCE, optionNoInsurance);

            foreach (InsuranceCarrier rec in recs) {
              sb.AppendFormat(@"<option value=""{0}"">{1}</option>", rec.id, rec.name);
            }

            return sb.ToString();
        }

    }
}
