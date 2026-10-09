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

namespace Spedmon
{
  
     
  public class NewsletterPagePrivate : WebUI
  {
    public string recid;

    /*
       public string pagenav_load_url = MBA.HttpApplication.createLink(
        "multimedia_page_private.aspx" ,
        true ,
        new NameValue("amd" , "uidbssub" ));
      */

    public NewsletterPagePrivate(): base ( "newsletterpageprivate"
                                    , "Newsletter Page"       
									, "newsletter_page_private.css"
                                    , ""
                                    ,Constants.ROLE_ALL){}
    
    public string tkn = "";
    

    protected void Page_Load(object sender, EventArgs e)
    {   
      
       this.useSessionHelperPrivacyScreen = false; 

      /*###########################################################################
       # Fetch parameters
       ###########################################################################*/
            
      recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);

      var  ctrlIframe   = findControlRecu(this.Page, "contentIframe")      as MBA.IFrame;

      ctrlIframe.src = MBA.HttpApplication.createLink(
          "newsletter_page_content_private.ashx",
          true,
          new NameValue("recid", recid));


      tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");

    }
  }
}


