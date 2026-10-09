USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          BIGINT
  , @orpDocumentID                     BIGINT
)    


RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED */    
 /**    
  * 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(  
  with
  cte_st
  as
  (
	select top 1 
	  t1.responseCode 
	from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @orpDocumentID, null, null, null) as t1
	order by 
	  t1.id            desc
    , t1.effectiveDate desc
    , t1.enteredOn     desc
  )
  ,
  
  cte_p1
  as
  (  
    select top 1   
	    lastApprovalOrpPracID            = t1.orpPracID
	  , lastApprovalOrpName              = t1.orpPracName 
      , lastApprovalOrpTitle             = t1.orpPracTitle
      , lastApprovalOrpNPI               = t1.orpPracNPI
      , lastApprovalEffectiveDate        = t1.effectiveDate
      , lastApprovalEffectiveDateStr     = t1.effectiveDateStr
      , lastApprovalExpirationDate       = t1.expirationDate
      , lastApprovalExpirationDateStr    = t1.expirationDateStr
	  , lastApprovalExpiresInDays        = datediff(day,getdate(),t1.expirationDate)
	  , lastApprovalOrpIsValidMcalOrp    = t1.orpIsValidMcalOrp
	  , lastApprovalOrpIsValidMcalOrpStr = t1.orpIsValidMcalOrpStr
    from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @orpDocumentID, null, null, null) as t1
      
    order by 
	    t1.id            desc
      , t1.effectiveDate desc
      , t1.enteredOn     desc
  )
  ,
  cte_p2
  as
  (
    select top 1
	    p1.*       
	  , lastApprovalExpirationState = case 
	      when (p2.responseCode = 300)                                                   then 4
	      when (p1.lastApprovalExpiresInDays < 0 and p2.responseCode = 100)              then 3
		  when (p1.lastApprovalExpiresInDays between 0 and 30 and p2.responseCode = 100) then 2
		  when (p1.lastApprovalExpiresInDays > 30 and p2.responseCode = 100)             then 1
		  when (p2.responseCode = 200)													 then 0		  
		end

	  from cte_p1 as p1
	  cross apply cte_st as p2
  )
  ,
  cte_p3
  as
  (
  select top 1
    p2.* 
  	, lastApprovalExpirationMessage = case 
	     when (lastApprovalExpirationState = 4)  then 'Denied'
		 when (lastApprovalExpirationState = 3)  then 'Expired For ' + convert(varchar,abs(lastApprovalExpiresInDays)) + ' days' 
		 when (lastApprovalExpirationState = 2)  then 'Expiring In ' + convert(varchar,lastApprovalExpiresInDays)      + ' days'
         when (lastApprovalExpirationState = 1)  then 'Current'
		 when (lastApprovalExpirationState = 0)  then 'Not Yet Signed or Pending Signature/Authorization'	
		 /* Was: Not Signed or Pending E-Authorization*/
	  end

  from cte_p2 as p2

  )
  select top 1 p3.* from cte_p3 as p3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED] TO [webuser]
GO  
