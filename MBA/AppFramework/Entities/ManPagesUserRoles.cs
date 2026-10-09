using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  /***************************************************************************
   * ManPage*/
  /**
   * 
   **************************************************************************/
  
  public class ManPagesUserRole: Entity
  {                
    
  }
  
  /***************************************************************************
   * ManPagesUserRoles */
  /**
   * 
   **************************************************************************/
  
  public abstract class ManPagesUserRoles:Entities
  {
     
    /***************************************************************************
     * view */
    /**
     * View user roles
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB view (   SqlConnection connUsers
                                     ,  DetailsLog log
                                     ,  UserInfo uInfo
                                     ,  int recViewType
                                     ,  bool   pagedOrTop
                                     ,  string idx
                                     ,  string canEdit
                                     ,  string active
                                     ,  string appName
                                     ,  string term
                                     ,  defineCols dc )
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms     = new List<SqlParameter>();   

      string             viewUDF   = "APP_MAN_PAGES_USER_ROLES_VIEW (@userID, @userGroup, @userRank, @appName, @term)";      

      Object             vAppName  = Validate.optString (appName,  Messages.NO_APP_NAME);
      Object             vTerm     = Validate.optString (term,     @"Invalid term");
      
      parms.Add(Database.SqlParm("@appName",  SqlDbType.VarChar,  vAppName,  ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar,  vTerm,    ParameterDirection.Input, 256));

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
    
    public static ReturnSel viewSel (   SqlConnection connUsers
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , bool top
                                      , string topSize
                                      , string appName
                                      , string term) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){
      
      };

      return Entities.viewSel(connUsers, log, uInfo,top, topSize,
        delegate{return ManPagesUserRoles.view (connUsers, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", appName, term, dc);});
    }
  }
}
