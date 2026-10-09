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
   * RptDistApp */
  /**
   * Report distribution application
   * Part 2/2 of this class
   * The first part is in Program.cs
   ***************************************************************************/                  
    
  partial class RptDistApp:BatchApplication
  {
      
    /***************************************************************************
     * SaveHistoryRecord */
    /**
     * Saves history record 
     * 
     ***************************************************************************/                  
    
    static void SaveHistoryRecord (DistributionHistory dh, int status)
    {
      SaveHistoryRecord(dh,status,null);
    }
    
    static void SaveHistoryRecord(DistributionHistory dh, int status, Exception e)
    {
                             
      dh.Status = status;
      
      /*----------------------------
       * Set exitState to status
       * if it is not a success
       * or a warning.  This will
       * ensure the OS gets the right
       * return code.  Also logs
       * and displays status
       *----------------------------*/
        
      if ((status != Return.RET_SUCCESS) && (status != Return.RET_INFO))
      {
        exitState = status;
        DisplayNotice(status, dh.SummaryMsg + " " + dh.Message);
      }
      
      /*----------------------------
       * Display exception message
       * if applicable
       *----------------------------*/

      if (e != null)
      {
        DisplayNotice(Return.RET_ERROR, dh.SummaryMsg + " " + e.Message);
      }
        
      /*----------------------------
       * Display flags
       *----------------------------*/

      string whatFlags = Enums.WhatEnumFlagsAreSetNames<DistributionResultFlag> ((int)dh.ResultFlags);          
      DisplayNotice(status, dh.SummaryMsg + " Flags = " + whatFlags);
        
      /*----------------------------
       * Save history record
       *----------------------------*/
            
      ReturnSaveRecord hr = (ReturnSaveRecord) callMethodSaveRecord (delegate {                                                                                        
        return Spedmon.DistributionsHistory.save(dbConnApp,log,uInfo,dh);                  
      }, true, false);
    }

    /***************************************************************************
     * GetDistributionList */
    /**
     * Gets distribution list
     ***************************************************************************/      
    
    static List<Spedmon.Distribution> GetDistributionList(DateTime rd)  /* no reason why this shouldn't be a method of MBA.Distribution */
    {
    
      List<Spedmon.Distribution> Reports = new List<Spedmon.Distribution>();          
           
      ReturnDB sdo = (ReturnDB) callMethodView (delegate {
        return Spedmon.Distributions.view(dbConnApp,log,uInfo,Entities.REC_VIEW_RAW, false,null,null,null,null,rd,null);            
       }, true, false);                   
                              
      List<Object> slo = Database.convertRecordsToList(ref sdo.records, typeof(Spedmon.Distribution));
      
      foreach (Object o in slo)
        Reports.Add((Spedmon.Distribution) o);
      
      return Reports;
    }
        
    /***************************************************************************
     * DistTot */
    /**
     * Total distributions being processed today
     ***************************************************************************/  
     
     static int DistTot  = 0;
     
    /***************************************************************************
     * DistNum */
    /**
     * Current distribution number being processed
     ***************************************************************************/  
     
     static int DistNum  = 0;

    /***************************************************************************
     * runDate */
    /**
     * The date this application is ACTUALLY running
     ***************************************************************************/   

    protected static DateTime runDate = DateTime.Now;
    
    /***************************************************************************
     * procRunDate */
    /**
     * The date we are running this application FOR
     *
     ***************************************************************************/         
    
    static DateTime procRunDate = DateTime.Now;
    
    /***************************************************************************
     * main */
    /**
     * Code for main delegate
     * Note: This is the main entry point.
     ***************************************************************************/      
    
    static void main()
    {
      /*============================================================
       * Provide defaults for critical dates
       *============================================================*/       
     
      DateTime dfltRunDate     = Dates.StartDate(rundatetime);
      DateTime dfltProcRunDate = dfltRunDate;
      
      /*============================================================
       * Process arguments and use defaults if args are not passed
       *============================================================*/       
 
      procRunDate = ParseArgumentDate ("prd", dfltProcRunDate);
      runDate     = ParseArgumentDate ("rd",  dfltRunDate, "prd");
      
      if (procRunDate > runDate) throw new MBA.Critical("Proc run date cannot be greater than run date!");
        
      retryDate = runDate.AddDays(1);
           
      DisplayNotice(Return.RET_INFO,Util.createMessageString("Run date is {0}",Dates.ToLongDateAndTimeString(runDate)));         
      DisplayNotice(Return.RET_INFO,Util.createMessageString("Proc run date is {0}",Dates.ToLongDateAndTimeString(procRunDate)));         
      DisplayNotice(Return.RET_INFO,Util.createMessageString("Retry date is {0}",Dates.ToLongDateAndTimeString(retryDate)));         

      /*============================================================
       * Get report distrubution list passing in procRunDate
       * procRunDate will be used for new distribution reference
       * dates
       *============================================================*/       

      DisplayNotice(Return.RET_INFO,"Getting report distribution list");          
      List<Spedmon.Distribution> ReportDistributions = GetDistributionList(procRunDate);         
                                       
      /*============================================================
       * Check the list
       *============================================================*/       
                      
      DistTot = ReportDistributions.Count;

      /*----------------------------
       * If there is nothing to do
       * then we are done
       *----------------------------*/          
      

     /* NOTE: This script, ultimately, has three conditionals that it checks, in order to decide which reports to run, if any.
      * The first one is this one.  It checks the value from GetDistributionList(procRunDate), above.  GetDistributionList() checks against the
      * Distribution History, to avoid sending out unnecessary, duplicate reports. */
 
      if (DistTot == 0)
        DisplayNotice(Return.RET_INFO,"No distributions to process or already run today");                    
      
      /*----------------------------
       * Otherwise we might have 
       * something to do
       *----------------------------*/  
      
      else
        DisplayNotice(Return.RET_INFO,"{0} distributions to process",DistTot.ToString());                              
           

      /*============================================================
       * Process the list
       * 
       * Note: This is the main processing loop
       *============================================================*/       

      foreach (Spedmon.Distribution ReportDistribution in ReportDistributions)
      {            
        
        /*============================================================
         * Exit loop if app if being canceled
         *============================================================*/       

        if (cancelApp) break;
        
        /*============================================================
         * Update report distribution counter
         *============================================================*/ 
        
        DistNum++;  // Note: Ctr is here because of continues
                
        /*============================================================
         * Create distribution history record from list item
         * We will add to it and save it when we are done with 
         * each list item
         *============================================================*/       
           
        DistributionHistory dh = new DistributionHistory();            
        dh = DistributionHistory.Create(ReportDistribution);            
                   
        /*----------------------------
         * Save run date, save counters
         * and init message and
         * result flags
         *----------------------------*/
            
        dh.RunDate     = runDate;
        dh.ProcRunDate = procRunDate;
        dh.RetryDate   = retryDate;
        dh.DistTot     = DistTot;
        dh.DistNum     = DistNum;
        dh.Message     = "";
        dh.ResultFlags = 0;                                              
        
        /*----------------------------
         * Create start of display msg
         * this will be used by
         *----------------------------*/

        dh.SummaryMsg = Util.createMessageString(@"[{0} of {1}] {2} [{3}] ",
                                                   dh.DistNum.ToString(), 
                                                   dh.DistTot.ToString(), 
                                                   dh.ClientName, 
                                                   dh.PublicationDescription);
        
        

        /*============================================================
         * Notify user what distribution is being worked on
         *============================================================*/                 

        DisplayNotice(Return.RET_INFO,dh.SummaryMsg);
        
        /*============================================================
         * Determine if this is a new distribution or a retry
         *============================================================*/            
        
        /*----------------------------
         * Retry
         *----------------------------*/
            
        if (ReportDistribution.IsRetry)                          
          dh.ResultFlags |= DistributionResultFlag.Retry;

        /*----------------------------
         * New
         *----------------------------*/

        else
          dh.ResultFlags |= DistributionResultFlag.New;

       
        /*============================================================
         * Determine relative date ranges
         *============================================================*/      
        
        RelativeDates.RelativeDateRange RelativeDateRange1;
        //RelativeDates.RelativeDateRange RelativeDateRange2;
        
        try
        {
          
          /*----------------------------
           * Compute actual range from
           * relative value w/respect
           * to reference date
           *----------------------------*/

          RelativeDateRange1 = RelativeDates.ComputeRelativeDateRange(ReportDistribution.ReferenceDate, ReportDistribution.RelativeDateRange1);
          // RelativeDateRange2 = RelativeDates.ComputeRelativeDateRange(ReportDistribution.ReferenceDate, ReportDistribution.RelativeDateRange2);             
  
          /*----------------------------
           * Save actual range
           *----------------------------*/
          
          dh.ActualDateRange1 = RelativeDateRange1.ToString();                  
                                                                                 
        }
        
        /*----------------------------
         * If there was an issue with
         * procesing the relative date
         * expressions its probably due
         * to a distribution record
         * issue
         *----------------------------*/
        
        catch (Exception e)
        {
          dh.ResultFlags |= DistributionResultFlag.ConfigError;
          dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
          dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
          dh.Message = "Possible configuration issue with relative date fields in distribution record";             
          SaveHistoryRecord(dh,Return.RET_ERROR,e);
          continue;
        }                        
        
        /*============================================================
         * Determine relative schedule
         *============================================================*/      
        
        try
        {
         /*----------------------------
           * If the reference date does
           * not fall under the schedule
           * it is not a day that we
           * would generate this report
           * Move on to the next 
           * distribution 
           *----------------------------*/

            /* NOTE: This is the second conditional (of the three conditionals) that the script checks against, to decide
             * which reports to send.  For each individual report subscription which passed the previous conditional, we check to see if today,
             * the day the script is being run, falls on the Schedule, noted in ChronTab syntax, in the REPORT_PUBLICATIONS table. */

          if (!Schedule.IsValueAScheduledDate(ReportDistribution.ReferenceDate,ReportDistribution.Schedule))
          {               
            dh.ResultFlags |= DistributionResultFlag.NotRunDate;             
            dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
            dh.Message = "Not time to run yet";             
            DisplayNotice(Return.RET_SUCCESS, dh.Message); 
            SaveHistoryRecord(dh,Return.RET_SUCCESS); // TODO: why are we saving a record of the fact that we didn't send a report when the report wasn't due?
                                                      // And why are we saving it with a code of RET_SUCCESS ?? ... I understand that this code is tested and stable,
            continue;                                 // but I wouldn't call it scalable.  If we had a thousand subscribers and a thousand reports, this could get messy
          }

          /*----------------------------
           * Otherwise it appears that 
           * it is time to run the report
           *----------------------------*/

          else
          {
            dh.ResultFlags |= DistributionResultFlag.IsRunDate;            
          }
        }
        
        /*----------------------------
         * If there was an issue with
         * procesing the relative date
         * expressions its probably due
         * to a distribution record
         * issue
         *----------------------------*/

        catch (Exception e)
        {
          dh.ResultFlags |= DistributionResultFlag.ConfigError;
          dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
          dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
          dh.Message = "Possible configuration issue with relative schedule fields in distribution record";             
          SaveHistoryRecord(dh,Return.RET_ERROR,e);
          continue;
        }
     
        /*============================================================
         * If we reach this point it is time to generate this report
         * but we need to see if we are ALLOWED to do so.
         *
         * Note: It is very important that these control dates be
         * kept up-to-date and accurate
         *============================================================*/                                               
        
        /*----------------------------
         * Yes, proceed
         *----------------------------*/

 /* NOTE: The third conditional (of three conditionals) check the OKToPublishUpToDate from the REPORT_PUBLICATION_CLASSES table */
        if ((RelativeDateRange1.StartDate <= Dates.StartDate (ReportDistribution.OKToPublishUpToDate)) 
         && (RelativeDateRange1.EndDate   <= Dates.EndDate   (ReportDistribution.OKToPublishUpToDate)))
        {
          dh.ResultFlags |= DistributionResultFlag.IsOKToPublish;
        }
                // TODO!  TODO!  TODO!
                // Andy says we need to make sure that the OKToPublishUpToDate does not hold-up the delivery of non-financial reports.
                // Going forward.

        /*----------------------------
         * No, skip it, setup a retry,
         * and move on to the next.
         *----------------------------*/
                 
        else
        {
          dh.ResultFlags |= DistributionResultFlag.NotOKToPublish;
          dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
          dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry;                     
          dh.Message = "The OK to publish date for this report class needs to be updated!";   
          DisplayNotice(Return.RET_WARNING, dh.Message);
          SaveHistoryRecord(dh,Return.RET_WARNING);
          continue;
        }
                         
        /*============================================================
         * Exit if app if being canceled
         *============================================================*/       

        if (cancelApp) break;
                                                
        /*============================================================
         * Generate data for the report based on the report data
         * used and the data source.
         * 
         * Note: Exceptions are handled by the methods
         *============================================================*/                       
        
        Byte[]  rf = null;
        string  fn = "";
                                          
        if (!ReportDistribution.isInternal && (ReportDistribution.ClientID == null || Util.IsNullOrEmpty(ReportDistribution.ClientName) ))
        {
            dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
            dh.ResultFlags |= DistributionResultFlag.ConfigError;
            dh.Message = "This is an internal-only report; cannot generate a report pertaining to all clients for public distribution.  No report sent to " + ReportDistribution.DistributeToEmails;
            DisplayNotice(Return.RET_WARNING, dh.Message);
            SaveHistoryRecord(dh,Return.RET_WARNING);
            continue;
        }

        /*============================================================
         * Report Data from Rpt Framework
         *============================================================*/          
                    
        if (ReportDistribution.DataSourceType == PublicationDataSourceType.Rpt) // TODO: All of our report publications have DataSourceType = 1.
                                                                                // SELECT COUNT(DISTINCT DataSourceType) FROM [dbo].[REPORT_PUBLICATION_DATA_SOURCES] -- is 1
																				// SELECT COUNT(*) FROM [dbo].[REPORT_PUBLICATION_DATA_SOURCES] WHERE DataSourceType != 1 -- is 0
        {                                                                       // I'm thinking that, since it isn't giving us any real information, we can drop that column from
          /*----------------------------                                        // [dbo].[REPORT_PUBLICATION_DATA_SOURCES], and get rid of this IF conditional.
           * Pick data source and 
           * generate report DATA                                               // TODO: Let's also drop the "Format" column from [REPORT_PUBLICATIONS], since we are now using
           *----------------------------*/                                      // the Filetype_requested column from [REPORT_PUBLICATION_SUBSCRIPTIONS].

          DataFileDistributable ReportData = null;

                    /*----------------------------
                     * Claims paid by check date
                     * 1 period
                     *----------------------------*/

                    if (ReportDistribution.DataSource == Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P)
                    {
                        ReportData = (DataFileDistributable)callMethodViewRptData(delegate
                        {
                            return Spedmon.Reports.Fianancial.rptClaimsPaidByCheckDate1P(dbConnApp, log, uInfo, ReportDistribution.ClientID.ToString(), dh.ActualDateRange1, "N", false);
                        }, true, false);
                    }

                    /*----------------------------
                     * Claims paid by svc date
                     * 1 period
                     *----------------------------*/

                    else if (ReportDistribution.DataSource == Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_1P)
                    {
                        ReportData = (DataFileDistributable)callMethodViewRptData(delegate
                        {
                            return Spedmon.Reports.Fianancial.rptClaimsPaidByServiceDate1P(dbConnApp, log, uInfo, ReportDistribution.ClientID.ToString(), dh.ActualDateRange1, "N", false);
                        }, true, false);
                    }

                    else if (ReportDistribution.DataSource == Constants.REPT_SPEDCARE_WEEKLY_RPT)
                    {
                        if (ReportDistribution.isInternal)   // SpedCare Weekly Report is for internal users only.  Hard-coded logic added here to confirm that this report is going to internal personnel only 
                            ReportData = (DataFileDistributable)callMethodViewRptData(delegate
                            {
                                return Spedmon.Clients.rptSpEdCareWeeklyReport(
                                    dbConnApp,
                                    log,
                                    uInfo,
                                    false /* not paginated */,
                                    "" /* no page number */,
                                    Convert.ToString(ReportDistribution.ClientID), // logic that allows the internal user to request either filtered-by-client or unfiltered-by-client results,
                                                                                   // via the Add New Subscription save screen on the SpedCare web site
                                    "" /* time-travel as-of date defaults to today */,
                                    "" /* useless, unused param */,
                                    "" /* do not filter by rep ID; get info for all reps */,
                                    "" /* do not filter by active status; get active and inactive clients' info */
                                );
                            }, true, false);
                        else
                        {
                            dh.ResultFlags |= DistributionResultFlag.NotOKToPublish;
                            dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
                            dh.ResultFlags |= DistributionResultFlag.ConfigError;
                            dh.Message = "This report is permissible to send only to internal users; you cannot send the SpEdCare Weekly report to " + ReportDistribution.DistributeToEmails;
                            DisplayNotice(Return.RET_WARNING, dh.Message);
                            SaveHistoryRecord(dh, Return.RET_WARNING);
                            continue;
                        }
                        // TODO: At some point, we want to place error-warning logic inside of a CATCH block, instead of an else block for every single sensitive report.
                    }

                    else if (ReportDistribution.DataSource == Constants.REPT_TATTLETALE)
                    {
                        ReportData = (DataFileDistributable) callMethodViewRptData(delegate
                        {
                            string _tattleTaleClientID = @"";
                            if (ReportDistribution.ClientID.HasValue) _tattleTaleClientID = ReportDistribution.ClientID.ToString();
                            return Spedmon.ServicesByPracRpt.viewRptPracTattle (dbConnApp,log,uInfo,false,"",_tattleTaleClientID,"","","","","");
                        }, true, false);
                    }

                    else if (ReportDistribution.DataSource == Constants.REPT_BATCHES_NEEDING_PRIORITY_REVIEW)
                    {
                        if (ReportDistribution.isInternal) // Batches Needing Priority Review report is for internal users only.  Hard-coded logic added here to confirm that this report is going to internal personnel only 
                            ReportData = (DataFileDistributable)callMethodViewRptData(delegate
              {
                /* We use internal default date range for the report*/    
              return Spedmon.InputBatchesStatus.RPT_BatchesNeedingPriorityReview(dbConnApp, log, uInfo, false, "");
              }, true, false);
                        else
                        {
                            dh.ResultFlags |= DistributionResultFlag.NotOKToPublish;
                            dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
                            dh.ResultFlags |= DistributionResultFlag.ConfigError;
                            dh.Message = "This report is permissible to send only to internal users; you cannot send the Batches Needing Priority Review report to " + ReportDistribution.DistributeToEmails;
                            DisplayNotice(Return.RET_WARNING, dh.Message);
                            SaveHistoryRecord(dh, Return.RET_WARNING);
                            continue;
                        }
                    }
                    else if (ReportDistribution.DataSource == Constants.REPT_CLAIMS_TRANSMISSION_SUMMARY)
                    {
                        if (ReportDistribution.isInternal) // Claims Transmission Summary report is for internal users only.  Hard-coded logic added here to confirm that this report is going to internal personnel only 
                            ReportData = (DataFileDistributable)callMethodViewRptData(delegate
                            {
                                /* We use internal default date range for the report*/    
                                return Spedmon.Claims.rptClaimsTransmissionSummary(dbConnApp, log, uInfo, false, "", "", "", "", "","");
                            }, true, false);
                        else
                        {
                            dh.ResultFlags |= DistributionResultFlag.NotOKToPublish;
                            dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
                            dh.ResultFlags |= DistributionResultFlag.ConfigError;
                            dh.Message = "This report is permissible to send only to internal users; you cannot send the Claims Transmission Summary Report to " + ReportDistribution.DistributeToEmails;
                            DisplayNotice(Return.RET_WARNING, dh.Message);
                            SaveHistoryRecord(dh, Return.RET_WARNING);
                            continue;
                        }

                    }

                    /*----------------------------
                     * Unknown data source
                     * Skip this report and move on
                     * to the next.
                     *----------------------------*/

                    else
                    {
                        dh.ResultFlags |= DistributionResultFlag.ConfigError;
                        dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
                        dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry;
                        dh.Message = "Possible configuration issue with data source field in distribution record";
                        SaveHistoryRecord(dh, Return.RET_ERROR);
                        continue;
                    }
                            
          /*----------------------------
           * If we have report data
           * see if there were issues
           * with generating it
           *----------------------------*/
              
          if (ReportData != null)
          {               
            /*----------------------------
             * A non successfull return
             * could mean no records or
             * something wrong with the
             * data.  Either case we
             * dont generate a report
             * file and we skip to the
             * next report.
             *----------------------------*/

             if (ReportData.status != Return.RET_SUCCESS)
             {                                    
               /*----------------------------
                * No records
                * This is OK because it means
                * there is nothing to report
                * and there is no need to retry
                * later.
                *----------------------------*/
     
               if (ReportData.message == Messages.NO_RECORDS_FOUND)
               {
                 dh.ResultFlags |= DistributionResultFlag.NoRecords;
                 dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
                 dh.Message = "The report was generated and there were no records";                                                      
                 SaveHistoryRecord(dh,Return.RET_SUCCESS);                  
               }
                  
               /*----------------------------
                * Something else is wrong
                * The query could be bad or
                * there could be issues with
                * the data.  This is not OK
                * and it is considered an 
                * error.  Setup retry.
                *----------------------------*/
                   
               else
               {
                 dh.ResultFlags |= DistributionResultFlag.DataError;
                 dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;  
                 dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry;                   
                 dh.Message = ReportData.message;                                     
                 SaveHistoryRecord(dh,Return.RET_ERROR);                  
               }
                    
               continue;
             } // No success
           }                                              
                                                                                                         
           /*============================================================
            * Exit if app if being canceled
            *============================================================*/       

           if (cancelApp) break;
           
           /*============================================================
            * Create report FILE (bytes) based on requested format
            *============================================================*/             
            
           try
           {

             /*----------------------------
              * PDF
              *----------------------------*/
              
             if (ReportDistribution.fileTypeRequested == Constants.REPT_FORMAT_PDF_REPORT)
             {                                         
                 rf = ReportData.DataToPDF();
                 fn = ReportData.GenerateFileName("pdf");
             }

             /*----------------------------
              * Excel
              *----------------------------*/

             else if (ReportDistribution.fileTypeRequested == Constants.REPT_FORMAT_XLS_REPORT)
             {                
                 rf = ReportData.DataToXLS();
                 fn = ReportData.GenerateFileName("xls");
             }
              
             /*----------------------------
              * HTML
              *----------------------------*/

             else if (ReportDistribution.fileTypeRequested == Constants.REPT_FORMAT_HTML_REPORT)
             {
                 rf = ReportData.DataToHTML();
                 fn = ReportData.GenerateFileName("html");        
             } 
             
             /*----------------------------
              * We don't know the format
              * Skip this record, setup retry,
              * and move on to the next
              *----------------------------*/
               
             else
             {
               dh.ResultFlags |= DistributionResultFlag.ConfigError;
               dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
               dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
               dh.Message = "Possible configuration issue with report format field in distribution record";    
               SaveHistoryRecord(dh,Return.RET_ERROR);
               continue;
             }              
           }
            
           /*----------------------------
            * Some other issue occurred
            * with creating the file.
            * Setup retry and move on 
            * to next.
            *----------------------------*/
            
           catch (Exception e)
           {
             dh.ResultFlags |= DistributionResultFlag.FileError;
             dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
             dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry;
             dh.Message = "There was a problem with creating a report file (bytes)";
             SaveHistoryRecord(dh,Return.RET_ERROR,e);
             continue;  
           }                
         } 
            
         /*============================================================
          * Report Data from View Framework
          *============================================================*/          

         else if (ReportDistribution.DataSourceType == PublicationDataSourceType.View)
         {
           // TODO: Implement
		   // Question... implement what?  Is that still even necessary?
		   // I'm thinking that, since we have the ability to call the method from the [entitiy].cs file,
		   // and that method knows whether it is calling a view, a UDF, or a SPROC, we don't need any special implementation here.
         }
          
         /*============================================================
          * Unknown data source type
          *============================================================*/  
            
         else
         {
           dh.ResultFlags |= DistributionResultFlag.ConfigError;
           dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
           dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
           dh.Message = "Possible configuration issue with report data source field in distribution record";    
           SaveHistoryRecord(dh,Return.RET_ERROR);
           continue;
         }
                        
         /*============================================================
          * Exit if app if being canceled
          *============================================================*/       

         if (cancelApp) break;
         
         /*============================================================
          * Create and send email
          * to distribute report based on report class
          *============================================================*/  
          
         try
         {  
            
           /*============================================================
            * Client financial reports
            * 
            * Emailed to client recepients and client reps are CCd
            *============================================================*/  

           if (ReportDistribution.PublicationClass == PublicationsClass.ClientFinancialReport
                 || ReportDistribution.PublicationClass == PublicationsClass.PartnerReport)
           {            
                         
             /*----------------------------
              * Create subject line
              * The subject line needs to
              * use the same wording as the
              * report file name.
              *----------------------------*/
            
             string subject = String.Format(ReportDistribution.DistEmailTitleTemplate,
                                                       ReportDistribution.ClientName,
                                                       ReportDistribution.PublicationDistributionDescription1,
                                                       RelativeDateRange1.ToString());

             /*----------------------------
              * Create body
              * The body uses basically the
              * same wording that was used
              * by the legacy report
              * templates
              *----------------------------*/
              
             StringBuilder sb = new StringBuilder();                                                                                 
              
             /*----------------------------
              * Header
              * Note: Debug mode only
              *----------------------------*/
              
             if (debugMode)
             {
               string pubDesc = @"<div style=""text-align:right;""><span style=""font-style:italic;font-size:.90em;color:#bbb;"">" + ReportDistribution.PublicationDescription + @"</span></div>";              
               sb.AppendLine(pubDesc);
             }
              
             /*----------------------------
              * Content
              *----------------------------*/

             string pubDesc2     =  ReportDistribution.PublicationDistributionDescription2;
             string pubDate      =  RelativeDateRange1.EndDate.ToString(ReportDistribution.PublicationDistributionDateFormat);
             string repName      =  ReportDistribution.isInternal ? "" : ReportDistribution.RepNameFirst + " " + ReportDistribution.RepNameLast;
             string repEmail     =  ReportDistribution.isInternal ? "" : @"<a href=""mailto:" + ReportDistribution.RepEmail + @""">" + ReportDistribution.RepEmail + @"</a>";
             string repPhoneNums =  ReportDistribution.isInternal ? "" : Util.removeAllNonNumeric(ReportDistribution.RepPhone);
             string repPhone     =  ReportDistribution.isInternal ? "" : @"<a href=""tel:" + repPhoneNums + @""">" + ReportDistribution.RepPhone + @"</a>";
                        /* NOTE: if I felt that I had the time, then I would want INTERNAL email notifications to have, in the footer, the signature string (first + last name, etc.)
                         *       of the person who CREATED the subscription.  So, if I logged in to spedcare and subscribed somebody to a report, then the email sent out would
                         *       say "James Miles" at the bottom.  If Terry logged in and subscribed somebody to a report, the emails would say "Terry Rohl" at the bottom; and if
                         *       Chuck logged in and subscribed somebody to a report, then the emails sent would say "Chuck Muirhead" at the bottom. 
                         
                                  That would be for INTERNAL emails only.  Outward-facing subscriptions (to a non-SBSC subscriber) would still have the client-consultant's name
                                  at the bottom of the email.  */
                                                 
             sb.AppendLine(Util.stringToHTML(String.Format(  ReportDistribution.DistEmailBodyTemplate
                                                           , pubDesc2
                                                           , pubDate
                                                           , repName
                                                           , repEmail
                                                           , repPhone)));

             /*----------------------------
              * Footer
              *----------------------------*/
              
             sb.AppendLine(@"<br/>");
              
             string contactName = @"<span style=""font-size:1.2em;font-style:oblique;"">" + Constants.APP_CONTACT.name + @"</span>";
             sb.AppendLine(Util.stringToHTML(String.Format(ReportDistribution.DistEmailFooterTemplate,
                                                                      contactName)));
                                       
          
              
             string body = sb.ToString();
                        
             /*----------------------------
              * Send email
              *----------------------------*/
               
             Email.sendMail(Constants.APP_SMTP_HOST, 
                            Constants.APP_SMTP_PORT,
                            Constants.APP_EMAIL_FROM,
                            ReportDistribution.DistributeToEmails,
                            ReportDistribution.isInternal ? "" : ReportDistribution.RepEmail,
                            "",
                            fn, //filename
                            ref rf,
                            subject,
                            body);
              
             DisplayNotice(Return.RET_SUCCESS, "email sent");
              
            }
      
           
           /*============================================================
            * Unknown report class
            *============================================================*/  
            
           else
           {
             dh.ResultFlags |= DistributionResultFlag.ConfigError;
             dh.ResultFlags |= DistributionResultFlag.NoFileDistributed;
             dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
             dh.Message = "Possible configuration issue with report class field in distribution record";
             SaveHistoryRecord(dh,Return.RET_ERROR);
             continue;
           }
         }

         /*----------------------------
          * Could not email report for
          * some reason.  Skip to next
          *----------------------------*/   

         catch (Exception e)
         {              
           dh.ResultFlags |= DistributionResultFlag.EmailError;
           dh.ResultFlags |= DistributionResultFlag.NoFileDistributed; 
           dh.ResultFlags |= DistributionResultFlag.ScheduleForRetry; 
           dh.Message = "There was an issue with either creating or sending the report email.";                        
           SaveHistoryRecord(dh,Return.RET_ERROR,e);                      
           continue;
         }
          
         /*============================================================
          * If we reach this point a report was successfully distributed
          * (assuming the email went through).  Move on to the next
          * report (if any).
          *============================================================*/  
  
         dh.ResultFlags |= DistributionResultFlag.FileDistributed;                        
         SaveHistoryRecord(dh,Return.RET_SUCCESS);      
                              
         /*============================================================
          * Exit if app if being canceled
          *============================================================*/       

         if (cancelApp) break;
                                                                                         
        } // Report subscriptions           
    } // main()    
  }
}