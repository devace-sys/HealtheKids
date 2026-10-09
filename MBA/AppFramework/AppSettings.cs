using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using MBA.IdentifyData;

namespace MBA
{          
  public class AppSettings
  {
        
    /***************************************************************************
     * getAppSetting */
    /**
     * Returns value of setting
     * 
     ***************************************************************************/                                          
    
    public static bool getAppSetting (   SqlConnection connUsers
                                        , DetailsLog    log
                                        , UserInfo      uInfo 
                                        , string        appName
                                        , string        namespaceName
                                        , string        className
                                        , string        subClass1
                                        , string        subClass2
                                        , string        name
                                        , out string    value )
    {           
    
      Object returnDBScalarVal;
      value = null;

      /*----------------------------
       * Scalar udf call
       *---------------------------*/

      string sql = @"select dbo.APP_SETTING_GET_VALUE (@appName, @namespace, @class, @subClass1, @subClass2, @name)";
                           
      /*----------------------------
       * Parameters
       *---------------------------*/
      
      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@appName",   SqlDbType.VarChar, appName,       ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@namespace", SqlDbType.VarChar, namespaceName, ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@class",     SqlDbType.VarChar, className,     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@subClass1", SqlDbType.VarChar, subClass1,     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@subClass2", SqlDbType.VarChar, subClass2,     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@name",      SqlDbType.VarChar, name,          ParameterDirection.Input, 50));

      /*----------------------------
       * Attempt to retrieve value
       *----------------------------*/  
      
      if (Database.execScalar(connUsers,sql, parms, out returnDBScalarVal)) {
        value = (String) returnDBScalarVal;
        return true;
      }
      else
      {
        value = null;
        return false;
      }
    }        
  }
}
