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
   * ClientAttendanceCalendar */
  /**
   * A client attendance calendar
   **************************************************************************/
   
  public class ClientAttendanceSchedule:ClientAttendanceYearlyData
  {            
  }
  
  /***************************************************************************
   * ClientAttendanceSchedules*/
  /**
   * Methods to work with ClientAttendanceSchedule
   *
   **************************************************************************/

  public class ClientAttendanceSchedules:ClientAttendanceEntities
  {          
        
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL = "Bell Schedule Names";
    
    /***************************************************************************
     * save */
    /**
     * Save a schedule
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * 
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, 
                                         string name,
                                         string description,
                                         string fiscalYearID,
                                         string editDelReason,
                                         string validateRec,
                                         string saveType, 
                                         string recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long      vClientID     = Validate.reqClientID (uInfo, clientID);                       
      
      string    vName         = Validate.reqString   (name,         Messages.INVALID_NVP_NAME);
      string    vDescription  = Validate.optString   (description,  Messages.INVALID_NVP_DESCRIPTION);
      int       vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
      
      /*----------------------------
       * Populate db params
       *----------------------------*/          

      parms.Add(Database.SqlParm("@clientID",          SqlDbType.Int,      vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",              SqlDbType.VarChar,  vName,             ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@description",       SqlDbType.VarChar,  vDescription,      ParameterDirection.Input, 1000));      
      parms.Add(Database.SqlParm("@fiscalYearID",      SqlDbType.Int,      vFiscalYearID,     ParameterDirection.Input));
 
      parms.Add(Database.SqlParm("@MsgNoClient",       SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoName",         SqlDbType.VarChar,  Messages.INVALID_NVP_NAME,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoFYID",         SqlDbType.VarChar,  Messages.INVALID_FISCAL_YEAR_ID,   ParameterDirection.Input, 1000));
 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLIENT_ATTENDANCE_SCHEDULE_Save", Messages.DUP_CLIENT_ATTENDANCE_SCHEDULE , ref parms, null);
    }     
        
    /***************************************************************************
     * viewSel */
    /**
     * Returns a list of attendance schedules for record selection
     ***************************************************************************/   

    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string clientID, string fiscalYearID, string term)
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
      delegate{return ClientAttendanceSchedules.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "Y", clientID, fiscalYearID, dc);});

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
                                 string clientID,
                                 string fiscalYearID,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.CLIENT_ATTENDANCE_SCHEDULE_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @active, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      Object vClientID     = Validate.optClientID (uInfo,        clientID);
      Object vFiscalYearID = Validate.optInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);      

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int, vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.Int, vFiscalYearID, ParameterDirection.Input));
       
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
    * delete */
    /**
     * "Deletes" a schedule record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string recID)
    {

        /*----------------------------
         * Check for required and 
         * optional parameters
         * and validate data integrity
         * of all supplied parameters
         *----------------------------*/

        Object vClientID = Validate.optClientID(uInfo, "");

        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

        /*----------------------------
         * Call base method 
         *----------------------------*/

        return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLIENT_ATTENDANCE_SCHEDULE_DELETE", ref parms);
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single 
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  ID              ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ClientAttendanceSchedule load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     string recID)
    {
        return (ClientAttendanceSchedule)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientAttendanceSchedule),
        delegate { return ClientAttendanceSchedules.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", null); });
    }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool paged,
                                           string pageNumber,                                          
                                           string clientID,
                                           string fiscalYearID,
                                           string canEdit,
                                           string active)
    {
        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("id");
            ss.addDisplayColumn("clientName                as [Client]");
            ss.addDisplayColumn("fiscalYearName            as [Fiscal Year]");
            ss.addDisplayColumn("name                      as [Bell Schedule Name]", true);
            ss.addDisplayColumn("description               as [Description]",        true);
       
            //ss.addPageOrderColumn("[]");

            pageroworder = ss.pageRowOrder();

        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
          delegate { return ClientAttendanceSchedules.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, fiscalYearID, dc); });
    }
  }
}
