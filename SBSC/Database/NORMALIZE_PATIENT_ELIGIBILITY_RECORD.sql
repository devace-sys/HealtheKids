USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NORMALIZE_PATIENT_ELIGIBILITY_RECORD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NORMALIZE_PATIENT_ELIGIBILITY_RECORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[NORMALIZE_PATIENT_ELIGIBILITY_RECORD]    
(@patID    INT,    
 @elgDisp  SMALLINT,    
 @refDate  DATETIME,    
 @mCurDate DATETIME,    
 @mCurFlag NVARCHAR(1),    
 @JanFlag  NVARCHAR(1),    
 @FebFlag  NVARCHAR(1),    
 @MarFlag  NVARCHAR(1),    
 @AprFlag  NVARCHAR(1),    
 @MayFlag  NVARCHAR(1),    
 @JunFlag  NVARCHAR(1),    
 @JulFlag  NVARCHAR(1),    
 @AugFlag  NVARCHAR(1),    
 @SepFlag  NVARCHAR(1),    
 @OctFlag  NVARCHAR(1),    
 @NovFlag  NVARCHAR(1),    
 @DecFlag  NVARCHAR(1)        
)    
RETURNS TABLE

/***************************************************************************    
 * NORMALIZE_PATIENT_ELIGIBILITY_RECORD */    
/**      
 * Calls CALC_ELIGIBILITY in "parse" mode to return the records as is
 *
 * @returns Table 
 ***************************************************************************/                         
     
AS
return  
   
   
  /*-------------------------------
   * Note: 
   * CALC_ELIGIBILITY does not 
   * return patient id nor does
   * it use patient id in its
   * calculations, and it is 
   * complex enough to not want
   * to touch.  Therefore we wrap
   * the call here.
   *------------------------------*/
  
  select 
    @patID as Patient_id, 
    c.* 
  from dbo.CALC_ELIGIBILITY(1,
                            null,
                            @mcurDate,
                            @mCurFlag,
                            @JanFlag,
                            @FebFlag,
                            @MarFlag,
                            @AprFlag,
                            @MayFlag,
							@JunFlag,
							@JulFlag,
							@AugFlag,
							@SepFlag,
							@OctFlag,
							@NovFlag,
							@DecFlag) as c
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[NORMALIZE_PATIENT_ELIGIBILITY_RECORD] TO [webuser]
GO   
