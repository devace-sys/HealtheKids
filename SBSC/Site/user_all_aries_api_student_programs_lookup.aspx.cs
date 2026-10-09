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
   * UserAllAriesApiStudentProgramsLookup */
  /**
   * 
   ***************************************************************************/
   
  public class UserAllAriesApiStudentProgramsLookup : WebUI

  {

    public UserAllAriesApiStudentProgramsLookup() : base(  "user-all-aries-api-student-programs-lookup"
                                                          , "ARIES API Student Programs Lookup"
                                                          , @""
                                                          , @""
										                  , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER      = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN   = Spedmon.Constants.PARM_API_TOKEN;
    public const string PARM_NAME_ASID        = Geo.ARIES.Common.PARM_NAME_ARIES_STUDENT_ID;
    public const string PARM_NAME_ASCDE       = Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE;
    public const string PARM_NAME_APCDE       = Geo.ARIES.Common.PARM_NAME_ARIES_PROGRAM_CODE;

    public string clientID          = "";
    public string amd               = "";
    public string tkn               = "";
    public string server            = "";
    public string apiToken          = "";
    public string asid              = "";
    public string ascde             = "";
    public string apcde             = "";
    public bool   requestSuccesful  = false;
    
	public List<Geo.ARIES.StudentProgram> studentPrograms = null;
	
	protected void Page_Load(object sender, EventArgs e)
    {
      studentPrograms = new List<Geo.ARIES.StudentProgram>();
	  
      tkn         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);
      asid        = MBA.HttpApplication.getParameter(PARM_NAME_ASID);
      ascde       = MBA.HttpApplication.getParameter(PARM_NAME_ASCDE);     
      apcde       = MBA.HttpApplication.getParameter(PARM_NAME_APCDE);     

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
         asid = "0"; /* 0 = All students */
      }
      
      /* Student programs lookup */

      studentPrograms = Geo.ARIES.StudentPrograms.getList(server,apiToken,schoolCode,asid,apcde,out requestSuccesful);

    }     
  }
}
