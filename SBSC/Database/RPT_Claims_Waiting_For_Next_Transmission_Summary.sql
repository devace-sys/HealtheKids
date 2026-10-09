USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_Claims_Waiting_For_Next_Transmission_Summary') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_Claims_Waiting_For_Next_Transmission_Summary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_Claims_Waiting_For_Next_Transmission_Summary] ()

RETURNS TABLE
 
/***************************************************************************
 * RPT_Claims_Waiting_For_Next_Transmission_Summary */
/**
 * Returns a table of report rows
 *
 * @param   client ID             filter by Client ID to get one client or all Clients.
 * @param   repID                 filter by Practical Consultant ID to get one or all Consultants,
 * @return                        Table of report rows
 ***************************************************************************/
 
AS RETURN 
(
  select top (dbo.CONST_MAX_ROWS())
      AS_OF_DATE = convert(date,LAST_UPDATED)
    , CLIENT_NAME
	, REP_NAME
    , NUM_CLAIMS
    , TOTAL_AMT
  from
  ( 
    select 
        cch.LAST_UPDATED
	  , cch.CLIENT_ID
      , cch.CLIENT_NAME	
	  , cch.REP_ID
	  , cch.REP_NAME
	  , NUM_CLAIMS = count(CLAIM_ID)
      , TOTAL_AMT  = sum(cch.EST_AMT)      
	from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA as cch
	where cch.HOLD_CODE in (10000,10100,10200)	
    group by 
        cch.LAST_UPDATED
      , cch.CLIENT_ID
      , cch.CLIENT_NAME 
	  , cch.REP_ID
	  , cch.REP_NAME   
  ) as q1

order by 
    LAST_UPDATED
  , CLIENT_NAME
  , REP_NAME

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_Claims_Waiting_For_Next_Transmission_Summary] TO [webuser]
GO   


