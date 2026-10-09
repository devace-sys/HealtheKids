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
   * WebUIControlCommand */
  /**
  * Base class for all controls that accept commands from users.
  * 
  ****************************************************************************/

  public abstract class WebUIControlCommand : WebUIControl
  {
    public WebUIControlCommand(string tag, bool noclosetag) : base(tag, noclosetag) { }

    protected override void Render(HtmlTextWriter writer)
    {
      base.Render(writer);
    }
  }

}

