using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using MBA.X12.XDOC;
using MBA.X12.X835;
using MBA.X12.X835_5010;

namespace MBA.X12.ParsingWorkflow
{
  public class ParseX835_5010:ProcessFileBase
  {
    
    public ParseX835_5010()
    {

     /********************************************************************************
      * Defaults 
      ********************************************************************************/

      this.GenerateContentReportFile   = true;
      this.ContentReportIncludeDetails = false;
      this.GenerateCSVImportFile       = true;
      this.GenerateXMLImportFile       = false;            
      
     /********************************************************************************
      * Setup 
      ********************************************************************************/

      pf              = new X835_5010.ParseFile();
      FileParsingInfo = new X12FileParsingInformation();
      rf              = new X835.CreateReportFile();    
      
     /********************************************************************************
      * Wire up event bubbles 
      ********************************************************************************/

      pf.ProcessingStatusEvent              += HandleProcessingStatusEvent;
      FileParsingInfo.ProcessingStatusEvent += HandleProcessingStatusEvent; 
      rf.ProcessingStatusEvent              += HandleProcessingStatusEvent;

    }
    
    private X835_5010.ParseFile        pf;
    private X12FileParsingInformation  FileParsingInfo;
    private X835.CreateReportFile      rf;

    public bool         GenerateContentReportFile   { get; set; }
    public bool         ContentReportIncludeDetails { get; set; }
    public bool         GenerateCSVImportFile       { get; set; }
    public bool         GenerateXMLImportFile       { get; set; }    
    public string       X12FileIn                   { get; set; }
    public string       ZipFilePassword             { get; set; }     
    public string       X12FileInOriginal            {get; private set;}
    
      
    private void HandleProcessingStatusEvent (object sender, ProcessingStatusEventArgs e)
    {
     /* Bubble */
      DisplayMessage(e.Message);
    }

    private void DisplayMessage(string message)
    {
      this.RaiseProcessingStatusEvent (message);
    }
    
    
    public int RunParser()
    {
      
      try
      {             
      
        X12FileInOriginal = @"";
        
        /********************************************************************************
         * Test if file passed in
         ********************************************************************************/

        if (String.IsNullOrEmpty(X12FileIn))
        {
          DisplayMessage(@"File not provided");
          return (int) ExitCodes.NoFileNameProvided;
        }
          
        /********************************************************************************
         * Test if file passed in exists
         ********************************************************************************/

        if (!File.Exists(X12FileIn)) 
        {
          DisplayMessage(@"File does not exist");
          return (int) ExitCodes.FileDoesNotExist;        
        }

        /********************************************************************************
         * Get info about file
         ********************************************************************************/

        var fi = new FileInfo(X12FileIn);

        /********************************************************************************
         * File is a zip file
         ********************************************************************************/      

        if (fi.Extension.ToLower() == @".zip")
        {                  
          DisplayMessage(@"Zip file provided.  Attempting to extract text file.");
          try
          {
            var X12FilesIn = Utility.ExtractZipFile (X12FileIn, ZipFilePassword, fi.DirectoryName);
            if (X12FilesIn.Count != 1)
            {
              return (int) ExitCodes.EmptyZip;              
            }
            X12FileInOriginal = X12FilesIn[0];
          }
          catch(Exception e)
          {
            DisplayMessage(e.Message);            
            return (int) ExitCodes.UnzipFailed;
          }
        }  
 
        /********************************************************************************
         * File is a text file
         ********************************************************************************/      

        else
        {          
          DisplayMessage(@"Text file provided");
          X12FileInOriginal = X12FileIn;
        }
        
        /********************************************************************************
         * Create file names
         ********************************************************************************/

        string X12FileInWrapped       = MBA.X12.Utility.CreateOutputFileName(X12FileInOriginal,  @"wrapped",   @"x12");
        string XLSXFileOutForReview   = MBA.X12.Utility.CreateOutputFileName(X12FileInOriginal,  @"contents",  @"xlsx");
        string CSVFileOutForImport    = MBA.X12.Utility.CreateOutputFileName(X12FileInOriginal,  @"csv");
        string XMLFileOutForImport    = MBA.X12.Utility.CreateOutputFileName(X12FileInOriginal,  @"import",   @"xml");                
  
        /********************************************************************************
         * Unwrap original X12 file
         ********************************************************************************/

        if (!pf.WrapUnwrappedX12File (X12FileInOriginal, X12FileInWrapped))      
          return (int) ExitCodes.WrapFileFailed;
      
        /********************************************************************************
         * Get parsing information from file in
         ********************************************************************************/
               
        if (!FileParsingInfo.LoadParsingInformationFromFile (X12FileInWrapped)) 
          return (int) ExitCodes.GettingParsingInfoFailed;

        /********************************************************************************
         * If requested create import file for SpEdCare -- Original Flat "CSV" Version
         * Note: This code has been modified as little as possible, hence the need to
         * wrap it in a try/catch
         ********************************************************************************/
        
        if (GenerateCSVImportFile)
        {
          try
          {
            pf.ParseFileForImportIntoSpEdCare (X12FileInWrapped, CSVFileOutForImport);
          }
          catch (Exception e)
          {          
            DisplayMessage(e.Message);
            return (int) ExitCodes.GeneratingCSVImportFailed;
          }
        }
        
        /********************************************************************************
         * If requested generate content report 
         ********************************************************************************/
  
        if (GenerateContentReportFile)
        {
          /* Summary data */
          
          var summaryData = new List<TransactionSetSummary>();
          if (!pf.ExtractSummaryData (X12FileInWrapped, ref FileParsingInfo, out summaryData))
                return (int) ExitCodes.ExtractingSummaryDataFailed;        
               
          /* Detail data (if requested) */
                              
          var detailData = new List<TransactionSetDetail>();
          if (ContentReportIncludeDetails)           
            if (!pf.ExtractDetailData(X12FileInWrapped, ref FileParsingInfo, out detailData))
              return (int) ExitCodes.ExtractingDetailDataFailed;
        
          /* Generate excel file */
          
          if (!rf.ParsedFileTransactionSetToExcel(ref summaryData, ref detailData, ContentReportIncludeDetails, XLSXFileOutForReview))
            return (int) ExitCodes.Generating835ContentReportFailed;        
        }
        
        /********************************************************************************
         * If requested, create XML version of entire 835 file import  
         ********************************************************************************/
        
        if (GenerateXMLImportFile)
        {
          if (!pf.ConvertX12TransactionSetsToToXML(X12FileInWrapped, ref FileParsingInfo, XMLFileOutForImport))
            return (int) ExitCodes.GeneratingXMLImportFailed;
        }      
      }

      /********************************************************************************
       * Unexpected error 
       ********************************************************************************/
        
      catch (Exception e)
      {
        DisplayMessage(e.Message);
        return (int) ExitCodes.UnknownError;
      }

      /********************************************************************************
       * Clean up and get ready to exit 
       ********************************************************************************/

      finally
      {        
        DisplayMessage(@"Parsing complete");        
      }

      return (int) ExitCodes.Success;      
    }
  }
}
