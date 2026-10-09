USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW ( 
    @daysOfWeekSvcProvidedJSON nvarchar(max)
  , @svcType                   int  /* 2 */
  , @svcSubType1               int  /* 2000 = Individual, 2001 = Group */
  , @dow                       int  /* 1 to 5 */
)
 
RETURNS bit
WITH SCHEMABINDING 
AS     
BEGIN        

declare @svcOnDowStr as varchar(50) = ''

set @daysOfWeekSvcProvidedJSON = isnull(@daysOfWeekSvcProvidedJSON,'{}')

if (@svcType is null)                   return null
if (@svcSubType1 is null)               return null
if (@dow is null)                       return null
if (@dow in (0,6))                      return null

/* Treatment */

if (@svcType = 2)
begin

  /* Individual */
  
  if (@svcSubType1 = 2000)
  begin
    set @svcOnDowStr = trim(lower(isnull((case 
         when @dow = 1 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.monInd')
         when @dow = 2 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.tueInd')
	     when @dow = 3 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.wedInd')
         when @dow = 4 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.thurInd')
         when @dow = 5 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.friInd')
         else null end) , N'false')))
  end
  
  /* Group */

  else if (@svcSubType1 = 2001)
  begin
    set @svcOnDowStr = trim(lower(isnull((case 
       when @dow = 1 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.monGrp')
       when @dow = 2 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.tueGrp')
	   when @dow = 3 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.wedGrp')
       when @dow = 4 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.thurGrp')
       when @dow = 5 then JSON_VALUE (@daysOfWeekSvcProvidedJSON, '$.friGrp')
       else null end) , N'false')))
  end
  else 
  begin
    return null
  end

end /* Treatment*/
else
begin
  return null
end

if (@svcOnDowStr = '')       return null
if (@svcOnDowStr = N'true')  return 1
if (@svcOnDowStr = N'false') return 0

return null

END				
				   
GO  
