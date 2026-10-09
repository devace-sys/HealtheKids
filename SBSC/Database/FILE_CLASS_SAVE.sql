USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_CLASS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_CLASS_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[FILE_CLASS_SAVE] (
    @userID					bigint = 0  /* Not used*/
  , @userGroup				int    = 0  /* Not used */
  , @userRank				int    = 0  /* Not used */
  , @fileClassID            bigint        = -1 /* Required */
  , @fileClassName          varchar(1000) = '' /* Required */
  , @fileClassDescription   varchar(8000) = '' /* Optional */
  , @fileRelatedToPrac      bit           = 0
  , @fileRelatedToPat       bit           = 0
  , @validateRec			bit           = 1
  , @saveType				int           = 1
  , @recID					bigint        = 0 /* Will be set to fileClassID */
  , @MsgNoRec				varchar(1000) = 'No record'
  , @MsgNoEdit				varchar(1000) = 'Cannot edit'
  , @MsgDupRec				varchar(1000) = 'File class already exists'
  , @MsgDataError			varchar(1000) = 'Data error'
  , @MsgNotActive			varchar(1000) = 'Record is not active'
  , @spDetails				varchar(8000) OUTPUT
  , @recordID				bigint        OUTPUT /* Will be set to fileClassID */   )
AS    
BEGIN     
    
/***************************************************************************    
 * FILE_CLASS_SAVE */    
/**    
 * Creates a new file class and supporting data or edits existing
 *
 ***************************************************************************/         
     
SET NOCOUNT ON    

declare @tranOpen as bit = 0
declare @today    as datetime

BEGIN TRY    
    
declare @fileParts as table (
	partOrder int 
  , partID    bigint
)

/*-------------------------------    
 * Init   
 *------------------------------*/    

set @tranOpen   = 0    
set @spDetails  = ''    
set @recordID   = 0
set @today      = getdate()

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
/*
IF (@userID      IS NULL) RAISERROR ('userID is required',			11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',		11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',		11, 1)    
*/

/*-------------------------------    
 * Sanitize 
 *------------------------------*/    

set @fileClassID          = isnull(@fileClassID,-1)
set @fileClassName        = trim(isnull(@fileClassName,''))
set @fileClassDescription = trim(isnull(@fileClassDescription,''))
set @MsgDupRec            = isnull(@MsgDupRec, 'File class already exists')
set @MsgNoRec             = isnull(@MsgNoRec,  'Record does not exist')

/*-------------------------------    
 * Check for required data
 *------------------------------*/    

if (@fileClassID  <= 0 )  raiserror ('File class ID is required',    11, 1)
if (@fileClassName = '')  raiserror ('File class name is required',  11, 1)
if (@validateRec is null) raiserror ('Validate flag required',		 11, 1)    
if (@saveType    is null) raiserror ('Save type is required',		 11, 1)    

/*-------------------------------    
 * Replacement data
 *------------------------------*/    

set @recID     = @fileClassID
set @recordID  = @fileClassID

/*-------------------------------    
 * See if a record already exists
 * Also create file name parts
 * based on inputs
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  /*============================== Same ID ==============================*/    

  if exists (select top 1 fc.id from dbo.FILE_CLASSES as fc where fc.id = @fileClassID)
  begin
	raiserror (@MsgDupRec, 11, 1) 
	return(0)
  end
  
  /*============================== Same Name? ==============================*/    

  if exists (select top 1 fc.id from dbo.FILE_CLASSES as fc where fc.[name] = @fileClassName)
  begin
    raiserror (@MsgDupRec, 11, 1) 
	return(0)
  end
  
  /*============================== Generate file parts ==============================*/    

  insert into @fileParts (partOrder, partID) values (1,3)  -- client short name
  insert into @fileParts (partOrder, partID) values (2,5)  -- file class

  if (@fileRelatedToPrac = 1) insert into @fileParts (partOrder, partID) values (3,8) -- prac
  if (@fileRelatedToPat  = 1) insert into @fileParts (partOrder, partID) values (4,7) -- pat

  insert into @fileParts (partOrder, partID) values (5,2)     -- upload date
  insert into @fileParts (partOrder, partID) values (6,1)     -- upload id
  insert into @fileParts (partOrder, partID) values (7,9999)  -- file extension

end

/*-------------------------------    
 * See if record exists and 
 * check if an edit will create
 * a duplicate name
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  /*============================== No existing record?  ==============================*/    

  if not exists (select top 1 fc.id from dbo.FILE_CLASSES as fc where fc.id = @fileClassID)
  begin
    raiserror (@msgNoRec, 11,1)
	return(0)
  end

  /*============================== Another record with same name?  ==============================*/    

  if exists (select top 1 fc.id from dbo.FILE_CLASSES as fc where ((fc.[name] = @fileClassName) and fc.id != @fileClassID))
  begin
    raiserror (@MsgDupRec, 11, 1) 
	return(0)
  end

end

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
if (@validateRec = 1) 
begin
  return(0)    
end       

/*-------------------------------    
 * Create or modify records     
 *------------------------------*/    
    
begin transaction
    
  set @TranOpen = 1    
        
  /*============================== New Record ==============================*/    
  
  if (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  begin       
       
     insert into [dbo].[FILE_CLASSES] (
            [id]
          , [name]
          , [description]
          , [upload_allowed_from_public]
          , [upload_allowed_from_private]
          , [active]
          , [fileStoragePathNameAddressReceiveOriginalID]
          , [fileStoragePathNameAddressStorageFiledID]
          , [fileStoragePathNameAddressStorageReviewID]
          , [fileStoragePathNameAddressArchiveFiledID]
          , [fileStoragePathNameAddressArchiveOriginalID]
          , [fileStoragePathNameAddressWebReferenceID]
          , [fileStoragePathNameAddressDeactivateOrReplaceID]
          , [fileAsMimeType]
         )
         values
         (
                 @fileClassID             --[id]
           ,     @fileClassName           --[name] 
           ,     ''                       --[description]
           ,     0                        --[upload_allowed_from_public]  /* No longer used */
           ,     1                        --[upload_allowed_from_private] /* Set to 0 if not related to */
           ,     1                        --[active]
           ,     8                        --[fileStoragePathNameAddressReceiveOriginalID]
           ,     3                        --[fileStoragePathNameAddressStorageFiledID]
           ,     12                       --[fileStoragePathNameAddressStorageReviewID]
           ,     13                       --[fileStoragePathNameAddressArchiveFiledID]
           ,     9                        --[fileStoragePathNameAddressArchiveOriginalID]
           ,     NULL                     --[fileStoragePathNameAddressWebReferenceID]
           ,     11                       --[fileStoragePathNameAddressDeactivateOrReplaceID]
           ,     NULL                     --[fileAsMimeType]
         )                               
 
         insert into dbo.FILE_UPLOAD_NAME_PARTS (fileClassID, partID, partOrder, active)
         select  
             fileClassID = @fileClassID
           , fp.partID
           , fp.partOrder
           , active      = 1
		 from @fileParts as fp
 end      
  
 /*============================== Existing Record ==============================*/ 
 
 else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 begin  
   update [dbo].[FILE_CLASSES]
   set 
       [name]        = @fileClassName
	 , [description] = @fileClassDescription
   where (id = @fileClassID)   
 end

 else
 begin
   raiserror ('Unknown or unsupported save type', 11, 1)             
 end
    
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
    
commit transaction
set @tranOpen = 0    
return(0)    

end try
begin catch
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  if @tranOpen = 1 rollback transaction
      
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
    
end catch
end
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FILE_CLASS_SAVE] TO [webuser]
GO
