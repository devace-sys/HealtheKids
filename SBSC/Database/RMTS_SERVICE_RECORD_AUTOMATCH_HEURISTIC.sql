
USE SPEDMON
GO
 

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC] (
    @clientID    bigint
  , @quarterID   bigint
  , @importRowID bigint
  , @userID      bigint
)

AS    
BEGIN

declare @fileContentJSON VARCHAR(max)
declare @quarterStartDate date;
declare @quarterEndDate   date;

declare @today datetime = GETDATE();

declare @RMTS_Moment_Req as table (
  [rmtsMomentDataImportID] [bigint] NOT NULL,

  "Quarter" [varchar](15),
  "LEA" [varchar](75),

  "CostPool" [varchar](75),

  "email" [nvarchar](256),

  "LastName" [varchar](75) , -- not null,
  "FirstName" [varchar](75) , -- not null,
  "JobTitle" [varchar](50)  , -- not null,
  "JobClassification" [varchar](75)  , -- not null,
  "SampledMoment" [varchar](75)  , -- not null,
  "momentDatetime" [datetime]  , -- not null,

  "MomentSubmitted" [varchar](75) null,
  "MomentSubmittedDatetime" [datetime] null,

  "ActivityCode" [varchar](10),
  "SMAACode16AuditRequired" [varchar](max),
  "LEABOPCode2AAuditRequired" [varchar](max),
  "RelatedToStudentAssessmentIEP_IFSP_CarePlan" [varchar](max),
  "WhoWereYouWith" [varchar](max),
  "WhatWereYouDoing" [varchar](max),
  "WhyWereYouPerformingThisActivity" [varchar](max),
  "ClarifyingQuestion1" [varchar](max),
  "ClarifyingQuestionAnswer1" [varchar](max),
  "ClarifyingQuestion2" [varchar](max),
  "ClarifyingQuestionAnswer2" [varchar](max),
  "CodingComments" [varchar](max),
  "pracID" bigint,
  "PracUserID" bigint,
  svcRecID bigint
  ,
  req_id bigint
  );

if (@quarterID > 0)
begin
  SELECT
    @quarterStartDate=QTR_START,
    @quarterEndDate=QTR_END
  FROM [dbo].[COMPANY_FISCAL_QUARTERS]
  WHERE ID = @quarterID

end

/*==================================================================================================================
 * Get RMTS moment data provided by LEC/LGA
 *=================================================================================================================*/

/*----------------------------------------------------------
 * Initial match attempt
 *---------------------------------------------------------*/

if (@importRowID IS NOT NULL) -- if we're processing an original import
begin

  SELECT @fileContentJSON = [fileContentJSON] FROM [dbo].[RMTS_Moments_Data_Imports] where id=@importRowID

