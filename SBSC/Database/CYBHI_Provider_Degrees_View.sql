USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_Provider_Degrees_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_Provider_Degrees_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_Provider_Degrees_View] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
)
 
RETURNS TABLE      

/***************************************************************************    
 * CYBHI_Provider_Degrees_View */    
/**    
 * Returns complete list of name and values for the TPAs list of degrees
 *
 * Note: Keep this in synch with the spec from the TPA (third party admin).
 * Currently the TPA is Carelon.
 * The spec can be found here : 
 * http://sbscitdev.help4schools.com/dokuwiki/lib/exe/fetch.php?media=cybhi:2._carelon_standard_provider_data_exchange_layout_guide.pdf
 ***************************************************************************/            
    
AS RETURN (        
  select top (dbo.CONST_MAX_ROWS())
      cpd.id
	, cpd.codeValue 
    , [name] = cpd.codeValue + ' - ' + cpd.[name] 
  from dbo.CYBHI_Provider_Degrees as cpd
  where (
        (cpd.active = 1)
	and ((@term is null) or (cpd.[name] like (('%' + @term + '%'))) or (cpd.codeValue like (('%' + @term + '%'))))
  )
  order by 
    cpd.[name]
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_Provider_Degrees_View] TO [webuser]
GO   
