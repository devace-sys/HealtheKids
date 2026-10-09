using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class NumberRange : InputBaseNumber
	{
		// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/range

        public NumberRange (): base(InputType.range, @"numberrange")
		{
		}

		protected override void Render (HtmlTextWriter writer)
		{
			base.Render (writer);
		}
	}
}

