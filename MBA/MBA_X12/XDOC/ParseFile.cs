using System;
using System.Text;
using System.Xml;
﻿using System.Linq;
using System.Xml.Linq;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;


namespace MBA.X12.XDOC
{
    
  public class ParseFile: ProcessFileBase
  {
    
    /// <summary>
    /// Reads all lines in <paramref name="X12FileIn"/> and saves a copy of the
    /// lines in <paramref name="X12FileOut"/> without CR/LF.  
    /// </summary>
    /// <param name="X12FileIn">Unwrapped X12 file.</param>
    /// <param name="X12FileOut">Wrapped x12 file.</param>

    public bool WrapUnwrappedX12File (string X12FileIn, string X12FileOut)
    {
      const int BUFFER_SIZE = 4096;
      bool retState = false;      
      RaiseProcessingStatusEvent(@"Wrapping X12 File - Started");
      try
      {
        if (String.IsNullOrEmpty(X12FileIn))   throw new ArgumentException     (@"X12FileIn file path and name required.");
        if (String.IsNullOrEmpty(X12FileOut))  throw new ArgumentException     (@"X12FileIn file path and name required.");
        if (!System.IO.File.Exists(X12FileIn)) throw new FileNotFoundException (@"X12FileIn does not exist");
        if (X12FileIn == X12FileOut)           throw new Exception             (@"X12File and X12FileOut cannot be same file");
      
        using (var inputFs  = new FileStream   (X12FileIn,  FileMode.Open,   FileAccess.Read,  FileShare.None))
        using (var outputFs = new FileStream   (X12FileOut, FileMode.Create, FileAccess.Write, FileShare.None))
        using (var inputSr  = new StreamReader (inputFs))
        using (var outputSw = new StreamWriter (outputFs))
        {       
          
          try
          {
            while (!inputSr.EndOfStream)
            {
              var bufferIn = new char[BUFFER_SIZE];
              inputSr.ReadBlock(bufferIn, 0, BUFFER_SIZE);
              var stringOut = new String(bufferIn).Replace("\r", "").Replace("\n", "").Trim();
              outputSw.Write(stringOut);
            }
            retState = true;
          }
          catch (Exception e)
          {
            retState = false;
            throw (e);
          }
          finally
          {
            outputSw.Close();
            inputSr.Close();
            outputFs.Close();
            inputFs.Close();
          }
        }
      }
      catch (Exception e)
      {
        retState = false;
        RaiseProcessingStatusEvent(e.Message);        
      }
      RaiseProcessingStatusEvent(@"Wrapping X12 File - Complete");        
      return retState;
    }
      
    /// <summary>
    /// Reads all lines in <paramref name="X12FileIn"/> and saves a copy of the
    /// lines in <paramref name="X12FileOut"/> with segmentTerminator replaced with segmentTerminator + Environment.Newline
    /// </summary>
    /// <param name="X12FileIn">Unwrapped X12 file.</param>
    /// <param name="segmentTerminator">X12 segment terminator.... usually ~</param>
    /// <param name="X12FileOut">Wrapped x12 file.</param>

    public bool UnwrapWrappedX12File (string X12FileIn, char segmentTerminator, string X12FileOut)
    {
      const int BUFFER_SIZE = 4096;
      bool retState = false;      
      RaiseProcessingStatusEvent(@"Unwrapping X12 File - Started");
      try
      {
        string segTerm = segmentTerminator.ToString();
        if (String.IsNullOrEmpty(X12FileIn))         throw new ArgumentException     (@"X12FileIn file path and name required.");
        if (String.IsNullOrEmpty(segTerm))           throw new ArgumentException     (@"Segment terminator required");
        if (String.IsNullOrEmpty(X12FileOut))        throw new ArgumentException     (@"X12FileIn file path and name required.");
        if (!System.IO.File.Exists(X12FileIn))       throw new FileNotFoundException (@"X12FileIn does not exist");
        if (X12FileIn == X12FileOut)                 throw new Exception             (@"X12File and X12FileOut cannot be same file");
      
        string segmentTerminatorCrLf = segTerm + Environment.NewLine;

        using (var inputFs  = new FileStream   (X12FileIn,  FileMode.Open,   FileAccess.Read,  FileShare.None))
        using (var outputFs = new FileStream   (X12FileOut, FileMode.Create, FileAccess.Write, FileShare.None))
        using (var inputSr  = new StreamReader (inputFs))
        using (var outputSw = new StreamWriter (outputFs))
        {       
          
          try
          {
            while (!inputSr.EndOfStream)
            {
              var bufferIn = new char[BUFFER_SIZE];
              inputSr.ReadBlock(bufferIn, 0, BUFFER_SIZE);
              var stringOut = new String(bufferIn).Replace(segTerm,segmentTerminatorCrLf);
              outputSw.Write(stringOut);
            }
            retState = true;
          }
          catch (Exception e)
          {
            retState = false;
            throw (e);
          }
          finally
          {
            outputSw.Close();
            inputSr.Close();
            outputFs.Close();
            inputFs.Close();
          }
        }
      }
      catch (Exception e)
      {
        retState = false;
        RaiseProcessingStatusEvent(e.Message);        
      }
      RaiseProcessingStatusEvent(@"Unwrapping X12 File - Complete");        
      return retState;
    }

