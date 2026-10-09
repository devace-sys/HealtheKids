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
   * PatientVitalsMeasurment */
  /**
   * Physician based standard document record
   **************************************************************************/

  public class PatientVitalsMeasurement: Entity
  {
        public long clientID;
        public long patID;
        public DateTime measurementDate;
        public string measurementDateStr;
        public string measurementDateYMD;
        public TimeSpan measurmentTime;
        public string measurmentTimeStr;
        public string measurmentTimeHMS;
        public decimal temp;
        public string tempStr;
        public int pulseRate;
        public string pulseRateStr;
        public int respiratoryRate;
        public string respiratoryRateStr;
        public int bloodPressureSys;
        public string bloodPressureSysStr;
        public int bloodPressureDia;
        public string bloodPressureDiaStr;
        public int o2Saturation;
        public string o2SaturationStr;
        public int bloodGlucose;
        public string bloodGlucoseStr;
        public int heightFt;
        public string heightFtStr;
        public decimal heightInch;
        public string heightInchStr;
        public decimal weightlb;
        public string weightlbStr;

        public const string DEFAULT_PAGING_ORDER = @"id desc";
    }

    /***************************************************************************
     * PatientVitalsMeasurements */
    /**
     * Methods to work with physician based standards documentation
     **************************************************************************/

    public class PatientVitalsMeasurements: Entities
  { 
    
     public const string URL_SVC_BASE                = @"patientvitals.asmx";
     public const string URL_REST_SAVE_INLINE        = URL_SVC_BASE + @"/saveinline";
     public const string URL_REST_DELETE_INLINE      = URL_SVC_BASE + @"/deleteinline";
     public const string URL_REST_VIEW               = @"api/v1/patientvitals";
     public const string URL_VIEW_REPORT             = @"patientvitals.ashx";

        /***************************************************************************
            * URL_REST_VIEW */
        /**
            * 
        **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PatientVitalsMeasurements.URL_REST_VIEW, true);
        }
        public static string URL_REST_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientVitalsMeasurements.URL_REST_SAVE_INLINE, true);
        }

        public static string URL_REST_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientVitalsMeasurements.URL_REST_DELETE_INLINE, true);
        }

        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(PatientVitalsMeasurements.URL_VIEW_REPORT, true);
        }

        /***************************************************************************
         * delete */
        /**
         * "Deletes" record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                               , DetailsLog      log
                                               , UserInfo        uInfo
                                               , string          editDelReason
                                               , string          validateRec
                                               , string          recID )
    {           
                
      string deleteSproc  = @"PATIENT_VITALS_MEASUREMENTS_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      Object vClientID = Validate.optClientID(uInfo, "");      
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);
    }


        /***************************************************************************
         * save */
        /**
         * Save new or update existing record
         *
         * @param  userID          User id of who is recording service
         * @param  userGroup       1 = Client, 2 = SBSC (from users db)
         * @param  userRank        Users role ranking
         * @param  clientID
         * @param  patID 
         * @param  measurementDate
         * @param  measurmentTime
         * @param  temp
         * @param  pulseRate
         * @param  respitoryRate
         * @param  bloodPressureSys
         * @param  bloodPressureDia
         * @param  o2Saturation
         * @param  bloodGlucose
         * @param  heightFt 
         * @param  heightInch
         * @param  weight 
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

        public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        clientID
										     , string        patID
                                             , string        temp
                                             , string        pulseRate
                                             , string        respiratoryRate
                                             , string        bloodPressureSys
                                             , string        bloodPressureDia
                                             , string        o2Saturation
                                             , string        bloodGlucose
                                             , string        heightFt
                                             , string        heightInch
                                             , string        weightlb
                                             , string        editDelReason
                                             , string        validateRec
                                             , string        saveType
                                             , string        recID)
        {           
                       
      string saveSproc  = @"PATIENT_VITALS_MEASUREMENTS_SAVE";
      string dupRecMsg  = @"Patient vitals measurements already exists";
      
      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/  
           
      long       vClientID                = Validate.reqClientID (uInfo,            clientID);
      long       vPatID                   = Validate.reqPatID    (uInfo,            patID);
      var        vTemp                    = Validate.optFixed    (temp,             @"Invalid temperature value");
      var        vPulseRate               = Validate.optInteger  (pulseRate,        @"Invalid pulse rate value",               true);
      var        vRespiratoryRate         = Validate.optInteger  (respiratoryRate,  @"Invalid respiratory rate value",         true);
      var        vBloodPressureSys        = Validate.optInteger  (bloodPressureSys, @"Invalid blood pressure systolic value",  true);
      var        vBloodPressureDia        = Validate.optInteger  (bloodPressureDia, @"Invalid blood pressure diastolic value", true);
      var        vO2Saturation            = Validate.optInteger  (o2Saturation,     @"Invalid O2 saturation value",            true);
      var        vBloodGlucose            = Validate.optInteger  (bloodGlucose,     @"Invalid Blood Glucose value",            true);
      var        vHeightFt                = Validate.optInteger  (heightFt,         @"Invalid height value",                   true);            
      var        vHeightInch              = Validate.optFixed    (heightInch,       @"Invalid height value");
      var        vWeight                  = Validate.optFixed    (weightlb,         @"Invalid weight value");
                  
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,     vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,     vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@temp",                SqlDbType.Decimal,    vTemp,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pulseRate",           SqlDbType.SmallInt,   vPulseRate,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@respiratoryRate",     SqlDbType.SmallInt,   vRespiratoryRate,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@bloodPressureSys",    SqlDbType.SmallInt,   vBloodPressureSys,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@bloodPressureDia",    SqlDbType.SmallInt,   vBloodPressureDia,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@o2Saturation",        SqlDbType.SmallInt,   vO2Saturation,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@bloodGlucose",        SqlDbType.SmallInt,   vBloodGlucose,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@heightft",            SqlDbType.SmallInt,   vHeightFt,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@heightinch",          SqlDbType.Decimal,    vHeightInch,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@weightlb",            SqlDbType.Decimal,    vWeight,              ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
    }    

    /***************************************************************************
      * view */
      /**
      * * @param  clientID       Client ID
          @param  patID          Patient ID
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
                                  , string        patID
                                  , defineCols    dc)
    {
    
      string viewUDF = "dbo.PATIENT_VITALS_MEASUREMENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      long  vClientID           = Validate.reqClientID               (uInfo,          clientID);
      long  vPatID              = Validate.reqPatID                  (uInfo,          patID);
	    
	  List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,               ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }   
    /***************************************************************************
     * load */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static PatientVitalsMeasurement load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        patID
                                                 , string        recID )
    {      
      return (PatientVitalsMeasurement) Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientVitalsMeasurement),
      delegate { return PatientVitalsMeasurements.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, patID, null); });
    } 
      
   /*************************************************************************
    * viewListPatientVitalsRecs */
   /**
    * Return a list of Special Authorization records
    * 
    ***************************************************************************/

    public static List<PatientVitalsMeasurement> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patID
                                                         , string        active)
      
     {
        var recs = new List<PatientVitalsMeasurement>();
        ReturnDB rd = PatientVitalsMeasurements.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, patID, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PatientVitalsMeasurement));
        foreach (var o in slo) {
            recs.Add((PatientVitalsMeasurement) o);
        }
        return recs;
    }

     /***************************************************************************
      * viewSel */
      /**
      * * @param  clientID       Client ID
          @param  patID          Patient ID
     **************************************************************************/
    public static Return viewSel(  SqlConnection connSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , bool top
                                , string topSize
                                , string clientID
                                , string patID
     )
    {
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {

        };

        return Entities.viewSel(connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate {
                                    return PatientVitalsMeasurements.view(connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_SEL
                                                        , top
                                                        , topSize
                                                        , ""
                                                        , "1"
                                                        , clientID
                                                        , patID
                                                        , dc);
                                });
    }

    
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , bool          paged
                                            , string        pageNumber
                                            , string        canEdit
                                            , string        active
                                            , string        clientID
                                            , string        patID
     )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
          ss.addDisplayColumn("id");
          ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name]", "@clientID", true, ref parms);

          ss.addDisplayColumn("measurementDateStr    as [Date]");
          ss.addDisplayColumn("measurmentTimeStr     as [Time]");
          ss.addDisplayColumn("temp                  as [Temperature]");
          ss.addDisplayColumn("pulseRate             as [Pulse\nRate]");
          ss.addDisplayColumn("respiratoryRate       as [Respiratory\nRate]");
          ss.addDisplayColumn("bloodPressureSys      as [Blood\nPressure\nSystolic]");
          ss.addDisplayColumn("bloodPressureDia      as [Blood\nPressure\nDiastolic]");
          ss.addDisplayColumn("o2Saturation          as [O2\nSaturation]");
          ss.addDisplayColumn("bloodGlucose          as [Blood\nGlucose]");
          ss.addDisplayColumn("heightFt              as [Height\n(ft)]");
          ss.addDisplayColumn("heightInch            as [Height\n(in)]");
          ss.addDisplayColumn("weightlb              as [Weight]");
          if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
          {
              ss.addDisplayColumn("clientID");
              ss.addDisplayColumn("patID                as [patientID]");
          }

          pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return PatientVitalsMeasurements.view ( connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_TBL
                                                             , paged
                                                             , pageNumber
                                                             , canEdit
                                                             , active
                                                             , clientID
                                                             , patID
                                                             , dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = @"Patient Vitals Measurements";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
    }


    /***************************************************************************
    * viewObjects 
    *
    * Returns a list of patients objects
    * 
    ***************************************************************************/

    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo   uInfo                                                    
                                              , bool       pageObjectList
                                              , string     pageOrder
                                              , string     idx
                                              , string     active
                                              , string     clientID
                                              , string     patID
    )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientVitalsMeasurement.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(PatientVitalsMeasurement)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return PatientVitalsMeasurements.view (  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_OBJECTS
                                                             , pageObjectList
                                                             , idx
                                                             , "" /* Can edit */
                                                             , active
                                                             , clientID
                                                             , patID
                                                             , dc);
                                    });
      

    }        
   }
}
