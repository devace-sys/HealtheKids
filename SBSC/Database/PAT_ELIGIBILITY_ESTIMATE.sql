USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PAT_ELIGIBILITY_ESTIMATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PAT_ELIGIBILITY_ESTIMATE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PAT_ELIGIBILITY_ESTIMATE]    
(@mCurFlag NVARCHAR(1),    
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
)RETURNS CHAR(2) AS     
BEGIN          
     
  /*-------------------------------    
   * All flags are yes.    
   * Assuming the eligibilty data    
   * is current we know that    
   * this patient is eligible    
   *------------------------------*/    
      
  IF ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@mCurFlag)) = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@FebFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MarFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AprFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JunFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JulFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AugFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND         
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@SepFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@OctFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@NovFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@DecFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES())    
     RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()    
    
  /*-------------------------------    
   * All flags are no.    
   * Assuming the eligibilty data    
   * is current we know that    
   * this patient is not eligible    
   *------------------------------*/    
       
  IF ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@mCurFlag)) = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@FebFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MarFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AprFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JunFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JulFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AugFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND         
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@SepFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@OctFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@NovFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@DecFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO())    
     RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()    
    
  /*-------------------------------    
   * Flags are a mix    
   * We don't know their eligibility    
   * yet.  To determine eligibility    
   * we need the date of service    
   *------------------------------*/     
  RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
    
END    
    
GO
