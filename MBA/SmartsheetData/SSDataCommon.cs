using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Smartsheet.Api;
using Smartsheet.Api.Models;
using Smartsheet.Api.OAuth;
using System.Web;
using MBA;

namespace SmartsheetData
{
  public class SSDataCommon
  {
    
    /***************************************************************************
     * API_KEY_?*/
    /**
     * Various Smartsheet API keys
     ***************************************************************************/  

    public static string API_KEY_ADMIN_STAFF      = "1w3llo9t7fj7gxz44f78dl15hz";
    public static string API_KEY_BACKUP_APP       = "5qgayfywpi0nrxiqz3ivxds0ts";
    public static string API_KEY_PRODUCTION_STAFF = "63tj9l2y9j63a265tqtai8pugk";    
    public static string API_KEY_DEFAULT          = API_KEY_PRODUCTION_STAFF;
    
    /***************************************************************************
     * PARM_SS_DATA_? */
    /**
     * Parameters
     ***************************************************************************/  

    public static string PARM_SS_DATA_CLASS       = "sscls";
    public static string PARM_SS_DATA_UID         = "ssuid";
    
    /***************************************************************************
     * VALUE_SS_DATA_CLASS_? */
    /**
     * Parameters
     ***************************************************************************/  

    public static string VALUE_SS_DATA_CLASS_SHEET  = "s";
    public static string VALUE_SS_DATA_CLASS_REPORT = "r";
    
    /***************************************************************************
     * GetToken */
    /**
     * Returns a Smartsheets Token object using our default API key
     ***************************************************************************/  

    public static Token GetToken()
    {
      return GetToken(API_KEY_DEFAULT);
    }
    
    /***************************************************************************
     * GetToken */
    /**
     * Returns a Smartsheets Token object using the API key string provided
     ***************************************************************************/  

    public static Token GetToken(string apikey)
    {	
      Token t = new Token();
      t.AccessToken = apikey;
      return t;
    }
		
		/***************************************************************************
     * Connect */
    /**
     * Connects to smartsheets using the token generated from default API key
     * and returns a SmartsheetClient object.
     ***************************************************************************/  

		public static SmartsheetClient Connect()
		{
		  return Connect(GetToken());
		}
		
		/***************************************************************************
     * Connect */
    /**
     * Connects to smartsheets using a Smartsheets Token object
     * and returns a SmartsheetClient object.
     ***************************************************************************/  
    
		public static SmartsheetClient Connect(Token accessToken)
		{
		  
		  SmartsheetClient c = new SmartsheetBuilder().SetAccessToken(accessToken.AccessToken).Build();
		  return c;
		}
		
		
  }
}
