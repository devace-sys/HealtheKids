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
     * UserQuickLinks */
    /**
     * the js file will need to be included for this component
     * 
     ****************************************************************************/
 
    public class UserQuickLinks : ControlBase
    {
 
        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/
 
        public UserQuickLinks() : base() { }

        protected string _title              = @"";
        public string    title              { get { return _title;              } set { _title              = value; } }
       
        protected override void Render(HtmlTextWriter writer)
        {   
 
            var _divID       = @"mbauserquicklinks" + "_" + Guid.NewGuid().ToString();

            string _opts = @"{"
                         + @" 'title':"""         + _title                              + @""""                        
                         + @",'tkn':"""           + rd.wu.usr.token                     + @""""                        
                         + @"}";
 
            writer.Write(@"<div id=""{0}""></div>"
                           , _divID);
            writer.Write ("<script>$( document ).ready(function(){ $('#" + _divID + "').userQuickLinks(" + _opts + ");})</script>");
 
            base.Render(writer);
        }
    }

}

