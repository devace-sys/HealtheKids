USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_PROCESSING_EXCEPTION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_PROCESSING_EXCEPTION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_PROCESSING_EXCEPTION_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,   
 @recID        INT,     
 @clientID     BIGINT,
 @pracID       BIGINT,
 @startDate    DATETIME,
 @endDate      DATETIME,
 @exceptionID  int,
 @active       BIT,    
 @canEdit      BIT)    
 
 RETURNS @recs TABLE([id]                  [bigint] ,
	                 [clientid]            [bigint] ,
	                 [name]                [VARCHAR](100),	                 
	                 [pracid]              [bigint] ,
	                 [pracname]            [VARCHAR](100),
	                 [startDate]           [datetime] ,
	                 [endDate]             [datetime] ,
	                 [exceptionid]         [smallint] ,
	                 [exceptionname]       [VARCHAR](100),
	                 [notes]               [varchar](MAX),
	                 [active]              [bit] ) AS    
                           
 
 /***************************************************************************    
  * CLAIMS_PROCESSING_EXCEPTION_VIEW */    
 /**    
  * Returns a table of CLAIMS_PROCESSING_EXCEPTION that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  clientID        Required.  ID of client   
  * @param  pracID          PeractitionerID 
  * @param  startDate       Start date    
  * @param  endDate         End date   
  * @param  active          If client is active
  * @param  recID           record id    
  * @return                 Table of client data    
  ***************************************************************************/     
  
begin
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/   
 
 insert into @recs 
   select cpe.id              as ID,
          cpe.client_id       as Client_ID,
          cc.client_name      as client_name,
          cpe.practitioner_id as practitioner_id,
          pp.concat_name      as Practitioner_name,
          cpe.start_date      as start_date,
          cpe.end_date        as end_date,
          cpe.EXCEPTION_ID    as exception_id,
          cpl.Name            as exception_name,
          cpe.Note            as Notes,
          cpe.ACTIVE          AS active
   from dbo.CLAIMS_PROCESSING_EXCEPTIONS cpe 
   LEFT JOIN CLAIMS_PROCESSING_EXCEPTION_LIST cpl on cpl.id             = cpe.EXCEPTION_ID                                          
   LEFT JOIN PRACTITIONER_Practitioner pp         on pp.practitioner_id = cpe.practitioner_id
   LEFT JOIN CLIENTS_Client cc                    on cc.Client_id       = cpe.Client_id
   where (1=1)     
   and ((@clientID is null)      or (cpe.CLIENT_ID       = @clientID))
   and ((@pracID      is null)   or (cpe.PRACTITIONER_ID = @pracID))
   and ((@startdate   is null)   or (cpe.START_DATE     >= @startdate ))
   and ((@endDate     is null)   or (cpe.END_DATE       <= @endDate))
   and ((@exceptionID is null)   or (cpe.exception_id    = @exceptionID))
   and ((@recID       is null)   or (cpe.id              = @recID)) 
 return
 
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_PROCESSING_EXCEPTION_VIEW] TO [webuser]
GO
