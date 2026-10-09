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
     * AnnouncementsWidget */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class AnnouncementsWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public AnnouncementsWidget() : base() { }

        protected string _title = @"Announcements";
        protected string _urlAnnouncementsAjax = @"";
        protected string _urlAnnouncementsAjaxData = @"";
        protected string _urlAnnouncementsLinksBase = @"";
        public string title                    { get { return _title; }                     set { _title = value; } }
        public string urlAnnouncementsAjax     { get { return _urlAnnouncementsAjax; }      set { _urlAnnouncementsAjax = value; } }
        public string urlAnnouncementsAjaxData { get { return _urlAnnouncementsAjaxData; }  set { _urlAnnouncementsAjaxData = value; } }
        public string urlAnnouncementsLinksBase { get { return _urlAnnouncementsLinksBase; } set { _urlAnnouncementsLinksBase = value; } }

        protected override void Render(HtmlTextWriter writer)
        {

            var _divID = @"mbaannouncementwidget" + "_" + Guid.NewGuid().ToString();

            string _opts = @"{"
                         + @" 'title':""" + _title + @""""
                         + @",'tkn':""" + rd.wu.usr.token + @""""
                         + @",'urlAnnouncementsAjax':""" + _urlAnnouncementsAjax + @""""
                         + @",'urlAnnouncementsAjaxData':'" + _urlAnnouncementsAjaxData + @"'"
                         + @",'urlAnnouncementsLinksBase':'" + _urlAnnouncementsLinksBase + @"'"
                         + @"}";

            writer.Write(@"<div id=""{0}""></div>"
                           , _divID);
            writer.Write("<script>$( document ).ready(function(){ $('#" + _divID + "').announcementsWidget(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }

}