using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Web;
using Spedmon;
using MBA;
using MBA.Reporting;

namespace Spedmon
{
  
  /***************************************************************************
   * ProcessBulkNotifications */
  /**
   * Application class
   ***************************************************************************/   

  public class ProcessBulkNotifications:BatchApplication
  {

    protected static string newManPageSubject           = "";
    protected static string newManPageHead              = "";
    protected static string newManPageBodyStart         = "";
    protected static string newManPageBodyEnd           = ""; 
    protected static string PracSupSvcsToReviewMsgTitle = "";
    protected static string PracSupSvcsToReviewMsgBody  = "";


    protected static List <NewsletterPageContentUserResponsePendingEmailNotification> MultiMediaNotifications                 = null;
    protected static List <ManPageContentUserResponsePendingEmailNotification>        ManPageNotifications                    = null;    
    protected static List <PatientInfoRequestsResponsesMassUpdate>                    patientInfoRequestsResponsesMassUpdates = null;

    /***************************************************************************
     * GetAndCheckAppSettings() */
    /**
     * Get application settings
     ***************************************************************************/ 
	 
    static bool GetAndCheckAppSettings ()
    {

      bool _result = true;
   
      try
      {        
        DisplayNotice (Return.RET_INFO,"Getting application settings");

        newManPageSubject      = Constants.getAppSetting ("newManPageSubject",    @"");
        newManPageHead         = Constants.getAppSetting ("newManPageHead",       @"");
        newManPageBodyStart    = Constants.getAppSetting ("newManPageBodyStart",  @"");
        newManPageBodyEnd      = Constants.getAppSetting ("newManPageBodyEnd",    @"");                
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_CRITICAL,err.Message);
        _result = false;        
      }
      
      return _result;
      
    }
  
    /***************************************************************************
     * GetMultiMediaContentUserResponsesList */
    /**
     * 
     ***************************************************************************/ 
	 
    static bool GetMultiMediaContentUserResponsesList ()
    {

      bool _result = true;

      try
      {
        DisplayNotice (Return.RET_INFO,"Getting list of newsletter notifications (this may take awhile)");
        
        MultiMediaNotifications = null;
        MultiMediaNotifications = new List<NewsletterPageContentUserResponsePendingEmailNotification>();
        
        MultiMediaNotifications = Spedmon.NewsletterPages.viewManPageContentUserResponsePendingMultiMediaEmailNotificationList(
            dbConnApp //dbConnUser
          , log
          , uInfo 
          , Constants.APP_NAME
        ); 
        _result = true;
      }
      catch (Exception err)
      {
        _result = false;
        
        DisplayNotice  (  Return.RET_WARNING
                         , @"Exception thrown : {0}"
                         , err.Message
                       );                                                                                                                      
                
      }
      
      return _result;    

    }

    /***************************************************************************
     * GetContentUserResponsesList */
    /**
     *
     ***************************************************************************/  
	 
    static bool GetContentUserResponsesList ()
    {

      bool _result = true;
      
      try
      {
        DisplayNotice (Return.RET_INFO,"Getting list of notifications for man pages (this may take awhile)");
        
        ManPageNotifications = null;
        ManPageNotifications = new List<ManPageContentUserResponsePendingEmailNotification>();
        
        ManPageNotifications = Spedmon.ManPages.viewManPageContentUserResponsePendingEmailNotificationList(
            dbConnUser
          , log
          , uInfo
        ); 

      }
      catch (Exception err)
      {
        _result = false;
        DisplayNotice  (  Return.RET_WARNING
                         , @"Exception thrown : {0}"
                         , err.Message
                       );             
      }

      return _result;    

    }

    /***************************************************************************
     * ProcessContentUserResponsesList */
    /**
     * Gets list of files ready to be processed
     ***************************************************************************/ 
	 
