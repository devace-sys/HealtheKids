USE SPEDMON
GO
 

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_Notes_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENTS_Notes_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENTS_Notes_VIEW] (
    @userID                bigint
  , @userGroup             bigint    
  , @userRank              int     
  , @active                bit
  , @recID                 bigint
  , @clientID              bigint
  , @sharedWithClient      bit
  , @topicID               bigint
  , @clientsFilteredForConsultant  bit
)
    
returns table     
as
 
return 
( 
   
   select
        cn.*                      
      , nt.[name]       as topicName 
      , u.UserName      as createdByUserName
      , cc.CLIENT_NAME  as clientName
      , dbo.RPT_DATE_FMT_YYYY_MM_DD(cn.created)   as createdOnYMD
	  , dbo.RPT_DATE_FMT(cn.[created])            as createdOnStr
    
	from  dbo.CLIENTS_Notes        as cn
    join  dbo.CLIENTS_Notes_Topics as nt on nt.id        = cn.topicID
    join  dbo.CLIENTS_Client       as cc on cc.CLIENT_ID = cn.clientID
    join  users.dbo.Users          as u  on u.userrid    = cn.createdBy

    LEFT JOIN  dbo.CLIENTS_Client_Reps as ccr
               ON (
               --@clientID IS NULL
               --AND
               @clientsFilteredForConsultant = 1
               AND (
                  ccr.id = cc.ClientRepIDLEACurrent
                  OR
                  ccr.id = cc.ClientRepIDMAACurrent
                  )
               )

    where ( 
          (1=1)
      and ((cn.clientID         = @clientID)         or (@clientID is null))
      and ((cn.topicID          = @topicID)          or (@topicID  is null))
      and ((cn.active           = @active)           or (@active   is null))
      and ((cn.id               = @recID)            or (@recID    is null))   
      and ((cn.sharedWithClient = @sharedWithClient) or (@sharedWithClient is null))
      and (
            @clientsFilteredForConsultant = 0
            OR
            @clientID IS NOT NULL
            OR
            ( @userID = ccr.user_id )
     )
    )
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENTS_Notes_VIEW] TO [webuser]
GO