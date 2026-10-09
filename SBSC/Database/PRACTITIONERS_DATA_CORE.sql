USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONERS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONERS_DATA_CORE]  (
    @source                         INT
  , @clientID                       BIGINT
  , @patID                          BIGINT
  , @refDate                        DATETIME
  , @refPracGroupServiceClassNameID BIGINT
)    

RETURNS TABLE

 /***************************************************************************    
  * PRACTITIONERS_DATA_CORE */    
 /**    
  * Returns core set of practitioner ids    
  *    
  * @param  source                           Required               Source of data
  * @param  clientID                         Required               Client ID
  * @param  patID                            Optional & Contextual  Patient ID
  * @param  refDate                          Optional & Contextual  Reference date
  * @param  refPracGroupServiceClassNameID   Optional & Contextual  Group service class name id 
  * @return Table of client and practitioner ids 
  ***************************************************************************/     

AS RETURN
(

  with

  /*-------------------------------
   * All
   * Note: This is technically
   * all active due to how we
   * use this in the middleware
   * Do not refactor this.
   *------------------------------*/
  
  cte_0
  as
  (        
  select [SOURCE] = 0, *
  from
  (
    select * from dbo.PRACTITIONER_CLIENT
  ) as p_all
  )
  ,

  /*-------------------------------
   * Service history
   *------------------------------*/    

  cte_1
  as
  (  
    select [SOURCE] = 1, *
    from
    (
      select pc.*
      from dbo.PRACTITIONER_CLIENT as pc
      join 
      (      
        select 
          distinct pracID as [PRACTITIONER_ID]
        from  dbo.SERVICE_RECORDS as sr
        where 
          (1=1)
          and (sr.state <> dbo.CONST_SVC_REC_STATE_DEL()) 
          and (sr.state <> dbo.CONST_SVC_REC_STATE_CIF()) 
          and ((@clientID is null) or (clientID = @clientID))
          and ((@patID    is null) or (patID    = @patID))   
      ) as sh on sh.[PRACTITIONER_ID] = pc.PRACTITIONER_ID    
    ) as p_sh
   )
   ,
  
  /*-------------------------------
   * Practitioner case load
   *------------------------------*/  

   cte_2
   as
   (     
   select [SOURCE] = 2, *
   from
   (
      select distinct 
        pc.*
      from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
      join dbo.PRACTITIONER_Client           as pc on ((pc.CLIENT_ID = ppc.clientID) and (pc.PRACTITIONER_ID = ppc.pracID))
	  where ( 
	          (1=1)
          and ((@clientID is null) or (ppc.clientID = @clientID))
	      and (ppc.pracID is not null)
	      and ((@patID is null) or (ppc.patID = @patID))
	  )
	) as p_cl
    )  
    ,

    /*-------------------------------
     * One on One Aide Assignments
     *------------------------------*/

    cte_3
    as
    (
      
    select [SOURCE] = 3, *
    from
    (
      select distinct pc.*
      from dbo.PRACTITIONER_CLIENT as pc
      join 
      (
        select distinct
          PRACTITIONER_ID
        from 
          dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE(@clientID,null,@patID,@refDate)
      ) as aa on aa.[PRACTITIONER_ID] = pc.PRACTITIONER_ID
      
    ) as p_aa
    )
    ,

    /*-------------------------------
     * Inactive
     *------------------------------*/

    cte_4
    as
    (
    select [SOURCE] = 4, * 
    from
    (
      select 
         pc.*
      from dbo.PRACTITIONER_Client       as pc
      join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
      where 
        pp.ACTIVE = 0
        and ((@clientID is null) or (pc.CLIENT_ID = @clientID))
    ) as p_all_inactive
    ) 
   
    ,

    /*-------------------------------
     * Transportation Only
     *------------------------------*/
     
    cte_5
    as
    (
    select [SOURCE] = 5, * 
    from
    (
      select 
        prc.*
      from dbo.PRACTITIONER_Client       as prc
      join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID
      join dbo.PRACTITIONER_GROUPS       as prg on  prg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
                                         and prg.GROUP_TYPE in (1,2)
                                         and prg.ACTIVE = 1
      join dbo.GROUP_Group               as grg on  grg.GROUP_ID = prg.GROUP_ID
                                         and grg.GROUP_TYPE in (1,2)
                                         and grg.PARENT_GROUP_ID = 163
                                         and grg.ACTIVE = 1
      where ((1=1) and ((@clientID is null) or (prc.CLIENT_ID = @clientID)))
    ) as trans
    
    )
	, 
 
    /*-------------------------------
     * Potential ORP only
     *------------------------------*/
 
    cte_6 
    as
	(
	  
	  /* Note: The GROUP_SERVICE_NAME_CLASS_ID in this case 
	     is highly dependenrt on the partition id (200) and is not 100% interchangable
		 with other partitions because some practitioners from different group families
		 can function as ORPs outside of their group family.  For example RCSNs 
		 (group family = 3) can be the ORP for counselling services (group family = 2) 
		 but they cannot be an ORP within their own group.	   
	   */

	  select 
         [SOURCE] = 6 
		,prc.*
      from dbo.PRACTITIONER_Client       as prc
      join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID
      join dbo.PRACTITIONER_GROUPS       as prg on  prg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
                                         and prg.GROUP_TYPE in (1,2)
      join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_SERVICE_CLASS_PARTITION_ID = 200
	                                                                    and png.GROUP_ID                        = prg.GROUP_ID
      where (
	         (1=1) 
	    and ((@clientID is null) or (prc.CLIENT_ID = @clientID))
		and ((@refPracGroupServiceClassNameID is null) or (png.GROUP_SERVICE_CLASS_NAME_ID = @refPracGroupServiceClassNameID))
	  )
	)
	, 
 
    /*-------------------------------
     * All Active and Inactive
     *------------------------------*/
 
    cte_7 
    as
	(
	  
	  select [SOURCE] = 7, p_all_active_and_inactive.* 
      from
      (
        select 
         pc.*
        from dbo.PRACTITIONER_Client       as pc
        where (
	         (1=1)
	     and ((@clientID is null) or (pc.CLIENT_ID = @clientID))
	    )
      ) as p_all_active_and_inactive
	)
	,
	
	/*-------------------------------
     * Within standard practice family
	 * only
     *------------------------------*/
 
    cte_8 
    as
	(
	  
	  /* Note: The GROUP_SERVICE_NAME_CLASS_ID in this case 
	     is for partition id (100) 
	   */

	  select 
         [SOURCE] = 8 
		,prc.*
      from dbo.PRACTITIONER_Client       as prc
      join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID
      join dbo.PRACTITIONER_GROUPS       as prg on  prg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
                                         and prg.GROUP_TYPE in (1,2)
      join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
	                                                                    and png.GROUP_ID                        = prg.GROUP_ID
      where (
	         (1=1) 
	    and ((@clientID is null) or (prc.CLIENT_ID = @clientID))
		and ((@refPracGroupServiceClassNameID is null) or (png.GROUP_SERVICE_CLASS_NAME_ID = @refPracGroupServiceClassNameID))
	  )
	)
    select *
    from
    (    
          select * from cte_0
    union select * from cte_1
    union select * from cte_2
    --union select * from cte_3
    union select * from cte_4
    union select * from cte_5
	union select * from cte_6
    union select * from cte_7
	union select * from cte_8

	) as q1
    where 
    (1=1)                  and
    (q1.source = @source)  and
    ((@clientID is null) or (q1.CLIENT_ID = @clientID))
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONERS_DATA_CORE] TO [webuser]
GO

  