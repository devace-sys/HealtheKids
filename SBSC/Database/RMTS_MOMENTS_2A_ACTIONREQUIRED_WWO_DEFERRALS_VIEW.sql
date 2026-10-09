USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENTS_2A_ACTIONREQUIRED_WWO_DEFERRALS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_MOMENTS_2A_ACTIONREQUIRED_WWO_DEFERRALS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_MOMENTS_2A_ACTIONREQUIRED_WWO_DEFERRALS_VIEW] ( 

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

    select   *

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

       -- 
	   null  ,  --  @pcalReviewStatusCode

     null  --  @isDeferred
     --

    ) rm_v

    WHERE isActionRequired = 1

) 									      
     								       
GO									       
									       
/*-------------------------------	   		
 * User Permissions						
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_MOMENTS_2A_ACTIONREQUIRED_WWO_DEFERRALS_VIEW] TO [webuser]
GO