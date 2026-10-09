USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CDE_SCHOOLS_SITES_CURRENT]'))
DROP VIEW [dbo].[CDE_SCHOOLS_SITES_CURRENT]
GO

CREATE VIEW [dbo].[CDE_SCHOOLS_SITES_CURRENT] 
AS 

/***************************************************************************    
 * CDE_SCHOOLS_SITES_CURRENT */
/**    
 *
 * @returns table
 ***************************************************************************/     


select
  *
, HasAddressData = convert(bit,case when ((Street != '') and (City != '') and (State != '') and (Zip5 != '')) then 1 else 0 end)
, HasCDSCode     = convert(bit,case when (LEN(CDSCode) = 14) then 1 else 0 end)
, LastUpdateDaysAgo = DATEDIFF(DAY,  LastUpdate,GETDATE())
from
(
  select
       County    = ltrim(rtrim(isnull(County, ''))) 
     , District  = ltrim(rtrim(isnull(District, ''))) 
     , School    = ltrim(rtrim(isnull(School, '')))
     , CDSCode
     , CDSCodeCounty   = SUBSTRING(CDS_FIRST_7,1,2)
     , CDSCodeDistrict = SUBSTRING(CDS_FIRST_7,3,5)
     , CDSCodeSite     = CDS_LAST_7    
     , CDSCodeFirst7   = CDS_FIRST_7     , CDSCodeLast7    = CDS_LAST_7
     , Website = ltrim(rtrim(isnull(Website,'')))
     , Phone   = ltrim(rtrim(isnull(Phone,  '')))
     , Street  = ltrim(rtrim(isnull(Street, '')))
     , City    = ltrim(rtrim(isnull(City,   '')))
     , State   = ltrim(rtrim(isnull(State,  '')))
     , Zip     = ltrim(rtrim(isnull(Zip,    '')))
     , Zip5    = isnull(SUBSTRING(Zip,1,5), '')
     , Zip4    = isnull(SUBSTRING(Zip,7,4), '')
     , DataSource 
     , LastUpdate     

  from
  (
    select 
        County
      , District
      , CDSCode 
      , School
      , Website
      , Street
      , City
      , State
      , Zip
      , Phone
      , DataSource = 'Public Schools'
      , LastUpdate = CONVERT(date,LastUpdate)      , CDS_FIRST_7      , CDS_LAST_7
    from dbo.CDE_SCHOOLS_PUBLIC_SITES_CURRENT
    
    union
    select 
        County
      , District = [Public District]
      , CDSCode  = [Cds Code]
      , School
      , Website  = ''
      , Street
      , City
      , State
      , Zip
      , Phone      = [Telephone]
      , DataSource = 'Private Schools'
      , LastUpdate = [Published Date]      , CDS_FIRST_7      , CDS_LAST_7
    from dbo.CDE_SCHOOLS_PRIVATE_SITES_CURRENT
  ) as q0
) as q1

GO
