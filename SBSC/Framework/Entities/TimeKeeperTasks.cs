using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


  public class TimeKeeperTasks : Entities
  {


   public static MBA.ReturnDB getAvailableTasks(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, int recViewType,
                                 bool pagedOrTop, string term, string empid, defineCols dc) {
     List<SqlParameter> parms = new List<SqlParameter>();
     object v_empid  = Validate.optInteger (empid, "invalid empid");
     parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt,  v_empid, ParameterDirection.Input));

     return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, "1", "", "", "[dbo].[TIMEKEEPER_ViewListOfTasks] (@empid)", ref parms, null, dc);
  }

  public static MBA.ReturnDB allAvailableTasks(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, int recViewType,
                                bool pagedOrTop, string term, defineCols dc) {
     return TimeKeeperTasks.getAvailableTasks(connSpedmon, log, uInfo, recViewType,
                                   pagedOrTop, term, "", dc);
  }

   public static ReturnSel allAvailableTasksViewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string term)
   {

     /*----------------------------
      * Define our context column
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
         //ss.addDisplayColumn("dbo.BIT_TO_MSG(ISNULL(CLAIM_TCM,1), '', '** TCM -- DO NOT BILL FOR TCM -- TCM ** | ') + cds as context1");
     };

     /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
     bool top = true;
     string topSize = "500";
     ReturnSel rs = Entities.viewSel(connSpedmon, log, uInfo ,top, topSize,

     delegate{return TimeKeeperTasks.allAvailableTasks(connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, /* topSize, */ term, dc);});

     return rs;

   }

  }
}
