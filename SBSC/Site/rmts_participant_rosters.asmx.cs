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
using System.IO;




namespace Spedmon
{
    /***************************************************************************
     * RmtsParticipantRostersSvc
    /*
     * Web services end point for entity methods
     *
     * Unless indicated, each of these methods require that the caller is
     * logged in.
     *
     * Each end point method provides a wrapper for a corresponding framework
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

    public class RmtsParticipantRostersSvc : MBA.WebSvc
    {
        public RmtsParticipantRostersSvc() : base() { }

    
    /***************************************************************************
     * save */
    /**
     * Save roster
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (  string  clientid
                                  , string  fyquarterid				
                                  , string  participantsrosterjson
                                  , string  participantsrosterchangesjson
                                  , string  savetype
                                  , string  validaterec
                                  , string  editDelReason
                                  , string  recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        
        return Spedmon.RmtsParticipationRosters.save (
            this.dbConnApp
          , log
          , uInfo        
          , clientid
          , fyquarterid
          , participantsrosterjson
          , participantsrosterchangesjson
          , savetype
          , validaterec
          , editDelReason
          , recid
        );
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }    

    /***************************************************************************
     * loadInitialData */
    /**
     * load initial roster data
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnRmtsParticipationRoster getInitialData(string  clientid)
    {
      return (ReturnRmtsParticipationRoster) 
     
      callMethod(typeof(ReturnRmtsParticipationRoster),       
      delegate()
      {                     
        
        return Spedmon.RmtsParticipationRosters.getInitialData(
            this.dbConnApp
          , log
          , uInfo
          , clientid
        );
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }		
        
    /***************************************************************************
     * loadByQuarter */
    /**
     * load roster by quarter
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnRmtsParticipationRoster loadRoster (  string  clientid , string  recid)
    {
      return (ReturnRmtsParticipationRoster) 
     
      callMethod(typeof(ReturnRmtsParticipationRoster),       
      delegate()
      {                     
        
        return Spedmon.RmtsParticipationRosters.loadRoster(
            this.dbConnApp
          , log
          , uInfo        
          , clientid
          , recid
        );
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }		

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnRmtsParticipationRoster loadByQuarter(  string  clientid
                                  , string  active
                                  , string  recid  // todo: I would have renamed this fiscalQuarterID (before)
                                                   //       and fiscalYearID (now)
                                                   //       in the incoming JSON in the request
                                  , string  quarternum)
    {
      return (ReturnRmtsParticipationRoster) 
     
      callMethod(typeof(ReturnRmtsParticipationRoster),       
      delegate()
      {                     
        
        return Spedmon.RmtsParticipationRosters.loadByQuarterNum (
            this.dbConnApp
          , log
          , uInfo        
          , active
          , clientid
          , recid
          , quarternum
        );
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }	
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnRmtsParticipationRosterHistHtml viewHTMLTblModHist(
                                    string  clientid
                                  , string  rosterid)
    {
      return (ReturnRmtsParticipationRosterHistHtml) 
     
      callMethod(typeof(ReturnRmtsParticipationRosterHistHtml),       
      delegate()
      {                     
        
        return Spedmon.RmtsParticipationRosters.viewHTMLTblModHist (
            this.dbConnApp
          , log
          , uInfo        
          , clientid
          , rosterid
        );
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }

    }
}