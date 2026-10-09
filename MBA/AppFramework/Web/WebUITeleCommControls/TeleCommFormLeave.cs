using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{  

  /**************************************************************************
   * TeleCommFormLeave */
  /**
   * 
   * @param  tsp            Telecomm session participant
   ****************************************************************************/ 

  public class TeleCommFormLeave:ControlBase
  {
    public TeleCommFormLeave(){}
    
	  protected TeleCommSessionParticipant _tsp;
    protected string _leaveButtonLabel = @"Leave Meeting";
    public string leaveButtonLabel { get { return _leaveButtonLabel;} set { _leaveButtonLabel = value;}}

    public TeleCommSessionParticipant     tsp { get { return _tsp; } set { _tsp = value; }}  

	  protected override void Render (HtmlTextWriter writer) 
	  { 
      writer.Write(@"<form id=""{0}"" method=""get"" action=""{1}"" class=""telecomm-form-leave"">", this.ID, HttpApplication.currentEndPointName());             
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" required/>", Constants.PARM_ROOM_PART_ENTER_OR_EXIT, TeleCommSessionParticipants.SESSION_LEAVE);        
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" required/>", Constants.PARM_ROOM_ID,                 _tsp.roomID);
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" required/>", Constants.PARM_ROOM_PART_UID,           _tsp.participantEmail);          
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" required/>", Constants.PARM_ROOM_PART_PIN,           _tsp.participantPIN);
      writer.Write(@"<button type=""submit"" class=""telecomm-form-button-leave btn btn-primary"">{0}</button>", _leaveButtonLabel);
      writer.Write(@"</form>");      
	  }  
  }
}