;with 
json_relevant_cols 
as 
(
--INSERT INTO @RMTS_Moment_Req
SELECT

  @importRowID recordID, 
  @quarterID [Quarter],

  COALESCE(
   NULLIF(s1.LEA,''),
   NULLIF(s1.[AgencyName],'')
  ) LEA,

  [CostPoolName], --null,

  email = trim(isnull(s1.[email], '')),

  trim(isnull(COALESCE(
   NULLIF(s1.[Last Name],''),
   NULLIF(s1.[PersonLastName],'')
  ),'')) [Last Name],

  trim(isnull(COALESCE(
   NULLIF(s1.[First Name], ''),
    NULLIF(s1.[PersonFirstName], '')
  ),'')) [First Name],

  COALESCE(
   NULLIF(s1.[Job Title],''),
   NULLIF(s1.[PositionJobTitle],'')
  ) [Job Title],

  COALESCE(
   NULLIF(s1.[Job Classification],''),
   NULLIF(s1.[JobCategoryName],'')
  ) [Job Classification],

  COALESCE(
   NULLIF(s1.[Sampled Moment],''),
   NULLIF(s1.[Moment.DateTime],'')
  ) [Sampled Moment],

  CAST(
    COALESCE(
     NULLIF(s1.[Sampled Moment],''),
     NULLIF(s1.[Moment.DateTime],'')
    )
    as datetime) [MomentDateTime],

  null n1,
  null n2,

  COALESCE(
   NULLIF(s1.[Activity Code],''),
   NULLIF(
     SUBSTRING(s1.[CodeTypeName],  1, CHARINDEX('.',s1.[CodeTypeName]) - 1)
     ,''
   )
  ) [Activity Code],

  s1.[SMAA - Code 16 Audit Required],
  s1.[LEABOP - Code 2A Audit Required],

  s1.[Related to Student Assessment/IEP/IFSP/Care Plan],


  COALESCE(
   NULLIF(s1.[Who were you with],''),
   NULLIF(s1.[MomentQuestions Who were you with?],'')
  ) [Who were you with],

  COALESCE(
   NULLIF(s1.[What were you doing],''),
   NULLIF(s1.[MomentQuestions What were you doing?],'')
  ) [What were you doing],

  COALESCE(
   NULLIF(s1.[Why were you performing this activity],''),
   NULLIF(s1.[MomentQuestions Why were you performing this activity?],'')
  ) [Why were you performing this activity],

  COALESCE(
   NULLIF(s1."ClarifyingQuestion1",''),
   NULLIF(s1."ParticipantInteractions QCComment_1",'')
  ) "ClarifyingQuestion1",

  COALESCE(
   NULLIF(s1."ClarifyingQuestionAnswer1", ''),
   NULLIF(s1."ParticipantInteractions.ParticipantFollowUpAnswer_1", '')
  ) "ClarifyingQuestionAnswer1",


  COALESCE(
   NULLIF(s1."ClarifyingQuestion2",''),
   NULLIF(s1."ParticipantInteractions QCComment_2",'')
  ) "ClarifyingQuestion2",

  COALESCE(
   NULLIF(s1."ClarifyingQuestionAnswer2", ''),
   NULLIF(s1."ParticipantInteractions.ParticipantFollowUpAnswer_2", '')
  ) "ClarifyingQuestionAnswer2",


  s1."CodingComments" ,

  null n3, --prac1.id,
  null n4, --prac1.UserIdInt
  null n5,

  null n6

FROM OpenJson(@fileContentJSON)
WITH (
			  [rowDataBad]				bit			'$."rowBad"',
			  [optionalRowDataBad]		bit			'$."optionalRowDataBad"',
              [CostPoolName]  [varchar](50)         '$."rowData"."CostPool.Name"',

              --[Quarter]    [varchar](15)        '$.Quarter', -- quarterID is already passed in

              LEA          [varchar](75  )      '$."rowData".LEA',
              [AgencyName]  [varchar](75)         '$."rowData"."Agency.Name"',

              [email]  [varchar](256)            '$."rowData"."email"',


              [Last Name]  [varchar](75)        '$."rowData"."Last Name"',
              [PersonLastName]  [varchar](75)         '$."rowData"."Person.LastName"',

              [First Name] [varchar](75)         '$."rowData"."First Name"',
              [PersonFirstName]  [varchar](75)   '$."rowData"."Person.FirstName"',

              [Job Title]  [varchar](50)         '$."rowData"."Job Title"',
              [PositionJobTitle]  [varchar](50)         '$."rowData"."JobPosition.JobTitle"',

              [Job Classification] [varchar](75)      '$."rowData"."Job Classification"',
              [JobCategoryName] [varchar](75)         '$."rowData"."JobCategory.Name"',
                 
              [Sampled Moment] [varchar](75)          '$."rowData"."Sampled Moment"',
              [Moment.DateTime]  [varchar](75)        '$."rowData"."Moment.DateTime"',  -- parse string for SQL datetime
                 
              [Activity Code] [varchar](10)           '$."rowData"."Activity Code"',
              [CodeTypeName] [varchar](10)           '$."rowData"."CodeType.Name"',   -- parse string for code

              [SMAA - Code 16 Audit Required]   [varchar](max)        '$."rowData"."SMAA - Code 16 Audit Required"',
              [LEABOP - Code 2A Audit Required] [varchar](max) '$."rowData"."LEABOP - Code 2A Audit Required"',
              [Related to Student Assessment/IEP/IFSP/Care Plan] [varchar](max)  '$."rowData"."Related to Student Assessment/IEP/IFSP/Care Plan?"',

              [Who were you with] [varchar](max)                                 '$."rowData"."Who were you with?"',
              [MomentQuestions Who were you with?] [varchar](max)                '$."rowData"."MomentQuestions.Who were you with?"',
                
              [What were you doing] [varchar](max)                             '$."rowData"."What were you doing?"',
              [MomentQuestions What were you doing?] [varchar](max)                             '$."rowData"."MomentQuestions.What were you doing?"',


              [Why were you performing this activity]   [varchar](max)         '$."rowData"."Why were you performing this activity?"',
              [MomentQuestions Why were you performing this activity?]   [varchar](max)         '$."rowData"."MomentQuestions.Why were you performing this activity?"',


              "ClarifyingQuestion1"  [varchar](max)       '$."rowData"."Participant Clarifying Question 1"',
              "ParticipantInteractions QCComment_1"  [varchar](max)       '$."rowData"."ParticipantInteractions.QCComment_1"',


              "ClarifyingQuestionAnswer1"  [varchar](max)                                '$."rowData"."Participant Clarifying Answer 1"',
              "ParticipantInteractions.ParticipantFollowUpAnswer_1"  [varchar](max)      '$."rowData"."ParticipantInteractions.ParticipantFollowUpAnswer_1"',

              "ClarifyingQuestion2"  [varchar](max)       '$."rowData"."Participant Clarifying Question 2"',
              "ParticipantInteractions QCComment_2"  [varchar](max)       '$."rowData"."ParticipantInteractions.QCComment_2"',

              "ClarifyingQuestionAnswer2"  [varchar](max)       '$."rowData"."Participant Clarifying Answer 2"',
              "ParticipantInteractions.ParticipantFollowUpAnswer_2"  [varchar](max)      '$."rowData"."ParticipantInteractions.ParticipantFollowUpAnswer_2"',

              "CodingComments"  [varchar](max)       '$."rowData"."Coding Comments"'
) s1
)		  
INSERT INTO @RMTS_Moment_Req
SELECT * FROM json_relevant_cols


