USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SITES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SITES_VIEW] (
 @userID      BIGINT,
 @userGroup   INT,
 @userRank    INT,
 @clientID    INT,    
 @name        VARCHAR(50), 
 @canEdit     BIT,
 @active      BIT,
 @recID		  INT  
)    
 RETURNS TABLE AS RETURN(    
   select top (dbo.CONST_MAX_ROWS()) 
   
     q1.*
   , dbo.SITE_IS_UNKNOWN_FLAG (q1.name,q1.cds7) as uFlag    
      
   , [AddressLine] = dbo.BUILD_PLACE_ADDRESS_STRING (
       q1.address1
	 , q1.address2
	 , q1.city
	 , q1.state
	 , q1.zip5
	 , q1.zip4
	 , 0 )

   , activeStr = dbo.RPT_BIT_TO_YN(q1.active)
   
   , placeID    = dbo.BUILD_PLACE_ID_STRING (  dbo.CONST_PLACE_CLASS_CLIENT_SITE()
                                                , q1.clientID
                                                , q1.id
                                                , q1.siteAddressID
												, 1 )
                                                
   , placeClass = dbo.CONST_PLACE_CLASS_CLIENT_SITE()
   from    
   (    
     select   s.SITE_ID             as id,    
              s.SITE_NAME           as name,   
              ISNULL(s.CLIENT_PROVIDED_SITE_UID,'')as clientProvidedSiteUID, 
              ISNULL(s.SITE_CDS,'') as cds7,    
              s.SITE_CLIENT_ID      as clientID,    
              c.CLIENT_NAME         as clientName,    
              c.CLIENT_CDS          as clientCds,
              isnull(sa.ADDRESS_1,'')	    as address1,
              isnull(sa.ADDRESS_2,'')		as address2,
              isnull(sa.CITY,'')			as city,
              upper(isnull(sa.[STATE],''))  as [state],
              isnull(sa.ZIP,'')		        as zip5,
              isnull(sa.ZIP_PLUS_FOUR,'')   as zip4,
              isnull(s.ACTIVE,0)    as active,
			  s.attemptFuzzyMatchByNameAndCode as attemptFuzzyMatchByNameAndCode,
			  attemptFuzzyMatchByNameAndCodeStr = dbo.RPT_BIT_TO_YN(s.attemptFuzzyMatchByNameAndCode),
			  siteAddressID = sa.SITE_ADDRESS_ID,
			  phoneNumber = isnull(sa.PHONE_NUMBER,''),
			  s.cybhiTpaApproved as cybhiTpaApproved,
			  cybhiTpaApprovedStr       = dbo.RPT_BIT_TO_YN(s.cybhiTpaApproved),
			  s.cybhiTpaApprovedOn as cybhiTpaApprovedOn,
			  cybhiTpaApprovedOnStr = dbo.RPT_DATE_FMT(s.cybhiTpaApprovedOn),
			  cybhiTpaApprovedOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(s.cybhiTpaApprovedOn)
			  
     from     dbo.SITES_SITE        as s     
     join     dbo.CLIENTS_Client    as c  on c.CLIENT_ID = s.SITE_CLIENT_ID  
     left join dbo.SITES_Address    as sa on sa.SITE_ID = s.SITE_ID
                                       
     where ( 
	       (1=1)     
       and ((@clientID  is null) or (s.SITE_CLIENT_ID = @clientID))  
       and ((@name      is null) or (s.SITE_NAME like (@name + '%')))     
       and ((@recID     is null) or (s.SITE_ID = @recID))  
       and ((@active    is null) or (s.ACTIVE = @active))
     )
   ) as q1
   order by 
       q1.clientName
     , q1.name
 )     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SITES_VIEW] TO [webuser]
GO
