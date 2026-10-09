using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using MBA;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;

namespace Spedmon
{
    
  /***************************************************************************
   * PlanWriterPlan */
  /**
   *
   ***************************************************************************/

  public class PlanWriterPlan : Entity
  {
    public long     clientID;
    public string   clientName;
    public long     groupServiceClassNameID;    
    public DateTime planDateVal;
    public string   planDateStr;
    public long     planTypeID;
    public string   planTypeName;
    public long     patientID;    
    public string   patientName;    
    public DateTime patientDOBVal;        
    public string   patientDOBStr;
    public string   patientStudentID;
    public string   patientGrade;
    public string   patientSiteName; 
    public long     planCreatorUserID;
    public bool     planCreatorSigned;
    public string   planCreatorSignedDate;
    public string   planCreatorSignedName;
    public string   planCreatorSignatureImg; 
  }
      
  /***************************************************************************
   * PlanWriterPlanJSON */
  /**
   *
   ***************************************************************************/

  public class PlanWriterPlanJSON : Entity
  {
        public const string DEFAULT_PAGING_ORDER = @"patName asc, planDateVal asc";

        public string patName;
        public long   patID;
        public string planDate;
        public DateTime planDateVal;
        public string planDateStr;
        public string planDateStrYMD;
        public long   diagnosisID;
        public string diagnosisName;
        public string diagnosisDesc;
        public string orpDocSelectionsJSON;
        public string participantsJSON;
        public bool   planCreatorSigned;
        public string planCreatorSignedDate;
        public string planCreatorSignatureImg;
        public long   createdBy;
        public string planCreatorLname;
        public string planCreatorFname;
        public string planCreatorEmail;
        public string planCreatorPhone;
        public long   recID;
        public long   authReqRecID;
        public int    saveType;
        public bool   hasUnsavedChanges;
  }
  
  /***************************************************************************
   * PlanWriterPlans */
  /**
   *
   ***************************************************************************/
  
  public class PlanWriterPlans : Entities
  {
    public static string URL_ASHX      = "plan_writer_plans_file.ashx";

    public static string URL_ASPX_SAVE = "user_all_care_plan_save.aspx";
    public static string URL_PDF_PREVIEW = "user_all_care_plan_pdf_preview.aspx";

    public static string URL_ASMX           = "plan_writer_plans.asmx";
    public static string URL_ASMX_LOAD_JSON = URL_ASMX + "/loadJSON";
    public static string URL_ASMX_SAVE      = URL_ASMX + "/save";
    public static string URL_ASMX_SAVE_NO_JSON = URL_ASMX + "/saveNoJSON";
    public static string URL_ASMX_DELETE    = URL_ASMX + "/delete2";
    public static string URL_ASMX_REQ_AUTH  = URL_ASMX + "/requestAuthorization";
    public static string URL_ASMX_VIEW_SEL_ORP_DOCS  = URL_ASMX + "/viewSelORPDocs";
    public static string URL_ASMX_CHANGE_PLAN_AUTHOR = URL_ASMX + "/changeplanauthor";
    public static string VAL_FILE_CLASS_HEALTH_CARE_INSTRUCTIONS = "8"; 
    public static string SEL_LABEL_MANAGE = "Manage Care Plans"; 
    public static string URL_USER_ALL_MANAGE_PLANS = "user_all_care_plan_save.aspx"; 

    public static string URL_REST_VIEW = "api/v1/planwriterplans"; 
  
    public static string GEN_URL_ASPX_SAVE() { 
        return MBA.HttpApplication.createLink(URL_ASPX_SAVE, true);
    }
    public static string GEN_URL_ASPX_CHANGE_PLAN_AUTHOR()
    {
        return MBA.HttpApplication.createLink(URL_ASMX_CHANGE_PLAN_AUTHOR,true);
    }

