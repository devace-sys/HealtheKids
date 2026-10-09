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

/*#####################################################################################################
 *                                      IMPORTANT PLEASE READ
 *
 *                     This service is DEDICATED to user message notifications.
 * It is critical it remain that way because of the time sensitive nature of some of the possible 
 * messages.  This includes patient referal notifications that may need to be sent out ASAP.
 * 
 *               Please do not add any additional notification processing logic to this service.
 * 
 *####################################################################################################*/

namespace Spedmon
{
  
  /***************************************************************************
   * ProcessEmailNotifications */
  /**
   * Application class
   ***************************************************************************/   

  public class ProcessEmailNotifications:BatchApplication
  {

    protected static string newManPageSubject           = "";
    protected static string newManPageHead              = "";
    protected static string newManPageBodyStart         = "";
    protected static string newManPageBodyEnd           = ""; 
    protected static string PracSupSvcsToReviewMsgTitle = "";
    protected static string PracSupSvcsToReviewMsgBody  = "";

    protected static List <UserMessage> UserMessagesFlagedForEmailAndNotYetSent = null;

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
     * GetUserMessagesFlaggedForEmailAndNotYetSent */
    /**
     * 
     ***************************************************************************/   

    static bool GetUserMessagesFlaggedForEmailAndNotYetSent() 
    {
      bool _result = true;

      try
      {
        DisplayNotice (Return.RET_INFO,"Getting list of user messages flagged for email and not yet sent");
        
        UserMessagesFlagedForEmailAndNotYetSent = null;
        UserMessagesFlagedForEmailAndNotYetSent = new List<UserMessage>();
        UserMessagesFlagedForEmailAndNotYetSent = Spedmon.UserMessages.viewWaitingToEmailList(dbConnUser, log, uInfo);
        _result = true;
      }
      catch (Exception err)
      {
         DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }
      return _result;
    }    

    /***************************************************************************
     * ProcessUserMessagesFlaggedForEmailAndNotYetSent */
    /**
     * 
     ***************************************************************************/   

    static bool ProcessUserMessagesFlaggedForEmailAndNotYetSent()
    {     
      bool _result = true;
      
      try
      {   
        DisplayNotice (Return.RET_INFO,"Processing list of user messages flagged for email and not yet sent (if any)");
        
        if (UserMessagesFlagedForEmailAndNotYetSent.Count == 0)
        {
           DisplayNotice (Return.RET_INFO,"No user messages to send emails out for");
           return _result;
        }
        else
        {
           DisplayNotice (Return.RET_INFO,"{0} user message emails to send out",UserMessagesFlagedForEmailAndNotYetSent.Count.ToString());
        }
             
        foreach (var userMsg in UserMessagesFlagedForEmailAndNotYetSent)
        {
                        
            bool   result    = false;
            string retStatus = "";
            
            UserInfo ui = new UserInfo();
            
            ui.userid    = userMsg.recipientUserID;
            ui.userGroup = userMsg.recipientUserGroup;
            ui.userRank  = userMsg.recipientUserRank; 
            
            string subject = "";
            if (!String.IsNullOrWhiteSpace(userMsg.subject)) {
              subject = userMsg.subject;              
            }

            if ((userMsg.recipIsPcalStaff) && (!(String.IsNullOrWhiteSpace(userMsg.senderClientName))) && (!(String.IsNullOrWhiteSpace(userMsg.senderName)))) {
              subject = subject + " (From " + userMsg.senderName + " - " + userMsg.senderClientName + ")";
            }
                                      
            result = MBA.Email.sendMessageHtmlWithHeroImage60pct(

                //  UserMsg.messageID
                // to implement the openmsgmodal URL param in a future release
                  
                  userMsg.promptUserToGotoURL
                , userMsg.gotoURL
                , userMsg.recipientUserName

                , Constants.APP_EMAIL_FROM
                , userMsg.recipientEmail

                , subject                       
                       
                , userMsg.body

                , MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL


                , userMsg.respPromptOptionsBitwise
                , userMsg.respPromptOptionsJSON
                , out retStatus);

            if (result == true)
            {
              
              DisplayNotice  (  Return.RET_SUCCESS, @"Sent message to {0}", userMsg.recipientEmail);

              DisplayNotice  (  Return.RET_INFO, @"Flagging email sent for {0}", userMsg.recipientEmail);                
              Spedmon.UserMessages.recordOpFlagAsEmailed(dbConnUser,log,uInfo,"N","",userMsg.id.ToString());

            }
            else
            {
              DisplayNotice  (  Return.RET_WARNING
                              , @"Unable to send message to {0} : {1}"
                              , userMsg.recipientEmail                                                   
                              , retStatus );                                                                                                                      

            }
        }        
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
        _result = false;
      }

      return _result;    
        
    }

    /***************************************************************************
     * ProcessUserMessagesThatAreFlaggedToEmailAndNotYetSent */
    /**
     * 
     ***************************************************************************/   

    static bool ProcessUserMessagesThatAreFlaggedToEmailAndNotYetSent ()
    {
      bool _result = true;      
      
      DisplayNotice (Return.RET_INFO,"Processing user message notifications (if any)");

      try
      {
          if (!GetUserMessagesFlaggedForEmailAndNotYetSent())     return false;
          if (!ProcessUserMessagesFlaggedForEmailAndNotYetSent()) return false;
      }
      catch (Exception err)
      {
        DisplayNotice (Return.RET_WARNING, err.Message);
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
      ProcessUserMessagesThatAreFlaggedToEmailAndNotYetSent();
    }
        
    /***************************************************************************
     * StartProcessingEmailNotifications */
    /**
     * Entry point
     ***************************************************************************/
    public static void StartProcessingEmailNotifications (string[] args = null)
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
              "Generate Notification Emails", 
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
