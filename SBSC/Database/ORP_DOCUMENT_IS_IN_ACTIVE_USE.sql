USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_IS_IN_ACTIVE_USE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_IS_IN_ACTIVE_USE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ORP_DOCUMENT_IS_IN_ACTIVE_USE] (@clientID bigint, @orpDocID as bigint)
RETURNS BIT
AS     
BEGIN    
  
  /* TODO: Remove this temp disable of function when we have orp doc merge in place.*/
  /* TODO: Consider removing the use of this function and the function itself.  It may no longer be needed. */
  
  return 0

  
  if (@orpDocID is null) return null
  if (@orpDocID <= 0)    return null
  
  declare @orpDocTypeID            as bigint = null
  declare @groupServiceClassNameID as bigint = null 
  declare @clientIDRec             as bigint = null
  declare @patID                   as bigint = null
  declare @recID                   as bigint = null
  declare @startDate               as datetime = null
  declare @endDate                 as datetime = null
  declare @numRelatedSvcRecs       as bigint = 0
  declare @numRelatedJenRecs       as bigint = 0
  declare @numRelatedRecs          as bigint = 0

  select top 1    
      @recID                   = odc.id
    , @clientIDRec             = odc.CLIENT_ID
    , @patID                   = odc.PATIENT_ID
	, @startDate               = odc.START_DATE
	, @endDate                 = odc.END_DATE
    , @orpDocTypeID            = odc.ORP_DOCUMENT_TYPE_ID
    , @groupServiceClassNameID = odc.GROUP_SERVICE_CLASS_NAME_ID

  from dbo.ORP_DOCUMENTS_DATA_CORE (@clientID,null,null,null,null,@orpDocID,null) as odc

  where (
         (odc.ID = @orpDocID)
    and ((@clientID is null) or (odc.CLIENT_ID = @clientID))
  )
  
  if (@recID is null) return null

  if (@orpDocTypeID = 1)
  begin
    select 
	  @numRelatedSvcRecs = count(sr.id) 
	  from dbo.SERVICE_RECORDS as sr
	  where     
	        (sr.clientID = @clientIDRec)
	    and (sr.dos between @startDate and @endDate)
	    and (sr.orpDocID = @recID)
		and (sr.state not in ( dbo.CONST_SVC_REC_STATE_DEL(), dbo.CONST_SVC_REC_STATE_CIF()))
  end
  else
  begin
    
	select 
	  @numRelatedSvcRecs = count(sr.id) 
	 from dbo.SERVICE_RECORDS as sr
	 where (     
	        (sr.clientID = @clientIDRec)
        and (sr.patID    = @patID)
		and (sr.dos between @startDate and @endDate)
	    and (sr.orpDocID = @recID)
		and (sr.state not in ( dbo.CONST_SVC_REC_STATE_DEL(), dbo.CONST_SVC_REC_STATE_CIF()))
	 )

	 /* Check journal entries if we can and if neccessary */

	 if (@groupServiceClassNameID = 3)
	 begin
	   select 
	      @numRelatedJenRecs = count (sjee.id)
	   from dbo.SvcJournals              as sj
	   join dbo.SvcJournal_Event_Entries as sjee on sjee.journalID = sj.id
	   where (
	         (sj.clientID = @clientIDRec)
	     and (sj.patID    = @patID)
	     and (sj.dos between @startDate and @endDate)
		 and (sj.active = 1)
		 and (sjee.active = 1)
		 and (sjee.orpDocID = @recID)
	   )	   
	 end
  end

  set @numRelatedRecs = @numRelatedSvcRecs + @numRelatedJenRecs
  if (@numRelatedRecs != 0) return 1
  return 0
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[ORP_DOCUMENT_IS_IN_ACTIVE_USE] TO [webuser]
GO