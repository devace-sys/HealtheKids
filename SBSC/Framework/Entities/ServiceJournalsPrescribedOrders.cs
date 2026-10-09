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
   * ServiceJournalsPrescribedOrder */
  /**
   * Service journal prescribed order
   **************************************************************************/

  public class ServiceJournalsPrescribedOrder
  {
    public long     id;
    public long     clientID;
    public string   clientName;
    public long     patID;    
    public string   patName;
    public DateTime effectiveDate;
    public string   effectiveDateStr;
    public DateTime endDate;
    public string   endDateStr;
    public long     orpDocStdNameID;
    public string   orpDocStdName;
    public string   svcName;
	public string   svcDesc;
    public string   noteCrit1;
    public string   noteCrit2;
	public string   noteCrit3;
	public string   noteCrit4;
	public string   noteCrit5;
	public string   noteCrit6;
	public string   noteCrit7;
	public string   noteCrit8;
	public string   noteCrit9;
	public string   noteCrit10;
    public string   formBuilderQuestionsJSON;
    public string   formBuilderAnswersJSON;
	public string   noteObsvCmnt;

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

    public bool?    siteAide;
	public bool?    busAide;
	public string   iepYN;
	public string   siteAideYN;
	public string   busAideYN;
	public int?     dailyFreq;	  
	public string   pracIDsStr;
    public string   pracNamesStr;
    public string   pracTitlesStr;
    public string   detailsTrainingPracsJSON;
    public string   orderProfilePracIDsStr;
    public string   orpPracName;
    public long     orpPracID;
    public long     orpDocID;
    public long     orpDocType;

    public string   groupServiceClassNameName;
    public long     groupServiceClassNameID;
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

    public bool     allowMultipleOrders;
    public string   orderContextFieldName;
    public string   orderContextFieldNameValue;

    public string   svcDescOrFormBuilderHtml;

    public string   diagnosis;
    public string   mdOrders;

    public long   refID;
    public bool   active;
    public string activeStr;
    public bool   lastApprovalOrpIsValidMcalOrp;
    public string lastApprovalOrpIsValidMcalOrpStr;

    public string siteName;
        
   }


    /***************************************************************************
     * ReturnServiceJournalsPrescribedOrders */
    /**
     * Return class for multiple prescribed orders
     **************************************************************************/

    public class ReturnServiceJournalsPrescribedOrders : Return
  {
 
    public ReturnServiceJournalsPrescribedOrders ()            : base(){}
    public ReturnServiceJournalsPrescribedOrders (string msg)  : base(msg){}
    public ReturnServiceJournalsPrescribedOrders (Exception e) : base(e){}
    public ReturnServiceJournalsPrescribedOrders (Warning e)   : base(e){}
    public ReturnServiceJournalsPrescribedOrders (Critical e)  : base(e){}
    public ReturnServiceJournalsPrescribedOrders (SessionExpired e):base(e){}
    
    public bool                              hasPrescribedOrders = false;
    public ServiceJournalsPrescribedOrder[]  prescribedOrders;
  }
      
  /***************************************************************************
   * ServiceJournalsPrescribedOrders */
  /**
   * Methods to work with service prescribed orders
   **************************************************************************/

  public class ServiceJournalsPrescribedOrders:Entities
  {          

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a order
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (
      ref RequestResponse rd
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
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_DELETE",ref parms);
    }

                    
    /***************************************************************************
     * save */
    /**
     * Save a prescribed order
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
										 , string        endDate
										 , string        svcName
                                         , string        orpDocStdNameID
	                                     , string        svcDesc
	                                     , string        noteCrit1
                                         , string        noteCrit2
	                                     , string        noteCrit3
	                                     , string        noteCrit4
                                         , string        allowMultipleOrders  
                                         , string        orderContextFieldName
                                         , string        formBuilderQuestionsJSON
                                         , string        formBuilderAnswersJSONForOrder
	                                     , string        noteObsvCmnt
	                                     , string        iep
                                         , string        dailyfreq
                                         , string        pracids
                                         , string        details_pracs_training
                                         , string        groupServiceClassNameID
                                         , string        orpPracID
                                         , string        orpAuthSvcDate
                                         , string        svcAuthStatusConfirmRespCode
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      int       vClientID                        = Validate.reqClientID               (uInfo,                           clientID);
      int       vPatID                           = Validate.reqInteger                (patID,                           @"Missing or invalid patient selection");
      long      vGroupServiceClassNameID         = Validate.reqOrpGroupSvcClassNameID (uInfo,                           groupServiceClassNameID);
      long      vOrpDocStdNameID                 = Validate.reqInteger                (orpDocStdNameID,                 @"Missing or invalid service name selection");
      DateTime  vEffectiveDate                   = Validate.reqDate                   (effectiveDate,                   @"Missing or invalid plan start date.");
                                                 
      Object    vEndDate                         = Validate.optDate                   (endDate,                         Messages.INVALID_END_DATE);
      Object    vSvcName                         = Validate.optString                 (svcName,                         @"Invalid service name");
      string    vSvcDesc                         = Validate.optString                 (svcDesc,                         @"Invalid service description");
      string    vNoteCrit1                       = Validate.optString                 (noteCrit1,                       @"Invalid note criteria");
      string    vNoteCrit2                       = Validate.optString                 (noteCrit2,                       @"Invalid note criteria");
      string    vNoteCrit3                       = Validate.optString                 (noteCrit3,                       @"Invalid note criteria");
      string    vNoteCrit4                       = Validate.optString                 (noteCrit4,                       @"Invalid note criteria");
      string    vNoteObsvCmnt                    = Validate.optString                 (noteObsvCmnt,                    @"Invalid observation/comment");      
      Object    vIEP                             = Validate.optFlag                   (iep,                             Messages.IFSP_IEP_FLAG_BAD, false);
      Object    vDailyFreq                       = Validate.optInteger                (dailyfreq,                       Messages.INVALID_NUM_TIMES_DAY);
      string    vFormBuilderQuestionsJSON        = Validate.optString                 (formBuilderQuestionsJSON      ,  @"Invalid form data");
      string    vFormBuilderAnswersJSONForOrder  = Validate.optString                 (formBuilderAnswersJSONForOrder,  @"Invalid form data");
      Object    vAllowMultipleOrders             = Validate.optFlag                   (allowMultipleOrders,             @"Invalid flag for multi-order", false);
      string    vOrderContextFieldName           = Validate.optString                 (orderContextFieldName,           @"Invalid context field name");

            
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
                                                               
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.Int,      vClientID,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                    SqlDbType.Int,      vPatID,                           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@effectiveDate",            SqlDbType.DateTime, vEffectiveDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                  SqlDbType.DateTime, vEndDate,                         ParameterDirection.Input));
                                                                                                                    
      parms.Add(Database.SqlParm("@svcName",                  SqlDbType.VarChar,  vSvcName,                         ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@orpDocStdNameID",          SqlDbType.BigInt,   vOrpDocStdNameID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcDesc",                  SqlDbType.VarChar,  vSvcDesc,                         ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit1",                SqlDbType.VarChar,  vNoteCrit1,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit2",                SqlDbType.VarChar,  vNoteCrit2,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit3",                SqlDbType.VarChar,  vNoteCrit3,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit4",                SqlDbType.VarChar,  vNoteCrit4,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@allowMultipleOrders",      SqlDbType.Bit    ,  vAllowMultipleOrders,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orderContextFieldName",    SqlDbType.VarChar,  vOrderContextFieldName,           ParameterDirection.Input,200));
      parms.Add(Database.SqlParm("@formBuilderQuestionsJSON", SqlDbType.VarChar,  vFormBuilderQuestionsJSON,        ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@formBuilderAnswersJSON",   SqlDbType.VarChar,  vFormBuilderAnswersJSONForOrder,  ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@noteObsvCmnt",             SqlDbType.VarChar,  vNoteObsvCmnt,                    ParameterDirection.Input,2000));
      parms.Add(Database.SqlParm("@iep",                      SqlDbType.Bit,      vIEP,                             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dailyFreq",                SqlDbType.Int,      vDailyFreq,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupServiceClassNameID",  SqlDbType.BigInt,   vGroupServiceClassNameID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracIDsStr",               SqlDbType.VarChar,  vPracIDsStr,                      ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@detailsTrainingPracsJSON", SqlDbType.VarChar,  details_pracs_training,           ParameterDirection.Input, -1));

      parms.Add(Database.SqlParmDataTable <ServiceJournalPractitionerTrainingDetail>  ("@detailsTrainingPracs", vTrainingDetails.details_pracs_training, "ServiceJournalPractitionerTrainingDetails"));         
      

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE", @"Order already exists", ref parms,null);
    }     
   
                    
    /***************************************************************************
     * saveOrderOrProfile */
    /**
     * Save an order or profile
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
  
    public static ReturnSaveRecord saveOrderOrProfile(  ref RequestResponse rd
                                         , SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
                                         , string        patID
                                         , string        orpDocType
                                         , string        effectiveDate
										 , string        endDate
										 , string        svcName
                                         , string        orpDocStdNameID
	                                     , string        svcDesc
	                                     , string        noteCrit1
                                         , string        noteCrit2
	                                     , string        noteCrit3
	                                     , string        noteCrit4
	                                     , string        noteCrit5
	                                     , string        noteCrit6
	                                     , string        noteCrit7
	                                     , string        noteCrit8
	                                     , string        noteCrit9
	                                     , string        noteCrit10
	                                     , string        expectedOutcomes
                                         , string        allowMultipleOrders  
                                         , string        orderContextFieldName
                                         , string        formBuilderQuestionsJSON
                                         , string        formBuilderAnswersJSONForOrder
	                                     , string        noteObsvCmnt
	                                     , string        iep
	                                     , string        frequency
	                                     , string        projectedMinutes
	                                     , string        planStartDate
	                                     , string        planEndDate
                                         , string        siteAide
	                                     , string        busAide
                                         , string        dailyfreq
                                         , string        pracids
                                         , string        details_pracs_training
                                         , string        groupServiceClassNameID
                                         , string        orpPracID
                                         , string        orpAuthSvcDate
                                         , string        orpAuthExpDate
                                         , string        svcAuthStatusConfirmRespCode
                                         , string        diagnosis
                                         , string        mdOrders
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      int       vClientID                        = Validate.reqClientID               (uInfo,                           clientID);
      int       vPatID                           = Validate.reqInteger                (patID,                           @"Missing or invalid patient selection");
      int       vOrpDocType                      = Validate.reqInteger                (orpDocType,                      @"Missing or invalid ORP document type");
      
      // groupServiceClassNameID is only required for orders, not profiles
      Object    vGroupServiceClassNameID         = (vOrpDocType == 2) ?
                                                    Validate.reqOrpGroupSvcClassNameID(uInfo,                           groupServiceClassNameID) :
                                                    Validate.optInteger               (groupServiceClassNameID,         @"Missing or invalid group family id");
      long      vOrpDocStdNameID                 = Validate.reqInteger                (orpDocStdNameID,                 @"Missing or invalid service name selection");
      DateTime  vEffectiveDate                   = Validate.reqDate                   (effectiveDate,                   @"Missing or invalid plan start date.");
                                                 
      Object    vEndDate                         = Validate.optDate                   (endDate,                         Messages.INVALID_END_DATE);
      Object    vSvcName                         = Validate.optString                 (svcName,                         @"Invalid service name");
      string    vSvcDesc                         = Validate.optString                 (svcDesc,                         @"Invalid service description");
      string    vNoteCrit1                       = Validate.optString                 (noteCrit1,                       @"Invalid note criteria");
      string    vNoteCrit2                       = Validate.optString                 (noteCrit2,                       @"Invalid note criteria");
      string    vNoteCrit3                       = Validate.optString                 (noteCrit3,                       @"Invalid note criteria");
      string    vNoteCrit4                       = Validate.optString                 (noteCrit4,                       @"Invalid note criteria");
      string    vNoteCrit5                       = Validate.optString                 (noteCrit5,                       @"Invalid note criteria");
      string    vNoteCrit6                       = Validate.optString                 (noteCrit6,                       @"Invalid note criteria");
      string    vNoteCrit7                       = Validate.optString                 (noteCrit7,                       @"Invalid note criteria");
      string    vNoteCrit8                       = Validate.optString                 (noteCrit8,                       @"Invalid note criteria");
      string    vNoteCrit9                       = Validate.optString                 (noteCrit9,                       @"Invalid note criteria");
      string    vNoteCrit10                      = Validate.optString                 (noteCrit10,                      @"Invalid note criteria");
      string    vExpectedOutcomes                = Validate.optString                 (expectedOutcomes,                @"Invalid expected outcome");
      string    vDiagnosis                       = Validate.optString                 (diagnosis,                       @"Invalid diagnosis");
      string    vMdOrders                        = Validate.optString                 (mdOrders,                        @"Invalid md Orders");
      string    vNoteObsvCmnt                    = Validate.optString                 (noteObsvCmnt,                    @"Invalid observation/comment");      
      Object    vIEP                             = Validate.optFlag                   (iep,                             Messages.IFSP_IEP_FLAG_BAD, false);
      Object    vFrequency                       = Validate.optInteger                (frequency,                       @"Invalid Frequency");
      Object    vProjectedMinutes                = Validate.optInteger                (projectedMinutes,                Messages.INVALID_NUM_MINS, false);
      Object    vPlanStartDate                   = Validate.optDate                   (planStartDate,                   Messages.INVALID_START_DATE);
      Object    vPlanEndDate                     = Validate.optDate                   (planEndDate,                     Messages.INVALID_END_DATE);
      Object    vSiteAide                        = Validate.optFlag                   (siteAide,                        @"Invalid site aide flag", false);
      Object    vBusAide                         = Validate.optFlag                   (busAide,                         @"Invalid bus aide flag", false);
      Object    vDailyFreq                       = (vOrpDocType == 2) ?
                                                    Validate.optInteger(dailyfreq, Messages.INVALID_NUM_TIMES_DAY) :
                                                    (int)0; 
      string    vFormBuilderQuestionsJSON        = Validate.optString                 (formBuilderQuestionsJSON      ,  @"Invalid form data");
      string    vFormBuilderAnswersJSONForOrder  = Validate.optString                 (formBuilderAnswersJSONForOrder,  @"Invalid form data");
      Object    vAllowMultipleOrders             = Validate.optFlag                   (allowMultipleOrders,             @"Invalid flag for multi-order", false);
      string    vOrderContextFieldName           = Validate.optString                 (orderContextFieldName,           @"Invalid context field name");

            
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
                                                                    , orpAuthExpDate
                                                                    , svcAuthStatusConfirmRespCode
                                                                    , ref parms);

      /*----------------------------
       * Add remaining sproc parameters
       *----------------------------*/
                                                               
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.Int,      vClientID,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                    SqlDbType.Int,      vPatID,                           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@orpDocType",               SqlDbType.Int,      vOrpDocType,                      ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@effectiveDate",            SqlDbType.DateTime, vEffectiveDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                  SqlDbType.DateTime, vEndDate,                         ParameterDirection.Input));
                                                                                                                    
      parms.Add(Database.SqlParm("@svcName",                  SqlDbType.VarChar,  vSvcName,                         ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@orpDocStdNameID",          SqlDbType.BigInt,   vOrpDocStdNameID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcDesc",                  SqlDbType.VarChar,  vSvcDesc,                         ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit1",                SqlDbType.VarChar,  vNoteCrit1,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit2",                SqlDbType.VarChar,  vNoteCrit2,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit3",                SqlDbType.VarChar,  vNoteCrit3,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit4",                SqlDbType.VarChar,  vNoteCrit4,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit5",                SqlDbType.VarChar,  vNoteCrit5,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit6",                SqlDbType.VarChar,  vNoteCrit6,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit7",                SqlDbType.VarChar,  vNoteCrit7,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit8",                SqlDbType.VarChar,  vNoteCrit8,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit9",                SqlDbType.VarChar,  vNoteCrit9,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@noteCrit10",               SqlDbType.VarChar,  vNoteCrit10,                      ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@expectedOutcomes",         SqlDbType.VarChar,  vExpectedOutcomes,                ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@diagnosis",                SqlDbType.VarChar,  vDiagnosis,                       ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@mdOrders",                 SqlDbType.VarChar,  vMdOrders,                        ParameterDirection.Input,8000));
      parms.Add(Database.SqlParm("@allowMultipleOrders",      SqlDbType.Bit    ,  vAllowMultipleOrders,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orderContextFieldName",    SqlDbType.VarChar,  vOrderContextFieldName,           ParameterDirection.Input,200));
      parms.Add(Database.SqlParm("@formBuilderQuestionsJSON", SqlDbType.VarChar,  vFormBuilderQuestionsJSON,        ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@formBuilderAnswersJSON",   SqlDbType.VarChar,  vFormBuilderAnswersJSONForOrder,  ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@noteObsvCmnt",             SqlDbType.VarChar,  vNoteObsvCmnt,                    ParameterDirection.Input,2000));
      parms.Add(Database.SqlParm("@iep",                      SqlDbType.Bit,      vIEP,                             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@frequency",                SqlDbType.Int,      vFrequency,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@projectedMinutes",         SqlDbType.Int,      vProjectedMinutes,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planStartDate",            SqlDbType.Date,     vPlanStartDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planEndDate",              SqlDbType.Date,     vPlanEndDate,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteAide",                 SqlDbType.Bit,      vSiteAide,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@busAide",                  SqlDbType.Bit,      vBusAide,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dailyFreq",                SqlDbType.Int,      vDailyFreq,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupServiceClassNameID",  SqlDbType.BigInt,   vGroupServiceClassNameID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracIDsStr",               SqlDbType.VarChar,  vPracIDsStr,                      ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@detailsTrainingPracsJSON", SqlDbType.VarChar,  details_pracs_training,           ParameterDirection.Input, -1));

      parms.Add(Database.SqlParmDataTable <ServiceJournalPractitionerTrainingDetail>  ("@detailsTrainingPracs", vTrainingDetails.details_pracs_training, "ServiceJournalPractitionerTrainingDetails"));         
      

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE", @"Order already exists", ref parms,null);
    }     
   
    
    /***************************************************************************
     * view */
    /**
     * Note: We retrieve pracID internally for practitioners and force this
     * to be the pracID to the view udf so pracs can only see orders that
     * are related to their discipline family.
     **************************************************************************/  
    
    public static ReturnDB view ( SqlConnection connSpedmon, 
                                  DetailsLog    log, 
                                  UserInfo      uInfo,
                                  int           recViewType,
                                  bool          pagedOrTop,
                                  string        idx,
                                  string        canEdit,
                                  string        active,
                                  string        clientID,
                                  string        patID,
                                  string        groupSvcClassNameID,
                                  string        referenceDate,
                                  string        startDate,
                                  string        endDate,
								                  string        maxRow,
                                  defineCols    dc)
    {
    

      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @groupSvcClassNameID, @patID, @referenceDate, @startRefDate, @endRefDate, @maxRow, @recID, @active)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      Object  vClientID            = Validate.optClientID (uInfo, clientID);            
      Object  vPracID              = Validate.optPracID   (uInfo, @""); /* Force prac ID for practitioners */
      
      Object  vGroupSvcClassNameID = Validate.optInteger  (groupSvcClassNameID, Messages.INVALID_GROUP_FAMILY);
      Object  vPatID               = Validate.optInteger  (patID,               Messages.INVALID_PAT_ID);
      Object  vReferenceDate       = Validate.optDate     (referenceDate,       Messages.INVALID_DATES);
      Object  vStartRefDate        = Validate.optDate     (startDate,           Messages.INVALID_START_DATE);
      Object  vEndRefDate          = Validate.optDate     (endDate,             Messages.INVALID_END_DATE);
      Object  vMaxRow              = Validate.optInteger  (maxRow,              @"Invalid max row");
	  
      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,   vPracID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,               ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,   vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referenceDate",       SqlDbType.DateTime, vReferenceDate,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startRefDate",        SqlDbType.Date,     vStartRefDate,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endRefDate",          SqlDbType.Date,     vEndRefDate,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@maxRow",              SqlDbType.Int,      vMaxRow,              ParameterDirection.Input));      
      
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
                                           , string        groupSvcClassNameID
                                           , string        dateRange
                                           , string        canEdit
                                           , string        active )
   {

     ReturnDataTable so = new ReturnDataTable();
     
     /*-------------------------------
      * Parse date range into start
      * and end dates
      *----------------------------*/

     string startDate = "";
     string endDate = "";
     Util.parseDateRange(dateRange, out startDate, out endDate);
      
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
       ss.addDisplayColumn("id") ;
       ss.addDisplayColumn("patName           as [Patient]",          true);      
       ss.addDisplayColumn("orpDocStdName     as [Service]",          true);
     
       if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
       {
         ss.addDisplayColumn("effectiveDateStr  as [Plan Start\nDate]", true);
         ss.addDisplayColumn("endDateStr        as [Plan End\nDate]",   true);
         ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Active]");
       }

       ss.addDisplayColumn("lastApprovalEffectiveDateStr  as [Effective Date]");
       ss.addDisplayColumn("lastApprovalExpirationMessage as [ORP Approval\nStatus]");
       
       ss.addDisplayColumn("orpPracName       as [ORP\nProfessional]");
       ss.addDisplayColumn("orpNPI            as [ORP\nNPI]");
       ss.addDisplayColumn("orpIsValidMcalOrp as [ORP\nValid]");
       //ss.addDisplayColumn("svcDesc           as [Short Description]");
       ss.addDisplayColumn("noteCrit1         as [Note Criteria 1]");
       ss.addDisplayColumn("noteCrit2         as [Note Criteria 2]");
       ss.addDisplayColumn("noteCrit3         as [Note Criteria 3]");
       ss.addDisplayColumn("noteCrit4         as [Note Criteria 4]");
       ss.addDisplayColumn("createdByUserName        as [Created By]");
       ss.addDisplayColumn("createdStr               as [Created\nOn]");
       ss.addDisplayColumn("lastModifiedByUserName   as [Last Modified By]");
       ss.addDisplayColumn("lastModifiedStr          as [Last\nModified\nOn]");

       
       pageroworder = ss.pageRowOrder();

     };

     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return ServiceJournalsPrescribedOrders.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, patID, groupSvcClassNameID, null, startDate, endDate, null, dc); });
   
     /*----------------------------
      * Add a title and footer
      *----------------------------*/
                   
     so.tableName   = "Prescribed Orders - View";
     so.tableFooter = Messages.CONFIDENTIAL;
     
     /*----------------------------
      * Done
      *----------------------------*/

     return so;
     
    }            

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single prescribed order
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

    public static ServiceJournalsPrescribedOrder load (   SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
														   , string        patID
														   , string        referenceDate
                                                           , string        recID
                                                         )
    {      
      return (ServiceJournalsPrescribedOrder) Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceJournalsPrescribedOrder),
      delegate { return ServiceJournalsPrescribedOrders.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, patID, null, referenceDate, null, null, "1",null); });
    } 
                 
   
    
    /***************************************************************************
     * getServiceJournalsPrescribedOrders*/
    /**
     * Outputs data for prescribed orders
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

    public static ReturnServiceJournalsPrescribedOrders getServiceJournalsPrescribedOrders (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        patID
      , string        referenceDate )
    
    {    
      ReturnServiceJournalsPrescribedOrders so = new ReturnServiceJournalsPrescribedOrders();
      so.hasPrescribedOrders = false;      
      so.prescribedOrders = null;
      
      ReturnDB rd = view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", "", clientID, patID, null, referenceDate,null,null,null,null);            
      if (rd.hasRecords) 
      {        
      
        List<ServiceJournalsPrescribedOrder> rl = new List<ServiceJournalsPrescribedOrder>();
        so.hasPrescribedOrders = true;
        Object[] ol = Database.convertRecords(rd.records,typeof(ServiceJournalsPrescribedOrder));
        foreach(Object o in ol) {
          ServiceJournalsPrescribedOrder po = (ServiceJournalsPrescribedOrder) o;
          rl.Add(po);
        }
        so.prescribedOrders = rl.ToArray();
      }
      
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
                                                   , string        recID )
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
        
         string viewUDF = "dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View (@userID, @userGroup, @userRank, @modifiedBy, @recordID)";

        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        var vRecID      = Validate.optInteger  (recID, Messages.INVALID_RECORD_ID);
        var vModifiedBy = Validate.optInteger  (modifiedBy, Messages.INVALID_USER_ID);
        var logParms = new List<SqlParameter>();

        logParms.Add(Database.SqlParm("@recordID"  , SqlDbType.BigInt, vRecID        , ParameterDirection.Input));
        logParms.Add(Database.SqlParm("@modifiedBy", SqlDbType.BigInt, vModifiedBy   , ParameterDirection.Input));
        
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
