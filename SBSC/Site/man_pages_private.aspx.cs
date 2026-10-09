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



  public class ManPagesPrivate : WebUI
  {

    public string recid                            = "";
    public bool   preSelectedAnnouncementSpecified = false;
    public string tkn                              = "";
    public string needMoreHelpContactContent       = "";
    public string needMoreHelpContactContent2      = "";


    public ManPagesPrivate(): base ( "manpages"
                                    , ManPages.SEL_LABEL_CONTENT
									, "man_pages_private.css"
                                    , ""
                                    , Constants.ROLE_ALL)
    {
            
    }


    protected void Page_Load(object sender, EventArgs e)
    {

      /*###########################################################################
        # Disable privacy screen mode as we do not want the help screen to be
        # blanked out after a period of idle time.
        ###########################################################################*/

       this.useSessionHelperPrivacyScreen = false;

      /*###########################################################################
        # Load image assets
        ###########################################################################*/

       var img1 = findControlRecu(this.Page, "bigSplash") as MBA.Img;
       var img2 = findControlRecu(this.Page, "croppedSplash" ) as MBA.Img;
       img1.src = MBA.HttpApplication.createLink("web-ui-3/custom/css/hq-orangebg.png");
       img2.src = MBA.HttpApplication.createLink("web-ui-3/custom/css/hq-orangebg - 3.png");

      /*###########################################################################
        # Pass security token to front end
        ###########################################################################*/
 
       tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");

      /*###########################################################################
        # Fetch parameters
        ###########################################################################*/

      recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
     
      /*###########################################################################
        # If the id of an announcement is passed inform the front end that we need
        # to load the specific announcement instead of the first announcement and
        # we need to scroll to the content of the announcement (scrolling past
        # the newsletter search).
        ###########################################################################*/
       
      if (!String.IsNullOrWhiteSpace(recid)) preSelectedAnnouncementSpecified = true;

      /*###########################################################################
        # Generate need more help message content lines
        ###########################################################################*/

      createNeedMoreHelpContactContentTwoStrings(
          ref rd, this.dbConnUser, this.log, this.uInfo,
          out needMoreHelpContactContent,
          out needMoreHelpContactContent2
          );

      /*###########################################################################
        # Add additional content to 1st line of need more help
        ###########################################################################*/

      StringBuilder sb = new StringBuilder();

      sb.Append(@"<p class=""mt-3"">");
      sb.Append(needMoreHelpContactContent);
      sb.Append(@"</p>");
      needMoreHelpContactContent = sb.ToString();
        
      /*###########################################################################
        # Add additional content to 2nd line of need more help
        ###########################################################################*/
      
      sb = new StringBuilder();

      sb.Append(@"<span class=""help-parag-2""><p class=""mt-3 ml-3"">");
      sb.Append(needMoreHelpContactContent2);
      sb.Append(@"</p></span>");
      needMoreHelpContactContent2 = sb.ToString();


    }
  }
}
