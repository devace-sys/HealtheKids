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
   * PatientsPromisedServicesComplianceCurrentFY */
  /**
   * 
   **************************************************************************/

  public class PatientsPromisedServicesComplianceCurrentFY:Entities
  {            


    public const string SEL_LABEL_ANNUAL_PERFORMANCE_BY_SITE_SERVICE_SUMMARY = "IDEA Compliance - Performance By Site and Service - FY To Date";
    public const string SEL_LABEL_ANNUAL_PERFORMANCE_BY_SERVICE_SUMMARY      = "IDEA Compliance - Performance By Service - FY To Date";


    /***************************************************************************
        * rptAnnualPerformanceBySiteServiceSummary */
    /**
        * 
        **************************************************************************/


   public static ReturnDataTable rptAnnualPerformanceBySiteServiceSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID
    )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_ANNUAL_PERFORMANCE_BY_SITE_SERVICE_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt (null, null, null, @clientID )";

            /*-------------------------------
             * Validate
             *-------------------------------*/
       
       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       
       
       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = CdeComplianceCommon.defineColsRptPerformanceBySiteServiceSummary(true);

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();

       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));          

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
        * rptAnnualPerformanceByServiceSummary */
    /**
        * 
        **************************************************************************/

   public static ReturnDataTable rptAnnualPerformanceByServiceSummary (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , bool          paged
         , string        pageNumber
         , string        clientID
    )
   {
          
       /*-------------------------------
        * Define Table Name with TS
        *-------------------------------*/       

       string tblName = String.Format("{0}-{1}"
                                      , SEL_LABEL_ANNUAL_PERFORMANCE_BY_SERVICE_SUMMARY 
                                      , DateTime.Now.ToYYYYMMDDHHMMSSString());                

       /*-------------------------------
        * Define Report UDF
        *-------------------------------*/       

       string reportUDF = "dbo.Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt (null, null, null, @clientID )";
       
       /*-------------------------------
        * Validate
        *-------------------------------*/

       Object vClientID = Validate.optClientID (uInfo, clientID); /* PCAL staff can call for all clients */
       
       
       /*-------------------------------
        * Define columns
        *-------------------------------*/

       defineCols dc = CdeComplianceCommon.defineColsRptPerformanceByServiceSummary(true);

       /*-------------------------------
        * Pass parameters
        *-------------------------------*/

       var prms = new List<SqlParameter>();

       prms.Add(Database.SqlParm ("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));          

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