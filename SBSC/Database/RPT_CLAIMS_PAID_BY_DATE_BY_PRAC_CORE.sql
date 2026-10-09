USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE] (
    @clientID     INT
  , @startDateDOS DATETIME    
  , @endDateDOS   DATETIME     
  , @startDateDOW DATETIME    
  , @endDateDOW   DATETIME 
)

returns @claimsPaid table (
    [Client]                      nvarchar (max)
  , [Group]                       nvarchar (max)
  , [Practitioner]                nvarchar (max)
  , [Active]                      bit   
  , [Paid]                        bit           default(0)
  , [Assessments]                 NUMERIC(18,8) default(0)
  , [Services & Transportation]   NUMERIC(18,8) default(0)
  , [TCM]                         NUMERIC(18,8) default(0)
  , [Total]                       NUMERIC(18,8) default(0)
  , [PRAC_CHECKSUM]               varbinary(64) not null
)
as
begin
 
 /***************************************************************************    
  * RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE */    
 /**    
  * Generates data for claims paid for a given:
  *
  * - client 
  * - date of service (DOS) range
  * - date of warrant (DOW) range (check date)
  *    
  * @param  clientID      Client id
  * @param  startDateDOS  Starting DOS
  * @param  endDateDOS    Ending DOS
  * @param  startDateDOW  Starting DOW
  * @param  endDateDOW    Ending DOW
  * @return               Table 
  ***************************************************************************/  

declare @pracsPaid as table (
    [Client]                      nvarchar (max)
  , [Group]                       nvarchar (max) 
  , [Practitioner]                nvarchar (max) 
  , [Active]                      bit              
  , [Assessments]                 NUMERIC(18,8) default(0)
  , [Services & Transportation]   NUMERIC(18,8) default(0)
  , [TCM]                         NUMERIC(18,8) default(0)
  , [Total]                       NUMERIC(18,8) default(0)
  , PRAC_CHECKSUM                 varbinary(64) not null
  unique clustered (PRAC_CHECKSUM)
)

declare @pracsNotPaidButWeNeedToReportOn as table (
    [Client]                      nvarchar (max)
  , [Group]                       nvarchar (max)
  , [Practitioner]                nvarchar (max)
  , PRAC_CHECKSUM                 varbinary(64)
  unique clustered (PRAC_CHECKSUM)
)

/*-------------------------------
 * Get all pracs that have 
 * payments or adjustements
 *------------------------------*/
;
with
cte_p1
as
(
  select 
      t1.[CLIENT_ID]
    , t1.[PRACTITIONER_ID]
    , t1.[ASSESSMENTS]
    , t1.[SERVICES_AND_TRANSPORTATION] 
    , t1.[TCM]                        
    , t1.[AMOUNT_DISBURSED]           
  from dbo.RPT_CLAIMS_PAID_BY_DATE_CORE (@clientID, @startDateDOS, @endDateDOS, @startDateDOW, @endDateDOW) as t1       
)
,

/* Initial aggregation */

cte_p2
as
(
  select 
      p1.CLIENT_ID
    , p1.PRACTITIONER_ID 
    , [Assessments]                 = sum (p1.[ASSESSMENTS])
    , [Services & Transportation]   = sum (p1.[SERVICES_AND_TRANSPORTATION])
    , [TCM]                         = sum (p1.[TCM])
    , [Total]                       = sum (p1.[AMOUNT_DISBURSED])
  from cte_p1 as p1
  group by 
      p1.CLIENT_ID
    , p1.PRACTITIONER_ID
)
,

/* Get prac names, group names, etc
 * and convert active to a number so we can aggregate this value in the next
 * step.
 */

cte_p3
as
(
  select 
      [Client]       = clc.CLIENT_NAME
    , [Group]        = COALESCE(pgr.GROUP_NAME, pgd.GROUP_NAME)   
    , [Practitioner] = dbo.CREATE_CONCAT_NAME (prp.LAST_NAME, prp.FIRST_NAME) 
                    + ' (' 
				    + isnull(pgd.GROUP_NAME_ABBREVIATION,'NA') 
				    + ')' 
    , ActiveNum = convert(tinyint,(isnull(prp.ACTIVE,0)))
    , p2.[Assessments]
    , p2.[Services & Transportation]
    , p2.[TCM]
    , p2.[Total]
  from cte_p2                        as p2
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = p2.PRACTITIONER_ID
  join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID       = p2.CLIENT_ID
  join      dbo.PRACTITIONER_GROUPS_VIEW_CORE(124) as pgd on pgd.PRACTITIONER_ID = p2.PRACTITIONER_ID
  left join dbo.PRACTITIONER_GROUPS_VIEW_CORE(35)  as pgr on pgr.PRACTITIONER_ID = p2.PRACTITIONER_ID
)
,

/* Aggregate rows with same prac, and group names */

