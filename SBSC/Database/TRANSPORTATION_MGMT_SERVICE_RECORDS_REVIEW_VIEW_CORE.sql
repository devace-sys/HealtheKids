USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE] (
   @userID            BIGINT   
  ,@userGroup         INT    
  ,@userRank          INT
  ,@clientID          BIGINT
  ,@patID             BIGINT
  ,@startDate         datetime
  ,@endDate           datetime )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_REVIEW_TRANSPORTATION_VIEW_CORE */    
/**    
 *     
 * @return Service records
 ***************************************************************************/     
    
return 
(        
  
  with
  cte_p1
  as
  (
    select   
        [svcRecID]  = sr.id
      , [newDetail] = convert(bit,case when (srr.id is null) then 1 else 0 end)
      , [dosVal]    = sr.dos
      , [milesVal]  = dbo.CALC_TOTAL_MILES_8 (  sr.trip1Start
                                              , sr.trip1End
                                              , sr.trip2Start
                                              , sr.trip2End
                                              , sr.trip3Start
                                              , sr.trip3End
                                              , sr.trip4Start
                                              , sr.trip4End )
  
      , [okToBill]  = isnull(srr.OK_TO_BILL,convert(bit,1))
      , [notes]     = isnull(srr.NOTES,'')
    
    from      dbo.SERVICE_RECORDS                              as sr
    left join dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED as srr on srr.SVC_REC_ID = sr.ID
                                                                    
    where (
          (sr.clientID = @clientID)
      and (sr.patID    = @patID)
      and (sr.svcType  = dbo.CONST_SERVICES_TRANSPORT())
      and (sr.dos between @startDate and @endDate)
      and (sr.state != dbo.CONST_SVC_REC_STATE_CIF())
      and (sr.state != dbo.CONST_SVC_REC_STATE_DEL())
      and ((srr.OK_TO_BILL is null) or (srr.OK_TO_BILL = 0))
    )
  )
  ,
  cte_p2
  as
  (
    select 
        *
      , [dosStr]    = dbo.RPT_DATE_FMT(dosVal) 
      , [milesStr]  = convert(varchar,milesVal) 
    from cte_p1                   
  )
  
  select * from cte_p2
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE] TO [webuser]
GO