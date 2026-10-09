using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class UnorderedList : ElementBase
	{
    // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/ul

		public UnorderedList() : base("ul",@"ul")
		{		
    }

		protected override void Render (HtmlTextWriter writer)
		{	
			base.Render (writer);
		}
	}
}

