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
   * PlanWriterPlansSvc */
  /*
   * Web services end points
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
  
  public class PlanWriterPlansSvc : MBA.WebSvc
  {

    /***************************************************************************
        * delete */
    /**
        *
        ****************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(string organizationID
                                    , string ownerID
                                    , string groupID
                                    )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
            return Spedmon.PlanWriterPlans.delete(this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , ""
                                                , "0"
                                                , organizationID
                                                , ownerID
                                                , groupID);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method 
    }

    /***************************************************************************
        * delete2 */
    /**
     *
     ****************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete2(string clientid
                                    , string recid
                                    )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
            return Spedmon.PlanWriterPlans.delete(this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , ""
                                                , "0"
                                                , clientid
                                                , null
                                                , recid);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method 
    }

    /***************************************************************************
        * save */
    /**
        * 
        ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save(   string clientid
                                    , string plantypeid
                                    , string plandatajson
                                    , string savetype
                                    , string recid)
    {
        return (ReturnSaveRecord)

        callMethod(
            typeof(ReturnSaveRecord)
        , delegate ()
        {
            return Spedmon.PlanWriterPlans.save(dbConnApp
                                            , log
                                            , uInfo
                                            , clientid
                                            , plantypeid
                                            , plandatajson
                                            , ""
                                            , "0"
                                            , savetype
                                            , recid);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveNoJSON(string clientid
                                     , string plantypeid
                                     , string patid
                                     , string plandate
                                     , string diagnosisid
                                     , string diagnosisname
                                     , string diagnosisdesc
                                     , string orpdocselectionsjson
                                     , string participantsjson
                                     , string plancreatorsigned
                                     , string plancreatorsigneddate
                                     , string plancreatorsignatureimg
                                     , string savetype
                                     , string recid)
    {
        return (ReturnSaveRecord)

        callMethod(
            typeof(ReturnSaveRecord)
        , delegate ()
        {
            return Spedmon.PlanWriterPlans.saveNoJSON(dbConnApp
                                            , log
                                            , uInfo
                                            , clientid
                                            , plantypeid
                                            , patid
                                            , plandate
                                            , diagnosisid
                                            , diagnosisname
                                            , diagnosisdesc
                                            , orpdocselectionsjson
                                            , participantsjson
                                            , plancreatorsigned
                                            , plancreatorsigneddate
                                            , plancreatorsignatureimg
                                            , ""
                                            , "0"
                                            , savetype
                                            , recid);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
    }
       
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord changeplanauthor (  string clientid                                                                                 
                                              , string newplanauthoruserid
                                              , string recid)
    {
        return (ReturnSaveRecord)

        callMethod(
        typeof(ReturnSaveRecord)
        , delegate ()
        {
            return Spedmon.PlanWriterPlans.changePlanAuthor ( dbConnApp
                                                            , log
                                                            , uInfo
                                                            , clientid                                                            
                                                            , newplanauthoruserid
                                                            , recid);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord requestAuthorization(
                                      string clientid
                                    , string districtcontactuserid         
                                    , string patid                         
                                    , string referencedentityid            
                                    , string svcdescription                
                                    , string prtgrd1personid               
                                    , string prtgrd2personid               
                                    , string recid                         
    )

    {
        return (ReturnSaveRecord)

        callMethod(
            typeof(ReturnSaveRecord)
        , delegate ()
        {
            return Spedmon.PlanWriterPlans.requestAuthorization(
                                              dbConnApp
                                            , dbConnUser
                                            , log
                                            , uInfo
                                            , clientid
                                            , districtcontactuserid
                                            , patid
                                            , referencedentityid
                                            , svcdescription
                                            , prtgrd1personid
                                            , prtgrd2personid
                                            , recid);
        },
        Constants.ROLE_CARE_PLAN_WRITER);  // Who can call this method           
    }

    /***************************************************************************
        * viewSel */
    /**
        * Selection view 
        ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel(string clientid
                                , string groupsvcclassnameid
                                , string term)
    {
        return (ReturnSel)
        callMethod(typeof(ReturnSel),
        delegate ()
        {
            return Spedmon.PlanWriterPlans.viewSel(dbConnApp
                                                , log
                                                , uInfo
                                                , false
                                                , ""
                                                , clientid
                                                , groupsvcclassnameid
                                                                            , term);

        },
        Constants.ROLE_CARE_PLAN_WRITER); // Who can call this method
    }


    /***************************************************************************
        * loadJSON */
    /**
        * load view 
        ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel loadJSON(string clientid
                                , string patid
                                , string pracid
                                , string siteid
                                , string fiscalyearid
                                , string iscreatedbycaller
                                , string isexpiring     
                                , string isexpired       
                                , string term
                                , string recid)
    {
        return (ReturnSel)
        callMethod(typeof(ReturnSel),
        delegate ()
        {
            return Spedmon.PlanWriterPlans.viewSelJSON(dbConnApp
                                                        , log
                                                        , uInfo
                                                        , false
                                                        , ""
                                                        , clientid
                                                        , patid
                                                        , pracid
                                                        , siteid
                                                        , fiscalyearid
                                                        , iscreatedbycaller
                                                        , isexpiring     
                                                        , isexpired
                                                        , term);
        },
        Constants.ROLE_CARE_PLAN_WRITER); // Who can call this method
    }

    /***************************************************************************
     * viewSelServicesByOrpDocType */
    /**
     * Selection view 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelORPDocs(string clientid, string pracid, string patid, string includeonlyorpdoctypeids, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel)
      , delegate() { return 
        Spedmon.PlanWriterPlans.viewSelORPDocs (   this.dbConnApp
                                       , this.log
                                       , this.uInfo
                                       , true
                                       , ""
                                       , clientid
                                       , pracid
                                       , patid   
                                       , includeonlyorpdoctypeids
                                       , term );}
      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
         
  }
}
