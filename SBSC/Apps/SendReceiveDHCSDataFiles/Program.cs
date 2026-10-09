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


namespace Spedmon
{
  
  
  /***************************************************************************
   * SendReceiveDHCSDataFilesApp */
  /**
   * Application class
   ***************************************************************************/   
  class SendReceiveDHCSDataFilesApp:BatchApplication
  {
            
	/***************************************************************************
     * main */
    /**
     * Entry delegate
     ***************************************************************************/   
     
    static void main()
    {    	
      /* This is the entry point for your logic */
      if (hasArguments()) /* arguments are in the form n:v where n=name and v = value.. seperated by spaces*/
      { 
        foreach (var argument in arguments)
        {
          Console.WriteLine(argument.name);
          Console.WriteLine(argument.value);
        }

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
              "SendReceiveDHCSDataFiles", 
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
