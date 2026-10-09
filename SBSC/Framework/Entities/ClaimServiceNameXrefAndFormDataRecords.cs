using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * ClaimServiceNameXrefAndFormDataRecords */
  /** 
   ***************************************************************************/
   public class ClaimServiceNameXrefAndFormDataRecord : Entity
   {
     public long        planTypeID;
     public string      planTypeName;
     public long        groupID;
     public string      groupName;
     public bool        groupRequiresSupervision;
     public string      groupRequiresSupervisionStr;
     public long        svcNameID;
     public string      svcName;
     public long        svcTypeId;
     public string      svcTypeName;
     public long        svcSubType1Id;
     public string      svcSubType1Name;
     public bool        isStandard;
     public bool        hasFormData;
     public bool        hasClientID;
     public string      formDataJson;
     public long        clientID;
     public string      clientName;
     public long        groupSvcClassNameID;
     public string      groupSvcClassName;
     public bool        hasPatientGoalTracking;
     public bool        hasSessionRatingTracking;
     public int?        spEdSvcCodeValue;
     public string      spEdSvcCodeName;
     public string      svcNameWithCalpadsCode;
     public string      fillablePdfSelectionsJSON;
     public bool        hasFillablePdfSelections;
   }

    /***************************************************************************
     * ClaimServiceNameXrefAndFormDataRecords */
    /** 
     ***************************************************************************/
	 
    public class ClaimServiceNameXrefAndFormDataRecords : Entities
    {
      public const string SEL_LABEL_MANAGE         = @"Manage Service Name Form Data";
      public const string URL_SBS_ALL_MANAGE       = @"sbs_all_manage_service_name_form_data.aspx";
      public const string MENU_LNK_MANAGE          = @"manageservicenameformdatalnk";
      public const string URL_REST_VIEW_BASE       = @"api/v1/claimservicenamexrefandformdatarecords";
      public const string URL_SVC_BASE             = @"claim_service_name_xref_and_form_data_records.asmx/";
      public const string URL_SVC_SAVE_BASE        = URL_SVC_BASE + @"save";

      public const string URL_DELETE_INLINE_BASE            =  URL_SVC_BASE + @"deleteinline";

      public const string URL_DELETE_MULTI_INLINE_BASE      =  URL_SVC_BASE + @"deletemultiinline";

      public const string URL_MULTICLONE_BASE                    =  URL_SVC_BASE + @"multiclone";

      public const string URL_SAVE_FORMJSON_MULTI_BASE                    =  URL_SVC_BASE + @"saveformjsonmulti";

      public const string URL_SBS_ALL_MANAGE_FILLABLE_PDFS_BASE = @"sbs_all_manage_service_name_form_data_fillable_pdf_files.aspx";
      public const string DEFAULT_PAGING_ORDER                  = @"name asc";

      public const string URL_VIEW_REPORT_BASE           = @"claim_service_name_xref_and_form_data_records.ashx";

      public static string URL_VIEW_REPORT()
      { 
      return MBA.HttpApplication.createLink( ClaimServiceNameXrefAndFormDataRecords.URL_VIEW_REPORT_BASE, true);
      }

      public static string URL_REST_VIEW()
      { 
      return MBA.HttpApplication.createLink( ClaimServiceNameXrefAndFormDataRecords.URL_REST_VIEW_BASE, true);
      }
     
      public static string URL_CLONE()
      {
        return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_SVC_SAVE_BASE
                                              , true
                                              );
      }
        public static string URL_EDIT()
      {
        return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_SVC_SAVE_BASE
                , true
                );
      }

      public static string URL_DELETE_INLINE()
      {
        return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_DELETE_INLINE_BASE
                , true
                );
      }

      public static string URL_DELETE_MULTI_INLINE()
      {
        return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_DELETE_MULTI_INLINE_BASE
                , true
                );
      }

      public static string URL_MULTICLONE()
      {
        return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_MULTICLONE_BASE
                , true
                );
      }

      public static string URL_SAVE_FORMJSON_MULTI()
      {
            return MBA.HttpApplication.createLink(ClaimServiceNameXrefAndFormDataRecords.URL_SAVE_FORMJSON_MULTI_BASE
                    , true
                    );
      }
      public static string URL_SBS_ALL_MANAGE_FILLABLE_PDFS()
      {
          return MBA.HttpApplication.createLink( ClaimServiceNameXrefAndFormDataRecords.URL_SBS_ALL_MANAGE_FILLABLE_PDFS_BASE                                                
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                );
      }

        /***************************************************************************
         * view */
        /** 
         ***************************************************************************/
      protected static ReturnDB view (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , int           recViewType
        , bool          pagedOrTop
        , string        idx
        , string        canEdit
        , string        active
        , string        clientID
        , string        planTypeID
        , string        groupID
        , string        nameID
        , string        groupSvcClassNameID
        , string        svcTypeID
        , string        term

        , string        exclMissingCliID
        , defineCols    dc )
    {

	    ///
        string viewUDF = "dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW ( @userID, @userGroup, @userRank, @clientID, @planTypeID, @groupID, @nameID, @groupSvcClassNameID, @svcTypeID, @term, @hasClientID, @active, @recID)";


        Object vClientID             = Validate.optInteger (clientID,            Messages.INVALID_CLIENT_ID);
        Object vPlanTypeID           = Validate.optInteger (planTypeID,          Messages.INVALID_PLAN_TYPE);
        Object vGroupID              = Validate.optInteger (groupID,             Messages.INVALID_GROUP_NAME);
        Object vNameID               = Validate.optInteger (nameID,              Messages.INVALID_NAME_ID);
        Object vGroupSvcClassNameID  = Validate.optInteger (groupSvcClassNameID, Messages.INVALID_GROUP_FAMILY);
        Object vSvcTypeID            = Validate.optInteger (svcTypeID,           Messages.INVALID_SERVICE_TYPE);
        string vTerm                 = Validate.optString  (term,                Messages.INVALID_SEARCH_TERM);

        Object vExclMissingCliID       = Validate.optFlagYesOnly(exclMissingCliID, "exclude for unspecified client?");

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID"            , SqlDbType.BigInt , vClientID            , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@planTypeID"          , SqlDbType.BigInt , vPlanTypeID          , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@groupID"             , SqlDbType.BigInt , vGroupID             , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@nameID"              , SqlDbType.BigInt , vNameID              , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@groupSvcClassNameID" , SqlDbType.BigInt , vGroupSvcClassNameID , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@svcTypeID"           , SqlDbType.Int    , vSvcTypeID           , ParameterDirection.Input));            
        parms.Add(Database.SqlParm("@term"                , SqlDbType.VarChar, vTerm                , ParameterDirection.Input, 256));

        
        parms.Add(Database.SqlParm("@hasClientID", SqlDbType.Bit, vExclMissingCliID, ParameterDirection.Input));


        var rd = Entities.view (  connSpedmon
                                , log
                                , uInfo
                                , recViewType
                                , pagedOrTop
                                , idx
                                , canEdit
                                , active
                                , viewUDF
                                , ref parms
                                , null
                                , dc);
        return rd;
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of patients objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          pageObjectList
                                              , string        pageOrder
                                              , string        idx
                                              , string        active
                                              , string        clientID 
                                              , string        planTypeID
                                              , string        groupID
                                              , string        nameID
                                              , string        groupSvcClassNameID
                                              , string        svcTypeID
                                              , string        exclMissingCliID
                                              , string        term )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientParentMcalConsents.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd =  Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(ClaimServiceNameXrefAndFormDataRecord)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return ClaimServiceNameXrefAndFormDataRecords.view (
                                                          connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_OBJECTS
                                                        , pageObjectList
                                                        , idx
                                                        , "" /* Can edit */
                                                        , active                                                             
                                                        , clientID
                                                        , planTypeID
                                                        , groupID
                                                        , nameID
                                                        , groupSvcClassNameID
                                                        , svcTypeID
                                                        , term
                                                        , exclMissingCliID

                                                        , dc );
                                    });

      return rd;
    }
    
    /***************************************************************************
    * save */
   /**
    ***************************************************************************/   
  
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
										 , string        planTypeID
                                         , string        groupID
                                         , string        nameID
                                         , string        formDataJSON
                                         , string        hasPatientGoalTracking
                                         , string        hasSessionRatingTracking
                                         , string        spEdSvcCodeValue
                                         , string        fillablePdfSelectionsJSON
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE";
      string dupRecMsg = @"Claim Service already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      Object  vClientID                  = Validate.optClientID (uInfo,                     clientID);
      long    vPlanTypeID                = Validate.reqInteger  (planTypeID,                @"Invalid plan type");
      long    vGroupID                   = Validate.reqInteger  (groupID,                   @"Invalid group id");
      long    vNameID                    = Validate.reqInteger  (nameID,                    @"Invalid name id");
      Object  vFormDataJSON              = Validate.optString   (formDataJSON,              @"Invalid form Data");
      bool    vHasPatientGoalTracking    = Validate.reqFlag     (hasPatientGoalTracking,    @"Invalid patient goal tracking flag");
      Object  vSpEdSvcCodeValue          = Validate.optInteger  (spEdSvcCodeValue,          @"Invalid SpEd Service Code");
      bool    vHasSessionRatingTracking  = Validate.reqFlag     (hasSessionRatingTracking,  @"Invalid session rating tracking flag");
      Object  vFillablePdfSelectionsJSON = Validate.optString   (fillablePdfSelectionsJSON, @"Invalid file data");

      var parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",                   SqlDbType.BigInt,  vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planTypeID",                 SqlDbType.BigInt,  vPlanTypeID,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",                    SqlDbType.BigInt,  vGroupID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",                     SqlDbType.BigInt,  vNameID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@formDataJSON",               SqlDbType.VarChar, vFormDataJSON,              ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@hasPatientGoalTracking",     SqlDbType.Bit,     vHasPatientGoalTracking,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@spEdSvcCodeValue",           SqlDbType.Int,     vSpEdSvcCodeValue,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@hasSessionRatingTracking",   SqlDbType.Bit,     vHasSessionRatingTracking,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fillablePdfSelectionsJSON",  SqlDbType.VarChar, vFillablePdfSelectionsJSON, ParameterDirection.Input, -1));

    
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
    }

    /***************************************************************************
     * viewSingle */
    /**
     * 
     ***************************************************************************/   

    public static ReturnDB viewSingle ( SqlConnection connSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool   pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string clientID
                                 , string planTypeID
                                 , string groupID
                                 , string nameID
                                 , defineCols dc)
    {

      string viewUDF  = "dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW (@userID, @userGroup, @userRank, @clientID, @planTypeID, @groupID, @nameID, @active, @recID)";
      
      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/
      
      Object  vClientID     = Validate.optClientID (uInfo,        clientID);
      long    vPlanTypeID   = Validate.reqInteger  (planTypeID,   @"Invalid plan type");
      long    vGroupID      = Validate.reqInteger  (groupID,      @"Invalid group id");
      long    vNameID       = Validate.reqInteger  (nameID,       @"Invalid name id");

      List<SqlParameter> parms    = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planTypeID",   SqlDbType.BigInt,  vPlanTypeID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",      SqlDbType.BigInt,  vGroupID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",       SqlDbType.BigInt,  vNameID,       ParameterDirection.Input));
   
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

    /***************************************************************************
         * loadN */
        /**
         * Outputs data for a single record
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

        public static ClaimServiceNameXrefAndFormDataRecord loadN( SqlConnection connSpedmon
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , int n
                                       , string clientid
                                       , string plantypeid                           
                                       , string groupid
                                       , string nameid )
        {
            return (ClaimServiceNameXrefAndFormDataRecord)Entities.loadNRecord(connSpedmon
                                                      , log
                                                      , uInfo
                                                      , n
                                                      , typeof(ClaimServiceNameXrefAndFormDataRecord)
                                                      , delegate
                                                      {
                                                          return ClaimServiceNameXrefAndFormDataRecords.viewSingle(connSpedmon
                                                                                   , log
                                                                                   , uInfo
                                                                                   , Entities.REC_VIEW_LOAD_N
                                                                                   , false
                                                                                   , ""
                                                                                   , ""
                                                                                   , "1"
                                                                                   , clientid
                                                                                   , plantypeid
                                                                                   , groupid
                                                                                   , nameid
                                                                                   , null);
                                                      });
        }

        /***************************************************************************
         * delete */
        /**
         * Deac a single rec item
         *
         * @param  editDelReason     ignored
         * @param  validateRec       1 for test, 0 to commit changes
         * @param  recID             recID
         * 
         * @return                   ReturnSaveRecord
         ***************************************************************************/
        public static ReturnSaveRecord delete(
               SqlConnection connSpedmon
              , DetailsLog log
              , UserInfo uInfo
              , string editDelReason
              , string validateRec
              , string recID)
        {

            var parms = new List<SqlParameter>();
            return Entities.delete(connSpedmon
                                   , log
                                   , uInfo
                                   , editDelReason
                                   , validateRec
                                   , recID
                                   , "CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE"
                                   , ref parms);
        }

        /***************************************************************************
         * deleteMulti */
        /**
         * Deacs the rows enumerated in the recIDs param string.
         *
         * @param  editDelReason     ignored
         * @param  validateRec       1 for test, 0 to commit changes
         * @param  recIDs            recIDs, comma-separated
         * 
         * @return                   ReturnSaveRecord
         ***************************************************************************/

        public static ReturnSaveRecord deleteMulti(
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo

            , string editDelReason
            , string validateRec

            , string recIDs)
        {

            var parms = new List<SqlParameter>();


            return Entities.recordOpMulti(connSpedmon
                                           , log
                                           , uInfo
                                           , editDelReason
                                           , validateRec
                                           , recIDs
                                           , "CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI"
                                           , true
                                           , ref parms);
        }
       /***************************************************************************
        * cloneMulti */
       /**
        * save form JSON to the recIDs provided.
        * used to create a new set of forms for a given client from the form ids provided
        *
        * @param  editDelReason      ignored
        * @param  validateRec        1 for test, 0 to commit changes
        * @param  recIDs             recIDs of rows to clone, comma-separated
        * @param  clientidforclones  client to clone to
        *                            
        * @return                    ReturnSaveRecord
        ***************************************************************************/

        public static ReturnSaveRecord cloneMulti(
          SqlConnection connSpedmon
        , DetailsLog log
        , UserInfo uInfo

        , string editDelReason
        , string validateRec

        , string recIDs
        , string clientidforclones)
      {

            var parms = new List<SqlParameter>();

            Validate.reqInteger(clientidforclones, "Please select a client to clone to."); // NOTE: we don't have a built-in reqClientID() function that
                                                         // accepts an arbitrary err-msg param

            var vCliIDs = Validate.reqClientID(uInfo, clientidforclones);

            parms.Add(
               Database.SqlParm("@clientIDsForClones", SqlDbType.BigInt, vCliIDs, ParameterDirection.Input)
            );


            return Entities.recordOpMulti(connSpedmon
                                           , log
                                           , uInfo
                                           , editDelReason
                                           , validateRec
                                           , recIDs
                                           , "CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE"
                                           , true
                                           , ref parms);
        }



        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                            bool paged,
                                            string pageNumber,
                                            string canEdit,

                                            string active

                                            , string clientID
                                            , string planTypeID
                                            , string groupID
                                            , string nameID
                                            , string groupSvcClassNameID
                                            , string svcTypeID
                                            , string term

                                            , string exclMissingCliID)
        {


            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("id");


                ss.addDisplayColumn("planTypeName");

                ss.addDisplayColumn("groupName");

                ss.addDisplayColumn("groupRequiresSupervisionStr");

                ss.addDisplayColumn("svcName");

                ss.addDisplayColumn("svcTypeName");

                ss.addDisplayColumn("svcSubType1Name");

                ss.addDisplayColumn("isStandard");
                ss.addDisplayColumn("hasFormData");

                ss.addDisplayColumn("hasClientID");



                ss.addDisplayColumn("clientName");

                ss.addDisplayColumn("groupSvcClassName");

                ss.addDisplayColumn("hasPatientGoalTracking");
                ss.addDisplayColumn("hasSessionRatingTracking");

                ss.addDisplayColumn("spEdSvcCodeValue");
                ss.addDisplayColumn("spEdSvcCodeName");

  


                pageroworder = ss.pageRowOrder();

            };

            string tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return ClaimServiceNameXrefAndFormDataRecords.view(
                      connSpedmon, log, uInfo,


                      Entities.REC_VIEW_TBL, // recViewType
                      paged , //          pagedOrTop
                      pageNumber ,
                      canEdit 
                        , active
                        , clientID
                        , planTypeID
                        , groupID
                        , nameID
                        , groupSvcClassNameID
                        , svcTypeID
                        , term

                        , exclMissingCliID
                        , dc

                      ); }
              , "tableName" // todo
              , tableFooter
              );
        }

        /***************************************************************************
         * saveFormJsonMulti */
        /**
         * save form JSON to the recIDs provided.
         * Used for bulk updates of existing data
         *
         * @param  editDelReason      ignored
         * @param  validateRec        1 for test, 0 to commit changes
         * @param  recIDs             recIDs, comma-separated (not a JSON array or quoted string)
         * @param  updatedformjson    form JSON (stringified), nested inside a greater JSON object,
         *                            { "997": stringified_formobj, "998": stringified_formobj }.
         *                            The keys are identical to the ints provided in recIDs param.
         *                            The nested objs are all identical, as we may wish to implement
         *                            different form-content, per row, in a later, upgraded iteration.
         *                            
         * @return                    ReturnSaveRecord
         ***************************************************************************/
        public static ReturnSaveRecord saveFormJsonMulti(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo

          , string editDelReason
          , string validateRec

          , string recIDs
          , string updatedformjson
            )
        {

            var parms = new List<SqlParameter>();

            var vUpdatedFormJson = Validate.reqString(updatedformjson, "requires valid form data");
            // TODO: a reqJson() validator function
            // is not available at the middleware level, unfortunately


            parms.Add(Database.SqlParm("@updatedFormJson", SqlDbType.VarChar, vUpdatedFormJson, ParameterDirection.Input, -1));

            return Entities.recordOpMulti(connSpedmon
                                           , log
                                           , uInfo
                                           , editDelReason
                                           , validateRec
                                           , recIDs
                                           , "CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_JSON_MULTISAVE"
                                           , true
                                           , ref parms);
        }


    }


}

