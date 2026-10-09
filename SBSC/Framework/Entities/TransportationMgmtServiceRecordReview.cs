using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;
using MBA;

namespace Spedmon
{
      
  /***************************************************************************
   * ReturnTransMgmtManageServiceRecordData
  /**
   *
   ***************************************************************************/

  public class ReturnTransMgmtManageServiceRecordReviewDetails : Return
  {
    public ReturnTransMgmtManageServiceRecordReviewDetails ()                 : base(){}
    public ReturnTransMgmtManageServiceRecordReviewDetails (string msg)       : base(msg){}
    public ReturnTransMgmtManageServiceRecordReviewDetails (Exception e)      : base(e){}
    public ReturnTransMgmtManageServiceRecordReviewDetails (Warning e)        : base(e){}
    public ReturnTransMgmtManageServiceRecordReviewDetails (Critical e)       : base(e){}  
    public ReturnTransMgmtManageServiceRecordReviewDetails (SessionExpired e) : base(e){}
    
    public List<TransportationMgmtServiceRecordReviewDetail> svcRecs;  

  }
  
  /***************************************************************************
   * TransportationMgmtServiceRecordReviewDetail
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtServiceRecordReviewDetail 
  {
  
    public TransportationMgmtServiceRecordReviewDetail(){}
        
    [IsDataGridCol(1)]
    [DataGridColTitle("Service Record ID")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsInputKey(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public long svcRecID;
                        
    [IsDataGridCol(2)]
    [DataGridColTitle("Date of Service")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(100)]
    public string dosStr;
    
    [IsDataGridCol(3)]
    [DataGridColTitle("Miles")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(100)]
    public string milesStr;
    
    [IsDataGridCol(4)]       
    [DataGridColTitle("Release")]    
    [DataGridColWidth(50)]    
    public bool? okToBill;    

    [IsDataGridCol(5)]       
    [DataGridColTitle("Notes")]    
    [DataGridColWidth(255)]    
    public string notes; 
    
  
  }
    
  /***************************************************************************
   * TransportationMgmtServiceRecordReviewDetails */
  /**
   *
   **************************************************************************/   
  
