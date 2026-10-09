using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  /***************************************************************************
   * Distribution*/
  /**
   * 
   **************************************************************************/
   
  public class Distribution:MBA.Distribution
  {        
                       
  }
  
  /***************************************************************************
   * Distributions */
  /**
   * 
   **************************************************************************/

  public class Distributions:Entities
  {          
        
    /***************************************************************************
     * view */
    /**
     * View distribution.
     * 
     * Note: This is for use by automation only.
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog log, 
                                 UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID,
                                 DateTime runDate,
                                 defineCols dc) /* no reason this shouldn't be a method of MBA.Distribution */
    {
    
      string viewUDF = "dbo.REPORT_PUBLICATION_DISTRIBUTION_VIEW (null,null,null,@clientID,@runDate,1)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      Object vClientID = Validate.optInteger(clientID, Messages.INVALID_CLIENT_ID);
    
      List<SqlParameter> parms = new List<SqlParameter>();              

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,       vClientID, ParameterDirection.Input));          
      parms.Add(Database.SqlParm("@runDate",  SqlDbType.DateTime,  runDate,   ParameterDirection.Input));     
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
    
  
  }
}