WHERE (@quarterStartDate <= CAST( [MomentDateTime] as date) AND @quarterEndDate >= CAST( [MomentDateTime] as date) )

AND ( CAST( [MomentDateTime] as date) >= '2019-07-01' )

AND (
	(email != '')
	OR
	(
	      ([Last Name] != '')
	  AND ([First Name] != '')
	)
)

AND (CONVERT(time(0), [Sampled Moment]) > CONVERT(time(0), '00:00'))
AND (isnull([CostPoolName], '') = '' or [CostPoolName] like '%direct%' or [CostPoolName] like '%cost pool 1%')
 
end

/*----------------------------------------------------------
 * Subsequent attempt to match data
 *---------------------------------------------------------*/

else

begin

INSERT INTO @RMTS_Moment_Req
SELECT

 [rmtsMomentDataImportID],

  "Quarter",
  "LEA",

  "CostPool",

  email     = trim(isnull(email,'')),
  LastName  = trim(isnull(LastName,'')),
  FirstName = trim(isnull(FirstName,'')),
  "JobTitle",
  "JobClassification",
  "SampledMoment",
  "momentDatetime",

  "MomentSubmitted",
  "MomentSubmittedDatetime",

  "ActivityCode",
  "SMAACode16AuditRequired",
  "LEABOPCode2AAuditRequired",
  "RelatedToStudentAssessmentIEP_IFSP_CarePlan",
  "WhoWereYouWith",
  "WhatWereYouDoing",
  "WhyWereYouPerformingThisActivity",
  "ClarifyingQuestion1",
  "ClarifyingQuestionAnswer1",
  "ClarifyingQuestion2",
  "ClarifyingQuestionAnswer2",
  "CodingComments",
  "pracID",
  "PracUserID",
  svcRecID

  ,
  rmr.id
 
from [dbo].[RMTS_Moments_Data_Imports] as rrjd

join dbo.RMTS_Moments as rmr on ((rmr.[rmtsMomentDataImportID] = rrjd.id)
                                and (convert (date,rmr.[momentDatetime]) between @quarterStartDate and @quarterEndDate) 

                                and (rmr.svcRecID is null and rmr.isComplete = 0) /* Ignore records already matched */

								)								
where 
       (1=1)
   and ((@clientID is null) or (rrjd.clientID = @clientID))

end /* RMTS moment data */

/*==================================================================================================================
 * Attempt to match practitioners
 *=================================================================================================================*/

;with dist_prac 
as
(
  select distinct
       LastName  
     , FirstName 
	 , email     
  FROM @RMTS_Moment_Req as t1
 )
