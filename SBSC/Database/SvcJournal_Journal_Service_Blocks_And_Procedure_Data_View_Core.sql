USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core */    
 /**    
  * Returns a list of journal entries
  *
  * @return table
  ***************************************************************************/                        
     
AS RETURN
(
/*###########################################################################
  # Get patient and practioner group data.  Also determine plan type
  ###########################################################################*/

WITH
cte_p1
AS
(

SELECT
    sb.*
  , groupID   = pg.GROUP_ID
  , groupName = gg.GROUP_NAME
  , planType  = dbo.DOS_DOB_IEP_TO_PLAN_TYPE(sb.dos,pp.DATE_OF_BIRTH,sb.iep)

FROM dbo.SvcJournal_Journal_Service_Blocks_View_Core (  @userID
                                                      , @userGroup
                                                      , @userRank
                                                      , @clientID
                                                      , @journalID) AS sb

JOIN dbo.PATIENTS_Patient     AS  pp ON pp.PATIENT_ID      = sb.patID
JOIN dbo.PRACTITIONER_GROUPS  AS  pg ON pg.PRACTITIONER_ID = sb.pracID
                              AND pg.GROUP_TYPE IN (1,2)
JOIN dbo.GROUP_Group          AS  gg ON gg.GROUP_ID = pg.GROUP_ID
where 
  (sb.breakInCare = 0)

)
,

/*###########################################################################
  # Get service name id to use
  ###########################################################################*/

cte_p2
AS
(
  SELECT
      p1.*
    , gp.nameID
  FROM cte_p1                                                    AS  p1
  JOIN dbo.SvcJournal_Event_Types_PracClass_Groups_ServiceNames  AS  gp ON  gp.groupID    = p1.groupID
                                                                        AND gp.eventType  = p1.eventTypeID
                                                                        AND gp.planType   = p1.planType
)

,

/*###########################################################################
  # Get service data
  ###########################################################################*/

cte_p3
AS
(
  SELECT
     p2.*
    ,sva.PROCEDURE_ID                        AS procID
    ,sva.SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED AS orpDocReq
  FROM cte_p2 AS p2
  CROSS apply (
    SELECT top 1
      *
    FROM dbo.SERVICES_VIEW_ALL_CORE ( @clientID
                                    , p2.groupID
                                    , p2.planType
                                    , null 
                                    , p2.nameID
                                    , 1
                                    , 1
                                    , p2.dos
                                    , 1 )    
  ) AS sva
)

SELECT * FROM cte_p3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core] TO [webuser]
GO
