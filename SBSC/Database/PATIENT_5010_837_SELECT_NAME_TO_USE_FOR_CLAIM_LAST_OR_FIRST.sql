USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST] (  @LAST_NAME       nvarchar(50)
                                                                                     , @FIRST_NAME      nvarchar(50)
												                                     , @DHCS_LAST_NAME  nvarchar(50) 
												                                     , @DHCS_FIRST_NAME nvarchar(50)
												                                     , @LORF            char(1))
RETURNS nvarchar(50)
WITH SCHEMABINDING
AS     
BEGIN    
  
  /*
    Note: This function was designed to plug right in to the existing Claims_Write_5010_837_File.sql logic as of 2/19/2019.
  */

  /* If L or F is not passed in we assume nothing and get out */

  set @LORF = upper(isnull(@LORF,N''))
  if (@LORF = N'') return null
  
  declare @LNAME as nvarchar(50) = N''
  declare @FNAME as nvarchar(50) = N''
  
  set @LAST_NAME        = trim(isnull(@LAST_NAME       ,N''))
  set @FIRST_NAME       = trim(isnull(@FIRST_NAME      ,N''))
  set @DHCS_LAST_NAME   = trim(isnull(@DHCS_LAST_NAME  ,N''))
  set @DHCS_FIRST_NAME  = trim(isnull(@DHCS_FIRST_NAME ,N''))
      
  /* If we have a complete last and first dhcs name pair we want to use it for the patient name elements in 837 */
  
  if ((@DHCS_LAST_NAME != N'') and (@DHCS_FIRST_NAME != N''))
  begin
    set @LNAME = @DHCS_LAST_NAME 
    set @FNAME = @DHCS_FIRST_NAME
  end
  
  /* Otherwise we use the regular first and last name.  These should always be populated. */
  
  else if ((@LAST_NAME != N'') and (@FIRST_NAME != N''))
  begin
    set @LNAME = @LAST_NAME 
    set @FNAME = @FIRST_NAME
  end

  /* Otherwise if we reach this point this patient record is missing its first and/or last name fields.  Not good.*/
  
  else
  begin
    set @LNAME = null
	set @FNAME = null
  end

  /* Return last or first name depending on argument */
  
  if (@LORF = N'L') return @LNAME
  if (@LORF = N'F') return @FNAME
  
  return null
    
end 

GO
