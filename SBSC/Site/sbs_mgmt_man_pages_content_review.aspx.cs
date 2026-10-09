using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;
using Spedmon;

namespace Spedmon
{
  
     
  public class ManPagesContentReview : WebCustomReport
  {
    
    public ManPagesContentReview(): base (Constants.ROLE_ANNOUNCEMENT_ADMIN) { }
    
    public string tocMkupString  = "";
    public string contMkupString = "";
    public string title          = "";
    
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      
      title = ManPages.SEL_LABEL + " - " + ManPages.SEL_LABEL_REVIEW_CONTENT;
      
      StringBuilder sbToc      = new StringBuilder();
      StringBuilder sbCont     = new StringBuilder();
      List<ManPage> manPages   = Spedmon.ManPages.viewList(dbConnUser, log, uInfo, "Y");
      
      /*###########################################################################
        # Build table of contents
        ###########################################################################*/  
      
      sbToc.Append (@"<section id=""toc"" class=""cont toc"">");
      sbToc.Append (@"<table>");
      sbToc.Append (@"<thead>");
      sbToc.Append (@"<tr>");
      sbToc.Append (@"<th class=""date"">Start Date</th>");
      sbToc.Append (@"<th class=""string"">Title</th>");
      sbToc.Append (@"<th class=""string"">User Roles</th>");
      sbToc.Append (@"<th class=""link"">Link</th>");
      sbToc.Append (@"</tr>");
      sbToc.Append (@"</thead>");
      sbToc.Append (@"<tbody>");

      foreach (ManPage manPage in manPages) {
        
        string tocID   = String.Format (@"toc-{0}",  manPage.id);
        string contID  = String.Format (@"cont-{0}", manPage.id);

        sbToc.Append(@"<tr>");
        sbToc.AppendFormat(@"<td class=""date"">{0}</td>",manPage.startDateStr);
        sbToc.AppendFormat(@"<td class=""string"">{0}</td>",manPage.title);
        sbToc.AppendFormat(@"<td class=""string"">{0}</td>",manPage.forUserRoleIdNamesStr);
        sbToc.AppendFormat(@"<td class=""link"" id=""{0}""><a href=""#{1}"">Go To</a></td>",tocID,contID);
        sbToc.Append(@"</tr>");
        
      }

      sbToc.Append(@"</tbody>");
      sbToc.Append(@"</table>");
      sbToc.Append(@"<br/>");
      sbToc.Append(@"</section>");
      
      
      /*###########################################################################
        # Build content
        ###########################################################################*/  
     
        foreach (ManPage manPage in manPages) {
        
        string tocID   = String.Format (@"toc-{0}",  manPage.id);
        string contID  = String.Format (@"cont-{0}", manPage.id);

        sbCont.AppendFormat(@"<section id=""{0}"" class=""cont doc"">",contID); 
                     
        sbCont.Append(@"<table>");
        sbCont.Append (@"<thead>");
        sbCont.Append (@"<tr>");
        sbCont.Append (@"<th class=""date"">Start Date</th>");
        sbCont.Append (@"<th class=""string"">Title</th>");
        sbCont.Append (@"<th class=""string"">User Roles</th>");
        sbCont.Append (@"<th class=""link"">Link</th>");
        sbCont.Append (@"</tr>");
        sbCont.Append (@"</thead>");
        sbCont.Append(@"<tbody>");
        sbCont.Append(@"<tr>");
        sbCont.AppendFormat(@"<td class=""date"">{0}</td>",manPage.startDateStr);
        sbCont.AppendFormat(@"<td class=""string"">{0}</td>",manPage.title);
        sbCont.AppendFormat(@"<td class=""string"">{0}</td>",manPage.forUserRoleIdNamesStr);
        sbCont.AppendFormat(@"<td class=""link""><a href=""#{0}"">Go Back</a></td>",tocID);
        sbCont.Append(@"</tr>");
        sbCont.Append(@"</tbody>");
        sbCont.Append(@"</table>");
        sbCont.Append(@"<br/>");        
        sbCont.Append(@"<div class=""doc-outer"">");        
        sbCont.Append(@"<div class=""doc-inner"">");        
        sbCont.Append(manPage.content);
        sbCont.Append(@"</div>");
        sbCont.Append(@"</div>");
        sbCont.Append(@"</section>");
        sbCont.Append(@"<br/>");        
      }

      tocMkupString  = sbToc.ToString();
      contMkupString = sbCont.ToString();
      
      
    }
}
}