,
prac_info 
as 
(
   SELECT /* prac_info.* */ 
     d_p.*
   , pcp.id
   , pcp.userIDInt 
 from dist_prac as d_p
 CROSS APPLY (
     
     select top 1 

	     p_p.PRACTITIONER_ID as id
	   , p_p.UserID          as userIDInt 

     FROM dbo.PRACTITIONER_Client       as p_c
     JOIN dbo.PRACTITIONER_Practitioner as p_p on (p_p.[PRACTITIONER_ID] = p_c.[PRACTITIONER_ID]
                                               and (
											        /* Match last and first name */											      
												    ((p_p.[LAST_NAME] = d_p.[LastName]) AND (p_p.[FIRST_NAME] = d_p.[FirstName]))
												    /* or email */
												 or ((trim(isnull(p_p.[EMAIL],'')) != '') and (p_p.[EMAIL] = d_p.[email]))
											   ))
	 	    
     /* Limit to just this clients active practitioners */

	 where (
	       (p_c.CLIENT_ID = @clientID)
	   and (p_p.ACTIVE = 1)
	 )
	 
	 /* We want the most recent practitioner record created that matches our crit*/

	 order by 
	   p_p.PRACTITIONER_ID desc
   
  ) as pcp
)
UPDATE tRR
SET 
      pracID =  p_i.id
    , PracUserID = p_i.userIDInt
FROM @RMTS_Moment_Req tRR
JOIN prac_info p_i ON (    ((p_i.LastName  = tRR.LastName) AND (p_i.FirstName = tRR.FirstName))
	                    OR ((tRR.email != '') AND p_i.email      = tRR.email))

/*==================================================================================================================
 * Attempt to match service records
 *=================================================================================================================*/

UPDATE req
  SET
    svcRecID = sr.id
  from 
  @RMTS_Moment_Req as req
  join dbo.SERVICE_RECORDS as sr on ( 
          sr.clientID = @clientID
      and sr.pracID   = req.pracID
      and sr.patID is not null
      and sr.dos = convert(date,req.momentDatetime)
      and (    (sr.startTime is not null)
           and ( convert(time(0),req.momentDatetime) between sr.startTime and convert(time(0),DATEADD(minute,sr.numMins,sr.startTime)))
        )
     and sr.state not in (99,199)
   --and sr.svcType  = 5
   --and  sr.svcSubType1 = 5001
   )

  --join dbo.COMPANY_FISCAL_QUARTERS         as fq  on sr.dos between fq.QTR_START and fq.QTR_END
  --  AND  fq.ID = @quarterID

 where (1=1)

