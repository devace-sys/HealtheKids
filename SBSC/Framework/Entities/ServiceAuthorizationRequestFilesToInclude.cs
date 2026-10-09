using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{  
  
  /***************************************************************************
   * ServiceAuthorizationRequestFileToInclude */
  /**
   * 
   ***************************************************************************/
  public class ServiceAuthorizationRequestFileToInclude
  {
    public ServiceAuthorizationRequestFileToInclude(){}
    
    public long   id;    
    public string name;
    public string description;
    public long   uploadID;  
  }
  
  /***************************************************************************
   * ServiceAuthorizationRequestFilesToInclude */
  /**
   * 
   ****************************************************************************/
  public class ServiceAuthorizationRequestFilesToInclude:Entities
  {        
    
    /***************************************************************************
     * view */
    /**
     * View 
     * 
     * @return            ReturnDB
     ***************************************************************************/   
    
	public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , string        clientID
                                 , string        requestID
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active                                      
                                 , defineCols    dc )
    {

      
            
      string viewUDF = "dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW (@userID, @userGroup, @userRank, @clientID, @requestID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

       Object  vClientID  = Validate.optClientID (uInfo, clientID);
       long    vRequestID = Validate.reqInteger  (requestID, @"Invalid service authorization request id");

       var parms = new List<SqlParameter>();   

       parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
       parms.Add(Database.SqlParm("@requestID",  SqlDbType.BigInt,  vRequestID, ParameterDirection.Input));

       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/

       return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
     }
   
     /***************************************************************************
      * viewList */
     /**
      * View list 
      * 
      ***************************************************************************/   

     public static List<ServiceAuthorizationRequestFileToInclude> viewList (   SqlConnection connSpedmon
                                                                             , DetailsLog    log
                                                                             , UserInfo      uInfo
                                                                             , string clientID
                                                                             , string requestID )
     {
       var recs = new List<ServiceAuthorizationRequestFileToInclude>();

       var rd = ServiceAuthorizationRequestFilesToInclude.view(connSpedmon, log, uInfo, clientID, requestID, Entities.REC_VIEW_RAW, false, null, null, null, null);

       List<Object> slo = Database.convertRecordsToList (ref rd.records, typeof(ServiceAuthorizationRequestFileToInclude));
       
       foreach (var o in slo) {
         recs.Add((ServiceAuthorizationRequestFileToInclude) o);
       }
       return recs;
     }
    
     /***************************************************************************
      * updateList */
     /**
      * Updates existing request with a new list
      ****************************************************************************/
     public static ReturnDB updateList (   SqlConnection  connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        requestID
                                         , string        selectedFileList )
     {
 
        /*###########################################################################
          # Validate parameters specific to this entity save and create their 
          # database parameters
          ###########################################################################*/

        long   vRequestID        = Validate.reqInteger  (requestID,        @"Invalid authorization request");
        string vSelectedFileList = Validate.optString   (selectedFileList, @"Invalid file list");  

        var parms = new List<SqlParameter>();
        
        Entities.validateAndAddCommonUserInfoParameters(uInfo, ref parms);
        parms.Add(Database.SqlParm("@requestID",        SqlDbType.BigInt,  vRequestID,        ParameterDirection.Input));
        parms.Add(Database.SqlParm("@selectedFileList", SqlDbType.VarChar, vSelectedFileList, ParameterDirection.Input,-1));

        var rd = Database.execSproc(connSpedmon, log, @"dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES", parms);
        return rd;
     }

        /***************************************************************************
         * generateContentIncludeList */
        /**
         * Generates the list of included files (if any)
        ****************************************************************************/
        public static string generateContentIncludeList (  SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string clientID
                                                      , string requestID ) 
    {
      var cssCommon            = @"svc-auth-request-files";
      var cssNoFiles           = @"svc-auth-request-files-none";
      var includedFiles        = ServiceAuthorizationRequestFilesToInclude.viewList(connSpedmon, log, uInfo, clientID, requestID);
      var fileDownloadBaseUrl  = MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE() + @"&" + MBA.StoredFiles.PARAM_FILE_ID + @"="; 
      if (includedFiles.Count == 0) return String.Format(@"<div class=""{0} {1}"">None</div>",cssCommon,cssNoFiles); 
      var sb = new StringBuilder();           
      sb.AppendFormat(@"<ul class=""{0}"">",cssCommon);            
      foreach (var includedFile in includedFiles) 
      {            
        sb.AppendFormat(@"<li class=""{0}"">",cssCommon);
        sb.AppendFormat(@"<a class=""{0}"" title=""{1}"" target=""_blank"" href=""{2}{3}"" download><i class=""{0} fa fa-file""></i><span class=""{0}"">{4}</span></a>"
                        , cssCommon
                        , includedFile.description
                        , fileDownloadBaseUrl
                        , includedFile.uploadID
                        , includedFile.name);
        sb.AppendFormat(@"</li>");
      }
      sb.Append(@"</ul>");                  
      return sb.ToString();
    }
    

   } 
}