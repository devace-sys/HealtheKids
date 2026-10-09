USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_ROSTER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_ROSTER_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @clientID       bigint
  , @active         bit
  , @recID          bigint
  
)    
RETURNS 
TABLE
AS
RETURN
(

  select top (dbo.CONST_MAX_ROWS())
      id                  = rpr.id
	, [name]              = fyq.QTR_DEFINITION 
	, [startDate]         = fyq.QTR_START
	, [endDate]           = fyq.QTR_END
	, [active]            = rpr.active 
	, [notes]             = ''
	, clientID            = clc.CLIENT_ID
	, clientName          = clc.CLIENT_NAME	
	, fyID                = fy.ID
	, fyName              = fy.FY_DEFINITION
	, fyStartDate         = fy.FY_START
	, fyStartDateStr      = dbo.RPT_DATE_FMT(fy.FY_START)	
	, fyEndDate           = fy.FY_END
	, fyEndDateStr        = dbo.RPT_DATE_FMT(fy.FY_END)	
	
	, quarterID           = fyq.ID 	
	, quarterName         = fyq.QTR_DEFINITION
	, quarterStartDate    = fyq.QTR_START
	, quarterStartDateStr = dbo.RPT_DATE_FMT(fyq.QTR_START)
	, quarterEndDate      = fyq.QTR_END
	, quarterEndDateStr   = dbo.RPT_DATE_FMT(fyq.QTR_END)
	, quarterStartDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(fyq.QTR_START)
	, quarterEndDateStrYMD	 = dbo.RPT_DATE_FMT_YYYY_MM_DD(fyq.QTR_END)


	, quarterNumber       = fyq.QTR	
	
	, participantsJSON    = rpr.participantRosterJSON

    -- note: don't know why the list of partipants (here) is stored as a JSON blob;
    -- apparently we also have an RMTS_PARTICIPANTS table.  Don't know if one or both are being
    -- updated/revised, don't know which is more current and reliable

    -- guessing that this is the original, untouched data import from an excel/csv upload somewhere.
    -- Would have named this orig_data_import if that is the case

	, rp2.numParticipants



  from  dbo.RMTS_PARTICIPATION_ROSTER as rpr
  join  dbo.CLIENTS_Client            as clc on clc.CLIENT_ID = rpr.clientID
  join  dbo.COMPANY_FISCAL_QUARTERS   as fyq on fyq.id        = rpr.quarterID
  join  dbo.COMPANY_FISCAL_YEARS      as fy  on fy.ID         = fyq.FY_ID
  
  cross apply (
    select 
	  numParticipants = count(rp1.id) 
	from dbo.RMTS_PARTICIPANTS as rp1 
	where (rp1.rosterID = rpr.id)
  ) as rp2

  where (
         (1=1)
    and (rpr.clientID = @clientID)
    and ((@recID is null) or (rpr.id = @recID))
  )
  
  order by 
     fyq.QTR_DEFINITION
   
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPATION_ROSTER_VIEW] TO [webuser]
GO
