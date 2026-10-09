USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_PARTICIPANTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_VIEW_CORE] ( 
	   @clientID       BigInt    
	 , @rosterID       Bigint
	 , @active		   Bit
	 , @recID		   Bigint
)
     
RETURNS TABLE  

AS RETURN(

	select

      rp.id 
    , rp.pracID
    , rp.rosterID
    , fyQuarterID = fyq.ID
    , FY_ID
    , QtrNum = fyq.QTR

    , fyq.QTR_DEFINITION 
    , fyq.id  FYQ_ID

    , rp.startDate
    , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.startDate)
    , startDateStr    = dbo.RPT_DATE_FMT		   (rp.startDate)
    , rp.endDate
    , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.endDate  )
    , endDateStr      = dbo.RPT_DATE_FMT		   (rp.endDate  )
    , pracName        = pr.CONCAT_NAME

    , pracFirstName   = pr.FIRST_NAME
    , pracLastName    = pr.LAST_NAME

		, pracTitle       = g1.GROUP_NAME
    , reportingGroup  = g2.GROUP_NAME

		, clientID        = @clientID

    , pracEmail       = pr.Email
    

		, rp.reasonForStartDateChangeCode
		, reasonForStartDateChangeStr = rrs.reason
		, rp.reasonForEndDateChangeCode
		, reasonForEndDateChangeStr   = rre.reason

		                                 -- TODO: idk what how rp.hasServiceRecords is populated; don't know why we fail-over from
										 --       an sr count to the hasServiceRecords col from RMTS_PARTICIPANTS
		, hasServiceRecords		      = convert(bit, iif(sr_count != 0, 1, isnull(rp.hasServiceRecords, 0)))

		, hasServiceRecordsStr		  = iif((iif(sr_count != 0, 1, isnull(rp.hasServiceRecords, 0))) = 1, 'Yes', 'No')

		, svcRecCountTop3             = sr_count


		, hasReimbursement            = convert(bit, iif(cca.CLAIM_ID is not null, 1, isnull(rp.hasReimbursement, 0)))
		, hasReimbursementStr         = iif((iif(cca.CLAIM_ID is not null, 1, isnull(rp.hasReimbursement, 0))) = 1, 'Yes', 'No')
		, needsReasonForStartDateChange = convert(bit, iif (rp.startDate != fyq.QTR_START and isnull(reasonForStartDateChangeCode, 0) = 0, 1, 0))
		, needsReasonForEndDateChange   = convert(bit, iif (rp.endDate   != fyq.QTR_END   and isnull(reasonForEndDateChangeCode  , 0) = 0, 1, 0))
		, rp.created
		, rp.createdBy
		, rp.lastModified
		, rp.lastModifiedBy
		, submitClaims = pr.SUBMIT_CLAIMS
		, submitClaimsStr = dbo.RPT_BIT_TO_YN(pr.SUBMIT_CLAIMS)

        , g1.GROUP_ID groupID_pracTitle
        , g2.GROUP_ID groupID_reporting

		, pr.employeeRelationshipID

    , rp.deferralDate
    , rp.deferredBy 
    , rp.deferralReason
    , rp.deferralReasonNotes

	from dbo.RMTS_PARTICIPANTS                  as rp
	join dbo.RMTS_PARTICIPATION_ROSTER          as rpr	 on rpr.id             = rp.rosterID
	join dbo.COMPANY_FISCAL_QUARTERS            as fyq	 on fyq.ID             = rpr.quarterID
	join dbo.PRACTITIONER_Practitioner          as pr	 on pr.PRACTITIONER_ID = rp.pracID

	join dbo.PRACTITIONER_GROUPS                as pg	 on pg.PRACTITIONER_ID = pr.PRACTITIONER_ID and pg.GROUP_TYPE in (1,2)
	join dbo.GROUP_GROUP                        as g1	 on g1.GROUP_ID        = pg.GROUP_ID

	left join dbo.PRACTITIONER_GROUPS                as pg2	 on pg2.PRACTITIONER_ID = pr.PRACTITIONER_ID and pg2.GROUP_TYPE in (3,5)
	left join dbo.GROUP_GROUP                        as g2	 on g2.GROUP_ID        = pg2.GROUP_ID

	left join dbo.RMTS_REASONS_FOR_START_DATE_CHANGE as rrs   on rrs.id             = rp.reasonForStartDateChangeCode
	left join dbo.RMTS_REASONS_FOR_END_DATE_CHANGE   as rre   on rre.id             = rp.reasonForEndDateChangeCode
	outer apply (
	              select 
					sr_count = COUNT(sr2.id) 
				  FROM (
                    select top 3 
					  sr1.id
				    from dbo.SERVICE_RECORDS as sr1
				    where (     ((sr1.pracID   = rp.pracID)
					    	  and (sr1.dos between fyq.QTR_START and fyq.QTR_END)
						      and (sr1.id > 0))                   /* Using index [PRAC_DOS_W_STATE]*/
						      and (sr1.[state] not in (99, 199))  /* Exclude deleted and CIF */
					  )
                    ) sr2
	            ) as sr
	outer apply (select top 1
					 cca1.CLAIM_ID
				 from dbo.CLAIM_Claim as clm 				 
	left join dbo.CLAIM_Claim_Adjudication  as cca1 on (
													   (cca1.CLAIM_ID = clm.CLAIM_ID)
												   and (cca1.AMOUNT_PAID > 0)
												   )
	where (
			(clm.CLIENT_ID = @clientID								)
		and (clm.SERVICE_DATE between fyq.QTR_START and fyq.QTR_END	)
		and (clm.[STATUS] = '3' /* Paid */							)
		and (clm.PRACTITIONER_ID = pr.PRACTITIONER_ID				)
		and (pr.employeeRelationshipID = 10 /* Employee */          )
		)
	) as cca
	where (
			(1=1)

        -- pardon my ignorance, but after 7+ years I've still never learned what the
        --  1=1 AND syntax is useful for
 
        --   ... still don't know what the 1=1 syntax is useful for
                 
		and ((@recID     is null)  or (rp.pracID   = @recID))
		and ((@rosterID  is null)  or (rp.rosterID = @rosterID))
		and (rpr.clientID = @clientID)
    )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_VIEW_CORE] TO [webuser]
GO