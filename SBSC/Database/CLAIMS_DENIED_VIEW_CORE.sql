USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_DENIED_VIEW_CORE] (
     @clientID          BIGINT
   , @oldestDOS         DATETIME
   , @today             DATETIME
   , @lea               BIT
   , @claimID           BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLAIMS_DENIED_VIEW_CORE */    
 /**    
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

  /*###########################################################################
    # Returns data for a set of clients or a single client or a single claima
    ###########################################################################*/  
  
  select
	
	cdvdc.*	    

  from dbo.CLIENTS_Client as clc

  cross apply (

    select 
	  * 
	from dbo.CLAIMS_DENIED_VIEW_DATA_CORE(   clc.CLIENT_ID
	                                       , @oldestDOS
								  		   , @today
										   , @claimID )
  ) as cdvdc

  where (
        (1=1)
	and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
	and ((@lea is null)      or (clc.LEA       = @lea))
  )

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_VIEW_CORE] TO [webuser]
GO  
