USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[TRANSMISSION_RECORD_CLAIMS_ALL]'))
DROP VIEW [dbo].[TRANSMISSION_RECORD_CLAIMS_ALL]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[TRANSMISSION_RECORD_CLAIMS_ALL] 
AS 
(

/***************************************************************************    
 * TRANSMISSION_RECORD_CLAIMS_ALL */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select TRANSMISSION_ROLLBACK_ID = null, trc.* from dbo.Transmission_Record_Claims as trc
union 
select trca.* from dbo.Transmission_Record_Claims_Archive as trca

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSMISSION_RECORD_CLAIMS_ALL] TO [webuser]
GO
