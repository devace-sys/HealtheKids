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
    * RawText */
  /**
  * Raw text
  * 
  * @param  text            Text to add
  ****************************************************************************/

  public class RawText : RawHTML
  {
    public RawText() : base() { }
    public RawText(string text) : base(text) { }
  }

}

