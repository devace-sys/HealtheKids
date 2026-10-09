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
     * ActionItemTotalNumAmt */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class ActionItemTotalNumAmt : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public ActionItemTotalNumAmt() : base() { }

        protected string _urlBaseTotalNumAmt = @"";
        protected string _urlBaseDetails     = @"";
        protected string _urlDetails         = @"";
        protected string _title              = @"";
        protected string _css                = @"row col-12 d-flex m-0 p-1";
        protected string _footerText         = @"";
        protected string _countUnits         = @"";
        protected bool   _includeCount       = true;
        protected bool   _includeSum         = true;
        protected bool   _hidden             = false;
        protected bool   _detailsLinkOnly    = false;

        public string    css                { get { return _css;                } set { _css                = value; } }
        public string    title              { get { return _title;              } set { _title              = value; } }
        public string    urlBaseTotalNumAmt { get { return _urlBaseTotalNumAmt; } set { _urlBaseTotalNumAmt = value; } }
        public string    urlBaseDetails     { get { return _urlBaseDetails;     } set { _urlBaseDetails     = value; } }
        public string    urlDetails         { get { return _urlDetails;         } set { _urlDetails         = value; } }
        public string    footerText         { get { return _footerText;         } set { _footerText         = value; } }
        public string    countUnits         { get { return _countUnits;         } set { _countUnits         = value; } }
        public bool      includeCount       { get { return _includeCount;       } set { _includeCount       = value; } }
        public bool      includeSum         { get { return _includeSum;         } set { _includeSum         = value; } }
        public bool      hidden             { get { return _hidden;             } set { _hidden             = value; } }
        public bool      detailsLinkOnly    { get { return _detailsLinkOnly;    } set { _detailsLinkOnly    = value; } }
        protected override void Render(HtmlTextWriter writer)
        {   
            // if hidden, don't render anything
            if (_hidden)
            {
                return;
            }

            var _anchorID       = @"mbaactionitem" + "_" + Guid.NewGuid().ToString();
            var _urlTotalNumAmt = MBA.HttpApplication.createLink ( _urlBaseTotalNumAmt, true);
            var _targetHrefMkup = @"";

            if (!String.IsNullOrEmpty(_urlDetails))
            {
                _targetHrefMkup = @"target=""_blank"" href=""" + _urlDetails + @"""";
            }
            else
            {
                if (!String.IsNullOrEmpty(_urlBaseDetails))
                {
                    _urlDetails = MBA.HttpApplication.createLink(_urlBaseDetails
                                                                   , true
                                                                   , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                  );
                    _targetHrefMkup = @"target=""_blank"" href=""" + _urlDetails + @"""";
                }
            }

            string _opts = @"{"
                         + @" 'title':"""         + _title                                 + @""""
                         + @",'urlTotalNumAmt':'" + _urlTotalNumAmt                        + @"'"                        
                         + @",'includeCount':"    + Util.netBoolToJSBool(_includeCount)    + @""                        
                         + @",'includeSum':"      + Util.netBoolToJSBool(_includeSum)      + @""                        
                         + @",'footerText':"""    + _footerText                            + @""""                        
                         + @",'countUnits':"""    + _countUnits                            + @""""
                         + @",'detailsLinkOnly':" + Util.netBoolToJSBool(_detailsLinkOnly) + @""
                         + @"}";

            writer.Write(@"<a id=""{0}"" class=""mba-action-item-content-wrapper {1}"" {2}></a>"
                           , _anchorID
                           , _css
                           , _targetHrefMkup );
            writer.Write ("<script>$( document ).ready(function(){ $('#" + _anchorID + "').actionItemTotalNumAmt(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}
