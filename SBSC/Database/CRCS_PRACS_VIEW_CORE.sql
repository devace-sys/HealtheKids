USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRACS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRACS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PRACS_VIEW_CORE] ( 
	   @clientID           BigInt    
	 , @fq_id              Bigint
   , @quarterNumber      Int
   , @paramOrigRosterID  BigInt 
)
     
RETURNS TABLE  

AS RETURN(

        with quarter_to_query as (
          SELECT
            IIF ( 
              @quarterNumber = 1
              AND
              @fq_id >= 113
              ,
              2
              ,
              @quarterNumber
            ) quarterNumber
            ,
            IIF (
              @quarterNumber = 1
              AND
              @fq_id >= 113
              ,
              ( @fq_id + 1 )
              ,
              @fq_id        
            ) cfq_id
            ,

            IIF (
              @quarterNumber = 1
              AND
              @fq_id >= 113
              ,
              1
              ,
              0       
            ) force_lookup_q1_dates

        ),

        roster_to_query as (

          SELECT
            quarter_to_query.* ,

            cfq.FY_ID     ,


            ISNULL( cfq_q1.QTR_START , cfq.QTR_START ) QTR_START ,
            ISNULL( cfq_q1.QTR_END   , cfq.QTR_END   ) QTR_END  ,

            ISNULL( s2.rosterID, s1.rosterID) rosterID
            -- !!!!
            -- This ISNULL logic works different, both times.
            -- The first ISNULL we are returning the Q1 dates, if they have been looked up;
            -- The third ISNULL we are returning the Q2 rosterID, if it has been looked up.

          FROM
            quarter_to_query

          OUTER APPLY
          (  SELECT top 1 * from COMPANY_FISCAL_QUARTERS WHERE id = cfq_id ) cfq

          OUTER APPLY
          (  SELECT top 1 * from COMPANY_FISCAL_QUARTERS
             WHERE
               force_lookup_q1_dates = 1
               AND
               id = @fq_id ) cfq_q1

          OUTER APPLY
            ( SELECT @paramOrigRosterID rosterID ) s1

          OUTER APPLY
            ( SELECT top 1

                r.id rosterID

              FROM dbo.RMTS_PARTICIPATION_ROSTER r

              WHERE

                quarter_to_query.cfq_id != @fq_id  -- !!!!
                                                   -- !!!!

                AND
                r.clientID = @clientID
                AND
                r.quarterID = quarter_to_query.cfq_id

            ) s2

        )

	select
		  rp.id 
		, rp.pracID

		--, rp.rosterID

		, fyQuarterID = cfq_id

    , r_q.*
              

    -- ...
    /*

		, rp.startDate
		, startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.startDate)
		, startDateStr    = dbo.RPT_DATE_FMT		   (rp.startDate)
		, rp.endDate
		, endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(rp.endDate  )
		, endDateStr      = dbo.RPT_DATE_FMT		   (rp.endDate  )
    */
    -- ...

		, r_q.QTR_START      startDate
		, startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(r_q.QTR_START)
		, startDateStr    = dbo.RPT_DATE_FMT		   (r_q.QTR_START)

		, r_q.QTR_END       endDate
		, endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD( r_q.QTR_END  )
		, endDateStr      = dbo.RPT_DATE_FMT		   ( r_q.QTR_END  )

		, pracName        = rp.pracName

    , pracFirstName   = rp.pracFirstName
    , pracLastName    = rp.pracLastName

    , pracTitle       = rp.pracTitle
    , reportingGroup  = rp.reportingGroup

    , crcsPracticeFamilyName      = ggsvc.GROUP_SERVICE_CLASS_NAME

		, clientID        = @clientID

    , pracEmail       = rp.pracEmail

		, rp.reasonForStartDateChangeCode
		, reasonForStartDateChangeStr = rp.reasonForStartDateChangeStr
		, rp.reasonForEndDateChangeCode
		, reasonForEndDateChangeStr   = rp.reasonForEndDateChangeStr

		, hasServiceRecords		      
		, hasServiceRecordsStr		  
		, hasReimbursement            
		, hasReimbursementStr        
		, needsReasonForStartDateChange 
		, needsReasonForEndDateChange   
		, rp.created
		, rp.createdBy
		, rp.lastModified
		, rp.lastModifiedBy
		, submitClaims = rp.submitClaims
		, submitClaimsStr = rp.submitClaimsStr
		, rp.employeeRelationshipID

	from 

   roster_to_query r_q

   CROSS APPLY

   --

   RMTS_PARTICIPANTS_VIEW_CORE ( 
	   @clientID
	 , r_q.rosterID

	 , 1

	 , null
)  rp

        join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as ggsvcp on ggsvcp.GROUP_ID = rp.groupID_pracTitle
             and
             ggsvcp.GROUP_SERVICE_CLASS_PARTITION_ID = 600
                                          -- wish these numeric constants were commented more consistently
 
        join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES     as ggsvc
              on   ggsvc.GROUP_SERVICE_CLASS_NAME_ID = ggsvcp.GROUP_SERVICE_CLASS_NAME_ID
    --


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRACS_VIEW_CORE] TO [webuser]
GO