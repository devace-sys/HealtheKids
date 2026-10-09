USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PAT_LIST_EXPORT_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PAT_LIST_EXPORT_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_PAT_LIST_EXPORT_RPT] (
  @clientID  BIGINT
)

RETURNS TABLE

/***************************************************************************    
 * CYBHI_PAT_LIST_EXPORT_RPT */    
/**    
 * Returns all of the columns that the TPA requires BUT only includes rows 
 * for patients that have both C (critical) and R (required) fields completed.
 * Please note that ALL columns are returned including the columns that the LEA
 * is not responsible for completing.  
 *
 * This routine also 
 *
 * - handles the record number (with leading 0s) requirement
 * - removes patients that do not require TPA registration
 *   because of agreements with TPA and patients insurance carrier.
 *   (Note: we include the patients in the core routine for audit purposes)
 *
 ***************************************************************************/            

AS RETURN (

select
	 [Record Number]                                   = dbo.RPT_PAD_LEFT(convert(varchar(50), ROW_NUMBER() OVER (order by t1.[Record Number])), 7, N'0')
	,[Carelon PARENT Code]                             = t1.[Carelon PARENT Code]
	,[Submitter ID]                                    = t1.[Submitter ID]
	,[Registering Provider ID]                         = t1.[Registering Provider ID]
	,[Enrollment Indicator]                            = t1.[Enrollment Indicator]
	,[Enrollment Start Date]                           = t1.[Enrollment Start Date]
	,[Enrollment Termination Date]                     = t1.[Enrollment End Date]
	,[Carelon Assigned Member ID]                      = t1.[Carelon Assigned Member ID]
	,[Student ID]                                      = t1.[Student ID]
	,[Medicaid ID]                                     = ''
	,[Medicare ID]                                     = ''
	,[Social Security Number Indicator]                = ''
	,[Social Security Number]                          = ''
	,[Alien Registration ID]                           = ''
	,[VISA ID]                                         = ''
	,[Last Name]                                       = t1.[Last Name]
	,[Birth Surname]                                   = ''
	,[First Name]                                      = t1.[First Name]
	,[Middle Initial]                                  = ''
	,[Name Suffix]                                     = ''
	,[Preferred First Name]                            = ''
	,[Pronouns]                                        = ''
	,[Pronouns Other]                                  = ''
	,[Birth Date]                                      = t1.[Birth Date]
	,[Unknown Address]                                 = t1.[Unknown Address]
	,[Member is Homeless]                              = t1.[Member is Homeless]
	,[Street Address Line 1]                           = t1.[Street Address Line 1]
	,[Street Address Line 2]                           = ''
	,[City]                                            = t1.[City]
	,[State]                                           = t1.[State]
	,[Zip Code]                                        = t1.[Zip Code]
	,[Zip Code Extension]                              = ''
	,[Members County]                                  = ''
	,[Individual Email Address]                        = ''
	,[No Phone]                                        = t1.[No Phone]
	,[Home Phone Area Code]                            = t1.[Home Phone Area Code]
	,[Home Phone Exchange Number]                      = t1.[Home Phone Exchange Number]
	,[Home Phone Suffix]                               = t1.[Home Phone Suffix]
	,[Cell Phone Area Code]                            = ''
	,[Cell Phone Exchange Number]                      = ''
	,[Cell Phone Suffix]                               = ''
	,[Verbal Preference]                               = ''
	,[Interpreter Services Needed]                     = ''
	,[Speaking Language]                               = ''
	,[Speaking Language Other]                         = ''
	,[Written Language]                                = ''
	,[Written Language Other]                          = ''
	,[Gender At Birth]                                 = t1.[Gender At Birth]
	,[Gender Identity]                                 = ''
	,[Gender Identity Other]                           = ''
	,[Race Code 1]                                     = ''
	,[Race Code 2]                                     = ''
	,[Race Code 3]                                     = ''
	,[Race Code Other]                                 = ''
	,[Hispanic Or Latino Origin]                         = ''
	,[Marital Status]                                  = ''
	,[Sexual Orientation Status]                       = ''
	,[Sexual Orientation Status Other]                 = ''
	,[Housing Status]                                  = ''
	,[Disability Status 1]                             = ''
	,[Disability Status 2]                             = ''
	,[Disability Status 3]                             = ''
	,[Disability Status Other]                         = ''
	,[Filler Field 1]                                  = ''
	,[Filler Field 2]                                  = ''
	,[Filler Field 3]                                  = ''
	,[Filler Field 4]                                  = ''
	,[Insurance Carrier Code 1]                        = t1.[Insurance Carrier Code 1]
	,[Filler Field 5]                                  = ''
	,[Insurance Policy Member ID 1]                    = t1.[Insurance Policy Member ID 1]
	,[Insurance Subscriber First Name 1]               = t1.[Insurance Subscriber First Name 1]
	,[Insurance Subscriber Last Name 1]                = t1.[Insurance Subscriber Last Name 1]
	,[Insurance Primacy Indicator 1]                   = t1.[Insurance Primacy Indicator 1]
	,[Insurance Group Number 1]                        = t1.[Insurance Group Number 1]
	,[Insurance Address Line 1 1]                      = ''
	,[Insurance Address Line 2 1]                      = ''
	,[Insurance City 1]                                = ''
	,[Insurance State 1]                               = ''
	,[Insurance Zip 1]                                 = ''
	,[Insurance Phone 1]                               = ''
	,[Insurance Effective Date 1]                      = ''
	,[Insurance Expiration Date 1]                     = ''
	,[Insurance Carrier Code 2]                        = t1.[Insurance Carrier Code 2]
	,[Filler Field 6]                                  = ''
	,[Insurance Policy Member ID 2]                    = t1.[Insurance Policy Member ID 2]
	,[Insurance Subscriber First Name 2]               = t1.[Insurance Subscriber First Name 2]
	,[Insurance Subscriber Last Name 2]                = t1.[Insurance Subscriber Last Name 2]
	,[Insurance Primacy Indicator 2]                   = t1.[Insurance Primacy Indicator 2]
	,[Insurance Group Number 2]                        = t1.[Insurance Group Number 2]
	,[Insurance Address Line 1 2]                      = ''
	,[Insurance Address Line 2 2]                      = ''
	,[Insurance City 2]                                = ''
	,[Insurance State 2]                               = ''
	,[Insurance Zip 2]                                 = ''
	,[Insurance Phone 2]                               = ''
	,[Insurance Effective Date 2]                      = ''
	,[Insurance Expiration Date 2]                     = ''
	,[Insurance Carrier Code 3]                        = ''
	,[Filler Field 7]                                  = ''
	,[Insurance Policy Member ID 3]                    = ''
	,[Insurance Subscriber First Name 3]               = ''
	,[Insurance Subscriber Last Name 3]                = '' 
	,[Insurance Primacy Indicator 3]                   = '' 
	,[Insurance Group Number 3]                        = '' 
	,[Insurance Address Line 1 3]                      = '' 
	,[Insurance Address Line 2 3]                      = '' 
	,[Insurance City 3]                                = '' 
	,[Insurance State 3]                               = '' 
	,[Insurance Zip 3]                                 = '' 
	,[Insurance Phone 3]                               = '' 
	,[Insurance Effective Date 3]                      = '' 
	,[Insurance Expiration Date 3]                     = '' 
	,[Insurance Carrier Code 4]                        = '' 
	,[Filler Field 8]                                  = ''
	,[Insurance Policy Member ID 4]                    = '' 
	,[Insurance Subscriber First Name 4]               = '' 
	,[Insurance Subscriber Last Name 4]                = '' 
	,[Insurance Primacy Indicator 4]                   = '' 
	,[Insurance Group Number 4]                        = '' 
	,[Insurance Address Line 1 4]                      = '' 
	,[Insurance Address Line 2 4]                      = ''
	,[Insurance City 4]                                = '' 
	,[Insurance State 4]                               = ''
	,[Insurance Zip 4]                                 = ''
	,[Insurance Phone 4]                               = ''
	,[Insurance Effective Date 4]                      = ''
	,[Insurance Expiration Date 4]                     = ''
	,[Insurance Carrier Code 5]                        = ''
	,[Filler Field 9]                                  = ''
	,[Insurance Policy Member ID 5]                    = '' 
	,[Insurance Subscriber First Name 5]               = '' 
	,[Insurance Subscriber Last Name 5]                = '' 
	,[Insurance Primacy Indicator 5]                   = ''
	,[Insurance Group Number 5]                        = ''
	,[Insurance Address Line 1 5]                      = ''
	,[Insurance Address Line 2 5]                      = ''
	,[Insurance City 5]                                = ''
	,[Insurance State 5]                               = ''
	,[Insurance Zip 5]                                 = ''
	,[Insurance Phone 5]                               = ''
	,[Insurance Effective Date 5]                      = ''
	,[Insurance Expiration Date 5]                     = ''
	,[Parent or Guardian Relationship]                 = ''
	,[Parent or Guardian Relationship Other]           = ''
	,[Parent or Guardian Spoken Language]              = ''
	,[Parent or Guardian Spoken Language Other]	       = ''
	,[Parent or Guardian Last Name]                    = ''
	,[Parent or Guardian First Name]                   = ''
	,[Parent or Guardian Address Line 1]               = ''
	,[Parent or Guardian Address Line 2]               = ''
	,[Parent or Guardian City]                         = ''
	,[Parent or Guardian State]                        = ''
	,[Parent or Guardian Zip Code]                     = ''
	,[Parent or Guardian Zip Code Extension]           = ''
	,[Parent or Guardian Home Phone Area Code]         = ''
	,[Parent or Guardian Home Phone Exchange]          = ''
	,[Parent or Guardian Home Phone Suffix]            = ''
	,[Parent or Guardian Cell Phone Area Code]         = ''
	,[Parent or Guardian Cell Phone Exchange]          = ''
	,[Parent or Guardian Cell Phone Suffix]            = ''
	,[Parent or Guardian Email address]                = ''
	,[Parent or Guardian Verbal Preference]            = ''
	,[CDS Code]                                        = ''
	,[Federal District ID]                             = ''
	,[Federal School ID]                               = ''
	,[District Type]                                   = ''
	,[Federal Charter District ID]                     = ''
	,[School County]                                   = ''
	,[District or Administrative Authority name]       = ''

from dbo.CYBHI_PAT_LIST_RPT_CORE (@clientID, 1) as t1 

where ( 
	    (1=1)
	and (t1.[CanExportRow] = 1) /* Limit to rows we can export (export = 1 info is complete) */
    and (t1.registerPatWithTPA = 1) /* Limit to patients that have to be registered with TPA */
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_PAT_LIST_EXPORT_RPT] TO [webuser]
GO