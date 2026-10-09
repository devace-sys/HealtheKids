using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;

namespace Spedmon
{    
  
  /***************************************************************************
   * DataDrivenForm */
  /**
   * Data driven form
   ****************************************************************************/

  public class DataDrivenForm
  {
    public long   formID;
    public string formTitle;
    public string formInstructions;
    public long   startFormPageID;
    public long   endFormPageID;
    public bool   openInNewWindow;
    public bool   active;
  }
  
  /***************************************************************************
   * DataDrivenFormPage */
  /**
   * Data driven form page
   ****************************************************************************/

  public class DataDrivenFormPage
  {
    public long   formID;
    public long   formPageID;
    public string pageType;
    public string formTitle;
    public string pageTitle;
    public string pageInstructions;
    public bool   valid = true;
    public string pageMessageClass;
    public string pageMessageText;  
    public bool   active;    
  }
  
  /***************************************************************************
   * DataDrivenFormPagePart */
  /**
   * Data driven form page part
   ****************************************************************************/

  public class DataDrivenFormPagePart
  {
    public long   formID;
    public long   formPageID;
    public long   formPagePartID; 
    public string partType;
    public string dataType;
    public string id;
    public string name;
    public string label;
    public string placeholder;
    public bool   required;
    public string originalValue;
    public string value;   
    public string min;
    public string max;
    public string step;
    public bool   multiple;
    public string selectFrom;
    public string selectWhat;
    public bool   selectAuto;
    public string selectSourceURL;
    public string selectReqEntId1;
    public string selectReqEntId2;
    public bool   selectReplaceValue;
    public string selectReplaceWhoName;
    public string selectReplaceWhoValue;
    public string selectReplaceWithValue;    
    public string selectedNames;
    public string selectedCount;
    public bool   valid = true;
    public string partMessageClass;
    public string partMessageText;
    public bool   passForward;
    public string selectParmIDSelectedCount;
    public string selectParmNameSelectedCount;
    public string selectParmIDSelectedID;
    public string selectParmNameSelectedNames;
    public bool   active;
    
    public static string generateParmSelectedCount (string idorname)
    {
      return idorname + "-selected-count";
    } 
   
    public static string generateParmSelectedNames(string idorname)
    {
      return idorname + "-selected-names";
    }
   
  }
  
  /***************************************************************************
   * DataDrivenFormPagePartReqEntity */
  /**
   * Data driven form page part
   ****************************************************************************/
   
  public class DataDrivenFormPagePartReqEntity
  {
    public string id;
    public string name;
    public string value;
  }
  
  /***************************************************************************
   * DataDrivenFormRequestStatus */
  /**
   * Status of request
   ****************************************************************************/
        
  public class DataDrivenFormRequestStatus
  {
    public long     prevPageID;
    public long     currPageID;
    public long     nextPageID;
    public bool     complete;
    public DateTime completedOn;
  }
    
  /***************************************************************************
   * DataDrivenForms */
  /**
   * 
   ****************************************************************************/

  public class DataDrivenWebForms:Entities
  {
   
    /***************************************************************************
     * deleteFormForm */
    /**
     * 
     ****************************************************************************/
                
    public static ReturnSaveRecord deleteFormForm (  SqlConnection connSpedmon
                                                   , DetailsLog  log
                                                   , UserInfo    uInfo                                                 
                                                   , string      formRequestID
                                                   , ref HttpContext context)
    {
    
      /*============================================================
       * Delete
       *============================================================*/
       
       List<SqlParameter> parms = new List<SqlParameter>();
       parms.Add(Database.SqlParm("@formRequestID",     SqlDbType.VarChar, formRequestID,     ParameterDirection.Input, 1000));                             
       return Entities.delete(connSpedmon, log, uInfo, "","0","1","FORM_FORM_CANCEL", ref parms);    
    }

   /***************************************************************************
     * completeFormForm */
    /**
     * 
     ****************************************************************************/
                
    public static ReturnSaveRecord completeFormForm (  SqlConnection connSpedmon
                                                   , DetailsLog  log
                                                   , UserInfo    uInfo                                                 
                                                   , string      formRequestID
                                                   , ref HttpContext context)
    {
    
      /*============================================================
       * Complete
       *============================================================*/
       
       List<SqlParameter> parms = new List<SqlParameter>();
       parms.Add(Database.SqlParm("@formRequestID", SqlDbType.VarChar, formRequestID,     ParameterDirection.Input, 1000));                             
       return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             "1", 
                             "0", 
                             "", 
                             "", 
                             "FORM_FORM_COMPLETE", 
                             @"Duplicate form", 
                             ref parms, 
                             null);
    


    }
    
