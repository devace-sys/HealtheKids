using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;
using EAW.Web.UI.Controls;

namespace MBA.WebUI3Controls
{
	public class HiddenValue : EAW.Web.UI.Controls.HiddenValue
	{		
        public HiddenValue(): base()
		{
		
       }

		protected override void Render (HtmlTextWriter writer)
		{	     
            base.Render (writer);
		}

	}
}

