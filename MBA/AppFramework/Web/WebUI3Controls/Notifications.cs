using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace MBA.WebUI3Controls
{	
	public class Notifications : EAW.Web.UI.Controls.UnorderedList
	{    	   
      public Notifications():this(null)
      {

      }
      public Notifications (string id): base()
		  {
        this.ID = id; 
        this.Class = @"alert-group";
      }

      protected int _notificationCounter = 0;
      public void AppendNotification (int returnStatus, string message)
      {
        var n1 = new WebUI3Controls.Notification(returnStatus, message);
        this._childControlsToAppend.Add(n1);
        _notificationCounter++;
      }
      public void AppendNotification (WebUI3Common.ElementSemantic notificationType, string message)
      {
        var n1 = new WebUI3Controls.Notification(notificationType, message);
        this._childControlsToAppend.Add(n1);
        _notificationCounter++;
      }

      public void AppendNotification (WebUI3Common.ElementSemantic notificationType, string message, string actionMessage, string actionURL)
      {
        var n1 = new WebUI3Controls.Notification(notificationType, message);
        n1.Actionable    = true;
        n1.ActionMessage = actionMessage;
        n1.ActionURL     = actionURL;
        
        this._childControlsToAppend.Add(n1);
        _notificationCounter++;
      }

      public bool HasNotifications {get {if (this._notificationCounter == 0) return true; else return false;}}
	}
}

