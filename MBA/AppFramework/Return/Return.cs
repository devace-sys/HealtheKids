using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  /***************************************************************************
   * Return */
  /**
   * This is our base class for all return objects.
   ***************************************************************************/   

  public class Return
  {
    public const int RET_SUCCESS           = 0;
    public const int RET_INFO              = 1;
    public const int RET_WARNING           = 2;
    public const int RET_CRITICAL          = 3;
    public const int RET_ERROR             = 4;
    public const int RET_ABORT_OR_CANCEL   = 5;
    public const int RET_SESSION_EXPIRE        = 12;  // Keep in synch with database exception #
    public const int RET_PASSWORD_LOCK         = 14;  // Keep in synch with database exception #
    public const int RET_SUBSCRIPTION_REQUIRED = 15;  // Keep in synch with database exception #

    public const int RET_DUPLICATE_RECORD  = 20;
    public const int RET_REDIRECT          = 50;
    public const int RET_FATAL             = 99;

    public int      status  = RET_SUCCESS;
    public string   message = "Success";
    public string[] details;
    
    public Return()
    {
      status  = RET_SUCCESS;
      message = "Success";
    }

    public Return(string msg)
    {
      status  = RET_SUCCESS;
      message = msg;
    }

    public Return(string msg, string[] detailsin)
    {
      status  = RET_SUCCESS;
      message = msg;
      details = detailsin;
    }

    public Return (MBA.SessionExpired e)
    {
      status  = RET_SESSION_EXPIRE;
      message = e.Message.ToString();
      if (e.Data.Contains("details")){details = (string[])e.Data["details"];}      
    }
    
    public Return(MBA.Warning e)
    {
      status  = RET_WARNING;
      message = e.Message.ToString();
      if (e.Data.Contains("details")){details = (string[])e.Data["details"];}
    }

    public Return(MBA.Critical e)
    {
      status  = RET_CRITICAL;
      message = e.Message.ToString();
      if (e.Data.Contains("details")){details = (string[]) e.Data["details"];}
    }
    
    public Return (MBA.Fatal e)
    {
      status  = RET_FATAL;
      message = e.Message.ToString();
      if (e.Data.Contains("details")){details = (string[]) e.Data["details"];}
    }

    public Return(Exception e)
    {
      status  = RET_ERROR;
      message = e.Message.ToString();
      if (e.Data.Contains("details")){details = (string[]) e.Data["details"];}
    }
  }
 
}