    /***************************************************************************
     * saveFormForm */
    /**
     * 
     ****************************************************************************/
                
    public static ReturnSaveRecord saveFormForm (  SqlConnection   connSpedmon
                                                 , DetailsLog      log
                                                 , UserInfo        uInfo                                                 
                                                 , string          formRequestID
                                                 , long            formDefinitionID
                                                 , ref HttpContext context)
    {
    
      /*============================================================
       * Save 
       *============================================================*/

       List<SqlParameter> parms = new List<SqlParameter>();

       parms.Add(Database.SqlParm("@formRequestID",      SqlDbType.VarChar, formRequestID,                   ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@formDefinitionID",   SqlDbType.BigInt,  formDefinitionID,                ParameterDirection.Input));
       parms.Add(Database.SqlParm("@requestIP",          SqlDbType.VarChar, context.Request.UserHostAddress, ParameterDirection.Input,1000));
       parms.Add(Database.SqlParm("@requestUserAgent",   SqlDbType.VarChar, context.Request.UserAgent,       ParameterDirection.Input,8000));
                             
       return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             "1", 
                             "0", 
                             "", 
                             "", 
                             "FORM_FORM_SUBMIT", 
                             @"Duplicate form", 
                             ref parms, 
                             null);
    
    }
            
    
    /***************************************************************************
     * saveFormPage */
    /**
     * 
     ****************************************************************************/
    
    public static ReturnSaveRecord saveFormPage (SqlConnection connSpedmon
                                                 , DetailsLog  log
                                                 , UserInfo    uInfo                                                 
                                                 , string      formRequestID
                                                 , long        formPageDefinitionID)
    {
    
      /*============================================================
       * Save 
       *============================================================*/

       List<SqlParameter> parms = new List<SqlParameter>();

       parms.Add(Database.SqlParm("@formRequestID",         SqlDbType.VarChar, formRequestID,         ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@formPageDefinitionID",  SqlDbType.BigInt,  formPageDefinitionID,  ParameterDirection.Input));
                        
       return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             "1", 
                             "0", 
                             "", 
                             "", 
                             "FORM_PAGE_SUBMIT", 
                             @"Duplicate form", 
                             ref parms, 
                             null);
    
    }

    /***************************************************************************
     * saveFormPagePart */
    /**
     * 
     ****************************************************************************/

    public static ReturnSaveRecord saveFormPagePart (  SqlConnection connSpedmon
                                                     , DetailsLog  log
                                                     , UserInfo    uInfo                                                 
                                                     , string      formRequestID                                             
                                                     , DataDrivenFormPagePart fpp
                                                     , string uploadFolder
                                                     , ref HttpContext context
                                                    )
    {
      
      string fileMimeType = "";
      long   fileSize     = 0;         
      
      if (fpp.dataType == "file")
      {
        List <string> uniqFiles = new List<string>();       
        List <string> files     = new List<string>();
        
     
        
        List<PostedFile> uploadedFiles = PostedFiles.saveFilesPosted(context.Request.Files,uploadFolder);
        
        foreach(PostedFile uploadedFile in uploadedFiles)
        {
          files.Add     (uploadedFile.uploadedAs);
          uniqFiles.Add (uploadedFile.savedAs);
          fileMimeType  = uploadedFile.mimeType;
          fileSize      = uploadedFile.fileSize;
        }
       
        fpp.originalValue = String.Join(",",files.ToArray());
        fpp.selectedNames = String.Join("|",files.ToArray());
        fpp.selectedCount = uploadedFiles.Count.ToString();
        fpp.value         = String.Join(",",uniqFiles.ToArray());
        
      }

      /*============================================================
       * Save 
       *============================================================*/

       List<SqlParameter> parms = new List<SqlParameter>();

       parms.Add(Database.SqlParm("@formRequestID",            SqlDbType.VarChar, formRequestID,             ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@formPagePartDefinitionID", SqlDbType.BigInt,  fpp.formPagePartID,        ParameterDirection.Input));
       parms.Add(Database.SqlParm("@originalValue",            SqlDbType.VarChar, fpp.originalValue,         ParameterDirection.Input, 8000));
       parms.Add(Database.SqlParm("@value",                    SqlDbType.VarChar, fpp.value,                 ParameterDirection.Input, 8000));
       parms.Add(Database.SqlParm("@selectedCount",            SqlDbType.VarChar, fpp.selectedCount,         ParameterDirection.Input, 8000));
       parms.Add(Database.SqlParm("@selectedNames",            SqlDbType.VarChar, fpp.selectedNames,         ParameterDirection.Input, 8000));
       parms.Add(Database.SqlParm("@fileSize",                 SqlDbType.BigInt,  fileSize,         ParameterDirection.Input));
       parms.Add(Database.SqlParm("@fileMimeType",             SqlDbType.VarChar, fileMimeType,     ParameterDirection.Input, 8000));
                               
       return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             "1", 
                             "0", 
                             "", 
                             "", 
                             "FORM_PAGE_PART_SUBMIT", 
                             @"Duplicate form", 
                             ref parms, 
                             null);
    
    }          


    /***************************************************************************
     * copySubIntoNew */
    /**
     * 
     ****************************************************************************/
                
    public static ReturnSaveRecord copySubIntoNew (  SqlConnection connSpedmon
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo                                                 
                                                    , string        subFormRequestID
                                                    , string        newFormRequestID
                                                    , ref HttpContext context)
    {
    
      /*============================================================
       * Save 
       *============================================================*/

       List<SqlParameter> parms = new List<SqlParameter>();

       parms.Add(Database.SqlParm("@subFormRequestID",  SqlDbType.VarChar, subFormRequestID,                ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@newFormRequestID",  SqlDbType.VarChar, newFormRequestID,                ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@requestIP",         SqlDbType.VarChar, context.Request.UserHostAddress, ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@requestUserAgent",  SqlDbType.VarChar, context.Request.UserAgent,       ParameterDirection.Input, 8000));
                             
       return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             "1", 
                             "0", 
                             "", 
                             "", 
                             "FORM_FORM_COPY_SUBMITTED_INTO_NEW", 
                             @"Duplicate form", 
                             ref parms, 
                             null);
    
    }

    /***************************************************************************
     * loadFormForm */
    /**
     * Requests form
     ***************************************************************************/  
  
    public static DataDrivenForm loadFormForm (SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string formRequestID
										                     , long formDefinitionID)
    {
      DataDrivenForm f = new DataDrivenForm();

      string sql  = @"select * from dbo.FORM_FORM_VIEW (@userID, @userGroup, @userRank, @formRequestID, @formDefinitionID)";
      List <SqlParameter> parms = new List<SqlParameter>();            
      
      parms.Add(Database.SqlParm("@userID",           SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",        SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",         SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@formRequestID",    SqlDbType.VarChar,  formRequestID,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@formDefinitionID", SqlDbType.BigInt,   formDefinitionID, ParameterDirection.Input));                  

      ReturnDB rd = Database.execQuery(connSpedmon ,log, sql, false, parms);
      if (rd.hasRecords == false) return f;
      
      f = (DataDrivenForm) Database.convertRecord(rd.records,typeof(DataDrivenForm));
      
      return f;
    }

    /***************************************************************************
     * loadFormPage */
    /**
     * Requests form
     ***************************************************************************/  
    
    public static DataDrivenFormPage loadFormPage (  SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string formRequestID
	                                                 , long formDefinitionID
												                           , long formPageDefinitionID)
    {
      
      DataDrivenFormPage fp = new DataDrivenFormPage();
      
      string sql = @"select * from dbo.FORM_PAGES_VIEW (@userID, @userGroup, @userRank, @formRequestID, @formDefinitionID, @formPageDefinitionID)";
      
      List <SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@userID",           SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",        SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",         SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@formRequestID",    SqlDbType.VarChar,  formRequestID,    ParameterDirection.Input, 1000));
            
      parms.Add(Database.SqlParm("@formDefinitionID",       SqlDbType.BigInt,  formDefinitionID,     ParameterDirection.Input));                  
      parms.Add(Database.SqlParm("@formPageDefinitionID",   SqlDbType.BigInt,  formPageDefinitionID, ParameterDirection.Input));                  

      ReturnDB rd = Database.execQuery(connSpedmon ,log,sql,false,parms);
      if (rd.hasRecords == false) return fp;
      
      fp = (DataDrivenFormPage) Database.convertRecord(rd.records,typeof(DataDrivenFormPage));

      return fp;
    }

   
    /***************************************************************************
     * loadFormFormPageParts */
    /**
     * Requests form
     ***************************************************************************/  
    
	  public static List<DataDrivenFormPagePart> loadFormPageParts (
	      SqlConnection connSpedmon
      , DetailsLog log
      , UserInfo uInfo
      , string formRequestID
	    , long formDefinitionID
	    , long formPageDefinitionID )
    
    {
      
      List<DataDrivenFormPagePart> fpps = new List<DataDrivenFormPagePart>();      
      string sql = @"select * from dbo.FORM_PAGES_PARTS_VIEW (@userID, @userGroup, @userRank, @formRequestID, @formDefinitionID, @formPageDefinitionID)";
      List <SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@userID",                 SqlDbType.BigInt,   uInfo.userid,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",              SqlDbType.Int,      uInfo.userGroup,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",               SqlDbType.Int,      uInfo.userRank,       ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@formRequestID",          SqlDbType.VarChar,  formRequestID,        ParameterDirection.Input, 1000));            
      parms.Add(Database.SqlParm("@formDefinitionID",       SqlDbType.BigInt,   formDefinitionID,     ParameterDirection.Input));                  
      parms.Add(Database.SqlParm("@formPageDefinitionID",   SqlDbType.BigInt,   formPageDefinitionID, ParameterDirection.Input));                  

      ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);

