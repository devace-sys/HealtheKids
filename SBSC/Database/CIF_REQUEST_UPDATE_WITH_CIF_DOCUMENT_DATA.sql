USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUEST_UPDATE_WITH_CIF_DOCUMENT_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUEST_UPDATE_WITH_CIF_DOCUMENT_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUEST_UPDATE_WITH_CIF_DOCUMENT_DATA]  (
    @userID            bigint
  , @cifFormSubmitted  bit
  , @cifDocNum         varchar(256)
  , @claimID           bigint
)
AS    

BEGIN     
    
print 'This feature is no longer available.  CIF is handled via 837 files now'


/*============================================================
 * Done
 *============================================================*/  

RETURN(0)    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CIF_REQUEST_UPDATE_WITH_CIF_DOCUMENT_DATA] TO [webuser]
GO
