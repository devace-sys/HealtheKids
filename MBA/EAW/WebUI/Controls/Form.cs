using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	/*
accept-charset 	Specifies the charset used in the submitted form (default: the page charset).
action 	Specifies an address (url) where to submit the form (default: the submitting page).
autocomplete 	Specifies if the browser should autocomplete the form (default: on).
enctype 	Specifies the encoding of the submitted data (default: is url-encoded).
method 	Specifies the HTTP method used when submitting the form (default: GET).
name 	Specifies a name used to identify the form (for DOM usage: document.forms.name).
novalidate 	Specifies that the browser should not validate the form.
target 	Specifies the target of the address in the action attribute (default: _self).
*/

	public class Form : ElementBase
	{

		public Form () : base("form",@"form")
		{      
    
		}

		private string _action   = null;
		private string _method   = null;
		private string _target   = null;

        
        
    
    
    [Description("HTTP Url"), Category("HTML attribute"), DefaultValue(null)]
		public string Action { get { return _action; } set { _action = value; } }
    
		[Description("HTTP verb"), Category("HTML attribute"), DefaultValue(null)]
		public string Method { get { return _method; } set { _method = value; } }

		[Description("Target"), Category("HTML attribute"), DefaultValue(null)]
		public string Target { get { return _target; } set { _target = value; } }

		protected override void Render (HtmlTextWriter writer)
		{
			                   
     
      this.AddAttribute ("action", this._action);
			this.AddAttribute ("method", this._method);
			this.AddAttribute ("target", this._target);      
            
      base.Render (writer);
		}
	}
}

