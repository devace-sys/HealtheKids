USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Qualifications_Parse_JSON_Data_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Qualifications_Parse_JSON_Data_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Qualifications_Parse_JSON_Data_Core] (
    @today                  date     
  , @minDate                date
  , @maxDate                date  
  , @dispGroupID            bigint
  , @qualificationsJSONData varchar(max)
)    
returns table     
as 
return 
(      
  select 
      t3.*
	, ranking = DENSE_RANK() over (partition by t3.primaryQualification, t3.pracTypeID order by t3.endDate desc)
  from
  (
    select
        primaryQualification = convert(bit,(iif((t2.pracTypeID = @dispGroupID),1,0)))
      , t2.*
      , expiresInDays = datediff(day,@today,t2.endDate)
    from
    (
      select
           t1.pracTypeID    
	     , t1.pracTypeName  
	     , licenseNum    = isnull(t1.licenseNum,'')   
	     , startDate     = isnull(t1.startDate, @minDate)
         , endDate       = iif((t1.isLifetime = 0),t1.endDate, @maxDate)
	     , fullName      = isnull(t1.fullName,'')      
	     , isLifetime    = convert(bit,(isnull(t1.isLifetime,0)))
         --, issuanceState = 'CA'
      from OPENJSON(@qualificationsJSONData)
      with (   
              pracTypeID    bigint
	        , pracTypeName  varchar(1024)
	        , licenseNum    varchar(512)
	        , startDate     date
            , endDate       date
	        , fullName      varchar(1024)
	        , isLifetime    bit
  		    --, issuanceState varchar(15) /* Future use */                
      ) as t1
    ) as t2
  ) as t3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Qualifications_Parse_JSON_Data_Core] TO [webuser]
GO
