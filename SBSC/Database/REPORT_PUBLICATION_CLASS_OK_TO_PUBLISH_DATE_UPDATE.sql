USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE]     
(
  @rptPubClsID             BIGINT,
  @OKToPublishUpToDate     VARCHAR(1000)
)    

AS    
BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE */    
/**    
 * Updates OK to publish date for the given publication class id
 *
 * @param   rptPubClsID          The record id of the given class
 * @param   OKToPublishUpToDate  The latest date that is is OK to publish
 *                               reports for
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @OldDate AS DATETIME    
DECLARE @NewDate AS DATETIME
DECLARE @Msg     AS VARCHAR(1000)
DECLARE @ClsName AS VARCHAR(1000)

/*-------------------------------    
 * Validate rptPubClsID  
 *
 * Note: Only user editable
 * class ids should be allowed
 *------------------------------*/ 

IF (@rptPubClsID <> 1) 
BEGIN
  RAISERROR ('Invalid report publication class id', 11, 1)    
  RETURN (1)  
END

/*-------------------------------    
 * Validate and convert
 * OK to publish date
 *------------------------------*/ 

BEGIN TRY
  SET @NewDate = DATEADD(dd, 0, DATEDIFF(dd, 0, CONVERT(datetime,@OKToPublishUpToDate)))
END TRY
BEGIN CATCH
  RAISERROR ('Invalid date', 11, 1)    
  RETURN (1)  
END CATCH  

/*-------------------------------    
 * Fetch old record
 *------------------------------*/   

select @ClsName = Name, @OldDate = OKToPublishUpToDate FROM REPORT_PUBLICATION_CLASSES  WHERE ID = @rptPubClsID 

/*-------------------------------    
 * Display class name and
 * old OK to pub value
 *------------------------------*/   

print @ClsName
set @Msg = 'Old OK to Publish Up To Date : ' + CONVERT(varchar(255),@oldDate)
print @Msg

/*-------------------------------    
 * Update record
 *------------------------------*/    
    
UPDATE REPORT_PUBLICATION_CLASSES 
  SET OKToPublishUpToDate = @NewDate
WHERE ID = @rptPubClsID
  
/*-------------------------------    
 * Display new value
 *------------------------------*/    

set @Msg = 'New OK to Publish Up To Date : ' + CONVERT(varchar(255),@NewDate)
print @Msg

RETURN(0)    
END
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE] TO [webuser]
GO
