USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PAT_SITE_ON_DOS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PAT_SITE_ON_DOS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PAT_SITE_ON_DOS](@dos DATETIME, @clientID BIGINT, @patID BIGINT) RETURNS BIGINT AS     
BEGIN    
      
  declare @siteID as bigint    
  declare @onDos  as date  
    
  /*-------------------------------    
   * Subsitute for what parms we    
   * can and exit early if required    
   * parameters are not provided    
   *------------------------------*/    
         
  if (@patID    is null) return null    
  if (@clientID is null) return null    
  if (@dos      is null) set @dos = GETDATE()
   
  set @onDos = convert(date,@dos)
  
  /*-------------------------------    
   * Attempt to find the site the    
   * patient is at for the given    
   * date of service.
   * 
   * Note: We take advantage of
   * the clustered indexes for
   * pc and ps... and a patID
   * index on ps.
   * 
   * TODO: Remove datetime to date
   * conversions when ps has just
   * date values for start and end
   * date.  We can take further 
   * advantage of clustered index
   * for ps after this.     
   *------------------------------*/    
      
  select top 1
    @siteID = siteID      
  from    
  (    
    select 
        ps.PATIENT_SCHOOL_ID           as idx
      , ps.SITE_ID                     as siteID    
      , convert(date,ps.START_DATE)    as startDate    
      , convert(date,ps.END_DATE)      as endDate    
        
    from dbo.PATIENTS_CLIENT    as pc  
    join dbo.PATIENTS_School    as ps on ps.PATIENT_ID = pc.PATIENT_ID     
    where ( 
          (pc.CLIENT_ID  = @clientID)    
      and (pc.PATIENT_ID = @patID)
    )
  ) as q1    

  where 
    (@dos between q1.startDate and q1.endDate)
  
  order by 
    q1.idx desc
      
  /*-------------------------------    
   * If the site could not be found    
   * subsitute the Unknown Site Code    
   * for the given clientID    
   *------------------------------*/    
      
  if (@siteID is null)    
    select top 1 @siteID = id from dbo.SITES_VIEW(null,null,null,@clientID,null,null,null,null) where uFlag = 1  
    
  return @siteID    
    
END    
GO
