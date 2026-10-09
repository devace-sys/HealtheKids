USE SPEDMON
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_SITES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_SITES_SAVE
GO

CREATE PROCEDURE [dbo].[PRACTITIONER_SITES_SAVE] (
     @userID                  bigint 
   , @userGroup               bigint
   , @userRank                int
   , @clientID                bigint
   , @pracID                  bigint
   , @siteID				  bigint
   , @editDelReason           varchar (7000)
   , @validateRec             bit
   , @saveType                int
   , @recID                   bigint
   , @MsgNoRec              VARCHAR(1000)
   , @MsgNoEdit             VARCHAR(1000)
   , @MsgDupRec             VARCHAR(1000)
   , @MsgDataError          VARCHAR(1000)
   , @MsgNotActive          VARCHAR(1000)
   , @recordID              BIGINT        OUTPUT
   , @spDetails             VARCHAR(8000) OUTPUT
) 
 AS    
BEGIN    

declare @tranOpen  as bit  
declare @today     as datetime  

set @recordID   = 0    
set @spDetails  = ''    
set @today      = GETDATE()    
set @tranOpen   = 0

BEGIN TRY

  IF NOT EXISTS ( 
       SELECT top 1 
	     pp.PRACTITIONER_ID
       FROM PRACTITIONER_Client       as pc
       JOIN PRACTITIONER_Practitioner as pp ON pp.PRACTITIONER_ID = pc.PRACTITIONER_ID 
       WHERE (
	       (pc.CLIENT_ID       = @clientID)  
       and (pc.PRACTITIONER_ID = @pracID)
	   )
  )
  begin    
    RAISERROR('Requires valid practitioner and client', 11, 1)
  end

  if not exists (
    select top 1 
	  SITE_ID
	from dbo.SITES_Site 
	where 
	  ((SITE_CLIENT_ID = @clientID) and (SITE_ID = @siteID))
  )
  begin
    RAISERROR('Requires valid site', 11, 1)
  end

  IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN
    select top 1 
	  @recordID = pic.id
    from dbo.PRACTITIONER_SITES as pic 
	where ( 
	      (pic.id       = @recID)    
	  and (pic.pracID    = @pracID)
	)

    if ( ISNULL(@recordID,0) = 0 )
	begin
      RAISERROR( 'Please select a valid record to edit for this practitioner', 11, 1)
	end

  END

  /* Check for redudant rows */

  declare @dupCountExisting int = 0

  select 
    @dupCountExisting = count(*)
  from dbo.PRACTITIONER_SITES
  where (
        (pracID = @pracID)
    and (siteID = @siteID)
	and (   (@saveType = dbo.CONST_SAVE_TYPE_NEW()) /* New insert */
		 OR (id <> @recID))                         /* Editing, avoid matching current record */
  )
  
  /* If this op will create a redudant row exit */

  if ( @dupCountExisting > 0)
  begin
    RAISERROR( @MsgDupRec , 11, 1)
  end

  if ( @validateRec = 1) RETURN (0)

  SET @tranOpen = 1
  BEGIN TRANSACTION

  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin

    INSERT INTO dbo.PRACTITIONER_SITES (
        pracID
      , siteID 	  
	  , created
	  , createdBy
	  , active 
	)
	values (
	   @pracID
	 , @siteID 
	 , @today
	 , @userID
	 , 1
	)
    
    set @recordID = SCOPE_IDENTITY()

  end
  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  begin

    update dbo.PRACTITIONER_SITES
	set	    
        siteID          = @siteID                             
	  , lastModified    = @today
	  , lastModifiedBy  = @userID	  
	where 
	  (id = @recordID)

  end /* Edit */ 
  else 
  begin
    RAISERROR( 'Unknown or unsupported save type' , 11, 1)
  end

  COMMIT TRANSACTION
  SET @tranOpen = 0

END TRY 


BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()

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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_SITES_SAVE] TO [webuser]
GO
