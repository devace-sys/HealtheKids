using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
  /***************************************************************************
   * PatientPromisedServicesDeliveryException */
  /**
   *
   ***************************************************************************/
  public class PatientPromisedServicesDeliveryException : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"patName asc, patCSIS asc, patDOB asc";

        public long     clientID;
	    public string   clientName;
        public long     patID;
        public string   patName;
        public DateTime patDOB;
        public string   patDOBStr;
        public string   patCSIS;

	    public int      svcTrackingClass;
	    public int      spEdServiceCode;
	    public long     orpDocStandardSelectionNameID;
	    
        public string   spEdServiceCodeStr;
        public string   spEdServiceName;
        public string   spEdServiceCodeName;
        public string   orpDocStandardSelectionName;
        public string   serviceOrOrderName;

        public DateTime planStartDate;
	    public DateTime planEndDate;
	    public int      spEdFreqCode;
	    public string   spEdFreqName;
        public int      minsPerFreq;
	    public DateTime dosStart;
	    public DateTime dosEnd;
	    public int      numMinsMissing;
       
        public string   planStartDateStr;         
	    public string   planEndDateStr;
	    public string   dosStartStr;
	    public string   dosEndStr;

	    public string   createdByUserName;
        public int      deliveryExceptionAddedReasonID;
        public string   deliveryExceptionAddedReasonName;
	    public string   deliveryExceptionAddedNotes;

	    public string   removedByUserName;
        public int      deliveryExceptionRemovedReasonID;
	    public string   deliveryExceptionRemovedReasonName;	    
        public string   deliveryExceptionRemovedNotes;
  }  
  
  /***************************************************************************
   * PatientPromisedServicesDeliveryExceptions */
  /**
   *
   ***************************************************************************/

  public class PatientPromisedServicesDeliveryExceptions: Entities
  {

    public const int DATA_SOURCE_ALL               = 0;
    public const int DATA_SOURCE_CURRENT_CDE_AUDIT = 1;

    public const string SEL_LABEL_MANAGE   = @"Patient Promised Service Delivery Exceptions";
    public const string MENU_ID_MANAGE     = @"managepatientpromisedservicedeliveryexceptionslink";
    public const string BODY_ID_MANAGE     = @"managepatientpromisedservicedeliveryexceptions";
    public const string URL_MANAGE         = @"user_all_patient_promised_service_delivery_exceptions_manage.aspx";

    public const string URL_SERVICE_BASE                         = @"patientpromisedervicesdeliveryexceptions.asmx";
    public const string URL_REST_SAVE_INLINE_BASE                = URL_SERVICE_BASE + @"/saveinline";
    public const string URL_REST_DELETE_INLINE_BASE              = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_REST_OP_FLAG_AS_REVIEWED_INLINE_BASE = URL_SERVICE_BASE + @"/opflagasreviewedinline";
    public const string URL_REST_VIEW_BASE                       = @"api/v1/patientpromisedservicesdeliveryexceptions";
                                                                   
    /***************************************************************************
     * URL_REST_SAVE_INLINE */
    /**
     * 
     **************************************************************************/ 
    public static string URL_REST_SAVE_INLINE()
    {
        return MBA.HttpApplication.createLink(PatientPromisedServicesDeliveryExceptions.URL_REST_SAVE_INLINE_BASE, true);
    }

	/***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(PatientPromisedServicesDeliveryExceptions.URL_REST_DELETE_INLINE_BASE, true);
    }

	/***************************************************************************
     * URL_REST_FLAG_AS_REVIEWED_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_FLAG_AS_REVIEWED()
    {
        return MBA.HttpApplication.createLink(PatientPromisedServicesDeliveryExceptions.URL_REST_OP_FLAG_AS_REVIEWED_INLINE_BASE, true);
    }
    
    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  	 
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(PatientPromisedServicesDeliveryExceptions.URL_REST_VIEW_BASE, true);
    }
    
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        dataSource
                                 , string        clientID
                                 , string        patID                              
                                 , string        svcTrackingClass
                                 , string        spEdServiceCode
                                 , string        orpDocStandardSelectionNameID
                                 , string        planStartDate
                                 , string        planEndDate
                                 , string        reviewed
                                 , defineCols    dc)
    { 
             
      var viewUDF = "PATIENTS_PROMISED_SERVICES_DELIVERY_EXCEPTIONS_VIEW (@userID, @userGroup, @userRank, @source, @clientID, @patID, @svcTrackingClass, @spEdServiceCode, @orpDocStandardSelectionNameID, @planStartDate, @planEndDate, @reviewed, @active)"; 
 
      var parms = new List<SqlParameter>();
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  

      int       vDataSource                    = Validate.reqInteger        (dataSource,Messages.INVALID_DATA_SOURCE,true);
      int       vClientID                      = Validate.reqClientID       (uInfo, clientID);
      Object    vPatID                         = Validate.optPatID          (uInfo, patID);
      Object    vSvcTrackingClass              = Validate.optInteger        (svcTrackingClass,              @"Invalid service tracking class");
      Object    vSpEdServiceCode               = Validate.optInteger        (spEdServiceCode,               @"Invalid SpEd service code");
      Object    vOrpDocStandardSelectionNameID = Validate.optInteger        (orpDocStandardSelectionNameID, @"Invalid orp doc standard selection name id");
      Object    vPlanStartDate                 = Validate.optDate           (planStartDate,                 @"Invalid plan start date");
      Object    vPlanEndDate                   = Validate.optDate           (planEndDate,                   @"Invalid plan end date");
      Object    vReviewed                      = Validate.optFlag           (reviewed,                      @"Invalid reviewed value");

      /*----------------------------
       * Populate database parameters
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@source",                        SqlDbType.BigInt   , vDataSource,                     ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@clientID",                      SqlDbType.BigInt   , vClientID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                         SqlDbType.BigInt   , vPatID,                          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcTrackingClass",              SqlDbType.Int      , vSvcTrackingClass,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@spEdServiceCode",               SqlDbType.Int      , vSpEdServiceCode,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpDocStandardSelectionNameID", SqlDbType.BigInt   , vOrpDocStandardSelectionNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planStartDate",                 SqlDbType.Date     , vPlanStartDate,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planEndDate",                   SqlDbType.Date     , vPlanEndDate,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@reviewed",                      SqlDbType.Bit      , vReviewed,                       ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
    }
 
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string dataSource
                                             , string clientID
                                             , string patID
                                             , string svcTrackingClass
                                             , string spEdServiceCode
                                             , string orpDocStandardSelectionNameID
                                             , string planStartDate
                                             , string planEndDate
                                             , string reviewed )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientPromisedServicesDeliveryException.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PatientPromisedServicesDeliveryException)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PatientPromisedServicesDeliveryExceptions.view ( connSpedmon
                                                                               , log
                                                                               , uInfo
                                                                               , Entities.REC_VIEW_OBJECTS
                                                                               , pageObjectList
                                                                               , idx
                                                                               , "" /* Can edit */
                                                                               , active
                                                                               , dataSource
                                                                               , clientID
                                                                               , patID
                                                                               , svcTrackingClass
                                                                               , spEdServiceCode
                                                                               , orpDocStandardSelectionNameID
                                                                               , planStartDate
                                                                               , planEndDate
                                                                               , reviewed
                                                                               , dc);
                                      });
 
 
    }
    
    /***************************************************************************
     * viewTbl 
     *
     * Returns data table for report export
     * 
     ***************************************************************************/
    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , RequestResponse rd
                                           , bool   paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string dataSource
                                           , string clientID
                                           , string patID
                                           , string svcTrackingClass
                                           , string spEdServiceCode
                                           , string orpDocStandardSelectionNameID
                                           , string planStartDate
                                           , string planEndDate
                                           , string reviewed ) 
    {

            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

              ss.addDisplayColumn("patName                  as [Patient]", true);
              ss.addDisplayColumn("patDOBStr                as [DOB]",     true);
              ss.addDisplayColumn("patCSIS                  as [SSID]");
              ss.addDisplayColumn("serviceOrOrderName       as [Service]");              
              ss.addDisplayColumn("planStartDateStr         as [Plan\nStart\nDate]");
              ss.addDisplayColumn("planEndDateStr           as [Plan\nEnd\nDate]");
              ss.addDisplayColumn("spEdFreqName             as [Promised\nFrequency Of\nDelivery]");
              ss.addDisplayColumn("minsPerFreq              as [Minutes\nExpected]");
              ss.addDisplayColumn("createdByUserName        as [Deferred\nBy]");               
              ss.addDisplayColumn("dosStartStr              as [Starting\nDate\nof\nService]");
              ss.addDisplayColumn("dosEndStr                as [Ending\nDate\nof\nService]");
              ss.addDisplayColumn("numMinsMissing           as [Minutes\nDeferred]");
              ss.addDisplayColumn("deliveryExceptionAddedReasonName  as [Deferal\nReason]");
              ss.addDisplayColumn("deliveryExceptionAddedNotes       as [Deferal\nReason\nNotes]");
                            
              pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , delegate {
                                      return PatientPromisedServicesDeliveryExceptions.view (
                          connSpedmon
                        , log
                        , uInfo
                        , Entities.REC_VIEW_TBL
                        , paged
                        , pageNumber
                        , canEdit
                        , "Y" /*active*/
                        , dataSource
                        , clientID
                        , patID
                        , svcTrackingClass
                        , spEdServiceCode
                        , orpDocStandardSelectionNameID
                        , planStartDate
                        , planEndDate
                        , reviewed
                        , dc);
                     });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = PatientPromisedServicesDeliveryExceptions.SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;
            return so;
    }
    
    /***************************************************************************
     * opFlagAsReviewed */
    /**
     * Mark as reviewed 
     ***************************************************************************/
    public static ReturnSaveRecord opFlagAsReviewed ( SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo                                               
                                                     , string clientID
                                                     , string patID
                                                     , string editDelReason
                                                     , string validateRec                                               
                                                     , string recID )
    {
        /*----------------------------
         * Validate
         *----------------------------*/

        long   vClientID   = Validate.reqClientID (uInfo, clientID);
        long   vPatID      = Validate.reqPatID    (uInfo, patID);
  
        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/
        
        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patID",    SqlDbType.BigInt,   vPatID,     ParameterDirection.Input));

        /*----------------------------
         * Call base method 
         *----------------------------*/

        return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed", ref parms);
    }

    /***************************************************************************
     * delete
     *
     * 
     ***************************************************************************/
    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        clientID
                                            , string        patID
	                                        , string        deliveryExceptionRemovedReasonID
	                                        , string        deliveryExceptionRemovedNotes 
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        recID )
    {
        string deleteSproc  = @"PATIENTS_Promised_Services_Delivery_Exceptions_Delete";
                                
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  
      
      long      vClientID                         = Validate.reqClientID (uInfo, clientID);
      long      vPatID                            = Validate.reqPatID    (uInfo, patID);
      int       vDeliveryExceptionRemovedReasonID = Validate.reqInteger  (deliveryExceptionRemovedReasonID,   @"Invalid reason");
      string    vDeliveryExceptionRemovedNotes    = Validate.optString   (deliveryExceptionRemovedNotes,      @"Invalid notes");

      var parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",                         SqlDbType.BigInt,   vClientID,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                            SqlDbType.BigInt,   vPatID,                            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@deliveryExceptionRemovedReasonID", SqlDbType.Int,      vDeliveryExceptionRemovedReasonID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@deliveryExceptionRemovedNotes",    SqlDbType.VarChar,  vDeliveryExceptionRemovedNotes,    ParameterDirection.Input, -1));
   
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete (connSpedmon,log,uInfo, editDelReason, validateRec, recID, deleteSproc,ref parms);
    }
 
    /***************************************************************************
     * save 
     *
     * 
     ***************************************************************************/
    public static ReturnSaveRecord save ( 
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , string        clientID
	    , string        patID
	    , string        svcTrackingClass
	    , string        spEdServiceCode
	    , string        orpDocStandardSelectionNameID
	    , string        planStartDate
	    , string        planEndDate
	    , string        spEdFreqCode
	    , string        minsPerFreq
	    , string        dosStart
	    , string        dosEnd
	    , string        numMinsMissing
	    , string        deliveryExceptionAddedReasonID
	    , string        deliveryExceptionAddedNotes
        , string        editDelReason
        , string        validateRec
        , string        saveType
        , string        recID )
    {
      
      string saveSproc = @"PATIENTS_Promised_Services_Delivery_Exceptions_Save";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters.
        ###########################################################################*/  
     
        long      vClientID                       = Validate.reqClientID (uInfo, clientID);
        long      vPatID                          = Validate.reqPatID    (uInfo, patID);
        long      vSvcTrackingClass               = Validate.reqInteger  (svcTrackingClass,                 @"Invalid service tracking class");
        Object    vSpEdServiceCode                = Validate.optInteger  (spEdServiceCode,                  @"Invalid service", true);
        Object    vOrpDocStandardSelectionNameID  = Validate.optInteger  (orpDocStandardSelectionNameID,    @"Invalid service", true);
        DateTime  vPlanStartDate                  = Validate.reqDate     (planStartDate,                    Messages.INVALID_START_DATE);
        DateTime  vPlanEndDate                    = Validate.reqDate     (planEndDate,                      Messages.INVALID_END_DATE);
        int       vSpEdFreqCode                   = Validate.reqInteger  (spEdFreqCode,                     @"Invalid service frequency");
        int       vMinsPerFreq                    = Validate.reqInteger  (minsPerFreq,                      @"Invalid minutes per frequency");
        DateTime  vDosStart                       = Validate.reqDate     (dosStart,                         Messages.INVALID_START_DATE);
        DateTime  vDosEnd                         = Validate.reqDate     (dosEnd,                           Messages.INVALID_END_DATE);
        int       vNumMinsMissing                 = Validate.reqInteger  (numMinsMissing,                   @"Invalid number of minutes");
        int       vDeliveryExceptionAddedReasonID = Validate.reqInteger  (deliveryExceptionAddedReasonID,   @"Invalid reason");
        string    vDeliveryExceptionAddedNotes    = Validate.optString   (deliveryExceptionAddedNotes,      @"Invalid notes");
        
        var parms = new List<SqlParameter>();
 
        parms.Add(Database.SqlParm("@clientID",                       SqlDbType.BigInt,   vClientID,                       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patID",                          SqlDbType.BigInt,   vPatID,                          ParameterDirection.Input));
        parms.Add(Database.SqlParm("@svcTrackingClass",               SqlDbType.Int,      vSvcTrackingClass,               ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdServiceCode",                SqlDbType.Int,      vSpEdServiceCode,                ParameterDirection.Input));
        parms.Add(Database.SqlParm("@orpDocStandardSelectionNameID",  SqlDbType.BigInt,   vOrpDocStandardSelectionNameID,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@planStartDate",                  SqlDbType.Date,     vPlanStartDate,                  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@planEndDate",                    SqlDbType.Date,     vPlanEndDate,                    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdFreqCode",                   SqlDbType.Int,      vSpEdFreqCode,                   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@minsPerFreq",                    SqlDbType.Int,      vMinsPerFreq,                    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@dosStart",                       SqlDbType.DateTime, vDosStart,                       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@dosEnd",                         SqlDbType.DateTime, vDosEnd,                         ParameterDirection.Input));
        parms.Add(Database.SqlParm("@numMinsMissing",                 SqlDbType.Int,      vNumMinsMissing,                 ParameterDirection.Input));
        parms.Add(Database.SqlParm("@deliveryExceptionAddedReasonID", SqlDbType.Int,      vDeliveryExceptionAddedReasonID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@deliveryExceptionAddedNotes",    SqlDbType.VarChar,  vDeliveryExceptionAddedNotes,    ParameterDirection.Input, -1));

        /*###########################################################################
          # Call base method which handles the rest and returns the results
          ###########################################################################*/  

        return Entities.save (
              connSpedmon
            , log
            , uInfo
            , saveType
            , validateRec
            , editDelReason
            , recID
            , saveSproc
            , @"A record has already been entered"
            , ref parms
            , null);
    }
  }
}