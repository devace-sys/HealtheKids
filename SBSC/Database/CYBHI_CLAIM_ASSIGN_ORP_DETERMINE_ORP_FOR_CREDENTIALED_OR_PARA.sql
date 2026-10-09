USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA] (    
    @cybhiClinicalSupervisorPracID bigint = 0
  , @renderingPracID               bigint
  , @dos                           date
  , @tommorow                      date
  , @svcRecID                      bigint 
) 
returns bigint
as
begin
  
  declare @orpPracID         as bigint = 0
  declare @reqSvcRecApproval as bit    = 0
  declare @svcRecApprovalID  as bigint = null
  declare @svcRecReviewed    as bit    = null
  declare @svcRecApproved    as bit    = null

  /* ########## Find CYBHI ORP relationship if one exists ########## */

  set @orpPracID = 0

  select top 1 
      @orpPracID         = isnull(ppdss.SUPERVISING_PRAC_ID,0)
    , @reqSvcRecApproval = ppdss.requireSvcRecApprovalForNonProgCompRels  
  from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
  
  /* Uses index */

  where (   
        (ppdss.ACTIVE = 1)
    and (ppdss.SUPERVISED_PRAC_ID = @renderingPracID)
    and (@dos between convert(date,ppdss.START_DATE) and convert(date,isnull(ppdss.END_DATE,@tommorow)))
    and (ppdss.SUPERVISING_PRAC_ID is not null)
    and (ppdss.ID is not null)
    and (ppdss.relationshipTypeID = 20)
  )
  
  /* ########## If a ORP relationship exists ########## */

  if (@orpPracID != 0)
  begin
    
	/* ##### And service record approval is required ##### */

    if (@reqSvcRecApproval = 1)
    begin
    
	  /* ### Get service record approval record reference and status ### */
      
	  set @svcRecApprovalID = -1

      select top 1
	      @svcRecApprovalID = isnull(t1.id,-1)
	    , @svcRecApproved   = t1.approved
	    , @svcRecReviewed   = t1.reviewed
	  from dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS as t1
	  where (    ((t1.svcRecID        = @svcRecID))
	         and (t1.renderingPracID  = @renderingPracID)
	         and (t1.assignedToPracID = @orpPracID)
	  	     and (t1.active           = 1)
      )
	  
	  /* ### If no service record approval record exists 
	         then the requirement was probably set after this service was recorded 
			 so we treat this as if the orp did not require review ### */

	  if (@svcRecApprovalID = -1)
	  begin
	    return @orpPracID
	  end
	  
	  /* ### If service record has not been reviewed yet then return a 0 so claim will be held ### */

	  if (@svcRecReviewed = 0)
	  begin	    
	    return 0
	  end

	  /* ### If service record has not been approved then return a 0 so claim will be held ### */

	  if (@svcRecApproved = 0)
	  begin	    
	    return 0
	  end
	  
	  /* ### If service record has been approved then return the supervising prac as the orp ### */

	  else	  
	  begin
	    return @orpPracID
	  end
	 
	  /* ### Should never get to this point but if we do return a 0 so the claim will be held while we investigate ### */
	  
	  return 0
	
	end /* Approval required */

    /* ##### Otherise if no approval required then return the supervising prac as the orp #####*/

	else
	begin
	  return @orpPracID
	end
  end
    
  /* ########## If no ORP relationship exists then fallback to using clinical supervisor (if provided) ########## */

  else  
  begin
    set @cybhiClinicalSupervisorPracID = isnull(@cybhiClinicalSupervisorPracID,0)
	return @cybhiClinicalSupervisorPracID	
  end
  
  /* ########## Should never get to this point but if we do return 0 so claim is held ########## */
  
  return 0

end

GO
