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
     * DataEntryBoxDate */
    /**
     * 
     **************************************************************************/

    public class DataEntryBoxDate : DataEntryBoxBase
    {
        public DataEntryBoxDate() : base("date") { }

        protected DateTime? _value           = null;
        protected DateTime? _minValue        = null;
        protected DateTime? _maxValue        = null;
        protected bool      _setValueToToday = false;

        public new DateTime? value { 
            get { return _value; }  
            set { _value = value; } 
        }

        public DateTime? min
        {
            get { return _minValue; }
            set { _minValue = value;  
            }
        }
        public DateTime? max
        {
            get { return _maxValue; }
            set {_maxValue = value; }            
        }

        public void setValue (string value)
        {
            DateTime _valOut;
            if (DateTime.TryParse(value, out _valOut)) _value = _valOut;
        }

        public bool setValueToToday
        {
            get {  return _setValueToToday;}
            set { _setValueToToday = value;}
        }

        protected override void Render(HtmlTextWriter writer)
        {           
           if (_setValueToToday) _value = DateTime.Today;
           if (_value.HasValue)    { _valueStr  = _value.Value.ToHTML5DateString();    } else { _valueStr  = String.Empty; }
           if (_minValue.HasValue) { _minValStr = _minValue.Value.ToHTML5DateString(); } else { _minValStr = String.Empty; }
           if (_maxValue.HasValue) { _maxValStr = _maxValue.Value.ToHTML5DateString(); } else { _maxValStr = String.Empty; }
           if (!_size.HasValue) _size = 8;
           base.Render(writer);
        }
    }
}
