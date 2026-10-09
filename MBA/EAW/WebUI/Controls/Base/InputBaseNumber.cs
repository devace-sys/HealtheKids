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
    /// Input base number.
    /// </summary>
    public abstract class InputBaseNumber : InputBase
	{

       /// <summary>
       /// Initializes a new instance of the <see cref="EAW.Web.UI.Controls.Base.InputBaseNumber"/> class.
       /// </summary>
       /// <param name="type">Type.</param>
       /// <param name="classCtrl">Class ctrl.</param>
       public InputBaseNumber (InputType type, string classCtrl) : base(type, classCtrl)
	   {
	   }

		private Double? _max   = null;
		private Double? _min   = null;
		private Double? _step  = null;
		private Double? _value = null;
        
        /// <summary>
        /// Gets or sets the max.
        /// </summary>
        /// <value>The max.</value>
        [Description("The max value allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public Double? Max { get { return _max; } set { _max = value; } }

		/// <summary>
		/// Gets or sets the minimum.
		/// </summary>
		/// <value>The minimum.</value>
        [Description("The min value allowed.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public Double? Min { get { return _min; } set { _min = value; } }

		/// <summary>
		/// Gets or sets the step.
		/// </summary>
		/// <value>The step.</value>
        [Description("The step increment.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public Double? Step { get { return _step; } set { _value = _step; } }

		/// <summary>
		/// Gets or sets the value.
		/// </summary>
		/// <value>The value.</value>
        [Description("The value of the input field.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public Double? Value { get { return _value; } set { _value = value; } }
		
        /// <summary>
        /// Render the specified writer.
        /// </summary>
        /// <param name="writer">Writer.</param>
        protected override void Render (HtmlTextWriter writer)
		{			           
	      if (_value.HasValue) _valueStr = _value.Value.ToString();
          AddAttributeIfDefined(_max,  @"max");
		  AddAttributeIfDefined(_min,  @"min");
		  AddAttributeIfDefined(_step, @"step");	
          base.Render (writer);
		}

	}
}

