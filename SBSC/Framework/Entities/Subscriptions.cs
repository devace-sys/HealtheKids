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
   * Subscription */
  /**
   * A subscription to a report publication
   **************************************************************************/
   
  public class Subscription:MBA.Subscription
  {        
    public long   ClientID;
    public string ClientName;
    public string RepNameFirst;
    public string RepNameLast;
    public string RepEmail;
    public string RelativeDateRange1;
    public string RelativeDateRange2;                     
  }
  
  /***************************************************************************
   * Subscriptions */
  /**
   * Methods to work with report subscriptions
   **************************************************************************/

  public class Subscriptions:Entities
  {          
    
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL             = "Subscriptions";
    public const string SEL_LABEL_ADD         = "Add New";
    public const string SEL_LABEL_VIEW        = "View";
    public const string SEL_LABEL_EDIT_DELETE = "Edit or Delete";
    public const string SEL_LABEL_EDIT        = "Edit";   
    public const string SEL_LABEL_DELETE      = "Delete";
    
    /***************************************************************************
     * save */
    /**
     * Save a subscription record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * @param  publicationID   Publication id,
     * @param  subscriberID    subscriber id
     * @param  autoDistribute        1 = Yes, 0 = No
     * @param  distributionNotes     Any notes about the distribution (fax only, send with invoice, etc)
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
                                         string publicationID,
                                         string subscriberID, 
                                         string autoDistribute,
                                         string reqFileType,
                                         string distributionNotes,
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
      
      List<SqlParameter> parms           = new List<SqlParameter>();
      
      Object    vClientID                = Validate.optClientID (uInfo,  clientID);
      int       vPublicationID           = Validate.reqInteger  (publicationID,      Messages.INVALID_REP_PUB);
      int       vSubscriberID            = Validate.reqInteger  (subscriberID,       Messages.INVALID_SUBSCRIBER_ID);
      bool      vAutoDistribute          = Validate.reqFlag     (autoDistribute,     Messages.INVALID_PUB_SUB_OPTIONS);
      string    vDistributionNotes       = Validate.optString   (distributionNotes,  Messages.INVALID_NOTES);      
      int       vReqFileType             = Validate.reqShort    (reqFileType,        Messages.INVALID_FILE_TYPE);

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.Int,      vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@publicationID",       SqlDbType.Int,      vPublicationID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@subscriberID",        SqlDbType.Int,      vSubscriberID,              ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@autoDistribute",      SqlDbType.Bit,      vAutoDistribute,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@reqFileType",         SqlDbType.SmallInt, vReqFileType,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@distributionNotes",   SqlDbType.VarChar,  vDistributionNotes,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@MsgNoClient",         SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID, ParameterDirection.Input, 1000));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "REPORT_PUBLICATION_SUBSCRIPTION_Save", Messages.DUP_RPT_SUB_REC, ref parms,null);
    }     

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single subscription record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static Subscription load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (Subscription)Entities.load(connSpedmon, log, uInfo, recID, typeof(Subscription),
      delegate { return Subscriptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", null); });
    } 

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a subscription record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
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
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"REPORT_PUBLICATION_SUBSCRIPTION_Delete",ref parms);
    }
        
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool   paged,
                                           string pageNumber,
                                           string clientID,
                                           string canEdit,
                                           string active)
    {
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");
       
        ss.addDisplayColumn("ClientName as [Client]",         true);       
        ss.addDisplayColumn("SubscriberName as [Subscriber]", true);
        ss.addDisplayColumn("PublicationName as [Report]",    true);
        
        pageroworder = ss.pageRowOrder();

      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return Subscriptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Subscriptions";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
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
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.REPORT_PUBLICATION_SUBSCRIPTION_VIEW (@userID, @userGroup, @userRank ,@clientID, @active, @includeSensitiveReportsAndInternalSubscribers, @recID)";
      
      bool includeSensitiveReportsAndInternalSubscribers = uInfo.pcalStaff;

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
        
      Object vClientID = Validate.optClientID (uInfo, clientID);
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
      
      parms.Add(Database.SqlParm("@includeSensitiveReportsAndInternalSubscribers", SqlDbType.Bit, includeSensitiveReportsAndInternalSubscribers, ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }    
  }
}
