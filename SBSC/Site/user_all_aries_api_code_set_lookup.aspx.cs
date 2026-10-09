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
   * UserAllAriesApiCodeSetLookup */
  /**
   * 
   ***************************************************************************/
  public class UserAllAriesApiCodeSetLookup : WebUI

  {

    public UserAllAriesApiCodeSetLookup() : base(  "user-all-aries-api-code-set-lookup"
                                           , "ARIES API Code Set Lookup"
                                           , @""
                                           , @""
										   , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public const string PARM_NAME_SERVER         = Spedmon.Constants.PARM_API_URL;
    public const string PARM_NAME_API_TOKEN      = Spedmon.Constants.PARM_API_TOKEN;
    public const string PARM_NAME_TABLE_NAME     = "tablename";
	public const string PARM_NAME_FIELD_NAME     = "fieldname";
  
    public string clientID  = "";
    public string amd       = "";
    public string tkn       = "";
    public string server    = "";
    public string apiToken  = "";
    public string tableName = "";
    public string fieldName = "";
    public bool requestSuccesful = false;
    public bool hasData          = false;
    public List<Geo.ARIES.AriesCode> ariesCodes = new List<AriesCode>();
    
	protected void Page_Load(object sender, EventArgs e)
    {
      
      tkn       = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_TOKEN);
      amd       = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_APP_MODE);
      clientID  = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_CLIENT_ID);
      server    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_URL);
      apiToken  = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_API_TOKEN);
      tableName = MBA.HttpApplication.getParameter(PARM_NAME_TABLE_NAME);
      fieldName = MBA.HttpApplication.getParameter(PARM_NAME_FIELD_NAME);
      
      if (String.IsNullOrWhiteSpace(tkn)) tkn = this.rd.wu.usr.token;
      
      /* No server - get out */
            
      if (String.IsNullOrWhiteSpace(server)) return;
      
      /* No token - get out */

      if (String.IsNullOrWhiteSpace(apiToken)) return;      
    
      /* Get codes */

      ariesCodes = Geo.ARIES.Common.GetCodeSetList(server,apiToken,tableName,fieldName,out requestSuccesful,out hasData);
      
     }
  }
}
