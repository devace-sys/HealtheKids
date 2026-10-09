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
   * TeleCommFormJoin */
  /**
   * 
   * @param  tsp            Telecomm session participant
   ****************************************************************************/ 

  public class TeleCommFormJoin:ControlBase
  {
    public TeleCommFormJoin(){}
    
	  protected string _joinButtonLabel = @"Join Meeting";
    protected TeleCommSessionParticipant _tsp;
	  public TeleCommSessionParticipant     tsp { get { return _tsp; } set { _tsp = value; }}  
    public string joinButtonLabel { get { return _joinButtonLabel;} set { _joinButtonLabel = value;}}

	  protected override void Render (HtmlTextWriter writer) 
	  { 
      writer.Write(@"<form id=""{0}"" method=""get"" action=""{1}"" class=""telecomm-form-join container"">", this.ID, HttpApplication.currentEndPointName());        

      writer.Write(@"<div class=""row"">");

      writer.Write(@"<div class=""col-4 room-join-row-rid"">");
      writer.Write(@"<label for=""{0}"">Room ID</label>", Constants.PARM_ROOM_ID);
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-8"">");    
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""text"" value=""{1}"" class=""form-control"" required/>", Constants.PARM_ROOM_ID,_tsp.roomID);
      writer.Write(@"</div>");
      writer.Write(@"</div>");

      writer.Write(@"<div class=""row room-join-row-uid"">");
      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"<label for=""{0}"">Your Email</label>", Constants.PARM_ROOM_PART_UID);       
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-8"">");    
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""email"" value=""{1}"" class=""form-control"" required/>", Constants.PARM_ROOM_PART_UID,_tsp.participantEmail);  
      writer.Write(@"</div>");
      writer.Write(@"</div>");

      writer.Write(@"<div class=""row room-join-row-pin"">");
      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"<label for=""{0}"">Your PIN</label>", Constants.PARM_ROOM_PART_PIN);               
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-8"">");    
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""password"" class=""form-control"" required/>", Constants.PARM_ROOM_PART_PIN);
      writer.Write(@"</div>");
      writer.Write(@"</div>");
        
      writer.Write(@"<div class=""row justify-content-end room-join-row-submit"">");
      writer.Write(@"<div class=""col-sm-8 col-0"">");
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-sm-4 col-12"">");
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" required/>", Constants.PARM_ROOM_PART_ENTER_OR_EXIT, TeleCommSessionParticipants.SESSION_JOIN);
      writer.Write(@"<button class=""telecomm-form-button-join btn btn-primary"" type=""submit"">{0}</button>",_joinButtonLabel);
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-12 m-0 mt-2 p-0"">");
      writer.Write(@"<p>For the best experience, please join this meeting on a device that has a camera and microphone. You will still have the option to turn off your camera and mute your microphone during your conferencing session</p>");
      writer.Write(@" </div>");
      writer.Write(@" </div>");

      writer.Write(@"</form>");


	  }  
  }
}

