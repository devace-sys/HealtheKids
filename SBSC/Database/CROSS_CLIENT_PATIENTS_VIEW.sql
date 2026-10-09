USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CROSS_CLIENT_PATIENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CROSS_CLIENT_PATIENTS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CROSS_CLIENT_PATIENTS_VIEW] (
    @userID                       bigint
  , @userGroup                    int
  , @userRank                     int
  , @clientID			          bigint              /* Client ID of user or contextual client id */
  , @ssid                         nvarchar(50) = ''
  , @excludeOtherClientDataIfCallingClientHasRecs bit = 1
  , @excludeOtherClientIDAndPatID                 bit = 1
)
    
returns @recs table (
    id                int identity(1,1)
  , [name]            nvarchar(256)
  , clientID          bigint
  , patID             bigint
  , lastName          nvarchar(50)   
  , firstName         nvarchar(50)  
  , middleName        nvarchar(50) 
  , preferredNickname nvarchar(50)
  , dob               datetime
  , dobStrYMD         varchar(50)
  , gender            varchar(1)
  , CSIS              nvarchar(50)
  , ageCurrent        int
  , recExistsForCallingClient    bit default(0)  
  , ageCurrentStr                varchar(256)
  , recExistsForCallingClientStr varchar(256)
  , clientIDStr                  varchar(256)
  , patIDStr                     varchar(256)
)
AS     
BEGIN     

if (@clientID is null) return
set @ssid = trim(isnull(@ssid,N''))
if (@ssid = N'') return  /* Very important as we dont want to search for empty SSIDS */

declare @today as datetime = getdate()

insert into @recs (
    [name]
  , clientID
  , patID
  , lastName
  , firstName
  , middleName
  , preferredNickname
  , dob
  , dobStrYMD
  , gender
  , CSIS 
  , ageCurrent
  , recExistsForCallingClient 
)

select
  [name] = q1.lastName + N', ' + q1.firstName 
 , q1.*
from
(      
  select 
        clientID          = pac.CLIENT_ID
      , patID             = pap.PATIENT_ID
      , lastName          = pap.LAST_NAME
      , firstName         = pap.FIRST_NAME
      , middleName        = isnull(pap.MIDDLE_NAME,N'')
      , preferredNickname = isnull(pap.preferredNickname,N'')	
      , dob               = pap.DATE_OF_BIRTH
      , dobStrYMD         = dbo.RPT_DATE_FMT_YYYY_MM_DD(pap.DATE_OF_BIRTH)
      , gender            = pap.SEX
      , CSIS              = pap.CSIS
	  , ageCurrent        = dbo.CALC_AGE(pap.DATE_OF_BIRTH,@today)
	  , recExistsForCallingClient = iif(@clientID = pac.CLIENT_ID,1,0)
	
    from dbo.PATIENTS_Patient as pap  
    join dbo.PATIENTS_Client  as pac on pac.PATIENT_ID = pap.PATIENT_ID
    where ( 
        ((pap.CSIS = @ssid)) /*[onCSIS]*/
      and (pap.ACTIVE = N'y')
    )
  ) as q1

  /* For new record searches we only want to show cross references for other clients if
   * records do not already exist that are associated with the calling client.
   */
  
  if (@excludeOtherClientDataIfCallingClientHasRecs = 1)
  begin
    if exists (select top 1 patID from @recs where recExistsForCallingClient = 1)
	begin
	  delete @recs where recExistsForCallingClient = 0
	end
  end
  
  if (@excludeOtherClientIDAndPatID = 1)
  begin
    update @recs set clientID = -1, patID = -1 where recExistsForCallingClient = 0
  end

  update @recs
  set 
      recExistsForCallingClientStr = dbo.BIT_TO_YN(recExistsForCallingClient)
	, clientIDStr                  = convert(varchar(256),clientID)
    , patIDStr                     = convert(varchar(256),patID)
	, ageCurrentStr                = convert(varchar(256),ageCurrent)
	
  return

end
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CROSS_CLIENT_PATIENTS_VIEW] TO [webuser]
GO