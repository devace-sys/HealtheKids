USE users
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[APP_MAN_PAGES_DATA_CORE] (
   @appName        varchar(50)
 , @okToDisplay    bit

 -- TODO: consider adding a filter by include_in_welcome_package

 , @active         bit
 , @timeToDisplay  bit
 , @refDate        datetime
 , @includeContent bit
 , @recID          bigint
)
RETURNS TABLE
AS
RETURN
(

/***************************************************************************
 * APP_MAN_PAGES_DATA_CORE */
/**
 * Displays user data
 *
 * @return                 Table of user data
 ***************************************************************************/

select
  q1.*
from
(
  select
       mp.id
     , mp.appName
     , mp.startDate
     , mp.endDate
     , mp.title
     , mp.description
     , content = (case when ( isnull( @includeContent, convert(bit,1 )) = 1) then mp.content else '' end)
     , mp.okToDisplay

     , mp.include_in_welcome_package
     , mp.display_order
     
     , mp.created
     , mp.createdBy
     , mp.lastModified
     , mp.lastModifiedBy
     , mp.active
     , [name]          = mp.title
     --, [timeToDisplay] = convert(bit,case when isnull(@refDate,getdate()) between isnull(getdate(),mp.startDate) and isnull(mp.endDate,getdate()) then 1 else 0 end)
	 , [timeToDisplay] = convert(bit,iif(
	     /*if today or ref date >= startDate*/
	     ( (convert(date,(isnull(@refDate,getdate()))))  >= (convert(date,(isnull(mp.startDate,getdate())))) )
	   , 1
	   , 0 ))
	 , mp.featuredImgFileData
	 , mp.includeOnDashboard

  from dbo.AppManPages as mp

  where (
          (mp.appName = @appName)
      and ((@okToDisplay is null) or (mp.okToDisplay = @okToDisplay))
      and ((@active      is null) or (mp.active      = @active     ))
      and ((@recID       is null) or (mp.id          = @recID      ))
  )

) as q1
where (
      (1=1)
  and ((@timeToDisplay is null) or (timeToDisplay = @timeToDisplay))
)
)

GO
