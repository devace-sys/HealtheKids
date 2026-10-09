USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @modifiedBy     BIGINT
  , @recordID       BIGINT
)    
RETURNS 
TABLE
AS
RETURN
(
    select top (dbo.CONST_MAX_ROWS())
	    ua.[userName] as 'name'
	  , CASE
		  WHEN (sjsda.SAVE_TYPE = 1) THEN 'Created'
		  ELSE 'Modified'
	    END as 'action'
	  , CONVERT(varchar(50), sjsda.MODIFIED_ON) as 'date'
	 -- , '{"data_before": "", "data_after": ""}' as 'data'    /* TODO: Remove this once its confirmed there are no remaining dependencies */
  from [dbo].[SvcJournal_Service_Descriptions_Audit] as sjsda

  cross apply ( 
    select top 1 * from [users].[dbo].USERS_ALL as ua1
	where ua1.id = sjsda.MODIFIED_BY
  ) as ua     
    
  where ( 
        (@recordID   is null OR sjsda.RECORD_ID   = @recordID)
    and (@modifiedBy is null OR sjsda.MODIFIED_BY = @modifiedBy)
  )



  order by 
    sjsda.MODIFIED_ON desc
)
GO

GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View] TO [webuser]
GO
