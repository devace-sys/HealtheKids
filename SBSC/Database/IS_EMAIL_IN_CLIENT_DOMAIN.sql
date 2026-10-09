USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_EMAIL_IN_CLIENT_DOMAIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_EMAIL_IN_CLIENT_DOMAIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[IS_EMAIL_IN_CLIENT_DOMAIN] (@clientid BIGINT, @email varchar(1000))    
returns bit 
    
/***************************************************************************    
 * IS_EMAIL_IN_CLIENT_DOMAIN */    
/**    
 * Breaks email up and checks if the domain portion is in the client domains
 * table.
 *    
 * @param   clientID        Client ID
 * @param   email           Email to test
 * @return  bit or null
 ***************************************************************************/            
     
as           
begin    

declare @pos      as int
declare @len      as int
declare @start    as int
declare @end      as int
declare @domain   as varchar(1000)
declare @ID       as bigint

/*-------------------------------    
 * If the clientid is not valid
 * get out
 *------------------------------*/   

if (@clientid is null) return null
if (@clientid <= 0   ) return null

/*-------------------------------    
 * If the email is not valid
 * get out
 *------------------------------*/    

if (@email is null) return null
select @len = len(@email)
if (@len < 3) return null

/*-------------------------------    
 * Find position of @
 *------------------------------*/    

select @pos = charindex ('@',@email)

/*-------------------------------    
 * Find start and end of substring
 * after @.  This should be the
 * domain
 *------------------------------*/    

set @start = @pos + 1
set @end   = @len - @pos

/*-------------------------------    
 * Extract domain from email
 * trim it and lowercase it
 *------------------------------*/    

select @domain = lower(trim(substring(@email,@start,@end)))

/*-------------------------------    
 * Locate domain in table
 *------------------------------*/    
  
set @ID = null

select top 1 
  @ID = d.ID 
from 
  dbo.CLIENTS_DOMAINS as d 
where (
      (d.CLIENT_ID = @clientID) 
  and (lower(trim(d.DOMAIN)) = @domain)
  and (d.ACTIVE = 1)
)

/*-------------------------------    
 * Report results
 *------------------------------*/    

if (@ID is null) return 0
if (@ID <= 0)    return 0
if (@ID > 0)     return 1
    
/*-------------------------------    
 * If we reach this point something
 * unexpected happened
 *------------------------------*/    

return null

end    
    
GO
