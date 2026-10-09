USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Prac_Training_Parse_PracIDs_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Prac_Training_Parse_PracIDs_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Prac_Training_Parse_PracIDs_Core] (
    @clientID       bigint
  , @pracIDsStr     varchar(8000)
)   
RETURNS
TABLE
AS
RETURN
(
  select 
      [idx]       = pid.id
    , [pracID]    = pid.recid 
    , [pracName]  = prp.CONCAT_NAME
    , [pracTitle] = gg.GROUP_NAME
    
  
  from dbo.MULTI_RECORD_ID_PARSE (@pracIDsStr,',') as pid   
  join dbo.PRACTITIONER_Practitioner               as prp on  prp.PRACTITIONER_ID = pid.recID
  join dbo.PRACTITIONER_Client                     as prc on  prc.PRACTITIONER_ID = prp.PRACTITIONER_ID  
  join dbo.PRACTITIONER_GROUPS                     as prg on  prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                          and prg.GROUP_TYPE in (1,2)
                                                          and prg.ACTIVE = 1
  join dbo.GROUP_Group                             as gg  on  gg.GROUP_ID         = prg.GROUP_ID
 

where (
      (1=1)
  and ((@clientID is null) or (prc.CLIENT_ID = @clientID))
)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Prac_Training_Parse_PracIDs_Core] TO [webuser]
GO  