      if (rd.hasRecords == false) return fpps;
     
      Object ol = Database.convertRecords(rd.records,typeof(DataDrivenFormPagePart));
      
      foreach (Object o in Database.convertRecordsToList(ref rd.records,typeof(DataDrivenFormPagePart)))
      {
        DataDrivenFormPagePart fpp = (DataDrivenFormPagePart) o;
        fpps.Add(fpp);
      }
      
      return fpps;
    }
	   
    /***************************************************************************
     * loadFormFormPagePartsReqEntity */
    /**
     * Requests form
     ***************************************************************************/  
    
	  public static List<DataDrivenFormPagePartReqEntity> loadFormPagePartsReqEntities (
	      SqlConnection connSpedmon
      , DetailsLog log
      , UserInfo uInfo
      , string formRequestID
	    , long formDefinitionID
	    , long formPageDefinitionID )
    
    {
      
      List<DataDrivenFormPagePartReqEntity> fpps = new List<DataDrivenFormPagePartReqEntity>();      
      string sql = @"select * from dbo.FORM_PAGES_PARTS_REQ_ENT_VIEW (@userID, @userGroup, @userRank, @formRequestID, @formDefinitionID, @formPageDefinitionID)";
      List <SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@userID",                 SqlDbType.BigInt,   uInfo.userid,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",              SqlDbType.Int,      uInfo.userGroup,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",               SqlDbType.Int,      uInfo.userRank,       ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@formRequestID",          SqlDbType.VarChar,  formRequestID,        ParameterDirection.Input, 1000));            
      parms.Add(Database.SqlParm("@formDefinitionID",       SqlDbType.BigInt,   formDefinitionID,     ParameterDirection.Input));                  
      parms.Add(Database.SqlParm("@formPageDefinitionID",   SqlDbType.BigInt,   formPageDefinitionID, ParameterDirection.Input));                  

      ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);

      if (rd.hasRecords == false) return fpps;
     
      Object ol = Database.convertRecords(rd.records,typeof(DataDrivenFormPagePart));
      
      foreach (Object o in Database.convertRecordsToList(ref rd.records,typeof(DataDrivenFormPagePartReqEntity)))
      {
        DataDrivenFormPagePartReqEntity fpp = (DataDrivenFormPagePartReqEntity) o;
        fpps.Add(fpp);
      }
      
      return fpps;
    }
	  	  	  
	  /***************************************************************************
     * loadFormFormRequestStatus */
    /**
     * Requests form
     ***************************************************************************/  
	  
	  public static DataDrivenFormRequestStatus loadFormRequestStatus (  SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
	                                                 , string formRequestID
	                                                 , long formDefinitionID	                                                
												                           , long formPageDefinitionID)
    {
      
      DataDrivenFormRequestStatus fp = new DataDrivenFormRequestStatus();

      string sql      = @"select * from FORM_REQUEST_STATUS_VIEW(null,null,null,@formRequestID,@formID,@formPageID)";
      List <SqlParameter> parms = new List<SqlParameter>();            
     
      parms.Add(Database.SqlParm("@formRequestID", SqlDbType.VarChar, formRequestID,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@formID",        SqlDbType.BigInt,  formDefinitionID,     ParameterDirection.Input));                  
      parms.Add(Database.SqlParm("@formPageID",    SqlDbType.BigInt,  formPageDefinitionID, ParameterDirection.Input));                  

      ReturnDB rd = Database.execQuery(connSpedmon ,log,sql,false,parms);
      if (rd.hasRecords == false) return fp;
      
      fp = (DataDrivenFormRequestStatus) Database.convertRecord(rd.records,typeof(DataDrivenFormRequestStatus));

      return fp;
    }
		
	  /***************************************************************************
     * viewFormPagePartSelectionsReturnDB */
    /**
     * List of entities
     ****************************************************************************/
             
    public static ReturnDB viewFormPagePartSelectionsReturnDB (  SqlConnection connSpedmon
                                   , DetailsLog  log
                                   , UserInfo    uInfo
                                   , string      selectFrom
                                   , string      selectWhat
                                   , string      top
                                   , string      active
								                   , string      reqEntityVal1
								                   , string      reqEntityVal2
								                   , string      term
								                   , string      name
								                   , string      value)
    {

      ReturnDB rd = new ReturnDB();
      

      int    vSelectFrom   = Validate.reqInteger        (selectFrom,    @"Invalid select from");
      int    vSelectWhat   = Validate.reqInteger        (selectWhat,    @"Invalid select what");
      Object vTop          = Validate.optInteger        (top,           @"Top is not valid");
      bool   vActive       = Validate.reqFlag           (active,        @"Invalid active flag");
      Object vReqEntVal1   = Validate.optString         (reqEntityVal1, @"Invalid req entity val 1");
      Object vReqEntVal2   = Validate.optString         (reqEntityVal2, @"Invalid req entity val 2");      
      string vTerm         = Validate.optString         (term,          @"Invalid term");
      string vName         = Validate.optString         (name,          @"Invalid name");
      string vValue        = Validate.optString         (value,         @"Invalid id");
            
      string sql = @"select * from dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW(@userID, @userGroup, @userRank, @selectFrom, @selectWhat, @top, @active, @reqEntityVal1, @reqEntityVal2, @term, @name, @value)";

      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",     SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",      SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@selectFrom",    SqlDbType.Int,      vSelectFrom,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@selectWhat",    SqlDbType.Int,      vSelectWhat,      ParameterDirection.Input));
    
      parms.Add(Database.SqlParm("@top",           SqlDbType.Int,      vTop,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@active",        SqlDbType.Bit,      vActive,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@reqEntityVal1", SqlDbType.VarChar,  vReqEntVal1,      ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@reqEntityVal2", SqlDbType.VarChar,  vReqEntVal2,      ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@term",          SqlDbType.VarChar,  vTerm,            ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@name",          SqlDbType.VarChar,  vName,            ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@value",         SqlDbType.VarChar,  vValue,           ParameterDirection.Input, 1000));
      
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      
      return rd;
    }
    
    /***************************************************************************
     * viewFormPagePartSelections */
    /**
     * View names and values
     ****************************************************************************/

    public static ReturnSelections viewFormPagePartSelections (  SqlConnection connSpedmon
                                   , DetailsLog  log
                                   , UserInfo    uInfo
                                   , string      selectFrom
                                   , string      selectWhat
								                   , string      reqEntityVal1
								                   , string      reqEntityVal2
								                   , string      term)
                                                             
    {
      ReturnSelections r  = new ReturnSelections();      
      
      string top = "500";      
      ReturnDB rd = viewFormPagePartSelectionsReturnDB  (connSpedmon, log, uInfo, selectFrom, selectWhat, top, "Y", reqEntityVal1, reqEntityVal2, term, null, null);
      r = Database.convertReturnDBToReturnSelections(ref rd);
      return r;
    }


    /***************************************************************************
     * viewFormPagePartSelectionsList */
    /**
     * View 
     ****************************************************************************/
       
    public static List<MBA.Selection> viewFormPagePartSelectionsList (   SqlConnection connSpedmon
                                                 , DetailsLog  log
                                                 , UserInfo    uInfo
								                                 , string      selectFrom
								                                 , string      selectWhat
                                                 , string      top
                                                 , string      active
								                                 , string      reqEntityVal1
								                                 , string      reqEntityVal2
								                                 , string      term
								                                 , string      name
								                                 , string      value)
                                    
    {
      List<MBA.Selection> rl = new List<MBA.Selection>();
      ReturnDB            rd = viewFormPagePartSelectionsReturnDB (connSpedmon, log, uInfo, selectFrom, selectWhat, top, active, reqEntityVal1, reqEntityVal2, term, name, value);
      Object[]            ol = Database.convertRecords(rd.records, typeof(MBA.Selection));
      foreach (Object o in ol)
      {
        MBA.Selection r = (MBA.Selection)o;
        rl.Add(r);
      }
      return rl;
    }	
  }    
}