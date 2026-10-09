USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_FORM_SUBMIT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_FORM_SUBMIT
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_FORM_SUBMIT ( 
  @userID             bigint,
  @userGroup          int,
  @userRank           int,
  @formRequestID      varchar(1000),
  @formDefinitionID   bigint,
  @requestIP          varchar(1000),
  @requestUserAgent   varchar(1000),
  @editDelReason      VARCHAR(7000),    
  @validateRec        BIT,    
  @saveType           INT,    
  @recID              BIGINT,  
  @MsgNoRec           VARCHAR(1000),    
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec          VARCHAR(1000),   
  @MsgDataError       VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),     
  
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * FORM_FORM_SUBMIT */    
/**    
 * Adds answers for a given svc note.  Manages bookmarks.  Adds file records.
 *
 * Note: This is designed to be called from SVC_NOTES_APPEND_NOTE_NOTEANSWERS
 *    
 * @param   userID                       The userid of who saved the record    
 * @param   userGroup                    Users group    
 * @param   userRank                     User rank
 * @param   formRequestID                Unique identifier for form request
 * @parm    formDefinitionID             Record id for form definition
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today  as datetime = getdate()
set @recordID = null
set @spDetails  = ''

/*###########################################################################
  # Look for existing
  ###########################################################################*/  

select @recordID = id from FORM_FORM_SUBMITTED where (formRequestID = @formRequestID)

/*###########################################################################
  # If there is no existing record create new
  ###########################################################################*/  

if (@recordID is null)
begin

  /*============================================================
   * Create new form form record
   *============================================================*/
 
  insert into FORM_FORM_SUBMITTED (
     formRequestID
    ,formDefinitionID
    ,userID
    ,userGroup
    ,userRank
    ,requestIP
    ,requestUserAgent
    ,createdOn
    ,complete
    ,active
  )  
  values (
     @formRequestID
    ,@formDefinitionID
    ,@userID
    ,@userGroup
    ,@userRank
    ,@requestIP
    ,@requestUserAgent
    ,@today
    ,0
    ,1
  )

  set @recordID = SCOPE_IDENTITY()
  
end

/*###########################################################################
  # Otherwise update
  ###########################################################################*/  

else
begin

  /*============================================================
   * Update existing
   *============================================================*/

  update FORM_FORM_SUBMITTED set lastUpdatedOn = @today where id = @recordID
  
end

/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FORM_FORM_SUBMIT] TO [webuser]

GO