USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_CONTACTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_CONTACTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_CONTACTS_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @active              BIT 
  , @term		         VARCHAR(256)
  , @recID               BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLIENT_CONTACTS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

select top (dbo.CONST_MAX_ROWS())
	  cc.[id]
	, cc.contactName       as [name]
	, cc.clientID        
	, cc.contactName         
	, cc.contactRoleID   
	, ccr.[name]		   as contactRoleName         
	, cc.email             
	, isNULL(cc.phone, '') as phone 

from [dbo].[CLIENTS_Contacts] as cc
LEFT JOIN [dbo].[CLIENT_CONTACT_ROLES] as ccr
ON cc.contactRoleID = ccr.[id]

where  (
      (1=1)
      AND
      ((@clientID is null) or (cc.clientID = @clientID))
      -- needs to be able to query all clients at once, to use a JOIN rather than an APPLY.
      -- otherwise not scalable

  and ((@active is null) or (cc.active = @active))
  and ((@recID  is null) or (cc.[id]   = @recID))
  and ((@term   is null) or (cc.contactName like (('%' + @term + '%'))))
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_CONTACTS_VIEW] TO [webuser]
GO  