    /// <summary>
		/// Extracts and parses transaction sets from <paramref name="X12FileInWrapped"/> into 
		/// <paramref name="XMLFileOut"/>.  Applies X12 parsing rules based on function group.
		/// </summary>
		/// <remarks>
		/// This method was created to convert LARGE X12 files into XML in an resource efficient and timely
		/// manner as the Parser class in OopFactory.X12.Parsing struggles with converting LARGE X12 files into
		/// XML.
		/// </remarks>
		/// <param name="X12FileInWrapped">X12 file in.</param>
		/// <param name="FileParsingInfo">Parsing information for file in</param>
		/// <param name="XMLFileOut">XML file out.</param>

		public bool ConvertX12TransactionSetsToToXML (  string X12FileInWrapped 
		                                              , ref X12FileParsingInformation FileParsingInfo		                                            
		                                              , string XMLFileOut)
		{

		  bool retState = false;
		  var TransactionFileGroups = new List<TransactionFileGroup>();     
			RaiseProcessingStatusEvent(@"Converting X12 Transaction Sets to XML - Starting");
		  try
			{
   
				/********************************************************************************
				 * Allocate temp files for conversion from X12 to XML
				 ********************************************************************************/
				
        RaiseProcessingStatusEvent(@"Allocating temp files");
				for (var idx = 1; idx <= FileParsingInfo.SegmentCountST; idx++)
					TransactionFileGroups.Add(new TransactionFileGroup(idx));

				/********************************************************************************
				 * Divide wrapped X12 file by transaction set into seperate X12 files
				 * We use the X12StreamReader from the OopFactory library to do this.
				 ********************************************************************************/
        
				RaiseProcessingStatusEvent(@"Dividing X12 file by transaction set into seperate X12 files");
				using (var inputFs = new FileStream(X12FileInWrapped
												  , FileMode.Open
												  , FileAccess.Read
												  , FileShare.None))

				using (var inputSr = new X12StreamReader(inputFs
														  , FileParsingInfo.FileEncoding))
				{
					int idx = 0;
					var TransactionSet = inputSr.ReadNextTransaction();
					while (!String.IsNullOrEmpty(TransactionSet.Transactions.First()))
					{
						var msg = String.Format(@"Getting transaction set {0} of {1}", (idx + 1), TransactionFileGroups.Count());
				    RaiseProcessingStatusEvent(msg);
						using (var outputFs = new FileStream(TransactionFileGroups[idx].FileNameX12
															  , FileMode.Create
															  , FileAccess.Write
															  , FileShare.None))

						using (var outputSw = new StreamWriter(outputFs))
						{
							outputSw.Write(TransactionSet.ToString());
							outputSw.Close();
							outputFs.Close();
						}
						TransactionSet = inputSr.ReadNextTransaction();
						idx++;
					}
					inputFs.Close();
				}

				/********************************************************************************
				 * Parse seperate X12 files into seperate (but complete) XML files.
				 ********************************************************************************/

				RaiseProcessingStatusEvent(@"Parsing seperate X12 files into XML files");
				System.Threading.Tasks.Parallel.ForEach(TransactionFileGroups, txfg =>
			  {
				  using (var inputFs = new FileStream(txfg.FileNameX12
												   , FileMode.Open
												   , FileAccess.Read
												   , FileShare.None))

				  using (var outputFs = new FileStream(txfg.FileNameXML
														  , FileMode.Create
														  , FileAccess.Write
														  , FileShare.None))
				  {
					  var msg = String.Format(@"Parsing X12 transaction set {0} into seperate XML file", txfg.Idx);
            RaiseProcessingStatusEvent(msg);
					  var parser = new X12Parser();
					  parser.ParseMultiple(inputFs)[0].Serialize(outputFs);
					  inputFs.Close();
					  outputFs.Close();
					  msg = String.Format(@"Parsing X12 {0} is complete", txfg.Idx);
					  RaiseProcessingStatusEvent(msg);
				  }
			  });

				/********************************************************************************
  			 * Extract transaction elements only from seperate XML files into seperate text files.
	  		 ********************************************************************************/
        
	  		RaiseProcessingStatusEvent(@"Extracting transaction elements only from seperate XML into text files");
				System.Threading.Tasks.Parallel.ForEach(TransactionFileGroups, txfg =>
			  {
				  using (var inputFs = new FileStream(txfg.FileNameXML
																		 , FileMode.Open
																		 , FileAccess.Read
																		 , FileShare.None))

				  using (var outputFs = new FileStream(txfg.FileNameXMLTransOnlyTXT
																		  , FileMode.Create
																		  , FileAccess.Write
																		  , FileShare.None))
				  {
					  var msg = String.Format(@"Parsing XML transaction set {0} into seperate text file", txfg.Idx);
					  RaiseProcessingStatusEvent(msg);
					  var xws = new XmlWriterSettings();
					  xws.OmitXmlDeclaration = true;  /* Get rid of xml doctype line */
					  xws.Indent = false; /* Cut down on whitespace */
					  using (var sw = XmlWriter.Create(outputFs, xws))
					  {
						  var xdoc = XDocument.Load(inputFs);
						  /* Get rid of comment nodes */
						  xdoc.DescendantNodes().Where(x => x.NodeType == XmlNodeType.Comment).Remove();
						  /* Skip down past Interchange Header, Function Group Header */
						  XElement txe = xdoc.Descendants(@"Transaction").First();
						  txe.Save(sw);
						  sw.Close();
					  }
					  outputFs.Close();
					  inputFs.Close();
					  msg = String.Format(@"Parsing XML {0} is complete", txfg.Idx);
					  RaiseProcessingStatusEvent(msg);
				  }
			  });

				/********************************************************************************
				 * Create new XML document from seperate text files. 
				 ********************************************************************************/		
				
        RaiseProcessingStatusEvent(@"Creating new combined XML document containing just transaction sets from text files");
				using (var outputFs = new FileStream(XMLFileOut
																		   , FileMode.Create
																		   , FileAccess.Write
																		   , FileShare.None))
				using (var outputSw = new StreamWriter(outputFs))
				{
					outputSw.Write(@"<?xml version=""1.0""?>");
					outputSw.Write(@"<Transactions>");
					foreach (var txfg in TransactionFileGroups)
					{
						var msg = String.Format(@"Combining txt file {0} of {1}", txfg.Idx, TransactionFileGroups.Count());
		        RaiseProcessingStatusEvent(msg);
						using (var inputFs = new FileStream(txfg.FileNameXMLTransOnlyTXT
																				  , FileMode.Open
																				  , FileAccess.Read
																				  , FileShare.None))
						using (var inputSr = new StreamReader(inputFs))
						{
							outputSw.Write(inputSr.ReadToEnd());
							inputSr.Close();
							inputFs.Close();
						}
					}
					outputSw.Write(@"</Transactions>");
					outputSw.Close();
					outputFs.Close();
				}
			  retState = true;
		  }		  		  		            
			catch (Exception e)			
      {
			  retState = false;
			  RaiseProcessingStatusEvent(e.Message);
			}

			/********************************************************************************
			 * Clean up and done
			 ********************************************************************************/

			finally
			{
				RaiseProcessingStatusEvent(@"Cleaning up");
			  foreach (var tfg in TransactionFileGroups) tfg.Delete();
			  RaiseProcessingStatusEvent(@"Converting X12 Transaction Sets to XML - Complete");
			}
			
			return retState;
	  }
	
  }
}
