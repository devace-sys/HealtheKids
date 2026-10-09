using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
 
  public class Publication:MBA.Publication
  {
  }
  
  public class Publications:Entities
  {
     
    public const string SEL_LABEL = "Subscribe to Reports";
    
    /***************************************************************************
     * viewSel */
    /**
     * Returns a selection list of publications
     * 
     ***************************************************************************/   

    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
    {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        ss.addDisplayColumn("Description as context1");
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return Publications.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", dc);});

   }
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog log, 
                                 UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.REPORT_PUBLICATION_VIEW (null,null,null, @includeSensitive)";
      
      bool includeSensitive = uInfo.pcalStaff;

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@includeSensitive",     SqlDbType.Bit,   includeSensitive,   ParameterDirection.Input));
        
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
    
  }
}
