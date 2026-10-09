
USE SPEDMON

GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MEDI_CAL_ELIGIBILITY_DATA') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].MEDI_CAL_ELIGIBILITY_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[MEDI_CAL_ELIGIBILITY_DATA]
(@clientID      BIGINT,
 @repID         BIGINT
)
RETURNS TABLE AS RETURN (
/******************************************

	Medi_Cal eligibility data
	
	NB: In order to match between
	population files from the client
	and the DHS to/from files,
	each population file is compared 
	against the first DHS file that was
	created after the popfile upload date.

******************************************/

SELECT client_elig_rprt.*,cli.Client_ID from CLIENTS_Client cli
outer apply
(
select top 1
	cc.CLIENT_NAME, 
	pats_file.*, 
	count_DHCS.*, 
	(num_elig + num_not_elig) as elig_total_sum, 
	elig_counts.*, 
	numpats-dhcs_matched as pop_elig_difference, 
	(CONVERT(DECIMAL(12,2),numpats-DHCS_matched)/numpats)*100 as percent_not_in_pop

from CLIENTS_Client cc

/***************
Get a listing of all the population files, listing the number of unique patient IDs associated with that file.
***************/

outer apply 
	(select pf.File_ID, Upload_Date, COUNT( distinct pfp.Patient_ID) numpats
	from 
		Population_Files pf
		inner join Population_File_Patients pfp 
			on pf.File_ID = pfp.File_ID 
			and cc.CLIENT_ID = pf.Client_ID
		where pf.Is_Full_File = 1
		group by pf.File_ID, Upload_Date
	) pats_file
	
	
/*
	List the number of unique patient IDs in a population file where:
	* the patient has been in a student data file created after the population file referenced
	* the student data file the patient is in has completed/made a full trip.
*/	
outer apply
	(
		select --pfp.file_id, 
			COUNT(distinct pfp.Patient_ID) DHCS_matched
		from 
			(select distinct file_id, patient_id from Population_File_Patients) pfp
			
			cross apply
			(
				select top 1 Patient_ID from
		
				PATIENTS_StudentData_FileID psdf
				
				inner join PATIENTS_StudentData_Correlation psdc 
				on pfp.Patient_ID = psdc.PATIENT_ID 
				and psdc.FILE_ID = psdf.FILE_NUMBER_ID					
				where 				
					psdf.DATE_CREATED >=  pats_file.Upload_Date
					and psdf.NOTE = 'COMPLETED'
					and psdf.DATE_RETURNED is not null
					and psdc.PATIENT_ID = pfp.Patient_ID	
			)stu_dat_mat

		where  
			pfp.File_ID = pats_file.File_ID
	) count_DHCS



/*
	Determine eligibility counts:
	Using the normalized eligibility, sum up the number of months where each patient has a Y. If <> 0, they are E (1 or more mos of eligibility). If = 0, NE.
*/
outer apply 
(
	select SUM( case when num_elig_mons <> 0 then 1 else 0  END) as num_elig, SUM( case when num_elig_mons = 0 then 1 else 0 END) as num_not_elig
	from 
	 (select distinct patient_id,File_ID from Population_File_Patients ) pfp
			
		outer apply
		( 
			select distinct
				pen.Patient_ID,
				SUM(CASE WHEN IS_ELIG = 1 then 1 else 0 end) num_elig_mons
			from
				PATIENTS_ELIGIBILITY_NORMALIZED pen
			where 
				pfp.Patient_ID = pen.PATIENT_ID				
			group by pen.PATIENT_ID
		) elig_mon_count
	
	where 
			 pfp.File_ID = pats_file.File_ID
	
) elig_counts

where 

cli.CLIENT_ID = cc.CLIENT_ID and

(CONVERT(DECIMAL(12,2),numpats-DHCS_matched)/numpats)*100 < 2

order by CLIENT_NAME, Upload_Date desc

) client_elig_rprt

WHERE cli.CLIENT_ID                        <> 112 and 
      cli.RevenueSharingCategoryLEACurrent <> 'Never an LEA Client' and
      cli.LEA                               = 1 and
      (@clientID is null or cli.Client_ID                = @clientID) and 
      (@repID    is null    or cli.ClientRepIDLEACurrent = @repID)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[MEDI_CAL_ELIGIBILITY_DATA] TO [webuser]
GO
