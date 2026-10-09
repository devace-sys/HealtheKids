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
   * UserAllAriesApiStudentStudentsLookup */
  /**
   * 
   ***************************************************************************/
   
  public class UserAllAriesApiStudentStudentsLookup : WebUI

  {

    public UserAllAriesApiStudentStudentsLookup() : base(  "user-all-aries-api-student-students-lookup"
                                                          , "ARIES API Student Lookup"
                                                          , @""
                                                          , @""
										                  , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER        = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN     = Spedmon.Constants.PARM_API_TOKEN;
    public const string PARM_NAME_ASID          = Geo.ARIES.Common.PARM_NAME_ARIES_STUDENT_ID;
    public const string PARM_NAME_ASCDE         = Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE;
    public const string PARM_NAME_REC_NUM_START = Geo.ARIES.Common.PARM_NAME_ARIES_REC_NUM_START;
    public const string PARM_NAME_REC_NUM_END   = Geo.ARIES.Common.PARM_NAME_ARIES_REC_NUM_END;

    public string clientID          = "";
    public string amd               = "";
    public string tkn               = "";
    public string server            = "";
    public string apiToken          = "";
    public string asid              = "";
    public string ascde             = "";
    public string arnsrt            = "";
    public string arnend            = "";
    public bool   requestSuccesful  = false;
    
	public string URL_STUDENT_CONTACTS_FOR_STUDENT_BASE = "";
    public string URL_STUDENT_PROGRAMS_FOR_STUDENT_BASE = "";

    public List<Geo.ARIES.Student> students = null;
	
	protected void Page_Load(object sender, EventArgs e)
    {
      students = new List<Geo.ARIES.Student>();
	  
      tkn         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);
      asid        = MBA.HttpApplication.getParameter(PARM_NAME_ASID);
      ascde       = MBA.HttpApplication.getParameter(PARM_NAME_ASCDE);     
      arnsrt      = MBA.HttpApplication.getParameter(PARM_NAME_REC_NUM_START);
      arnend      = MBA.HttpApplication.getParameter(PARM_NAME_REC_NUM_END);

      /* No token get default*/
      
      if (String.IsNullOrWhiteSpace(tkn)) tkn = this.rd.wu.usr.token;
      
      /* No server - get out */
            
      if (String.IsNullOrWhiteSpace(server)) return;
      
      /* No token - get out */

      if (String.IsNullOrWhiteSpace(apiToken)) return;      
    	  
      /* If school code is passed it needs to be an int */

      int schoolCode = 0;

      if (!String.IsNullOrWhiteSpace(ascde)) {
          if (!int.TryParse(ascde,out schoolCode)) { 
            schoolCode = 0;
          }
      }

      /* If student id is passed */

      if (!String.IsNullOrWhiteSpace(asid)) {      
      
      }
      else
      {
         
      }
      
      /* If starting record is passed it needs to be an int */

      int? startingRecord = null;

      if (!String.IsNullOrWhiteSpace(arnsrt)) {
        int recNum;
        if (int.TryParse(arnsrt,out recNum)) {
          startingRecord = recNum;
        }
      }

      /* If ending record is passed it needs to be an int */

      int? endingRecord = null;

      if (!String.IsNullOrWhiteSpace(arnend)) {
        int recNum;
        if (int.TryParse(arnend,out recNum)) {
          endingRecord = recNum;
        }
      }

      /* Students lookup */

      students = Geo.ARIES.Students.getList (server, apiToken, schoolCode, asid, startingRecord, endingRecord, out requestSuccesful);

      URL_STUDENT_CONTACTS_FOR_STUDENT_BASE  = Spedmon.ARIES.URL_STUDENT_CONTACTS_FOR_STUDENT (amd,clientID,server,apiToken,asid);
      URL_STUDENT_PROGRAMS_FOR_STUDENT_BASE  = Spedmon.ARIES.URL_STUDENT_PROGRAMS_FOR_STUDENT (amd,clientID,server,apiToken,asid);

    }     
  }
}
