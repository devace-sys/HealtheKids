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
   * StepSelectionOptions */
  /**
   * Options for post selection
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class StepSelectionOptions : Control
  {
    public StepSelectionOptions() { }

    protected override void Render(HtmlTextWriter writer)
    {

      /*-------------------------------
       * Content start
       *------------------------------*/

      writer.Write(@"<div id=""" + this.ID + @""">");
      base.Render(writer);
      writer.Write(@"</div>");
    }
  }

}

