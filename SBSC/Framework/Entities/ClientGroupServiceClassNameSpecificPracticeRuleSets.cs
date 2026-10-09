using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * ClientGroupServiceClassNameSpecificPracticeRuleSet */
  /** 
   ***************************************************************************/
  public class ClientGroupServiceClassNameSpecificPracticeRuleSet {

    public long   id;
    public long   clientID;
    public string groupSvcClassName;
    public long   groupSvcClassNameID;
    public bool   departmentHeadsCanViewSupervisedPracsPrivateNotes;
    public bool   departmentHeadsCanViewSupervisedPracsStoredFiles;
    public bool   departmentHeadsCanViewSupervisedPracsSvcRecs;
    public bool   onlyDepartmentHeadsCanManageDirectSupervisionAssignments;
    public bool   departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup;
    public bool   departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup;
    public bool   supervisingAndSupervisedPracsMustBeInSameReportingGroup;
    public bool   departmentHeadsCanViewAllPracDataInTheirReportingGroup;

    //public bool notesRequiredForServiceRecords;

    public const string DEFAULT_PAGING_ORDER = @"groupSvcClassName asc";
  }

  /***************************************************************************
   * ClientGroupServiceClassNameSpecificPracticeRuleSets */
  /** 
   ***************************************************************************/
	 
  public class ClientGroupServiceClassNameSpecificPracticeRuleSets : Entities
  {
    public const string URL_REST_VIEW_BASE = @"api/v1/clientgroupserviceclassnamespecificpracticerulesets";
    public const string URL_SVC_BASE       = @"client_group_service_class_name_specific_practice_rule_sets.asmx/";
      
    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/
    public static string URL_REST_VIEW()
    {
      return MBA.HttpApplication.createLink(URL_REST_VIEW_BASE, true);
    }
    
    /***************************************************************************
     * URL_SVC_UPDATE_RULE_SET */
    /**
     * 
     **************************************************************************/
     
    public static string URL_SVC_UPDATE_RULE_SET()
    {
      return MBA.HttpApplication.createLink(URL_SVC_BASE + @"updateruleset", true);
    } 


   /***************************************************************************
     * load */
    /**
     * @return ClientGroupServiceClassNameSpecificPracticeRuleSet
     ***************************************************************************/ 
    
    protected static ClientGroupServiceClassNameSpecificPracticeRuleSet load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string groupSvcClassNameID)
    { 
       ClientGroupServiceClassNameSpecificPracticeRuleSet prs = (ClientGroupServiceClassNameSpecificPracticeRuleSet) load ( connSpedmon, log, uInfo, typeof(ClientGroupServiceClassNameSpecificPracticeRuleSet)
         , delegate {    
           return ClientGroupServiceClassNameSpecificPracticeRuleSets.view (connSpedmon, log, uInfo , Entities.REC_VIEW_RAW, false, "", "", "", clientID, groupSvcClassNameID, null );
       });                  
       return prs;
    }

   /***************************************************************************
    * updateRuleSet */
   /** 
    ***************************************************************************/
   public static ReturnSaveRecord updateRuleSet (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        departmentHeadsCanViewSupervisedPracsPrivateNotes
      , string        departmentHeadsCanViewSupervisedPracsStoredFiles
      , string        departmentHeadsCanViewSupervisedPracsSvcRecs
      , string        onlyDepartmentHeadsCanManageDirectSupervisionAssignments
      , string        departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup
      , string        departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup
      , string        supervisingAndSupervisedPracsMustBeInSameReportingGroup
      , string        departmentHeadsCanViewAllPracDataInTheirReportingGroup
      , string        recID )
    
    {
      
      var parms = new List<SqlParameter>();

      int    vClientID                                                                       = Validate.reqClientID (uInfo, clientID);    
      bool   vDepartmentHeadsCanViewSupervisedPracsPrivateNotes                              = Validate.reqFlag     (departmentHeadsCanViewSupervisedPracsPrivateNotes,                              Messages.INVALID_FLAG);
      bool   vDepartmentHeadsCanViewSupervisedPracsStoredFiles                               = Validate.reqFlag     (departmentHeadsCanViewSupervisedPracsStoredFiles,                               Messages.INVALID_FLAG);
      bool   vDepartmentHeadsCanViewSupervisedPracsSvcRecs                                   = Validate.reqFlag     (departmentHeadsCanViewSupervisedPracsSvcRecs,                                   Messages.INVALID_FLAG);
      bool   vOnlyDepartmentHeadsCanManageDirectSupervisionAssignments                       = Validate.reqFlag     (onlyDepartmentHeadsCanManageDirectSupervisionAssignments,                       Messages.INVALID_FLAG);
      bool   vDepartmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup             = Validate.reqFlag     (departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup,             Messages.INVALID_FLAG);
      bool   vDepartmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup  = Validate.reqFlag     (departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup,  Messages.INVALID_FLAG);
      bool   vSupervisingAndSupervisedPracsMustBeInSameReportingGroup                        = Validate.reqFlag     (supervisingAndSupervisedPracsMustBeInSameReportingGroup,                        Messages.INVALID_FLAG);
      bool   vDepartmentHeadsCanViewAllPracDataInTheirReportingGroup                         = Validate.reqFlag     (departmentHeadsCanViewAllPracDataInTheirReportingGroup,                         Messages.INVALID_FLAG);
            
      parms.Add(MBA.Database.SqlParm("@clientID",                                                  SqlDbType.BigInt,  vClientID,                                                   ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanViewSupervisedPracsPrivateNotes",         SqlDbType.Bit,     vDepartmentHeadsCanViewSupervisedPracsPrivateNotes,          ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanViewSupervisedPracsStoredFiles",          SqlDbType.Bit,     vDepartmentHeadsCanViewSupervisedPracsStoredFiles,           ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanViewSupervisedPracsSvcRecs",              SqlDbType.Bit,     vDepartmentHeadsCanViewSupervisedPracsSvcRecs,               ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@onlyDepartmentHeadsCanManageDirectSupervisionAssignments",  SqlDbType.Bit,     vOnlyDepartmentHeadsCanManageDirectSupervisionAssignments,   ParameterDirection.Input));      
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup",             SqlDbType.Bit,     vDepartmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup,              ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup",  SqlDbType.Bit,     vDepartmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup,   ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@supervisingAndSupervisedPracsMustBeInSameReportingGroup",                        SqlDbType.Bit,     vSupervisingAndSupervisedPracsMustBeInSameReportingGroup,                         ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@departmentHeadsCanViewAllPracDataInTheirReportingGroup",                         SqlDbType.Bit,     vDepartmentHeadsCanViewAllPracDataInTheirReportingGroup,                          ParameterDirection.Input));
           
      return recordOp (  connSpedmon
                       , log
                       , uInfo
                       , ""
                       , "0"
                       , recID
                       , @"dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET"
                       , ref parms);

    }
    
     
    /***************************************************************************
     * view */
    /** 
     ***************************************************************************/
    protected static ReturnDB view (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , int           recViewType
        , bool          pagedOrTop
        , string        idx
        , string        canEdit
        , string        active
        , string        clientID
        , string        groupSvcClassNameID
        , defineCols    dc )
    {
      string viewUDF = "dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW (null, null, null, @clientID, @groupSvcClassNameID, 1, null)";

      var parms = new List<SqlParameter>();

      int    vClientID            = Validate.reqClientID                (uInfo, clientID);
      Object vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID  (uInfo, groupSvcClassNameID);

      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            
      var rd = Entities.view ( connSpedmon
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
                             , dc);
      return rd;
    }
     
    /***************************************************************************
     * viewObjects 
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
                                              , string       groupSvcClassNameID)

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientGroupServiceClassNameSpecificPracticeRuleSet.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd =  Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(ClientGroupServiceClassNameSpecificPracticeRuleSet)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                      return ClientGroupServiceClassNameSpecificPracticeRuleSets.view (  
                                          connSpedmon
                                        , log
                                        , uInfo
                                        , Entities.REC_VIEW_OBJECTS
                                        , pageObjectList
                                        , idx
                                        , "" /* Can edit */
                                        , active                                                             
                                        , clientID
                                        , groupSvcClassNameID
                                        , dc );
                                    });
      return rd;
    }    
  }
}