    static bool ProcessContentUserResponsesList (string spedCareURI, string msgTitle)
    {

      bool _result = true;
      
      try
      {   
      
        if (ManPageNotifications.Count == 0)
        {
           DisplayNotice (Return.RET_INFO,"No notifications to send out");
           return _result;
        }
        else
        {
           DisplayNotice (Return.RET_INFO,"{0} notifications to send out",ManPageNotifications.Count.ToString());
        }
        
         //https://stackoverflow.com/a/5983025

        List<manPageTitleStartdateDescription>  list_of_man_desc_objs;
     
        foreach (ManPageContentUserResponsePendingEmailNotification ManPageNotification in ManPageNotifications)
        {
                        
            DisplayNotice  (  Return.RET_INFO
                              , @"Attempting to send message to {0} at {1}"
                              , ManPageNotification.userEmail
                              , ManPageNotification.clientName
                           );                                                                                                                      

            bool   result    = false;
            string retStatus = "";
            
            UserInfo ui = new UserInfo();
            
            ui.userid       = ManPageNotification.userID;
            ui.userGroup    = ManPageNotification.userGroup;
            ui.userRank     = ManPageNotification.userRank;


           //https://stackoverflow.com/a/5983025

           list_of_man_desc_objs = (List<manPageTitleStartdateDescription>) JSON.fromJSONString(
                ManPageNotification.manPageTitleStartdateDescriptionJSONarrs,
                typeof(List<manPageTitleStartdateDescription>),
                JsonLibrary.NEWTONSOFT
            );

            //https://stackoverflow.com/a/1817332

            //https://stackoverflow.com/a/41455988

            result = MBA.Email.sendAnnouncementAsHtmlWithHeroImage60pctAndImageList(

                //0,  // userMsgId; these messages don't have a corresponding dialog widget to open, so the URL param openmsgmodal
                      // will not be applicable

                false, // promptUserToGotoURL
                null,
                null,  // ManPage notifications will also not have a gotoURL callback, at least for this release

                Constants.APP_EMAIL_FROM,
                ManPageNotification.userEmail,
                "Explore " + newManPageSubject, // TODO; let's remember to re-word the subject, in the config file in on the live server and test servers
                "Now available in SpEdCare",  // maybe this could go in a config file as well
                list_of_man_desc_objs,


                MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL,


                MBA.EmbeddedResources.CommonImages.IMAGE_NAME_LIST_ITEM_DOCTOR_SPEAKING,

              out retStatus
            );


            if (result == true)
            {
              
              DisplayNotice  (  Return.RET_SUCCESS
                              , @"Sent message to {0} at {1}"
                              , ManPageNotification.userEmail
                              , ManPageNotification.clientName );

              DisplayNotice  (  Return.RET_INFO
                              , @"Logging user response for {0}"
                              , ManPageNotification.userEmail
                             );
                             
              ReturnSaveRecord rs = Spedmon.ManPages.logUserResponses (  dbConnUser
                                                                       , log
                                                                       , ui
                                                                       , @"4"
                                                                       , ManPageNotification.manPageIDs );
            }
            else
            {
              DisplayNotice  (  Return.RET_WARNING
                              , @"Unable to send message to {0} at {1} : {2}"
                              , ManPageNotification.userEmail
                              , ManPageNotification.clientName
                              , retStatus );                                                                                                                      

            }
        }        
      }
      catch (Exception err)
      {
        DisplayNotice  (  Return.RET_WARNING
                              , @"Exception thrown : {0}"
                              , err.Message
                        );                                                                                                                      

                
        _result = false;
      }

      return _result;    

    }
   
    /***************************************************************************
     * ProcessMultiMediaContentUserResponsesList */
    /**
     * 
     ***************************************************************************/ 

