using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{


    public class TimekeeperEmployees : Entities
    {


        public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo)
        {

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                
            };
            bool top = false;
            string topSize = "";
            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return TimekeeperEmployees.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", dc); });

        }

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int recViewType,
                                     bool pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string active,
                                     defineCols dc
                                     )
        {

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewEmployeeList] ()";

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        public static ReturnSel viewSelTasksForEmployee(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string empid)
        {

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

            };
            bool top = false;
            string topSize = "";
            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return TimekeeperEmployeeFavorites.getAvailableTasks(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, "", empid, dc); });

        }



        public static ReturnSaveRecord saveFavTaskForEmployee (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        taskID
      , string        empid )
      
        {           

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vtaskid           = Validate.reqInteger   (taskID,   "invalid task id");  
	  
      parms.Add(Database.SqlParm("@taskID",        SqlDbType.BigInt, vtaskid,        ParameterDirection.Input));

      return Entities.save(connSpedmon, log, uInfo, "1", "0", "", empid, "Timekeeper_MoveToFavoriteTasks", Messages.DUP_CASELOAD_REC , ref parms, null);

        }   

        public static ReturnSaveRecord deleteFavTaskForEmployee (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        taskID
      , string        empid )
      
        {           

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vtaskid           = Validate.reqInteger   (taskID,   "invalid task id");  
	  
      parms.Add(Database.SqlParm("@taskID",        SqlDbType.BigInt, vtaskid,        ParameterDirection.Input));

      return Entities.save(connSpedmon, log, uInfo, "1", "0", "", empid, "Timekeeper_RemoveFromFavoriteTasks", Messages.DUP_CASELOAD_REC , ref parms, null);

        }   


        public static ReturnSaveRecord saveFavClientForEmployee (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        taskID
      , string        empid )
      
        {           

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vtaskid           = Validate.reqInteger   (taskID,   "invalid task id");  
	  
      parms.Add(Database.SqlParm("@taskID",        SqlDbType.BigInt, vtaskid,        ParameterDirection.Input));

      return Entities.save(connSpedmon, log, uInfo, "1", "0", "", empid, "Timekeeper_MoveToFavoriteClients", Messages.DUP_CASELOAD_REC , ref parms, null);

        }   

        public static ReturnSaveRecord deleteFavClientForEmployee (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        taskID
      , string        empid )
      
        {           

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vtaskid           = Validate.reqInteger   (taskID,   "invalid task id");  
	  
      parms.Add(Database.SqlParm("@taskID",        SqlDbType.BigInt, vtaskid,        ParameterDirection.Input));

      return Entities.save(connSpedmon, log, uInfo, "1", "0", "", empid, "Timekeeper_RemoveFromFavoriteClients", Messages.DUP_CASELOAD_REC , ref parms, null);

        }   


   public static ReturnSel favoriteClientsViewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string empid)
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
     string topSize = "500"; string term = "";
     ReturnSel rs = Entities.viewSel(connSpedmon, log, uInfo ,top, topSize,

     delegate{return TimekeeperEmployees.getFavoriteClients(connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, /* topSize, */ term, empid, dc);});

     return rs;

   }


   public static MBA.ReturnDB getFavoriteClients(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, int recViewType,
                                 bool pagedOrTop, string term, string empid, defineCols dc) {
     List<SqlParameter> parms = new List<SqlParameter>();
     object v_empid  = Validate.optInteger (empid, "invalid empid");
     parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt,  v_empid, ParameterDirection.Input));
     return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, "1", "", "", "[dbo].[TIMEKEEPER_ViewListOfFavoriteClients] (@empid)", ref parms, null, dc);
  }





  }
}

