USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW] (
    @userID        BIGINT,    
    @userGroup     INT,    
    @userRank      INT,
    @clientID      bigint,
    @pracID        bigint
)
RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW */    
/**    
 * Returns list of active practitioners that can supervise pracID 
 * within clientID who have user accounts
 *
 * @param clientID  Client ID
 * @param pracID    Supervised practitioners prac id
 * 
 ***************************************************************************/      

with 
cte_pass_1
as
(
select psg.* 
from dbo.PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW (@clientID, @pracID) as sug 
cross apply (select * from dbo.PRACTITIONERS_SUPERVISING_GROUP_ID_VIEW (@clientID, sug.GROUP_ID)) as psg
where ((sug.GROUP_TYPE in (1,2)) and (psg.PRAC_ASP_ID is not null))
)
,
cte_pass_2
as
(
select p1.*, isnull(ppss.ACTIVE,0) as Assigned 
from cte_pass_1 as p1
left join dbo.PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR as ppss on ppss.SUPERVISING_PRAC_ID = p1.PRACTITIONER_ID and ppss.SUPERVISED_PRAC_ID = @pracID
)
,
cte_pass_3
as
(
select p2.* 
from cte_pass_2                           as p2
join dbo.PRACTITIONER_Client              as pc   on pc.PRACTITIONER_ID = p2.PRACTITIONER_ID
join dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as srao on srao.clientID = pc.CLIENT_ID
where (srao.approvalSystem = 1)
)
select * from cte_pass_3

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW] TO [webuser]
GO
