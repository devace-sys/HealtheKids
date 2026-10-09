USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_SERVICE_DETAILS_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_SERVICE_DETAILS_STRING
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_SERVICE_DETAILS_STRING]
(
    @serviceTypeID          int
  , @groupBase              varchar(50)
  , @hasSvcDetailFlags      bit
  , @svcDetFlag1            bit
  , @svcDetFlag2            bit
  , @svcDetFlag3            bit
  , @svcDetFlag4            bit
) 
RETURNS nvarchar(100)
AS     
BEGIN    
 
     declare @serviceDetails  as nvarchar(100)
          
     set @serviceDetails = case when ((@hasSvcDetailFlags = 1) 
                                      and (@serviceTypeID = dbo.CONST_SERVICES_ASSESS())
                                      and (@groupBase     = 'Speech')
                                )
                           then
                               case when @svcDetFlag1 = 1 then ' + Fluency'                 else '' end
                             + case when @svcDetFlag2 = 1 then ' + Sound Production'        else '' end
                             + case when @svcDetFlag3 = 1 then ' + Language Comprehension'  else '' end
                             + case when @svcDetFlag4 = 1 then ' + Voice & Resonance'       else '' end
                           else 
                             ''
                           end
    
     return @serviceDetails
     
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_SERVICE_DETAILS_STRING] TO [webuser]
GO