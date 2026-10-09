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
using EAW.MediaFile;

namespace MBA
{
     
  /**************************************************************************
   * MediaFileLink */
  /**
   *
   *
   * @param  url        File to link to
   * @param  findFile   Find the file and create a url?
   * @param  filesRoot  Location to start search
   * @param  file       File to search for
   *
   * @param  href            action to take when button is clicked
   * @param  icon            jquery ui icon (ui-icon-x)
   ****************************************************************************/

  public class MediaFileLink : EAW.MediaFile.MediaFileLink
  {
    public MediaFileLink()
    {
    }

  }
}
