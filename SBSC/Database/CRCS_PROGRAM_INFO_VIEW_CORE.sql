USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PROGRAM_INFO_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PROGRAM_INFO_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PROGRAM_INFO_VIEW_CORE] ( 
	     @clientID          Bigint 
	   , @fiscalYearID      Bigint
	   , @active            Bit
	   , @recID             Bigint   
)
     
RETURNS TABLE  

AS RETURN(

  select 
		    cpi.*
		  , contactName              = cc1.contactName
		  , crcsBusinessOfficialName = cc2.contactName
		  , lecOrLgaName             = lol.name
  from dbo.CRCS_PROGRAM_INFO     as cpi
  left join dbo.CLIENTS_Contacts as cc1 on cc1.id = cpi.contactID
  left join dbo.CLIENTS_Contacts as cc2 on cc2.id = cpi.crcsBusinessOfficialID
  left join dbo.LEC_OR_LGA       as lol on lol.id = cpi.lecOrLgaID
  where (cpi.clientID = @clientID)
    and (cpi.fiscalYearID = @fiscalYearID)
    and ((@recID  is null) or (cpi.id     = @recID))
	and ((@active is null) or (cpi.active = @active))
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PROGRAM_INFO_VIEW_CORE] TO [webuser]
GO