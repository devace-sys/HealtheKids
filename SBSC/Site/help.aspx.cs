using System;
using System.Data;
using System.Text;
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
* help */
/**
* help page
***************************************************************************/
namespace Spedmon
{
  public class help : WebUI
  {
    
    public help(): base("help","Help","","",Constants.ROLE_ALL_PCAL_AND_CLIENT){}
    
    public string recid;
    public string tkn                        = "";
    public string needMoreHelpContactContent = "";
    public string sectionsTOC                = "";
    public string sectionsContent            = "";
    protected void Page_Load(object sender, EventArgs e)
    {   
      
      /*###########################################################################
        # Fetch parameters
        ###########################################################################*/
            
      recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);

      if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) 
      {    
        StringBuilder sb = new StringBuilder();
        sb.Append(@"<div class=""help-box-container"">");
        sb.Append(@"<div class=""help-box help-box-info"">");
        sb.Append(@"<p>");
        sb.Append(createNeedMoreHelpContactContent(ref rd, this.dbConnUser, this.log, this.uInfo ));
        sb.Append(@"</p>");
        sb.Append(@"</div>");
        sb.Append(@"</div>");
        needMoreHelpContactContent = sb.ToString();
      }

      tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");

      var manPages = ManPages.viewContentList(dbConnUser,log,uInfo,@"Y");
      var sbSectionsTOC      = new StringBuilder();
      var sbSectionsContent  = new StringBuilder();
      sbSectionsTOC.Append(@"<ol>");        
      foreach (var manPage in manPages) {
         var sectionID = @"mp-" + manPage.id;
         sbSectionsTOC.AppendFormat(@"<li><a href=""#{0}"">{1}</a></li>",sectionID,manPage.title);        
         sbSectionsContent.AppendFormat(@"<article id=""{0}"">",sectionID);
         sbSectionsContent.Append(manPage.content);
         sbSectionsContent.Append("</article>");
         sbSectionsContent.Append(@"<hr>");
       }
       sbSectionsTOC.Append(@"</ol>");  
       sectionsTOC = sbSectionsTOC.ToString();
       sectionsContent = sbSectionsContent.ToString();
    }
  }
}


