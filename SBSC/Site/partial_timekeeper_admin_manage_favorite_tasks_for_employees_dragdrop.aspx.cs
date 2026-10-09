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

namespace Spedmon
{
  /***************************************************************************
   * TimekeeperAdminManageFavoriteTasksForEmployeesDragdrop */
  /**
   *
   ***************************************************************************/   

  public class PartialTimekeeperAdminManageFavoriteTasksForEmployeesDragdrop: WebUI
  {
    public string tkn      = "";
    
    public PartialTimekeeperAdminManageFavoriteTasksForEmployeesDragdrop() : base(  "",
                                                   "",
                                                   "user_all_timekeeper_panel.css",
                                                   "favorite-tasks-employees.js",
                                                   Constants.ROLE_ADMIN_WORKLEADER_ONLY)
        {
        renderOptionContentOnly = true;
    }
        
    protected void Page_Load(object sender, EventArgs e)
    {           
      tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");   
    }
  
  }
}
