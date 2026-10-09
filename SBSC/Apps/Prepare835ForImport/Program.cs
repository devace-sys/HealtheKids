using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Xml;
using System.Xml.Xsl;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;

using Spedmon;
using MBA;

namespace Spedmon
{
   
  /***************************************************************************
   * Prepare835ForImportApp */
  /**
   * Application class
   ***************************************************************************/   

  class Prepare835ForImportApp:BatchApplication
  {
               
    /***************************************************************************
     * SeperatorCount */
    /**
     * Counts number of elSep in segment and returns that number
     ***************************************************************************/   
    
    static int SeperatorCount(string segment, char elSep)
    {
       int sepCount = 0;
       foreach (char c in segment)
       {
          if (c == elSep)  
          sepCount++;
       }
       return sepCount;
    }
     
    /***************************************************************************
     * main */
    /**
     * Entry delegate
     ***************************************************************************/   
     
    static void main()
    {    	    
      if (!hasArguments()) return;
      
      NameValue fileNameIn;
      String    fileIn;
      
      if (!findArgument (@"filein", out fileNameIn)) return;
      fileIn = (String) fileNameIn.value;      
                                          
      Stream       transformStream = new FileStream   ( "Tranform835.xslt", FileMode.Open, FileAccess.Read);
      Stream       inputStream     = new FileStream   ( fileIn,             FileMode.Open, FileAccess.Read);
      StreamWriter outputFile      = new StreamWriter ( fileIn + ".csv" , false);

      byte[] inputBuffer = new byte[inputStream.Length];
      int    inputLength = (int) inputStream.Length;
      inputStream.Read(inputBuffer, 0, inputLength);

      System.Text.Encoding enc = System.Text.Encoding.ASCII;

      /* EDS returns the 835 file in a truncated format; each line is broken at position 81. 
       * The parser isn't equipped to handle this, so remove the line breaks before the parser sees them. */
      
      inputStream = new MemoryStream(enc.GetBytes(enc.GetString(inputBuffer).Replace("\r","").Replace("\n","")));
           
      X12Parser   parser      = new X12Parser();
      Interchange interchange = parser.Parse(inputStream);

      char elSep           = interchange.SegmentString[3];
      char subElSep        = interchange.SegmentString[104];
      int  blockID         = 1;
      int  elSep_PadLength = 50; /*Need to have a consistent number of delimiters for each like, else SQL bulk insert throws EOF error*/
     
      foreach (FunctionGroup fgrp in interchange.FunctionGroups)
      {                
        foreach (Transaction trns in fgrp.Transactions)
        {
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

                  if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "050")
                  {
                    DTM01 = CLMseg.SegmentString;
                  }

                  else if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "232")
                  {
                    DTM02 = CLMseg.SegmentString;
                  }

                  else if (CLMseg.SegmentId == "DTM" & CLMseg.GetElement(1) == "233")
                  {
                    DTM03 = CLMseg.SegmentString;
                  }

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

    }
        
    /***************************************************************************
     * Main */
    /**
     * Entry point
     ***************************************************************************/                             

    static void Main(string[] args)
    {
      /*============================================================
       * Enter application
       *============================================================*/  

      try
      {
                                          
        /*-------------------------------
         * Define main delegate
         *------------------------------*/
        
        GenericCallBack mainDel = delegate {main();};
                   
        /*-------------------------------
         * Start the application
         *------------------------------*/
        
        enter(Spedmon.Constants.APP_NAME, 
              "Prepare 835 For Import", 
              Spedmon.Constants.APP_VERSION, 
              ref args, 
              ref mainDel );        
      }
                    
      /*============================================================
       * Exception handler of last resort
       *============================================================*/  
       
      catch (Exception e)
      {
        /*-------------------------------
         * Let the user know and indicate
         * a fatal state in our exit state
         *------------------------------*/
        
        DisplayNotice(Return.RET_FATAL, e.Message);
        exitState = Return.RET_FATAL;
      }

      /*============================================================
       * Clean up
       *============================================================*/

      finally
      {
        cleanup();        
      }

      /*============================================================
       * Exit
       *============================================================*/
      
      exit();                
                   
    }
  }
}
