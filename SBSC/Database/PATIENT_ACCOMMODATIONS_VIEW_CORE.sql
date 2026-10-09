USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ACCOMMODATIONS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_ACCOMMODATIONS_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_ACCOMMODATIONS_VIEW_CORE] (
    @clientID              bigint     
  , @patID                 bigint
  , @recordType            int
  , @term				   VARCHAR(50)
  , @refDate               date 
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
  , @today                 datetime
)
    
returns table     
as
 
return 
(    
with
cte_p0
as
(
  select 
      pa.*
    
	, clientID                 = pc.CLIENT_ID
    /* Record type */
	, recordTypeStr            = case pa.recordType
								     when 1 then 'Accommodation'
									 when 2 then 'Modification'
									 when 3 then 'Personnel Support'
									 else ''
								   end
	/* Status */
	, statusStr                = case pa.status
								     when 1 then 'Draft'
									 when 2 then 'Active'
									 when 3 then 'Discontinued'
									 else ''
								   end
	/* Dates */
    , startDateStr             = dbo.RPT_DATE_FMT(pa.startDate)
    , endDateStr               = dbo.RPT_DATE_FMT(pa.endDate)
	, startDateYYYYMMDD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(pa.startDate)
	, endDateYYYYMMDD          = dbo.RPT_DATE_FMT_YYYY_MM_DD(pa.endDate)
	/* Active */
    , activeStr                = dbo.RPT_BIT_TO_YN (pa.active)
	/* Section helpers */
	, isAssessmentSupport      = case when pa.appliesToNames like '%Assessment%' then 1 else 0 end
	, isDiscontinued           = case when pa.status = 3 then 1 else 0 end
  from  dbo.PATIENTS_Client          as pc   
  join  dbo.PATIENTS_Accommodations  as pa  on  pa.patID = pc.PATIENT_ID
  where (
        (1=1)
    and ((@clientID is null) or (pc.CLIENT_ID  = @clientID))
    and ((@patID    is null) or (pc.PATIENT_ID = @patID))
	and ((@patID      is null) or (pa.patID      = @patID))
    and ((@recordType is null) or (pa.recordType = @recordType))
    and ((@active     is null) or (pa.active     = @active))
    and ((@recID      is null) or (pa.id         = @recID))
	and ((@refDate  is null) or (pa.endDate >= @refDate) or (pa.endDate is null))
  )
)
,
cte_p1
as
(
  select 
      p0.* 
	, [name]                   = isnull(p0.accommodation, '')
    , selContextHTML = isnull(p0.startDateStr,'')  /* Date range*/
					 + ' to ' 
					 + isnull(p0.endDateStr,'') 
                     + ' - '
					 /* Frequency */
					 + isnull(p0.frequencyName,'') + ' - '
					 /* Location */
					 + isnull(p0.locationName,'')
  from cte_p0 as p0
  where ( 
        (1=1)
    and ((@term is null) or (isnull(p0.accommodation,'') like '%' + @term + '%'))
  )
)
select 
    p1.*
from cte_p1 as p1 
 
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_ACCOMMODATIONS_VIEW_CORE] TO [webuser]
GO