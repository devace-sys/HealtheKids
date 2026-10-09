USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED] ( 

  @userID bigint,
  @userGroup int,
  @userRank int,

  @recid int,  -- NOT USED

  @environmentID int,

   @fyquarterid   BIGINT,


   @fyID        int,
   @quarterNum   int,


   @clientID     bigint

)
     
RETURNS TABLE  

AS RETURN(

  with q_ints as (

    select

      CAST( isActionRequired          as int     ) isActionRequired ,
      CAST( uploadedDocumentationOnly as int     ) uploadedDocumentationOnly ,

      CAST( actionRequiredUnmatched      as int     ) isUnmatchedActionRequired ,
      CAST( actionRequiredNoDocs         as int     ) noDocsActionRequired ,

      CAST( isAwaitingCoord                as int   ) isAwaitingCoord ,

      CAST( isDeferred                     as int   ) isDeferred  

    from  [dbo].[RPT_RMTS_MOMENTS_VIEW]
    ( 

	  null, null, null ,
	
	  null  ,  -- @recid 
	
	  @environmentID ,
	
	   @fyquarterid  ,
	
	
	   @fyID        ,
	   @quarterNum  ,
	
	   '2A'         ,
	   null  ,  -- @matched  
 
	   @clientID ,

     --
     null , -- @pracID
     --

	   null  ,   --  @isComplete   
	   null  ,  --  @pcalReviewStatusCode

     null  --  @isDeferred

    ) rm_v


  ),
  q_sums as (

    SELECT

      SUM( isActionRequired             ) numActionRequired ,
      SUM( uploadedDocumentationOnly    ) numUploadedDocumentationOnly ,

      SUM( isUnmatchedActionRequired       ) numUnmatchedActionRequired ,
      SUM( noDocsActionRequired            ) numNoDocsActionRequired    ,

      SUM( isAwaitingCoord                 ) numAwaitingCoord           ,

      SUM( isDeferred                 ) numDeferred                     

      -- c2                                numParticipantsWoSvcrecs

    FROM   q_ints
 )
 SELECT * from
    q_sums
    OUTER APPLY --  q_sums is a one-line result set; OUTER APPLY runs once.  A JOIN subquery or CTE would also work

    (
      SELECT COUNT(*) numParticipantsWoSvcrecs FROM
        [dbo].[RMTS_PARTICIPANTS_WO_SVCRECS_VIEW] ( 
	   @userID              
	 , @userGroup           
	 , @userRank         
	 , @clientID
         , 0  --  @isDeferred
        ) c2
    ) c2

    OUTER APPLY --  q_sums x 1 line is a one-line result set; OUTER APPLY runs once.  A JOIN subquery or CTE would also work

    (
      SELECT COUNT(*) numPossibleAppeals
      from  [dbo].[RPT_RMTS_MOMENTS_VIEW]
      ( 

	  null, null, null ,
	
	  null  ,  -- @recid 
	
	  null , --@environmentID 
	
	   @fyquarterid  ,
	
	
	   @fyID        ,
	   @quarterNum  ,
	
	   null , -- possible codes: '2A', etc
	   null  ,  -- @matched  
 
	   @clientID ,

     --
     null , -- @pracID
     --

	   null  ,   --  @isComplete   
	   300 ,  --  @pcalReviewStatusCode  -- POSSIBLE APPEAL

     0  --  @isDeferred

      )   c3

    ) c3

    OUTER APPLY --  one-line result set ...

    (
      SELECT COUNT(*) numAwaitingCodeReview
      from  [dbo].[RPT_RMTS_MOMENTS_VIEW]
      ( 

	  null, null, null ,
	
	  null  ,  -- @recid 
	
	  null , --@environmentID 
	
	   @fyquarterid  ,
	
	
	   @fyID        ,
	   @quarterNum  ,
	
	   null , -- possible codes: '2A', etc
	   null  ,  -- @matched  
 
	   @clientID ,

     --
     null , -- @pracID
     --

	   null  ,   --  @isComplete   
	   100 ,  --  @pcalReviewStatusCode  -- AWAITING CODE REVIEW

     0  --  @isDeferred

      )   c4

    ) c4


) 									      
     								       
GO									       
									       
/*-------------------------------	   		
 * User Permissions						
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED] TO [webuser]
GO