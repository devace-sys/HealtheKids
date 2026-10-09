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

/***************************************************************************
 * SystemAdminViewCurrentLogins */
/**
 * Display list of current logins
 ***************************************************************************/

namespace Spedmon
{
  public class SystemAdminViewCurrentLogins : WebUI
  {
    public    string  recsHTML  { get { return _recsHtml; } }
    protected string  _recsHtml = @"";
 
    public SystemAdminViewCurrentLogins() : base("systemadmin","System Admin - View Current Logins","","",Constants.ROLE_ADMIN){}
    protected void Page_Load(object sender, EventArgs e)
    {               
      string sql = @"select Client,UserName,RoleName,LoggedOn,SessionLastAccess,LastAccessMinutesAgo,UserIP,UserAgent from dbo.CURRENT_LOGINS_VIEW() ";
      ReturnDB rd = Database.execQuery(dbConnUser,log,sql);
      ReturnInfoTable rit = Database.convertReturnDBToReturnInfoTable(ref rd);      
     _recsHtml = ReturnInfoTable.ToHTMLTableString(ref rit);    
    }
  }
}
