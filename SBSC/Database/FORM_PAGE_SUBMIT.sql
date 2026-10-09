USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGE_SUBMIT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_PAGE_SUBMIT
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_PAGE_SUBMIT ( 
  @userID                               bigint,
  @userGroup                            int,
  @userRank                             int,
  @formRequestID                        varchar(1000),
  @formPageDefinitionID                 bigint,
  
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,
  
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),   
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
  
)
AS
BEGIN

/***************************************************************************    
 * FORM_PAGE_SUBMIT */    
/**    
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
  # Clear 
  ###########################################################################*/  

exec FORM_PAGE_CLEAR @formRequestID, @formPageDefinitionID

/*###########################################################################
  # Look for existing
  ###########################################################################*/  

select @recordID = id from FORM_PAGES_SUBMITTED where ((formRequestID = @formRequestID) and (formPageDefinitionID = @formPageDefinitionID))

/*###########################################################################
  # If there is no existing record create new
  ###########################################################################*/  

if (@recordID is null)
begin

  insert into FORM_PAGES_SUBMITTED (
     formRequestID
    ,formPageDefinitionID
    ,createdOn
  )  
  values (
     @formRequestID
    ,@formPageDefinitionID 
    ,@today
  )

  set @recordID = SCOPE_IDENTITY()
end

/*###########################################################################
  # Otherwise update
  ###########################################################################*/  

else
begin
  update FORM_PAGES_SUBMITTED set lastUpdatedOn = @today where id = @recordID  
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
                         
GRANT EXECUTE ON  [dbo].[FORM_PAGE_SUBMIT] TO [webuser]

GO