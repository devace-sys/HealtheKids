using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  
  /***************************************************************************
   * AppException */
  /**
   * Base class for MBA application exceptions.   Used mainly to identify
   * an MBA exception.
   ***************************************************************************/ 
  
  public class AppException:ApplicationException
  {    
    public bool excludeMsgFromDetails = false;

    public AppException():base(){}
    public AppException(string message):base(message){}  
    public AppException(string message, bool excludeMsgFromDetails):base(message){this.excludeMsgFromDetails = excludeMsgFromDetails;}
    public AppException(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  
  }
  
  /***************************************************************************
   * EarlyExit */
  /**
   * Early Exit exception  Mainly used for login and logout.
   ***************************************************************************/ 

  public class EarlyExit:AppException
  {
    public EarlyExit():base(){}    
  }

 
 /***************************************************************************
  * SessionExpired */
 /**
  * Session expired exception
  ***************************************************************************/ 
  
  public class SessionExpired:AppException
  {
    public SessionExpired():base(){}
    public SessionExpired(string msg):base(msg){}
    public SessionExpired(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }

 /***************************************************************************
  * SubscriptionRequired */
 /**
  * User requires subscription to app
  ***************************************************************************/ 
  
  public class SubscriptionRequired:AppException
  {
    public SubscriptionRequired():base(){}
    public SubscriptionRequired(string msg):base(msg){}
    public SubscriptionRequired(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }

 /***************************************************************************
  * PasswordLock */
 /**
  * Password lock out
  ***************************************************************************/ 
  
  public class PasswordLock:AppException
  {
    public PasswordLock():base(){}
    public PasswordLock(string msg):base(msg){}
    public PasswordLock(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }

  /***************************************************************************
   * Warning */
  /**
   * Warning expection.
   ***************************************************************************/   

  public class Warning:AppException
  {
    public Warning():base(){}    
    public Warning(string msg):base(msg){}
    public Warning(string message, bool excludeMsgFromDetails):base(message,excludeMsgFromDetails){}
    public Warning(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }

  /***************************************************************************
   * Critical */
  /**
   * Critical expection.
   ***************************************************************************/   
  
  public class Critical:AppException
  {
    public Critical():base(){}    
    public Critical(string msg):base(msg){}
    public Critical(string message, bool excludeMsgFromDetails):base(message,excludeMsgFromDetails){}
    public Critical(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }
  
  /***************************************************************************
   * Fatal */
  /**
   * Fatal expection.
   ***************************************************************************/   

  public class Fatal:AppException
  {
    public Fatal():base(){}    
    public Fatal(string msg):base(msg){}
    public Fatal(string message, bool excludeMsgFromDetails):base(message,excludeMsgFromDetails){}
    public Fatal(string msg, string[] details):base(msg){this.Data.Add("details",details);}
  }
   
}
