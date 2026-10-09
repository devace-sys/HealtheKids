USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR
GO    

CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR] (
   @clientID as bigint
 , @pracID   as bigint
 , @qtrNum   as int
 , @today    as date
)
RETURNS BIT
AS
BEGIN

  declare @isOnRoster as bit = null

  if (isnull(@clientID,0) < = 0 )            return @isOnRoster
  if (isnull(@pracID,  0) <= 0)              return @isOnRoster
  if (isnull(@qtrNum,  0) not between 1 and 4) return @isOnRoster
 
  if (@today is null) set @today = convert(date,getdate())
  
  set @isOnRoster = 0
  
  select top 1
  
    @isOnRoster = convert(bit,(iif(rps.id is null,0,1)))
  
  from dbo.COMPANY_FISCAL_YEARS     as fy
  join dbo.COMPANY_FISCAL_QUARTERS  as fq  on fq.FY_ID  = fy.ID

  outer apply (
    select top 1 
      rp.id
    from dbo.RMTS_PARTICIPATION_ROSTER as pr
    join dbo.RMTS_PARTICIPANTS         as rp on rp.pracID = @pracID
                                             and rp.rosterID = pr.id
											 and convert(date, rp.endDate) = fq.QTR_END
    where( 
          (pr.clientID = @clientID)
      and (pr.quarterID = fq.ID)
      and (pr.active = 1)
    )
  ) as rps

  where ( 
          (@today between fy.FY_START and fy.FY_END)
      and (fq.QTR = @qtrNum)
  )

  return @isOnRoster 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR] TO [webuser]
GO