cte_p4
as
(
  select 
      p3.[Client] 
    , p3.[Group]
    , p3.[Practitioner]
    , ActiveTot                   = sum(p3.ActiveNum)
    , [Assessments]               = sum(p3.[Assessments])
    , [Services & Transportation] = sum(p3.[Services & Transportation])
    , [TCM]                       = sum(p3.[TCM])
    , [Total]                     = sum(p3.[Total])
  from cte_p3 as p3
  group by
      p3.[Client] 
    , p3.[Group]
    , p3.[Practitioner]
)

/* Convert active sum back into a flag, create a unique hash for the
   client + prac (group) + rept group name and populate pracsPaid */

insert into @pracsPaid (
    [Client]     
  , [Group]    
  , [Practitioner]
  , [Active]      
  , [Assessments] 
  , [Services & Transportation] 
  , [TCM]  
  , [Total] 
  , PRAC_CHECKSUM
)
select       
      p4.[Client] 
    , p4.[Group]
    , p4.[Practitioner]
    , Active = convert(bit,(iif((p4.ActiveTot > 0),1,0)))
    , [Assessments]    
    , [Services & Transportation] 
    , [TCM]  
    , [Total]
	, PRAC_CHECKSUM = HASHBYTES('SHA2_512'
		                     , ( isnull([Client],N'')
	                         + N'|' 
	                         + isnull([Group],N'')
                             + N'|'
	                         + isnull([Practitioner],N'')))
from cte_p4 as p4
option (recompile)

/*-------------------------------
 * Get all pracs that dont have
 * payments or adjustements
 * but we need to report on
 *------------------------------*/

/* Get active pracs that are currently with client and can be included in fin reports */

;with
cte_p1
as
(
  select 
      [Client]       = clc.CLIENT_NAME
    , [Group]        = COALESCE(pgr.GROUP_NAME, pgd.GROUP_NAME)   
    , [Practitioner] = dbo.CREATE_CONCAT_NAME (prp.LAST_NAME, prp.FIRST_NAME) 
                     + ' (' 
				     + isnull(pgd.GROUP_NAME_ABBREVIATION,'NA') 
				     + ')' 
  from      dbo.CLIENTS_Client                     as clc 
  join      dbo.PRACTITIONER_CLIENT                as prc on prc.CLIENT_ID       = clc.CLIENT_ID
  join      dbo.PRACTITIONER_Practitioner          as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
  join      dbo.PRACTITIONER_GROUPS_VIEW_CORE(124) as pgd on pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID
  left join dbo.PRACTITIONER_GROUPS_VIEW_CORE(35)  as pgr on pgr.PRACTITIONER_ID = prp.PRACTITIONER_ID
  where (
        (clc.CLIENT_ID = @clientID)
    and (isnull(prp.includeInFinRepts,1) = 1)
    and (isnull(prp.Active,0) = 1)
    and (prp.currentlyWithClient = 1)
  )
)
,

/* Eliminate duplicate actives */

cte_p2
as
(
  select distinct
      p1.Client 
    , p1.[Group]
    , p1.Practitioner
  from cte_p1 as p1
)
,

/* Generate unique hash per row */
cte_p3
as
(
  select 
    p2.* 
  , PRAC_CHECKSUM = HASHBYTES('SHA2_512'
		                      , ( isnull([Client],N'')
	                          + N'|' 
	                          + isnull([Group],N'')
                              + N'|'
	                          + isnull([Practitioner],N'')))
  from cte_p2 as p2
)

/* Only include rows that are not already in paid */

insert into @pracsNotPaidButWeNeedToReportOn (
    [Client]
  , [Group] 
  , [Practitioner]
  , PRAC_CHECKSUM 
)
select 
    p3.Client
  , p3.[Group] 
  , p3.[Practitioner]
  , p3.PRAC_CHECKSUM
from cte_p3          as p3
left join @pracsPaid as t1 on t1.PRAC_CHECKSUM = p3.PRAC_CHECKSUM
where 
  (t1.PRAC_CHECKSUM is null)
option (recompile)

/*-------------------------------
 * Combine results
 *------------------------------*/

insert into @claimsPaid (
    [Client] 
  , [Group]  
  , [Practitioner]
  , [Active]      
  , [Paid]    
  , [Assessments] 
  , [Services & Transportation]
  , [TCM] 
  , [Total] 
  , [PRAC_CHECKSUM]
)
select
    [Client] 
  , [Group]  
  , [Practitioner]
  , [Active]      
  , [Paid] = 1
  , [Assessments] 
  , [Services & Transportation]
  , [TCM] 
  , [Total] 
  , [PRAC_CHECKSUM]
from @pracsPaid


insert into @claimsPaid (
    [Client] 
  , [Group]  
  , [Practitioner]
  , [Active]      
  , [Paid]    
  , [Assessments] 
  , [Services & Transportation]
  , [TCM] 
  , [Total] 
  , [PRAC_CHECKSUM]
)
select
    [Client] 
  , [Group]  
  , [Practitioner]
  , [Active]                    = 1      
  , [Paid]                      = 0
  , [Assessments]               = 0 
  , [Services & Transportation] = 0
  , [TCM]                       = 0
  , [Total] = 0
  , [PRAC_CHECKSUM]
from @pracsNotPaidButWeNeedToReportOn

return

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE] TO [webuser]
GO   
