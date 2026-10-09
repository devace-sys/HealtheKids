﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Net.Mail;
using MBA;
using MBA.Reporting;
using Spedmon;
using Spedmon.Reports;

namespace Spedmon
{
  
  /***************************************************************************
   * FileExportDistApp */
  /**
   * File export distribution application
   * Part 2/2 of this class
   * The first part is in Program.cs
   ***************************************************************************/                  
    
  partial class FileExportDistApp:BatchApplication
  {
      
   
    /***************************************************************************
     * GetDistributionList */
    /**
     * Gets distribution list
     ***************************************************************************/      
    
    static private bool getDistributionList( out List<MBA.FileExportDistribution> fileExportDistributions )  
    {
      bool retState = true;

      fileExportDistributions = new List<MBA.FileExportDistribution>();          
            
      try
      { 
        ReturnDB rdo = (ReturnDB) callMethodView (delegate {        
          return MBA.FileExportDistributions.view (dbConnUser, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", "Y", "spedcare", "", null);
        }, true, false);                   
                 
        List<Object> slo = Database.convertRecordsToList (ref rdo.records, typeof(MBA.FileExportDistribution));        
        foreach (var o in slo) {
          fileExportDistributions.Add ( (MBA.FileExportDistribution) o );
        }
        retState = true;
      }
      catch (Exception e) {

        retState = false;
      }
      return retState;     
    }
    
   
   /***************************************************************************
     * runDate */
    /**
     * The date this application is ACTUALLY running
     ***************************************************************************/   

    protected static DateTime runDate = DateTime.Now;
    
    
    /***************************************************************************
     * main */
    /**
     * Code for main delegate
     * Note: This is the main entry point.
     ***************************************************************************/      
    
    static void main()
    {
      /*============================================================
       * Get run date
       *============================================================*/       
     
      runDate = DateTime.Now;

      /*============================================================
       * Get file export distribution list
       *============================================================*/       

      DisplayNotice(Return.RET_INFO,"Getting file export distribution list");          

      List<MBA.FileExportDistribution> fileExportDistributions = new List<FileExportDistribution>();
      
      if (getDistributionList(out fileExportDistributions) == false) return;
      
      if (fileExportDistributions.Count == 0) {          
        DisplayNotice(Return.RET_WARNING,"No distribution records");        
        return;
      }

      if (cancelApp) return; /* Exit on cancel */

      /*============================================================
       * Process the list
       * 
       * Note: This is the main processing loop
       *============================================================*/       

      foreach (var fileExportDistribution in fileExportDistributions) {            

        if (cancelApp) break; /* Exit on cancel */
        
        byte[]          fileBytes = null;
        string          fileName  = "";
        ReturnDataTable reportData = null;
           
        try
        { 
  
          /*============================================================
           * Notify user what distribution is being worked on and if
           * its ok to process it today
           *============================================================*/                 

          DisplayNotice(Return.RET_INFO,"Processing {0} {1} for client ID {2}"
              , fileExportDistribution.distributionSourceName
              , fileExportDistribution.PublicationName
              , fileExportDistribution.clientID.ToString());
        
          if (!Schedule.IsValueAScheduledDate(runDate,fileExportDistribution.Schedule)) {
            DisplayNotice(Return.RET_INFO,"Not scheduled to generate and distribute today");
            continue;       
          }
             
          DisplayNotice(Return.RET_INFO,"Ok to generate and distribute today");
        
          if (cancelApp) break; /* Exit on cancel */
                                                 
          /*============================================================
           * Generate data for the export based on the report data
           * used and the data source.
           *============================================================*/                       
         
          if (fileExportDistribution.DataSource == Constants.FILE_EXPORT_ORDERS_CURRENT_AND_EXPIRING) { 
            DisplayNotice(Return.RET_INFO,"Getting data for current and expiring orders"); 
            reportData = callMethodViewDataTable( delegate {              
              return Spedmon.ORPDocuments.rptCurrentAndExpiringOrders (dbConnApp, log, uInfo, false, "", fileExportDistribution.clientID.ToString(), false);
            }
            , true
            , false); 
          }
          else {
            DisplayNotice(Return.RET_WARNING,"Unknown data source"); 
            continue;
          }           
                            
          if (cancelApp) break; /* Exit on cancel */
          
          /*============================================================
           * No records, continue
           *============================================================*/             
          
          if (reportData.hasRecords == false) {                         
            DisplayNotice(Return.RET_WARNING,"No records"); 
            continue;
          }

          /*============================================================
           * Create report FILE (bytes) based on requested format
           *============================================================*/             
            
          /*----------------------------
           * Excel (3)
           *----------------------------*/

          if (fileExportDistribution.fileTypeRequested == Constants.REPT_FORMAT_XLS) {                                   
            DisplayNotice(Return.RET_INFO,"Generating excel file");
            fileBytes = Excel2.returnDataTableToFile(ref reportData);
            fileName  = reportData.GenerateFileName("xlsx");
          }
              
          /*----------------------------
           * CSV (9)
           *----------------------------*/

          else if (fileExportDistribution.fileTypeRequested == Constants.REPT_FORMAT_CSV) {
            DisplayNotice(Return.RET_INFO,"Generating CSV file");
            fileBytes = CSV.returnDataTableToFile(ref reportData);
            fileName  = reportData.GenerateFileName("csv");        
          }
          
          /*----------------------------
           * PSV (10)
           *----------------------------*/

          else if (fileExportDistribution.fileTypeRequested == Constants.REPT_FORMAT_PSV) {
            DisplayNotice(Return.RET_INFO,"Generating PSV file"); 
            fileBytes = PSV.returnDataTableToFile(ref reportData);
            fileName  = reportData.GenerateFileName("txt");        
          }

          /*----------------------------
           * We don't know the format          
           * raise error
           *----------------------------*/
               
          else {
            DisplayNotice(Return.RET_ERROR,"Unknown format"); 
            continue;
          }              
        
          if (cancelApp) break; /* Exit on cancel */
                                                    
          /*============================================================
           * Save file
           *============================================================*/  
          
          string filePathAndName = Path.Combine(fileExportDistribution.destinationFolder,fileName);
          DisplayNotice(Return.RET_INFO,"Attempting to save {0}",filePathAndName); 
          
          System.IO.File.WriteAllBytes (filePathAndName, fileBytes);

        }
        catch (Exception e) {
          DisplayNotice(Return.RET_ERROR,e.Message);           
          continue;
        }
      } /* export file distributions */
    } /* main() */
  }
}