using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Net;
using System.Net.Security;
using System.Net.Cache;
using Spedmon;
using MBA;
using Geo;
using System.Threading;
using System.Threading.Tasks;

namespace Spedmon
{
  /***************************************************************************
   * AriesUpdatesApp */
  /**
   * Application class
   ***************************************************************************/   

  class AriesUpdatesApp:BatchApplication
  {
                    
    
    /***************************************************************************
     * GenerateAriesExport */
    /**
     * 
     ***************************************************************************/   
   
    static void GenerateAriesExport (ClientStudentInformationSystem ariesServer, string filePath)
    {            
      try { 
        DisplayNotice (Return.RET_INFO,"Fetching student data from ARIES for {0}",ariesServer.clientName);

        var schoolsAndStudents = Spedmon.ARIES.viewSchoolsAndStudents(ariesServer,true);
      
        if (schoolsAndStudents.Count != 0) { 

          DisplayNotice (Return.RET_INFO,"Student data was retrieved from ARIES for {0}",ariesServer.clientName);

          DisplayNotice (Return.RET_INFO,"Attempting to generate export file content from ARIES data for {0}",ariesServer.clientName);

          string statusMsg = @"";
          var sb = new StringBuilder(); 
          bool retStatus = true;

          retStatus = Spedmon.ARIES.generateExportFileContent(ref schoolsAndStudents,out statusMsg, out sb);

          if (retStatus == true) {
            DisplayNotice (Return.RET_INFO,"Export file content has been generated from ARIES data for {0}",ariesServer.clientName);
            try { 
              string fileName = String.Format( @"{0}-tpop-{1}"
                                              ,ariesServer.clientName.Replace(" ","")
                                              ,DateTime.Now.ToHTML5DateString());
          
              string filePathAndName = MBA.CSV.generateFileName(filePath,fileName);
              DisplayNotice (Return.RET_INFO,"Attempting to generate file {0}",filePathAndName);            
              System.IO.File.WriteAllText(filePathAndName,sb.ToString());
            }
            catch (Exception e) {
              DisplayNotice (Return.RET_WARNING,"An error occurred when attempting to generate file : {0}",e.Message);
            }
          } 
          else {
            DisplayNotice (Return.RET_WARNING,"A problem occured in generating export file content {0}",statusMsg);
          }
        } 
        else {
          DisplayNotice (Return.RET_WARNING,"NO student data was retrieved from ARIES for {0}",ariesServer.clientName);
        }
      }
      catch (Exception e) {
        DisplayNotice (Return.RET_WARNING,"Issue with retrieving data from ARIES : {0}",e.Message);
      }
    }

    /***************************************************************************
     * GenerateAriesExports */
    /**
     * Note: Concurrent (multi threaded)
     ***************************************************************************/   

    static void GenerateAriesExports()
    {      
      DisplayNotice (Return.RET_INFO,"ARIES exports");
      try { 

        var batchUpdateAries = Constants.BATCH_UPDATE_ARIES_EXPORTS_ENABLED;
            
        if (batchUpdateAries == @"1") { 
          var filePath = Constants.ARIES_EXPORTS_FILE_PATH;
          var ariesServers = Spedmon.ARIES.viewClients( dbConnApp, log, uInfo, "", "Y");          

          DisplayNotice (Return.RET_INFO,"ARIES export files will be placed in : {0}",filePath);
          DisplayNotice (Return.RET_INFO,"Number of expected export files : {0}",ariesServers.Count.ToString());          

          /* Note: MaxDegreeOfParallelism is set to 6 to limit cpu, network, and memory usage */

          Parallel.ForEach ( ariesServers, new ParallelOptions { MaxDegreeOfParallelism = 6 }, ariesServer => {     
            GenerateAriesExport (ariesServer, filePath);                    
          });

        }
        else {
          DisplayNotice (Return.RET_WARNING,"Fetching student data from ARIES is DISABLED");
        }
      }
      catch (Exception e) {
        DisplayNotice (Return.RET_WARNING,"Issue with generating ARIES exports : {0}",e.Message);
      }
    }
    
    /***************************************************************************
     * GetAndCheckAppSettings */
    /**
     * 
     ***************************************************************************/   

    static bool GetAndCheckAppSettings ()
    {
      
      bool _result = true;
      
      try
      {  
        DisplayNotice (Return.RET_INFO,"Getting application settings");
      }
      catch (Exception e)
      {
         DisplayNotice (Return.RET_ERROR,"{0}",e.Message);
        _result = false;        
      }
                  
      return _result;
      
    }

	/***************************************************************************
     * main */
    /**
     * Entry delegate
     ***************************************************************************/   
     
    static void main()
    {    	    
      if (GetAndCheckAppSettings())
      { 
        GenerateAriesExports();      
        
      }      
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
              "ARIES Updates", 
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
