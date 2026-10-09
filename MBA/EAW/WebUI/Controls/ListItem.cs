using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class ListItem : ElementBase
	{
   // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/li

		
    public ListItem() : base("li",@"li")
		{		
    }
		
    protected override void Render (HtmlTextWriter writer)
		{	
			base.Render (writer);
		}
	}
}

