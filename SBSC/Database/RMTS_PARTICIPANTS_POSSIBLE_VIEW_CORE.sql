USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE] (  
    @clientID  bigint
)    
 
RETURNS
TABLE
AS
RETURN
(
 
 /***************************************************************************    
  * RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE */    
 /**    
  * Returns a table of possible participants
  *    
  * @return                 Table 
  ***************************************************************************/     
 
select top (dbo.CONST_MAX_ROWS())

    id                        = prc.PRACTITIONER_ID
  , [name]                    = convert(varchar(256)
                              ,(
							    trim(isnull(prp.LAST_NAME,N'')) 
                                + N', ' 
						        + trim(isnull(prp.FIRST_NAME,N''))
							   ))
  , [title]                   = convert(varchar(1000),gg.GROUP_NAME)
                              + ' - '
                              + scn.GROUP_SERVICE_CLASS_NAME
  , submitClaims              = prp.SUBMIT_CLAIMS
  , submitClaimsStr           = dbo.RPT_BIT_TO_YN(prp.SUBMIT_CLAIMS)
  , clientID                  = prc.CLIENT_ID
  , pracID                    = prc.PRACTITIONER_ID
  , groupID                   = pg.GROUP_ID
  , groupServiceClassNameID   = png.GROUP_SERVICE_CLASS_NAME_ID

from dbo.PRACTITIONER_Client                               as prc
join dbo.PRACTITIONER_Practitioner                         as prp on  ((prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID)
                                                                  and (prp.ACTIVE = 1)                 
                                                                  and (prp.employeeRelationshipID = 10)) 

join dbo.PRACTITIONER_GROUPS                               as pg  on  (pg.PRACTITIONER_ID   = prp.PRACTITIONER_ID)                                  

join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on  ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 300)                                                                  
																  and (png.GROUP_SERVICE_CLASS_NAME_ID is not null) /* for index */
																  and (png.GROUP_ID  = pg.GROUP_ID))

join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as scn on  (scn.GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID)

join dbo.GROUP_GROUP                                       as gg  on  ((gg.GROUP_TYPE in (1,2))
                                                                  and (gg.GROUP_ID   = png.GROUP_ID))
where ((prc.CLIENT_ID = @clientID))

)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE] TO [webuser]
GO
