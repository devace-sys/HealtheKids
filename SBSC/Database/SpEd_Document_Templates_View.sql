USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SpEd_Document_Templates_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SpEd_Document_Templates_View
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SpEd_Document_Templates_View] (
   @userID                    BIGINT
 , @userGroup                 INT  
 , @userRank                  INT 
 , @clientID                  BIGINT
 , @term                      VARCHAR(128)
 , @display                   BIT
 , @spEdPlanTypeCode          INT
 , @active                    BIT
 , @recID                     BIGINT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * SpEd_Document_Templates_View */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
( 
  
  with 
  cte_p1
  as
  (
    select 
	    clientName = null
	  , standardSelection = convert(bit,1)
	  , sdts.* 
	
	from dbo.SpEd_Document_Templates as sdts 
	where  (
	        (1=1)
	    and ((@recID is null) or (sdts.id = @recID))
	    and (sdts.clientID is null)
	 )
  )
  ,
  cte_p2
  as
  (
    select 
        clientName = clc.CLIENT_NAME 
	  , standardSelection = convert(bit,0)
	  , sdtc.* 
    from dbo.SpEd_Document_Templates as sdtc
    join dbo.CLIENTS_Client          as clc on clc.CLIENT_ID = sdtc.clientID
	where (
         (1=1) 
	 and (sdtc.clientID is not null)
	 and ((@recID is null) or (sdtc.id = @recID))
	 and ((@clientID is null) or (sdtc.clientID = @clientID))
	)
  )
  ,
  cte_p3
  as
  (
    select * from cte_p1 as p1
	union all
	select * from cte_p2 as p2
  )
  ,
  cte_p4
  as
  (
    select 
	  p3.* 
	from cte_p3 as p3
    where (
           (1=1) 
      and ((@display is null)          or (p3.display = @display))
      and ((@active is null)           or (p3.active  = @active))
	  and ((@spEdPlanTypeCode is null) or (p3.spEdPlanTypeCode = @spEdPlanTypeCode))
    )
  )
  
  select top (dbo.CONST_MAX_ROWS()) 
    p4.*          
  from cte_p4 as p4
  where ( 
        (1=1)
    and ((@term is null) or (    (p4.[name]  like '%' + @term + '%')
                              or (p4.[description] like '%' + @term + '%') /* Key words search */
                            ))
   
  )
  order by 
      p4.[standardSelection] asc 
	, p4.[name] asc
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SpEd_Document_Templates_View] TO [webuser]
GO