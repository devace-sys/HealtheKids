using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Collections.ObjectModel;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;

namespace MBA
{
  /***************************************************************************
  * DatabaseMgmt */
  /**
  * Database management tools for SQL Server
  ***************************************************************************/

  public class DatabaseMgmt
  {
    
    /***************************************************************************
     * retrieveServerInfo */
    /**
     * Retrieves information about the server that conn is connected to
     * 
     * @param  conn    Open database connection
     * @return Microsoft.SqlServer.Management.Smo.Server
     ***************************************************************************/
    
    protected static Microsoft.SqlServer.Management.Smo.Server retrieveServerInfo (SqlConnection conn)
    {
      Microsoft.SqlServer.Management.Common.ServerConnection srvConn  = new ServerConnection(conn);
      Microsoft.SqlServer.Management.Smo.Server              srv      = new Server(srvConn);
      return srv;
    }

    /***************************************************************************
     * retrieveDatabaseInfo */
    /**
     * Retrieves information about a given database name (dbName)
     * 
     * @param  srv     Microsoft.SqlServer.Management.Smo.Server object
     * @param  dbName  Name of database to retrieve information for from srv
     * @return Microsoft.SqlServer.Management.Smo.Database
     ***************************************************************************/
    
    protected static Microsoft.SqlServer.Management.Smo.Database retrieveDatabaseInfo (Microsoft.SqlServer.Management.Smo.Server srv, string dbName)
    {
      Microsoft.SqlServer.Management.Smo.Database db = srv.Databases[dbName];
      return db;
    }

  }
}