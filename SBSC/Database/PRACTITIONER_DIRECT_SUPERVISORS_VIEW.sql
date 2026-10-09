USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISORS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PRACTITIONER_DIRECT_SUPERVISORS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_DIRECT_SUPERVISORS_VIEW] (
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
      id                  = ppds.id
	, [name]              = prp.CONCAT_NAME + N' - ' + gg.GROUP_NAME  
	, clientID            = clc.CLIENT_ID
	, clientName          = clc.CLIENT_NAME	
	, pracID              = prp.PRACTITIONER_ID
	, pracName            = prp.CONCAT_NAME
	, groupID             = gg.GROUP_ID
	, groupName           = gg.GROUP_NAME
	, ppds.supervisingPracDetailsJSON
	, [supervisingPracDetailsStr] = isnull(sups4.supervisingPracDetailsStr,'')
	, [active]                    = ppds.active
		
  from  dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISORS as ppds  
  join  dbo.CLIENTS_Client                               as clc on clc.CLIENT_ID       = ppds.clientID
  join  dbo.PRACTITIONER_Practitioner                    as prp on prp.PRACTITIONER_ID = ppds.pracID
  join  dbo.PRACTITIONER_GROUPS                          as prg on prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                                and prg.GROUP_TYPE in (1,2)
  join  dbo.GROUP_Group                                  as gg  on gg.GROUP_ID         = prg.GROUP_ID
                                                                and prg.GROUP_TYPE in (1,2)

  outer apply (
    select 
	  supervisingPracDetailsStr = STRING_AGG(convert(varchar(max)
	  ,  '* ' +
	     + sups3.supervisingPracName 
	     + ' (' 
		 + startDateStr 
		 + ' to ' 
		 + endDateStr 
		 + ')'
	  )
	  
	  , (' ' + CHAR(13))) from
    (
	  select 
	    sups2.*
	  from
	  (
	    select 
            supervisingPracName = sups1.supervisingPracName  
	      , startDate            = case when trim(sups1.startDateStr) = '' then null else convert (date,sups1.startDateStr) end
          , endDate              = case when trim(sups1.endDateStr)   = '' then null else convert (date,sups1.endDateStr)   end
          , startDateStr
		  , endDateStr
		FROM OPENJSON(ppds.supervisingPracDetailsJSON,'$')
        WITH (
              supervisingPracName varchar(256) '$.supervisingPracName' 
			, startDateStr        varchar(256) '$.startDate'
            , endDateStr          varchar(256) '$.endDate'
        ) as sups1
      ) as sups2
      where (
	        (sups2.startDate is not null) 
		and ((sups2.endDate is null) or (sups2.endDate >= convert(date,getdate())))
	  )
	) as sups3
) as sups4

where (
      (1=1)
  and (ppds.clientID = @clientID)
  and ((@recID is null) or (ppds.id = @recID))
)  
order by 
  prp.CONCAT_NAME  
   
)
GO

GRANT SELECT ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISORS_VIEW] TO [webuser]
GO
