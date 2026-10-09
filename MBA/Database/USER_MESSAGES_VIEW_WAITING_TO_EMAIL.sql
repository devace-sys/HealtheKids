USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_MESSAGES_VIEW_WAITING_TO_EMAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_MESSAGES_VIEW_WAITING_TO_EMAIL
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[USER_MESSAGES_VIEW_WAITING_TO_EMAIL] (
  @appName  VARCHAR(50)
)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * USER_MESSAGES_VIEW_WAITING_TO_EMAIL */    
 /**    
  * Returns a table of entities
  *    
  * @return  Table 
  ***************************************************************************/     
 

AS RETURN
(
   select 
		  id = umdc1.userMessageID /* Returning the user_message.id instead of message.id */
                , messageID = umdc1.id
		, umdc1.subject
		, umdc1.body
		, umdc1.senderUserID
		, umdc1.senderName 
		, umdc1.active
		, umdc1.created
		, umdc1.okToShow
		, umdc1.hasRead
		, umdc1.recipientUserID
		, umdc1.recipientUserGroup
		, umdc1.recipientUserRank 
		, umdc1.recipientName
		, umdc1.recipientEmail
		, recipientsJSON  = ''
        , umdc1.respPromptOptionsBitwise
        , umdc1.respPromptOptionsJSON

    , recipientUserName
    , promptUserToGotoURL
    , gotoURL


		, umdc1.systemGenerated
		, umdc1.allowReply
		, umdc1.sendEmail
		, umdc1.emailSent
		, createdStr = FORMAT(umdc1.created, 'MM/dd/yyyy hh:mm tt')

   , umdc1.senderClientName 
   ,  umdc1.senderClientID

   , umdc1.recipientClientName 
   , umdc1.recipientClientID

   , umdc1.senderEmail

   , umdc1.recipIsPcalStaff

  from dbo.USER_MESSAGES_DATA_CORE (  @appName
                                    , null /* Sender userID */
	  							    , null /* Receiver userID */
								    , 1    /* @okToShow */
								    , null /* @hasRead */
								    , 1    /*@sendEmail */
								    , 0    /*@emailSent */
								    , 1    /*@active */
								    , null /*@recID*/) as umdc1

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[USER_MESSAGES_VIEW_WAITING_TO_EMAIL] TO [webuser]
GO