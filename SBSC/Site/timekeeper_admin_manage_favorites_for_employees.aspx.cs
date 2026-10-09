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
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Spedmon
{

  public class TimekeeperAdminManageFavoritesForEmployees: WebUI
  {
    public string tkn      = "";
    public MBA.ReturnDB r_db_1;
    
    public TimekeeperAdminManageFavoritesForEmployees() : base(  "",
                                                   "",
                                                   "user_all_timekeeper_panel.css",
                                                   "favorite-tasks-employees.js",
                                                   Constants.ROLE_ADMIN_WORKLEADER_ONLY){
        //renderOptionContentOnly = true;
    }
        
    protected void Page_Load(object sender, EventArgs e)
    {           

         MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
         {
             pageroworder = "id";
        };

        r_db_1 = TimekeeperEmployees.view(this.dbConnApp, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", dc);


        tkn               = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");   
    }
  
  }
}
