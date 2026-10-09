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
   * TeleCommFormSelectParticipant */
  /**
   * 
   * 
   ****************************************************************************/ 

  public class TeleCommFormSelectParticipant:ControlBase
  {
    public TeleCommFormSelectParticipant(){}    
    
    protected TeleCommSessionParticipant _tsp;
	  protected List<TeleCommParticipant>  _participants;
    protected long?                      _selectWhatParticipantRoleID;
    protected string _cssClasses         = @"custom-select";

    /* Must be set via code behind */
	  public TeleCommSessionParticipant     tsp                 { get { return _tsp; }                    set { _tsp = value; }}  
    
    /* Must be set via code behind */	  
    public List<TeleCommParticipant>      participants        { get { return _participants;}            set { _participants = value;}}
	
	  public long? selectWhatParticipantRoleID {  get { return _selectWhatParticipantRoleID; } set { _selectWhatParticipantRoleID = value;} }
    public string cssClasses                 { get { return _cssClasses;}                    set { _cssClasses = value;}}
    protected override void Render (HtmlTextWriter writer) 
	  { 
      
      writer.Write(@"<select id=""{0}"" name=""{0}{2}"" class=""{1}"" required>", this.ID, this._cssClasses, Constants.PARM_ROOM_PART_UID);

      writer.Write(@"<option value=""""></option>");                            

      foreach (var participant in participants) {
        
        if (participant.email == @"") continue;
          
        /* Dont include if we are filtering */
        if (_selectWhatParticipantRoleID.HasValue)          
            if (participant.roleID != _selectWhatParticipantRoleID.Value) continue;
                    
        var _selected = @"";
        
        if (participant.email == _tsp.participantEmail) 
          _selected = @" selected"; /* Note: Keep the leading space*/
        else
          _selected = @"";

        writer.Write(@"<option value=""{0}""{2}>{1}</option>",participant.email, participant.name, _selected);                            
        
      }      
      writer.Write(@"</select>");     
      
	 }  
  }
}

