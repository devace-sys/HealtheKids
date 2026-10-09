using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  /**************************************************************************
   * RmtsCurrentQuarter */
  /**
   **************************************************************************/

  public class RmtsCurrentQuarter : Entity
  {
     public bool   isCurrentQuarter;
     public string startDateStr;
     public string endDateStr;
     public long   qtrNumber;
     public long   fyID;
  }
  
  /**************************************************************************
   * RmtsCurrentQuarters */
  /**
   * Current quarter selection
   *
   * Note: This is not a menu item
   **************************************************************************/

  public class RmtsCurrentQuarters:Entities
  {          

    /***************************************************************************
     * loadAllRecords */
    /**
     * 
     ***************************************************************************/                                                                  
    public static List<RmtsCurrentQuarter> loadAllRecords (   SqlConnection connSpedmon
                                                              , DetailsLog    log
                                                              , UserInfo      uInfo ) 
    {
      
      var listItems = new List<RmtsCurrentQuarter>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (RmtsCurrentQuarter)
                                      , delegate { 
                                        return RmtsCurrentQuarters.view (  connSpedmon
                                                                         , log
                                                                         , uInfo
                                                                         , Entities.REC_VIEW_ALL
                                                                         , false
                                                                         , ""
                                                                         , ""
                                                                         , ""
                                                                         , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          RmtsCurrentQuarter listItem = (RmtsCurrentQuarter) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
    
    /***************************************************************************
     * loadCurrentQuarter */
    /**
     * 
     ***************************************************************************/                                                                  
   public static RmtsCurrentQuarter loadCurrentQuarter (  SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo ) 
    {
      var so = new RmtsCurrentQuarter();
      var qtrs = loadAllRecords(connSpedmon,log,uInfo);
      foreach (var qtr in qtrs) {
        if (qtr.isCurrentQuarter == true) 
        {
          so = qtr;
          break;
        }
      }
      return so;
    }

    /***************************************************************************
     * viewSel */
    /**
     * Returns a list of attendance years for record selection
     ***************************************************************************/   
    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
    {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        ss.addDisplayColumn("[startDateStr] + ' to ' + [endDateStr] as context1");
        ss.addDisplayColumn("[startDateStr] as recData1");
        ss.addDisplayColumn("[endDateStr] as recData2");
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return RmtsCurrentQuarters.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", dc);});

    }

    /***************************************************************************
     * view */
    /**
     * Returns a ReturnDB object containing current fiscal rmts quarters
     *
     * @return ReturnDB
     ***************************************************************************/  
     
    public static ReturnDB view ( SqlConnection connSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , int    recViewType
                                , bool   pagedOrTop
                                , string idx
                                , string canEdit
                                , string active
                                , defineCols dc) 
    {
    
      string viewUDF = "dbo.RMTS_CURRENT_QUARTERS_VIEW()";    


      List<SqlParameter> parms = new List<SqlParameter>();

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
        
    public static RmtsCurrentQuarter load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        recID )
    {      
      return (RmtsCurrentQuarter) Entities.load(connSpedmon, log, uInfo, recID, typeof(RmtsCurrentQuarter),
      delegate { return RmtsCurrentQuarters.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "1", null); });
    }
  }
}
