using System;
using System.Linq;
using System.Linq.Expressions; 
using System.IO;
using System.Collections.Generic;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;
using System.Text;
using System.Text.RegularExpressions;
using MBA.X12.XDOC;
using MBA.X12.X835;

namespace MBA.X12.X835_5010
{

  public class ParseFile: X12.XDOC.ParseFile
  {    
    /// <summary>
    /// Counts number of seperators in segment.  Used by ParseFileForImportIntoSpEdCare
    /// </summary>
    /// <returns>The count.</returns>
    /// <param name="segment">Segment.</param>
    /// <param name="elSep">El sep.</param>

    private int SeperatorCount(string segment, char elSep)
    {
       int sepCount = 0;
       foreach (char c in segment)
       {
          if (c == elSep)  
          sepCount++;
       }
       return sepCount;
    }

    
    /// <summary>
    /// Parses the file for import into spEdCare.
    /// </summary>
    /// <remarks>This is the original parser code.</remarks>
    /// <param name="X12FileInWrapped">X12 file in wrapped form</param>
    /// <param name="X12FileOut">X12 file out.</param>

    public void ParseFileForImportIntoSpEdCare (string X12FileInWrapped, string X12FileOut)
    {         
                                                
      RaiseProcessingStatusEvent(@"Creating SpEdCare Import File - Starting");
      //Stream       transformStream = new FileStream   ( "Tranform835.xslt", FileMode.Open, FileAccess.Read);
      Stream       inputStream     = new FileStream   ( X12FileInWrapped, FileMode.Open, FileAccess.Read);
      StreamWriter outputFile      = new StreamWriter ( X12FileOut, false);
      System.Text.Encoding enc = System.Text.Encoding.ASCII;
           
      X12Parser   parser      = new X12Parser();
      Interchange interchange = parser.Parse (inputStream);

      char elSep           = interchange.SegmentString[3];
      char subElSep        = interchange.SegmentString[104];
      int  blockID         = 1;
      int  elSep_PadLength = 50; /*Need to have a consistent number of delimiters for each like, else SQL bulk insert throws EOF error*/
     
      foreach (FunctionGroup fgrp in interchange.FunctionGroups)
      {                
        
      	foreach (Transaction trns in fgrp.Transactions)
        {
      		
      	  RaiseProcessingStatusEvent((String.Format(@"Processing transaction set {0}",trns.ControlNumber)));

      	  string  trnsSegments   = "";
          string  clpSegment     = "";
          string  clmSegments    = "";
          string  svcSegments    = "";
          string  pad            = "";
          int     transactionID  = blockID;
          blockID               = blockID + 1;

          foreach (Segment trnSeg in trns.Segments)
          {
            //if ((trnSeg.SegmentId == "BPR") || (trnSeg.SegmentId == "TRN"))
            
            /* Provider-level adjustment segments can occur more than once */
            
            if (trnSeg.SegmentId == "PLB") 
            {
              for (int ele = 3; ele < trnSeg.ElementCount; ele += 2)
              {
                string PLBsegment = "PLB" + elSep + blockID + elSep + transactionID + elSep + trnSeg.SegmentId + elSep + trnSeg.GetElement(1) + elSep + trnSeg.GetElement(2) + elSep + trnSeg.GetElement(ele) + elSep + trnSeg.GetElement(ele + 1);
                pad = "";
                pad = pad.PadRight(elSep_PadLength - SeperatorCount(PLBsegment, elSep), elSep);

                outputFile.WriteLine(PLBsegment + pad);
                blockID++;
              }
            }
            else if (trnSeg.SegmentId != "LX") // LX is just used for sorting/hierarchical purposes. In sufficient numbers 
            {
              trnsSegments += trnSeg.SegmentString + elSep;
            }
          }
          
          string TransactionLine = "TRN" + elSep + transactionID.ToString() + elSep + elSep + trnsSegments;
          
          pad = "";
          pad = pad.PadRight(elSep_PadLength - SeperatorCount(TransactionLine, elSep), elSep);
          outputFile.WriteLine(TransactionLine+pad);
                    
          foreach (Loop LX_loop in trns.Loops) 
          {
            /*All the payers for*/
            
            if ((LX_loop.SegmentId != "LX") & (LX_loop.GetElement(1) == "PE"))
            {
                            //provSegment = LX_loop.SegmentString + elSep;
                            ////continue;
            }
            else
            {
              foreach (Loop CLP_loop in LX_loop.Loops)
              {
                int claimBlockID;
                //Console.WriteLine(CLP_loop.Specification.Name);
                clpSegment = CLP_loop.SegmentString + elSep;
                claimBlockID = blockID;
                blockID += 1;
                
                string DTM01 = "";
                string DTM02 = "";
                string DTM03 = "";
                string DTM04 = "";
                string NM74  = "";
                
                foreach (Segment CLMseg in CLP_loop.Segments)
                {
                  string NM_check = CLMseg.GetElement(1);

                  /* Date claim received */
                  if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "050")
                  {
                    DTM01 = CLMseg.SegmentString;
                  }
                  /* Claim period start */
                  else if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "232")
                  {
                    DTM02 = CLMseg.SegmentString;
                  }
                  /* Claim period end */
                  else if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "233")
                  {
                    DTM03 = CLMseg.SegmentString;
                  }
                  
                  /* Situational??  Coverage expiration?? */
                  
                  else if (CLMseg.SegmentId == "DTM")
                  {
                    DTM04 = CLMseg.SegmentString;
                  }

                  else if (CLMseg.SegmentId == "NM1" & NM_check == "QC")
                  {
                    clmSegments = CLMseg.SegmentString;
                  }

                  /* The NM1*74 is used to define corrections to a patient name */

                  else if (CLMseg.SegmentId == "NM1" & NM_check == "74") 
                  {
                    NM74 = CLMseg.SegmentString;
                  }

                  /* Either rendering provider info or other claim related info?? */
                  
                  else if (CLMseg.SegmentId == "REF")
                  {
                    string CLMBlock = CLMseg.SegmentId + elSep + blockID + elSep + claimBlockID + elSep + CLMseg.SegmentString;
                    pad = "";
                    pad = pad.PadRight(elSep_PadLength - SeperatorCount(CLMBlock, elSep), elSep);
                    outputFile.WriteLine(CLMBlock + pad);
                    blockID += 1;
                  }                                  
                } // CLP_loop.Segments

                String CLPBlock = "CLP" + elSep + claimBlockID + elSep + transactionID + elSep + clpSegment + elSep + clmSegments + elSep + DTM01 + elSep + DTM02 + elSep + DTM03 + elSep + DTM04;
                pad = "";
                pad = pad.PadRight(elSep_PadLength - SeperatorCount(CLPBlock, elSep), elSep);
                outputFile.WriteLine(CLPBlock + pad);

                if (NM74 != "")
                {
                  string NM174Block = "NM1" + elSep + blockID + elSep + claimBlockID + elSep + NM74;
                  pad = "";
                  pad = pad.PadRight(elSep_PadLength - SeperatorCount(NM174Block, elSep), elSep);
                  outputFile.WriteLine(NM174Block + pad);
                  NM74 = "";
                  NM174Block = "";
                  blockID += 1;
                }

                foreach (Loop SVCsubLoop in CLP_loop.Loops)
                {
                  int svcBlockID = blockID;
                  blockID++;
                  int subElCount = SVCsubLoop.GetElement(1).Split(subElSep).Length - 1;
                  if (subElCount < 5)
                  {
                    pad = "";
                    pad=pad.PadRight(5-subElCount, subElSep);
                    SVCsubLoop.SetElement(1,SVCsubLoop.GetElement(1) + pad);
                  }
                  string SVCBlock = "SVC" + elSep + svcBlockID + elSep + claimBlockID + elSep + SVCsubLoop.SegmentString.Replace(subElSep,elSep);
                  pad = "";
                  pad = pad.PadRight(elSep_PadLength - SeperatorCount(SVCBlock, elSep), elSep);
                  outputFile.WriteLine(SVCBlock+pad);

                  foreach (Segment SVCseg in SVCsubLoop.Segments)
                  {
                    string SVCsubBlock = SVCseg.SegmentId + elSep + blockID + elSep + svcBlockID + elSep + SVCseg.SegmentString;
                    pad = "";
                    pad = pad.PadRight(elSep_PadLength - SeperatorCount(SVCsubBlock, elSep), elSep);
                    outputFile.WriteLine(SVCsubBlock+pad);
                    blockID++;
                  }
                }
                clpSegment = "";
                clmSegments = "";
                svcSegments = "";
              }
            }
          }
        }
      }

      outputFile.Close();      
      RaiseProcessingStatusEvent(@"Creating SpEdCare Import File - Complete");
    }
   
    
    private bool IsOurClaimIDRef (string claimIDRef)
    {

      /* SpEdCare after 10/2017*/   
      
      if (Regex.Match(claimIDRef,@"^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$").Success)
        return true;

      /* SpEdCare before 10/2017 */
      
      if (Regex.Match(claimIDRef,@"^[^-]*-[^-]*-SPD$").Success)
        return true;
      
      /* HEBS */
      
      if (Regex.Match(claimIDRef,@"^[^-]*-[^-]*-[^-]*-[^-]*$").Success) 
        return true;
      
      return false;      

    }
    
    private string CreateLineOut (   long IDX
                                   , char delimiter 
                                   , params String[] args
                                  )

    {
      var sb = new StringBuilder();           
      sb.Append(IDX.ToString());
      foreach (var arg in args)
      {
       sb.Append(delimiter);
       sb.Append(arg);
      }
      return sb.ToString();
    }
    
    /// <summary>
    /// ExtractOriginalContentsToSB
    /// </summary>
    /// <param name="X12FileInWrapped"></param>
    /// <param name="FileParsingInfo"></param>
    /// <returns></returns>    
    public bool ParseFileIntoUnwrapped (  string X12FileInWrapped
                                        , string X12FileUnWrappedTxOut
                                        , ref X12FileParsingInformation FileParsingInfo )
    {
      
      bool retState = false;
      
      RaiseProcessingStatusEvent(@"Extracting original contents into flat tx file - Starting");
              
      try
      {
        
        /********************************************************************************
         * Extract data
         ********************************************************************************/

        long IDX = 1;  
        
        using (var inputFs   = new FileStream      (X12FileInWrapped, FileMode.Open, FileAccess.Read, FileShare.Read))        
        using (var inputSr   = new StreamReader    (inputFs, FileParsingInfo.FileEncoding))
        using (var outputSw  = new StreamWriter    (X12FileUnWrappedTxOut, false))
        {

       
        inputFs.Close();
      }      
      retState = true;
    }
    catch (Exception e)
    {
      retState = false;
      RaiseProcessingStatusEvent(e.Message);
    }

     finally
     {
       RaiseProcessingStatusEvent("Extracting original contents into flat tx file - Complete");
     }
                 
     return retState;
   } 
    
    /// <summary>
    /// Extract summary data
    /// </summary>
    /// <param name="X12FileInWrapped"></param>
    /// <param name="FileParsingInfo"></param>
    /// <returns></returns>
    
    public bool ExtractSummaryData (  string X12FileInWrapped
                                    , ref X12FileParsingInformation FileParsingInfo                         
                                    , out List<TransactionSetSummary> TransSetSummaryData
                                   )
    {
      
      bool retState = false;
      
      TransSetSummaryData = new List<TransactionSetSummary>();
      
      RaiseProcessingStatusEvent(@"Extracting Summary Level Data - Starting");
              
      try
      {
        
        /********************************************************************************
         * Extract data
         ********************************************************************************/

        long IDX = 1;  
        
        using (var inputFs   = new FileStream      (X12FileInWrapped, FileMode.Open, FileAccess.Read, FileShare.Read))
        using (var inputSr   = new X12StreamReader (inputFs, FileParsingInfo.FileEncoding))
        {

          var flatTransaction = inputSr.ReadNextTransaction();
        
          while (!String.IsNullOrEmpty(flatTransaction.Transactions[0].ToString()))
          {

            var parser       = new X12Parser();
            var interchanges = parser.ParseMultiple(flatTransaction.ToString());
            var interchange  = interchanges[0];
            var fg           = interchange.FunctionGroups.ElementAt(0); /* One expected */                       
            var transaction  = fg.Transactions[0];            
                                  
            /* Loops */
              
            var payeeLoop   = transaction.Loops
                                .AsParallel()
                                .FirstOrDefault(l => l.Specification.LoopId == @"1000B");
            
            /* Segments */
                          
                                
            var bprSegment  = transaction.Segments
                                .AsParallel()
                                .FirstOrDefault(s => s.SegmentId == @"BPR");
            
            var trnSegment  = transaction.Segments
                                .AsParallel()
                                .FirstOrDefault(s => s.SegmentId == @"TRN");
            
            var prodDateSegment  = transaction.Segments
                                .AsParallel()
                                .FirstOrDefault(s => s.SegmentId == @"DTM" && s.GetElement(1) == @"405");

            var plbSegments = transaction.Segments
                                .AsParallel()
                                .Where(s => s.SegmentId == @"PLB")
                                .ToList();

            


            /* Elements */

            var tsControlNumber = transaction.GetElement(2);

            var warrantDateVal  = bprSegment.GetDate8Element(16);
            var warrantAmtVal   = bprSegment.GetDecimalElement(2);
            var warrantNumber   = trnSegment.GetElement(2);


            var providerName    = payeeLoop.GetElement(2);
            var providerNPI     = payeeLoop.GetElement(4);              
  
            RaiseProcessingStatusEvent(providerName);
     
            /* Normalize and Aggregate */
            
            var plbAdjustementsList = new List<IPlbAdjustment>();
            
            foreach (var plbSegment in plbSegments)
            {
              Segment plbSeg = plbSegment;
              ProviderLevelAdjustments.ExtractFromSegmentAndAddToList( FileParsingInfo.SubElementDelimiter
                                                                                    , ref plbSeg
                                                                                    , ref plbAdjustementsList );                                                                                   
            }
            
            
            var totAmtPlbAdjustmentsVal = plbAdjustementsList
                                            .AsParallel()
                                            .Sum(a=> a.Amount);
                                                  
            var totClaimsPaidAmtAllVal  = transaction.Loops
                                            .AsParallel()
                                            .Where(l1 => l1.Specification.LoopId == @"2000")
                                            .SelectMany(l2 => l2.Loops)
                                            .Where(l3 => l3.Specification.LoopId == @"2100")
                                            .Select(l4 => l4.GetDecimalElement(4))                      
                                            .Sum(l5 => l5.HasValue ? l5.Value : 0);
                                              
            var totClaimsPaidAmtUsVal  = transaction.Loops
                                           .AsParallel()
                                           .Where(l1 => l1.Specification.LoopId == @"2000")
                                           .SelectMany(l2 => l2.Loops)
                                           .Where(l3 => l3.Specification.LoopId == @"2100" && IsOurClaimIDRef (l3.GetElement(1)) == true)
                                           .Select(l4 => l4.GetDecimalElement(4))
                                           .Sum(l5 => l5.HasValue ? l5.Value : 0);
            
            var totClaimsPaidAmtOther = totClaimsPaidAmtAllVal - totClaimsPaidAmtUsVal;
            
            TransSetSummaryData.Add(new TransactionSetSummary(  IDX
                                                              , tsControlNumber
                                                              , providerName
                                                              , providerNPI
                                                              , warrantNumber
                                                              , warrantDateVal
                                                              , warrantAmtVal
                                                              , totClaimsPaidAmtAllVal
                                                              , totClaimsPaidAmtUsVal
                                                              , totClaimsPaidAmtOther
                                                              , totAmtPlbAdjustmentsVal
                                                              , plbAdjustementsList));
                                                        
            IDX++;
                        
            flatTransaction = inputSr.ReadNextTransaction();
        } 
        
        inputFs.Close();
      }      
      retState = true;
    }
    catch (Exception e)
    {
      retState = false;
      RaiseProcessingStatusEvent(e.Message);
    }

     finally
     {
       RaiseProcessingStatusEvent("Extracting Summary Level Data - Complete");
     }
            
     return retState;
   } 
    
   
    public bool ExtractDetailData (  string X12FileInWrapped
                                   , ref X12FileParsingInformation   FileParsingInfo                                    
                                   , out List<TransactionSetDetail>  TransSetDetailData                              
                                  )
    {
      
      bool retState = false;      
      TransSetDetailData = new List<TransactionSetDetail>();
      
      RaiseProcessingStatusEvent(@"Extracting Detail Level Data - Starting");
              
      try
      {
        
        /********************************************************************************
         * Extract data
         * Unbundling Tips:
         * To unbundle 837 files into individual claims, use loop ID 2300
         * To unbundle 835 files into individual remittance EOBs, use loop ID 2100
         * If the resulting X12 file is "unreadable" by an EDI application try turning off the whitespace option (see fifth argument) 
         ********************************************************************************/

        long IDX = 1;
        
        using (var inputFs = new FileStream(X12FileInWrapped, FileMode.Open, FileAccess.Read, FileShare.Read))
        using (var inputSr = new X12StreamReader(inputFs, FileParsingInfo.FileEncoding))
        {
          var flatTransaction = inputSr.ReadNextTransaction();
        
          while (!String.IsNullOrEmpty(flatTransaction.Transactions[0].ToString()))
          {
            var parser         = new X12Parser();
            var interchangesIn = parser.ParseMultiple(flatTransaction.ToString());
            var interchangeIn  = interchangesIn[0];
            
            /* Unbudle by loop 2100 */
            
            var interchangesOut = parser.UnbundleByLoop(interchangeIn,@"2100");
           
            /* Note if segment does not repeat in a loop its elements are available at the loop level */

            foreach (var interchangeOut in interchangesOut)
            {
                            
              var fg            = interchangeOut.FunctionGroups.ElementAt(0); /* One expected */
              var transaction   = fg.Transactions[0];                         /* One expected x*/              
                                   
              /* Loops */
              
              var payeeLoop         = transaction.Loops
                                                 .FirstOrDefault(l => l.Specification.LoopId == @"1000B");
              
              var claimContLoop     = transaction.Loops
                                                 .FirstOrDefault(l => l.Specification.LoopId == @"2000");

              var claimPayLoop      = claimContLoop.Loops
                                                   .FirstOrDefault(l => l.Specification.LoopId == @"2100");
              
              var svcPayLoop        = claimPayLoop.Loops
                                                  .FirstOrDefault(l => l.Specification.LoopId == @"2110");
              
              /* Segments */
              
            
              var patientNameSeg    = claimPayLoop.Segments
                                                  .FirstOrDefault(s => s.SegmentId == @"NM1" && s.GetElement(1) == @"QC" && s.GetElement(2) == @"1");

              /* Note: Corected patient name is situational */

              var correctedPatientNameSeg = claimPayLoop.Segments
                                                  .FirstOrDefault(s => s.SegmentId == @"NM1" && s.GetElement(1) == @"74" && s.GetElement(2) == @"1");

              var stmtFrmToDateSeg  = claimPayLoop.Segments
                                                  .FirstOrDefault(s => s.SegmentId == @"DTM" && s.GetElement(1) == @"232");

              var patientCvrgExpSeg = claimPayLoop.Segments
                                                  .FirstOrDefault(s => s.SegmentId == @"DTM" && s.GetElement(1) == @"050");
              
              
              var clmCasSegments    = claimPayLoop.Segments
                                      .AsParallel()
                                      .Where(s => s.SegmentId == @"CAS")
                                      .ToList();
              
              var svcCasSegments    = svcPayLoop.Segments
                                       .AsParallel()
                                       .Where(s => s.SegmentId == @"CAS")
                                       .ToList();
              
              var svcLqSegments     = svcPayLoop.Segments
                                      .AsParallel()
                                      .Where(s => s.SegmentId == @"LQ")
                                      .ToList();
              /* Elements */
                                                     
              var providerName         = payeeLoop.GetElement(2);
              var providerNPI          = payeeLoop.GetElement(4);              
              var tsControlNumber      = transaction.GetElement(2);
              
              var LX                   = claimContLoop.GetElement(1);
              
              var claimIDRef           = claimPayLoop.GetElement(1);
              var claimStatusCode      = claimPayLoop.GetElement(2);
              
              var claimAmountSubmitted = claimPayLoop.GetDecimalElement(3);
              var claimAmountPaid      = claimPayLoop.GetDecimalElement(4);                                           
              var claimCtrlNum         = claimPayLoop.GetElement(7);
              
              
              var patientLastName      = patientNameSeg.GetElement(3);
              var patientFirstName     = patientNameSeg.GetElement(4);
              var patientBIC           = patientNameSeg.GetElement(9);       
              
              var procSubElems         = svcPayLoop.GetElement(1);
              var svcAmountSub         = svcPayLoop.GetDecimalElement(2);
              var svcAmountPaid        = svcPayLoop.GetDecimalElement(3);
              var svcUnitsPaid         = svcPayLoop.GetIntElement(5);
              
              RaiseProcessingStatusEvent(providerName + @" " + LX);

              /* Normalize and Aggregate */
            
              var clmCasAdjustmentsList = new List<ICasAdjustment>();
            
              foreach (var casSegment in clmCasSegments)
              {
                Segment casSeg = casSegment;
                CASAdjustments.ExtractClaimAdjustmentsFromSegmentAndAddToList( CasAdjustmentLevel.CLAIM
                                                                              , ref casSeg
                                                                              , ref clmCasAdjustmentsList );                                                                                   
              }
            
              var svcCasAdjustementsList = new List<ICasAdjustment>();

              foreach (var casSegment in svcCasSegments)
              {
                Segment casSeg = casSegment;
                CASAdjustments.ExtractClaimAdjustmentsFromSegmentAndAddToList( CasAdjustmentLevel.SERVICE
                                                                              , ref casSeg
                                                                              , ref svcCasAdjustementsList );                                                                                   
              }
            
              var hcRemarkCodesList = new List<HealthCareRemarkCode>();
              
              foreach(var lqSegment in svcLqSegments)
              {
                hcRemarkCodesList.Add(new HealthCareRemarkCode(lqSegment.GetElement(1),lqSegment.GetElement(2)));
              }
              
              TransSetDetailData.Add (new TransactionSetDetail (
                IDX
              , tsControlNumber
              , providerName              
              , providerNPI
              , LX
              , claimIDRef
              , claimStatusCode
              , claimAmountSubmitted
              , claimAmountPaid
              , claimCtrlNum
              , patientLastName
              , patientFirstName
              , patientBIC
              , procSubElems
              , svcAmountSub
              , svcAmountPaid
              , svcUnitsPaid
              , clmCasAdjustmentsList
              , svcCasAdjustementsList
              , hcRemarkCodesList 
             ));
                                                 
             IDX++;
              
            }
            flatTransaction = inputSr.ReadNextTransaction();
          }
          inputFs.Close();
      }
     
      
      retState = true;
    }
    catch (Exception e)
    {
      retState = false;
      RaiseProcessingStatusEvent(e.Message);
    }

     finally
     {
       RaiseProcessingStatusEvent("Extracting Detail Level Data - Complete");
     }
            
     return retState;
   } 
    
   
  
    
    
  }
}
