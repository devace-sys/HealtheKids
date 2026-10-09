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
   * ClientAttendanceYear */
  /**
   * A client attendance year
   **************************************************************************/
   
  public class ClientAttendanceYear:Entity
  {            
    public string   attendanceYear;
    public string   startDateStr;
    public string   endDateStr;
    public string   description;
    public bool     current;
  }
  
  /***************************************************************************
   * ClientAttendanceYears */
  /**
   * Methods to work with ClientAttendanceYear
   *
   * Note: This is not a menu item
   **************************************************************************/

  public class ClientAttendanceYears:Entities
  {          
    
    
    /***************************************************************************
     * loadNRecord */
    /**
     * Returns record n
     ***************************************************************************/   
    
    public static ClientAttendanceYear loadNRecord (SqlConnection connSpedmon, 
                                                    DetailsLog log, 
                                                    UserInfo uInfo,
                                                    int n)
    {
      return (ClientAttendanceYear)Entities.loadNRecord(connSpedmon, log, uInfo, n, typeof(ClientAttendanceYear),
      delegate { return ClientAttendanceYears.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "Y", "", null); });
    }
            
    /***************************************************************************
     * load */
    /**
     * Returns record 
     ***************************************************************************/       
    
    public static ClientAttendanceYear load (SqlConnection connSpedmon, 
                                             DetailsLog log, 
                                             UserInfo uInfo,
                                             string recID)
    {
      return load(connSpedmon, log, uInfo, recID, null);   
    }


    public static ClientAttendanceYear load (SqlConnection connSpedmon, 
                                             DetailsLog log, 
                                             UserInfo uInfo,
                                             string recID,
                                             string refDate)
    {
      return (ClientAttendanceYear)Entities.load (connSpedmon, log, uInfo, recID, typeof(ClientAttendanceYear),
      delegate { return ClientAttendanceYears.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "Y", refDate, null); });
   
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
        ss.addDisplayColumn("description as context1");
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return ClientAttendanceYears.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", "", dc);});

    }

    /***************************************************************************
     * view */
    /**
     * Returns a ReturnDB object containing attendance years.
     *
     * @param   active          1    = show only next, current, and last 
     *                                 attendance years.
     *                          0    = show all except next, current, and last 
     *                          null = show all
     * @return ReturnDB
     ***************************************************************************/  
     
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog log, 
                                 UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string refDate,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.CLIENT_ATTENDANCE_YEARS_VIEW (@userID, @userGroup, @userRank , @refDate, @active)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      Object vRefDate = Validate.optDate(refDate,Messages.INVALID_REF_DATE);

      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@refDate",  SqlDbType.DateTime, vRefDate,  ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }    
  }
}
