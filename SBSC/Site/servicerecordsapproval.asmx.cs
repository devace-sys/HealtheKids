using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ServiceRecordsApprovalSvc */
  /*
   * Web services end point for Service Record Approvals
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class ServiceRecordsApprovalSvc: MBA.WebSvc
  {

    /***************************************************************************
     * opassignsupervisorbypracid */
    /**
     * Assign supervisor
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opaassignsupervisor (
      string validaterec,
      string recid )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApprovalSupervisors.opAssignOrUnassignSupervisorByPracID (this.dbConnApp, 
                                                                    this.log, 
                                                                    this.uInfo,                                                                    
                                                                    "",
                                                                    validaterec,                                                             
                                                                    recid,
                                                                    "Y");
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    } 
   
    /***************************************************************************
     * opunassignsupervisorbypracid */
    /**
     * Unassign supervisor
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opunassignsupervisor (
      string editDelReason,
      string validaterec,
      string recid )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApprovalSupervisors.opAssignOrUnassignSupervisorByPracID (this.dbConnApp, 
                                                                    this.log, 
                                                                    this.uInfo,                                                                    
                                                                    editDelReason,
                                                                    validaterec,                                                             
                                                                    recid,
                                                                    "N");
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    } 
   

    /***************************************************************************
     * opacceptbatchbypracid */
    /**
     * Accept service record
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opacceptbatchbypracid (
          string editDelReason
        , string validaterec
        , string recid 
        , string siteid  
        , string daterange 
      )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptOrRejectBatchByPracID (  this.dbConnApp
                                                                     , this.log
                                                                     , this.uInfo                                                                    
                                                                     , editDelReason
                                                                     , validaterec                                                            
                                                                     , recid
                                                                     , "Y"
                                                                     , siteid
                                                                     , daterange );
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }    

    /***************************************************************************
     * oprejectbatchbypracid */
    /**
     * Reject
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord oprejectbatchbypracid (
        string editDelReason
      , string validaterec
      , string recid 
      , string siteid  
      , string daterange )        
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptOrRejectBatchByPracID (   this.dbConnApp
                                                                      , this.log
                                                                      , this.uInfo
                                                                      , editDelReason
                                                                      , validaterec                                                            
                                                                      , recid
                                                                      , "N"
                                                                      , siteid  
                                                                      , daterange );
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }    

    
    /***************************************************************************
     * opacceptbatchbysvcrecappid */
    /**
     * Accept 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opacceptbatchbysvcrecappid (
        string editDelReason
      , string validaterec
      , string recidmulti )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptOrRejectBatchBySvcRecApprovalID (this.dbConnApp, 
                                                                    this.log, 
                                                                    this.uInfo,
                                                                    editDelReason,
                                                                    validaterec,                                                                    
                                                                    recidmulti,
                                                                    "Y");
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }

    /***************************************************************************
     * opacceptbatchbysvcrecappidwithnotesandnotification */
    /**
     * Accept 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opacceptbatchbysvcrecappidwithnotesandnotification (
      string editDelReason,
      string validaterec,
      string recidmulti,
      string sendreviewnotestorenderingprac)
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptOrRejectBatchBySvcRecApprovalIDWithNotesAndNotification (this.dbConnApp, 
                                                                    this.log, 
                                                                    this.uInfo,
                                                                    editDelReason,
                                                                    validaterec,                                                                    
                                                                    recidmulti,
                                                                    "Y",
                                                                    sendreviewnotestorenderingprac);
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }

    /***************************************************************************
     * opacceptbatchbysvcjournalid */
    /**
     * Accept 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opacceptbatchbysvcjournalid (
        string editDelReason
      , string validaterec
      , string recid
      , string siteid 
      , string daterange )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptBatchBySvcJournalID (   this.dbConnApp
                                                                    , this.log
                                                                    , this.uInfo
                                                                    , editDelReason
                                                                    , validaterec                                                                   
                                                                    , recid                                                                  
                                                                    , "Y"
                                                                    , siteid 
                                                                    , daterange );
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }

    /***************************************************************************
     * opacceptbatchbypatid */
    /**
     * Accept 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord opacceptbatchbypatid (
        string editDelReason
      , string validaterec
      , string recid
      , string siteid  
      , string daterange 
    )
       
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
        return ServiceRecordsApproval.opAcceptOrRejectBatchByPatID(  this.dbConnApp
                                                                    , this.log
                                                                    , this.uInfo
                                                                    , editDelReason
                                                                    , validaterec                                                                   
                                                                    , recid                                                               
                                                                    , "Y"
                                                                    , siteid
                                                                    , daterange);
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }

    /***************************************************************************
     * oprejectbatchbysvcrecappid */
    /**
     * Reject
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord  oprejectbatchbysvcrecappid (
       string editDelReason,
       string validaterec,
       string recidmulti)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
                                                             
        return ServiceRecordsApproval.opAcceptOrRejectBatchBySvcRecApprovalID (this.dbConnApp, 
                                                                       this.log, 
                                                                       this.uInfo,
                                                                       editDelReason,
                                                                       validaterec,
                                                                       recidmulti,
                                                                       "N");                                                             
                                                             
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    }

    /***************************************************************************
     * loadsvcrecnotes */
    /**
     * 
     ***************************************************************************/    
    /*
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnServiceRecordNote loadsvcrecnotes ( 
      string svcrecid 
    )
       
    {
      return (ReturnServiceRecordNote) 
     
      callMethod(typeof(ReturnServiceRecordNote),       
      delegate()
      {
        return ServiceRecordsNote.load (  this.dbConnApp
                                         , this.log
                                         , this.uInfo
                                         , ""
                                         , svcrecid);
      },
      Constants.ROLE_LEA_PROVIDER);  // Who can call this method           
    } 
    */  
  }
}
