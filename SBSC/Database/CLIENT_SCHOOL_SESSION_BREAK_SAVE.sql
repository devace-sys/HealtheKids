USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_BREAK_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_SCHOOL_SESSION_BREAK_SAVE
GO
 
CREATE PROCEDURE dbo.CLIENT_SCHOOL_SESSION_BREAK_SAVE (
    @userID              bigint
  , @userGroup           bigint
  , @userRank            int
  , @clientID            bigint
  , @academicYearID      bigint
  , @clientWideBreak     bit
  , @siteID              bigint
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
   
DECLARE @today                 as datetime   -- Current date/time stamp    
DECLARE @tranOpen              as bit        -- Is a transaction open
declare @academicYearStartDate as datetime
declare @academicYearEndDate   as datetime

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

if (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
if (@userID      IS NULL) RAISERROR ('user id is required',     11, 1)    
if (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
if (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
if (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------    
 * Client, academic year,
 * client wide flag, site and 
 * dates.
 *------------------------------*/    

if (@clientID       IS NULL) RAISERROR ('Client ID is required',        11, 1)
if (@academicYearID IS NULL) RAISERROR ('Academic year ID is required', 11, 1) 
if (@startDate      IS NULL) RAISERROR ('Start date is required',       11, 1)
if (@endDate        IS NULL) RAISERROR ('End date is required',         11, 1)

/*-------------------------------    
 * Set default for client wide
 * break
 *------------------------------*/    

if (@clientWideBreak IS NULL) set @clientWideBreak = 1

/*-------------------------------    
 * Make sure academic year 
 * is provided and also get 
 * start and end dates for 
 * selection so we can test 
 * the break start/end dates
 *------------------------------*/  

set @academicYearStartDate = null
set @academicYearEndDate   = null

select top 1 
    @academicYearStartDate = csa.startDate
  , @academicYearEndDate   = csa.endDate
from [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as csa
where ( 
      (csa.id       = @academicYearID)
  and (csa.clientID = @clientID)
)

if (@academicYearStartDate is null)
begin
  RAISERROR ('Invalid school year', 11, 1)
end

/*-------------------------------    
 * Make sure site id (if required)
 * is valid
 *------------------------------*/  

if (@clientWideBreak = 0) 
begin
  
  if (@siteID is null) RAISERROR ('Site selection is required', 11, 1)
  
  if not exists (
    select top 1 
      ss.SITE_ID
    from dbo.SITES_Site as ss
    where (
          (ss.SITE_ID = @siteID)
      and (ss.SITE_CLIENT_ID = @clientID)
    )
  )
  begin
    RAISERROR ('Site is not valid', 11, 1)
  end
end
else
begin
  set @siteID = null
end

/*-------------------------------    
 * Make sure name is OK
 *------------------------------*/    

set @name = trim(isnull(@name,''))
if (@name = '') RAISERROR ('Name is required',  11, 1)

/*-------------------------------    
 * Make sure start and end dates
 * are OK
 *------------------------------*/    

if (@startDate > @endDate) RAISERROR ('Start date cannot be later than end date', 11, 1)

if (@startDate not between @academicYearStartDate and @academicYearEndDate)
  RAISERROR ('Start date cannot be outside of school year start and end date', 11, 1)

if (@endDate not between @academicYearStartDate and @academicYearEndDate)
  RAISERROR ('End date cannot be outside of school year start and end date', 11, 1)

/*============================================================
 * Duplicate check
 *============================================================*/  


/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  set @recordID = 0 
  return(0)    
END                          
 
/*============================================================
 * Save
 *============================================================*/  
    
BEGIN TRANSACTION    
   
  set @tranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[CLIENT_SCHOOL_SESSION_BREAKS]
    (                   
	     clientID            
	   , academicYearID
	   , clientWideBreak
	   , siteID 
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
	   , @academicYearID
	   , @clientWideBreak
	   , @siteID            
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
       
     UPDATE [dbo].[CLIENT_SCHOOL_SESSION_BREAKS]
     SET
          [name]             = @name
		, academicYearID     = @academicYearID
        , clientWideBreak    = @clientWideBreak
	    , siteID             = @siteID
		, startDate          = @startDate
        , endDate            = @endDate
		, lastModified       = @today
        , lastModifiedBy     = @userID
 
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
 
GRANT EXECUTE ON  dbo.CLIENT_SCHOOL_SESSION_BREAK_SAVE TO webuser
GO