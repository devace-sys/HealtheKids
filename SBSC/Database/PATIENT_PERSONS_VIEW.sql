USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PERSONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PERSONS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patientID              BIGINT
 , @CLASS_ID_1             bigint
 , @CLASS_ID_2             bigint
 , @term                   varchar(256)
 , @active                 BIT
 , @recID                  BIGINT 
)

RETURNS TABLE
AS
RETURN
(  
  select top (dbo.CONST_MAX_ROWS()) 
    t1.*
  from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                      , @userGroup
                                      , @userRank
                                      , @clientID
                                      , @patientID
                                      , @CLASS_ID_1
                                      , @CLASS_ID_2
                                      , @active
                                      , @recID
									  , null) as t1
   where (
         (1=1)         
     and (
	       (@term is null) 
	       or 
		   (
		         (t1.[name]  like (isnull(@term,'') + '%'))
		      or (t1.[email] like (isnull(@term,'') + '%'))
		   )
        )
   )
   order by 
     t1.[name]  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PERSONS_VIEW] TO [webuser]
GO