USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_HAS_QUALIFIED_DIRECT_SUPERVISION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_HAS_QUALIFIED_DIRECT_SUPERVISION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_HAS_QUALIFIED_DIRECT_SUPERVISION] ( 
    @pracID  bigint
  , @groupID bigint
  , @dos     date
)
RETURNS BIT
AS     
BEGIN    
    declare @supID as bigint = null
    
	select top 1 

	  @supID = ppds.ID
    
	from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppds
  
    /* Supevisor */
    
	join dbo.PRACTITIONER_Practitioner  as prp on (prp.PRACTITIONER_ID = ppds.SUPERVISING_PRAC_ID) 

    /* Supervisor discipline group = 1 */
  
    join dbo.PRACTITIONER_GROUPS        as prg on ((prg.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (prg.GROUP_TYPE = 1))  
    join dbo.GROUP_Group                as gg  on (gg.GROUP_ID          = prg.GROUP_ID)
  
    /* Supervised group/Supervising group matched pair */

    join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggs on ((ggs.SUPERVISED_GROUP_ID = @groupID) 
	                                                         and (ggs.SUPERVISING_GROUP_ID = gg.GROUP_ID))
  
    /* direct supervision assignments for the supervised practitioner only */
  
    where (
	      (ppds.SUPERVISED_PRAC_ID = @pracID)
	  and (ppds.START_DATE is not null)	  	  
      and ((@dos is null) or (@dos between (ppds.START_DATE) and (isnull(ppds.END_DATE,convert(date,getdate())))))
	  and (ppds.SHARE_NOTES = 0)
	  and (ppds.relationshipTypeID = 10)
    )
    
	if (@supID is not null) return 1
	
	return 0
END  
GO
