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
     * DeptHeadWidget */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class DeptHeadWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public DeptHeadWidget() : base() { }

        protected string _title     = @"";
        protected string _css       = @"row col-12 d-flex m-0 p-1";
        protected bool   _hidden    = false;
        protected string _link1Title = @"";
        protected string _link1Url   = @"";

        public string    css                { get { return _css;           } set { _css           = value; } }
        public string    title              { get { return _title;         } set { _title         = value; } }
        public bool      hidden             { get { return _hidden;        } set { _hidden        = value; } }
        public string    link1Title         { get { return _link1Title;    } set { _link1Title    = value; } }
        public string    link1Url           { get { return _link1Url;      } set { _link1Url      = value; } }
       
        protected override void Render(HtmlTextWriter writer)
        {   
            // if hidden, don't render anything
            if (_hidden)
            {
                return;
            }

            var _divID       = @"mbadepthead" + "_" + Guid.NewGuid().ToString();

            string _opts = @"{"
                         + @" 'title':"""          + _title          + @""""
                         + @",'link1Title':"""     + _link1Title     + @""""
                         + @",'link1Url':"""       + _link1Url       + @""""
                         + @"}";

            writer.Write(@"<div id=""{0}"" class=""mba-dept-head-content-wrapper {1}"" style=""height: 7em;""></div>"
                           , _divID
                           , _css);
            writer.Write ("<script>$( document ).ready(function(){ $('#" + _divID + "').deptHeadWidget(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}
