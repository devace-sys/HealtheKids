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
   * TeleCommFormRSVP */
  /**
   * 
   * @param  tsp            Telecomm session participant
   ****************************************************************************/ 

  public class TeleCommFormRSVP:ControlBase
  {
    public TeleCommFormRSVP(){}
    
	protected string _yesButtonLabel = @"Yes, I Will Attend";
 	protected string _noButtonLabel  = @"No, I Cannot Attend";

    protected TeleCommSessionParticipant _tsp;
	public TeleCommSessionParticipant     tsp { get { return _tsp; } set { _tsp = value; }}

    // TODO: this control should have been written with a TeleCommSessionRsvpInfo property,
    //       not a TeleCommSessionParticipant property, but that class wasn't written/invented
    //       until well after I started here

    //protected List<Object> _all_participants;
    //public    List<Object> all_participants { get { return _all_participants; } set { _all_participants = value; }}

    // can't help but notice how convoluted it is that
    // MBA.TeleCommSessionParticipant and MBA.TeleCommParticipant are two separate MBA.Entity classes;
    // the corresponding MBA.Entities classes pull from more or less the same tables.
    // Now we've introduced a third class, TeleCommSessionRsvpInfo

    public string _roomID;
    public string _rsvpReqResp;
    public string _rsvpToken;
    public bool? rsvpWillAttend;
    public DateTime rsvpAltDate;
    public string rsvpNotes;

    public string invite_text;
    public string participants_html_table;

    //public string sped_tkn;

	protected override void Render (HtmlTextWriter writer) 
	{

      if (_tsp == null)            return;
      if (_tsp.sessionOK == false) return;

      writer.Write(@"<div class=""row"">");

      writer.Write(@"<div class=""col-12""><p>");

      writer.Write(invite_text);

      writer.Write(@"</p></div>");

      writer.Write(@"</div>");

      writer.Write(@"<form id=""{0}"" method=""get"" action=""{1}"" class=""telecomm-form-join container"">", this.ID, HttpApplication.currentEndPointName());        

      writer.Write(
          @"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" />",
          Constants.PARM_ROOM_PART_RSVP_TOKEN,
          _tsp.inviteRsvpToken);


      writer.Write(
          @"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" />",
          Constants.PARM_ROOM_PART_RSVP_REQ_RSP,
          TeleCommSessionParticipants.SESSION_RSVP_RSP);

      writer.Write(
          @"<input id=""{0}"" name=""{0}"" type=""hidden"" value=""{1}"" />",
          Constants.PARM_ROOM_PART_RSVP_ALT_DATE,
          _tsp.inviteRsvpAlternateDatetimeRequested);
 

      writer.Write(@"<div class=""row"">");

      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"<label for=""{0}"">Room ID</label>", Constants.PARM_ROOM_ID);
      writer.Write(@"</div>");
      writer.Write(@"<div class=""col-8"">");

      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""text"" value=""{1}"" class=""form-control"" readonly/>",
          Constants.PARM_ROOM_ID,
          _tsp.roomID
          );

      writer.Write(@"</div>");
      writer.Write(@"</div>");

      writer.Write(@"<div class=""row"">");
      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"<label for=""{0}"">Your Email</label>", Constants.PARM_ROOM_PART_UID);       
      writer.Write(@"</div>");

      writer.Write(@"<div class=""col-8"">");
      writer.Write(@"<input id=""{0}"" name=""{0}"" type=""email"" value=""{1}"" class=""form-control"" readonly/>", Constants.PARM_ROOM_PART_UID, _tsp.participantEmail);
      writer.Write(@"</div>");

      writer.Write(@"</div>");

      writer.Write(@"<div class=""row"">");
      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"<label for=""{0}"">Comments</label>", Constants.PARM_ROOM_PART_RSVP_NOTES);       
      writer.Write(@"</div>");

      writer.Write(@"<div class=""col-8"">");
      writer.Write(@"<input id=""{0}"" name=""{0}"" class=""form-control"" value=""{1}""  />",
          Constants.PARM_ROOM_PART_RSVP_NOTES,
          _tsp.inviteRsvpNotes
      );
      writer.Write(@"</div>");

      writer.Write(@"</div>");
            
      writer.Write(@"<div class=""row mt-1"">");

      writer.Write(@"<div class=""col-4"">");
      writer.Write(@"</div>");

      writer.Write(@"<div class=""col-8 d-flex justify-content-end"">");

      writer.Write(@"<button class=""btn btn-secondary mr-1"" type=""submit"" name=""{0}"" value=""0"">{1}", Constants.PARM_ROOM_PART_RSVP_WILL_ATTEND, _noButtonLabel);
      if ( this.rsvpWillAttend == false ) writer.Write(@"<i class=""fa fa-check-circle""></i>");
      writer.Write(@"</button>");
      
      writer.Write(@"<button class=""btn btn-primary ml-1"" type=""submit"" name=""{0}"" value=""1"">{1}", Constants.PARM_ROOM_PART_RSVP_WILL_ATTEND, _yesButtonLabel);
      if ( this.rsvpWillAttend == true ) writer.Write(@"<i class=""fa fa-check-circle""></i>");
      writer.Write(@"</button>");

      writer.Write(@"</div>");

      writer.Write(@"</div>");

      writer.Write(@"</form>");

      writer.Write(this.participants_html_table);

      //writer.Write(@"<div class=""row"">");
      //writer.Write(@"<div class=""col-10"">Participant</div>");
      //writer.Write(@"<div class=""col-2"">Will Attend?</div>");   
      //writer.Write(@"</div></hr/>");
      
      /*
       if (this.all_participants != null)
        foreach ( var i in this.all_participants ) {
          var c = (MBA.TeleCommParticipant) i;         
                                                     
          writer.Write(@"<div class=""row"">");
          writer.Write(@"<div class=""col-10"">{0}</div>", c.name);
          writer.Write(@"<div class=""col-2"">{0}</div>",  Util.boolToYesNoUnknown( c.inviteRsvpWillAttend) );   
          writer.Write(@"</div>");
        
        }
      */

    }

  }

}

