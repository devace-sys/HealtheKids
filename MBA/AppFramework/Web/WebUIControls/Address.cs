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
   * Address */
  /**
   * Address tags
   * https://www.w3schools.com/tags/tag_address.asp 
   **************************************************************************/

  public class Address : WebUIControlContainer
  {
    public Address() : base("address", false) { }

    protected string _value = @"";

    public string value { get { return _value; } set { _value = value;}}
    protected override void Render(HtmlTextWriter writer)
    {
      
      if (!String.IsNullOrEmpty(_value))
      { 
        this.Controls.Add(new RawText(_value));       
      }
    
      /*-------------------------------
       * Render child controls
       *------------------------------*/

      base.Render(writer);

    }
  }

}

