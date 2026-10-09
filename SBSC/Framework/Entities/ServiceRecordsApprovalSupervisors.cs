using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Collections.ObjectModel;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.Web.Script.Serialization;
using System.Text;

using MBA;

namespace Spedmon
{     
    
   
  /***************************************************************************
   * ServiceRecordsApprovalSupervisors */
  /**
   * Records of services rendered by practitioners for patients.  These
   * records can be entered either by the client or internal staff.
   ***************************************************************************/

  public class ServiceRecordsApprovalSupervisors:Entities
  {

    /***************************************************************************
     * opAssignOrUnassignSupervisor */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opAssignOrUnassignSupervisorByPracID ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec
      , string        recID      
      , string        assign)
    {
      /* We use the logged in users clientID and pracID */
      
      Object    vClientID  = Validate.optClientID (uInfo, "");
	    Object    vPracID    = Validate.optPracID   (uInfo, "");	    
	    bool      vAssign    = Validate.reqFlag     (assign, Messages.INVALID_FLAG_ASSIGN);   

      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.Int,   vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@supervisedPracID",    SqlDbType.Int,   vPracID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@supervisingPracID",   SqlDbType.Int,   recID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@assign",              SqlDbType.Bit,   vAssign,    ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID", ref parms);
      
    }



    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
   
    public static ReturnDB view (SqlConnection connSpedmon,
                                 DetailsLog    log,
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
								                 string        supervisedPracID,
                                 defineCols dc)
    {
   
      string viewUDF = "dbo.PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW (@userID, @userGroup, @userRank, @clientID, @supervisedPracID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID        = Validate.optClientID (uInfo,   clientID);
	    Object    vSupervisedPracID = Validate.optPracID   (uInfo,   supervisedPracID);
	        
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.Int,      vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@supervisedPracID",    SqlDbType.Int,      vSupervisedPracID,  ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
								                           , string        supervisedPracID )
    {
      ReturnDataTable so = new ReturnDataTable();
               
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("PRACTITIONER_ID as [id]");
        ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(Assigned) as [Assigned to Me]", true);                            
        ss.addDisplayColumn("CONCAT_NAME   as [Practitioner]", true);      
        ss.addDisplayColumn("GROUP_NAME    as [Group]");                               
        
		    pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceRecordsApprovalSupervisors.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, supervisedPracID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Records to Approve";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }
    
    /***************************************************************************
     * generateStaticHTMLTable */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 string
     ***************************************************************************/

    public static string generateStaticHTMLTable(  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
								                                 , string        approvingPracID
                                                 )
    {                                          
     
      ReturnDataTable  rd = viewTbl(connSpedmon, log, uInfo,false,"1",null,null,clientID,approvingPracID);          
     
      //rd.tableName   = sj.patientName + " - " + sj.dos + " from " + sj.startOfDayTime + " to " + sj.endOfDayTime;
      //rd.tableFooter = String.Format ("{0} events recorded", rd.iTotalRecords);
      return ReturnDataTable.createHTMLTable (ref rd);

    }    
    	
	
  }
} 

