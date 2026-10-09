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
   * UserAllServiceRecordsView */
  /**
   * 
   ***************************************************************************/   

  public class UserAllServiceRecordsView: WebUI
  {
    public UserAllServiceRecordsView() : base( @"user_all_service_records_view"
	                                          , "Service Records"
                                              , @""
                                              , @""
										      , Constants.ROLE_ADMIN){}

    public string restViewURL = @"";
    public string clientID    = @"";
    public string patID       = @"";
    
    protected void Page_Load(object sender, EventArgs e)
    {
          clientID    = @"116";
          patID       = @"1971091";
          restViewURL = MBA.HttpApplication.createLink(@"api/v1/servicerecords"
                                                        , true
                                                        , new NameValue (Constants.PARM_CLIENT_ID,  clientID)
                                                        , new NameValue (Constants.PARM_PATIENT_ID, patID)                                                        
                                                       ); ;
                                                         
    }
  }
}