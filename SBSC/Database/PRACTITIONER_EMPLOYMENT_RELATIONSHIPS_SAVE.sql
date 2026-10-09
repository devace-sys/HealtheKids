USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE
GO
 
CREATE PROCEDURE dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE (
    @userID               bigint
  , @userGroup            int
  , @userRank             int
  , @clientID             bigint
  , @pracID               bigint
  , @employeeRelationship bigint
  , @startDate            datetime
  , @endDate              datetime
  , @notes                varchar(max)
  , @editDelReason        VARCHAR(7000)
  , @validateRec          BIT    
  , @recID                BIGINT
  , @MsgNoRec             VARCHAR(1000)   
  , @MsgDupRec            VARCHAR(1000)
  , @MsgNoEdit            VARCHAR(1000)
  , @MsgNotActive         VARCHAR(1000)
  , @MsgDataError         VARCHAR(1000)
  , @saveType             smallint
  , @spDetails            VARCHAR(8000) OUTPUT    
  , @recordID             BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today      AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen   AS BIT            -- Is a transaction open
 
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 

/*-------------------------------    
 * Init working variables    
 *------------------------------*/    

SET @today = GETDATE()   
   
/*-------------------------------    
 * Defaults and cleanup
 *------------------------------*/    

set @notes = trim(isnull(@notes,''))

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup    IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userID       IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank     IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec  IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType     IS NULL) RAISERROR ('Save type is required',   11, 1)    

IF (@clientID             is null) RAISERROR ('clientID is required',              11, 1)
IF (@pracID               is null) RAISERROR ('pracID is required',                11, 1)
if (@employeeRelationship is null) RAISERROR ('employee relationship is required', 11, 1)
if (@startDate            is null) RAISERROR ('startDate is required',             11, 1)
if (@endDate              is null) RAISERROR ('endDate is required',               11, 1)

/*============================================================
 * Verify
 *============================================================*/  

/*-------------------------------    
 * Client + Prac 
 *------------------------------*/      

if not exists (
  select top 1 
    prp.PRACTITIONER_ID 
  from dbo.PRACTITIONER_Practitioner as prp
  join dbo.PRACTITIONER_Client       as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
  where (
        (prp.PRACTITIONER_ID = @pracID)
    and (prc.CLIENT_ID       = @clientID)
  )
)
    
/*-------------------------------    
 * Relationship id 
 *------------------------------*/      

if not exists (
  select top 1 er.TYPE_ID 
  from dbo.EMPLOYMENT_RELATIONSHIPS as er 
  where 
    (er.TYPE_ID = @employeeRelationship)  
)
begin
  RAISERROR ('Invalid employment relationship', 11, 1)
end

if (@startDate > @endDate)
begin
  RAISERROR ('Start date cannot be after end date', 11, 1)
end

/*============================================================
 * If we are editing the record, make sure it exists 
 *============================================================*/  
  
if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  IF (@recID IS NULL) RAISERROR ('Record id is required', 11, 1)    
  
  select top 1 
    @recordID = per.id
  from dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS as per
  where (
        (1=1)
    and (per.clientID  = @clientID)
    and (per.pracID    = @pracID)
	and (per.id        = @recID)             
    and (per.active    = 1)
  )
  option (recompile)

  if (@recordID != @recID)
  begin
    RAISERROR (@MsgNoRec, 11, 1)
  end

end

/*============================================================
 * Check for duplicate records in all active records
 *============================================================*/  

/* Exact match */

if exists (
  select top 1 
    per.id
  from dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS as per  
  where (
        (1=1)
    and (per.clientID = @clientID)
	and (per.pracID   = @pracID)
	and (per.employeeRelationshipID = @employeeRelationship)
	and (per.startDate              = @startDate)
	and (per.endDate                = @endDate)
    and ((@recID IS NULL) or (per.id != @recID))
	and (per.active = 1)
  )  
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end

/* Overlaps */

if exists (
  select top 1 
    per.id
  from dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS as per  
  where (
        (1=1)
    and (per.clientID = @clientID)
	and (per.pracID   = @pracID)
	and (dbo.DATES_HAVE_OVERLAP(per.startDate,per.endDate,@startDate,@endDate,null,null,null) = 1)
    and ((@recID IS NULL) or (per.id != @recID))
	and (per.active = 1)
  )
)
begin
  RAISERROR ('Overlaps another record', 11, 1)
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          
    
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[PRACTITIONER_EMPLOYMENT_RELATIONSHIPS]
    (                   
	     clientID            
	   , pracID
	   , employeeRelationshipID
	   , startDate
	   , endDate
	   , notes
	   , created
	   , createdBy
	   , active
	)    
    VALUES    
    (  
         @clientID             
	   , @pracID
	   , @employeeRelationship
	   , @startDate
	   , @endDate
	   , @notes
	   , @today
	   , @userID
	   , 1
    )      
    
    SET @recordID = SCOPE_IDENTITY()    

  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/                      
       
     UPDATE [dbo].[PRACTITIONER_EMPLOYMENT_RELATIONSHIPS]
     SET                      
          employeeRelationshipID = @employeeRelationship
		, startDate              = @startDate
		, endDate                = @endDate
		, lastModified           = @today
        , lastModifiedBy         = @userID
     WHERE ([id] = @recID)
 
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
SET @TranOpen = 0    
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
     
 -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE TO webuser
GO