USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[SERVICES_VIEW] (     
    @userID                   BIGINT
  , @userGroup                INT    
  , @userRank                 INT
  , @recID                    INT    
  , @clientID                 INT    
  , @pracID                   INT     
  , @patID                    INT
  , @name                     NVARCHAR(100)
  , @dos                      DATETIME
  , @isiep                    BIT
  , @active                   BIT
  , @canEdit                  BIT
  , @svcNamesListDataSourceID smallint
) 
RETURNS TABLE 

/***************************************************************************    
 * SERVICES_VIEW */    
/**    
 * Returns a table of services that match the given parameters
 * Each client has one or more practitioners.   
 * 
 * TODO: THIS IS CURRENTLY A WRAPPER TO OLDER VIEW FUNCTIONALITY
 * THIS WILL NEED TO BE REFACTORED WHEN THIS ENTITY IS FULLY 
 * IMPLEMENTED.   
 *    
 * @param  clientID        ID of client    
 * @param  pracID          ID of practitioner
 * @param  patID           ID of patient
 * @param  isiep           Is this an IEP/IFSP
 * @param  dos             Date of service
 * @param  name            All or part of services name
 * @param  active          If service is active
 * @param  canEdit         If service can be edited
 * @param  recID           Name id
 * @return                 Table of services data
 ***************************************************************************/     

AS RETURN(      
  
with
cte_p1
as
(
  select 
      id        = sr.nameID
    , flag1     = sr.svcType
    , class1    = sr.groupBase
    
    , recData1  = convert(varchar,isnull(sr.groupServiceClassNameID,0))
    , recData2  = convert(varchar,isnull(sr.groupServiceClassNameName,''))
	, recData3  = convert(varchar,sr.isAutoSelectORPDocPossible)
	, recData4  = sr.svcRenderedVia
	, recData5  = sr.svcPlanTypeName
	, recData6  = sr.svcTypeName
	, recData7  = sr.svcSubType1Name
	, recData8  = sr.svcSubType1IDStr
	, recData9  = sr.calpadsCodeName
	, recData10 = sr.calpadsCodeValueStr
    , recData11 = sr.selectionNameWithoutInPersonOrTelehealthText
	, recData12 = convert(varchar(50),sr.selectionForModalityFlags) 
	, recData13 = convert(varchar(50),sr.selectionAltModalityNameID)
	, recData14 = convert(varchar,sr.serviceEntryOrpDocumentRequired)
	, sr.*			

  from dbo.SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP (
      @clientID
    , @pracID
    , @patID
    , @dos
    , @isiep
    , @recID
    , 0
    , null
    , 1
    , @svcNamesListDataSourceID) as sr   
  
  where ((sr.nameID > 0))
)
,
cte_p2
as
(  
  select 
    p1.*    
  from cte_p1 as p1      
  where (
        (1=1)
    and ((@name is null) or (p1.name like (dbo.CREATE_SEARCH_PAT(@name))))  
  )
)
select 
  p2.* 
from cte_p2 as p2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICES_VIEW] TO [webuser]
GO