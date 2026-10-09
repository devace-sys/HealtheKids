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
     * PCalPerformanceWidgetUrlSet */
    /**
     * 
     ****************************************************************************/

    public class PCalPerformanceWidgetUrlSet
    {
        public string title;
        public string label;
        public string iframeSrcUrl;
        public string popUpPageUrl;
        public string regularPageUrl;
        public string menuID;
    }

    /**************************************************************************
     * PCalPerformanceWidget */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class PCalPerformanceWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public PCalPerformanceWidget() : base() { }

        protected string _title               = @"";
        protected string _css                 = @"row col-12 d-flex m-0 p-1";
        protected bool   _hidden              = false;
        protected string _iframeSrcUrl        = @"";
        protected string _popUpPageUrl        = @"";
        protected bool   _openPopUpOnSamePage = false;
        public string    css                 { get { return _css;           } set { _css           = value; } }
        public string    title               { get { return _title;         } set { _title         = value; } }
        public bool      hidden              { get { return _hidden;        } set { _hidden        = value; } }
        public string    iframeSrcUrl        { get { return _iframeSrcUrl;  } set { _iframeSrcUrl  = value; } }
        public string    popUpPageUrl        { get { return _popUpPageUrl;  } set { _popUpPageUrl  = value; } }
        public bool      openPopUpOnSamePage { get { return _openPopUpOnSamePage;}  set { _openPopUpOnSamePage = value; } }
        protected override void Render(HtmlTextWriter writer)
        {   
            // if hidden, don't render anything
            if (_hidden)
            {
                return;
            }

            var _divID       = @"mbapcalperformance" + "_" + Guid.NewGuid().ToString();

            string _opts = @"{"
                         + @" 'title':"""             + _title          + @""""
                         + @",'iframeSrcUrl':"""      + _iframeSrcUrl   + @""""
                         + @",'popUpPageUrl':"""      + _popUpPageUrl   + @""""
                         + @",'openPopUpOnSamePage':" + Util.netBoolToJSBool(_openPopUpOnSamePage)
                         + @"}";

            writer.Write(@"<div id=""{0}""></div>"
                           , _divID);
            writer.Write ("<script>$( document ).ready(function(){ $('#" + _divID + "').pcalPerformanceWidget(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}
