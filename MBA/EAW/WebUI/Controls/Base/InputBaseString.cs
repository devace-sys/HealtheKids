using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using EAW.Web.UI;
using EAW.Web.UI.Controls.Base;
using EAW.Web.UI.Controls.Attributes;

namespace EAW.Web.UI.Controls.Base
{
    /// <summary>
	/// Input base string.
	/// </summary>
    public abstract class InputBaseString : InputBase
	{
       // text, search, tel, url, email, or password
       public InputBaseString (InputType type, string classCtrl) : base(type, classCtrl)
	   {
	   }

		private int?   _max   = null;
		private int?   _min   = null;
        private int?   _size  = null;
        
		[Description("The max chars allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public int? Max { get { return _max; } set { _max = value; } }

		[Description("The min chars allowed.  Used in HTML forms."), Category("HTML data attribute"), DefaultValue(null)]
		public int? Min { get { return _min; } set { _min = value; } }
		
		[Description("The display size"), Category("HTML data attribute"), DefaultValue(null)]
		public int? Size { get { return _size; } set { _size = value; } }
		
        // todo: pattern
        
        protected override void Render (HtmlTextWriter writer)
		{			           
            AddAttributeIfDefined(_max,   @"maxlength");
			AddAttributeIfDefined(_min,   @"minlength");
           	AddAttributeIfDefined(_size,  @"size");	
            base.Render (writer);
		}

	}
}

