using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

using MBA;

namespace MBA.WebUI3Controls
{	
	public class Notification : EAW.Web.UI.Controls.ListItem
	{    
	    
      public Notification (): this(WebUI3Common.ElementSemantic.info,null)
	    {
      }
      public Notification(int returnStatus, string message):this(WebUI3Common.ReturnStatusToElementSemantic(returnStatus), message)
      {
      }
      
      public Notification (WebUI3Common.ElementSemantic notificationType, string message): base()
      {
        this._notificationType = notificationType;       
        this._message          = message;
      }
      
      protected bool                         _actionable       = false;
      protected string                       _actionMessage    = @"";
      protected string                       _actionURL        = @"";
      protected bool                         _dismissable      = true;
      protected string                       _message          = @"";
      

      protected WebUI3Common.ElementSemantic _notificationType = WebUI3Common.ElementSemantic.info;
           
      [Description("Is There An Associated Action?"), Category("Render Option"), DefaultValue(true)]
      public bool                         Actionable       { get  { return _actionable;}      
                                                             set  { _actionable = value;}}
      
      [Description("Action Message"), Category("Render Option"), DefaultValue(null)]
      public string                       ActionMessage    { get  { return _actionMessage;}          
                                                             set  { _actionMessage = value;}}

      [Description("Action URL"), Category("Render Option"), DefaultValue(null)]
      public string                       ActionURL        { get  { return _actionURL;}          
                                                             set  { _actionURL = value;}}

      [Description("Can this notification be dismissed?"), Category("Render Option"), DefaultValue(true)]
      public bool                         Dismissable      { get  { return _dismissable;}      
                                                             set  { _dismissable = value;}}
      [Description("Notification Message"), Category("Render Option"), DefaultValue(null)]
      public string                       Message          { get  { return _message;}          
                                                             set  { _message = value;}}
      [Description("Notification Type"), Category("Render Option"), DefaultValue(WebUI3Common.ElementSemantic.info)]
      public WebUI3Common.ElementSemantic NotificationType { get  { return _notificationType;} 
                                                             set  { _notificationType = value;}}
      protected override void Render (HtmlTextWriter writer)
		  {
       
        this.Class = String.Format(@"alert alert-{0}",WebUI3Common.GetElementSemanticName(_notificationType));
        if (String.IsNullOrEmpty(_message)) _message = @"";
        
        Control m1 = new LiteralControl(_message);
        this._childControlsToAppend.Add(m1);

        if (_actionable)
        {
          string am1 = String.Format(@"<a href=""{0}"" class=""alert-link"">{1}</a>",_actionURL,_actionMessage);
          var ac1 = new LiteralControl(am1);
          this._childControlsToAppend.Add(ac1);
        }

        if (_dismissable) 
        {
          this.Class = this.Class + @" alert-dismissible fade show";
          Control b1 = new LiteralControl(@"<button type=""button"" class=""close"" data-dismiss=""alert"" aria-label=""Close""><span aria-hidden=""true"">&times;</span></button>");
          this._childControlsToAppend.Add(b1);
        }
        
        
        base.Render (writer);
		 }
	}
}

