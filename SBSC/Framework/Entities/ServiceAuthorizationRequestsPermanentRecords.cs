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
   * ServiceAuthorizationRequestPermanentRecord */
  /**
   * 
   **************************************************************************/
  public class ServiceAuthorizationRequestPermanentRecord: Entity
  {
      public long     clientID;
      public long     pracID;    
      public long     orpPracID;
      public long     patID;     
      public long     groupSvcClassNameID;
      public long     fileClass;
	    public string   fileNameSpace;
	    public string   fileSource;
      public long     requestID;
      public long     uploadID;	  
      public DateTime created;
      public long     createdBy;
      public DateTime lastModified;
      public long     lastModifiedBy;    
      public long     referencedEntityID;
  }
          
  /***************************************************************************
   *  ServiceAuthorizationRequestsPermanentRecords */
  /**
   * 
   **************************************************************************/

  public class ServiceAuthorizationRequestsPermanentRecords:Entities
  {                    
    /***************************************************************************
     * save */
    /**
     * Save new or update existing record
     *
     ***************************************************************************/     
    public static ReturnSaveRecord setFileUploadPending (  SqlConnection connSpedmon                                                           
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , string        fileUploadPending
                                                            , string        uploadID
                                                            , string        editDelReason
                                                            , string        validateRec                                                     
                                                            , string        recID )
    {           
                               
      bool vFileUploadPending  = Validate.reqFlag      (fileUploadPending,  @"Invalid value for file upload pending");
      Object  vUploadID        = Validate.optInteger   (uploadID,           @"Invalid upload id");
             
      List<SqlParameter> parms = new List<SqlParameter>();     

      parms.Add(Database.SqlParm("@fileUploadPending",    SqlDbType.Bit,     vFileUploadPending,    ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@fileUploadID",         SqlDbType.BigInt,  vUploadID,             ParameterDirection.Input));

      return Entities.recordOp (  connSpedmon
                                , log
                                , uInfo
                                , editDelReason
                                , validateRec
                                , recID
                                , "SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING"
                                , ref parms );
      
     } 

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
                                  , string        systemWillGenerateFileUpload
                                  , string        fileUploadPending
                                  , string        requestID
                                  , string        uploadID
                                  , defineCols    dc )
    {
    
      string viewUDF = "dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW (@userID, @userGroup, @userRank, @systemWillGenerateFileUpload, @fileUploadPending, @requestID, @uploadID, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/         	          
                  
      Object  vSystemWillGenerateFileUpload = Validate.optFlag      (systemWillGenerateFileUpload,  @"Invalid value for system will generate file upload");
      Object  vFileUploadPending            = Validate.optFlag      (fileUploadPending,             @"Invalid value for file upload pending");
      Object  vRequestID                    = Validate.optInteger   (requestID,                     @"Invalid request id");
      Object  vUploadID                     = Validate.optInteger   (uploadID,                      @"Invalid upload id");
   
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@systemWillGenerateFileUpload",    SqlDbType.Bit,     vSystemWillGenerateFileUpload,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileUploadPending",               SqlDbType.Bit,     vFileUploadPending,              ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@requestID",                       SqlDbType.BigInt,  vRequestID,                      ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@uploadID",                        SqlDbType.BigInt,  vUploadID,                       ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }
    
    /***************************************************************************
     * viewDataList */
    /**
     * 
     **************************************************************************/  

    public static List<ServiceAuthorizationRequestPermanentRecord> viewDataList (  SqlConnection connSpedmon
                                                                                 , DetailsLog    log
                                                                                 , UserInfo      uInfo
                                                                                 , string        canEdit
                                                                                 , string        active
                                                                                 , string        systemWillGenerateFileUpload
                                                                                 , string        fileUploadPending
                                                                                 , string        requestID
                                                                                 , string        uploadID
                                                                                 , string        recID )
    
    {
      List<ServiceAuthorizationRequestPermanentRecord> rl = new List<ServiceAuthorizationRequestPermanentRecord>();

      ReturnDB rd = view (  connSpedmon
                           , log
                           , uInfo
                           , REC_VIEW_RAW
                           , false
                           , recID
                           , canEdit
                           , active
                           , systemWillGenerateFileUpload
                           , fileUploadPending
                           , requestID
                           , uploadID
                           , null);
     
      Object[] ol = Database.convertRecords(rd.records, typeof(ServiceAuthorizationRequestPermanentRecord));
      
      foreach (Object o in ol)
      {
        ServiceAuthorizationRequestPermanentRecord r = (ServiceAuthorizationRequestPermanentRecord) o;
        rl.Add(r);
      }
      return rl;
    }

             
  }
}
