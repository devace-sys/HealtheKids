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
   * LinkInternal */
  /**
   * LinkInternal
   *
   * @param  href            Link to external app
   * @param  openNew         Open new page
   * @param  text            Text inside
   ****************************************************************************/

 // TODO: figure out later if we need to modify this to support gotoURLAdditionalParams in the users.dbo.MESSAGES table.
//       It looks like maybe we don't, since right not we're only using this control in a few places unrelated to notifications and messaging.

  public class LinkInternal : ControlBase
  {
      public LinkInternal(): base() {
        this._parameters = new List<MBA.NameValue>();
	  }

      protected string _label                   = String.Empty;
	  protected string _title                   = String.Empty;
      protected string _url                     = String.Empty;
      protected bool   _urlPrivate              = true;
	  protected string _faClass                 = @"fa fa-link";
	  protected bool   _openNew                 = true;
	  protected bool   _subWindow               = true;
      protected string _additionalCssClass      = "";
      protected bool   _hidden                  = false;

      protected List<MBA.NameValue> _parameters = new List<MBA.NameValue>();
      public string label              { get { return _label;      }         set { _label      = value; }}
      public string title              { get { return _title;      }         set { _title      = value; }}
  	  public string url                { get { return _url;        }         set { _url        = value; }}
      public bool   urlPrivate         { get { return _urlPrivate; }         set { _urlPrivate = value; }}
      public string faClass            { get { return _faClass;    }         set { _faClass    = value; }}
      public bool   openNew            { get { return _openNew;    }         set { _openNew    = value; }}
      public bool   subWindow          { get { return _subWindow;  }         set { _subWindow  = value; }}
      public string additionalCssClass { get { return _additionalCssClass;} set { _additionalCssClass = @" " + value.Trim();}}
      public bool   hidden             { get { return _hidden;} set { _hidden = value;} }
      public void addParameter (MBA.NameValue parameter)
      {
          this._parameters.Add(parameter);
      }

	  protected override void Render(HtmlTextWriter writer)
      {
        bool _urlHasParameters = false;

        if (_subWindow == true) this.addParameter(new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));

        MBA.NameValue [] _pa = this._parameters.ToArray();

        this._url = HttpApplication.createLink(this._url, this._urlPrivate, _pa);

        if ((this._urlPrivate == true) || (_pa.Length >0 )) _urlHasParameters = true;

        writer.Write (@"<button class=""mba-web-ui-link-internal mba-web-ui-link-internal-button{4}"" type=""button"" id=""{0}"" title=""{1}""><span class=""mba-web-ui-link-internal mba-web-ui-link-internal-label{4}"">{2}</span><i class=""{3} mba-web-ui-link-internal-icon{4}""></i></button>"
                         , this.ID
                         , this._title
						 , this._label
					     , this._faClass
                         , this._additionalCssClass);

        //string _hdlrCode = (this._openNew == true) ? @"$.spedmonWebUI.openURL('" + this._url + "', 1)" : @"$.spedmonWebUI.gotoURL('" + this._url + "');";

        //writer.Write ("<script>$(document).ready(function(){ $('#" + this.ID + "').on('click',function(e){"+ _hdlrCode + "});});</script>");
        
        string optsJSON = @"{"                              
                        + @"openNew:"             + Util.netBoolToJSBool(_openNew) 
                        + @",baseHasParameters:"  + Util.netBoolToJSBool(_urlHasParameters)                     
                        + @",baseURL:" + @"""" + this._url + @""""                     
                        + @",hidden:"  + Util.netBoolToJSBool(_hidden)                     
                        + @"}";    
        
        writer.Write ("<script>$(document).ready(function(){ $('#" + this.ID + "').MBA_Link(" + optsJSON+ ");})</script>");
		
      }
  }
}
