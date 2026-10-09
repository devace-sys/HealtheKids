USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_Provider_Specialties_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_Provider_Specialties_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_Provider_Specialties_View] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
)
 
RETURNS TABLE      

/***************************************************************************    
 * CYBHI_Provider_Specialties_View*/    
/**    
 * Returns complete list of name and values for the TPAs list of specialties
 *
 * Note: Keep this in synch with the spec from the TPA (third party admin).
 * Currently the TPA is Carelon.
 * The spec can be found here : 
 * http://sbscitdev.help4schools.com/dokuwiki/lib/exe/fetch.php?media=cybhi:2._carelon_standard_provider_data_exchange_layout_guide.pdf
 ***************************************************************************/            

AS RETURN (        
  select top (dbo.CONST_MAX_ROWS())
      cps.id 
	, cps.codeValue
    , [name] = cps.codeValue + ' - ' + cps.[name] 
  from dbo.CYBHI_Provider_Specialties as cps
  where (
        (cps.active = 1)
	and ((@term is null) or (cps.[name] like (('%' + @term + '%'))) or (cps.codeValue like (('%' + @term + '%'))))
  )
  order by 
    cps.[name]
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_Provider_Specialties_View] TO [webuser]
GO   