/*==================================================================================================================
 * If this is a new import of RMTS data from LEC/LGA save the data for later use
 *=================================================================================================================*/

	       
 if (@importRowID IS NOT NULL)  -- if we are doing an import
 begin

  UPDATE rmr_existing -- [dbo].[RMTS_Moments](
  SET

  "rmtsMomentDataImportID"= rmr_new."rmtsMomentDataImportID"  ,
  "Quarter"= rmr_new."Quarter"  ,
  "LEA"= rmr_new."LEA"  ,

  "CostPool"= rmr_new."CostPool"  ,

  "email"= rmr_new."email",

  "LastName"= rmr_new."LastName"  ,
  "FirstName"= rmr_new."FirstName"  ,
  "JobTitle"= rmr_new."JobTitle"  ,
  "JobClassification"= rmr_new."JobClassification"  ,
  "SampledMoment"= rmr_new."SampledMoment"  ,
  "momentDatetime"= rmr_new."momentDatetime"  ,

  "MomentSubmitted"= rmr_new."MomentSubmitted"  ,
  "MomentSubmittedDatetime"= rmr_new."MomentSubmittedDatetime"  ,

  "momentDate" = CAST( rmr_new."SampledMoment" AS date ),
  "momentTime" = CAST( rmr_new."SampledMoment" AS time ),

  "ActivityCode"= rmr_new."ActivityCode"  ,
  "SMAACode16AuditRequired"= rmr_new."SMAACode16AuditRequired"  ,
  "LEABOPCode2AAuditRequired"= rmr_new."LEABOPCode2AAuditRequired"  ,
  "RelatedToStudentAssessmentIEP_IFSP_CarePlan"= rmr_new."RelatedToStudentAssessmentIEP_IFSP_CarePlan"  ,
  "WhoWereYouWith"= rmr_new."WhoWereYouWith"  ,
  "WhatWereYouDoing"= rmr_new."WhatWereYouDoing"  ,
  "WhyWereYouPerformingThisActivity"= rmr_new."WhyWereYouPerformingThisActivity"  ,

  "ClarifyingQuestion1"= rmr_new."ClarifyingQuestion1"  ,
  "ClarifyingQuestionAnswer1"= rmr_new."ClarifyingQuestionAnswer1"  ,
  "ClarifyingQuestion2"= rmr_new."ClarifyingQuestion2"  ,
  "ClarifyingQuestionAnswer2"= rmr_new."ClarifyingQuestionAnswer2"  ,
  "CodingComments"= rmr_new."CodingComments"  ,

    [svcRecID] = CASE WHEN rmr_existing.svcRecID IS NULL THEN rmr_new.svcRecID ELSE rmr_existing.svcRecID END,
    [svcrecIsAutoMatched] = case when rmr_new.[svcRecID] IS NOT NULL then 1 else 0 end ,
    pracID = rmr_new.pracID ,
    PracUserID = rmr_new.PracUserID ,

    --rmtsReqState = CASE WHEN rmr_new.svcRecID IS NULL THEN 0 ELSE 1 END,
    --rmtsReqNextStep = CASE WHEN rmr_new.svcRecID IS NULL THEN 1 ELSE 0 END,

    --mustCorrectThisMistake = CASE WHEN rmr_new.svcRecID IS NULL THEN rmr_existing.mustCorrectThisMistake ELSE 0 END,

    isComplete = CASE WHEN rmr_existing.isComplete = 1 THEN 1 ELSE
                   CASE WHEN rmr_new.svcRecID IS NOT NULL AND rmr_existing.mustCorrectThisMistake = 0 THEN 1 ELSE 0 END
                 END

  FROM [dbo].[RMTS_Moments] rmr_existing
  JOIN @RMTS_Moment_Req rmr_new
  ON
       rmr_new.svcRecID = rmr_existing.svcRecID

       OR

       (
         rmr_new.momentDatetime = rmr_existing.momentDatetime
         AND
         rmr_new.pracID = rmr_existing.pracID

         AND ( rmr_existing.svcRecID IS NULL OR rmr_existing.mustCorrectThisMistake = 1 )

       )

       OR

       (
         rmr_new.momentDatetime = rmr_existing.momentDatetime
         AND
		 (
			 (
				 rmr_new.email = rmr_existing.email
			 )
			 OR 
			 (
				 rmr_new.LastName = rmr_existing.LastName
				 AND
				 rmr_new.FirstName = rmr_existing.FirstName
			 )
		 )

         AND ( ISNULL(rmr_existing.isComplete, 0) = 0 OR rmr_existing.mustCorrectThisMistake = 1 )

         

       )

  INSERT INTO [dbo].[RMTS_Moments](
  "rmtsMomentDataImportID",
  "Quarter",
  "LEA",

  "CostPool",

  "email",

  "LastName",
  "FirstName",
  "JobTitle",
  "JobClassification",
  "SampledMoment",
  "momentDatetime",

  "MomentSubmitted",
  "MomentSubmittedDatetime",

  "momentDate",
  "momentTime",

  "ActivityCode",
  "SMAACode16AuditRequired",
  "LEABOPCode2AAuditRequired",
  "RelatedToStudentAssessmentIEP_IFSP_CarePlan",
  "WhoWereYouWith",
  "WhatWereYouDoing",
  "WhyWereYouPerformingThisActivity",

  "ClarifyingQuestion1",
  "ClarifyingQuestionAnswer1",
  "ClarifyingQuestion2",
  "ClarifyingQuestionAnswer2",
  "CodingComments",
  "pracID",
  "PracUserID",
  svcRecID,

  svcrecIsAutoMatched,
  isComplete,

  rmtsReqState,
  rmtsReqNextStep,

  clientID,
  quarterID,

  [matched],
  matchedOn,
  matchedBy, --  (userID here.... 0 is System/Automatch)
  matchedToWhat, -- ( 1= sevice revord, 2= documentation file upload)

  created,
  createdBy,
  lastModified,
  lastModifiedBy,
  active

)

select
  rmr_new.[rmtsMomentDataImportID],

  rmr_new."Quarter",
  rmr_new."LEA",

  rmr_new."CostPool",

  rmr_new."email",

  rmr_new."LastName",
  rmr_new."FirstName",
  rmr_new."JobTitle",
  rmr_new."JobClassification",
  rmr_new."SampledMoment",
  rmr_new."momentDatetime",

  rmr_new."MomentSubmitted",
  rmr_new."MomentSubmittedDatetime",

  CONVERT( date, rmr_new."SampledMoment" ),
  CONVERT( time(0), rmr_new."SampledMoment" ),

  rmr_new."ActivityCode",
  rmr_new."SMAACode16AuditRequired",
  rmr_new."LEABOPCode2AAuditRequired",
  rmr_new."RelatedToStudentAssessmentIEP_IFSP_CarePlan",
  rmr_new."WhoWereYouWith",
  rmr_new."WhatWereYouDoing",
  rmr_new."WhyWereYouPerformingThisActivity",
  rmr_new."ClarifyingQuestion1",
  rmr_new."ClarifyingQuestionAnswer1",
  rmr_new."ClarifyingQuestion2",
  rmr_new."ClarifyingQuestionAnswer2",
  rmr_new."CodingComments",
  rmr_new."pracID",
  rmr_new."PracUserID",
  rmr_new.svcRecID,

  CASE WHEN rmr_new.svcRecID IS NULL THEN 0 ELSE 1 END,
  CASE WHEN rmr_new.svcRecID IS NULL THEN 0 ELSE 1 END,

  CASE WHEN rmr_new.svcRecID IS NULL THEN 0 ELSE 1 END,
  CASE WHEN rmr_new.svcRecID IS NULL THEN 1 ELSE 0 END,

  @clientID,
  @quarterID,

  CASE WHEN rmr_new.svcRecID IS NULL THEN 0 ELSE 1 END,
  CASE WHEN rmr_new.svcRecID IS NULL THEN NULL ELSE @today END,
  CASE WHEN rmr_new.svcRecID IS NULL THEN NULL ELSE @userID END,
  CASE WHEN rmr_new.svcRecID IS NULL THEN NULL ELSE 1 END,

  @today,
  @userID,
  null,
  null,
  1

  from @RMTS_Moment_Req rmr_new
  LEFT JOIN [RMTS_Moments] rmr_existing

    ON (
	       rmr_new.svcRecID = rmr_existing.svcRecID

	       OR

	       (
	         rmr_new.momentDatetime = rmr_existing.momentDatetime
	         AND
	         rmr_new.pracID = rmr_existing.pracID
	       )

	       OR

	       (
	         rmr_new.momentDatetime = rmr_existing.momentDatetime
	         AND
			 (
				 (
					 rmr_new.email = rmr_existing.email
				 )
				 OR 
				 (
					 rmr_new.LastName = rmr_existing.LastName
					 AND
					 rmr_new.FirstName = rmr_existing.FirstName
				 )
			 )
	       )
        )
        AND  @clientID = rmr_existing.clientID

        AND rmr_existing.deferralDate IS NULL
        
  WHERE rmr_existing.id IS NULL

end
-------
 else -- automatching already-imported, existing rmts moment reqs to service records
-------

  UPDATE r_m_r -- [dbo].[RMTS_Moments](

	SET
    [svcRecID] = tmp.svcRecID ,
    [svcrecIsAutoMatched] = case when tmp.[svcRecID] IS NOT NULL then 1 else 0 end,
    pracID = tmp.pracID,
    PracUserID = tmp.PracUserID,

    rmtsReqState = CASE WHEN tmp.svcRecID IS NULL THEN 0 ELSE 1 END,
    rmtsReqNextStep = CASE WHEN tmp.svcRecID IS NULL THEN 1 ELSE 0 END,

    mustCorrectThisMistake = CASE WHEN tmp.svcRecID IS NULL THEN r_m_r.mustCorrectThisMistake ELSE 0 END,

    isComplete = CASE WHEN tmp.svcRecID IS NULL THEN r_m_r.isComplete ELSE 1 END

  FROM [dbo].[RMTS_Moments] r_m_r
  JOIN @RMTS_Moment_Req tmp ON tmp.req_id = r_m_r.ID AND tmp.pracID IS NOT NULL


UPDATE rmdi
  SET matchingToSvcRecsComplete = 1

FROM  [RMTS_Moments_Data_Imports] rmdi
JOIN  @RMTS_Moment_Req tmp
      ON tmp.rmtsMomentDataImportID = rmdi.ID

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON dbo.RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC TO [webuser]
GO
