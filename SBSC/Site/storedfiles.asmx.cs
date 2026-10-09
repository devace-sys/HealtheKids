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
   * StoredFilesSvc */
  /*
   * Web services end point.
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
  
  public class StoredFilesSvc : MBA.WebSvc
  {


    /***************************************************************************
     * viewInfoTable */
    /**
     * View info
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnInfoTable viewInfoTable (   string clientid
                                           , string pracid
							               , string patid
                                           , string referencedentityid
                                           , string fileclass
							               , string filenamespace
							               , string filesource)
    {
      return (ReturnInfoTable) 
      callMethod(typeof(ReturnInfoTable), 
      delegate()
      {
        return Spedmon.StoredFiles.viewInfoTable (   this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , clientid
                                                   , pracid
                                                   , patid
                                                   , referencedentityid
                                                   , fileclass
                                                   , filenamespace
                                                   , filesource );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 

    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (   string clientid
                               , string pracid
							   , string patid
                               , string referencedentityid
                               , string fileclass
							   , string filenamespace
							   , string filesource
                               , string term )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      { 
        return Spedmon.StoredFiles.viewSel (    dbConnApp 
                                              , log
                                              , uInfo
                                              , false 
                                              , "" 
                                              , clientid
                                              , pracid
											  , patid
											  , referencedentityid
                                              , fileclass
											  , filenamespace
											  , filesource
                                              , term );                                             
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * delete */
    /**
     * Deactivate
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline ( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.delete (  this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , @""
                                           , @"N"
                                           , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * flagasconfidential */
    /**
     * Set confidential flag
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord flagasconfidentialinline ( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.flagAsConfidential (   this.dbConnApp
                                                        , this.log
                                                        , this.uInfo
                                                        , @""
                                                        , @"N"
                                                        , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * flagasnonconfidential */
    /**
     * Remove confidential flag
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord flagasnonconfidentialinline ( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.flagAsNonConfidential (  this.dbConnApp
                                                          , this.log
                                                          , this.uInfo
                                                          , @""
                                                          , @"N"
                                                          , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * enablefilesharingwithpatient */
    /**
     * Flag as shared with Patient ON
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord enablefilesharingwithpatient( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.EnableFileSharingWithPatient ( this.dbConnApp
                                                                , this.log
                                                                , this.uInfo
                                                                , @""
                                                                , @"N"
                                                                , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * disablefilesharingwithpatient */
    /**
     * Flag as shared with Patient OFF
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord disablefilesharingwithpatient( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.DisableFileSharingWithPatient (  this.dbConnApp
                                                                  , this.log
                                                                  , this.uInfo
                                                                  , @""
                                                                  , @"N"
                                                                  , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
    
    /***************************************************************************
     * enablefilesharingwithparentguardian */
    /**
     * Flag as shared with Parent/Guardian ON
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord enablefilesharingwithparentguardian( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.EnableFileSharingWithParentGuardian (  this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , @""
                                                                        , @"N"
                                                                        , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * DisableFileSharingWithParentGuardian */
    /**
     * Flag as shared with Parent/Guardia OFF
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord disablefilesharingwithparentguardian( string recid )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.StoredFiles.DisableFileSharingWithParentGuardian ( this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , @""
                                                                        , @"N"
                                                                        , recid );
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }    
  }
}
