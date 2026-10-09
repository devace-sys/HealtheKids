USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_PRAC_PAT_MIN_MAX_SVC_DATES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_PRAC_PAT_MIN_MAX_SVC_DATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_PRAC_PAT_MIN_MAX_SVC_DATES] (@clientID INT,
                                                            @pracID   INT,
                                                            @patID    INT,     
                                                            @startDate DATETIME OUTPUT,
                                                            @endDate   DATETIME OUTPUT,
                                                            @recCount  INT      OUTPUT)    
AS    
BEGIN    
    
/***************************************************************************    
 * CLIENT_PRAC_PAT_MIN_MAX_SVC_DATES */    
/**    
 * Find min and max service dates for given clientID, pracID, and patID
 *    
 * @param    clientID    Client id
 * @param    pracID      Practitioner id
 * @param    patID       Patient id
 * @returns  startDate   Minimum state end or null
 *           endDate     Maximum end date or null
 *           recCount    Number of recs
 ***************************************************************************/    
    
SET NOCOUNT ON    
    
  select 
    @startDate = dbo.DATE_ONLY(min(dos)), 
    @endDate   = dbo.DATE_ONLY(max(dos)),
    @recCount  = COUNT(id)
  from 
    SERVICE_RECORDS as sr
  where 
    sr.state    != dbo.CONST_REC_STATE_DEL() and 
    sr.state    != dbo.CONST_REC_STATE_CIF() and 
    sr.clientID =  @clientID                 and 
    sr.pracID   =  @pracID                   and 
    sr.patID    =  @patID  

  RETURN(0)    
    
END    
GO
