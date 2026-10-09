using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;
using System.Text;
using System.Collections.Generic;
using Geo.ARIES;

namespace Spedmon
{
  
  /***************************************************************************
   * UserAllAriesApiSiteLookup */
  /**
   * 
   ***************************************************************************/
   
  public class UserAllAriesApiSiteLookup : WebUI

  {

    public UserAllAriesApiSiteLookup() : base(  "user-all-aries-api-site-lookup"
                                           , "ARIES API Site Lookup"
                                           , @""
                                           , @""
										   , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER     = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN  = Spedmon.Constants.PARM_API_TOKEN;
    	
    public string clientID  = "";
    public string amd       = "";
    public string tkn       = "";
    public string server    = "";
    public string apiToken  = "";
    public bool   requestSuccesful = false;
    
    public string URL_STUDENT_PROFILES_AT_SCHOOL_PREVIEW_BASE = "";
    public string URL_STUDENT_STUDENTS_AT_SCHOOL      = "";
    public string URL_STUDENT_CONTACTS_AT_SCHOOL_BASE = "";
    public string URL_STUDENT_PROGRAMS_AT_SCHOOL_BASE = "";

	public List<Geo.ARIES.School> schools = null;

	protected void Page_Load(object sender, EventArgs e)
    {
      
      tkn       = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd       = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID  = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken  = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);
      
      schools = new List<Geo.ARIES.School>();
	  
      if (String.IsNullOrWhiteSpace(tkn)) tkn = this.rd.wu.usr.token;
      
      /* No server - get out */
            
      if (String.IsNullOrWhiteSpace(server)) return;
      
      /* No token - get out */

      if (String.IsNullOrWhiteSpace(apiToken)) return;      
    
	  /* Get schools */
	  
      requestSuccesful = false;
      schools = Geo.ARIES.Schools.getList(server,apiToken,out requestSuccesful);
      
      URL_STUDENT_STUDENTS_AT_SCHOOL               = Spedmon.ARIES.URL_STUDENT_STUDENTS_AT_SCHOOL(amd,clientID,server,apiToken,"");
      URL_STUDENT_CONTACTS_AT_SCHOOL_BASE          = Spedmon.ARIES.URL_STUDENT_CONTACTS_AT_SCHOOL(amd,clientID,server,apiToken,"");
      URL_STUDENT_PROGRAMS_AT_SCHOOL_BASE          = Spedmon.ARIES.URL_STUDENT_PROGRAMS_AT_SCHOOL(amd,clientID,server,apiToken,"");
      URL_STUDENT_PROFILES_AT_SCHOOL_PREVIEW_BASE  = Spedmon.ARIES.URL_STUDENT_PROFILES_LOOKUP(amd,clientID,server,apiToken,"");

     }
  }
}