    public static string GEN_URL_ASMX_LOAD_JSON() { 
        return MBA.HttpApplication.createLink(URL_ASMX_LOAD_JSON, true);
    }  
    public static string URL_ASMX_SAVE_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_SAVE, true);
    } 
    public static string URL_ASMX_SAVE_NO_JSON_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_SAVE_NO_JSON, true);
    }
    public static string URL_REST_VIEW_BASE() { 
        return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
    }
    public static string URL_ASMX_DELETE_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_DELETE, true);
    }
    public static string URL_ASMX_REQ_AUTH_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_REQ_AUTH, true);
    }
    public static string URL_ASMX_VIEW_SEL_ORP_DOCS_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_VIEW_SEL_ORP_DOCS, true);
    }
    public static string URL_ASHX_BASE() { 
        return MBA.HttpApplication.createLink(URL_ASHX, true);
    }
    public static string URL_PDF_PREVIEW_BASE() { 
        return MBA.HttpApplication.createLink(URL_PDF_PREVIEW
            , true
            , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
            );
    }

    /***************************************************************************
     * save */
    /**
        * Save 
        *
        * @param  userID          User id of who is recording service
        * @param  userGroup       1 = Client, 2 = SBSC (from users db)
        * @param  userRank        Users role ranking
        * @param  clientID        Patient's client id
        * @param  patID
        *
        * @param  editDelReason   Reason for record edit or delete
        * @param  validateRec     1 = Performs data integrity validation tasks
        *                             Perform advisory validation tasks that can
        *                             only be conducted by referencing data from the
        *                             database and then exits WITHOUT saving the record
        *                         0 = Peform data integrity validation tasks and
        *                             if these tasks succeed peforms the desired
        *                             operation (saveType) on the record and exits
        * @param  saveType        Type of operation to perform
        *                         1 = New, 2 = Edit, 3 = Delete
        * @param  recID           Record id of existing patient record to edit or
        *                         delete.
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

    public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        planTypeID
                                          , string        planDataJSON
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )  
    {
     
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     

      long     vClientID            = Validate.reqClientID (uInfo, clientID);      
      long     vPlanTypeID          = Validate.reqInteger  (planTypeID,   Messages.INVALID_PLAN_TYPE);
      string   vPlanDataJSON        = Validate.reqString   (planDataJSON, "Invalid JSON data");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planTypeID",           SqlDbType.BigInt,  vPlanTypeID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planDataJSON",         SqlDbType.VarChar, vPlanDataJSON,          ParameterDirection.Input, -1));
                 
      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "PLAN_WRITER_PLANS_ALL_INFO_Save"
                            , "There is already an active plan for this patient and date"
                            , ref parms
                            , null );
        }

       /***************************************************************************
        * changePlanAuthor  */
       /**
        * Change plan author
        *
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

    public static ReturnSaveRecord changePlanAuthor ( SqlConnection connSpedmon
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , string        clientID                                                     
                                                     , string        newPlanAuthorUserID
                                                     , string        recID )
    {
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      var parms = new List<SqlParameter>();

      long  vClientID            = Validate.reqClientID (uInfo, clientID);      
      long  vNewPlanAuthorUserID = Validate.reqInteger  (newPlanAuthorUserID, @"Invalid user ID");
      
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@newPlanAuthorUserID", SqlDbType.BigInt, vNewPlanAuthorUserID, ParameterDirection.Input));
      
      return Entities.recordOp (  connSpedmon
                                , log
                                , uInfo
                                , @""
                                , @"N"
                                , recID
                                , @"PLAN_WRITER_PLANS_CHANGE_AUTHOR"
                                , ref parms );

    }

    /// <summary>
    /// This is a copy of the save method where the parameters
    /// that were passed in a JSON to that method are opened up as seperate
    /// parameters in this one
    /// </summary>
    public static ReturnSaveRecord saveNoJSON(   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        planTypeID
                                          , string        patID			      
                                          , string        planDate			      
                                          , string        diagnosisID		      
                                          , string        diagnosisName	      
                                          , string        diagnosisDesc		  
                                          , string        orpDocSelectionsJSON	  
                                          , string        participantsJSON		  
                                          , string        planCreatorSigned	  
                                          , string        planCreatorSignedDate  
                                          , string        planCreatorSignatureImg
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )  
    {
     
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     

      long     vClientID                 = Validate.reqClientID (uInfo                  , clientID);      
      long     vPlanTypeID               = Validate.reqInteger  (planTypeID             , Messages.INVALID_PLAN_TYPE);
      var      vPatID			         = Validate.reqInteger  (patID			        , Messages.INVALID_PAT_ID);
      var      vPlanDate			     = Validate.reqDate     (planDate			    , "Invalid plan date");
      var      vDiagnosisID		         = Validate.optInteger  (diagnosisID		    , "Invalid diagnosis ID");
      var      vDiagnosisName	         = Validate.optString   (diagnosisName	        , "Invalid diagnosis name");
      var      vDiagnosisDesc		     = Validate.optString   (diagnosisDesc		    , "Invalid diagnosis description");
      var      vOrpDocSelectionsJSON	 = Validate.optString   (orpDocSelectionsJSON	, "Invalid ORP document selection(s)");
      var      vParticipantsJSON		 = Validate.optString   (participantsJSON		, "Invalid participant selection(s)");
      var      vPlanCreatorSigned	     = Validate.reqString   (planCreatorSigned	    , "Invalid plan creator signature flag");
      var      vPlanCreatorSignedDate    = Validate.optDate     (planCreatorSignedDate  , "Invalid plan creator signature");
      var      vPlanCreatorSignatureImg  = Validate.optString   (planCreatorSignatureImg, "Invalid plan creator signature img");
      
      parms.Add(Database.SqlParm("@clientID"               ,         SqlDbType.BigInt,  vClientID               ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@planTypeID"             ,         SqlDbType.BigInt,  vPlanTypeID             ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@patID"                  ,         SqlDbType.VarChar, vPatID			        ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@planDate"               ,         SqlDbType.VarChar, vPlanDate			    ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@diagnosisID"            ,         SqlDbType.VarChar, vDiagnosisID		    ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@diagnosisName"          ,         SqlDbType.VarChar, vDiagnosisName	        ,         ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@diagnosisDesc"          ,         SqlDbType.VarChar, vDiagnosisDesc		    ,         ParameterDirection.Input, -1 ));
      parms.Add(Database.SqlParm("@orpDocSelectionsJSON"   ,         SqlDbType.VarChar, vOrpDocSelectionsJSON   ,         ParameterDirection.Input, -1 ));
      parms.Add(Database.SqlParm("@participantsJSON"       ,         SqlDbType.VarChar, vParticipantsJSON	    ,         ParameterDirection.Input, -1 ));
      parms.Add(Database.SqlParm("@planCreatorSigned"      ,         SqlDbType.VarChar, vPlanCreatorSigned	    ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@planCreatorSignedDate"  ,         SqlDbType.VarChar, vPlanCreatorSignedDate  ,         ParameterDirection.Input     ));
      parms.Add(Database.SqlParm("@planCreatorSignatureImg",         SqlDbType.VarChar, vPlanCreatorSignatureImg,         ParameterDirection.Input, -1 ));
                 
      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "PLAN_WRITER_PLANS_ALL_INFO_SAVE_NO_JSON"
                            , "There is already an active plan for this patient and date"
                            , ref parms
                            , null );
    }



    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
                                  , string        patientID
                                  , string        groupSvcClassNameID
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PLAN_WRITER_PLANS_VIEW (@userID, @userGroup, @userRank, @clientID, @patientID, @groupSvcClassNameID, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long   vClientID            = Validate.reqClientID                      (uInfo, clientID);
      Object vPatientID           = Validate.optInteger                       (patientID, Messages.INVALID_PAT_ID);
      Object vGroupSvcClassNameID = Validate.optPlanWriterGroupSvcClassNameID (uInfo, groupSvcClassNameID);      
      Object vTerm                = Validate.optString                        (term,  @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patientID",            SqlDbType.BigInt,  vPatientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt,  vGroupSvcClassNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar, vTerm,                 ParameterDirection.Input, 256));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
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
                            , dc );    
    }
    
    /***************************************************************************
     * viewJSON */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB viewJSON(SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        canEdit
                                     , string        active
                                     , string        clientID
                                     , string        patientID
                                     , string        pracID
                                     , string        siteID
                                     , string        fiscalYearID
                                     , string        isCreatedByCaller
                                     , string        isExpiring     
                                     , string        isExpired
                                     , string        term
                                     , defineCols    dc )
    { 
      
      string viewUDF = @"dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW (@userID, @userGroup, @userRank, @clientID, @patientID, @pracID, @siteID, @fiscalYearID, @isCreatedByCaller, @isExpiring, @isExpired, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long   vClientID            = Validate.reqClientID (uInfo, clientID);
      Object vPatientID           = Validate.optInteger  (patientID, Messages.INVALID_PAT_ID);
      Object vPracID              = Validate.optInteger  (pracID, Messages.INVALID_PRAC_ID);
      Object vSiteID              = Validate.optInteger  (siteID, Messages.INVALID_SITE_ID);
      Object vFiscalYearID        = Validate.optInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
      Object vIsCreatedByCaller   = Validate.optFlag     (isCreatedByCaller, Messages.INVALID_FLAG);
      Object vIsExpiring          = Validate.optFlag     (isExpiring, Messages.INVALID_FLAG);
      Object vIsExpired           = Validate.optFlag     (isExpired, Messages.INVALID_FLAG);
      Object vTerm                = Validate.optString   (term,  @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patientID",            SqlDbType.BigInt,  vPatientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",               SqlDbType.BigInt,  vPracID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",               SqlDbType.BigInt,  vSiteID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID",         SqlDbType.BigInt,  vFiscalYearID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isCreatedByCaller",    SqlDbType.BigInt,  vIsCreatedByCaller,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isExpiring",           SqlDbType.BigInt,  vIsExpiring,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isExpired",            SqlDbType.BigInt,  vIsExpired,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar, vTerm,                 ParameterDirection.Input, 256));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
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
                            , dc );    
    }
        
    /***************************************************************************
     * viewSelJSON */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSelJSON (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID                                                                         
                                      , string        patientID 
                                      , string        pracID
                                      , string        siteID
                                      , string        fiscalYearID
                                      , string        isCreatedByCaller
                                      , string        isExpiring     
                                      , string        isExpired
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("id                                      as id", true);
          ss.addDisplayColumn("planDate                                as recData1");
          ss.addDisplayColumn("convert(varchar,diagnosisID)            as recData2");
          ss.addDisplayColumn("diagnosisName                           as recData3");
          ss.addDisplayColumn("diagnosisDesc                           as recData4");
          ss.addDisplayColumn("orpDocSelectionsJSON                    as recData5");
          ss.addDisplayColumn("participantsJSON                        as recData6");
          ss.addDisplayColumn("convert(varchar, planCreatorSigned)     as recData7");
          ss.addDisplayColumn("planCreatorSignedDate                   as recData8");
          ss.addDisplayColumn("planCreatorSignatureImg                 as recData9");
          ss.addDisplayColumn("convert(varchar, createdBy)             as recData10");
          ss.addDisplayColumn("planCreatorLname                        as recData11");
          ss.addDisplayColumn("planCreatorFname                        as recData12");
          ss.addDisplayColumn("planCreatorEmail                        as recData13");
          ss.addDisplayColumn("planCreatorPhone                        as recData14");
          ss.addDisplayColumn("patName                                 as recData15");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PlanWriterPlans.viewJSON (   connSpedmon
                                                                , log
                                                                , uInfo
                                                                , Entities.REC_VIEW_SEL_CUSTOM
                                                                , top
                                                                , topSize
                                                                , ""
                                                                , "Y"
                                                                , clientID
                                                                , patientID
                                                                , pracID
                                                                , siteID
                                                                , fiscalYearID
                                                                , isCreatedByCaller
                                                                , isExpiring     
                                                                , isExpired
                                                                , term
                                                                , dc); 
                                  });
                                                                    
    }

        
    /*************************************************************************
    * viewListJSON */
   /**
    * Return a list of PlanWriterPlan
    * 
    ***************************************************************************/

    public static List<PlanWriterPlanJSON> viewListJSON( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patientID
                                                         , string        active)
      
     {
        var recs = new List<PlanWriterPlanJSON>();
        ReturnDB rd = PlanWriterPlans.viewJSON(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, "", active, clientID, patientID, "", "",  "", "", "", "", "", null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PlanWriterPlanJSON));
        foreach (var o in slo) {
            recs.Add((PlanWriterPlanJSON) o);
        }
        return recs;
    }


    /***************************************************************************
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID                                                                         
                                      , string        groupSvcClassNameID  
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("convert(varchar,patientID)  as recData1");
          ss.addDisplayColumn("patientName as recData2");
          ss.addDisplayColumn("planDateStr as recData3");
          ss.addDisplayColumn("convert(varchar,planTypeID) as recData4");
          //ss.addDisplayColumn("description as context1");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PlanWriterPlans.view (   connSpedmon
                                                                , log
                                                                , uInfo
                                                                , Entities.REC_VIEW_SEL
                                                                , top
                                                                , topSize
                                                                , ""
                                                                , "Y"
                                                                , clientID
                                                                , ""
                                                                , groupSvcClassNameID
                                                                , term
                                                                , dc); 
                                  });
                                                                    
    }

    /***************************************************************************
     * load */
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

    public static PlanWriterPlan load (  SqlConnection connSpedmon
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        clientID
                                             , string        groupSvcClassNameID
                                             , string        recID )
    {
      return (PlanWriterPlan) Entities.load (   connSpedmon
                                              , log
                                              , uInfo
                                              , recID
                                              , typeof (PlanWriterPlan)
                                              , delegate {          
                                                    return PlanWriterPlans.view (  connSpedmon
                                                                                  , log
                                                                                  , uInfo
                                                                                  , Entities.REC_VIEW_LOAD
                                                                                  , false
                                                                                  , recID
                                                                                  , ""
                                                                                  , ""
                                                                                  , clientID
                                                                                  , ""
                                                                                  , groupSvcClassNameID
                                                                                  , ""
                                                                                 , null );
                                                 });
    }

    public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool pageObjectList
                                                , string pageOrder
                                                , string idx
                                                , string active
                                                , string clientID
                                                , string patientID
                                                , string pracID
                                                , string siteID
                                                , string fiscalYearID
                                                , string isCreatedByCaller
                                                , string isExpiring
                                                , string isExpired
                                                , string term
    )
    {

        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PlanWriterPlanJSON.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
            * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        return Entities.viewObjects(connSpedmon
                                        , log
                                        , uInfo
                                        , typeof(PlanWriterPlanJSON)
                                        , pageObjectList
                                        , pageOrder
                                        , delegate
                                        {
                                            return viewJSON(
                                                      connSpedmon
                                                    , log
                                                    , uInfo
                                                    , Entities.REC_VIEW_OBJECTS
                                                    , pageObjectList
                                                    , idx
                                                    , "" // canEdit
                                                    , active
                                                    , clientID
                                                    , patientID
                                                    , pracID
                                                    , siteID
                                                    , fiscalYearID
                                                    , isCreatedByCaller
                                                    , isExpiring
                                                    , isExpired
                                                    , term
                                                    , dc
                                            );
                                        });
    }

   
    /***************************************************************************
     * delete */
    /**    
     *
     * @param  editDelReason   Reason for edit/delete
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        clientID
                                            , string        groupSvcClassNameID
                                            , string        recID )
    {

        /*----------------------------
         * Check for required and
         * optional parameters
         * and validate data integrity
         * of all supplied parameters
         *----------------------------*/

        long     vClientID            = Validate.reqClientID (uInfo, clientID);      
        Object   vGroupSvcClassNameID = Validate.optPlanWriterGroupSvcClassNameID (uInfo, groupSvcClassNameID);
        
        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
  
        parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
        parms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt,  vGroupSvcClassNameID,  ParameterDirection.Input));

        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "PLAN_WRITER_PLANS_Delete"
                                 , ref parms);
    }

    /***************************************************************************
     * viewORPDocs */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB viewORPDocs (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
				                				  , string        rdrPracID
				                				  , string        rdrGroupSvcClassNameID
				                				  , string        patID
                                  , string        dos
                                  , string        term
                                  , string        includeOnlyOrpDocTypeIDs
                                  , string        displayRank
                                  , defineCols    dc )
    {
    
      string viewUDF = "dbo.ORP_DOCUMENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @rdrPracID, @rdrGroupSvcClassNameID, @patID, @dos, @term, null, null, @includeOnlyOrpDocTypeIDs, @displayRank, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      Object  vClientID               = Validate.optClientID (uInfo,  clientID);      
      //Object  vRdrPracID              = Validate.optInteger   (rdrPracID, Messages.INVALID_NUMBER);
      Object  vRdrPracID              = Validate.optPracID   (uInfo,rdrPracID);
      Object  vRdrGroupSvcClassNameID = Validate.optInteger  (rdrGroupSvcClassNameID, Messages.INVALID_GROUP_ID);     
      Object  vPatID                  = Validate.optInteger  (patID,                  Messages.INVALID_PAT_ID);
	  Object  vDOS                    = Validate.optDate     (dos,                    Messages.INVALID_DOS);
      Object  vTerm                   = Validate.optString   (term,                   Messages.INVALID_SEARCH_TERM);
      
      Object  vIncludeOnlyOrpDocTypeIDs = Validate.optRecIDMultiStr(includeOnlyOrpDocTypeIDs, @"Invalid orp doc type ids");
      Object  vDisplayRank              = Validate.optInteger  (displayRank, @"Invalid display ranking");
	    
	  List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrPracID",                SqlDbType.BigInt,   vRdrPracID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrGroupSvcClassNameID",   SqlDbType.BigInt,   vRdrGroupSvcClassNameID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                    SqlDbType.BigInt,   vPatID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",                      SqlDbType.Date,     vDOS,                         ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@term",                     SqlDbType.VarChar,  vTerm,                        ParameterDirection.Input, 255));	    
	  parms.Add(Database.SqlParm("@includeOnlyOrpDocTypeIDs", SqlDbType.VarChar,  vIncludeOnlyOrpDocTypeIDs,    ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@displayRank",              SqlDbType.BigInt,   vDisplayRank,                 ParameterDirection.Input));
	    
	    	  
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }
    
    /***************************************************************************
     * viewSelORPDocs */
    /**
     * Returns a 
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/
  
    public static ReturnSel viewSelORPDocs (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        rdrPracID				                				  
                                      , string        patID  
                                      , string        includeOnlyOrpDocTypeIDs
                                      , string        term ) 
    {
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        
        ss.addDisplayColumn("context1");        
        ss.addDisplayColumn("svcNoteTemplateTitle           as [recData1]");
        ss.addDisplayColumn("svcNoteTemplateText            as [recData2]");
        ss.addDisplayColumn("orpPracName                    as [recData3]");
        ss.addDisplayColumn("startDateStr                   as [recData4]");
        ss.addDisplayColumn("CONVERT(varchar, orpDocTypeID) as [recData5]");
        ss.addDisplayColumn("CONVERT(varchar, refID)        as [recData6]");
        
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate{ return                              
                                PlanWriterPlans.viewORPDocs (  connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_SEL
                                                   , top
                                                   , topSize
                                                   , ""                                                  
                                                   , "1"                                                  
                                                   , clientID
                                                   , rdrPracID
                                                   , null
                                                   , patID
                                                   , ""
                                                   , term
                                                   , includeOnlyOrpDocTypeIDs
                                                   , @"1"    /* Limits patient profiles to most current*/
                                                   , dc );
                              });
    }
    

   /*############################################################################################################
     #
     # Plan Custom PDF Generation
     #
     ###########################################################################################################*/ 
                                                                    
   /**************************************************************************
     * pdfGenerateCellLabelAndText */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell pdfGenerateCellLabelAndText (  ref Font cellLabelFont
                                                           , ref Font cellTextFont                                                                                                                                
                                                           , int   rowSpan
                                                           , int   colSpan
                                                           , int   horizontalAlign
                                                           , int   verticalAlign
                                                           , Color backgroundColor
                                                           , int   borders
                                                           , string label
                                                           , string text
                                                           , bool insertNewline
                                                           )
    {        
      String strLabel = String.Format(@"{0} : " , label);
      String strText  = String.Format(@"{0}"    , text);
    
      Phrase    p1 = new Phrase (strLabel,cellLabelFont);
      Phrase    p2 = new Phrase(Chunk.NEWLINE);
      Phrase    p3 = new Phrase (strText, cellTextFont);
      Paragraph  p = new Paragraph();
      
      p.Add(p1);
      
      if (insertNewline == true) {
        p.Add(p2);
      }
      
      p.Add(p3);    
      
      PdfPCell c = PDFCommon.generateCell(p,rowSpan,colSpan,horizontalAlign,verticalAlign,backgroundColor,borders);
      
      return c;
    }

    /**************************************************************************
     * pdfGenerateCellLabelAndTextLong */
    /**
     *
     **************************************************************************/  

    protected static void pdfGenerateCellLabelAndTextLong (  ref Font cellLabelFont
                                                           , ref Font cellTextFont                                                                                                                                
                                                           , int   rowSpan
                                                           , int   colSpan
                                                           , int   horizontalAlign
                                                           , int   verticalAlign
                                                           , Color backgroundColor
                                                           , int   borders
                                                           , string label
                                                           , string text
                                                           , bool insertNewline
                                                           , ref List<PdfPCell> cells
                                                           )
    {        
      String strLabel = String.Format(@"{0} : " , label);
      String strText  = String.Format(@"{0}"    , text);
    
      Phrase    p1 = new Phrase (strLabel,cellLabelFont);
      Phrase    p2 = new Phrase(Chunk.NEWLINE);
      Phrase    p3 = new Phrase (strText, cellTextFont);
      Paragraph  p = new Paragraph();
      
      if (!String.IsNullOrEmpty(label)) p.Add(p1);
      
      if (!String.IsNullOrEmpty(label) && insertNewline == true) {
        p.Add(p2);
      }

      cells.Add(PDFCommon.generateCell(p, rowSpan, colSpan, horizontalAlign, verticalAlign, backgroundColor, borders));

      foreach (string chunk in strText.Replace("\\n", "\n").Split('\n')) {
            // paragraph that stores each chunk to be turned into a cell
            Paragraph  par = new Paragraph();

            par.Add(new Phrase(chunk, cellTextFont));

            cells.Add(PDFCommon.generateCell(par, rowSpan, colSpan, horizontalAlign, verticalAlign, backgroundColor, borders));
      }      
      
      return;
    }

    /**************************************************************************
     * pdfAddPlanFileCellsLabelInlineAndText */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileCellsLabelInlineAndText (  ref Font cellLabelInlineFont
                                                                 , ref Font cellTextFont                                                                
                                                                 , ref List<PdfPCell> cells
                                                                 , int   rowSpan
                                                                 , int   colSpan
                                                                 , int   horizontalAlign
                                                                 , int   verticalAlign
                                                                 , Color backgroundColor
                                                                 , int   borders                                                                 
                                                                 , string label
                                                                 , string text                                                                 
                                                                )
    {        
            
      PdfPCell c1 = pdfGenerateCellLabelAndText (  ref cellLabelInlineFont
                                                 , ref cellTextFont                                                                                                                                
                                                 , rowSpan
                                                 , colSpan
                                                 , horizontalAlign
                                                 , verticalAlign
                                                 , backgroundColor
                                                 , borders
                                                 , label
                                                 , text
                                                 , false);      
      cells.Add(c1);
   
   }
   
   
   /**************************************************************************
    * pdfAddPlanFileCellsLabelInlineAndText */
   /**
    *
    **************************************************************************/  

   protected static void pdfAddPlanOrderSvcDescOrFormFileCellsLabelInlineAndText (  
                                                                   ref iTextSharp.text.Document doc
                                                                 , ref MemoryStream ms
                                                                 , ref PdfWriter writer
                                                                 , ref Font cellLabelInlineFont
                                                                 , ref Font cellTextFont                                                                
                                                                 , ref List<PdfPCell> cells                                             
                                                                 , int    rowSpan
                                                                 , int    colSpan
                                                                 , int    borders                                                                 
                                                                 , string label
                                                                 , PlanWriterPlansPrescribedOrder order
                                                                )
  {
           // if form data exists, use it instead of service description
           if (!String.IsNullOrEmpty(order.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(order.formBuilderAnswersJSON))
           {
               // build a dictionary of form answers
               Dictionary<String, String> formAnswersDict = PDFFormGeneration.savedAnswersJsonToDict(order.formBuilderAnswersJSON);
            
               List<PdfPCell> frmCells = new List<PdfPCell>();
               

               PDFFormGeneration.insertFormFieldsToPDFCells(
                         ref writer
                       , ref doc
                       , ref frmCells
                       , order.formBuilderQuestionsJSON
                       , formAnswersDict
                       , PDFFormGeneration.Constants.numColsBase12);

               //MemoryStream msWithAnswers = new MemoryStream();
               //doc.Close();
               //msWithAnswers = PDFFormGeneration.insertAnswersToPdf(ref ms, formAnswersDict);
               //ms = new MemoryStream(msWithAnswers.ToArray());

               PdfPTable frmTbl = PDFCommon.generateTable(12, frmCells);
               frmTbl.SpacingBefore = 0;
               frmTbl.SpacingAfter = 0;
               frmTbl.TotalWidth  = 600f;
               frmTbl.LockedWidth = true; 
               doc.Add(frmTbl);
           }
           else
           {

               pdfAddPlanFileCellsLabelInlineAndText(ref cellLabelInlineFont
                                                       , ref cellTextFont
                                                       , ref cells
                                                       , 1
                                                       , 3
                                                       , PDFCommon.CELL_BORDERS_BOTTOM_LEFT_MIDDLE_RIGHT
                                                       , @"Service Description"
                                                       , order.svcDesc
                                                       );
           }

           
           PdfPTable tbl = PDFCommon.generateTable(3, cells);
           tbl.SpacingBefore = 0;
           tbl.SpacingAfter  = 0;
           tbl.TotalWidth  = 600f;
           tbl.LockedWidth = true; 
           doc.Add(tbl);
  }
   
     
   /**************************************************************************
    * pdfAddPlanFileCellsLabelInlineAndText */
   /**
    *
    **************************************************************************/  

   protected static void pdfAddPlanFileCellsLabelInlineAndText (  ref Font cellLabelInlineFont
                                                                 , ref Font cellTextFont                                                                
                                                                 , ref List<PdfPCell> cells                                             
                                                                 , int    rowSpan
                                                                 , int    colSpan
                                                                 , int    borders                                                                 
                                                                 , string label
                                                                 , string text
                                                                )
   {        
      
     pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                            , ref cellTextFont                                                                
                                            , ref cells
                                            , rowSpan
                                            , colSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , Color.WHITE
                                            , borders
                                            , label
                                            , text );
   }    
        
   /**************************************************************************
    * pdfAddPlanFileCellsLabelInlineAndTextLong */
   /**
    *
    **************************************************************************/  

   protected static void pdfAddPlanFileCellsLabelInlineAndTextLong (  ref Font cellLabelInlineFont
                                                                 , ref Font cellTextFont                                                                
                                                                 , ref List<PdfPCell> cells                                             
                                                                 , int    rowSpan
                                                                 , int    colSpan
                                                                 , int    borders                                                                 
                                                                 , string label
                                                                 , string text
                                                                )
   {        
      
     pdfGenerateCellLabelAndTextLong (  ref cellLabelInlineFont
                                      , ref cellTextFont                                                                                                                                
                                      , rowSpan
                                      , colSpan
                                      , Rectangle.ALIGN_LEFT
                                      , Rectangle.ALIGN_MIDDLE
                                      , Color.WHITE
                                      , borders
                                      , label
                                      , text
                                      , false
                                      , ref cells
                                      );
   }
   
   /**************************************************************************
    * pdfAddPlanFileCellsLabelTopAndText */
   /**
    *
    **************************************************************************/  

   protected static void pdfAddPlanFileCellsLabelTopAndText (    ref Font cellLabelTopFont
                                                               , ref Font cellTextFont                                                                
                                                               , ref List<PdfPCell> cells                                             
                                                               , int    rowSpan
                                                               , int    colSpan
                                                               , int    borders                                                                 
                                                               , string label
                                                               , string text
                                                             )
   {        
    
    
     PdfPCell c1 = pdfGenerateCellLabelAndText (  ref cellLabelTopFont
                                                , ref cellTextFont                                                                                                                                
                                                , rowSpan
                                                , colSpan
                                                , Rectangle.ALIGN_LEFT
                                                , Rectangle.ALIGN_MIDDLE
                                                , Color.WHITE
                                                , borders
                                                , label
                                                , text
                                                , true); 
                                                  
     cells.Add(c1);
   }
   
   

   /*#############################
     #
     # Plan File Sub Components
     #
     #############################*/ 
  
    /**************************************************************************
     * pdfGenerateRotatedCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell pdfGenerateRotatedCell (  ref Font rotatedLabelFont
                                                      , int rowSpan
                                                      , int colSpan
                                                      , Color backgroundColor
                                                      , string label )
    {
           
      
      Paragraph p1 = new Paragraph (label,rotatedLabelFont);
      p1.Alignment = Rectangle.ALIGN_CENTER;      
      
      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , rowSpan
                                            , colSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_TOP
                                            , backgroundColor
                                            , PDFCommon.CELL_BORDERS_ALL);      
      c1.Rotation      = 90;
      c1.PaddingBottom = 5;
      return c1;
    }
    
    /**************************************************************************
     * pdfGenerateComponentTitleCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell pdfGenerateComponentTitleCell (  ref Font componentTitleFont
                                                             , int rowSpan
                                                             , int colSpan
                                                             , int borders
                                                             , string label )
    {
           
      
      Paragraph p1 = new Paragraph (label,componentTitleFont);
      p1.Alignment = Rectangle.ALIGN_LEFT;      
      
      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , rowSpan
                                            , colSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , Color.WHITE
                                            , borders);      
      c1.PaddingTop    = 5;
      c1.PaddingBottom = 5;
      
      return c1;
    }

    /**************************************************************************
     * pdpdfGenerateFillOutCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell pdfGenerateFillOutCell (  ref Font fillOutLabelFont
                                                      , int rowSpan
                                                      , int colSpan
                                                      , string label )
    {
                 
      Paragraph p1 = new Paragraph (label,fillOutLabelFont);
      p1.Alignment = Rectangle.ALIGN_LEFT;      
      
      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , rowSpan
                                            , colSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_TOP
                                            , Color.WHITE
                                            , PDFCommon.CELL_BORDERS_ALL);      
      c1.PaddingBottom = 25;
      
      return c1;
    }

    /**************************************************************************
     * pdpdfGenerateFillOutCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell pdfGenerateFillOutCell (  ref Font fillOutLabelFont
                                                      , int rowSpan
                                                      , int colSpan
                                                      , string label
                                                      , int paddingBottom)
    {
                 
      Paragraph p1 = new Paragraph (label,fillOutLabelFont);
      p1.Alignment = Rectangle.ALIGN_LEFT;      
      
      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , rowSpan
                                            , colSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_TOP
                                            , Color.WHITE
                                            , PDFCommon.CELL_BORDERS_ALL);      
      c1.PaddingBottom = paddingBottom;
      
      return c1;
    }
       
   /*#############################
     #
     # Plan File Components
     #
     #############################*/ 

    /**************************************************************************
     * pdfAddPlanFileComponentPlanInfo */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentPlanInfo (   ref iTextSharp.text.Document doc
                                                            , ref Font componentTitleFont
                                                            , ref Font cellTitleFont
                                                            , ref Font cellLabelTopFont
                                                            , ref Font cellLabelInlineFont
                                                            , ref Font cellTextFont
                                                            , ref Client         client
                                                            , ref PlanWriterPlan plan
                                                          )
    {
         
      List<PdfPCell> cells = new List<PdfPCell>();
      
      String compTitle = client.name + @" - Care Plan";
      
      Paragraph p1 = new Paragraph (compTitle, componentTitleFont);
      p1.Alignment = Rectangle.ALIGN_CENTER;      
      
      PdfPCell c1 = PDFCommon.generateCell (   p1
                                             , 1
                                             , 2
                                             , Rectangle.ALIGN_CENTER
                                             , Rectangle.ALIGN_CENTER
                                             , Color.WHITE
                                             , PDFCommon.CELL_BORDERS_NONE);
      
      //PdfPCell c2 = pdfGenerateCellLabelAndText (   ref cellLabelInlineFont
      //                                            , ref cellTextFont                                                                                                                                
      //                                            , 1
      //                                            , 1
      //                                            , Rectangle.ALIGN_RIGHT
      //                                            , Rectangle.ALIGN_MIDDLE
      //                                            , Color.WHITE
      //                                            , PDFCommon.CELL_BORDERS_NONE
      //                                            , @"Plan Type"
      //                                            , plan.planTypeName
      //                                            , false
      //                                          );
                                   
      
      PdfPCell c3 = pdfGenerateCellLabelAndText (   ref cellLabelInlineFont
                                    , ref cellTextFont                                                                                                                                
                                    , 1
                                    , 2
                                    , Rectangle.ALIGN_CENTER
                                    , Rectangle.ALIGN_MIDDLE
                                    , Color.WHITE
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , @"Plan Date"
                                    , plan.planDateStr
                                    , false
                                   );
      
      //c2.PaddingRight = 5;
      c3.PaddingLeft  = 5;
      
      cells.Add(c1);
      //cells.Add(c2);
      cells.Add(c3);
      
      PdfPTable tbl     = PDFCommon.generateTable(2,cells);
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;   
      tbl.SpacingAfter  = 5;
      doc.Add(tbl);
    }
    
    /**************************************************************************
     * pdfAddPlanFileComponentPatientInfo */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentPatientInfo (   ref iTextSharp.text.Document doc
                                                               , ref Font componentTitleFont
                                                               , ref Font cellTitleFont
                                                               , ref Font cellLabelTopFont
                                                               , ref Font cellLabelInlineFont
                                                               , ref Font cellTextFont                                                                 
                                                               , ref Patient patient
                                                               , ref Site    site
                                                             )
    {
    
      List<PdfPCell> cells = new List<PdfPCell>();

      /* Row 1 */
      
      cells.Add(pdfGenerateComponentTitleCell (  ref componentTitleFont
                                               , 1
                                               , 5
                                               , PDFCommon.CELL_BORDERS_ALL
                                               , @"Patient and Plan Participant Information"));
      /* Row 2 */
      
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                                                                       
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_TOP_LEFT                                             
                                             , @"Student"
                                             , patient.firstName.Trim() + ' ' + patient.lastName.Trim()                                             
                                             );
                                                                
   
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 1
                                             , PDFCommon.CELL_BORDERS_TOP_MIDDLE
                                             , @"Date of Birth"
                                             , patient.dob.ToShortDateString()                                             
                                             );

      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2                                             
                                             , PDFCommon.CELL_BORDERS_TOP_RIGHT
                                             , @"Student ID"                                             
                                             , patient.siteRefID
                                             );

      /* Row 3 */
      
     pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_BOTTOM_LEFT
                                             , @"School Name"
                                             , site.name
                                             );

      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 1                                             
                                             , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE
                                             , @"Grade"
                                             , patient.siteRank                                         
                                            );

      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells 
                                             , 1
                                             , 2                                                                                         
                                             , PDFCommon.CELL_BORDERS_BOTTOM_RIGHT
                                             , @"School Address"
                                             , site.AddressLine
                                             );      

      PdfPTable tbl = PDFCommon.generateTable(5,cells);
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;   
      tbl.SpacingAfter = 0;
      doc.Add(tbl);
    }

    /**************************************************************************
     *  pdfAddPlanFileComponentParticipantParentInfo */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentParticipantParentInfo (    ref iTextSharp.text.Document doc
                                                                        , ref Font componentTitleFont
                                                                        , ref Font cellTitleFont
                                                                        , ref Font cellLabelTopFont
                                                                        , ref Font cellLabelInlineFont
                                                                        , ref Font cellTextFont 
                                                                        , ref PlanWriterPlansPatientPerson person
                                                                        )
    {
    
      List<PdfPCell> cells = new List<PdfPCell>();

      /* Row 1 */
      
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                                                                       
                                             , 1
                                             , 3
                                             , PDFCommon.CELL_BORDERS_TOP_LEFT                                             
                                             , person.className2
                                             , person.firstName.Trim() + ' ' + person.lastName.Trim()                                             
                                             );
                                                                
   
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_TOP_MIDDLE
                                             , @"Email"
                                             , person.email
                                             );
     
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_TOP_RIGHT
                                             , @"Phone"
                                             , person.phone
                                             );

      /* Row 2 */
      
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 7                     
                                             , PDFCommon.CELL_BORDERS_BOTTOM_LEFT_MIDDLE_RIGHT
                                             , @"Address"
                                             , person.placeAddress                                             
                                             );

      PdfPTable tbl = PDFCommon.generateTable(7,cells);
      tbl.SpacingAfter  = 0;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true; 
      doc.Add(tbl);   
   
    }


    /**************************************************************************
     *  pdfAddPlanFileComponentParticipantParentInfo */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentParticipantOtherInfo (   ref iTextSharp.text.Document doc
                                                                        , ref Font componentTitleFont
                                                                        , ref Font cellTitleFont
                                                                        , ref Font cellLabelTopFont
                                                                        , ref Font cellLabelInlineFont
                                                                        , ref Font cellTextFont 
                                                                        , ref PlanWriterPlansPatientPerson person
                                                                        )
    {
    
      List<PdfPCell> cells = new List<PdfPCell>();

      /* Row 1 */
      
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                                                                       
                                             , 1
                                             , 3
                                             , PDFCommon.CELL_BORDERS_TOP_BOTTOM_LEFT                                            
                                             , person.className2
                                             , person.firstName.Trim() + ' ' + person.lastName.Trim()                                             
                                             );
                                                                
   
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_TOP_BOTTOM_MIDDLE
                                             , @"Email"
                                             , person.email
                                             );
     
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                          
                                             , 1
                                             , 2
                                             , PDFCommon.CELL_BORDERS_TOP_BOTTOM_RIGHT
                                             , @"Phone"
                                             , person.phone
                                             );

      PdfPTable tbl = PDFCommon.generateTable(7,cells);
      tbl.SpacingAfter  = 0;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true; 
      doc.Add(tbl);      
    }

    /**************************************************************************
     * pdfAddPlanFileComponentDiagnosis */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentDiagnosis (  ref iTextSharp.text.Document doc
                                                                     , ref Font componentTitleFont
                                                                     , ref Font cellTitleFont
                                                                     , ref Font cellLabelTopFont
                                                                     , ref Font cellLabelInlineFont
                                                                     , ref Font cellTextFont
                                                                     , ref PlanWriterPlanDiagnosis diagnosis )
    {
      List<PdfPCell> cells = new List<PdfPCell>();

      /* Row 1 */
      
      pdfAddPlanFileCellsLabelInlineAndText (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                                                                       
                                             , 1
                                             , 4
                                             , PDFCommon.CELL_BORDERS_TOP_LEFT_MIDDLE_RIGHT                                           
                                             , @"Diagnosis"
                                             , diagnosis.name
                                             );
      /* Row 2 */                                                         
   
      pdfAddPlanFileCellsLabelInlineAndTextLong (  ref cellLabelInlineFont
                                             , ref cellTextFont                                                                
                                             , ref cells                                                                                                                                       
                                             , 1
                                             , 4
                                             , PDFCommon.CELL_BORDERS_MIDDLE_LEFT_RIGHT
                                             , @"Description"
                                             , diagnosis.description
                                             );


      cells.Add(PDFCommon.generateCell("", 1, 4, Rectangle.ALIGN_CENTER, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_LEFT_MIDDLE_RIGHT, 1, ref cellTextFont));

      PdfPTable tbl = PDFCommon.generateTable(4,cells);
      tbl.SpacingBefore = 5;
      tbl.SpacingAfter  = 5;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true; 
      doc.Add(tbl);    
    
    }

    /**************************************************************************
     * pdfAddPlanFileComponentPhysOrmSignature */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentPhysOrmSignature (  ref iTextSharp.text.Document doc
                                                                    , ref Font rotatedLabelFont
                                                                    , ref Font fillOutLabelFont
                                                                   )
    {
      List<PdfPCell> cells = new List<PdfPCell>();
      
      /* Row 1&2 Col 1 */
      
      cells.Add(pdfGenerateRotatedCell (  ref rotatedLabelFont, 2, 1, Color.LIGHT_GRAY, @"Authorization"));
    
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 4, @"Physician or ORP Name (Please Print)" ));
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 1, @"Phone" ));    
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 3, @"NPI #" ));
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 3, @"Medi-Cal Provider #" ));
      
      
      /* Row 2 */
      
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 9, @"Signature" ));
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 2,  @"Date" ));
      
      PdfPTable tbl = PDFCommon.generateTable(12,cells);
      
      tbl.SpacingBefore = 0;
      tbl.SpacingAfter  = 5;
      tbl.KeepTogether  = true;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;   
      doc.Add(tbl);
    
    }
                                           
    /**************************************************************************
     * pdfAddPlanFileComponentConditionServDesc */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentConditionServDesc (  ref iTextSharp.text.Document doc
                                                                     , ref PdfWriter writer
                                                                     , ref Font componentTitleFont
                                                                     , ref Font cellTitleFont
                                                                     , ref Font cellLabelTopFont
                                                                     , ref Font cellLabelInlineFont
                                                                     , ref Font cellTextFont 
                                                                     , ref Font fillOutLabelFont
                                                                     , ref PlanWriterPlansServiceDescription service
                                                                    )
    {

      List<PdfPCell> cells = new List<PdfPCell>();

      /* Row 1 */
      
      cells.Add(pdfGenerateComponentTitleCell (  ref componentTitleFont
                                               , 1
                                               , PDFFormGeneration.Constants.numColsBase12
                                               , PDFCommon.CELL_BORDERS_ALL
                                               , @"Accompanying and Monitoring Request"));
      /* Row 2 */
      
      // create a dictionary of the answers if form builder data is being used
      Dictionary<String, String> formAnswersDict = new Dictionary<string, string>();

      if (!String.IsNullOrEmpty(service.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(service.formBuilderAnswersJSON))
            formAnswersDict = PDFFormGeneration.savedAnswersJsonToDict(service.formBuilderAnswersJSON);

      /* Svc Description */      

      cells.Add(PDFFormGeneration.generateSpaceCell(PDFFormGeneration.Constants.numColsBase12));
      
      // if form data exists, use it instead of service description
      if (!String.IsNullOrEmpty(service.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(service.formBuilderAnswersJSON)) {                  
         PDFFormGeneration.insertFormFieldsToPDFCells(
                                  ref writer
                                , ref doc
                                , ref cells
                                , service.formBuilderQuestionsJSON
                                , formAnswersDict
                                , PDFFormGeneration.Constants.numColsBase12);
      } 
      
      // otherwise use service description
      else {
         pdfAddPlanFileCellsLabelInlineAndTextLong(ref cellTextFont
                                                 , ref cellTextFont
                                                 , ref cells
                                                 , 1
                                                 , PDFFormGeneration.Constants.numColsBase12
                                                 , PDFCommon.CELL_BORDERS_NONE
                                                 , null
                                                 , service.serviceDescription);
      }   
      
      PDFFormGeneration.addBarrierCell(writer, ref cells, PDFFormGeneration.Constants.numColsBase12);

      cells.Add(PDFCommon.generateCell(""
                          , 1
                          , PDFFormGeneration.Constants.numColsBase12
                          , Rectangle.ALIGN_LEFT
                          , Rectangle.ALIGN_MIDDLE
                          , PDFCommon.CELL_BORDERS_NONE
                          , 2
                          , ref cellTextFont));
                  
      PdfPTable tbl = PDFCommon.generateTable(PDFFormGeneration.Constants.numColsBase12, cells);
      tbl.SpacingBefore = 0;
      tbl.SpacingAfter  = 0;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;  
      doc.Add(tbl);    
            
    }
        
    /**************************************************************************
     * pdfAddPlanFileComponentSignatureLine */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentSignatureLine (  ref iTextSharp.text.Document doc                                                                
                                                                , ref Font cellTitleFont                                                                
                                                                , ref Font fillOutLabelFont
                                                                , ref PlanWriterPlansPatientPerson person )
    {
    
    
      List<PdfPCell> cells = new List<PdfPCell>();

      Paragraph p1 = new Paragraph (person.name, cellTitleFont);
      p1.Alignment = Rectangle.ALIGN_LEFT;      
      
      /* Row 1 */

      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , 1
                                            , 5
                                            , Rectangle.ALIGN_MIDDLE
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.COLOR_PARCHMENT
                                            , PDFCommon.CELL_BORDERS_TOP_LEFT_MIDDLE_RIGHT);
      
     
      cells.Add(c1);
      
                                                                                     
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 2, @"Name (Please Print)" ));    
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 2, @"Signature" ));
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 1, @"Date" ));
                                                                                                   
      PdfPTable tbl = PDFCommon.generateTable(5,cells);
      tbl.SpacingBefore = 2;
      tbl.SpacingAfter  = 2;
      tbl.KeepTogether = true;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;  
      doc.Add(tbl);    

    }
        
         
    /**************************************************************************
     * pdfAddPlanFileComponentSignatureLine */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentSignatureLine(   ref iTextSharp.text.Document doc
                                                                , ref Font cellTitleFont
                                                                , ref Font fillOutLabelFont
                                                                , bool   signed
                                                                , string signedName
                                                                , string signedDate
                                                                , iTextSharp.text.Image signatureImg) 
    {
    
    
      List<PdfPCell> cells = new List<PdfPCell>();

      Paragraph p1 = new Paragraph (signedName, cellTitleFont);
      p1.Alignment = Rectangle.ALIGN_LEFT;      
      
      /* Row 1 */

      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , 1
                                            , 5
                                            , Rectangle.ALIGN_MIDDLE
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.COLOR_PARCHMENT
                                            , PDFCommon.CELL_BORDERS_TOP_LEFT_MIDDLE_RIGHT);
      
     
      cells.Add(c1);
      
                                                                                     
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 2
                                        , @"Name (Please Print)" + ((signed) ? ("\n\n" + signedName) : "")
                                        , ((signed) ? 10 : 25)
                                        ));    
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, ((signatureImg == null) ? 2 : 1)
                                        , @"Signature" + ((signed) ? ("\n\nElectronically Signed By " + signedName) : "")
                                        , ((signed) ? 10 : 25)
                                        ));
      if (signatureImg != null) {
                // set absolute size for image
                signatureImg.ScaleAbsolute(80f, 30f);
                cells.Add(PDFCommon.generateCell(signatureImg, 1, 1, Rectangle.ALIGN_CENTER, Rectangle.ALIGN_MIDDLE, Color.WHITE, PDFCommon.CELL_BORDERS_TOP_BOTTOM_MIDDLE));
      }
      cells.Add(pdfGenerateFillOutCell (  ref fillOutLabelFont, 1, 1
                                        , @"Date" + ((signed) ? ("\n\n" + signedDate) : "")
                                        , ((signed) ? 10 : 25)
                                       ));  
                                                                                                   
      PdfPTable tbl = PDFCommon.generateTable(5,cells);
      tbl.SpacingBefore = 2;
      tbl.SpacingAfter  = 2;
      tbl.KeepTogether = true;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;  
      doc.Add(tbl);    

    }
        
    /**************************************************************************
     * pdfAddPlanFileComponentSectionTitle */
    /**
     *
     **************************************************************************/  

    protected static void pdfAddPlanFileComponentSectionTitle (  ref iTextSharp.text.Document doc
                                                                , ref Font componentTitleFont
                                                                , string label
                                                                , int borders                                                                
                                                               )
    {
         
      List<PdfPCell> cells = new List<PdfPCell>();
      
      Paragraph p1 = new Paragraph (label, componentTitleFont);
      p1.Alignment = Rectangle.ALIGN_CENTER;      
      
      PdfPCell c1 = PDFCommon.generateCell(   p1
                                            , 1
                                            , 2
                                            , Rectangle.ALIGN_CENTER
                                            , Rectangle.ALIGN_CENTER
                                            , Color.WHITE
                                            , borders);
      
      cells.Add(c1);
      
      PdfPTable tbl = PDFCommon.generateTable(1,cells);
      tbl.SpacingBefore = 5;
      tbl.SpacingAfter  = 5;
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;  
      doc.Add(tbl);
    }
      
    
    /**************************************************************************
     * generateRequestResponseFileDocumentSectionForOrder */
    /**
     *
     **************************************************************************/  

    protected static void generateRequestResponseFileDocumentSectionForOrder(  ref iTextSharp.text.Document doc
                                                                             , ref PdfWriter writer
                                                                             , ref MemoryStream ms
                                                                             , ref ServiceAuthorizationRequest sar  )

    {
      
      /* Grab copies of the fonts we are going to use */
      
      Font docTitleFont     = PDFCommon.generateFont(FontFactory.HELVETICA,   18, Font.BOLD,   Color.BLACK);
      Font docDiscFont      = PDFCommon.generateFont(FontFactory.HELVETICA,   8,  Font.NORMAL, Color.BLACK);
      Font cellLabelFont    = PDFCommon.generateFont(FontFactory.HELVETICA,   8, Font.BOLD,   Color.BLACK);
      Font cellTextFont     = PDFCommon.generateFont(FontFactory.HELVETICA,   8, Font.NORMAL, Color.BLACK);
      Font cellTextFontDesc = PDFCommon.generateFont(FontFactory.HELVETICA,   6,  Font.NORMAL, Color.BLACK);
      Font cellDocKeyFont   = PDFCommon.generateFont(FontFactory.COURIER,     10, Font.BOLD,   Color.RED);

      List<PdfPCell> headerCells = new List<PdfPCell>();
      List<PdfPCell> bodyCells   = new List<PdfPCell>();

      // create a dictionary of the answers if form builder data is being used
      Dictionary<String, String> formAnswersDict = new Dictionary<string, string>();

      if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(sar.formBuilderAnswersJSON))
            formAnswersDict = PDFFormGeneration.savedAnswersJsonToDict(sar.formBuilderAnswersJSON);

      /* Svc Description */      

      bodyCells.Add(PDFFormGeneration.generateSpaceCell(PDFFormGeneration.Constants.numColsBase12));
      
      // if form data exists, use it instead of service description
      if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(sar.formBuilderAnswersJSON)) {                  
         PDFFormGeneration.insertFormFieldsToPDFCells(
                                  ref writer
                                , ref doc
                                , ref bodyCells
                                , sar.formBuilderQuestionsJSON
                                , formAnswersDict
                                , PDFFormGeneration.Constants.numColsBase12);
      } 
      
      // otherwise use service description
      else {
        /* Section title */
     
        bodyCells.Add(PDFCommon.generateCell ( sar.currChainResponseSectionTitle
                                       , 1
                                       , PDFFormGeneration.Constants.numColsBase12
                                       , Rectangle.ALIGN_LEFT
                                       , Rectangle.ALIGN_MIDDLE
                                       , PDFCommon.CELL_BORDERS_NONE
                                       , 3
                                       , ref cellLabelFont
                                       , Color.WHITE));

         pdfAddPlanFileCellsLabelInlineAndTextLong(ref cellTextFont
                                                 , ref cellTextFont
                                                 , ref bodyCells
                                                 , 1
                                                 , PDFFormGeneration.Constants.numColsBase12
                                                 , PDFCommon.CELL_BORDERS_NONE
                                                 , null
                                                 , sar.svcDescription);
      }            

      /* Current authorization section */
      
      var curAuthSecTbl = ServiceAuthorizationCommon.generateAuthorizationSection (     sar.currChainResponseSectionTitle
                                                           , sar.currChainReqSvcAuthMethodSelectionID
                                                           , sar.currChainResponseCode
                                                           , sar.currChainResponseNotes
                                                           , sar.currChainResponseRecordedOnStr                                                        
                                                           , sar.currChainResponseAttestStatement
                                                           , sar.currChainRespondantSignature
                                                           , sar.currChainResponseEffectiveDateStr
                                                           , sar.currChainRespondantName
                                                           , sar.currChainRespondantNPI
                                                           , sar.currChainRespondantEmail
                                                           , sar.currChainRespondantPhone
                                                           , sar.currChainShowRespondantNPI
                                                           , PDFCommon.COLOR_PARCHMENT                                                      
                                                           , ref docDiscFont
                                                           , ref cellLabelFont
                                                           , ref cellTextFont );  


      bodyCells.Add(PDFCommon.generateCell( ref curAuthSecTbl
                                          , 1
                                          , PDFFormGeneration.Constants.numColsBase12
                                          , Rectangle.ALIGN_CENTER
                                          , Rectangle.ALIGN_TOP
                                          , PDFCommon.COLOR_PARCHMENT
                                          , PDFCommon.CELL_BORDERS_ALL
                                          , 3));

      bodyCells.Add(PDFCommon.generateCell(""
                          , 1
                          , PDFFormGeneration.Constants.numColsBase12
                          , Rectangle.ALIGN_LEFT
                          , Rectangle.ALIGN_MIDDLE
                          , PDFCommon.CELL_BORDERS_NONE
                          , 2
                          , ref cellTextFontDesc));
            
      bodyCells.Add(PDFCommon.generateCell(""
                          , 1
                          , PDFFormGeneration.Constants.numColsBase12
                          , Rectangle.ALIGN_LEFT
                          , Rectangle.ALIGN_MIDDLE
                          , PDFCommon.CELL_BORDERS_NONE
                          , 2
                          , ref cellTextFontDesc));
      
      /* Generate table that holds document itself */
      
      PdfPTable tbl  = PDFCommon.generateTable(  PDFFormGeneration.Constants.numColsBase12
                                        , 0
                                        , headerCells
                                        , bodyCells);
      
      tbl.TotalWidth  = 600f;
      tbl.LockedWidth = true;   
      float[] widths = new float[] { 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f};

      tbl.SetWidths(widths); 
      doc.Add(tbl);
    } 
                    
    /**************************************************************************
     * pdfGeneratePlanFile */
    /**
     *
     **************************************************************************/  

    public static ReturnFileBytes pdfGeneratePlanFile (   SqlConnection connSpedmon
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        clientID
                                                        , string        groupSvcClassNameID
                                                        , string        planID )
    {                        
                              
      RenderPdfCallBack cb = new RenderPdfCallBack ( delegate (   ref iTextSharp.text.Document     doc
                                                                , ref MemoryStream                 ms
                                                                , ref PdfWriter                    writer
                                                                , ref String                       title
                                                                , ref String                       author
                                                                , ref String                       batch
                                                                , ref String                       filename
                                                              )
      {
       
        /* Verify access */

        PlanWriterRecords.validateClientAccessForMethodOrHandler (  connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , clientID);
	    
        /* Generate fonts we will use */
                
        Font   sectionTitleFont     = PDFCommon.generateFont(FontFactory.HELVETICA, 12  , Font.BOLD       , Color.BLACK);
        Font   componentTitleFont   = PDFCommon.generateFont(FontFactory.HELVETICA, 10  , Font.BOLD       , Color.BLACK);
        
        Font   cellTitleFont        = PDFCommon.generateFont(FontFactory.HELVETICA, 6   , Font.BOLD       , Color.BLACK);
        Font   cellLabelTopFont     = PDFCommon.generateFont(FontFactory.HELVETICA, 6   , Font.UNDERLINE  , Color.BLACK);
        
        Font   cellLabelInlineFont  = PDFCommon.generateFont(FontFactory.HELVETICA, 8   , Font.BOLD       , Color.BLACK);
        Font   cellTextFont         = PDFCommon.generateFont(FontFactory.HELVETICA, 8   , Font.NORMAL     , Color.BLACK);
        
        Font rotatedLabelFont       = PDFCommon.generateFont(FontFactory.HELVETICA, 8  , Font.BOLD        , Color.BLACK);
        Font   fillOutLabelFont     = PDFCommon.generateFont(FontFactory.HELVETICA, 8  , Font.NORMAL      , Color.BLACK);
        
        
        /* Get global plan data */
        
        PlanWriterPlan plan;
        try {
              plan = PlanWriterPlans.load (connSpedmon, log, uInfo, clientID, groupSvcClassNameID, planID);
        } catch (Exception ex)
        {
              return;
        }
        String         patientID  = plan.patientID.ToString();        
        Client         client     = Clients.load ( connSpedmon, log, uInfo, clientID);       
        Patient        patient    = Patients.load( connSpedmon, log, uInfo, patientID);
        String         siteID     = patient.siteID.ToString();
        Site           site       = Sites.load(connSpedmon, log, uInfo, siteID);

        /* Generate plan content */
                
        /* Plan info */
        
        pdfAddPlanFileComponentPlanInfo (  ref doc
                                         , ref componentTitleFont
                                         , ref cellTitleFont
                                         , ref cellLabelTopFont
                                         , ref cellLabelInlineFont
                                         , ref cellTextFont
                                         , ref client
                                         , ref plan );
        
        /* Patient info */
        
        pdfAddPlanFileComponentPatientInfo (   ref doc
                                             , ref componentTitleFont
                                             , ref  cellTitleFont
                                            , ref  cellLabelTopFont
                                            , ref  cellLabelInlineFont
                                            , ref  cellTextFont                                                                 
                                            , ref  patient
                                            , ref    site);                                            
            

        List<PlanWriterPlansPrescribedOrder>    orders    = null; 
        List<PlanWriterPlansServiceDescription> services = null;
        List<PlanWriterPlansPatientPerson> participants = null;

        
             
        orders = PlanWriterPlansPrescribedOrders.loadAllRecords (   connSpedmon                                                                                                                          
                                                                            , log
                                                                            , uInfo
                                                                            , clientID
                                                                            , groupSvcClassNameID
                                                                            , planID);
                                                                                                               
        services = PlanWriterPlansServiceDescriptions.loadAllRecords (   connSpedmon
                                                                                 , log
                                                                                , uInfo
                                                                                , clientID
                                                                                , groupSvcClassNameID
                                                                                , planID);
        participants = PlanWriterPlansPatientPersons.loadAllRecords (   connSpedmon
                                                                                 , log
                                                                                , uInfo
                                                                                , clientID
                                                                                , groupSvcClassNameID
                                                                                , patientID 
                                                                                , planID);



        
        PlanWriterPlanDiagnosis _diagnosis = PlanWriterDiagnoses.loadPlanDiag(  connSpedmon
                                                                               , log
                                                                               , uInfo
                                                                               , clientID
                                                                               , planID );


        pdfAddPlanFileComponentDiagnosis(         ref doc
                                                , ref componentTitleFont
                                                , ref cellTitleFont
                                                , ref cellLabelTopFont
                                                , ref cellLabelInlineFont
                                                , ref cellTextFont
                                                , ref _diagnosis
                                                );


        /* Orders */


        foreach (PlanWriterPlansPrescribedOrder order in orders) {
            
            PlanWriterPlansPrescribedOrder _order = order;

            ServiceAuthorizationRequest sar;
            try {
              sar = ServiceAuthorizationRequests.load(connSpedmon,log,uInfo, _order.requestID.ToString());
            } catch(Exception ex) { 
              sar                                      = new ServiceAuthorizationRequest();
              sar.svcDescription                       = order.svcDesc;
              sar.formBuilderQuestionsJSON             = order.formBuilderQuestionsJSON;
              sar.formBuilderAnswersJSON               = order.formBuilderAnswersJSON;
              sar.currChainReqSvcAuthMethodSelectionID = (int) RequestServiceAuthorizationMethod.ELECTRONIC;
              sar.currChainResponseSectionTitle        = order.svcName;
              //sar.currChainResponseCode                = null;
              sar.currChainResponseNotes               = null;
              sar.currChainResponseRecordedOnStr       = null;
              sar.currChainResponseAttestStatement     = null;
              sar.currChainRespondantSignature         = null;
              sar.currChainResponseEffectiveDateStr    = null;
              sar.currChainRespondantName              = null;
              sar.currChainRespondantNPI               = null;
              sar.currChainRespondantEmail             = null;
              sar.currChainRespondantPhone             = null;
              //sar.currChainShowRespondantNPI           = null;
            }

            generateRequestResponseFileDocumentSectionForOrder(ref doc, ref writer, ref ms, ref sar);

            //pdfAddPlanFileComponentPhysOrmSignature ( ref doc, ref rotatedLabelFont, ref fillOutLabelFont);
            
        } /* Orders */

        /* Service Descriptions */
        
        foreach (PlanWriterPlansServiceDescription service in services) {
            
            PlanWriterPlansServiceDescription _service = service;

            ServiceAuthorizationRequest sar;
            try {
              sar = ServiceAuthorizationRequests.load(connSpedmon,log,uInfo, _service.requestID.ToString());
            } catch(Exception ex) { 
              sar                                      = new ServiceAuthorizationRequest();
              sar.svcDescription                       = _service.serviceDescription;
              sar.formBuilderQuestionsJSON             = _service.formBuilderQuestionsJSON;
              sar.formBuilderAnswersJSON               = _service.formBuilderAnswersJSON;
              sar.currChainReqSvcAuthMethodSelectionID = (int) RequestServiceAuthorizationMethod.ELECTRONIC;
              sar.currChainResponseSectionTitle        = "Accompanying and Monitoring Request";
              //sar.currChainResponseCode                = null;
              sar.currChainResponseNotes               = null;
              sar.currChainResponseRecordedOnStr       = null;
              sar.currChainResponseAttestStatement     = null;
              sar.currChainRespondantSignature         = null;
              sar.currChainResponseEffectiveDateStr    = null;
              sar.currChainRespondantName              = null;
              sar.currChainRespondantNPI               = null;
              sar.currChainRespondantEmail             = null;
              sar.currChainRespondantPhone             = null;
              //sar.currChainShowRespondantNPI           = null;
            }

            generateRequestResponseFileDocumentSectionForOrder(ref doc, ref writer, ref ms, ref sar);                                                                

        } /* Services */
        
        
        /* Signatures */
        
        pdfAddPlanFileComponentSectionTitle(ref doc, ref componentTitleFont, @"Signatures", PDFCommon.CELL_BORDERS_NONE);

        // render plan creator
        pdfAddPlanFileComponentSignatureLine(ref doc
                                           , ref cellTitleFont
                                           , ref fillOutLabelFont
                                           , plan.planCreatorSigned
                                           , plan.planCreatorSignedName
                                           , plan.planCreatorSignedDate
                                           , ((String.IsNullOrEmpty(plan.planCreatorSignatureImg)) ?
                                              null
                                              :
                                              iTextSharp.text.Image.GetInstance(Convert.FromBase64String(plan.planCreatorSignatureImg.Split(',')[1]))));

        foreach (PlanWriterPlansPatientPerson person in participants)
        {


            PlanWriterPlansPatientPerson _person = person;

            if (_person.action == 0)
            {

                pdfAddPlanFileComponentSignatureLine(       ref doc
                                                          , ref cellTitleFont
                                                          , ref fillOutLabelFont
                                                          , _person.signed
                                                          , _person.name
                                                          , _person.signedDateStr
                                                          , null);
            }

        } /* Signatures */

        // generate appearances for form fields in PDF
        PDFFormGeneration.generateAcroFieldAppearances(ref ms, ref doc);

        /* PDF Meta data */
        
        title    = plan.name;
        author   = plan.clientName;
        batch    = "";
        
        /* PDF file name */
        
        string fn = String.Format (@"{0}-{1}-{2}-{3}-{4}-{5}"
                                   , plan.clientName
                                   , plan.patientName.Replace(",","").Replace("-","")
                                   , plan.planTypeName
                                   , plan.planDateVal.Year
                                   , plan.planDateVal.Month
                                   , plan.planDateVal.Day);
                                      
        filename = fn;

        PDFFormGeneration.generateAcroFieldAppearances(ref ms, ref doc);
      
      });
      
      PageEventHelperPageNumberAndCreateDate peh = new PageEventHelperPageNumberAndCreateDate();
      
      string _title    = "";
      string _author   = "";
      string _batch    = "";
      string _filename = "";
      
      return PDFCommon.generateDocument (   _title
                                          , _author
                                          , _batch
                                          , _filename
                                          , PDFCommon.ORIENTATION_PORTRAIT
                                          , 1f
                                          , 1f
                                          , 1f
                                          , 40f
                                          , peh
                                          , cb);

      
    }
    
    /**************************************************************************
     * generateStoredFile */
    /**
     *
     **************************************************************************/

    public static ReturnSaveRecord generateStoredFile ( SqlConnection connSpedmon
                                                       , SqlConnection connUser
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID
                                                       , string patID
                                                       , string referencedEntityID )
    {
      /*###########################################################################
        # Generate file bytes for care plan
        ###########################################################################*/
      
      ReturnFileBytes rfb = PlanWriterPlans.pdfGeneratePlanFile( connSpedmon
                                                                 , log
                                                                 , uInfo
                                                                 , clientID
                                                                 , null
                                                                 , referencedEntityID );

      /*###########################################################################
        # Generate file bytes for care plan
        ###########################################################################*/

      ReturnSaveRecord sfs = StoredFiles.save( connSpedmon
                                              , log
                                             , uInfo
                                             , MBA.StoredFiles.FILE_CARE_PLAN_AUTH
                                             , ""
                                             , ""
                                             , "careplan_writer"
                                             , "eauth"
                                             , clientID
                                             , ""
                                             , patID
                                             , @"" /*referencedEntityID*/
                                             , rfb
                                             , @""
                                             , @"N"
                                             , Constants.SAVE_TYPE_NEW.ToString()
                                             , "");

           return sfs;
        }

        /**************************************************************************
         * requestAuthorization */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord requestAuthorization ( SqlConnection connSpedmon
                                                        , SqlConnection connUser
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        clientID
                                                        , string        districtContactUserID
                                                        , string        patID
                                                        , string        referencedEntityID
                                                        , string        svcDescription
                                                        , string        prtGrd1PersonID
                                                        , string        prtGrd2PersonID
                                                        , string        recID)
    {

     
      /*###########################################################################
        # Generate file for care plan (unsigned by parent) for parental review
        # and hopefully approval
        ###########################################################################*/
      
      string selectedFileList;
      var sfs = generateStoredFile(connSpedmon, connUser, log, uInfo, clientID, patID, referencedEntityID);
       
      selectedFileList = sfs.recordID.ToString();

      /*###########################################################################
        # Create authorization request with the unsigned care plan attached
        ###########################################################################*/

      return ServiceAuthorizationRequests.save (  connSpedmon
                                                , connUser
                                                , log
                                                , uInfo
                                                , clientID
                                                , districtContactUserID
                                                , patID
                                                , "4"  // svcAuthorizationRequestTypeID
                                                , referencedEntityID
                                                , svcDescription
                                                , ""   // formBuilderQuestionsJSON
                                                , ""   // formBuilderAnswersJSONForOrder
                                                , "10" //reqSvcAuthFromSelectionID
                                                , "10" //reqSvcAuthMethodSelectionID
                                                , prtGrd1PersonID
                                                , prtGrd2PersonID
                                                , ""
                                                , selectedFileList
                                                , ""  // editDelReason
                                                , "0" // validateRec
                                                , Constants.SAVE_TYPE_NEW.ToString()
                                                , recID );
    }      

  }

}
