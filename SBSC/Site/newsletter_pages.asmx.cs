
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

using Spedmon;

namespace Spedmon
{


  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class NewsletterPagesSvc : MBA.WebSvc
  {
    /***************************************************************************
     * delete */
    /**
     * "delete" a record
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
          
        return Spedmon.NewsletterPages.delete(this.dbConnApp,this.log,this.uInfo,editDelReason,validaterec,recid);                                           
      },
        Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    /***************************************************************************
     * deleteinline */
    /**
     * Inline delete for rest views
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline (string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
          
        return Spedmon.NewsletterPages.delete(this.dbConnApp,this.log,this.uInfo,@"","N",recid);                                           
      },
        Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    /***************************************************************************
     * resetandrepublish */
    /**
     * Reset campaign and republish 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord resetandrepublish ( string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate()
      {

          return Spedmon.NewsletterPages.resetAndRepublish(dbConnApp
                               , log
                               , uInfo
                               , recid );
      }
      , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }


    /***************************************************************************
     * save */
    /**
     * Save man pages
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord
            save (    string startdate

					, string forcontactroleids

                    , string foruserroleids 

                    , string forclientids
                    , string announcementtitle
                    , string announcementcontent
                    , string readyToSend
                    , string isresourcelibrarytopic
                    , string tags
                    , string tooltip
                    , string sendEmailSelected
                    , string editDelReason
                    , string validaterec
                    , string savetype
                    , string recid )
    {

      return (ReturnSaveRecord) 
     
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate()
      {

          return Spedmon.NewsletterPages.save ( dbConnApp //dbConnUser
                               , log
                               , uInfo
                               , startdate

							   , forcontactroleids
                               , foruserroleids

                               , forclientids
                               , announcementtitle

                               , announcementcontent

                               , readyToSend

                               , isresourcelibrarytopic
                               , tags
                               , tooltip

                               , sendEmailSelected

                               , savetype
                               , validaterec
                               , editDelReason
                               , recid );
      }
      , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord
           addindivrecipemailaddy(
                     string mm_recid
                   , string email_address
                   , string custom_msgbody
                   )
    {

        return (ReturnSaveRecord)

        callMethod(
          typeof(ReturnSaveRecord)
        , delegate ()
        {

            return Spedmon.NewsletterPages.addIndivRecipEmailAddy(
                                   dbConnApp //dbConnUser
                                 , log
                                 , uInfo

                                 , mm_recid
                                 , email_address
                                 , custom_msgbody
                                 );
        }
        , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    /* Please remember viewSel is one of the few exceptions for web method names as someone named the first set of these methods viewSel
        * so it order to maintain the standard that was set, viewSel can be mixed case.
        * Parameters are still all lowercase.  Just the method name is set.
        */
    public ReturnSel viewSel(string term)
    {

        return (ReturnSel)
        callMethod(typeof(ReturnSel),
        (MethodCallback)delegate ()
        {

            return Spedmon.NewsletterPages.viewSel(this.dbConnApp, this.log, this.uInfo, term);

        },
        Constants.ROLE_ALL); // Who can call this method    

    }


    }
}
