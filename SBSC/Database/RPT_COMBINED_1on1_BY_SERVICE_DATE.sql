USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('RPT_COMBINED_1on1_BY_SERVICE_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[RPT_COMBINED_1on1_BY_SERVICE_DATE]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_COMBINED_1on1_BY_SERVICE_DATE]  
(@clientID   BIGINT,
 @pracID     BIGINT,
 @startDate  date,
 @endDate    date)    
 
 RETURNS  @patientRpt TABLE (PATIENT_NAME      nvarchar(100),   
                              PRAC_NAME         nvarchar(100),                                
			                 AMOUNT            MONEY		   
                             ) AS   
 
 /***************************************************************************    
  * RPT_COMBINED_1on1_BY_SERVICE_DATE */    
 /**    
  * Returns a table of patients claims for 1:1 Aide where service date is
  * in the given date range for the given clientID.    
  * 
  * @param  clientID        ClientID   
  * @param  startDate       Start date    
  * @param  endDate         End date  
  * @return                 Table of data 
  ***************************************************************************/              
begin

	insert into @patientRpt
		select pp.CONCAT_NAME,pr.CONCAT_NAME,		       		
		       convert(decimal(10,2),sum(ca.AMOUNT_PAID * ca.EDSPERCENT)) 
		  from CLAIM_Claim cc
		  join CLAIM_Claim_Adjudication ca  on ca.CLAIM_ID        = cc.CLAIM_ID
		  join PATIENTS_Patient pp          on pp.PATIENT_ID      = cc.PATIENT_ID
		  join PRACTITIONER_Practitioner pr on pr.PRACTITIONER_ID = cc.PRACTITIONER_ID
		 where (@pracID is null or cc.PRACTITIONER_ID = @pracID)
		       and cc.CLIENT_ID = @clientID   
		       and cc.service_date between @startDate and @endDate
		       and ca.AMOUNT_PAID <> 0
		       and cc.IS_PROXY   = 0
		 group by pp.CONCAT_NAME,pr.CONCAT_NAME
		 order by pp.CONCAT_NAME	
		 
/*-------------------------------    
 * Output summary line    
 *------------------------------*/    
      
 insert into @patientRpt    
    select 'zz-Grand Total' as PATIENT_NAME,'',SUM(AMOUNT) FROM @patientRpt 
		 	
return
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_COMBINED_1on1_BY_SERVICE_DATE] TO [webuser]
GO
