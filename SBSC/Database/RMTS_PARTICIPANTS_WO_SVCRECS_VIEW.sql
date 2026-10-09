USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_WO_SVCRECS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_PARTICIPANTS_WO_SVCRECS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_WO_SVCRECS_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @clientID          BigInt  
   , @filterfordeferred  BIT
)
     
RETURNS TABLE  

AS RETURN(

 with all_rosters_all_fys_this_client as (
   SELECT
     rpr.*, cfq.QTR quarterNum, cfq.FY_ID
	FROM  RMTS_PARTICIPATION_ROSTER rpr
	JOIN  COMPANY_FISCAL_QUARTERS   cfq  ON cfq.ID = rpr.quarterID
	WHERE rpr.clientID = @clientID
 ),
 all_fqIDs_and_rostersIDs_these_FYs_this_client as (
    SELECT
	  FY_ID,
	  '{' +
	    STRING_AGG( 
	          '"q_' + CAST( quarterNum as varchar) + '" :{' +
		                                                '"rosterID":' + CAST( id as varchar) + ',' +
		                                                '"quarterID":' + CAST( quarterID as varchar) + '}' 
	    , ', ' ) +
	   '}' j_
    FROM  all_rosters_all_fys_this_client
	GROUP BY  FY_ID
	  -- output 1 row per FY, with the Q1, Q2, Q3, Q4 roster numbers included within each row.
	  -- i feel like there's probably a way to do this with PIVOT() but i'm very fuzzy on the syntax
 ),

 sums_lt3_per_prac_per_fy  as (

	select 

	  FY_ID  ,
	  o1.pracID , 
	  SUM( svcRecCountTop3 ) sumRecCountTop3 ,
	  j_ 
	  FROM  all_fqIDs_and_rostersIDs_these_FYs_this_client f_j
	  OUTER APPLY (
		  SELECT pracID, ISNULL( svcRecCountTop3, 0)  svcRecCountTop3
					   FROM dbo.RMTS_PARTICIPANTS_VIEW_CORE(
							   @clientID,
							   JSON_VALUE(
									j_,
									'$."q_1"."rosterID"') ,
							   1,
							   null) rvc1

								 where  (

      
										( deferralDate IS NULL AND @filterfordeferred = 0)
										OR
										( deferralDate IS NOT NULL AND @filterfordeferred = 1)
      
								  )

		  UNION ALL 
		  SELECT pracID, ISNULL( svcRecCountTop3, 0)  svcRecCountTop3
					   FROM dbo.RMTS_PARTICIPANTS_VIEW_CORE(
							   @clientID,
							   JSON_VALUE(
									j_,
									'$."q_2"."rosterID"') ,
							   1,
							   null) rvc2

							   where  (

      
										( deferralDate IS NULL AND @filterfordeferred = 0)
										OR
										( deferralDate IS NOT NULL AND @filterfordeferred = 1)
      
								  )

		  UNION ALL 
		  SELECT pracID, ISNULL( svcRecCountTop3, 0)  svcRecCountTop3
					   FROM dbo.RMTS_PARTICIPANTS_VIEW_CORE(
							   @clientID,
							   JSON_VALUE(
									j_,
									'$."q_3"."rosterID"') ,
							   1,
							   null) rvc3

							   where  (

      
										( deferralDate IS NULL AND @filterfordeferred = 0)
										OR
										( deferralDate IS NOT NULL AND @filterfordeferred = 1)
      
								  )

		  UNION ALL 
		  SELECT pracID, ISNULL( svcRecCountTop3, 0)  svcRecCountTop3
					   FROM dbo.RMTS_PARTICIPANTS_VIEW_CORE(
							   @clientID,
							   JSON_VALUE(
									j_,
									'$."q_4"."rosterID"') ,
							   1,
							   null) rvc4

							   where  (

      
										( deferralDate IS NULL AND @filterfordeferred = 0)
										OR
										( deferralDate IS NOT NULL AND @filterfordeferred = 1)
      
								  )

	  ) o1 
	  -- from dbo.RMTS_PARTICIPANTS_VIEW_CORE(@clientID, null, 1, null) rvc





	  GROUP BY  FY_ID, pracID, j_
	  HAVING   SUM( svcRecCountTop3 ) < 3
   )

   SELECT
      o01.* ,
	  o01.id         rp_id   ,
	  pp.UserID      pracUid ,

	ua1.userName lastModifiedByStr ,
    ua2.userName deferredByStr     ,

    deferralDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD     ( deferralDate  )   ,
    deferralDateStr      = dbo.RPT_DATE_FMT	           ( deferralDate  )       ,



	JSON_VALUE(
									sums_.j_,
									'$."q_1"."rosterID"')   q1_rosterID        ,

	JSON_VALUE(
									sums_.j_,
									'$."q_1"."quarterID"')   q1_quarterID        ,

    cfy.FY_DEFINITION               ,

    sumRecCountTop3    numSvcsLt3

   FROM  sums_lt3_per_prac_per_fy sums_
   OUTER APPLY (
       SELECT *
       FROM dbo.RMTS_PARTICIPANTS_VIEW_CORE(
							   @clientID,
							   JSON_VALUE(
									sums_.j_,
									'$."q_1"."rosterID"') ,
							   1,
							   null) rvc1

								 where  (

							            rvc1.pracID  =  sums_.pracID

										AND
      
										( deferralDate IS NULL AND @filterfordeferred = 0)
										OR
										( deferralDate IS NOT NULL AND @filterfordeferred = 1)
      
								  )

   )  o01

   LEFT JOIN  dbo.COMPANY_FISCAL_YEARS cfy ON o01.FY_ID = cfy.ID 

   LEFT JOIN [users].dbo.users as ua1 ON o01.lastModifiedBy = ua1.userrid
   LEFT JOIN [users].dbo.users as ua2 ON o01.deferredBy     = ua2.userrid

   JOIN dbo.PRACTITIONER_Practitioner pp ON o01.pracID = pp.PRACTITIONER_ID
) 									      
     								       
GO									       
									       
/*-------------------------------	   		
 * User Permissions						
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_WO_SVCRECS_VIEW] TO [webuser]
GO