using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{      
  /***************************************************************************
   * ClientContactRoles */
  /**
   ***************************************************************************/   
  
  public class ClientContactRoles:Entities
  {
     
    /***************************************************************************
     * view */
    /**
     * View client contact roles
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view ( SqlConnection connSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool   pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string term
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
      string             viewUDF  = "dbo.CLIENT_CONTACT_ROLES_VIEW (@userID, @userGroup, @userRank, @term)";

      parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 1000));
   
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

   /***************************************************************************
    * viewSel */
   /**
    * View contact role selections
    * 
    * @return            ReturnSel
    ***************************************************************************/   
    
    public static ReturnSel viewSel (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , bool          paged
                                     , string        pageNumber
                                     , string        active
                                     , string        term) 
    {

      string vTerm      = Validate.optString (term);

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){
      };

      return Entities.viewSel(connSpedmon, log, uInfo,paged, pageNumber,
        delegate{return ClientContactRoles.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc);});
    }
  
  }
}
