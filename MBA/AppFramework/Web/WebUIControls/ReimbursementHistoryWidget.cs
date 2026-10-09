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
     * ReimbursementHistoryWidget */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class ReimbursementHistoryWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public ReimbursementHistoryWidget() : base() { }

        protected string _title          = @"";
        protected string _css            = @"row col-12 d-flex m-0 p-1";
        protected string _footerText     = @"";
        protected bool   _hidden         = false;
        protected bool   _renderHeaders  = false;
        protected string _colHeaders     = @"[]";
        protected string _reqUrlBaseThisYear = @"";
        protected string _reqUrlBaseLastYear = @"";
        protected string _reqUrlBaseGoalAmt  = @"";

        public string    css                { get { return _css;           } set { _css           = value; } }
        public string    title              { get { return _title;              } set { _title         = value; } }
        public bool      hidden             { get { return _hidden;             } set { _hidden        = value; } }
        public bool      renderHeaders      { get { return _renderHeaders;      } set { _renderHeaders = value; } }
        public string    colHeaders         { get { return _colHeaders;         } set { _colHeaders    = value; } }
        public string    footerText         { get { return _footerText;         } set { _footerText    = value; } }
        public string    reqUrlBaseThisYear { get { return _reqUrlBaseThisYear; } set { _reqUrlBaseThisYear = value; } }
        public string    reqUrlBaseLastYear { get { return _reqUrlBaseLastYear; } set { _reqUrlBaseLastYear = value; } }
        public string    reqUrlBaseGoalAmt  { get { return _reqUrlBaseGoalAmt;  } set { _reqUrlBaseGoalAmt = value; } }
        protected override void Render(HtmlTextWriter writer)
        {   
            // if hidden, don't render anything
            if (_hidden)
            {
                return;
            }

            var _divID       = @"mbareimbursementhistory" + "_" + Guid.NewGuid().ToString();
            var reqUrlThisYear = MBA.HttpApplication.createLink(_reqUrlBaseThisYear, true);
            var reqUrlLastYear = MBA.HttpApplication.createLink(_reqUrlBaseLastYear, true);
            var reqUrlGoalAmt  = MBA.HttpApplication.createLink(_reqUrlBaseGoalAmt, true);

            string _opts = @"{"
                         + @" 'title':"""          + _title          + @""""                        
                         + @",'renderHeaders':"""  + _renderHeaders  + @""""
                         + @",'colHeaders':'"      + _colHeaders     + @"'"                        
                         + @",'footerText':"""     + _footerText     + @""""
                         + @",'reqUrlThisYear':""" + reqUrlThisYear  + @""""
                         + @",'reqUrlLastYear':""" + reqUrlLastYear  + @""""
                         + @",'reqUrlGoalAmt':"""  + reqUrlGoalAmt   + @""""
                         + @"}";

            writer.Write(@"<div id=""{0}"" class=""mba-reimbursement-history-content-wrapper {1}""></div>"
                           , _divID
                           , _css);
            writer.Write ("<script>$( document ).ready(function(){ $('#" + _divID + "').reimbursementHistoryWidget(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}
