USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE]
(
    @userID           bigint
  , @userGroup        int
  , @userRank         int
  , @clientID         bigint
  , @pracID           bigint
  , @dos              datetime
  , @billingProgramID tinyint
  , @svcRecID         bigint
  , @saveType         int
  , @validateRec      bit
)
AS
BEGIN

    SET NOCOUNT ON

	if (@validateRec = 1) return

    declare @supervisingPracIdForCybhiOrp         as bigint   = -1
    declare @supervisingPracIdForInternal         as bigint   = -1
    declare @requireSvcRecApprovalForCybhiOrp     as bit      = 0
	declare @today                                as datetime = getdate()

    /*============================================================
     * On edit or delete: deactivate rows for this 
     * service record so they can be re-evaluated fresh
     *
	 * This will be done for all related svc records for any
	 * type of supervision relationship managed by this routine
	 *============================================================*/

    if (@saveType in (2,3))
    begin

        update dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS 
		set 
		  active         = 0
		, lastModified   = @today
		, lastModifiedBy = @userID
		where (
		      (svcRecID = @svcRecID)
		  and (active = 1)
		)

        update dbo.SERVICE_RECORDS_INTERNAL_REVIEWS  
		set 
		  active         = 0
		, lastModified   = @today
		, lastModifiedBy = @userID
		where (
		      (svcRecID = @svcRecID)
		  and (active = 1)
		)

       /*============================================================
        * If this is a delete there is nothing more to do so exit
        *============================================================*/

	   if (@saveType = 3) return

	end

    /*============================================================
     * CYBHI ORP review (type 20 relationship)
     * Only applicable when billing program is CYBHI (2)
     *============================================================*/

    if (@billingProgramID = 2) /* CYBHI */
    begin
	    
		/* Check if we have a supervision relationship for cybhi clinical sup/orp.
		 * Note: Only allowed one at a time
		 */

        select top 1
            @supervisingPracIdForCybhiOrp         = isnull(ppdss.SUPERVISING_PRAC_ID, -1)
          , @requireSvcRecApprovalForCybhiOrp     = ppdss.requireSvcRecApprovalForNonProgCompRels
        from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
        where (
                /* Uses index: [ACTIVE_SUPERVISED_START_END_IDX] */
                (ppdss.ACTIVE             = 1)
            and (ppdss.SUPERVISED_PRAC_ID = @pracID)
			and (@dos between (ppdss.START_DATE) and (isnull(ppdss.END_DATE, @dos)))
            and (ppdss.SUPERVISING_PRAC_ID is not null)
            and (ppdss.ID                  is not null)
            and (ppdss.relationshipTypeID  = 20)
        )
        order by 
		  ppdss.id desc /* Get most recently added */

		/* If we have one */

        if (@supervisingPracIdForCybhiOrp != -1)
        begin
            
			/* And the relationship specifies that the supervisor must review service records */

			if (@requireSvcRecApprovalForCybhiOrp = 1)
            begin
			  
			  /* Then generate a review record*/

              insert into dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS (
                  clientID
                , renderingPracID
				, assignedToPracID
                , assignedOn
		        , svcRecID
                , created
                , createdBy
              )
              values (
                @clientID
			  , @pracID
              , @supervisingPracIdForCybhiOrp
              , @today
		      , @svcRecID
              , @today
              , @userID
            )

          end /* Requires approval */

        end /* Has ORP relationship for CYBHI */

    end /* CYBHI billing program */

    /*============================================================
     * Internal review (type 30 relationship)
     * Applicable for all billing programs
     *============================================================*/
	
	/* Check if we have an internal review relationship.  
	 * Note: Only allowed one at a time
	 */

    select top 1
        @supervisingPracIdForInternal = isnull(ppdss.SUPERVISING_PRAC_ID, -1)
    from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
    where (
            /* Uses index: [ACTIVE_SUPERVISED_START_END_IDX] */
            (ppdss.ACTIVE             = 1)
        and (ppdss.SUPERVISED_PRAC_ID = @pracID)
        and (@dos between (ppdss.START_DATE) and (isnull(ppdss.END_DATE, @dos)))
        and (ppdss.SUPERVISING_PRAC_ID is not null)
        and (ppdss.ID                  is not null)
        and (ppdss.relationshipTypeID  = 30)
    )
    order by 
	  ppdss.id desc /* Get most recently added */

	/* If an internal relationship exists */

    if (@supervisingPracIdForInternal != -1)
    begin
	    
		/* Then generate a review record */
        
		insert into dbo.SERVICE_RECORDS_INTERNAL_REVIEWS (
            clientID
          , renderingPracID
		  , assignedToPracID
          , assignedOn
		  , svcRecID
          , created
          , createdBy
        )
        values (
            @clientID
          , @pracID
		  , @supervisingPracIdForInternal
          , @today
		  , @svcRecID
          , @today
          , @userID
        )

    end /* Has internal relationship */

    return

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE] TO [webuser]
GO
