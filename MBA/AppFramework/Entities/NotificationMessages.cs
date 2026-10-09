using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
    /***************************************************************************
     * NotificationMessage */
    /**
     * 
     **************************************************************************/
  
    public class NotificationMessage
    {                         	    
      public long    fromUserID;
      public string  fromUserName;
	  public string  fromEmail;
      public long    forUserID;
	  public string  forUserName;
      public string  forEmail;
      public string  msgTitle;
      public string  msgBody;
      public bool    msgIsHTML;      
    }  

    public class NotificationMessages
    {
      /***************************************************************************
       * emailNotificationMessages */
      /**
       *
       ***************************************************************************/     
      public static void emailNotificationMessages (List<NotificationMessage> messages)
      {

        foreach (NotificationMessage message in messages)
        {            
          string retStatus = "";
          Email.sendMail(message.forEmail
                        , message.msgTitle 
                        , message.msgBody
                        , message.msgIsHTML
                        , out retStatus);
        }          
      }


    }   
}
