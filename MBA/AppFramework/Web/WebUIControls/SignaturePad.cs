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
     * SignaturePad */
    /**
     * the signature pad js file will need to be included for this component
     * 
     * @param  name             name
     * @param  value            value
     ****************************************************************************/

    public class SignaturePad : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public SignaturePad() : base() { }

        protected string _showSignaturePadBtnLabel = "Sign";
        protected string _showSignaturePadBtnClass = "btn btn-primary";
        protected string _value = "";
        protected string _name = "spedmonsignaturepadbase64data";
        protected string _cssClass = "";

        public string value { get { return _value; } set { _value = value; } }
        public string name  { get { return _name;  } set { _name = value;  } }
        public string cssClass { get { return _cssClass; } set { _cssClass = value; } }
        public string showSignaturePadBtnLabel { get { return _showSignaturePadBtnLabel; } set { _showSignaturePadBtnLabel = value; } }
        public string showSignaturePadBtnClass { get { return _showSignaturePadBtnClass; } set { _showSignaturePadBtnClass = value; } }

        protected override void Render(HtmlTextWriter writer)
        {
            // set up opts
            string _opts = @"{"
                         + @" ""inputNameAndID"":"""          + _name
                         + @""",""inputInitialValue"":"""     + _value
                         + @""",""renderDialogBtnText"":"""   + _showSignaturePadBtnLabel
                         + @""",""renderDialogBtnClass"":"""  + _showSignaturePadBtnClass
                         + @"""}";
            string divID = _name + "_" + Guid.NewGuid().ToString();
            writer.Write(@"<div id=""" + _name + @""" class=""" + _cssClass  + @"""></div>"
                       + @"<script>$( document ).ready(function(){ $('#" + _name + "').spedmonSignaturePad(null," + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}