  public class TransportationMgmtServiceRecordReviewDetails
  {
    public List<TransportationMgmtServiceRecordReviewDetail> details;
  }
  
  
  /***************************************************************************
   * TransportationMgmtServiceRecordReview */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtServiceRecordReview : Entities
  {
                     
    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
                                  , string        patID
                                  , string        dosRange                                                                   
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @startDate, @endDate)";
      
      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dosRange, out startDate, out endDate);
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long      vClientID    = Validate.reqClientID (uInfo, clientID);
      long      vPatID       = Validate.reqInteger  (patID,      Messages.INVALID_PAT_ID);
      DateTime  vStartDate   = Validate.reqDate     (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      DateTime  vEndDate     = Validate.reqDate     (endDate,    Messages.INVALID_END_DATE);
      
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,    vClientID,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@patID",      SqlDbType.BigInt,    vPatID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",  SqlDbType.DateTime,  vStartDate,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",    SqlDbType.DateTime,  vEndDate,    ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , active
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }

    /***************************************************************************
     * loadAllRecords */
    /**    
     *
     ***************************************************************************/

    public static List<TransportationMgmtServiceRecordReviewDetail> loadAllRecords (  SqlConnection connSpedmon
                                                                                    , DetailsLog    log
                                                                                    , UserInfo      uInfo
                                                                                    , string        clientID
                                                                                    , string        patID
                                                                                    , string        dosRange) 
    {
      
      List<TransportationMgmtServiceRecordReviewDetail> listItems = new List<TransportationMgmtServiceRecordReviewDetail>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (TransportationMgmtServiceRecordReviewDetail)
                                      , delegate { 
                                        return TransportationMgmtServiceRecordReview.view ( connSpedmon
                                                                                           , log
                                                                                           , uInfo
                                                                                           , Entities.REC_VIEW_ALL
                                                                                           , false
                                                                                           , ""
                                                                                           , ""
                                                                                           , "Y"                                                                                 
                                                                                           , clientID
                                                                                           , patID
                                                                                           , dosRange
                                                                                           , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          TransportationMgmtServiceRecordReviewDetail listItem = (TransportationMgmtServiceRecordReviewDetail) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
   
    /***************************************************************************
     * loadServiceRecordReviewDetails */
    /**
     *
     **************************************************************************/  

    public static ReturnTransMgmtManageServiceRecordReviewDetails loadServiceRecordReviewDetails (  SqlConnection connSpedmon
                                                                                                  , DetailsLog    log
                                                                                                  , UserInfo      uInfo
                                                                                                  , string        clientID
                                                                                                  , string        patID
                                                                                                  , string        dosRange )
    {      
      ReturnTransMgmtManageServiceRecordReviewDetails rd = new ReturnTransMgmtManageServiceRecordReviewDetails();
      rd.svcRecs = loadAllRecords(connSpedmon, log, uInfo, clientID, patID, dosRange); 
      return rd;
    }
    
    /***************************************************************************
     * saveServiceRecordReviewDetails */
    /**
     *
     **************************************************************************/  
        
    public static ReturnSaveRecord saveServiceRecordReviewDetails (    SqlConnection connSpedmon
                                                                     , DetailsLog    log
                                                                     , UserInfo      uInfo    
                                                                     , string        clientID
                                                                     , string        patID
                                                                     , string        dosRange                                                                      
                                                                     , string        details
                                                                     , string        validateRec ) 
    {
        
      
      ReturnSaveRecord rd = new ReturnSaveRecord();
      
      /*----------------------------
       * Batch save is for new records
       * only so we provide the required
       * values for save here
       *----------------------------*/
      
      string editDelReason  = "";
      string saveType       = Constants.SAVE_TYPE_NEW.ToString();
      string recID          = "";

      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dosRange, out startDate, out endDate);

      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      long     vClientID   = Validate.reqClientID (uInfo, clientID);
      long     vPatID      = Validate.reqInteger  (patID,      Messages.INVALID_PAT_ID);
      DateTime vStartDate  = Validate.reqDate     (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      DateTime vEndDate    = Validate.reqDate     (endDate,    Messages.INVALID_END_DATE);
      
      /*----------------------------
       * Create additional validation
       * steps for the following 
       * reqObject validation check.
       *----------------------------*/

      AdditionalValidation av = delegate(Object o){
        
        /*-------------------------------
         * Cast o to review details
         *-------------------------------*/ 

        TransportationMgmtServiceRecordReviewDetails vDetails = (TransportationMgmtServiceRecordReviewDetails) o;

        /*-------------------------------
         * Perform range checks on 
         * dates and minutes and check
         * patient absent flag
         *-------------------------------*/ 
        
        int  rowNum = 1;

        foreach (TransportationMgmtServiceRecordReviewDetail vDetail in vDetails.details)
        {                
          bool? vOkToBill = Util.evaluateFlag (vDetail.okToBill, true);                                                            
          rowNum++;
        }
      };      
           
      /*----------------------------
       * Parse and convert details
       * string (JSON) to object 
       * 
       * Note: The parsing will
       * peform datatype validation
       *----------------------------*/

      TransportationMgmtServiceRecordReviewDetails vSvcRecReviewDetails = (TransportationMgmtServiceRecordReviewDetails) Validate.reqObject (details, Messages.INVALID_SVC_REC_DETAIL , "Spedmon", "Spedmon.TransportationMgmtServiceRecordReviewDetails", av);
                       
      List<SqlParameter> parms = new List<SqlParameter>();
           
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,    vClientID,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@patID",      SqlDbType.BigInt,    vPatID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",  SqlDbType.DateTime,  vStartDate,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",    SqlDbType.DateTime,  vEndDate,    ParameterDirection.Input));
      
      parms.Add(Database.SqlParmDataTable <TransportationMgmtServiceRecordReviewDetail> ("@svcDetails", vSvcRecReviewDetails.details, "TransportationMgmtServiceRecordReviewDetails"));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      
      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE", @"Review details have already been saved", ref parms,
        delegate()
        {
          // Note: No additional validation steps needed
        });      
      
    }    
  }
}