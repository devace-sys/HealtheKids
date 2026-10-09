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

namespace Spedmon
{
  /***************************************************************************
   * ThirdPartyDataUpdatesApp */
  /**
   * Application class
   ***************************************************************************/   

  class ThirdPartyDataUpdatesApp:BatchApplication
  {
                    
    /***************************************************************************
     * UpdateTripCalculations */
    /**
     * 
     ***************************************************************************/   

    static void UpdateTripCalculations()
    {             
       DisplayNotice (Return.RET_INFO,"Updating trip calculations");
       try { 
         var batchUpdateTripCalcs = Constants.BATCH_UPDATE_TRIP_CALCS_ENABLED;
         if (batchUpdateTripCalcs == @"1") { 
           DisplayNotice (Return.RET_INFO,"Updating all applicable trip calculations");
           Spedmon.TransportationMgmtTripCalculations.refreshAllTripCalcs(dbConnApp,log,uInfo);
         } 
         else {
           DisplayNotice (Return.RET_WARNING,"Updating all applicable trip calculations IS DISABLED");
         }
       } 
       catch (Exception e) {
          DisplayNotice (Return.RET_WARNING,"Issue with updating all applicable trip calculations : {0}",e.Message);
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
        UpdateTripCalculations();
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
              "Third Party Data Updates", 
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
