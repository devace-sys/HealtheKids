USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID('dbo.PATIENT_PROFILE_PICTURES_VIEW') 
    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.PATIENT_PROFILE_PICTURES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.PATIENT_PROFILE_PICTURES_VIEW 
( 
    @userID    bigint 
  , @userGroup int 
  , @userRank  int 
  , @clientID  bigint 
  , @patID     bigint = null 
  , @recID     bigint = null
)
RETURNS TABLE
AS
RETURN 
( 

select top 1
    t1.id
  , t1.clientID
  , t1.patID
  , t1.[fileName]
  , profilePictureBase64 = cast(decompress(t1.profilePictureImgData) as varchar(max))
  , t1.originalSize
  , t1.compressedSize

from dbo.PATIENT_PROFILE_PICTURES as t1
where ( 
      (t1.clientID = @clientID)
  and (t1.patID    = @patID)
  and ((@recID is null) or (t1.id = @recID))
  and (t1.active = 1)
)
)
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON dbo.PATIENT_PROFILE_PICTURES_VIEW TO [webuser]
GO