USE [spedmon]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGE_SAVE_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.NEWSLETTER_PAGE_SAVE_CORE
GO


  /*-------------------------------
   * Object Definition
   *------------------------------*/

CREATE PROCEDURE [dbo].[NEWSLETTER_PAGE_SAVE_CORE]

 (
  @userID                BIGINT,    
  @userGroup             INT,    
  @userRank              INT,
 
  @appName               varchar(50),    /* Application name (from web.config)*/

  @startDate             datetime,
  @forContactRoleIdsStr     varchar(8000),
  @forUserRoleIdsStr     varchar(8000),
  @forClientIdsStr       varchar(8000),

  @title                 varchar(512),

  @content               varchar(max),
  @readyToSend           bit,

  @isResourceLibraryTopic   bit            ,
  @tags                     varchar(512)  ,        
  @tooltip                  varchar(1000)  ,


  @sendEmailSelected        bit ,


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
 * NEWSLETTER_PAGE_SAVE_CORE */    
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

declare @forContactRoleIds as table (id int, recid bigint)
insert into @forContactRoleIds select * from dbo.MULTI_RECORD_ID_PARSE(@forContactRoleIdsStr,',')
-- dbo.STRING_SPLIT called internally in UDF

declare @forUserRoleIds as table (id int, recid bigint)
insert into @forUserRoleIDs select * from dbo.MULTI_RECORD_ID_PARSE(@forUserRoleIdsStr,',')

declare @forClientIds as table (id int, recid bigint)
insert into @forClientIDs select * from dbo.MULTI_RECORD_ID_PARSE(@forClientIdsStr,',')

set @tags  = dbo.STRING_REMOVE_EXTRA_SPACES(@tags)
declare @newsletterTags as table ( id int identity(1,1), tag_str varchar(256))

if (len(@tags) != 0) 
begin
  INSERT INTO @newsletterTags (
    tag_str
  )
  select 
    tag_str = convert(varchar(256),t2.[value]) 
  from string_split(@tags, ' ' ) as t2
  order by 
    t2.[value] asc
end

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
  from dbo.NewsletterPages
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

-- set @description = STRING_ESCAPE( (trim(isnull(@description,''))), 'json' )

/*-------------------------------    
 * Save a new record or replace
 * an existing record
 *------------------------------*/    
   
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    

  insert into dbo.NewsletterPages (
      [appName]
    , startDate
    , [title]
    , [content]
    , readyToSend
   , isResourceLibraryTopic 
   , [tags]                  
   , [tooltip]
   , [sendEmailSelected]
    , created
    , createdBy
    , active
  )                            
  values (
      @appName
    , @startDate
    , @title
    , @content
    , @readyToSend
    , @isResourceLibraryTopic 
    , @tags                  
    , @tooltip
    , @sendEmailSelected
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
  
  delete dbo.NewsletterPagesForContactRoles  where (pageID = @recordID)
  delete dbo.NewsletterPagesForClients       where (pageID = @recordID)
  delete [dbo].[NewsletterPagesForUserRoles] where (pageID = @recordID) 
  delete [dbo].[NewsletterPagesTags]         where (pageID = @recordID) 

  update dbo.NewsletterPages
  set
      startDate              = @startDate
    , [title]                = @title
    , [content]              = @content
    , lastModified           = @today                            
    , lastModifiedBy         = @userID
    , readyToSend            = @readyToSend
    , revisionNum            =  CASE WHEN (readyToSend = 1 AND @readyToSend = 1) THEN revisionNum + 1 ELSE revisionNum END
    , isResourceLibraryTopic   =  @isResourceLibraryTopic 
    , [tags]                   =  @tags                  
    , [tooltip]                =  @tooltip
    , [sendEmailSelected]      = @sendEmailSelected
       
  where (ID = @recordID)

END
ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)  
END

insert into dbo.NewsletterPagesForContactRoles
select      
    pageID          = @recordID
  , contactRoleID   = rid.recID   
from @forContactRoleIds as rid

insert into [dbo].[NewsletterPagesForUserRoles]
select      
    pageID                  = @recordID
  , [userRoleID]            = rid.recID 
from @forUserRoleIDs as rid

insert into dbo.NewsletterPagesForClients
select      
    pageID     = @recordID
  , clientID   = cid.recID   
from @forClientIDs as cid

insert into dbo.NewsletterPagesTags
select      
    pageID = @recordID
  , tag    =  tag_str
from @newsletterTags
   
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