    static bool ProcessMultiMediaContentUserResponsesList (string spedCareURI)
    {

      bool _result = true;

      string var_msg_content = null;
      
      try
      {   
      
        if (MultiMediaNotifications.Count == 0)
        {
           DisplayNotice (Return.RET_INFO,"No multimedia notifications to send out");
           _result = true;
           return _result;
        }
        else
        {
           DisplayNotice (Return.RET_INFO,"{0} multimedia notifications to send out", MultiMediaNotifications.Count.ToString());
        }


                //https://stackoverflow.com/a/5983025

                // List<object>  list_of_man_desc_objs;

        //int iter_x = 0;
        foreach (NewsletterPageContentUserResponsePendingEmailNotification n in MultiMediaNotifications)
        {

            if ( Util.IsNullOrEmpty( var_msg_content ) )  // runs first iteration of the foreach loop
            {

                DisplayNotice  (  Return.RET_INFO
                              , @"Getting message content"
                );

                /* Get content */

                var content = NewsletterPages.getStringContentMultiMediaEmailNotification(
                          dbConnApp, log, n.id.ToString(), Constants.APP_NAME
                      );
               
                /* Wrap content in tr and td so its compatible with Email.generateHtmlContentWithHeroImage60pct */
               
                var_msg_content = String.Format(@"<tr class=""{0}""><td class=""{0}"">{1}</td></tr>"
                                                , Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT
                                                , content);                      

            }
                        
            DisplayNotice  (  Return.RET_INFO
                              , @"Attempting to send multimedia message to {0} "
                              , n.email
                              //, ManPageNotification.clientName
                           );                                                                                                                    

            bool   result    = false;
            string retStatus = "";

            //bool last_iter = false;  iter_x++;
            //if ( iter_x == MultiMediaNotifications.Count() )
              //last_iter = true;

            
            //UserInfo ui = new UserInfo();
            
            //ui.userid       = ManPageNotification.userID;
            //ui.userGroup    = ManPageNotification.userGroup;
            //ui.userRank     = ManPageNotification.userRank;


           //https://stackoverflow.com/a/5983025

           //https://stackoverflow.com/a/1817332

           //https://stackoverflow.com/a/41455988

            result = MBA.Email.sendAnnouncementAsHtmlWithHeroImageAndRichText(

                //0,  // userMsgId; these messages don't have a corresponding dialog widget to open, so the URL param openmsgmodal
                      // will not be applicable

                false, // promptUserToGotoURL
                null,
                null,  // ManPage notifications will also not have a gotoURL callback, at least for this release

                Constants.APP_EMAIL_FROM,
                n.email,
                "" , 
                n.title , // newManPageSubject,
                "",

                var_msg_content , //n.content,

                MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL,
                                                     

              out retStatus
            );


            if (result == true)
            {
              
              DisplayNotice  (  Return.RET_SUCCESS
                              , @"Sent multimedia message to {0} "
                              , n.email
                              //, ManPageNotification.clientName 
                              );

              DisplayNotice  (  Return.RET_INFO
                              , @"Logging user response for {0}"
                              , n.email
                             );

              
                             
              ReturnSaveRecord rs = Spedmon.NewsletterPages.logSaveMessageSentNow(dbConnApp
                                                                      , log
                                                                       , uInfo
                                                                       , Constants.APP_NAME
                                                                       , n.email
                                                                       , n.recipientClientID.ToString()
                                                                       , n.contactID.ToString()
                                                                       , n.recipUserID.ToString()
                                                                       , n.revisionNum.ToString()
                                                                       , ( n.is_last_iter_per_batch ? "1" : "0" )
                                                                       , n.id.ToString() );
            }
            else
            {
              DisplayNotice  (  Return.RET_WARNING
                              , @"Unable to send multimedia message to {0} at {1} "
                              , n.email
                              //, "" //ManPageNotification.clientName
                              , retStatus );                                                                                                                      

            }

            // TODO: for testing purposes, send exactly ONE email with each test run.
            //       COMMENT/REMOVE before going live
            //return _result;  

        }        
      }
      catch (Exception err)
      {
        DisplayNotice  (  Return.RET_WARNING
                              , @"Exception thrown : {0}"
                              , err.Message
                        );                                                                                                                      

                
        _result = false;
      }
                

      return _result;    

    }

    
    /***************************************************************************
     * ProcesMultiMediaPageUserNotifications */
    /**
     * 
     ***************************************************************************/   

    static bool ProcesMultiMediaPageUserNotifications ()
    {

      bool _result = true;
      DisplayNotice (Return.RET_INFO,"Processing newsletter notifications (if any)");

      string spedCareURI = @"https://www.spedcare.com";
       
      try
      {
        if (!GetMultiMediaContentUserResponsesList())                return false;
        if (!ProcessMultiMediaContentUserResponsesList(spedCareURI)) return false;

      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }
      return _result;
    }

    /***************************************************************************
     * ProcesManPageUserNotifications */
    /**
     * 
     ***************************************************************************/   

