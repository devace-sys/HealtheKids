using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Net;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class Url : InputBaseString
	{
		public Url (): base(InputType.url, @"url")
		{
		}

		private Uri _value = null;

		[Description("The value of the input field.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public string Value { get { return _value.OriginalString; } set { _value = new Uri(value); } }

		protected override void Render (HtmlTextWriter writer)
		{		  
		  if (_value != null) _valueStr = _value.OriginalString; 
          base.Render (writer);
		}
	}
}

