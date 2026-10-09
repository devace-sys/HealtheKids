USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.APP_MAN_PAGE_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[APP_MAN_PAGE_SAVE_CORE]
 (@userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT, 
  @appName               varchar(50),    /* Application name (from web.config)*/
  @startDate             datetime,
  @endDate               datetime, 
  @forUserRoleIdsStr     varchar(8000),
  @forClientIdsStr       varchar(8000),
  @title                 varchar(512),
  @description           varchar(2000),
  @content               varchar(max),
  @okToDisplay           bit,

  @include_in_welcome_package   bit,
  @display_order                int,

  @featuredimgfiledata   varchar(max),
  @includeondashboard    bit,
  @editDelReason         VARCHAR(7000),    
  @validateRec           BIT,    
  @saveType              INT,    
  @recID                   BIGINT,    
  @MsgNoRec                VARCHAR(1000),    
  @MsgNoEdit               VARCHAR(1000), 
  @MsgDupRec               VARCHAR(1000),     
  @MsgDataError            VARCHAR(1000),
  @MsgNotActive            VARCHAR(1000),     
  @spDetails               VARCHAR(8000) OUTPUT,    
  @recordID                BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * APP_MAN_PAGE_SAVE_CORE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userID of who is requesting the new user account  
 * @param   userGroup       That users group    
 * @param   userRank        That user rank
 * @param   appDomain       Application domain (can be same as appName)
 * @param   appName         Application name (from web.config)
 * @param   usrid           Preference is for this user id
 * @param   selector        Scope of application of this preference.  Selectors 
 *                          could be CSS selectors, or names of end points.
 * @param   selectorType    Type of selector used.  Must set this properly.  CSS, END_POINT
 * @param   noun            Object name
 * @param   verb            Object method
 * @param   name            Method argument name
 * @param   value           Method argument value
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today            AS DATETIME         -- Current date/time stamp    
DECLARE @tempRecID        AS BIGINT
DECLARE @tempMsg          AS VARCHAR(1000)

BEGIN TRY    

/*-------------------------------    
 * Init our output parameters   
 *------------------------------*/    

set @recordID   = 0

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    


declare @forUserRoleIds as table (id int, recid bigint)
insert into @forUserRoleIDs select * from dbo.MULTI_RECORD_ID_PARSE(@forUserRoleIdsStr,',')

declare @forClientIds as table (id int, recid bigint)
insert into @forClientIDs select * from dbo.MULTI_RECORD_ID_PARSE(@forClientIdsStr,',')

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@appName      IS NULL) RAISERROR ('appName is required',     11, 1)  
IF (@title        IS NULL) RAISERROR ('title is required',       11, 1)  
IF (@content      IS NULL) RAISERROR ('content is required',       11, 1)  


if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  select top 1
    @recordID = id 
  from dbo.AppManPages 
  where ( 
        (id         = @recID)
    and (appName    = @appName)
    and (active     = 1)
  )
end

/*-------------------------------    
 * If we are providing advisement    
 * validation exit now    
 *------------------------------*/    
        
IF (@validateRec = 1) RETURN(0)  

/*-------------------------------    
 * Clean up description data
 * Note: Make sure nulls are saved
 * as empty strings
 *------------------------------*/    

set @description = STRING_ESCAPE( (trim(isnull(@description,''))), 'json' )

/*-------------------------------    
 * Save a new record or replace
 * an existing record
 *------------------------------*/    
   
--BEGIN TRANSACTION    

--SET @TranOpen = 1    


-- all other rows get pushed down, 1
IF ( ISNULL(@display_order, 0) > 0)
BEGIN
  update dbo.AppManPages 
  set 
    display_order =  display_order + 1
  where ( display_order >= @display_order          
        )
END

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    

  insert into dbo.AppManPages (
      [appName]
    , startDate
    , endDate
    , [title]
    , [description]
    , [content]
    , okToDisplay

    , include_in_welcome_package 
    , display_order     

	, featuredImgFileData
	, includeOnDashboard
    , created
    , createdBy
    , active
  )                            
  values (
      @appName
    , @startDate
    , @endDate
    , @title
    , @description
    , @content
    , @okToDisplay

    , @include_in_welcome_package
 
    , ISNULL( @display_order, 999 )   

	, @featuredimgfiledata
	, @includeondashboard
    , @today
    , @userID
    , 1
  )
    
  set @recordID = SCOPE_IDENTITY()    

END

/*-------------------------------    
 * Edit
 *------------------------------*/  

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) 
BEGIN
  
  delete dbo.AppManPagesForUserRoles where (pageID = @recordID)
  delete dbo.AppManPagesForAppOrganizations where (pageID = @recordID)
  
  update dbo.AppManPages
  set
      startDate              = @startDate
    , endDate                = @endDate
    , [title]                = @title
    , [description]          = @description
    , [content]              = @content
    , okToDisplay            = @okToDisplay

    , include_in_welcome_package  = @include_in_welcome_package

    , display_order               = ISNULL( @display_order, display_order)   

	, featuredImgFileData    = @featuredimgfiledata
	, includeOnDashboard     = @includeondashboard
    , lastModified           = @today                            
    , lastModifiedBy         = @userID

  where (ID = @recordID)

END
ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)  
END

  insert into dbo.AppManPagesForUserRoles
  select      
      pageID                  = @recordID
    , appManPageUserClassID   = rid.recID 
  
  from @forUserRoleIDs          as rid
  join dbo.AppManPagesUserRoles as rd on rd.id = rid.recID


  insert into dbo.AppManPagesForAppOrganizations
  select      
      pageID                  = @recordID
    , organizationID   = cid.recID 
  
  from @forClientIDs as cid

--COMMIT TRANSACTION    
--SET @TranOpen = 0 

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
     
  --IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

