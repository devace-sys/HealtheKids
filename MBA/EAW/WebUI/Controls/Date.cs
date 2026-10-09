using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Globalization;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class Date : InputBaseDateTime
	{
        // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/date

		public Date (): base(InputType.date,@"date",@"yyyy-MM-dd")
		{
 		          
        } 
        		
        protected override void Render (HtmlTextWriter writer)
		{					  
          base.Render (writer);
		}
	}
}

