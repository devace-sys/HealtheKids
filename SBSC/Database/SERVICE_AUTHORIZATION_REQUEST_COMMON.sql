USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE
GO

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA
GO

IF EXISTS (select * from sys.table_types where name = 'NEW_USER_ACCOUNT_DATA')
BEGIN
  DROP TYPE NEW_USER_ACCOUNT_DATA
END
GO

/*-------------------------------
 * New user account data
 * Keep in synch with the 
 * following :
 *
 * SQL Table Types
 * - Users.NEW_USER_ACCOUNT_DATA
 * - Spedmon.NEW_USER_ACCOUNT_DATA
 *
 * C# Classes 
 * - MBA.NewUserAccount
 *------------------------------*/

CREATE TYPE NEW_USER_ACCOUNT_DATA AS TABLE
(
     userName         nvarchar(256)
  ,  firstName        nvarchar(128)
  ,  lastName         nvarchar(128)
  ,  email            nvarchar(256)
  ,  phone            nvarchar(14)  
  ,  pwd              varchar(255)
  ,  districtOrClientName varchar(1000)
  ,  helpOrQuestionsContactInfo varchar(max)
  ,  msgTemplateTitle varchar(1000)
  ,  msgTemplateBody  varchar(max)
)



IF EXISTS (select * from sys.table_types where name = 'NOTIFICATION_MESSAGE_DATA')
BEGIN
  DROP TYPE NOTIFICATION_MESSAGE_DATA
END
GO

/*-------------------------------
 * Message data
 * Keep in synch with the 
 * following :
 *
 * SQL Table Types
 *
 * - Spedmon.NOTIFICATON_MESSAGE_DATA
 *
 * C# Classes 
 * - MBA.NotificationMessage
 *------------------------------*/
 
CREATE TYPE NOTIFICATION_MESSAGE_DATA AS TABLE
(
    fromUserID          bigint
  , fromUserName        nvarchar(256)
  , fromEmail           nvarchar(256)

  , forUserID           bigint
  , forUserName         nvarchar(256)
  , forEmail            nvarchar(256)

  , msgTitle            varchar(2000)
  , msgBody             varchar(max)
  , msgIsHTML           bit
)
GO

