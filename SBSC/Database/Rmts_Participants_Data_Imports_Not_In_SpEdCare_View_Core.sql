USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core] ( 
	   @clientID         BigInt    
	 , @fyQuarterID      Bigint
	 , @rmtsDataImportID Bigint
	 , @recID		     Bigint
)
     
RETURNS TABLE  

AS RETURN(

	select
		rp.id
	  , rp.lastName
	  , rp.firstName
	  , rp.middleName
	  , rp.title
	  , rp.email
	  , rp.startDate
	  , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.startDate)
	  , startDateStr    = dbo.RPT_DATE_FMT		     (rp.startDate)
	  , rp.endDate
	  , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.endDate)
	  , endDateStr      = dbo.RPT_DATE_FMT		     (rp.endDate)
	  , rp.rmtsDataImportID
	  , rpd.clientID
	  , rpd.fyQuarterID
	  , clientName = clc.CLIENT_NAME
	from dbo.Rmts_Participants_Data_Imports_Pracs_Not_In_SpEdCare as rp
	join dbo.Rmts_Participants_Data_Imports                       as rpd on rpd.id = rp.rmtsDataImportID
	join dbo.CLIENTS_Client                                       as clc on clc.CLIENT_ID = rpd.clientID
	where ( (1=1)
		and	((@clientID         is null) or (rpd.clientID    = @clientID))
		and ((@fyQuarterID      is null) or (rpd.fyQuarterID = @fyQuarterID))
		and ((@rmtsDataImportID is null) or (rpd.id          = @rmtsDataImportID))
		and (rp.processedPracID is null) -- if processedPracID is not null, it means record has already been processed
		and (rp.active = 1)
		and ((@recID            is null) or (rp.id           = @recID))
		)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core] TO [webuser]
GO