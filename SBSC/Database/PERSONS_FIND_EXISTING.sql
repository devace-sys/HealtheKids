USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_FIND_EXISTING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PERSONS_FIND_EXISTING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PERSONS_FIND_EXISTING] (
    @lastName    varchar(255)
  , @firstName   varchar(255)
  , @email       varchar(255)
  , @phone       varchar(255)
  , @classID1    bigint  
  , @classID2    bigint
) 
RETURNS BIGINT
AS

/***************************************************************************    
 * PERSONS_FIND_EXISTING */    
/**    
 * Finds existing person record based on email, phone, and name
 ***************************************************************************/   
     
BEGIN

set @lastName  = trim(isnull(@lastName,''))
set @firstName = trim(isnull(@firstName,''))
set @email     = trim(isnull(@email,''))
set @phone     = trim(isnull(@phone,''))

declare @personID as bigint = null

/* If all empty then get out */

if ((len(@lastName) = 0) and (len(@firstName) = 0) and (len(@email) = 0) and (len(@phone) = 0)) 
begin
  set @personID = -99
  return @personID
end

/* If name provided but no phone or email get out */

if ((len(@lastName) > 0) and (len(@firstName) > 0) and (len(@email) = 0) and (len(@phone) = 0)) 
begin
  set @personID = -99
  return @personID
end

/* If name and email or name and phone are passed or both */

if (((len(@lastName) > 0) and (len(@firstName) > 0)) and ((len(@email) > 0) or (len(@phone) > 0)))
begin
  
  /* Attempt to find */

  set @personID = null

  select top 1 
      @personID = t1.ID 
  from dbo.PERSONS_PERSON as t1 
  where (
	    (t1.CLASS_ID_1 = @classID1)
	and (t1.CLASS_ID_2 = @classID2)
    and (t1.LAST_NAME  = @lastName)
    and (t1.FIRST_NAME = @firstName)
    and ((t1.EMAIL = @email) or (t1.PHONE = @phone))
  )    
  
end

/* Otherwise get out */

else
begin 
  set @personID = -99
  return @personID
end

/* Exit */

return @personID

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON [dbo].[PERSONS_FIND_EXISTING] TO [webuser]
GO