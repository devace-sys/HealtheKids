using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;

namespace MBA
{    
  /***************************************************************************
  * WebSvc*/
  /**
  * Our base class for all web services (.asmx files)
  *
  * Each web method is an end point so all access control and other common
  * functionality is provided at the web method level and the scope of this
  * functionality is the web method.  What this means is that you can have
  * web methods with different access levels all in the same class.
  *
  * This inherits functionality from our HttpApplication class via global.asax 
  ***************************************************************************/

  public class WebSvc : System.Web.Services.WebService
	{

    /*-------------------------------
    * Protected variables
    *------------------------------*/   
    
    protected   SqlConnection           dbConnUser;       // Connection to user database
    protected   SqlConnection           dbConnApp;        // Connection to this applications database
    protected   DetailsLog              log;              // Our logging object
    protected   RequestResponse         rd;               // Our request response object    
    protected   UserInfo                uInfo;            // User info

    /*-------------------------------
     * Shared Public Methods
     *------------------------------*/
     
     // None

    /*-------------------------------
     * Methods
     *------------------------------*/

    /***************************************************************************
    * callMethod */
    /**
    * Wrapper for calling web methods
    * 
    * @param  rt              Return type of method call (use typeof() operator)
    * @param  cb              Method callback (use delegate) 
    * @param  permittedRoles  If this method should be private
    *                         supply all authorized roles
    * @return                 Object containing rt (need to cast)
    ***************************************************************************/   

    public Object callMethod(Type rt, MethodCallback cb)
    {
      return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd,ref this.uInfo, rt,cb,false,null,"");
    }

    public Object callMethod(Type rt, MethodCallback cb, params string[] permittedRoles)
    {
      return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd, ref this.uInfo, rt,cb,true,permittedRoles);
    }

  }
}
