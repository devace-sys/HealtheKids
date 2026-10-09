USE SPEDMON
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INSURANCE_CARRIERS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_INSURANCE_CARRIERS_SAVE
GO

CREATE PROCEDURE [dbo].[PATIENT_INSURANCE_CARRIERS_SAVE] (
     @userID                  bigint
   , @userGroup               int  
   , @userRank                int
   , @clientID                int    
   , @patID                   int
   , @insuranceCarrierID      bigint
   , @beneficiaryLastName     varchar (60)
   , @beneficiaryFirstName    varchar (35)
   , @beneficiaryID           varchar (80)

   , @policyHolderName	      varchar(512)
  -- NOTE: does not match convention on this table, where we are saving the beneficiary's first and last names as separate fields

  -- , @insCarrierNameStr
  --  NOT ALLOWING the end user to save freeform text.  They can leave the dropdown blank if necessary

    , @policyGroupID		  varchar(256)

    , @expiredOrInvalid		  bit
	, @cybhiRegisteredWithTpa bit
    -- a row needs to be able to be marked as un-usable for claiming purposes, without hiding it from the restView.
    -- suitable for historical record-keeping purposes (parent remarriage name changes and the like)

	, @primaryCarrier		  bit

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
	     pp.PATIENT_ID
       FROM PATIENTS_Client  as pc
       JOIN PATIENTS_Patient as pp ON pp.PATIENT_ID = pc.PATIENT_ID 
       WHERE (
	       (pc.CLIENT_ID = @clientID)  
       and (pc.PATIENT_ID = @patID)
	   )
  )
  begin    
    RAISERROR('requires valid patient and client', 11, 1)
  end

  IF (
       ( @insuranceCarrierID > 0 )
       AND
       (
         NOT EXISTS ( 
         SELECT top 1 
	       ic.id
         FROM dbo.INSURANCE_CARRIERS as ic
         WHERE 
	         (ic.id = @insuranceCarrierID)
         )
     )
   )
   begin
     RAISERROR('requires valid insurance carrier', 11, 1)
   end
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN

    select top 1 
	  @recordID = pic.id
    from dbo.PATIENT_INSURANCE_CARRIERS as pic 
	where ( 	          
	      (pic.clientID = @clientID)
	  and (pic.patID    = @patID)
	  and (pic.id       = @recID)
	) /* Index: CLIENT_PAT_IDX */

    if ( ISNULL(@recordID,0) = 0 )
	begin
      RAISERROR( 'Please select a valid record to edit for this patient', 11, 1)
	end

  END

  /*------------------------------------------------------------
   * Primary carrier validation
   *
   * Business rule:
   * A patient/client can only have one active/current insurance
   * carrier flagged as primary.
   *
   * Active/current means:
   *   active = 1
   *   expiredOrInvalid = 0
   *
   * When editing, we exclude the current record so it does not
   * detect itself as an existing primary carrier.
   *-----------------------------------------------------------*/

  IF (ISNULL(@expiredOrInvalid, 0) = 1 AND ISNULL(@primaryCarrier, 0) = 1)
  BEGIN
    RAISERROR(
        'An expired or invalid insurance carrier cannot be marked as Primary.',
        11,
        1
    )
  END

  IF (ISNULL(@primaryCarrier, 0) = 1)
  BEGIN

    IF EXISTS
    (
        SELECT TOP 1
          pic.id
        FROM dbo.PATIENT_INSURANCE_CARRIERS AS pic
        WHERE pic.clientID = @clientID
          AND pic.patID = @patID
          AND pic.active = 1
          AND ISNULL(pic.expiredOrInvalid, 0) = 0
          AND ISNULL(pic.primaryCarrier, 0) = 1
          AND pic.id <> ISNULL(@recordID, 0)
    )
    BEGIN
      RAISERROR(
          'This patient already has an active primary insurance carrier. Please set the existing primary carrier to NO before saving this one as Primary.',
          11,
          1
      )
    END

  END

  -- TODO: We are not worried about duplicates yet but we will be.

  declare @dupCountExisting int = 0

  if ( @dupCountExisting > 0)
  begin
    RAISERROR( @MsgDupRec , 11, 1)
  end

  if ( @validateRec = 1) RETURN (0)

  SET @tranOpen = 1
  BEGIN TRANSACTION

  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  begin

    INSERT INTO dbo.PATIENT_INSURANCE_CARRIERS (
	    clientID
      , patID
      , insuranceCarrierID 
      , beneficiaryLastName
	  , beneficiaryFirstName
      , beneficiaryID

      , policyHolderName
      , insCarrierNameStr
      , policyGroupID
      , expiredOrInvalid
	  , cybhiRegisteredWithTpa

	  , primaryCarrier
	  , created
	  , createdBy
	  , active 
	)
	values (
	   @clientID
	 , @patID
	 , @insuranceCarrierID 
     , @beneficiaryLastName
	 , @beneficiaryFirstName
     , @beneficiaryID

     , @policyHolderName

     , NULL

     , @policyGroupID
     , @expiredOrInvalid
	 , @cybhiRegisteredWithTpa

	 , @primaryCarrier
	 , @today
	 , @userID
	 , 1
	)
    
    set @recordID = SCOPE_IDENTITY()

  end
  else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  begin

    update dbo.PATIENT_INSURANCE_CARRIERS
	set	    
        insuranceCarrierID   =  CASE WHEN  ISNULL( @insuranceCarrierID , 0) = 0
                                     THEN  NULL
                                     ELSE  @insuranceCarrierID
                                END
	  , beneficiaryLastName  = @beneficiaryLastName 
	  , beneficiaryFirstName = @beneficiaryFirstName
      , beneficiaryID        = @beneficiaryID

      , policyHolderName    =  @policyHolderName
      , insCarrierNameStr   =  CASE WHEN ISNULL( @insuranceCarrierID , 0) = 0
                                   THEN  [insCarrierNameStr]
                                     -- For no carrier selected, leave existing placeholder
                                   ELSE  NULL
                                END
      , policyGroupID       =  @policyGroupID
      , expiredOrInvalid    =  @expiredOrInvalid
	  , cybhiRegisteredWithTpa = @cybhiRegisteredWithTpa

	  , primaryCarrier = @primaryCarrier

	  , lastModified         = @today
	  , lastModifiedBy       = @userID	  
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

GRANT EXECUTE ON  [dbo].[PATIENT_INSURANCE_CARRIERS_SAVE] TO [webuser]
GO
