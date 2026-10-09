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
   * ServiceRecordsApprovalSvcRecsToChangeDetail */
  /**
   ***************************************************************************/
  public class ServiceRecordsApprovalSvcRecsToChangeDetail : Entity {
        public long   journalID;
        public long   ID;
        public string SvcReviewNotes;
        public string startTimeStr;
        public string endTimeStr;
        public long   svcRecID;
        public long   svcRecApprovalID;
        public string SvcReviewedOnStr;
        public long   SvcReviewedByUserID;
        public string SvcReviewedByUserName;
        public string SvcReviewedByName;
        public string SvcReviewedByTitle;     
   }

  /***************************************************************************
   * ServiceRecordsApprovalSvcRecsToChange */
  /**
   * Records of services rendered by practitioners for patients.  These
   * records can be entered either by the client or internal staff.
   ***************************************************************************/

  public class ServiceRecordsApprovalSvcRecsToChangeDetails:Entities
  {

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
                                 string        pracID,
                                 defineCols dc)
    {
   
      string viewUDF = "dbo.SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_DETAIL (@userID, @userGroup, @userRank, @clientID, @pracID, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      long  vClientID  = Validate.reqClientID (uInfo,  clientID);
      long  vPracID    = Validate.reqPracID   (uInfo,  pracID);
	        
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,   vClientID,  ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@pracID",     SqlDbType.Int,   vPracID,    ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
     * viewObjects */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static List<ServiceRecordsApprovalSvcRecsToChangeDetail> viewList (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
                                           , string        pracID
                                          )
    {
      
     
        var recs = new List<ServiceRecordsApprovalSvcRecsToChangeDetail>();
        ReturnDB rd = ServiceRecordsApprovalSvcRecsToChangeDetails.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, paged, pageNumber, canEdit, active, clientID, pracID, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ServiceRecordsApprovalSvcRecsToChangeDetail));
        foreach (var o in slo) {
            recs.Add((ServiceRecordsApprovalSvcRecsToChangeDetail) o);
        }
        return recs;         
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
                                           , string        pracID
                                          )
    {
      ReturnDataTable so = new ReturnDataTable();
               
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("PatientName as [Patient]",  true);
        ss.addDisplayColumn("SvcDateStr  as [Date]",     true);              
        ss.addDisplayColumn("SvcName     as [Service Rendered]", true); 
        ss.addDisplayColumn("SvcReviewedByName + ' (' + SvcReviewedByTitle + ')' as [Service Reviewed By]");
        ss.addDisplayColumn("SvcReviewedOnStr as [Service Reviewed On]");
        ss.addDisplayColumn("SvcReviewNotes  as [Review Notes]");
        ss.addDisplayColumn("svcFromJournal as [svcFromJournal]");      
        ss.addDisplayColumn("svcRecID    as [referenceID1]");       
        ss.addDisplayColumn("journalID   as [referenceID2]");
        ss.addDisplayColumn("id");              
               
        //ss.addPageOrderColumn("Held asc");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceRecordsApprovalSvcRecsToChangeDetails.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, pracID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Records to Change";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }

    
    /***************************************************************************
     * load */
    /**
     * loads a man page
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  userID          User record id
     * @return                 User
     ***************************************************************************/ 
    
    public static ServiceRecordsApprovalSvcRecsToChangeDetail load (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string recID)
    { 
      return (ServiceRecordsApprovalSvcRecsToChangeDetail) Entities.load (connUsers, log, uInfo, recID, typeof(ServiceRecordsApprovalSvcRecsToChangeDetail),
      delegate 
      {    
        return ServiceRecordsApprovalSvcRecsToChangeDetails.view (connUsers, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, null, "1", null, null, null);
      });      
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
                                                 , string        pracID
                                                )
    {                                           

      ReturnDataTable rd = viewTbl(connSpedmon, log, uInfo,false,"1",null,null,clientID,pracID);
      
      rd.tableName   = "Records to Correct";
      rd.tableFooter = String.Format ("{0} records", rd.iTotalRecords);
      
      
      /*string editOrDeleteURL = MBA.HttpApplication.createLink( ServiceJournals.URL_PROV_ENTRY_NEW
                                                               , true
                                                               , new NameValue("journalid",journalID)
                                                               , new NameValue("savetype",Constants.SAVE_TYPE_EDIT.ToString())
                                                               , new NameValue("recid",""));
*/

      /*###########################################################################
        # Generate table
        ###########################################################################*/ 

      StringBuilder sb             = new StringBuilder();
      int           numVisibleCols = 0;

      if (rd.hasRecords == false)
      {
        sb.AppendFormat(@"<p>{0}</p>",rd.tableName);
        sb.Append(@"<p>No records</p>");
        return sb.ToString();
      }
      
      sb.Append(@"<table style=""width:95%;margin:0 auto;"">");

      /*###########################################################################
        # Caption
        ###########################################################################*/ 

      sb.Append(@"<caption>");
      sb.Append(rd.tableName);
      sb.Append(@"</caption>");
      
      /*###########################################################################
        # Header
        ###########################################################################*/ 

      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      
      /*============================================================
       * Include all visible columns
       *============================================================*/
           
      foreach (aoColumn col in rd.aoColumns)
      {
        
        if (col.bVisible)
        {
          
          if (col.sTitle == "svcFromJournal") {
            continue;
          }
          
          sb.AppendFormat(@"<th class=""{0} ui-state-default"" style=""width:{1}px"">",col.sClass, col.iWidth);
          sb.Append(col.sTitle);
          sb.Append (@"</th>");
          numVisibleCols++;
        }
        else
        {
          if (col.sTitle == "id") {
          
            string editDeleteColHdr = @"<th class=""ui-state-default"">Change</th>";
            sb.Append(editDeleteColHdr);
            numVisibleCols++;            
          }
        }
      }
      
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");

      /*###########################################################################
        # Footer
        ###########################################################################*/ 

      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th class=""ui-state-default"" colspan=""{0}"">",numVisibleCols);
      sb.Append(rd.tableFooter);
      sb.Append(@"</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");
      
      /*###########################################################################
        # Body
        ###########################################################################*/ 
      
      int curRow = 1;

      sb.Append(@"<tbody>");
                
      foreach(Object[] row in rd.aaData)
      {
        string evenodd = ((curRow % 2) == 0) ? "even":"odd";
        
        sb.AppendFormat (@"<tr class=""{0}"">",evenodd);
        
        int curCol = 0;
        bool   svcFromJournal = false;
        string svcRecID = "";
        string journalID = "";
        
        foreach (Object cell in row)
        {
          aoColumn curaoCol = rd.aoColumns[curCol];
          if (curaoCol.bVisible)
          {
            if (curaoCol.sTitle == "svcFromJournal") {
              
              bool? fJournal = Util.evaluateFlag(cell,true);
              if (fJournal.HasValue) svcFromJournal = fJournal.Value;
              curCol++;
              continue;
            }
            sb.AppendFormat(@"<td class=""{0}"">{1}</td>",curaoCol.sClass, cell);
          }
          else
          {

            if (curaoCol.sTitle == "referenceID1") {svcRecID  = cell.ToString(); }
            if (curaoCol.sTitle == "referenceID2") {journalID = cell.ToString(); }
                       
            if (curaoCol.sTitle == "id") {
              
              string editOrDelURL    = "";
              
              if (svcFromJournal == true) {

                editOrDelURL    = MBA.HttpApplication.createLink (  ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL
                                                                  , true
                                                                  , new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_NEW.ToString())
                                                                  , new NameValue(Constants.PARM_REC_ID,journalID)
                                                                  );
                
              }
              
              else {
              
                editOrDelURL    = MBA.HttpApplication.createLink ( ServiceRecords.PAGE_CLIENT_PROV_SVC_REC_SAVE_SINGLE
                                                                 , true
                                                                 ,  new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_EDIT.ToString())
                                                                 ,  new NameValue(Constants.PARM_REC_ID,   svcRecID)
                                                                 );                            
              }
              
              
              string editDelCol = String.Format(@"<td><a href=""{0}"">Change</a></td>",editOrDelURL);
              sb.Append(editDelCol);
            }
            else { 
              sb.AppendFormat(@"<td style=""display:none;"">{0}</td>",cell);
            }
            
          }
          curCol++;
        }
        sb.Append(@"</tr>");
        curRow++;
      }
      
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");

      return sb.ToString();

    }

        	
  }
} 

