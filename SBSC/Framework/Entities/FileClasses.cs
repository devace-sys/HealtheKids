using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using System.IO;
using MBA;

namespace Spedmon
{    
  
  public class FileClass: Entity
  {
  
  }
  
  // TODO: Refactor FILE_UPLOADS to use this class.
  
  /***************************************************************************
   * FileClasses */
  /**
   * 
   ***************************************************************************/  
     
  public class FileClasses:Entities
  {
    
    /***************************************************************************
     * load */
    /**
     * 
     * 
     ****************************************************************************/
    
    public static FileClass load (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        recID )
      
    {      
      return (FileClass) Entities.load(connSpedmon, log, uInfo, recID, typeof(FileClass),
      delegate { return FileClasses.view (connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", null, "", null); });      
    } 
    
    /***************************************************************************
     * view */
    /**
     * 
     * 
     ****************************************************************************/
     
    public static ReturnDB view (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        name
      , defineCols    dc)     
    
    {
    
      ReturnDB rd = new ReturnDB();
            
      Object vName = Validate.optString(name);
      
      string viewUDF = @"dbo.FILE_CLASS_VIEW (@userID, @userGroup, @userRank, @recID, @canEdit, @active, @name)";
      
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input,50));

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);  
    }

    /***************************************************************************
     * viewUploadFileClassesSel */
    /**
     * List of upload file classes for selection box
     * 
     ****************************************************************************/       

    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
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
     delegate{return FileClasses.view(connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", term,dc);});

   }                       
  }    
}
