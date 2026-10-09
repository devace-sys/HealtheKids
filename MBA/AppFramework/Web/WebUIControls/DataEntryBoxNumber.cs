using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{
    /**************************************************************************
     * DataEntryBoxNumber */
    /**
     * 
     **************************************************************************/
    public class DataEntryBoxNumber : DataEntryBoxBase
    {
        public DataEntryBoxNumber() : base("number") { }

        protected Double? _value    = null;
        protected Double? _minValue = null;
        protected Double? _maxValue = null;
        protected Double? _step     = null;
        
        /// <summary>
        /// Gets or sets the numeric value
        /// </summary>
       
        [Description("The numeric value."), Category("HTML attribute"), DefaultValue(null)]
        public Double? value
        {
            get { return _value; }
            set { _value = value; }
        }

        public Double? min
        {
            get { return _minValue; }
            set { _minValue = value; }
        }
        public Double? max
        {
            get { return _maxValue;  }
            set { _maxValue = value; }
        }

        public Double? step
        {
            get { return _step;  }
            set { _step = value; }
        }

        public void setValue (string value)
        {
            Double _valOut;
            if (Double.TryParse(value, out _valOut)) _value = _valOut;
        }
        public void setValue (Decimal value)
        {            
            _value = (Double) value;                    
        }
        public void setValue (long value)
        {            
            _value = (Double) value;                    
        }
        public void setValue (int value)
        {            
            _value = (Double) value;                    
        }
        protected override void Render(HtmlTextWriter writer)
        {
           if (_value.HasValue)    { _valueStr  = _value.ToString();          } else { _valueStr  = String.Empty; }
           if (_minValue.HasValue) { _minValStr = _minValue.Value.ToString(); } else { _minValStr = String.Empty; }
           if (_maxValue.HasValue) { _maxValStr = _maxValue.Value.ToString(); } else { _maxValStr = String.Empty; }
           if (_step.HasValue)     { _stepStr   = _step.Value.ToString();     } else { _stepStr   = String.Empty; }

           base.Render(writer);
        }
    }
}
