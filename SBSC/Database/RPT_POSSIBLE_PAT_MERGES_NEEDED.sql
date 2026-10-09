USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_POSSIBLE_PAT_MERGES_NEEDED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_POSSIBLE_PAT_MERGES_NEEDED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_POSSIBLE_PAT_MERGES_NEEDED](@clientID INT)    
 
RETURNS TABLE      

/***************************************************************************    
 * PRACTITIONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH */    
/**    
 * Returns a table of practitioners that currently:
 *
 * - are common between LEA and MAA
 * - are active in both programs
 * - are coded as "not MAA" in LEA
 *    
 * @param  clientID        ID of client 
 * @return                 Table of practitioner data    
 ***************************************************************************/     

AS RETURN(      


 with dup_csis_this_client as (
  SELECT
    COUNT(DISTINCT pp.PATIENT_ID) "count",
    CSIS ,
    --MAX(pp.PATIENT_ID) latest_added
    STRING_AGG( cast ( pp.PATIENT_ID as varchar), ',' ) patIDs
  FROM
  PATIENTS_Patient pp
  LEFT JOIN PATIENTS_Client pc ON pp.PATIENT_ID = pc.PATIENT_ID
                              AND @clientID IS NOT NULL  -- if null, then we don't do the join
                              
  WHERE (@clientID IS NULL OR pc.CLIENT_ID = @clientID)
  
    AND active != 'n'

    AND ISNULL(CSIS, '') != ''

  GROUP BY CSIS
  HAVING COUNT(DISTINCT pp.PATIENT_ID) > 1
),
dup_BIC_this_client as (
  SELECT
    COUNT(DISTINCT pp.PATIENT_ID) "count",
    BIC ,
    --MAX(pp.PATIENT_ID) latest_added
    STRING_AGG( cast ( pp.PATIENT_ID as varchar), ',' ) patIDs
  FROM
  PATIENTS_Patient pp
  LEFT JOIN PATIENTS_Client pc ON pp.PATIENT_ID = pc.PATIENT_ID
                              AND @clientID IS NOT NULL  -- if null, then we don't do the join

  WHERE (@clientID IS NULL OR pc.CLIENT_ID = @clientID)
  
    AND active != 'n'

    AND ISNULL(BIC, '') != ''

  GROUP BY BIC
  HAVING COUNT(DISTINCT pp.PATIENT_ID) > 1
),
dup_studName_this_client as (
  SELECT
    COUNT(DISTINCT pp.PATIENT_ID) "count" ,
    LAST_NAME, FIRST_NAME ,
    -- BIC --,
    --MAX(pp.PATIENT_ID) latest_added
    STRING_AGG( cast ( pp.PATIENT_ID as varchar), ',' ) patIDs
  FROM
  PATIENTS_Patient pp
  LEFT JOIN PATIENTS_Client pc ON pp.PATIENT_ID = pc.PATIENT_ID
                              AND @clientID IS NOT NULL  -- if null, then we don't do the join

  WHERE (@clientID IS NULL OR pc.CLIENT_ID = @clientID)
  
    AND active != 'n'

  GROUP BY LAST_NAME, FIRST_NAME
  HAVING COUNT(DISTINCT pp.PATIENT_ID) > 1
),
dup_stuId_this_client as (
  SELECT
    COUNT(DISTINCT ps.PATIENT_ID) "count" ,
    STUDENT_ID ,
    -- BIC --,
    --MAX(pp.PATIENT_ID) latest_added
    STRING_AGG( cast ( ps.PATIENT_ID as varchar(max) ), ',' ) patIDs
  FROM
  PATIENTS_School ps

  LEFT JOIN PATIENTS_Client pc ON ps.PATIENT_ID = pc.PATIENT_ID
                              AND @clientID IS NOT NULL  -- if null, then we don't do the join

  JOIN PATIENTS_Patient pp ON pp.PATIENT_ID = ps.PATIENT_ID and pp.ACTIVE != 'n'

  WHERE (@clientID IS NULL OR pc.CLIENT_ID = @clientID)
  
         AND ( ps.END_DATE IS NULL OR ps.END_DATE > GETDATE() )

         AND ISNULL(STUDENT_ID, '') != ''

  GROUP BY STUDENT_ID
  HAVING COUNT(DISTINCT ps.PATIENT_ID) > 1
),
dups_all_patids as (

  select
    'duplicate CSIS' mergeReason,
    indiv_patids.*
  FROM dup_csis_this_client dup_csis
  OUTER APPLY ( select value patID FROM OPENJSON ( '[' + dup_csis.patIDs + ']') indiv_patids ) indiv_patids

  UNION

  select
    'duplicate BIC' mergeReason,
    indiv_patids.*
  FROM dup_BIC_this_client dup_BIC
  OUTER APPLY ( select value patID FROM OPENJSON ( '[' + dup_BIC.patIDs + ']') indiv_patids ) indiv_patids

  UNION

  select
    'duplicate student name' mergeReason,
    indiv_patids.*
  FROM dup_studName_this_client dup_studName
  OUTER APPLY ( select value patID FROM OPENJSON ( '[' + dup_studName.patIDs + ']') indiv_patids ) indiv_patids

  UNION

  select
    'duplicate studentID' mergeReason,
    indiv_patids.*
  FROM dup_stuId_this_client dup_stuid
  OUTER APPLY ( select value patID FROM OPENJSON ( '[' + dup_stuid.patIDs + ']') indiv_patids ) indiv_patids

),
dups_w_reasons as (
  SELECT
    STRING_AGG( mergeReason, ', ') mergeReason,
    patID
  FROM dups_all_patids
  GROUP BY patID
)

select top (dbo.CONST_MAX_ROWS())
  cc.CLIENT_NAME, mergeReason, pp.*
from PATIENTS_Patient pp
LEFT JOIN dups_w_reasons ON pp.PATIENT_ID = dups_w_reasons.patID

JOIN PATIENTS_Client pc ON pp.PATIENT_ID = pc.PATIENT_ID
JOIN CLIENTS_Client cc  ON pc.CLIENT_ID  = cc.CLIENT_ID

WHERE dups_w_reasons.patID IS NOT NULL
      AND
      mergeReason != 'duplicate student name'

ORDER BY LAST_NAME asc, FIRST_NAME asc, PATIENT_ID desc

)

GO

/*-------------------------------
 * User Permissions
 *
 * Note: This script also 
 * requires the permissions
 * that are setup in:
 *
 * spedmon\batch\restore\
 * restore-partner-databases.sql
 *------------------------------*/
 
GRANT SELECT ON [dbo].[RPT_POSSIBLE_PAT_MERGES_NEEDED] TO [webuser]
GO



