using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * ServiceJournalsServiceDescription */
  /**
   * Service journal service description
   **************************************************************************/

  public class ServiceJournalsServiceDescription
  {
    public long     id;
    public long     clientID;
    public string   clientName;
    public long     patID;    
    public string   patName;
    public DateTime effectiveDate;
    public string   effectiveDateStr;
    public string   diagnosis;
    public string   mdOrders;
    public string   serviceDescription;
    public string   expectedOutcomes;

	public bool?    iep;
	public int?     frequency;
	public string   frequencyName;
	public int?     projectedMinutes;
	public DateTime? planStartDate;
	public string   planStartDateStr;
	public string   planStartDateStrYMD;
	public DateTime? planEndDate;
	public string   planEndDateStr;
	public string   planEndDateStrYMD;

    public string   iepYN;
    public bool?    siteAide;
    public string   siteAideYN;
	  public bool?    busAide;
	  public string   busAideYN;
    public string   pracIDsStr;
    public string   pracNamesStr;
    public string   pracTitlesStr;
    public string   detailsTrainingPracsJSON;
    public long     orpPracID;
    public long     orpDocID;
    public string   orpPracName;
    public DateTime created;
    public string   createdStr;
    public long     createdBy;
    public string   createdByUserName;    
    public DateTime lastModified;    
    public string   lastModifiedStr;
    public long     lastModifiedBy;
    public string   lastModifiedByUserName;
    
    public bool     hasLastApproval;
    public bool     displayLastApproval;
    public long     lastApprovalOrpPracID;
	  public string   lastApprovalOrpName;
    public string   lastApprovalOrpTitle;
    public string   lastApprovalOrpNPI;
    public DateTime lastApprovalEffectiveDate;
    public string   lastApprovalEffectiveDateStr;
    public DateTime lastApprovalExpirationDate;
    public string   lastApprovalExpirationDateStr;

    public int      lastApprovalExpiresInDays;
    public int      lastApprovalExpirationState;
    public string   lastApprovalExpirationMessage;

    public string   formBuilderQuestionsJSON;
    public string   formBuilderAnswersJSON;

    public bool     allowMultipleOrders;
    public string   orderContextFieldName;
    public string   orderContextFieldNameValue;



  }
      
  /***************************************************************************
   * ReturnServiceJournalsServiceDescription */
  /**
   * Return class for single service description
   **************************************************************************/

  public class ReturnServiceJournalsServiceDescription : Return
  {
 
    public ReturnServiceJournalsServiceDescription ()            : base(){}
    public ReturnServiceJournalsServiceDescription (string msg)  : base(msg){}
    public ReturnServiceJournalsServiceDescription (Exception e) : base(e){}
    public ReturnServiceJournalsServiceDescription (Warning e)   : base(e){}
    public ReturnServiceJournalsServiceDescription (Critical e)  : base(e){}
    public ReturnServiceJournalsServiceDescription (SessionExpired e):base(e){}
    
    public bool                              hasServiceDescription = false;
    public ServiceJournalsServiceDescription serviceDescription;
  
  }
      
  /***************************************************************************
   * ServiceJournalsServiceDescriptions */
  /**
   * Methods to work with service journals
   **************************************************************************/

  public class ServiceJournalsServiceDescriptions:Entities
  {          
                    
    /***************************************************************************
     * delete */
    /**
     * Deletes a service description
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  ref RequestResponse rd
                                           , SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec
                                           , string          recID)
    {           
           
      /*----------------------------
       * Exit if prac is not allowed
       *----------------------------*/
      
      //if (!ServiceJournals.isPracSomeoneWhoCanManageOrders (ref rd)) throw new MBA.Critical(Messages.ACCESS_DENIED);
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); 
     
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
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE",ref parms);
    }

    /***************************************************************************
     * save */
    /**
     * Save a service description
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  DOS             Date of service
     * @param  SvcType         Type of service
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
  
    public static ReturnSaveRecord save (  ref RequestResponse rd
                                         , SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
                                         , string        patID
                                         , string        effectiveDate
                                         , string        diagnosis
                                         , string        mdOrders
                                         , string        serviceDescription
                                         , string        expectedOutcomes
                                         , string        iep
                                         , string        siteaide
                                         , string        busaide
                                         , string        pracids
                                         , string        details_pracs_training
                                         , string        orpPracID 
                                         , string        orpAuthSvcDate
                                         , string        svcAuthStatusConfirmRespCode
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
            

      
      /*----------------------------
       * Exit if prac is not allowed
       *----------------------------*/
      
      //if (!ServiceJournals.isPracSomeoneWhoCanManageSvcDescr (ref rd)) throw new MBA.Critical(Messages.ACCESS_DENIED);
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      
      int       vClientID            = Validate.reqClientID (uInfo, clientID);
      int       vPatID               = Validate.reqInteger  (patID,              Messages.INVALID_PAT_ID);
      DateTime  vEffectiveDate       = Validate.reqDate     (effectiveDate,      Messages.INVALID_EFFECTIVE_DATE);      
      string    vDiagnosis           = Validate.optString   (diagnosis,          @"Invalid diagnosis");      
      string    vMdOrders            = Validate.optString   (mdOrders,           @"Invalid MD orders");      
      string    vServiceDescription  = Validate.optString   (serviceDescription, @"Invalid service description");      
      string    vExpectedOutcomes    = Validate.optString   (expectedOutcomes,   @"Invalid expected outcomes");      
      Object    vIEP                 = Validate.optFlag     (iep,                Messages.IFSP_IEP_FLAG_BAD, false);
      Object    vSiteAide            = Validate.optFlag     (siteaide,           @"Invalid 1:1 aide answer", false);
      Object    vBusAide             = Validate.optFlag     (busaide,            @"Invalid bus aide answer", false);

      /* Validate training data*/
      
      string                                    vPracIDsStr      = @"";
      ServiceJournalPractitionerTrainingDetails vTrainingDetails = new ServiceJournalPractitionerTrainingDetails();
      
      ServiceJournals.validatePracTrainingDetails (  ref pracids
                                                   , ref details_pracs_training
                                                   , out vPracIDsStr
                                                   , out vTrainingDetails );
      
      /*----------------------------
       * Validate orp and service 
       * authorization status
       * and add their associated
       * sproc parameters
       *----------------------------*/
 
      ORPDocuments.validateAndAddCommonSvcAuthorizationStatusParams(  ref rd
                                                                     , orpPracID
                                                                     , orpAuthSvcDate
                                                                     , null
                                                                     , svcAuthStatusConfirmRespCode
                                                                     , ref parms);

      /*----------------------------
       * Add remaining sproc parameters
       *----------------------------*/

      parms.Add(Database.SqlParm("@clientID",                     SqlDbType.Int,      vClientID,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                        SqlDbType.Int,      vPatID,                         ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@effectiveDate",                SqlDbType.DateTime, vEffectiveDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@diagnosis",                    SqlDbType.VarChar,  vDiagnosis,                     ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@mdOrders",                     SqlDbType.VarChar,  vMdOrders,                      ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@serviceDescription",           SqlDbType.VarChar,  vServiceDescription,            ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@expectedOutcomes",             SqlDbType.VarChar,  vExpectedOutcomes,              ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@iep",                          SqlDbType.Bit,      vIEP,                           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteAide",                     SqlDbType.Bit,      vSiteAide,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@busAide",                      SqlDbType.Bit,      vBusAide,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracIDsStr",                   SqlDbType.VarChar,  vPracIDsStr,                    ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@detailsTrainingPracsJSON",     SqlDbType.VarChar,  details_pracs_training,         ParameterDirection.Input, -1));
      parms.Add(Database.SqlParmDataTable <ServiceJournalPractitionerTrainingDetail>  ("@detailsTrainingPracs", vTrainingDetails.details_pracs_training, "ServiceJournalPractitionerTrainingDetails"));
                  
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE", @"Service description already exists", ref parms,null);
    }     
   
    
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
                                 string        patID,
                                 string        referenceDate,
								                 string        maxRow,
                                 defineCols    dc)
    {
    
      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @referenceDate, @maxRow, @recID, @active)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      Object  vClientID       = Validate.optClientID (uInfo,          clientID);
      Object  vPatID          = Validate.optInteger  (patID,          Messages.INVALID_PAT_ID);
      Object  vReferenceDate  = Validate.optDate     (referenceDate,  Messages.INVALID_DATES);
      Object  vMaxRow         = Validate.optInteger  (maxRow,         @"Invalid max row");
	  
      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",         SqlDbType.Int,      vClientID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",            SqlDbType.Int,      vPatID,          ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@referenceDate",    SqlDbType.DateTime, vReferenceDate,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@maxRow",           SqlDbType.Int,      vMaxRow,         ParameterDirection.Input));      
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }
    
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        clientID
                                           , string        patID
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so = new ReturnDataTable();
     
      
     /*----------------------------
      * SBSC staff can see both 
      * active and inactive for
      * views.
      *----------------------------*/

     if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
     {
       active = @"";
     }
     else
     {
       active = @"Y";
     }

     /*----------------------------
      * Define our columns and
      * set the page order for 
      * paging
      * 
      * TODO: Rewrite 
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {
       ss.addDisplayColumn("id");       
       ss.addDisplayColumnIfParmValueIsNull("clientName as [Client]","@clientID",true,ref parms);
       ss.addDisplayColumn("patName           as [Patient]", true);

       if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
       {
         ss.addDisplayColumn("effectiveDateStr  as [Plan Start\nDate]");
         ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Active]");
       }
       ss.addDisplayColumn("lastApprovalEffectiveDateStr  as [Effective Date]");
       ss.addDisplayColumn("lastApprovalExpirationMessage as [ORP Approval\nStatus]");
       
       ss.addDisplayColumn("orpPracName              as [ORP\nProfessional]");
       ss.addDisplayColumn("orpNPI                   as [ORP\nNPI]");
       ss.addDisplayColumn("orpIsValidMcalOrp        as [ORP\nValid]");
       ss.addDisplayColumn("diagnosis                as [Diagnosis]");
       ss.addDisplayColumn("mdOrders                 as [MD Orders]");       
       ss.addDisplayColumn("serviceDescription       as [Service\nDescription]");
       ss.addDisplayColumn("expectedOutcomes         as [Expected\nOutcomes]");
       ss.addDisplayColumn("createdByUserName        as [Created\nBy]");
       ss.addDisplayColumn("createdStr               as [Created\nOn]");
       ss.addDisplayColumn("lastModifiedByUserName   as [Last\nModified\nBy]");
       ss.addDisplayColumn("lastModifiedStr          as [Last\nModified\nOn]");
              
       pageroworder = ss.pageRowOrder();
     };

     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return ServiceJournalsServiceDescriptions.view (  connSpedmon
                                                                  , log
                                                                  , uInfo
                                                                  , Entities.REC_VIEW_TBL
                                                                  , paged
                                                                  , pageNumber
                                                                  , canEdit
                                                                  , active
                                                                  , clientID
                                                                  , patID
                                                                  , null  /* Tells UDF to use default*/
                                                                  , null  /* Tells UDF to use default */
                                                                  , dc); });
   
     /*----------------------------
      * Add a title and footer
      *----------------------------*/
                   
     so.tableName   = "Patient Profiles - View";
     so.tableFooter = Messages.CONFIDENTIAL;
     
     /*----------------------------
      * Done
      *----------------------------*/

     return so;
     
    }            

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single journal service description
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ServiceJournalsServiceDescription load (   SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
														                               , string        patID
														                               , string        referenceDate
                                                           , string        recID
                                                         )
    {
      
      return (ServiceJournalsServiceDescription) Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceJournalsServiceDescription),
      delegate { return ServiceJournalsServiceDescriptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, patID,referenceDate,"1",null); });
    } 
             
    /***************************************************************************
     * getServiceJournalsServiceDescription */
    /**
     * Outputs data for a single journal service description
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ReturnServiceJournalsServiceDescription getServiceJournalsServiceDescription (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        patID
      , string        referenceDate )
    
    {    
      ReturnServiceJournalsServiceDescription so = new ReturnServiceJournalsServiceDescription();
      so.hasServiceDescription = false;
      
      ReturnDB rd = view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", "", clientID, patID,referenceDate,"1",null);
      
      ServiceJournalsServiceDescription sd = new ServiceJournalsServiceDescription();
      if (rd.hasRecords) 
      {
        so.hasServiceDescription = true;
        sd = (ServiceJournalsServiceDescription) Database.convertRecord(rd.records,typeof(ServiceJournalsServiceDescription));      
      }
      so.serviceDescription = sd;          
      return so;    
    }

    /***************************************************************************
     * viewTblModHist */
    /**
     * Returns a data table of records for recent activity
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTblModHist (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        modifiedBy
                                                   , string        recID)
    {
        ReturnDataTable so = new ReturnDataTable();
        
        /*###########################################################################
          # Define our display columns and set the page order.  Page order needs to
          # be in the same sort order as the udf called in the view.
          ###########################################################################*/  

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {       
          ss.addDisplayColumn("name   as [Name]", true );
          ss.addDisplayColumn("action as [Action]"     );
          ss.addDisplayColumn("date   as [Date / Time]");
          pageroworder = ss.pageRowOrder();
        };

        /*###########################################################################
          # Set up custom view method params for log history UDF call 
          ###########################################################################*/
        
         string viewUDF = "dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View (@userID, @userGroup, @userRank, @modifiedBy, @recordID)";
        
        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        var vRecID       = Validate.optInteger  (recID                  , Messages.INVALID_RECORD_ID);
        var vModifiedBy  = Validate.optInteger  (modifiedBy             , Messages.INVALID_USER_ID);
        
        var logParms = new List<SqlParameter>();

        logParms.Add(Database.SqlParm("@recordID"   , SqlDbType.BigInt, vRecID        , ParameterDirection.Input));
        logParms.Add(Database.SqlParm("@modifiedBy" , SqlDbType.BigInt, vModifiedBy   , ParameterDirection.Input));
        
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/             
        
        /*###########################################################################
          # Call the base method which handles the rest and returns a ReturnDataTable
          ###########################################################################*/  

        so = Entities.viewTbl(  connSpedmon
                              , log
                              , uInfo
                              , false
                              , "1"
                              , delegate { return
                                Entities.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, false, "1", null, null, viewUDF, ref logParms, null, dc);
                               });
   
        /*###########################################################################
          # Add a title and footer to ReturnDataTable then return
          ###########################################################################*/  
                  
        so.tableName   = "Log History";
        so.tableFooter = Messages.CONFIDENTIAL;
            
        return so;
     
    }
  }
}