    static bool ProcessManPageUserNotifications ()
    {

      bool _result = true;

      DisplayNotice (Return.RET_INFO,"Processing help library or announcement notifications (if any)");

      string spedCareURI = @"https://www.spedcare.com";
      string msgTitle    = Messages.MSG_NEW_OR_UNREAD_MAN_PAGES_PART + " on SpEdCare.";
      
      try
      {
          if (!GetContentUserResponsesList())                          return false;
          if (!ProcessContentUserResponsesList(spedCareURI, msgTitle)) return false;
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }
      return _result;
    }
    
    /***************************************************************************
     * GetPatientInfoRequestResponseMassUpdates */
    /**
     * 
     ***************************************************************************/    
	 
    static bool GetPatientInfoRequestResponseMassUpdates() {
      bool _result = true;      
      try
      {
        DisplayNotice (Return.RET_INFO,"Getting list of patient info request response mass update campaigns that are not complete");
        patientInfoRequestsResponsesMassUpdates = Spedmon.PatientInfoRequestsResponsesMassUpdates.viewList(dbConnApp, log, uInfo,"","N");
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }
      return _result;
   }
   
   /***************************************************************************
    * ProcessPatientInfoRequestResponseMassUpdateRows */
   /**
    * 
    ***************************************************************************/ 
	
   static bool ProcessPatientInfoRequestResponseMassUpdateRows (PatientInfoRequestsResponsesMassUpdate patientInfoRequestsResponsesMassUpdate) {
      bool _result = true;            
      try
      {

        DisplayNotice (Return.RET_INFO, "Getting info request response mass update rows for {0}", patientInfoRequestsResponsesMassUpdate.clientName);
        
        string _clientIDStr = patientInfoRequestsResponsesMassUpdate.clientID.ToString();
        string _recIDStr    = patientInfoRequestsResponsesMassUpdate.id.ToString();
        int    _rowCtr      = 1;

        /* Get unprocessed rows */

        var patientInfoRequestsResponsesMassUpdateRows = PatientInfoRequestsResponsesMassUpdateRows.viewList(dbConnApp,log,uInfo,_clientIDStr,_recIDStr,"N","N");
        
        /* Process unprocessed rows */

        foreach (var patientInfoRequestsResponsesMassUpdateRow in patientInfoRequestsResponsesMassUpdateRows) {

          DisplayNotice ( Return.RET_INFO
                         , "Saving new info request for {0} {1}"
                         , patientInfoRequestsResponsesMassUpdate.clientName
                         , patientInfoRequestsResponsesMassUpdateRow.patName);
          
          var _patIDStr = patientInfoRequestsResponsesMassUpdateRow.patID.ToString();
          
          try { 

            var _so = Spedmon.PatientInfoRequestsResponses.saveNewRequestFromMassUpdateRow ( dbConnApp
                                                                                            , log
                                                                                            , uInfo
                                                                                            , _clientIDStr
                                                                                            , _patIDStr
                                                                                            , ""
                                                                                            , patientInfoRequestsResponsesMassUpdateRow.patPerIDs
                                                                                            , "Y"
                                                                                            , "N"
                                                                                            , patientInfoRequestsResponsesMassUpdate.requesterName
                                                                                            , patientInfoRequestsResponsesMassUpdate.requesterEmail
                                                                                            , patientInfoRequestsResponsesMassUpdate.requesterPhone
                                                                                            , patientInfoRequestsResponsesMassUpdate.requestBaseUrl
                                                                                            , patientInfoRequestsResponsesMassUpdateRow.id);            
          
            var _personsOut = PatientInfoRequestsResponsesCommon.parsePatientInfoRequestToPersonsJSONToList(_so.jsonData);
            foreach(var _personOut in _personsOut) {
               if (_personOut.sendEmail == true) { 
                 if (_personOut.sentEmail == true) { 
                       DisplayNotice ( Return.RET_INFO, "Info request emailed successfully to {0}", _personOut.email);
                 } 
                 else {
                       DisplayNotice ( Return.RET_WARNING, "Info request not emailed to {0}", _personOut.email);
                 }
               }
            }
          }
          catch (Exception unprocessedRowErr) {
            DisplayNotice (Return.RET_WARNING, unprocessedRowErr.Message);    
          }
          
          /* We are throttling at 10 rows at a time.  The reason is that it takes time to generate the
           * requests (about 1-2 seconds) and other tasks in this service have to wait.
           */

          _rowCtr++;

          if (_rowCtr >= 10) {               
            break; 
          }

        }  /* Process unprocessed rows*/      
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }      
      return _result;
   }

