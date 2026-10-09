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
     * CalendarWidget */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class CalendarWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public CalendarWidget() : base() { }

        protected string _title = @"Calendar";
        protected string _urlDateOnClick = @"";
        protected bool _hidden = false;

        // NUEVO
        protected string _defaultViewMode               = @""; // "agenda" | "calendar"
        protected string _urlAgendaGet                  = @"";
        protected string _clientid                      = @"";
        protected string _pracid                        = @"";
        protected string _sessionTimeOutUrl             = @"";
        protected string _urlScheduledServiceEditBase   = @"";
        protected string _urlScheduledServiceDeleteBase = @"";
        protected string _urlPatientEditBase            = @"";
        protected string _urlGroupViewEntity            = @"";
        protected string _urlGroupOnEdit                = @"";
        protected string _urlGroupOnClick               = @"";
        protected string _urlScheduledServiceAddBase    = @"";
        protected string _urlEditGrpSchSvc              = @"";

        public string title { get { return _title; } set { _title = value; } }
        public string urlDateOnClick { get { return _urlDateOnClick; } set { _urlDateOnClick = value; } }
        public bool hidden { get { return _hidden; } set { _hidden = value; } }

        public string defaultViewMode { get { return _defaultViewMode; } set { _defaultViewMode = value; } }
        public string urlAgendaGet { get { return _urlAgendaGet; } set { _urlAgendaGet = value; } }
        public string clientid { get { return _clientid; } set { _clientid = value; } }
        public string pracid { get { return _pracid; } set { _pracid = value; } }
        public string sessionTimeOutUrl { get { return _sessionTimeOutUrl; } set { _sessionTimeOutUrl = value; } }

        public string urlScheduledServiceEditBase { get { return _urlScheduledServiceEditBase; } set { _urlScheduledServiceEditBase = value; } }
        public string urlScheduledServiceDeleteBase { get { return _urlScheduledServiceDeleteBase; } set { _urlScheduledServiceDeleteBase = value; } }
        public string urlPatientEditBase { get { return _urlPatientEditBase; } set { _urlPatientEditBase = value; } }
        public string urlGroupViewEntity { get { return _urlGroupViewEntity; } set { _urlGroupViewEntity = value; } }
        public string urlGroupOnEdit { get { return _urlGroupOnEdit; } set { _urlGroupOnEdit = value; } }
        public string urlEditGrpSchSvc { get { return _urlEditGrpSchSvc; } set { _urlEditGrpSchSvc = value; } }
        public string urlScheduledServiceAddBase { get { return _urlScheduledServiceAddBase; } set { _urlScheduledServiceAddBase = value; } }

        protected override void Render(HtmlTextWriter writer)
        {
            if (_hidden) return;

            var _divID = @"mbacalendarwidget" + "_" + Guid.NewGuid().ToString();

            string _opts = @"{"
                         + @" 'title':""" + _title + @""""
                         + @",'tkn':""" + rd.wu.usr.token + @""""
                         + @",'urlDateOnClick':""" + _urlDateOnClick + @""""
                         + @",'defaultViewMode':""" + _defaultViewMode + @""""
                         + @",'urlAgendaGet':""" + _urlAgendaGet + @""""
                         + @",'clientid':""" + _clientid + @""""
                         + @",'pracid':""" + _pracid + @""""
                         + @",'sessionTimeOutUrl':""" + _sessionTimeOutUrl + @""""
                         + @",'urlScheduledServiceEditBase':""" + _urlScheduledServiceEditBase + @""""
                         + @",'urlScheduledServiceDeleteBase':""" + _urlScheduledServiceDeleteBase + @""""
                         + @",'urlPatientEditBase':""" + _urlPatientEditBase + @""""
                         + @",'urlGroupViewEntity':""" + _urlGroupViewEntity + @""""
                         + @",'urlGroupOnEdit':""" + _urlGroupOnEdit + @""""
                         + @",'urlEditGrpSchSvc':""" + _urlEditGrpSchSvc + @""""
                         + @",'urlScheduledServiceAddBase':""" + _urlScheduledServiceAddBase + @""""
                         + @"}";

            writer.Write(@"<div id=""{0}""></div>", _divID);
            writer.Write("<script>$(document).ready(function(){ $('#" + _divID + "').calendarWidget(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }

}