using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MBA;
using Spedmon;
using System.IO;
using System.Threading;
using wf = System.Windows.Forms;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Configuration;

namespace Spedmon
{
  /***************************************************************************
   * ReportsApp */
  /**
   * A windows forms application for generating bulk reports for clients.
   ***************************************************************************/   

  partial class ReportsApp:WinFormsApplication
  {
  
    /***************************************************************************
     * Client */
    /**
     * Internal class for storing client name/value data.
     * The list type controls require classes with properties.
     ***************************************************************************/   
     
    public class Client
    {
      public Client(long id, string name)
      {
        this.id   = id;
        this.name = name;
      }
      
      public long   id   {get;set;}
      public string name {get;set;}
    }
        
    /***************************************************************************
     * clients */
    /**
     * Our internal list of clients.
     ***************************************************************************/   

    public static Client[] clients;
        
    /***************************************************************************
     * getClients */
    /**
     * Calls the framework Clients.viewSel method to retrieve a list of clients
     * then returns an array of Client.
     ***************************************************************************/   

    protected static Client[] getClients()
    {
                   
      /*----------------------------
       * Create temporary list of
       * Client
       *----------------------------*/
      
      List<Client> clientsLst = new List<Client>();
      
      /*----------------------------
       * Call Clients.vewSel and
       * return the results.
       *----------------------------*/
      
      ReturnSel clientsSel = callMethodViewSel(delegate{
        return Spedmon.Clients.viewSel(dbConnApp, log, uInfo, false, "", "");
      }, false, true);
      
      /*----------------------------
       * Extract client data from
       * results and store in our
       * temporary list
       *----------------------------*/
      
      foreach (SelRec selrec in clientsSel.SelRecs)
        clientsLst.Add(new Client(selrec.id,selrec.label));

      /*----------------------------
       * Return the client list as
       * an array of Client
       *----------------------------*/
      
      return clientsLst.ToArray();
      
    }
   
    public static bool CheckFolder(string folder)
    {
      /*----------------------------
       * See if folder is defined
       *----------------------------*/   
      
      if (Util.IsNullOrEmpty(folder))
      {
        ReportsApp.DisplayNotice(MBA.Return.RET_WARNING,"You have not selected or entered a folder.");
        return false;
      }
      
      /*----------------------------
       * See if folder exists
       *----------------------------*/   

      if (!Directory.Exists(folder))
      {
        ReportsApp.DisplayNotice(MBA.Return.RET_WARNING,"The folder you selected or entered does not exist.");
        return false;
      }
      
      return true;
    }
  
    
    public static void generateClaimsPaidByDate1PReports(BackgroundWorker worker,
                                                         List<Client> selectedclients, 
                                                         string daterange,
                                                         string showzeros, 
                                                         string folder,
                                                         int report,
                                                         int format)
    {
      
      /*----------------------------
       * If worker indicates a 
       * cancellation has been
       * requested, alert user and 
       * get out.
       *----------------------------*/   

      if (worker.CancellationPending) 
      {
        worker.ReportProgress (100, "Canceling");
        return;
      }
      
      /*----------------------------
       * Init values used for progress
       * (percentage completed)
       * calculation.
       *----------------------------*/   
      
      int total = selectedclients.Count();
      int count = 1;
      
      /*----------------------------
       * Generate reports for each
       * client passed in
       *----------------------------*/   

      foreach (Client c in selectedclients)
      {
        
        /*----------------------------
         * If worker indicates a 
         * cancellation has been
         * requested, alert user and 
         * get out.
         *----------------------------*/   
        
        if (worker.CancellationPending) 
        {
          worker.ReportProgress (100, "Canceling");
          return;
        }
        
        /*----------------------------
         * Get client id and name
         *----------------------------*/   
        
        string clientid   = c.id.ToString();
        object clientname = c.name;
                
        /*----------------------------
         * Calculate and report 
         * progress
         *----------------------------*/
        
        int progress = Util.calculateProgress(count, total);
        string msg   = Util.createMessageString (@"Generating report for {0} [{1},{2}] [{3}/{4}]", c.name, report.ToString(), format.ToString(), count.ToString(), total.ToString());
        worker.ReportProgress (progress, msg);
        
        /*----------------------------
         * Generate report
         *----------------------------*/   

        bool retstate = generateClaimsPaidByDate1PReport (clientid, 
                                                          daterange, 
                                                          showzeros,
                                                          folder,
                                                          report,
                                                          format);
        /*----------------------------
         * If the report generation
         * was not succesful, 
         * alert user then get out
         *----------------------------*/   

        if (!retstate)
        {
          ReportsApp.DisplayNotice(Return.RET_WARNING,@"There was a problem with generating your report(s).  Please make sure you do not have any reports open for viewing and try again."); 
          break;
        }
                
        count++;
      }
      
      /*----------------------------
       * All done
       *----------------------------*/   

      worker.ReportProgress(100, "Reports complete");   
      return;  
    }
    
