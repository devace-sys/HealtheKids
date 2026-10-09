USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL]'))
DROP VIEW [dbo].[TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL] 
AS 
(

/***************************************************************************    
 * TRANSMISSION_RECORD_CLAIMS_ALL */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select TRANSMISSION_ROLLBACK_ID = null, tsc.* from dbo.Transmission_Summary_By_Client_837 as tsc
union 
select tsca.* from dbo.Transmission_Summary_By_Client_837_Archive as tsca

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL] TO [webuser]
GO
