using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class File : InputBase
	{
		public File (): base(InputType.file,@"file")
		{
		}

		protected string _value = null;

		[Description("The value of the input field.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public string Value { get { return _value; } set { _value = value; } }

		protected override void Render (HtmlTextWriter writer)
		{
			AddAttributeIfDefined(_value, @"value");
			base.Render (writer);
		}

	}
}

