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
   * TeleCommSvc */
  /*
   * Web services end point 
   *
   * Unless indicated, each of these methods are for all users
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

  public class TeleCommSvc : MBA.WebSvc
  {
    public TeleCommSvc() : base() { }

    /***************************************************************************
     * saveformwipdata */
    /**
     * Save form work in progress data
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
   
    public ReturnSaveRecord saveformwipdata ( string rmid
                                            , string rmpartuid
                                            , string rmpartpin
                                            , string formid
                                            , string formdata )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                             
        return TeleCommSessionParticipants.saveFormWipData (dbConnUser,log,uInfo,rd,rmid,rmpartuid,rmpartpin,formid,formdata);          
      }
      );
    }
   
    /***************************************************************************
     * signform */
    /**
     * Provide electronic signature
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
   
    public ReturnSaveRecord signform (   string rmid
                                       , string rmpartuid
                                       , string rmpartpin
                                       , string sigforformid
                                       , string sigcontrolid
                                       , string sigclassname        
                                       , string fieldnamesign
                                       , string sigadditionaldata
                                       , string ctrladditionaldataid
                                       , string sharedatawhensigned)
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                             
        return TeleCommSessionParticipants.signForm( dbConnUser
                                                    , log
                                                    , uInfo
                                                    , rd 
                                                    , rmid
                                                    , rmpartuid
                                                    , rmpartpin
                                                    , sigforformid
                                                    , sigcontrolid
                                                    , sigclassname   
                                                    , fieldnamesign
                                                    , sigadditionaldata
                                                    , ctrladditionaldataid
                                                    , sharedatawhensigned);          
      }
      );
    }
   
    /***************************************************************************
     * getformsignatureshtmltable */
    /**
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
   
    public ReturnHTMLContent getformsignatureshtmltable (  string rmid
                                                         , string rmpartuid
                                                         , string rmpartpin
                                                         , string signatureclassname)
    {
      return (ReturnHTMLContent) 
      callMethod(typeof(ReturnHTMLContent), delegate()
        {                                     
          return TeleCommSessionParticipants.getFormSignaturesHtmlTable (dbConnUser,log,uInfo,rd,rmid,rmpartuid,rmpartpin,signatureclassname);
        }
      );
    }

    /***************************************************************************
     * getsharedfilecontent */
    /**
     * Gets shared file HTML list 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
   
    public ReturnHTMLContent getsharedfilehtmllist (  string rmid
                                                    , string rmpartuid
                                                    , string rmpartpin )
    {
      return (ReturnHTMLContent) 
      callMethod(typeof(ReturnHTMLContent), delegate()
        {                                     
          return TeleCommSessionParticipants.getSharedFileHTMLList (dbConnUser,log,uInfo,rd,rmid,rmpartuid,rmpartpin);          
        }
      );
    }
    
    /***************************************************************************
     * banuser */
    /**
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]   
    public ReturnSaveRecord banuser (  string rmid
                                     , string rmpartuid
                                     , string rmpartpin
                                     , string rmpartuidtoban )
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord), delegate ()
      {
          return TeleCommSessionParticipants.banUser (  dbConnUser
                                                      , log
                                                      , uInfo
                                                      , rd
                                                      , rmid
                                                      , rmpartuid
                                                      , rmpartpin                                                      
                                                      , rmpartuidtoban
                                                      );
      } 
      );
    }    

    /***************************************************************************
     * sendmeetinginvites */
    /**
     * 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]   
    public ReturnSaveRecord sendmeetinginvites(  string rmid
                                     , string rmpartuid
                                     , string rmpartpin )
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord), delegate ()
      {
          return TeleCommSessions.sendInvitesForMeeting (  dbConnUser
                                                      , log
                                                      , uInfo
                                                      , rd
                                                      , Constants.APP_NAME
                                                      , rmid
                                                      , rmpartuid
                                                      , rmpartpin                                                      
                                                      );
      } 
      );
    }


    /***************************************************************************
     * sendmeetinginvites */
    /**
     * 
     ***************************************************************************/    
    /*
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]   
    public ReturnSaveRecord saveRsvpAnswer(string roomID
                                          , string rsvpToken
                                          , string willAttendSession
                                          , string altDateRequested
                                          , string rsvpNotes)
        {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord), delegate ()
      {
          return TeleCommSessions.saveRsvpAnswer(  dbConnUser
                                                      , log
                                                      , uInfo
                                                      , roomID
                                                      , rsvpToken
                                                      , willAttendSession
                                                      , altDateRequested
                                                      , rsvpNotes
                                                      );
      } 
      );
    }
    */


  }
}
