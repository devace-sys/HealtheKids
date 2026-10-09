using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class Number : InputBaseNumber
	{
        // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/number
        
        public Number (): base(InputType.number, @"number")
		{
		}

		protected override void Render (HtmlTextWriter writer)
		{
			base.Render (writer);
		}
	}
}

