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
   * TeleCommSessionsTeleIEPSvc */
  /*
   * Web services end point 
   *
   * Unless indicated, each of these methdos are for all users
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

  public class TeleCommSessionsTeleIEPSvc : MBA.WebSvc
  {
    public TeleCommSessionsTeleIEPSvc() : base() { }

     /***************************************************************************
      * gettelecommsessionparticipantforuserid */
     /**
      * Uses userid of user who is logged in 
      ***************************************************************************/   

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
      public ReturnTeleCommSessionParticipant gettelecommsessionparticipantforuserid (string roomid)
      {
        return (ReturnTeleCommSessionParticipant)
        callMethod(typeof(ReturnTeleCommSessionParticipant),
        delegate ()
        {
          ReturnTeleCommSessionParticipant so = TeleIEPSessions.getTeleCommSessionParticipantForUserID (this.dbConnUser, this.log, this.uInfo, roomid);
          return so;
        },
        Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC); // Who can call this method
       }
        /***************************************************************************
         * save */
        /**
         * Save scheduled session
         ***************************************************************************/    

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save (  string        clientid
                                      , string        facilitatoruserid
                                      , string        patid
                                      , string        iepformtype
 										                  , string        meetingdate
                                      , string        meetingtime
											                , string        meetingdurationinmins
                                      , string        title  
                                      , string        participantdetails
                                      , string        filestoshareuploadids
                                      , string        savetype
                                      , string        validaterec
                                      , string        editDelReason
                                      , string        recid)
        {
          return (ReturnSaveRecord) 
     
          callMethod(typeof(ReturnSaveRecord),       
          delegate()
          {                     
        
            return Spedmon.TeleIEPSessions.save (
               this.dbConnUser
             , this.dbConnApp
             , log
             , uInfo        
             , clientid
             , facilitatoruserid
             , patid
             , iepformtype
 				     , meetingdate
             , meetingtime
				     , meetingdurationinmins
             , title  
             , participantdetails
             , filestoshareuploadids
             , savetype
             , validaterec
             , editDelReason
             , recid
            );
          },
          Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC);  // Who can call this method           
        }
        
        /***************************************************************************
         * delete */
        /**
         * "Deletes" a session
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/  

        [WebMethod]
        [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete (   string editDelReason
                                         , string validaterec
                                         , string recid )
        {
          return (ReturnSaveRecord)
          callMethod(typeof(ReturnSaveRecord), delegate()
          {    
            return Spedmon.TeleIEPSessions.delete ( dbConnUser, log, uInfo, editDelReason, validaterec, recid);
          },
          Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC);  // Who can call this method           
        }

    }
}
