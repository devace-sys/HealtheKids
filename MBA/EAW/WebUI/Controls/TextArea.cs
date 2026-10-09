using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
	public class TextArea : FieldBase
	{

		// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/textarea

        public TextArea () : base("textarea",@"textarea")
		{
		}
        
        private int?   _cols  = 20;
        private int?   _max   = null;
		private int?   _min   = null;
        private int?   _rows  = 5;
        
        private System.Web.UI.LiteralControl _value = new LiteralControl(@"");
        
        [Description("The visible width of the text control in character widths.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(20)]
		public int? Cols { get { return _cols; } set { _cols = value; } }

   	    [Description("The max chars allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public int? Max { get { return _max; } set { _max = value; } }

		[Description("The min chars allowed.  Used in HTML forms."), Category("HTML data attribute"), DefaultValue(null)]
		public int? Min { get { return _min; } set { _min = value; } }

        [Description("The number of visible text lines for the control.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(5)]
		public int? Rows { get { return _rows; } set { _rows = value; } }

        [Description("The value of the textarea field.  Used in HTML forms."), Category("Content"), DefaultValue(null)]
		public string Value { get { return _value.Text; } set { _value.Text = value; } }

        // wrap : hard, soft (soft is default)

		protected override void Render (HtmlTextWriter writer)
		{
			if (this.Controls.Count == 0) {
				this.Controls.Add (_value);
			}
			else if (this.Controls.Count == 1) 
            {
			  if (this.Controls [0].GetType () == typeof(System.Web.UI.LiteralControl)) 
              {
			    _value = (System.Web.UI.LiteralControl)this.Controls [0];
			  } 
              else 
              {
                 // Bad
			  }            
			} 
            else 
            {
			  // Bad
            }            
			
            AddAttributeIfDefined(_cols, @"cols");
            AddAttributeIfDefined(_max,  @"maxlength");
			AddAttributeIfDefined(_min,  @"minlength");        
            
            base.Render (writer);
		}
	}
}