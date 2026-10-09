USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE] ( 
    @sessionID    bigint
  , @sigClassName varchar(512)
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE */
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

with
cte_p1
as
(
  select
       tsp.idx
     , tsp.id
     , tsp.name
     , tsp.title
     , email             = trim(isnull(tsp.email,''))
     , signatureID       = isnull(tsSigned.signatureID,0)
	 , signed            = convert(bit,isnull(tsSigned.signed,0))
     , signedOn          = tsSigned.signedOn
	 , sigAdditionalData = tsSigned.sigAdditionalData
  from dbo.TELECOMM_SESSIONS              as ts
  join dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.telecommSessionID = ts.id 
  
  /* Get latest */
  
  outer apply ( 
     select top 1 
          signatureID = tss.id
		, signed      = 1
	    , signedOn    = tss.recordedOn
		, sigAdditionalData = tss.sigAdditionalData
    from dbo.TELECOMM_SESSIONS_SIGNATURES as tss
    where (
          (tss.telecommSessionID            = ts.id)
      and (tss.telecommSessionParticipantID = tsp.id)
      and (tss.sigClassName                 = @sigClassName)
    )
    order by 
      tss.id desc 
  ) as tsSigned

  where 
    (ts.id = @sessionID) 
)
,
cte_p2
as
(
  select 
      p1.* 
    , [signature]     = case when (p1.signed = 1) then 'Electronically signed by ' + p1.[name] else '' end
    , [dateSignedStr] = dbo.RPT_DATE_FMT(p1.signedOn)
  from cte_p1 as p1
  where (p1.email != '')
)
select * from cte_p2 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE] TO [webuser]
GO


