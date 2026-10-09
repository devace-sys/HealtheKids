using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  public abstract class Roles:Entities
  {
    
    /***************************************************************************
     * view */
    /**
     * View user roles
     * 
     * @param  appName    Application name (from web.config or app.config) 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view ( SqlConnection connUsers
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool   pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string appName
                                 , string name
                                 , defineCols dc)
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms    = new List<SqlParameter>();   

      string             viewUDF  = "dbo.ROLES_VIEW (@userID, @userGroup, @userRank, @appName, @name,  @canEdit)";
      string             vAppName = Validate.reqString(appName, Messages.NO_APP_NAME);
      string             vName    = Validate.optString(name,    Messages.INVALID_ROLE);
   
      parms.Add(Database.SqlParm("@appname", SqlDbType.VarChar,  vAppName, ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@name",    SqlDbType.NVarChar, vName,    ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

   /***************************************************************************
    * viewSel */
   /**
    * View user role selections
    * 
    * @param  appName    Application name (from web.config or app.config) 
    * @return            ReturnSel
    ***************************************************************************/   
    
    public static ReturnSel viewSel (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, bool top, string topSize, string appName, string term) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){

         ss.addDisplayColumn("[reqSelpaAscStr] as recData1"); 
         ss.addDisplayColumn("[reqClientIDAsscStr] as recData2"); 
         ss.addDisplayColumn("[reqPracIDAsscStr] as recData3"); 
         ss.addDisplayColumn("[reqPrtGrdIDAsccStr] as recData4"); 
         ss.addDisplayColumn("[ascSelpaWithAcctStr] as recData5"); 
         ss.addDisplayColumn("[ascClientWithAcctStr] as recData6"); 
         ss.addDisplayColumn("[ascPracWithAcctStr] as recData7"); 
         ss.addDisplayColumn("[ascPrtGrdWithAcctStr] as recData8"); 
         
      };

      return Entities.viewSel(connUsers, log, uInfo,top, topSize,
        delegate{return Roles.view (connUsers, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "1", "1", appName, term, dc);});
    }

    
   }
}
