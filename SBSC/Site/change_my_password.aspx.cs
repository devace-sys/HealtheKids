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
 * ChangeMyPassword */
/**
 * Page for users to change their own password
 ***************************************************************************/

namespace Spedmon
{
  public class changemypassword : WebUI
  {        
    public changemypassword() : base("changemypassword","My Account - Change My Password","","",Constants.ROLE_ALL){}
    public string urlNextPage = @"";
    protected void Page_Load(object sender, EventArgs e)
    {           
      DataEntryRowSaveOrEdit ctrlSaveOrEdit = findControlRecu (this.Page, "saveOrEdit") as DataEntryRowSaveOrEdit;
      string startingPage = rd.wu.usr.startingPage;
      if (String.IsNullOrWhiteSpace(startingPage)) startingPage = Constants.HOME_PRIVATE;
      ctrlSaveOrEdit.includeCancelButton = true;
      if (rd.wu.usr.passwordMustBeChanged          == true) ctrlSaveOrEdit.includeCancelButton = false;
      if (rd.wu.usr.initialPasswordChangeCompleted == false) startingPage = Constants.MAN_PAGES_PRIVATE_NEW;
      urlNextPage = MBA.HttpApplication.createLink(startingPage,true);      
    }
  }
}
