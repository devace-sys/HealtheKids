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
 * SBSSystemAdminTelecommServer */
/**
 * 
 ***************************************************************************/

namespace Spedmon
{
  public class SBSSystemAdminTelecommServer : WebUI
  {
    protected string  _configDataJSON    = @"{}";
    protected string  _sessionsDataJSON  = @"{}";
    protected string  _participantsDataJSON  = @"{}";
    public    string  sessionsDataJSON   { get { return _sessionsDataJSON; } }
    public    string  configDataJSON     { get { return _configDataJSON;   } }
    public    string participantDataJSON { get {return _participantsDataJSON;}}
    public SBSSystemAdminTelecommServer() : base("systemadmintelecomm","System Admin - TeleComm","","",Constants.ROLE_ADMIN){}
    protected void Page_Load(object sender, EventArgs e)
    {               
      _configDataJSON   = MBA.TeleCommSessionParticipants.getServerActiveConfig();
      _sessionsDataJSON = MBA.TeleCommSessionParticipants.getSessions();
      
      //_participantsDataJSON = MBA.TeleCommSessionParticipants.getParticipants();
    }

  }
}
