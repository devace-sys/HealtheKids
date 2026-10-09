USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURE_MODIFIERS_LIST_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURE_MODIFIERS_LIST_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIM_PROCEDURE_MODIFIERS_LIST_VIEW] (
@userID           BIGINT,    
@userGroup        INT,    
@userRank         INT
)  
 RETURNS @recs TABLE(id  int,
	                 name [nchar](10) 
					 ) AS    
                           
 
 /***************************************************************************    
  * CLAIM_PROCEDURES_VIEW */    
 /**    
  * Returns a table of CLAIMS_PROCEDURE_MODIFIERS_LIST that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  active          If procedure is active
  * @param  recID           record id    
  * @return                 Table of data    
  ***************************************************************************/     
  
begin

DECLARE @temp TABLE([PROCEDURE_MODIFIER] [nchar](10))          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/   
 
     insert into @temp
      select DISTINCT PROCEDURE_MODIFIER_1 FROM CLAIM_PROCEDURES UNION 
      select DISTINCT PROCEDURE_MODIFIER_2 FROM CLAIM_PROCEDURES UNION 
      select DISTINCT PROCEDURE_MODIFIER_3 FROM CLAIM_PROCEDURES UNION
      select DISTINCT PROCEDURE_MODIFIER_4 FROM CLAIM_PROCEDURES
    insert into @recs
     select distinct null,PROCEDURE_MODIFIER from @temp
    
 return
 
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_PROCEDURE_MODIFIERS_LIST_VIEW] TO [webuser]
GO
