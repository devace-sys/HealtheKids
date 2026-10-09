USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE
GO
 
CREATE PROCEDURE dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE (
    @userID              bigint
  , @userGroup           bigint
  , @userRank            int
  , @clientID            bigint
  , @companyFiscalYearID bigint
  , @name                varchar(256)
  , @startDate           datetime
  , @endDate             datetime
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT    
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)   
  , @MsgDupRec           VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @saveType            smallint
  , @spDetails           VARCHAR(8000) OUTPUT    
  , @recordID            BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today                     AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen                  AS BIT            -- Is a transaction open

/*-------------------------------    
 * Init our output parameters    
 * and variables
 *------------------------------*/    
   
set @recordID   = 0    
set @spDetails  = '' 
set @tranOpen   = 0
set @today      = getdate()

BEGIN TRY    
      
/*============================================================
 * Parameter validation
 *============================================================*/  

/*-------------------------------    
 * Basics
 *------------------------------*/    

if (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)
if (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
if (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
if (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
if (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Client and dates
 *------------------------------*/    

if (@clientID  IS NULL) RAISERROR ('Client ID is required',   11, 1)
if (@startDate IS NULL) RAISERROR ('Start date is required',  11, 1)
if (@endDate   IS NULL) RAISERROR ('End date is required',  11, 1)

/*-------------------------------    
 * Make sure name is OK
 *------------------------------*/    

set @name = trim(isnull(@name,''))
if (@name = '') RAISERROR ('Name is required',  11, 1)

/*-------------------------------    
 * Make sure start and end dates
 * are OK
 *------------------------------*/    

if (@startDate > @endDate) RAISERROR ('Start date cannot be later than end date',  11, 1)

/*============================================================
 * If this is an edit 
 *============================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN   
  
  if (@recID is null) RAISERROR ('Record id is required',  11, 1)

  /*-------------------------------    
   * Check if changes are compatible
   * with related breaks.
   *------------------------------*/    

  declare @numIncompatibleBreaks as int = 0

  select 
    @numIncompatibleBreaks = count(ssb.id) 
  from [dbo].[CLIENT_SCHOOL_SESSION_BREAKS] as ssb
  where (
        (ssb.clientID       = @clientID) 
    and (ssb.academicYearID = @recID)
    and (ssb.active         = 1)
    and (@startDate not between ssb.startDate and ssb.endDate)
    and (@endDate   not between ssb.startDate and ssb.endDate)
  )

  if (@numIncompatibleBreaks > 0)
  begin
    RAISERROR ('There are breaks associated with this school year that have dates outside of the changes requested.  Please modify the start and end dates of the breaks before making this change or reassociate these breaks with another school year.', 11, 1)
  end

END

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  set @recordID = 0 
  return(0)    
END                          
 
   
BEGIN TRANSACTION    
   
  set @tranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS]
    (                   
	     clientID
	   , companyFiscalYearID            
	   , [name]
	   , startDate
	   , endDate
	   , created
	   , createdBy
	   , active
    )    
    VALUES    
    (  
         @clientID          
	   , @companyFiscalYearID	    
	   , @name   
	   , @startDate
	   , @endDate
	   , @today
       , @userID
	   , 1         
    )      
    
    set @recordID = SCOPE_IDENTITY()    
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/                      
       
     UPDATE [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS]
     SET
          companyFiscalYearID = @companyFiscalYearID
		, [name]              = @name
		, startDate           = @startDate
        , endDate             = @endDate
		, lastModified        = @today
        , lastModifiedBy      = @userID
 
     WHERE (
	       ([id]  = @recID)
       and (clientID = @clientID)  /* Ensures that client users can only update their own recs */
     )
	 
	 SET @recordID = @recid
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
      
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
   
COMMIT TRANSACTION    
SET @tranOpen = 0    
RETURN(0)    
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
     
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE TO webuser
GO