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
  
  
  class DownloadFileValue 
  {
      public string requestUrl   = @"";
      public string savePath     = @"";
      public string saveFile     = @"";    
  }

  /***************************************************************************
   * DownloadFileApp */
  /**
   * Application class
   ***************************************************************************/   

  class DownloadFilesApp:BatchApplication
  {
        
    
    public static List<String>                           fileKeys;
    public static Dictionary <String, DownloadFileValue> fileValues;
    
    /***************************************************************************
     * DownloadFile */
    /**
     * 
     ***************************************************************************/   

    static bool DownloadFile ( string fileKey )
  	{

      bool              _result      = true;
      DownloadFileValue fileValue;      
      String savePathFile            = null;

      DisplayNotice (Return.RET_INFO,"{0}", fileKey);
	    
	    try 
	    {

        if (!fileValues.ContainsKey(fileKey))
        {
          throw new Warning(@"File key not found");          
        } 
        
        fileValue = fileValues[fileKey];
	      
	      if (!Directory.Exists (fileValue.savePath)) 
	      {
	        throw new Warning(@"Path not found");
	      }

	      savePathFile = Path.Combine (fileValue.savePath,fileValue.saveFile);
		
	      DisplayNotice (Return.RET_INFO,"Downloading {0} to {1}",fileValue.requestUrl, savePathFile);

	      using (WebClient wc = new WebClient())
	      {			    
	        wc.Encoding              = System.Text.Encoding.UTF8;			  				  
		      wc.UseDefaultCredentials = false;
	        wc.CachePolicy           = new RequestCachePolicy (RequestCacheLevel.NoCacheNoStore);
		      ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback (delegate { return true; });			    			    
		      wc.DownloadFile (fileValue.requestUrl, savePathFile);
	      }
	      _result = true;
	    } 
	    catch (WebException we) 
	    {
	      DisplayNotice (Return.RET_ERROR,"{0}",we.Message);
	      _result = false;
	    }
      catch (Exception e)
      {
        DisplayNotice (Return.RET_ERROR,"{0}",e.Message);
	      _result = false;
      }
      return _result;      
	  }
	
    
    /***************************************************************************
     * DownloadFiles */
    /**
     * 
     ***************************************************************************/   

    static void DownloadFiles()
    {      
      DisplayNotice (Return.RET_INFO,"Downloading files");
      
      foreach (string fileKey in fileKeys)
      {
         DownloadFile(fileKey);     
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
  
        String fks = Constants.getAppSetting(@"fileKeys",@"");
        fileKeys   = fks.Split(',').ToList();
    
        foreach (String fileKey in fileKeys)
        {          
          DisplayNotice (Return.RET_INFO,"{0}", fileKey);
          String                     fileValueJSON = Constants.getAppSetting(fileKey,@"");
          DownloadFileValue fileValueObj  = (DownloadFileValue) JSON.fromJSONString (fileValueJSON,typeof(DownloadFileValue));
          fileValues[fileKey] = fileValueObj;
        }                        
        _result = true;
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
	    fileKeys   = new List<string>();
	    fileValues = new Dictionary <String,DownloadFileValue>();	    
      if (GetAndCheckAppSettings()) DownloadFiles();      
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
              "Download Files", 
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
