
USE [spedmon]
GO

DROP PROCEDURE if exists [dbo].[CLIENT_COMPLIANCE_ITEMS_DELETE]
GO


CREATE PROCEDURE [dbo].[CLIENT_COMPLIANCE_ITEMS_DELETE] (
    @userID          BIGINT
  , @userGroup       INT    
  , @userRank        INT 

  , @deleteForAllClients       bit
  , @validateRec               bit
  , @recID                     bigint

  , @editDelReason   VARCHAR(7000)
  , @msgNoRec        VARCHAR(1000)
  , @msgNoEdit       VARCHAR(1000)
  , @spDetails       VARCHAR(8000) OUTPUT
  , @recordID        BIGINT        OUTPUT
)  
AS    
BEGIN
  
  set @spDetails = ''  -- middleware will crash if this return param is left null.  Now you know!
  set @recordID  = null

  declare @tranOpen     as bit           = 0
  declare @errorstr     as varchar(max)  = ''
  declare @jsonvcharmax as varchar(max)  = '{}'

  declare @cciClientID  as bigint;
  declare @cciID        as bigint;
  declare @cfyID        as int;
 

  LINENO 40

  
  BEGIN TRY

    /* Find page and make sure its active */

    select top 1 
	      @recordID     = ccc_i.id
     ,  @cciID        = cc_i.id 
     ,  @cciClientID  = ccc_i.clientID
     ,  @cfyID        = cfy.ID
     from   [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS] ccc_i

     JOIN    dbo.CLIENT_COMPLIANCE_ITEMS cc_i
             ON  ccc_i.clientComplianceItemID = cc_i.id
     
     JOIN  [dbo].[COMPANY_FISCAL_YEARS] cfy
        ON  cfy.FY_START <= cast( cc_i.dueDate as date)
       AND  cfy.FY_END   >= cast( cc_i.dueDate as date)

     where ccc_i.id = @recID

	/* If we don't find the page or its no longer active, exit */

	if (@recordID is null) 
	begin
	  set @recordID = 0
	  return(0)
	end

    BEGIN TRANSACTION
      
	  set @tranOpen = 1
	 
        UPDATE  ccc_i
          SET
              [active] = 0
        FROM  [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS]  ccc_i

             JOIN    dbo.CLIENT_COMPLIANCE_ITEMS cc_i
             ON  ccc_i.clientComplianceItemID = cc_i.id
     
             JOIN  [dbo].[COMPANY_FISCAL_YEARS] cfy
             ON   cfy.FY_START <= cast( cc_i.dueDate as date)
             AND  cfy.FY_END   >= cast( cc_i.dueDate as date)


        WHERE  (
                  cc_i.id = @cciID
                  AND
                  cfy.ID = @cfyID
                  AND
                  (  ccc_i.clientID = @cciClientID   OR  @deleteForAllClients = 1 )
        )

    COMMIT TRANSACTION
    
	set @tranOpen = 0
    return (0)
  
  END TRY
  BEGIN CATCH

    if (@tranOpen = 1) 
    begin  
      rollback transaction
    end

    DECLARE @ErrorMessage  AS NVARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    


    SET @errorstr += ' - Ooops; ' + ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' line ' + CAST(ERROR_LINE() AS VARCHAR)

    --SET @spDetails = @errorstr  -- This should output the error to the browser.  Comment on production, uncomment on dev for diagnostics as needed.

    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);

  END CATCH
  
END
GO

grant execute on [dbo].[CLIENT_COMPLIANCE_ITEMS_DELETE] to webuser
GO

