USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE] (
    @clientID            as bigint
  , @groupSvcClassNameID as bigint
)   
RETURNS TABLE

 /***************************************************************************    
  * PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE */    
 /**    
  * Returns data from 
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(

with
cte_p1
as
(
  select 
     t1.*   
    , appliesToGroupSvcClassNameID = convert(bit,(case 
      when (@groupSvcClassNameID = 2)
	    then iif((t1.appliesToGroupSvcClassNameID2 = 1)
		         ,1
				 ,0)
      when (@groupSvcClassNameID = 3)  
	    then iif((t1.appliesToGroupSvcClassNameID3 = 1)
		         ,1
				 ,0)
      when (@groupSvcClassNameID = 4)  
	    then iif((t1.appliesToGroupSvcClassNameID4 = 1)
		         ,1
				 ,0)
	  when (@groupSvcClassNameID = 6)  
	    then iif((t1.appliesToGroupSvcClassNameID6 = 1)
		         ,1
				 ,0)
	  when (@groupSvcClassNameID = 9)  
	    then iif((t1.appliesToGroupSvcClassNameID9 = 1)
		          ,1
				 ,0)
	  when (@groupSvcClassNameID = 11) 
	    then iif((t1.appliesToGroupSvcClassNameID11 = 1)
		         ,1
				 ,0)
	  when (@groupSvcClassNameId is null) 
	    then 0
	  else 
	    0 
	  end))

  from dbo.PATIENT_PROMISED_SERVICES_UPCOMING_IEPS as t1 
  where 
    (t1.clientID = @clientID)
)
,
cte_p2
as
(
  select 
        p1.* 
      , assmtRecordedForGroupSvcClassNameID = convert(bit,(iif((sr2.id is null), 0, 1)))
      , assmtRecordedDate                   = sr2.dos
	  , assmtRecordedPracID                 = sr2.pracID
  from cte_p1 as p1

  /* Find recorded iep assessments */
  
  outer apply (
    select top 1
          sr1.id
		, sr1.dos
		, sr1.pracID
    from dbo.SERVICE_RECORDS as sr1
    where ( 
	    
		   /* Uses index CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS */
          
		  /* Key part */
		  
		  ((sr1.clientID           = p1.clientID)
      and (sr1.patID               = p1.patID)
      and (sr1.pracGrpSvcClsNameID = @groupSvcClassNameID)
      and (sr1.svcType             = 1)
      and (sr1.dos between p1.startDosToSearchForRecordedAmmts and p1.endDosToSearchForRecordedAssmts)
	  and (sr1.id is not null))
	  
	  /* Additional columns */
	  
	  and (sr1.isIFSPorIEP = 1)       /* SpEd only */
	  and (sr1.svcSubType1 != 1002)   /* Exclude ammended.  We only want to search for init/tri and annual */
      and (sr1.patAbsent   != 1)      /* Exclude doc only */
	  and (sr1.pracAbsent  != 1)      /* Exclude doc only */
	  and (sr1.state not in (99,199)) /* Exclude deleted or cifd */
  )
  order by
    sr1.dos desc
  ) as sr2
)
select 
  p2.* 
from cte_p2 as p2
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE] TO [webuser]
GO