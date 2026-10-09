using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * GroupsServiceClasse */
  /**
   * Practitioner group service classe
   ***************************************************************************/

  public class GroupsServiceClass:Entity
  {
  
  }
  
  /***************************************************************************
   * GroupsServiceClasses */
  /**
   * Practitioner group service classes
   ***************************************************************************/

  public class GroupsServiceClasses:MBA.Entities
  {

    public const string URL_REST_BASE                 = @"groups_service_classes.asmx";
    public const string URL_REST_VIEWSEL_FOR_ORP_DOCS = URL_REST_BASE + @"/viewSelForOrpDocs";

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/

    public static string URL_REST_VIEWSEL_FOR_ORP_DOCS_BASE()
    {
        return MBA.HttpApplication.createLink(GroupsServiceClasses.URL_REST_VIEWSEL_FOR_ORP_DOCS, true);
    }
        
    /***************************************************************************
     * view */
    /**
     * Load record
     * Note: Not standard
     *
     * @param  source          Partition id
     * @param  recID           Svc class name id
     * @return                 Record
     ***************************************************************************/   

    public static GroupsServiceClass load (  SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , string source
                                            , string recID)
    {
      
      GroupsServiceClass rec = new GroupsServiceClass();
      
      /*-------------------------------
       * Validate required and 
       * optional parameters
       *------------------------------*/ 

      long   vSource = Validate.reqInteger (source,@"Invalid source");
      long   vRecID  = Validate.reqInteger (recID,@"Invalid rec id");
      
     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      List<SqlParameter> parms = new List<SqlParameter>();      
      
      parms.Add(Database.SqlParm("@source", SqlDbType.BigInt,  vSource, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",  SqlDbType.BigInt,  vRecID,  ParameterDirection.Input));
      
      sql = @"select top 1 GROUP_SERVICE_CLASS_NAME_ID as id, Name as name, Context1 as notes from dbo.GROUPS_SERVICE_CLASS_VIEW (null,null,null,@source,null) where (GROUP_SERVICE_CLASS_NAME_ID = @recID)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      if (!rd.hasRecords) throw new Warning(Messages.RECORD_NOT_FOUND);      
      rec = (GroupsServiceClass) Database.convertRecord(rd.records,typeof(GroupsServiceClass));
      return rec;
                  
    }
    
    /***************************************************************************
     * view */
    /**
     * View service class records
     * 
     * @param  source          Partition id
     * @param  term            Search term
     * @return                 Group records
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        source
                                 , string        term
                                 , defineCols    dc ) 
    {
      
      string  viewUDF  = "dbo.GROUPS_SERVICE_CLASS_VIEW (null,null,null,@source,@term)";            
    
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms      = new List<SqlParameter>();	  
      int                vSource    = Validate.reqInteger   (source, @"Invalid partition id");
	    Object             vTerm      = Validate.optString    (term,   Messages.INVALID_GROUP_ID);
       
      parms.Add(Database.SqlParm("@source",   SqlDbType.Int,     vSource,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar, vTerm,    ParameterDirection.Input, 256));

      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view ( connSpedmon
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
     * viewSel */
    /**
     * View group record selections
     * 
     * @param  source          Partition id
     * @param  term            Search term
     * @return                 ReturnSel
     ***************************************************************************/   
    
    public static ReturnSel viewSel (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , bool          top
                                     , string        topSize
                                     , string        source
                                     , string        term ) 
    {
      defineCols dc = null;
      
	    dc = delegate ( ref SQLStatement       ss
	                  , ref string             pageroworder
	                  , ref List<SqlParameter> parms )
	    {        
        ss.addDisplayColumn ("context1 as context1");
        ss.addSortColumn    ("name");
      };
      
      return Entities.viewSel( connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate {
                                  return GroupsServiceClasses.view (  connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_SEL
                                                                   , top
                                                                   , topSize
                                                                   , ""
                                                                   , "1"
                                                                   , source
                                                                   , term
                                                                   , dc );
                                }
                              );
    }

    /***************************************************************************
     * viewSelForPatExpdSvcs */
    /**
     * Outputs a simple list of expected service classes for patient expected
     * services
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  term            All or part of service class name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    public static ReturnSel viewSelForPatExpdSvcs (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , bool          top
                                                   , string        topSize
                                                   , string        term  )
    {      
     
     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      string vTerm   = Validate.optString (term, Messages.INVALID_SERVICE);
      long   vSource = 2;
      
     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      List<SqlParameter> parms = new List<SqlParameter>();      
      
      parms.Add(Database.SqlParm("@term",   SqlDbType.VarChar, vTerm,   ParameterDirection.Input,255));
      parms.Add(Database.SqlParm("@source", SqlDbType.BigInt,  vSource, ParameterDirection.Input));
      
      sql = @"select GROUP_SERVICE_CLASS_NAME_ID as id, Name as label, Name as value, Context1 as context1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_PARTITION_ID) as recData1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_NAME_ID) as recData2 from dbo.GROUPS_SERVICE_CLASS_VIEW (null,null,null,@source,@term)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      ReturnSel so  = Database.convertReturnDBToReturnSel(ref rd);
      
      return so;      

    }


    /***************************************************************************
     * viewSelForPlanWriter */
    /**
     * Outputs a simple list of group service class list for the plan writer
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  term            All or part of service class name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    public static ReturnSel viewSelForPlanWriter (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , bool          top
                                                   , string        topSize
                                                   , string        term  )
    {      
     
     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      string vTerm   = Validate.optString (term, Messages.INVALID_SERVICE);
      long   vSource = 4;
      
     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      List<SqlParameter> parms = new List<SqlParameter>();      
      
      parms.Add(Database.SqlParm("@term",   SqlDbType.VarChar, vTerm,   ParameterDirection.Input,255));
      parms.Add(Database.SqlParm("@source", SqlDbType.BigInt,  vSource, ParameterDirection.Input));
      
      sql = @"select GROUP_SERVICE_CLASS_NAME_ID as id, Name as label, Name as value, Context1 as context1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_PARTITION_ID) as recData1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_NAME_ID) as recData2 from dbo.GROUPS_SERVICE_CLASS_VIEW (null,null,null,@source,@term)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      ReturnSel so  = Database.convertReturnDBToReturnSel(ref rd);
      
      return so;      

    }


    /***************************************************************************
     * viewSelForOrpDocs */
    /**
     * Outputs a simple list of group service class list for manage patient orders
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  term            All or part of service class name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    public static ReturnSel viewSelForOrpDocs (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , bool          top
                                                   , string        topSize
                                                   , string        term  )
    {      
     
     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      string vTerm   = Validate.optString (term, Messages.INVALID_SERVICE);
      long   vSource = 5;
      
     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      List<SqlParameter> parms = new List<SqlParameter>();      
      
      parms.Add(Database.SqlParm("@term",   SqlDbType.VarChar, vTerm,   ParameterDirection.Input,255));
      parms.Add(Database.SqlParm("@source", SqlDbType.BigInt,  vSource, ParameterDirection.Input));
      
      sql = @"select GROUP_SERVICE_CLASS_NAME_ID as id, Name as label, Name as value, Context1 as context1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_PARTITION_ID) as recData1 , CONVERT(varchar(10), GROUP_SERVICE_CLASS_NAME_ID) as recData2 from dbo.GROUPS_SERVICE_CLASS_VIEW (null,null,null,@source,@term)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      ReturnSel so  = Database.convertReturnDBToReturnSel(ref rd);
      
      return so;      

    }
  }
} 

