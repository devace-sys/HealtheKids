USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE (
     @clientID          BIGINT
   , @oldestDOS         DATETIME
   , @today             DATETIME   
   , @useOrLose         BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE */    
 /**    
  *
  * Returns claims we can automatically resubmit
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select 
    t1.*
  from dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE (@clientID ,@oldestDOS, @today, @useOrLose) as t1
  where (
            (t1.PATIENT_POSSIBLY_LEA_BOP_ELIG = 1)           /* BIC is OK and patient is ffp qualified */
		and ( 
	  
	    /* One of these codes*/
  
        ( t1.CODE_VALUE IN (
        --'109', -- do nothing
        '119',
        '16',
        --'177', -- resubmit 30 days after DOS
        '24',
        --'31',  -- requires report out
        '4',
        '58',
        --'6',   -- requires report out
        'B7',
        'M77',
        'MA04',
        'N129',
        'N29',
        'N30',
        'N362', 
        'N406',
        'N431',
        'N463',
        'N95',
		'29' /* Time limit for filing has expired.  TODO: Remove after DHCS removes this exception */)
        ) 

      /* Patient has not met the required eligibility requirements */	
	  /* Resubmit 30 days after dos and every 30 days after until claim expires */
	  
	    OR ((t1.CODE_VALUE = '177') AND (@today >= DATEADD(DAY, 30, t1.SERVICE_DATE) ))
      
	  /* Secondary payment cannot be considered without the identity of or payment information from the primary payer. The information was either not reported or was illegible.*/
	  /* Resubmit if procedure is for IEP/IFSP */

	    OR ((t1.CODE_VALUE in ('MA04')) AND (t1.IS_IFSP_IEP = 1))
     )
  )

) 

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE] TO [webuser]
GO  