    /**************************************************************************
     * generateClaimsPaidByDate1PReport*/
    /**
     * Calls the appropriate method from Spedmon.Financial
     * 
     ***************************************************************************/   

     public static bool generateClaimsPaidByDate1PReport (string clientID, 
                                                          string dateRange,
                                                          string includeZeros,
                                                          string folder,
                                                          int report,
                                                          int format)
    {
                         
      ReturnRptData rd = null;
      
      /*----------------------------
       * Check Date 1P
       *----------------------------*/
            
      if (report == Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P)
      {
        /*----------------------------
         * Call Spedmon.Reports.Financial
         * rptClaimsPaidByCheckDate1P
         * method and return results
         * into a report data object
         *----------------------------*/

        rd = (ReturnRptData) callMethod(typeof(ReturnRptData), delegate {
          return Spedmon.Reports.Fianancial.rptClaimsPaidByCheckDate1P(dbConnApp, 
                                                                       log, 
                                                                       uInfo, 
                                                                       clientID , 
                                                                       dateRange,
                                                                       includeZeros,
                                                                       true);
        }, false, true);
      }
 
      /*----------------------------
       * Service Date 1P
       *----------------------------*/

      else if (report == Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_1P)
      {
        /*----------------------------
         * Call Spedmon.Reports.Financial
         * rptClaimsPaidByServiceDate1P
         * method and return results
         * into a report data object
         *----------------------------*/
      
        rd = (ReturnRptData) callMethod(typeof(ReturnRptData), delegate {
          return Spedmon.Reports.Fianancial.rptClaimsPaidByServiceDate1P(dbConnApp, 
                                                                         log, 
                                                                         uInfo, 
                                                                         clientID , 
                                                                         dateRange,
                                                                         includeZeros,
                                                                         true);
        }, false, true);
      }
      else
      {
        return false;
      }
      
      
      /*----------------------------
       * Check status
       *----------------------------*/

      if (rd.status != Return.RET_SUCCESS) 
      {
        if (rd.message == Messages.NO_RECORDS_FOUND)
          return true;
        else
          return false;
      }     
    
      /*----------------------------
       * Convert report data into
       * a report file
       *----------------------------*/       
      
      Byte[] rf = null;
      string fn = "";
            
      if (format == Constants.REPT_FORMAT_PDF_REPORT)
      {
                                  
        /*----------------------------
         * Create PDF file (bytes)
         * from report data
         *----------------------------*/
        
        rf = MBA.PDF.ReturnRptDataToPDF(ref rd);
        fn = MBA.PDF.GenerateFileName(folder, rd.filename);
      
      }
      else if (format == Constants.REPT_FORMAT_XLS_REPORT)
      {
                          
       /*----------------------------
        * Create Excel file (bytes)
        * from report data
        *----------------------------*/
        
        rf = Excel.ReturnRptDataToXLS(ref rd);
        fn = MBA.Excel.GenerateFileName(folder, rd.filename);
      }
      else if (format == Constants.REPT_FORMAT_HTML_REPORT)
      {
      
       /*----------------------------
        * Create HTML file (bytes)
        * from report data
        *----------------------------*/
        
        rf = HTML.ReturnRptDataToHTML(ref rd);
        fn = MBA.HTML.GenerateFileName(folder, rd.filename);

      }
      else
      {
        return false;
      }             
      
      /*----------------------------
       * Write file to disk
       *----------------------------*/
      
      try
      {
        MBA.File.WriteBytes(fn, ref rf);
      }
      catch (Exception e)
      {
        ReportsApp.DisplayNotice(0,e.Message);
        return false;
      }
      
      return true;          
    }
  


  }
}
