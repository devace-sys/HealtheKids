using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Net.Mail;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class Email : InputBaseString
	{
		public Email (): base(InputType.email, @"email")
		{
		}

		private MailAddress _value = null;

		[Description("The value of the input field.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public string Value { get { return _value.Address; } set { _value = new MailAddress(value); }}

		protected override void Render (HtmlTextWriter writer)
		{		    
            if (_value != null) _valueStr = _value.Address;
			base.Render (writer);
		}
	}
}

