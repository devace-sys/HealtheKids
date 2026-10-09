using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using System.IO;
using EAW.MediaFile;

namespace Spedmon
{
  /***************************************************************************
   * StoredFile */
  /**
   *
   ***************************************************************************/
   
  public class StoredFile : StoredFileRecord
  {
    public static string DEFAULT_PAGING_ORDER = @"fileUploadOn desc";

    public DateTime fileUploadOn;
    public string   fileUploadOnStr;
    public string   fileClassName;
    public string   fileUploadByEmail;
    public string   description;
    public string   fileSizeHuman;
    public string   clientName;
    public string   pracName;
    public long     patID;
    public string   patName;
    public bool     isConfidentialPracticeFile;
    public string   isConfidentialPracticeFileStr;
    public string   fileMimeType;  
    public string   fileSubClass;
    public string   ourFileName;
    public long     userID;    
    public long     fileClassID;
    public bool     okToShareFileWithParentGuardian;
    public string   okToShareFileWithParentGuardianStr;
    public bool     okToShareFileWithPatient;
    public string   okToShareFileWithPatientStr;
  }
  
  /***************************************************************************
   * StoredFiles */
  /**
   *
   ***************************************************************************/
  
  public class StoredFiles:MBA.StoredFiles
  {
         
    public const string SEL_LABEL                = @"Stored Files";
    public const string SEL_LABEL_MANAGE         = SEL_LABEL + @" - Manage";
    public const string URL_REST_VIEW            = @"api/v1/storedfiles";
    public const string URL_BATCH_DOWNLOAD       = @"storedfiledownload.ashx";     
        
    public static string URL_WEB_SVC_DELETE_BASE                   = StoredFiles.URL_WEB_SVC + @"/deleteinline";
    public static string URL_WEB_SVC_FLAG_AS_CONFIDENTIAL_BASE     = StoredFiles.URL_WEB_SVC + @"/flagasconfidentialinline";
    public static string URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL_BASE = StoredFiles.URL_WEB_SVC + @"/flagasnonconfidentialinline";

    public static string URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT_BASE   = StoredFiles.URL_WEB_SVC + @"/enablefilesharingwithpatient";
    public static string URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT_BASE  = StoredFiles.URL_WEB_SVC + @"/disablefilesharingwithpatient";
    public static string URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT_BASE    = StoredFiles.URL_WEB_SVC + @"/enablefilesharingwithparentguardian";
    public static string URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT_BASE   = StoredFiles.URL_WEB_SVC + @"/disablefilesharingwithparentguardian";
    
        
   /***************************************************************************
    * URL_DOWNLOAD_HANDLER_PRIVATE_BASE */
   /**
    * 
    **************************************************************************/
  
   public static string URL_DOWNLOAD_HANDLER_PRIVATE_BASE()
   {
     return MBA.HttpApplication.createLink(StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE, true);
   }

   /***************************************************************************
    * URL_WEB_REPORT_BASE */
   /**
    * 
    **************************************************************************/
       
   public static string URL_WEB_REPORT_BASE()
   {
     return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_RPT, true);
   }
   
   /***************************************************************************
    * URL_REST_VIEW_BASE */
   /**
    * 
    **************************************************************************/
    public static string URL_REST_VIEW_BASE()
    {
      return MBA.HttpApplication.createLink(StoredFiles.URL_REST_VIEW, true);
    }    
   
