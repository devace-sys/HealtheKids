USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ACCOMMODATIONS_Save_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Save_Core
GO
 
CREATE PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Save_Core (
    @userID                 BIGINT
  , @userGroup              INT
  , @userRank               INT
  , @patID                  bigint
  , @recordType             int
  , @category               int
  , @categoryName           VARCHAR(256)
  , @accommodation          VARCHAR(512)
  , @accomDetails           VARCHAR(MAX)
  , @appliesTo              VARCHAR(MAX)
  , @appliesToNames         VARCHAR(MAX)
  , @startDate              date
  , @endDate                date
  , @frequency              int
  , @frequencyName          VARCHAR(256)
  , @duration               VARCHAR(512)
  , @location               int
  , @locationName           VARCHAR(256)
  , @locationOther          VARCHAR(512)
  , @linkedAreaOfNeed       VARCHAR(MAX)
  , @linkedAreaOfNeedNames  VARCHAR(MAX)
  , @alignedGoal            VARCHAR(MAX)
  , @alignedGoalNames       VARCHAR(MAX)
  , @staffResponsible       VARCHAR(MAX)
  , @staffResponsibleNames  VARCHAR(MAX)
  , @accomStatus            int
  , @discontinueReason      VARCHAR(7000)
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

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID          = 0    
SET @spDetails         = '' 
SET @today             = GETDATE()   

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
if (@patID         is null) RAISERROR ('Patient id is required',  11, 1)
 
/*============================================================
 * Default values
 *============================================================*/  

set @recordType  = isnull (@recordType,  1)    /* Default to accommodation */
set @accomStatus = isnull (@accomStatus, 1)    /* Default to draft */

/*============================================================
 * Sanity checks for patient
 *============================================================*/  

declare @patDob as date = null

select top 1  
  @patDob = pap.DATE_OF_BIRTH
from dbo.PATIENTS_Patient as pap
where (pap.PATIENT_ID = @patID)

if (@patDob is null) RAISERROR ('Invalid patient', 11, 1)

/*============================================================
 * Sanity checks for dates
 *============================================================*/  

if ((@startDate is not null) and (@endDate is not null))
begin
  if (@startDate > @endDate)  RAISERROR ('Start date cannot be after end date', 11, 1)
end

if (@startDate is not null)
begin
 if (@startDate < @patDob)
 begin
   RAISERROR ('Start date cannot be before patients date of birth',  11, 1)
 end
end

if (@endDate is not null)
begin
 if (@endDate < @patDob)
 begin
   RAISERROR ('End date cannot be before patients date of birth',  11, 1)
 end
end

/*============================================================
 * Lookup record
 *============================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    

  set @recordID = 0

  select top 1 
      @recordID = isnull(pa.id,0)
  from dbo.PATIENTS_Accommodations as pa
  where (
    (pa.id = @recID)
  )
  
  if (@recordID = 0)
  begin
    RAISERROR ('Record not found',  11, 1)
  end

END
  
/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          

/*============================================================
 * Resolve display names from the selected ids when the
 * caller did not pass them
 *============================================================*/  

IF (@categoryName IS NULL OR LEN(LTRIM(RTRIM(@categoryName))) = 0)
BEGIN

  IF (@category IS NOT NULL AND LEN(LTRIM(RTRIM(CAST(@category AS VARCHAR(20))))) > 0)
  BEGIN

    DECLARE @paddedCategory VARCHAR(MAX) = ',' + REPLACE(CAST(@category AS VARCHAR(20)), ' ', '') + ','

    SELECT @categoryName = STUFF((
        SELECT '|' + sac.[name]
        FROM dbo.sped_accommodation_categories AS sac
        WHERE @paddedCategory LIKE '%,' + CAST(sac.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(sac.id AS VARCHAR(20)) + ',', @paddedCategory)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END

IF (@frequencyName IS NULL OR LEN(LTRIM(RTRIM(@frequencyName))) = 0)
BEGIN

  IF (@frequency IS NOT NULL AND LEN(LTRIM(RTRIM(CAST(@frequency AS VARCHAR(20))))) > 0)
  BEGIN

    DECLARE @paddedFrequency VARCHAR(MAX) = ',' + REPLACE(CAST(@frequency AS VARCHAR(20)), ' ', '') + ','

    SELECT @frequencyName = STUFF((
        SELECT '|' + saf.[name]
        FROM dbo.sped_accommodation_frequencies AS saf
        WHERE @paddedFrequency LIKE '%,' + CAST(saf.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(saf.id AS VARCHAR(20)) + ',', @paddedFrequency)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END

IF (@locationName IS NULL OR LEN(LTRIM(RTRIM(@locationName))) = 0)
BEGIN

  IF (@location IS NOT NULL AND LEN(LTRIM(RTRIM(CAST(@location AS VARCHAR(20))))) > 0)
  BEGIN

    DECLARE @paddedLocation VARCHAR(MAX) = ',' + REPLACE(CAST(@location AS VARCHAR(20)), ' ', '') + ','

    SELECT @locationName = STUFF((
        SELECT '|' + sal.[name]
        FROM dbo.sped_accommodation_locations AS sal
        WHERE @paddedLocation LIKE '%,' + CAST(sal.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(sal.id AS VARCHAR(20)) + ',', @paddedLocation)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END

IF (@appliesToNames IS NULL OR LEN(LTRIM(RTRIM(@appliesToNames))) = 0)
BEGIN

  IF (@appliesTo IS NOT NULL AND LEN(LTRIM(RTRIM(@appliesTo))) > 0)
  BEGIN

    DECLARE @paddedAppliesTo VARCHAR(MAX) = ',' + REPLACE(@appliesTo, ' ', '') + ','

    SELECT @appliesToNames = STUFF((
        SELECT '|' + sat.[name]
        FROM dbo.sped_accommodation_applies_to AS sat
        WHERE @paddedAppliesTo LIKE '%,' + CAST(sat.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(sat.id AS VARCHAR(20)) + ',', @paddedAppliesTo)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END

IF (@linkedAreaOfNeedNames IS NULL OR LEN(LTRIM(RTRIM(@linkedAreaOfNeedNames))) = 0)
BEGIN

  IF (@linkedAreaOfNeed IS NOT NULL AND LEN(LTRIM(RTRIM(@linkedAreaOfNeed))) > 0)
  BEGIN

    DECLARE @paddedAreaOfNeed VARCHAR(MAX) = ',' + REPLACE(@linkedAreaOfNeed, ' ', '') + ','

    SELECT @linkedAreaOfNeedNames = STUFF((
        SELECT '|' + san.[name]
        FROM dbo.sped_accommodation_areas_of_need AS san
        WHERE @paddedAreaOfNeed LIKE '%,' + CAST(san.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(san.id AS VARCHAR(20)) + ',', @paddedAreaOfNeed)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END

IF (@staffResponsibleNames IS NULL OR LEN(LTRIM(RTRIM(@staffResponsibleNames))) = 0)
BEGIN

  IF (@staffResponsible IS NOT NULL AND LEN(LTRIM(RTRIM(@staffResponsible))) > 0)
  BEGIN

    DECLARE @paddedStaff VARCHAR(MAX) = ',' + REPLACE(@staffResponsible, ' ', '') + ','

    SELECT @staffResponsibleNames = STUFF((
        SELECT '|' + sas.[name]
        FROM dbo.sped_accommodation_staff_roles AS sas
        WHERE @paddedStaff LIKE '%,' + CAST(sas.id AS VARCHAR(20)) + ',%'
        ORDER BY CHARINDEX(',' + CAST(sas.id AS VARCHAR(20)) + ',', @paddedStaff)
        FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(MAX)'), 1, 1, '')

  END

END
 
     
/*-------------------------------    
 * New record
 *------------------------------*/    
   
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN        
    
  INSERT INTO [dbo].[PATIENTS_Accommodations]
  (                   
       patID            
     , recordType        
     , category          
     , categoryName      
     , accommodation     
     , details           
     , appliesTo         
     , appliesToNames    
     , startDate         
     , endDate           
     , frequency         
     , frequencyName     
     , duration          
     , location          
     , locationName      
     , locationOther     
     , linkedAreaOfNeed  
     , linkedAreaOfNeedNames
     , alignedGoal       
     , alignedGoalNames  
     , staffResponsible  
     , staffResponsibleNames
     , status            
     , discontinueReason 
     , created
     , createdBy
     , active
  )    
  VALUES    
  (  
       @patID             
     , @recordType        
     , @category          
     , @categoryName      
     , @accommodation     
     , @accomDetails      
     , @appliesTo         
     , @appliesToNames    
     , @startDate         
     , @endDate           
     , @frequency         
     , @frequencyName     
     , @duration          
     , @location          
     , @locationName      
     , @locationOther     
     , @linkedAreaOfNeed  
     , @linkedAreaOfNeedNames
     , @alignedGoal       
     , @alignedGoalNames  
     , @staffResponsible  
     , @staffResponsibleNames
     , @accomStatus       
     , @discontinueReason 
     , @today
     , @userID
     , 1         
   )      
    
  SET @recordID = SCOPE_IDENTITY()    
END           

/*-------------------------------    
 * Edit existing record    
 *------------------------------*/    

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
   
  UPDATE [dbo].[PATIENTS_Accommodations]
  SET 
      patID              = @patID             
    , recordType         = @recordType        
    , category           = @category          
    , categoryName       = @categoryName      
    , accommodation      = @accommodation     
    , details            = @accomDetails      
    , appliesTo          = @appliesTo         
    , appliesToNames     = @appliesToNames    
    , startDate          = @startDate         
    , endDate            = @endDate           
    , frequency          = @frequency         
    , frequencyName      = @frequencyName     
    , duration           = @duration          
    , location           = @location          
    , locationName       = @locationName      
    , locationOther      = @locationOther     
    , linkedAreaOfNeed   = @linkedAreaOfNeed  
    , linkedAreaOfNeedNames = @linkedAreaOfNeedNames
    , alignedGoal        = @alignedGoal       
    , alignedGoalNames   = @alignedGoalNames  
    , staffResponsible   = @staffResponsible  
    , staffResponsibleNames = @staffResponsibleNames
    , status             = @accomStatus       
    , discontinueReason  = @discontinueReason 
    , lastModified       = @today
    , lastModifiedBy     = @userID
   where ([id]  = @recID)

END    
ELSE    
BEGIN    
  RAISERROR ('Unknown save type', 11, 1)    
END    

       
/*-------------------------------    
 * If we reach this point    
 * everything is OK.  Exit    
 *------------------------------*/    
   
RETURN(0)    
END TRY 

BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong. Return any    
   * error messages to the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
          
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_ACCOMMODATIONS_Save_Core TO webuser
GO