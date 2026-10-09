USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTE_PREFERENCE_TYPES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))

DROP FUNCTION dbo.SVCNOTE_PREFERENCE_TYPES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTE_PREFERENCE_TYPES_VIEW
(
   @userID        INT  
  ,@userGroup     INT    
  ,@userRank      INT
)

RETURNS TABLE AS RETURN (

  select top(dbo.CONST_MAX_ROWS())
    id,
    ShortPrefDesc     as name,
    LongPrefDesc      as [description],
    UseFormattedNotes,
    ShortPrefDesc,
    LongPrefDesc 
  from dbo.SVCNOTE_PREFERENCE_TYPES
  where (UseFormattedNotes = 0)   /* TODO: This is a temp fix to take formatted notes off options */
  order by DisplayOrder
)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTE_PREFERENCE_TYPES_VIEW] TO [webuser]
GO