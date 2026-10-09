using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Net.Mail;
using MBA;
using Spedmon;
using Spedmon.Reports;


namespace Spedmon
{
  
  /***************************************************************************
   * FileExportDistApp */
  /**
   * File export distribution application
   * Part 1/2 of this class.
   * The second part is in FileExportDistApp.cs
   ***************************************************************************/ 
  
  partial class FileExportDistApp:BatchApplication
  {

    /***************************************************************************
     * Main */
    /**
     * Our entry point for this application from the operating system.
     * 
     * RptDist 
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
              "File Export Distributions", 
              Spedmon.Constants.APP_VERSION, 
              ref args, 
              ref mainDel);        
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
    
    } // Main        
  }
}
