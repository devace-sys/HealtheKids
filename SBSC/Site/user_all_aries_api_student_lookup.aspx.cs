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
   * UserAllAriesApiStudentLookup */
  /**
   * 
   ***************************************************************************/
   
  public class UserAllAriesApiStudentLookup : WebUI

  {

    public UserAllAriesApiStudentLookup() : base(  "user-all-aries-api-student-lookup"
                                           , "ARIES API Student Lookup"
                                           , @""
                                           , @""
										   , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER      = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN   = Spedmon.Constants.PARM_API_TOKEN;
    public const string PARM_NAME_ASCDE       = Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE;

    public string clientID    = "";
    public string amd         = "";
    public string tkn         = "";
    public string server      = "";
    public string apiToken    = "";
    public string ascde       = "";
    public bool   exportFileGenerated   = false;
    public string exportFileStatusMsg   = "";        

    public StringBuilder sbExportFileContents                   = null;
    public string exportFileContents                            = "";    

	public List<Geo.ARIES.SchoolAndStudents> schoolsAndStudents = null;
	
	protected void Page_Load(object sender, EventArgs e)
    {
      schoolsAndStudents = new List<Geo.ARIES.SchoolAndStudents>();
	  
      tkn         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd         = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);      
      ascde       = MBA.HttpApplication.getParameter(PARM_NAME_ASCDE);     
            
      /* No token get default*/
      
      if (String.IsNullOrWhiteSpace(tkn)) tkn = this.rd.wu.usr.token;
      
      /* No server - get out */
            
      if (String.IsNullOrWhiteSpace(server)) return;
      
      /* No token - get out */

      if (String.IsNullOrWhiteSpace(apiToken)) return;      
    	          
      /* No school code get out */

      if (String.IsNullOrWhiteSpace(ascde)) return;

      /* Get list by school code */
        
      schoolsAndStudents  = Geo.ARIES.SchoolsAndStudents.getList(server,apiToken,ascde);
              
      /* Using schools and students generate export file content */

      exportFileGenerated = Spedmon.ARIES.generateExportFileContent(ref schoolsAndStudents, out exportFileStatusMsg ,out sbExportFileContents);
      
      /* If the file content was generated */
      
      if (exportFileGenerated) {
        
          /* Get contents as string and replace line endings with JS friendly line endings. 
           * also strip out quotes.
           * We will parse this further on the front end. */

          exportFileContents = sbExportFileContents.ToString().Replace("\r\n", "\\n").Replace("\n", "\\n").Replace("'","").Replace("\"","");
      }
           
    }
  }
}
