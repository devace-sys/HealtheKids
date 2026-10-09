USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE] (
 @userID              BIGINT,    
 @userGroup           INT,    
 @userRank            INT,
 @clientID            BIGINT, 
 @patientID           BIGINT,
 @pracID			  BIGINT,
 @siteID			  BIGINT,
 @fiscalYearID        BIGINT,
 @isCreatedByCaller   BIT,
 @isExpiring          BIT,
 @isExpired           BIT,
 @active              BIT,
 @recID               INT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
(
/*-------------------------------
 * Get plans
 *------------------------------*/

	select distinct
	   id             = pwp.ID
	 , planDate       = convert(varchar(256), pwp.PLAN_DATE)
     , planDateVal    = pwp.PLAN_DATE
	 , planDateStr	  = dbo.RPT_DATE_FMT(pwp.PLAN_DATE)
	 , planDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(pwp.PLAN_DATE)
	 , diagnosisID   = pwpd.DIAGNOSIS_ID
	 , diagnosisName = pwpd.NAME
	 , diagnosisDesc = pwpd.DESCRIPTION
	 , orpDocSelectionsJSON = (select orpDocRefID, orpDocType from
									  (
										  (select   orpDocRefID = PRESCRIBED_ORDER_ID
												  , orpDocType = 2
											  from dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE as pwpcpo
											  where pwpcpo.PLAN_ID = pwp.ID
										  )
											UNION 
										  (select   orpDocRefID = SERVICE_DESCRIPTION_ID
							  				  , orpDocType = 3
							  				  from dbo.PLAN_WRITER_PLANS_CONDITIONS_SERVICE_DESCRIPTIONS_FLAGGED_FOR_USE as pwpcps
											  where pwpcps.PLAN_ID = pwp.ID
										  )
									  ) as t1
								FOR JSON PATH)
	, participantsJSON = (select participantID = pwppp.PATIENT_PERSON_ID
							   , participantAction =  pwppp.ACTION
						  from dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS as pwppp
						  where pwppp.PLAN_ID = pwp.ID
						  FOR JSON PATH)

    , planCreatorUserID = isnull(pwp.CREATED_BY, '')
	, planCreatorSigned = convert(bit, isnull(pwp.planCreatorSigned, 0))
	, planCreatorSignedDate = FORMAT (pwp.planCreatorSignedDate, 'yyyy-MM-dd')
	, planCreatorSignedName = ua.firstName + ' ' + ua.lastName
	, pwp.planCreatorSignatureImg
	, createdBy = pwp.CREATED_BY

	, planCreatorLname  = ua.lastName
	, planCreatorFname  = ua.firstName
	, planCreatorEmail  = ua.email
	, planCreatorPhone  = ua.phone

	, patName           = pp.CONCAT_NAME
	, patID             = pp.PATIENT_ID

	, recID             = pwp.ID
	, saveType		    = 2
	, hasUnsavedChanges = convert(bit, 0)

	, authReqRecID = sar.id

	from dbo.PLAN_WRITER_PLANS      as pwp
	left join dbo.PLAN_WRITER_PLANS_DIAGNOSES as pwpd on pwpd.PLAN_ID = pwp.ID
	left join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pwp.PATIENT_ID  
	left join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = pwp.PATIENT_ID  
	left join dbo.COMPANY_FISCAL_YEARS as fy on fy.ID = @fiscalYearID

	-- practitioner info (note: practitioners should only see care plans within their practice family)
	
	-- plan creator

	left join users.dbo.USERS_ALL as ua on ua.id = pwp.CREATED_BY
	left join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = ua.pracID
	left join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID and pg.GROUP_TYPE in (1,2)
	outer apply (select 
					png.GROUP_SERVICE_CLASS_NAME_ID
				 from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png 
				 where png.GROUP_ID = pg.GROUP_ID 
				   and png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
				 ) pngc

	-- caller

	left join users.dbo.USERS_ALL as uau on uau.id = @userID
	left join dbo.PRACTITIONER_Practitioner as prpu on prpu.PRACTITIONER_ID = uau.pracID
	left join dbo.PRACTITIONER_GROUPS       as pgu  on pgu.PRACTITIONER_ID  = prpu.PRACTITIONER_ID and pgu.GROUP_TYPE in (1,2)
	outer apply (select 
					png2.GROUP_SERVICE_CLASS_NAME_ID
				 from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png2 
				 where png2.GROUP_ID = pgu.GROUP_ID 				 
				 and png2.GROUP_SERVICE_CLASS_PARTITION_ID = 100
				 ) pngu

	outer apply (select top 1 
					id
				 from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar1
				 where sar1.referencedEntityID = pwp.ID and sar1.svcAuthorizationRequestTypeID = 4 -- 4 is parent auth for care plan
				 order by sar1.id desc
	) as sar

	where (
		   (1=1)      
	   and (pwp.CLIENT_ID  = @clientID)
	   and ((@patientID         is null)  or (pwp.PATIENT_ID = @patientID))
	   and ((@pracID            is null)  or (ua.pracID      = @pracID))
       and ((@siteID            is null)  or (ps.SITE_ID     = @siteID))
       and ((@fiscalYearID      is null)  or (pwp.PLAN_DATE between fy.FY_START and fy.FY_END))

	   -- for @isCreatedByCaller, @isExpiring and @isExpired,
	   -- we are ignoring the 0 case because it is not used, but if we need to filter by "not expired" for example, then the logic needs to be added
       and ((@isCreatedByCaller is null)  or (pwp.CREATED_BY = @userID))
       and ((isnull(@isExpiring, 0) = 0)  or (isnull(@isExpired, 0) != 0 -- if both @isExpiring and @isExpired are checked, exit as the edge case logic will take care of it
										  or (
											  DATEADD(m, 3, GETDATE()) > DATEADD(year, 1, pwp.PLAN_DATE) -- expiring means 3 months away from expiring
										  and GETDATE() < DATEADD(year, 1, pwp.PLAN_DATE) -- exclude expired plans
										  )
										  )
	   )
       and ((isnull(@isExpired, 0) = 0)  or (isnull(@isExpiring, 0) != 0 -- if both @isExpiring and @isExpired are checked, exit as the edge case logic will take care of it
										 or GETDATE() > DATEADD(year, 1, pwp.PLAN_DATE))
	   )
	   -- edge case where we want both expired and expiring plans
	   and ((isnull(@isExpiring, 0) = 0 or isnull(@isExpired, 0) = 0)
		 or (DATEADD(m, 3, GETDATE()) > DATEADD(year, 1, pwp.PLAN_DATE))
	   )

	   -- group filter for practitioners
	   and ((isnull(pngu.GROUP_SERVICE_CLASS_NAME_ID, 0) = 0) or (pngc.GROUP_SERVICE_CLASS_NAME_ID = pngu.GROUP_SERVICE_CLASS_NAME_ID))
	    
	   and ((@active            is null)  or (pwp.ACTIVE     = @active))
	   and ((@recID             is null)  or (pwp.ID         = @recID))
	)
)

GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE] TO [webuser]
GO