   /***************************************************************************
    * UpdateStatsPatientInfoRequestResponseMassUpdate */
   /**
    * 
    ***************************************************************************/ 
	
   static bool UpdateStatsPatientInfoRequestResponseMassUpdate (PatientInfoRequestsResponsesMassUpdate patientInfoRequestsResponsesMassUpdate) {
      bool _result = true;            
      try
      {
        DisplayNotice (Return.RET_INFO,"Patient info request response mass updates - Updating stats for {0}",patientInfoRequestsResponsesMassUpdate.clientName);       
        string clientIDStr = patientInfoRequestsResponsesMassUpdate.clientID.ToString();
        string recIDStr = patientInfoRequestsResponsesMassUpdate.id.ToString();
        Spedmon.PatientInfoRequestsResponsesMassUpdates.updateStats(dbConnApp, log, uInfo,clientIDStr,recIDStr);
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }      
      return _result;
   }


   /***************************************************************************
    * ProcessPatientInfoRequestResponseMassUpdate */
   /**
    * 
    ***************************************************************************/   
	
   static bool ProcessPatientInfoRequestResponseMassUpdate() {
      bool _result = true;      
      
      try
      {
        DisplayNotice (Return.RET_INFO,"Processing info request response mass updates (if any)");       

        /* For each campaign that is not completed */
        
        foreach(var patientInfoRequestsResponsesMassUpdate in patientInfoRequestsResponsesMassUpdates) {
          
          /* Process unprocessed rows */
          _result = ProcessPatientInfoRequestResponseMassUpdateRows (patientInfoRequestsResponsesMassUpdate);  
          
          /* Update stats */
          _result = UpdateStatsPatientInfoRequestResponseMassUpdate(patientInfoRequestsResponsesMassUpdate);
        }                
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_ERROR, err.Message);
        _result = false;
      }

      return _result;
   
   }
   
   /***************************************************************************
    * ProcessPatientInfoRequestResponseMassUpdates */
   /**
    * 
    ***************************************************************************/   
	
    static bool ProcessPatientInfoRequestResponseMassUpdates()
    {
      bool _result = true;      
      
      DisplayNotice (Return.RET_INFO,"Processing mass patient info request campaigns (if any)");

      try
      {
        if (!GetPatientInfoRequestResponseMassUpdates())     return false;
        if (!ProcessPatientInfoRequestResponseMassUpdate())  return false;
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_ERROR, err.Message);
        _result = false;
      }
      return _result;
    }

    /***************************************************************************
     * main */
    /**
     * Entry delegate
     ***************************************************************************/   
     
    static void main()
    {
      GetAndCheckAppSettings ();      
      ProcessManPageUserNotifications();
      ProcesMultiMediaPageUserNotifications();
      ProcessPatientInfoRequestResponseMassUpdates();      
    }
        
    /***************************************************************************
     * StartProcessingBulkNotifications */
    /**
     * Entry point
     ***************************************************************************/
	 
    public static void StartProcessingBulkNotifications (string[] args = null)
    {

      /*============================================================
       * Enter application
       *============================================================*/  

      try
      {
                                          
       /*-------------------------------
        * Define main delegate
        *------------------------------*/
        
        GenericCallBack mainDel = delegate {main();};
                   
       /*-------------------------------
        * Start the application
        *------------------------------*/
        
        enter(Spedmon.Constants.APP_NAME, 
              "Generate Bulk Notification Emails", 
              Spedmon.Constants.APP_VERSION, 
              ref args, 
              ref mainDel);        
      }
                    
      /*============================================================
       * Exception handler of last resort
       *============================================================*/  
       
      catch (Exception e)
      {
        /*-------------------------------
         * Let the user know and indicate
         * a fatal state in our exit state
         *------------------------------*/
        
        DisplayNotice(Return.RET_FATAL, e.Message);
        exitState = Return.RET_FATAL;
      }

     /*============================================================
      * Clean up
      *============================================================*/

      finally
      {
        cleanup();        
      }
                  
    }
  }
}
