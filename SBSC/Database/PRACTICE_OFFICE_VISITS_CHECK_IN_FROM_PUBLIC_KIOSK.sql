USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK] (
    @userIP                             varchar(500)                      
  , @userAgent                          varchar(8000)        
  , @ptkn                               varchar(512) 
  , @studentID                          nvarchar(50)
  , @practiceOfficeVisitReasonID        bigint
  , @practiceOfficeVisitReasonNotes     varchar(2000) /* Limit for non user is 2000 */  
)  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @tranOpen            as bit = 0
declare @userID              as bigint    
declare @userGroup           as int  
declare @userRank            as int
declare @clientID            as bigint
declare @groupSvcClassNameID as bigint
declare @siteID              as bigint
declare @spDetails           as varchar(8000) 
declare @saveType            as int           
declare @kioskID             as bigint
declare @recordID            as bigint 

set @saveType    = 0
set @recordID    = 0
set @spDetails   = ''
set @tranOpen    = 0
set @userID      = 0 /* Default for system */
set @userGroup   = 2
set @userRank    = 9
set @recordID    = 0

BEGIN TRY

/*============================================================
 * Find kiosk and populate client, site, and groupSvcClassName 
 *============================================================*/  

set @kioskID = -1

select top 1
     @kioskID             = isnull(pok.id,-1)
   , @groupSvcClassNameID = pok.groupSvcClassNameID
   , @clientID            = pok.clientID
   , @siteID              = pok.siteID
from dbo.PRACTICE_OFFICE_KIOSKS as pok
where ( 
      (pok.publicToken = @ptkn)
  and (pok.active = 1)
)

if (@kioskID = -1)
begin
  RAISERROR ('Kiosk not found', 11, 1)
end

/*============================================================
 * Call core 
 *============================================================*/  

begin transaction
set @tranOpen = 1
  
exec dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE 
    @userID 
  , @userGroup
  , @userRank 
  , @userIP
  , @userAgent
  , @clientID 
  , @groupSvcClassNameID 
  , @siteID 
  , @kioskID
  , @studentID
  , @practiceOfficeVisitReasonID 
  , @practiceOfficeVisitReasonNotes 
  , @recordID    OUTPUT
  , @spDetails   OUTPUT
  , @saveType    OUTPUT  

commit transaction
set @tranOpen = 0

/*============================================================
 * All done
 *============================================================*/  

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any
   * error error messages to    
   * the caller    
   *------------------------------*/    
       
 if (@tranOpen = 1) 
 begin
   rollback transaction
   set @tranOpen = 0
 end
 
  -- Error or raise error with severity 11 to 19 will be caught here    
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK] TO [webuser]
GO
