using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using System.IO;
using EAW.MediaFile;

namespace Spedmon
{
  
  /***************************************************************************
   * Sessions */
  /**
   *
   ***************************************************************************/
  
  public class Sessions:MBA.Sessions
  {
     public static ReturnValue requestKeepAlive ( ref RequestResponse rd, string msgName, string msgDataJSON )
     {
       return requestKeepAlive(Constants.APP_NAME,ref rd, msgName, msgDataJSON);
     }

  }
}
