USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_VIEW_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENTS_VIEW_ALL
GO

-- TODO: Remove once we have verified this is no longer needed

/*-------------------------------
 * Object Definition
 *------------------------------*/

/*
CREATE FUNCTION [dbo].[CLIENTS_VIEW_ALL]    
(@name        VARCHAR(50),    
 @activeLEA   BIT,    
 @activeMAA   BIT,    
 @clientID    INT)    
 RETURNS TABLE AS RETURN(    
   select     c.CLIENT_ID                   as id,    
              c.CLIENT_NAME                 as name,    
              c.CLIENT_CDS                  as cds,    
              isnull(cn.note,'')            as notes     
   from       CLIENTS_Client                as c     
   left join  INPUT_NOTES_CLIENT(@clientID) as cn on cn.clientID = c.CLIENT_ID     
   where (1=1)     
   and ((@name      is null) or (c.CLIENT_NAME like (@name + '%')))     
   and ((@activeLEA is null) or (c.LEA           = @activeLEA))    
   and ((@clientID  is null) or (c.CLIENT_ID     = @clientID))    
 )    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[CLIENTS_VIEW_ALL] TO [webuser]
GO*/