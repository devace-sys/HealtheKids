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
   * PatientsPromisedServicesCDEAuditCurrent */
  /**
   * 
   **************************************************************************/
  
  public class PatientsPromisedServicesCDEAuditCurrent : CdeComplianceBucketSummary
  {    
    public const string DEFAULT_PAGING_ORDER = "startDate asc";
    public long   clientID;
    public int    lastImportIssueCount;
    public string lastPatientDataImportResultsJSON;
  }

 
  /***************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrent */
  /**
   * 
   **************************************************************************/

  public class PatientsPromisedServicesCDEAuditsCurrent:Entities
  {            
      public const string SEL_LABEL                                     = CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT_SHORT;
      public const string SEL_LABEL_PERFORMANCE_BY_SITE_SERVICE_SUMMARY = SEL_LABEL + " - Performance by Site - By Service - Summary";
      public const string SEL_LABEL_PERFORMANCE_BY_SITE_BUCKET_SUMMARY  = SEL_LABEL + " - Performance by Site - By Bucket - Summary";
      public const string SEL_LABEL_PERFORMANCE_BY_SERVICE_SUMMARY      = SEL_LABEL + " - Performance - By Service - Summary";
      public const string SEL_LABEL_PERFORMANCE_BY_BUCKET_SUMMARY       = SEL_LABEL + " - Performance - By Bucket - Summary";

      /***************************************************************************
       * load */
      /**
       * 
       **************************************************************************/
 
      public static PatientsPromisedServicesCDEAuditCurrent load (  SqlConnection connSpedmon
                                                                  , DetailsLog    log
                                                                  , UserInfo      uInfo
                                                                  , string        clientID
                                                                  , string        patAbsentMinsAreSatisfiedMins)
      {
        var so = new PatientsPromisedServicesCDEAuditCurrent();

        so = (PatientsPromisedServicesCDEAuditCurrent) Entities.loadNRecord (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , 0
                                                      , typeof(PatientsPromisedServicesCDEAuditCurrent)
                                                      , delegate { 
                                                          return PatientsPromisedServicesCDEAuditsCurrent.view ( connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_RAW                                                                                           
                                                                                                , false
                                                                                                , ""
                                                                                                , ""
                                                                                                , ""
                                                                                                , clientID
                                                                                                , patAbsentMinsAreSatisfiedMins                                                                                                , null );});
               
        return so;
      }
        
      /***************************************************************************
       * get */
      /**
       * 
       **************************************************************************/
 
      public static ReturnEntity get (  SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , string        clientID
                                       , string        patAbsentMinsAreSatisfiedMins)
      {
        var so = new ReturnEntity();
        so.entity = PatientsPromisedServicesCDEAuditsCurrent.load(connSpedmon,log,uInfo,clientID,patAbsentMinsAreSatisfiedMins);
        return so;
      }
        
     /***************************************************************************
      * save */
     /**
      * Save 
      * 
      ***************************************************************************/   
  
      public static ReturnSaveOrReplaceRecord save  (   SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        startdate
                                                      , string        enddate
                                                      , string        validateRec )
      {           
    
        
       string saveOrReplaceSproc = "Patients_Promised_Services_CDE_Audits_Current_Save";                


       /*-------------------------------
        * Validate parameters
        *----------------------------*/
		   
       long     vClientID    = Validate.reqClientID (uInfo, clientID);
       DateTime vStartDate   = Validate.reqDate     (startdate,      Messages.INVALID_START_DATE);
       DateTime vEndDate     = Validate.reqDate     (enddate,        Messages.INVALID_END_DATE);

       /*----------------------------
        * Pass parm values to sp
        *----------------------------*/  

       var parms = new List<SqlParameter>();  

 	   parms.Add(Database.SqlParm ("@clientID",     SqlDbType.BigInt,   vClientID,   ParameterDirection.Input) );
       parms.Add(Database.SqlParm ("@startDate",    SqlDbType.DateTime, vStartDate,  ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@endDate",      SqlDbType.DateTime, vEndDate,    ParameterDirection.Input));
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord ( connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveOrReplaceSproc
                                             , ref parms
                                             , delegate(){});
                                                                                       
       
       return so;

    }

    /*************************************************************************
     * view */
    /**
     *
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
                                  , string        patAbsentMinsAreSatisfiedMins
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_View (@userID, @userGroup, @userRank, @clientID, @patAbsentMinsAreSatisfiedMins)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var  vClientID                      = Validate.reqClientID (uInfo, clientID);
      bool vPatAbsentMinsAreSatisfiedMins = Validate.reqFlag     (patAbsentMinsAreSatisfiedMins,@"Invalid value for patient absenses are treated as mins satisfied",false);
      
      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID",                      SqlDbType.BigInt, vClientID,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit,    vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
   }

   /***************************************************************************
    * rptPerformanceByServiceSummary */
   /**
    * 
    **************************************************************************/  
   public static ReturnDataTable rptPerformanceByServiceSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_PERFORMANCE_BY_SERVICE_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_SpEdSvc_Summary_Rpt (null, null, null, @clientID, @patAbsentMinsAreSatisfiedMins)";
       
       /*-------------------------------
        * Validate
        *-------------------------------*/
       
       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */

       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = Spedmon.CdeComplianceCommon.defineColsRptPerformanceByServiceSummary(false);

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();
       
       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));      
       prms.Add(Database.SqlParm ("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

       /*-------------------------------
        * Get Data
        *-------------------------------*/

       ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);            

       /*-------------------------------
        * Set Table Name
        *-------------------------------*/

       rd.tableName = tblName;

       /*-------------------------------
        * Done
        *-------------------------------*/

       return rd;
    }

   /***************************************************************************
    * rptPerformanceBySiteServiceSummary */
   /**
    * 
    **************************************************************************/  
   public static ReturnDataTable rptPerformanceBySiteServiceSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_PERFORMANCE_BY_SITE_SERVICE_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt (null, null, null, @clientID, @patAbsentMinsAreSatisfiedMins)";
       
       /*-------------------------------
        * Validate
        *-------------------------------*/
       
       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */
                                                   // ^ EXISTING LOGIC: we are not yet passing this up the stack
       
       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = Spedmon.CdeComplianceCommon.defineColsRptPerformanceBySiteServiceSummary(false);

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();

       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));      
       prms.Add(Database.SqlParm ("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

       /*-------------------------------
        * Get Data
        *-------------------------------*/

       ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);            

       /*-------------------------------
        * Set Table Name
        *-------------------------------*/

       rd.tableName = tblName;

       /*-------------------------------
        * Done
        *-------------------------------*/

       return rd;
    }
   
   /***************************************************************************
    * rptPerformanceByBucketSummary */
   /**
    * 
    **************************************************************************/  
   public static ReturnDataTable rptPerformanceByBucketSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_PERFORMANCE_BY_BUCKET_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt (null, null, null, @clientID ,@patAbsentMinsAreSatisfiedMins)";
       
       /*-------------------------------
        * Validate
        *-------------------------------*/
       
       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */
       
       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
       {
         ss.addDisplayColumn("clientName as [District]",                true);
         ss.addDisplayColumn("auditStartDate as [From\nDate\nof\nService]");
         ss.addDisplayColumn("auditEndDate as [To\nDate\nof\nService]");
         ss.addDisplayColumn("patsInBucketA as [Students\nIn\nBucket A]");
         ss.addDisplayColumn("patsInBucketB as [Students\nIn\nBucket B]");
         ss.addDisplayColumn("patsInBucketC as [Students\nIn\nBucket C]");
         ss.addDisplayColumn("totalPats as [Total\nStudents]");
         pageroworder = ss.pageRowOrder();
       };

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();
       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));      
       prms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

       /*-------------------------------
        * Get Data
        *-------------------------------*/

       ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);            

       /*-------------------------------
        * Set Table Name
        *-------------------------------*/

       rd.tableName = tblName;

       /*-------------------------------
        * Done
        *-------------------------------*/

       return rd;
    }

  /***************************************************************************
    * rptPerformanceBySiteBucketSummary */
   /**
    * 
    **************************************************************************/  
   public static ReturnDataTable rptPerformanceBySiteBucketSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_PERFORMANCE_BY_SITE_BUCKET_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt (null, null, null, @clientID, @patAbsentMinsAreSatisfiedMins)";
       
       /*-------------------------------
        * Validate
        *-------------------------------*/
       
       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */

       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
       {
         ss.addDisplayColumn("clientName as [District]",                true);
         ss.addDisplayColumn("siteName as [Site]",                      true);
         ss.addDisplayColumn("auditStartDate as [From\nDate\nof\nService]");
         ss.addDisplayColumn("auditEndDate as [To\nDate\nof\nService]");
         ss.addDisplayColumn("totalInBucketA as [Students\nIn\nBucket A]");
         ss.addDisplayColumn("totalInBucketB as [Students\nIn\nBucket B]");
         ss.addDisplayColumn("totalInBucketC as [Students\nIn\nBucket C]");
         ss.addDisplayColumn("totalInBuckets as [Total\nStudents]");
         pageroworder = ss.pageRowOrder();
       };

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();
       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));      
       prms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

       /*-------------------------------
        * Get Data
        *-------------------------------*/

       ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);            

       /*-------------------------------
        * Set Table Name
        *-------------------------------*/

       rd.tableName = tblName;

       /*-------------------------------
        * Done
        *-------------------------------*/

       return rd;
    }
  }
}
