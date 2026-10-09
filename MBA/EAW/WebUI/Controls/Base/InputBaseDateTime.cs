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
	/// Input base datetime.
	/// </summary>   
    public abstract class InputBaseDateTime : InputBase
	{

        public InputBaseDateTime (InputType type, string classCtrl, string fmt) : base(type, classCtrl)
	    {
	        _fmt = fmt;
        }

		private   DateTime? _max   = null;
		private   DateTime? _min   = null;
		private   int?      _step  = null;
		private   DateTime? _value = null;
        private   string    _fmt   = @""; /* Format string for datetime.. used for isolating date part or time part */

        [Description("The max value allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public DateTime? Max { get { return _max; } set { _max = value; } }

		[Description("The min value allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public DateTime? Min { get { return _min; } set { _min = value; } }

		[Description("The value of the input field.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public DateTime? Value { get { return _value; } set { _value = value; } }
		
		[Description("The step increment.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public int? Step { get { return _step; } set { _step = value; }}

        protected override void Render (HtmlTextWriter writer)
		{			           	                  		                  
          if (_value.HasValue) this._valueStr = _value.Value.ToString(_fmt);
          AddAttributeIfDefined(this._max,  @"max", _fmt);
          AddAttributeIfDefined(this._min,  @"min", _fmt);
          AddAttributeIfDefined(this._step, @"step");
          base.Render (writer);
		}

	}
}

