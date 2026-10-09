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
 * sbs_all_training */
/**
 * help page
 ***************************************************************************/

namespace Spedmon
{
  public class sbs_all_training : WebUI
  {
    
    public sbs_all_training(): base("training","Production Documents","","",Constants.ROLE_SBS_STAFF){}
      
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      
      //string         filter    = MBA.HttpApplication.getParameter("filter");
      
      //MediaFileLinks ctrlLinks = findControlRecu(this.Page, "links")     as MediaFileLinks;
      //Instructions   ctrlInstr = findControlRecu(this.Page, "more_help") as Instructions;
      
      //if (!Util.IsNullOrEmpty(filter))
      //{
        //ctrlLinks.pattern  = filter;
        //ctrlLinks.listType = MediaFileListType.SearchResultList;        
      //}

    }
}
}