   /***************************************************************************
    * URL_WEB_SVC_VIEW_SEL_BASE */
   /**
    * 
    **************************************************************************/
    public static string URL_WEB_SVC_VIEW_SEL_BASE()
    {
      return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_VIEW_SEL, true);
    }    
   
    /***************************************************************************
     * URL_BATCH_DOWNLOAD_BASE */
    /**
     * 
     **************************************************************************/
   
    public static string URL_BATCH_DOWNLOAD_BASE()
    { 
       return MBA.HttpApplication.createLink(StoredFiles.URL_BATCH_DOWNLOAD, true);
    }

    /***************************************************************************
     * SEL_LABEL_UPLOAD_WORK_BATCHES */
    /**
     * 
     **************************************************************************/
    
    public static string SEL_LABEL_UPLOAD_WORK_BATCHES = @"Upload Practitioner or Transportation Service Logs";

    /***************************************************************************
     * URL_UPLOAD_WORK_BATCHES */
    /**
     * 
     **************************************************************************/

    public static string URL_UPLOAD_WORK_BATCHES = @"user_all_stored_files_upload_files_from_client-work-batches.aspx";

    /***************************************************************************
     * URL_UPLOAD_WORK_BATCHES_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_UPLOAD_WORK_BATCHES_BASE()
    {
      return MBA.HttpApplication.createLink(StoredFiles.URL_UPLOAD_WORK_BATCHES, true, new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));
    }

    /***************************************************************************
     * URL_UPLOAD_STUDENT_DATA_FILES */
    /**
     * 
     **************************************************************************/

    public static string URL_UPLOAD_STUDENT_DATA_FILES = @"fileuploadsprivate.ashx";

    /***************************************************************************
     * URL_UPLOAD_STUDENT_DATA_FILES_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_UPLOAD_STUDENT_DATA_FILES_BASE()
    {
      return MBA.HttpApplication.createLink(StoredFiles.URL_UPLOAD_STUDENT_DATA_FILES, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_DELETE */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_DELETE()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_DELETE_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_FLAG_AS_CONFIDENTIAL */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT */
    /**
     ***************************************************************************/
    public static string URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()
    {
       return MBA.HttpApplication.createLink(StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT_BASE, true);
    }

    /***************************************************************************
     * load */
    /**
     * Load entity
     * 
     * @return                StoredFile
     ***************************************************************************/

    public static StoredFile load (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        recID
      , bool          assumeUserCanView = false)
      
    {      
      return (StoredFile) Entities.load(connSpedmon, log, uInfo, recID, typeof(StoredFile),
      delegate { return StoredFiles.view (connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", "", "", "", "", null, assumeUserCanView); });      
    } 
    
    /***************************************************************************
     * retrieve */
    /**
     * Load entity
     * 
     * @return                StoredFile
     ***************************************************************************/
    
    public static ReturnStoredFileRecord retrieve ( StoredFileRecord sfr )      
    {
      ReturnStoredFileRecord so = new ReturnStoredFileRecord();
      if (sfr is null) throw new Critical(@"File not found");        
      so.storedFileRecord         = sfr;      
      so.storedFileRecordFound    = true;
      so.storedFileTargetFound    = false;            
      
	  so.storedFileRecordID       = so.storedFileRecord.id.ToString();
      so.storedFileTargetLocation = System.IO.Path.Combine(so.storedFileRecord.fileRoot,so.storedFileRecord.filePath,so.storedFileRecord.fileName);
      so.storedFileTargetFound    = System.IO.File.Exists(so.storedFileTargetLocation);

      if (!so.storedFileTargetFound) throw new Critical(@"File not found");

      so.storedFileTarget                  = new StoredFileTarget();
      so.storedFileTarget.id               = so.storedFileRecord.fileId;
      so.storedFileTarget.fullPathFileName = so.storedFileTargetLocation;
      so.storedFileTarget.mfi              = new MediaFileInfo(so.storedFileTargetLocation);      

	  return so;    
    }

   public static ReturnStoredFileRecord retrieve ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        recID
      , bool          assumeUserCanView = false)
      
    {

      StoredFileRecord sfr = null;
        
      try
      {      
        sfr = load(connSpedmon,log,uInfo,recID, assumeUserCanView);
      }
      catch
      {
         sfr = null;
      }

      return retrieve(sfr);            
    }
    
    public static ReturnStoredFileRecord retrieveOld ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        recID
      , bool          assumeUserCanView = false)
      
    {


      ReturnStoredFileRecord so = new ReturnStoredFileRecord();
            
      so.storedFileRecord       = new StoredFileRecord();                       
      so.storedFileRecordFound  = false;              
      so.storedFileTargetFound  = false;
        
      try
      {      
        so.storedFileRecord = load(connSpedmon,log,uInfo,recID, assumeUserCanView);
      }
      catch
      {
        throw new Critical(@"File not found");
      }
      
      so.storedFileRecordFound    = true;
	  so.storedFileRecordID       = so.storedFileRecord.id.ToString();
      so.storedFileTargetLocation = so.storedFileRecord.fileRoot + so.storedFileRecord.filePath + so.storedFileRecord.fileName;
      so.storedFileTargetFound    = System.IO.File.Exists(so.storedFileTargetLocation);

      if (!so.storedFileTargetFound) throw new Critical(@"File not found");

      so.storedFileTarget                  = new StoredFileTarget();
      so.storedFileTarget.id               = so.storedFileRecord.fileId;
      so.storedFileTarget.fullPathFileName = so.storedFileTargetLocation;
      so.storedFileTarget.mfi              = new MediaFileInfo(so.storedFileTargetLocation);      

	  return so;    
    }
    
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        pracID
      , string        patID
      , string        referencedEntityID 
      , string        fileClass
      , string        fileDateRange
      , string        fileNameSpace
      , string        fileSource )
      
    {
    
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        
        ss.addDisplayColumn("rowOrder", true);
        ss.addDisplayColumn("id");        

        ss.addDisplayColumn("fileUploadOnStr   as [Uploaded On]");
        ss.addDisplayColumn("fileSizeHuman     as [File Size]");
        ss.addDisplayColumn("label             as [File Name]");             
        
        ss.addDisplayColumnIfParmValueIsNull("fileClassName as [Information in File]", "@fileClass", ref parms);
        ss.addDisplayColumnIfParmValueIsNull("clientName as [Client]",                 "@clientID",  ref parms);
        ss.addDisplayColumnIfParmValueIsNull("pracName as [Practitioner]",             "@pracID",    ref parms);
        ss.addDisplayColumnIfParmValueIsNull("patName  as [Patient]",                  "@patID",     ref parms);
        
        ss.addDisplayColumn("description       as [Upload Description]");
        ss.addDisplayColumn("isConfidentialPracticeFileStr as [Confidential]");
        ss.addDisplayColumn("okToShareFileWithParentGuardianStr as [Share With Parent Guardian]");
        ss.addDisplayColumn("okToShareFileWithPatientStr as [Share With Patient]");

        ss.addDisplayColumn("fileUploadByEmail as [Uploaded By]");
       
        if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
        {          
          ss.addDisplayColumn("fileSubClass as [Type of Information]");
          ss.addDisplayColumn("ourFileName as [SpEdCare File Name]");
        }
        ss.addDisplayColumn("fileMimeType as [File MIME Type]");
        ss.addDisplayColumn("id as [SpEdCare File ID]");
                         
        pageroworder = ss.pageRowOrder();
      };

      
      /*----------------------------
       * Title and footer
       *----------------------------*/
                   
      string tableName   = "Files Sent to SpEdcare";
      string tableFooter = Messages.CONFIDENTIAL;
      
      if ( ! Util.IsNullOrEmpty (clientID) )
      {
         Client c = Clients.load(connSpedmon,log,uInfo,clientID);
         tableName = tableName + " - " + c.name;
      }
     
     if ( !Util.IsNullOrEmpty (fileClass) )
     {
       FileClass fc = FileClasses.load(connSpedmon,log,uInfo,fileClass);
       tableName = tableName + " - " + fc.name;
     }
     
     if ( !Util.IsNullOrEmpty (pracID) )
     {
        Practitioner prac = Practitioners.load ( connSpedmon, log, uInfo, pracID );
        tableName = tableName + " - " + prac.name;
     }
     
     if ( !Util.IsNullOrEmpty (patID) )
     {
       Patient pat = Patients.load ( connSpedmon, log, uInfo, patID );
       tableName = tableName + " - " + pat.name;
     }
     
     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return StoredFiles.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, pracID, patID, referencedEntityID, fileClass, fileDateRange, fileNameSpace, fileSource, dc); },tableName, tableFooter);
   
      
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , bool          top
                                       , string        topSize
                                       , string        clientID
                                       , string        pracID
                                       , string        patID
                                       , string        referencedEntityID
                                       , string        fileClass
                                       , string        fileNameSpace
                                       , string        fileSource
                                       , string        term /* TODO: Implement filter*/)
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          
         string ctx1 =    @"context1 = fileClassName";                                      
         ss.addDisplayColumn(ctx1);

        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return StoredFiles.view ( connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_SEL
                                                              , top
                                                              , topSize
                                                              , ""
                                                              , "Y"
                                                              , clientID
                                                              , pracID
                                                              , patID
                                                              , referencedEntityID
                                                              , fileClass
                                                              , ""
                                                              , fileNameSpace
                                                              , fileSource
                                                              , dc); 
                                });
                                                                    
    }

    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/      
    public static ReturnDB view (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        pracID
      , string        patID
      , string        referencedEntityID
      , string        fileClass
      , string        fileDateRange
      , string        fileNameSpace
      , string        fileSource
      , defineCols    dc
      , bool assumeUserCanView = false)  
    
    {
       
      string viewUDF = "dbo.STORED_FILE_VIEW (@userId,@userGroup,@userRank,@environmentID,@clientID,@pracID,@patID,@referencedEntityID,@fileClass,@startDate,@endDate,@fileNameSpace,@fileSource,@recID,@assumeUserCanView)";

      /*-------------------------------
       * Parse date range into
       * start and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(fileDateRange, out startDate, out endDate);  

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long    vEnvironmentID      = Constants.STORED_FILES_APP_ENVIRONMENT;

      Object  vClientID           = Validate.optClientID (uInfo, clientID);
      Object  vPracID             = Validate.optInteger  (pracID,              Messages.INVALID_PRAC_ID);
      Object  vPatID              = Validate.optPatID    (uInfo, patID);
      Object  vReferencedEntityID = Validate.optInteger  (referencedEntityID,  @"Invalid entity ID");
      Object  vFileClass          = Validate.optInteger  (fileClass,           Messages.INVALID_FILE_CLASS);
      Object  vStartDate          = Validate.optDate     (startDate,           Messages.INVALID_START_DATE);
      Object  vEndDate            = Validate.optDate     (endDate,             Messages.INVALID_END_DATE);
      string  vFileNameSpace      = Validate.optString   (fileNameSpace,       @"File namespace is invalid");
      string  vFileSource         = Validate.optString   (fileSource,          @"File source is invalid");
                  
      parms.Add(Database.SqlParm("@environmentID",       SqlDbType.Int,      vEnvironmentID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,   vPracID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referencedEntityID",  SqlDbType.BigInt,   vReferencedEntityID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileClass",           SqlDbType.BigInt,   vFileClass,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",           SqlDbType.Date,     vStartDate,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",             SqlDbType.Date,     vEndDate,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileNameSpace",       SqlDbType.VarChar,  vFileNameSpace,      ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@fileSource",          SqlDbType.VarChar,  vFileSource,         ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@assumeUserCanView",   SqlDbType.Bit,      assumeUserCanView,   ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
    
    /***************************************************************************
     * viewInfoTable */
    /**
     ***************************************************************************/  
    public static ReturnInfoTable viewInfoTable (    SqlConnection connSpedmon
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo 
                                                    , string        clientID
                                                    , string        pracID
                                                    , string        patID
                                                    , string        referencedEntityID
                                                    , string        fileClass                                                    
                                                    , string        fileNameSpace
                                                    , string        fileSource)
    {
           
     ReturnInfoTable rd = new ReturnInfoTable();

     /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      string  viewUDF = "STORED_FILE_VIEW_INFO (@userID, @userGroup, @userRank, @environmentID, @clientID, @pracID, @patID, @referencedEntityID, @fileClass, @fileNameSpace, @fileSource)";     
      
      long    vEnvironmentID      = 3;
      Object  vClientID           = Validate.optClientID (uInfo, clientID);
      Object  vPracID             = Validate.optInteger  (pracID,              Messages.INVALID_PRAC_ID);
      Object  vPatID              = Validate.optInteger  (patID,               Messages.INVALID_PAT_ID);
      Object  vReferencedEntityID = Validate.optInteger  (referencedEntityID,  @"Invalid entity ID");
      Object  vFileClass          = Validate.optInteger  (fileClass,           Messages.INVALID_FILE_CLASS);
      string  vFileNameSpace      = Validate.optString   (fileNameSpace,       @"File namespace is invalid");
      string  vFileSource         = Validate.optString   (fileSource,          @"File source is invalid");
            
      parms.Add(Database.SqlParm("@environmentID",       SqlDbType.Int,      vEnvironmentID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,   vPracID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referencedEntityID",  SqlDbType.BigInt,   vReferencedEntityID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileClass",           SqlDbType.BigInt,   vFileClass,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileNameSpace",       SqlDbType.VarChar,  vFileNameSpace,      ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@fileSource",          SqlDbType.VarChar,  vFileSource,         ParameterDirection.Input, 500));
                              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      rd = Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
      
      for (int rowIdx = 0; rowIdx < rd.numRows; rowIdx++)
      {
        /* Build link for file download and replace the file name string with this link */
        string fileName  = rd.rowvalues[rowIdx].values[0];
        string fileRefID = rd.rowvalues[rowIdx].values[4];        
        string fileRefUrl = MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE() + @"&" + MBA.StoredFiles.PARAM_FILE_ID + @"=" + fileRefID;
        string fileRefLnk = String.Format(@"<a title=""Click to Download"" target=""_blank"" href=""{0}"">{1}</a>",fileRefUrl, fileName);
        rd.rowvalues[rowIdx].values[0] = fileRefLnk;
      }
      
      return rd;         
    }

    /***************************************************************************
     * saveBase */
    /**
     * Base method
     * Saves new stored file record in uploads table
     * 
     ****************************************************************************/       
    private static ReturnSaveRecord saveBase (      
        SqlConnection      connSpedmon
      , DetailsLog         log
      , UserInfo           uInfo
      , string             fileClass
      , string             fileSubClass     
      , string             fileDescription
      , string             fileNameSpace
      , string             fileSource
      , string             clientID
      , string             pracID      
      , string             patID
      , string             referencedEntityID
      , string             originalName
      , string             savedName
      , long               fileSize
      , string             fileMimeType
      , string             isConfidentialPracticeFile
      , string             referenceDate1  
      , string             editDelReason
      , string             validateRec
      , string             saveType
      , string             recID )

    {
                        
      long             vFileClass                  = Validate.reqInteger  (fileClass,          @"File class is required");
      long             vClientID                   = Validate.reqClientID (uInfo, clientID);
      bool             vIsConfidentialPracticeFile = Validate.reqFlag     (isConfidentialPracticeFile, "Invalid value for confidential", true);
      
      string           vFileSubClass       = Validate.optString   (fileSubClass,        @"File type is invalid");
      string           vFileDescription    = Validate.optString   (fileDescription,     @"File description is invalid");
      string           vFileNameSpace      = Validate.optString   (fileNameSpace,       @"File namespace is invalid");
      string           vFileSource         = Validate.optString   (fileSource,          @"File source is invalid");           
      Object           vPracID             = Validate.optInteger  (pracID,              @"Invalid practitioner id");
      Object           vPatID              = Validate.optInteger  (patID,               @"Invalid patient id");
      Object           vReferencedEntityID = Validate.optInteger  (referencedEntityID,  @"Invalid entity id");
      Object           vReferenceDate1     = Validate.optDate     (referenceDate1,      @"Invalid date");
      string           vOriginalName       = Validate.reqString   (originalName,        @"Original file name is required");
      string           vSavedName          = Validate.reqString   (savedName,           @"Saved file name is required");
      long             vFileSize           = Validate.reqInteger  (fileSize.ToString(), @"File size is required");            
      string           vFileMimeType       = Validate.reqString   (fileMimeType,        @"File type is required");      
           
      /*----------------------------
       * Populate db parameters
       *----------------------------*/

      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,   vPracID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referencedEntityID",  SqlDbType.BigInt,   vReferencedEntityID, ParameterDirection.Input));
     
      parms.Add(Database.SqlParm("@originalName",    SqlDbType.VarChar,  vOriginalName,       ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@savedName",       SqlDbType.VarChar,  vSavedName,          ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@fileClass",       SqlDbType.BigInt,   vFileClass,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileSubClass",    SqlDbType.VarChar,  vFileSubClass,       ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@fileDescription", SqlDbType.VarChar,  vFileDescription,    ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@fileNameSpace",   SqlDbType.VarChar,  vFileNameSpace,      ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@fileSource",      SqlDbType.VarChar,  vFileSource,         ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@fileSize",        SqlDbType.BigInt,   vFileSize,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileMimeType",    SqlDbType.VarChar,  vFileMimeType,       ParameterDirection.Input, 8000));
      
      parms.Add(Database.SqlParm("@isConfidentialPracticeFile",    SqlDbType.Bit,     vIsConfidentialPracticeFile,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referenceDate1",                SqlDbType.VarChar, vReferenceDate1,               ParameterDirection.Input,1000));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "STORED_FILE_SAVE"
                            , @"Duplicate file" 
                            , ref parms
                            , null );
                     
    }


    /***************************************************************************
     * save */
    /**
     * Saves new stored file passed in HttpFileCollection
     * 
     ****************************************************************************/
         
    public static ReturnSaveRecord save (      
        SqlConnection      connSpedmon
      , DetailsLog         log
      , UserInfo           uInfo
      , string             fileClass
      , string             fileSubClass     
      , string             fileDescription
      , string             fileNameSpace
      , string             fileSource
      , string             clientID
      , string             pracID      
      , string             patID
      , string             referencedEntityID
      , string             isConfidentialPracticeFile
      , string             referenceDate1
      , HttpFileCollection files
      , string             editDelReason
      , string             validateRec
      , string             saveType
      , string             recID )

    {
                              

      PostedFile postedFile       = null;
      bool       fileSavedToDisk  = false;
      
      try 
      {               

        fileSavedToDisk = false;
        var postedFiles = MBA.PostedFiles.getFilesPosted(files);        
        if (postedFiles.Count == 0) throw new MBA.Critical("File expected or non empty file expected");
        if (postedFiles.Count > 1)  throw new MBA.Critical("Only one file allowed");
        postedFiles = MBA.PostedFiles.saveFilesPosted(files);              
        fileSavedToDisk = true;
        postedFile = postedFiles[0];

        return saveBase (  connSpedmon
                         , log
                         , uInfo
                         , fileClass
                         , fileSubClass
                         , fileDescription
                         , fileNameSpace
                         , fileSource
                         , clientID
                         , pracID
                         , patID
                         , referencedEntityID                   
                         , postedFile.uploadedAs
                         , postedFile.savedAs  
                         , postedFile.fileSize
                         , postedFile.mimeType
                         , isConfidentialPracticeFile
                         , referenceDate1
                         , editDelReason
                         , validateRec
                         , saveType
                         , recID );
      }

      catch (Exception e) 
      {
     
        /* If we saved the physical file but something went wrong after delete it
          * Note the System.IO.File.Delete only works with single files so this guards against wildcards.*/

        if (fileSavedToDisk == true) System.IO.File.Delete (postedFile.savedIn);
                
        /* Reraise error so caller can deal with it */

        throw new Critical(e.Message);        
                     
      }
    }

    /***************************************************************************
     * save */
    /**
     * Saves new stored file from ReturnFileBytes
     * 
     * This is for saving internally generated files in the same place
     * as file uploads.  They will be treated as file uploads.
     ****************************************************************************/

    public static ReturnSaveRecord save (      
        SqlConnection      connSpedmon
      , DetailsLog         log
      , UserInfo           uInfo
      , string             fileClass
      , string             fileSubClass     
      , string             fileDescription
      , string             fileNameSpace
      , string             fileSource
      , string             clientID
      , string             pracID      
      , string             patID
      , string             referencedEntityID
      , ReturnFileBytes    fileIn        
      , string             editDelReason
      , string             validateRec
      , string             saveType
      , string             recID )

    {
      
      bool   fileSavedToDisk  = false;
      string savefile         = "";

      try 
      {
        fileSavedToDisk = false;                     
        string uniqfile = PostedFiles.createUniqueFilenameFromOriginalPostedFilename (0,fileIn.fileName);
        savefile = PostedFiles.createSavedFolderFilename  (Constants.FILE_UPLOAD_PATH, uniqfile);              
        System.IO.File.WriteAllBytes (savefile, fileIn.fileBytes);
        fileSavedToDisk = true;        
        var fi = new System.IO.FileInfo (savefile);        
        long fileSizeNew = fi.Length;
        string fileMimeTypeNew = MediaFileCommon.GetMIMETypeFromFilename(fi.Name);
        
        return saveBase (  connSpedmon
                         , log
                         , uInfo
                         , fileClass
                         , fileSubClass
                         , fileDescription
                         , fileNameSpace
                         , fileSource
                         , clientID
                         , pracID
                         , patID
                         , referencedEntityID                         
                         , fileIn.fileName
                         , uniqfile
                         , fileSizeNew
                         , fileMimeTypeNew
                         , "N"
                         , ""
                         , editDelReason
                         , validateRec
                         , saveType
                         , recID );
       }                                   
       catch (Exception e) 
       {
     
         /* If we saved the physical file but somethine went wrong after delete it
          * Note the System.IO.File.Delete only works with single files so this guards against wildcards.*/

         if (fileSavedToDisk == true) System.IO.File.Delete (savefile); 
                
         /* Reraise error so caller can deal with it */

          throw new Critical(e.Message);        
        }
     }
    
    /*************************************************************************
     * viewList */
    /**
     * Return a list of Stored File records
     * 
     ***************************************************************************/

    public static List<StoredFile> viewList(  SqlConnection connSpedmon
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        clientID
                                             , string        pracID
                                             , string        patID
                                             , string        referencedEntityID
                                             , string        active)
      
     {
        var recs = new List<StoredFile>();
        ReturnDB rd = StoredFiles.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, pracID, patID,referencedEntityID, "", "", null, null, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(StoredFile));
        foreach (var o in slo) {
            recs.Add((StoredFile) o);
        }
        return recs;
    }
    
   /*************************************************************************
     * viewObjects */
    /**
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , bool         pageObjectList
                                              , string       pageOrder
                                              , string       idx
                                              , string       active
                                              , string       clientID
                                              , string       pracID
                                              , string       patID
                                              , string       referencedEntityID
                                              , string       fileClass 
                                              , string       fileDateRange
                                              , string       fileNameSpace
                                              , string       fileSource )
      
    {

       /* Default page order */
 
       if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = StoredFile.DEFAULT_PAGING_ORDER;
 
       /* Define columns delegate is used to specify columns and page order 
        * We pass in the desired page row order here */
 
       defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
       {
          pageroworder = pageOrder;
       };
 
       return Entities.viewObjects( connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(StoredFile)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return StoredFiles.view (   connSpedmon
                                                                  , log
                                                                  , uInfo
                                                                  , Entities.REC_VIEW_OBJECTS
                                                                  , pageObjectList
                                                                  , idx
                                                                  , "" /* Can edit */
                                                                  , active
                                                                  , clientID
                                                                  , pracID
                                                                  , patID
                                                                  , referencedEntityID
                                                                  , fileClass
                                                                  , fileDateRange
                                                                  , fileNameSpace
                                                                  , fileSource
                                                                  , dc
                                                                  , false );
									  });

    }

   /*************************************************************************
    * delete */
   /**
    * Delete (deactivate)
    * 
    ***************************************************************************/

    public static ReturnSaveRecord delete (
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      /* Note: Only the author of the record can delete and this is enforced in the delete sproc */
     
      /*----------------------------
       * Call base method 
       *----------------------------*/

      var parms = new List<SqlParameter>();
      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_DELETE", ref parms);
    }

   /*************************************************************************
    * flagAsConfidential */
   /**
    * Flag as confidential
    * 
    ***************************************************************************/

    public static ReturnSaveRecord flagAsConfidential (
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      /* Note: Only the author of the record can change this value and this is enforced in the op sproc */
     
      /*----------------------------
       * Call base method 
       *----------------------------*/

      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_FLAG_AS_CONFIDENTIAL", ref parms);
    }

   /*************************************************************************
    * flagAsNonConfidential */
   /**
    * Flag as non confidential
    * 
    ***************************************************************************/

    public static ReturnSaveRecord flagAsNonConfidential (
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      /* Note: Only the author of the record can change this value and this is enforced in the op sproc */
     
      /*----------------------------
       * Call base method 
       *----------------------------*/

      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_FLAG_AS_NON_CONFIDENTIAL", ref parms);
    
     }
     
     /*************************************************************************
      * generatePDFViewerURL */
     /**
      * Generate url used for internal pdf viewer
      * the file parameter added uses the stored file download handler
      ***************************************************************************/

     public static string generatePDFViewerURL (string storedFileID)
     {
       string pdfFileValue  = MBA.HttpApplication.createLink (URL_DOWNLOAD_HANDLER_PRIVATE
                                                             , true
                                                             , new NameValue(PARAM_FILE_ID,storedFileID));
        return MBA.HttpApplication.createLink (  StoredFiles.PDF_VIEWER_URL_BASE
                                               , false
                                               , new NameValue(@"file",pdfFileValue));

     }
     
     /*************************************************************************
      * generatePDFViewerURL */
     /**
      * Generate url used for internal pdf viewer
      *
      * Just provides a server specific url to the pdf viewer with no file
      * parameter.
      * 
      * User can access the PDF viewer itself using the PDFViewerApplication
      * instance in the window or iframe that opens the PDF.  For example
      * $iframePDFViewer.contentWindow.PDFViewerApplication.open()
      ***************************************************************************/
     public static string generatePDFViewerURL()
     {
      return MBA.HttpApplication.createLink (  StoredFiles.PDF_VIEWER_URL_BASE
                                               , false                                                
                                            );

     }

    /*************************************************************************
     * EnableFileSharingWithPatient */
    /**
     * Flag as shared with Patient ON
     * 
     ***************************************************************************/

    public static ReturnSaveRecord EnableFileSharingWithPatient(
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_SHARE_WITH_PATIENT_ON", ref parms);
    }

   /*************************************************************************
    * DisableFileSharingWithPatient */
   /**
    * Flag as shared with Patient OFF
    * 
    ***************************************************************************/

    public static ReturnSaveRecord DisableFileSharingWithPatient(
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      /* Note: Only the author of the record can change this value and this is enforced in the op sproc */
     
      /*----------------------------
       * Call base method 
       *----------------------------*/

      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_SHARE_WITH_PATIENT_OFF", ref parms);
    
     }
     
     /*************************************************************************
     * EnableFileSharingWithParentGuardian */
    /**
     * Flag as shared with Parent/Guardian ON
     * 
     ***************************************************************************/

    public static ReturnSaveRecord EnableFileSharingWithParentGuardian(
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {

      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_SHARE_WITH_PARENT_GUARDIAN_ON", ref parms);
    }

   /*************************************************************************
    * DisableFileSharingWithParentGuardian */
   /**
    * Flag as shared with Parent/Guardia OFF
    * 
    ***************************************************************************/

    public static ReturnSaveRecord DisableFileSharingWithParentGuardian(
         SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       editDelReason
        , string       validateRec
        , string       recID )
    {
      /* Note: Only the author of the record can change this value and this is enforced in the op sproc */
     
      /*----------------------------
       * Call base method 
       *----------------------------*/
      var parms = new List<SqlParameter>();
      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "STORED_FILE_SHARE_WITH_PARENT_GUARDIAN_OFF", ref parms);
    
     }   
  }
}
