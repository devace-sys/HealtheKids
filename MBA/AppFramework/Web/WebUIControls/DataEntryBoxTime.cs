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
     * DataEntryBoxTime */
    /**
     * 
     **************************************************************************/

    public class DataEntryBoxTime : DataEntryBoxBase
    {
        public DataEntryBoxTime() : base("time") { }
        protected DateTime? _value    = null;
        protected DateTime? _minValue = null;
        protected DateTime? _maxValue = null;

        public new DateTime? value
        {
            get { return _value; }
            set { _value = value; }
        }
        public DateTime? min
        {
            get { return _minValue;  }
            set { _minValue = value; }
        }
        public DateTime? max
        {
            get { return _maxValue; }
            set { _maxValue = value; }
        }
        public void setValue(string value)
        {
            DateTime _valOut;
            if (DateTime.TryParse(value, out _valOut)) _value = _valOut;
        }

        public void setValue(TimeSpan? value)
        {
          if (value.HasValue)
          {            
            _value = new DateTime(value.Value.Ticks);
          }          
        }

        protected override void Render(HtmlTextWriter writer)
        {            
          if (_value.HasValue)    { _valueStr  = _value.Value.ToHTML5TimeString();    } else { _valueStr  = String.Empty; }
          if (_minValue.HasValue) { _minValStr = _minValue.Value.ToHTML5TimeString(); } else { _minValStr = String.Empty; }
          if (_maxValue.HasValue) { _maxValStr = _maxValue.Value.ToHTML5TimeString(); } else { _maxValStr = String.Empty; }
          base.Render(writer);
        }
    }
}
