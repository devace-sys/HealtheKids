USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW] (
    @userID               BIGINT
  , @userGroup            INT
  , @userRank             INT
  , @clientID             BIGINT
  , @pracID               BIGINT
  , @disciplineGroupID    BIGINT
  , @spEdServiceCode      BIGINT
  , @active               BIT
  , @recID                BIGINT

)    
RETURNS 
TABLE
AS
RETURN
(
  with
  cte_p1
  as
  (
    select
      prac_pss.*
    , clientName = cc.CLIENT_NAME
    , pracName   = pp.CONCAT_NAME

    , codeName  = s_s.[name] 
    , codeValue = CAST(  prac_pss.spEdServiceCode  as varchar(4) )
	
  from PRACTITIONER_PREFERENCE_SPED_SERVICES  prac_pss
  JOIN                        CLIENTS_Client  cc
                                              ON  prac_pss.clientID = cc.CLIENT_ID

  JOIN            PRACTITIONER_PRACTITIONER  pp
                                              ON  prac_pss.pracID  = pp.PRACTITIONER_ID

                        
  JOIN                     dbo.SpEd_Service  s_s
                                              ON  s_s.codeValue = prac_pss.spEdServiceCode



  where ( 
             (prac_pss.clientID = @clientID)

	 and ( (@pracID is null) or (prac_pss.pracID                        =   @pracID            ) )
         and ( (@disciplineGroupID is null) or (prac_pss.disciplineGroupID  =   @disciplineGroupID ) )
         and ( (@spEdServiceCode is null) or (prac_pss.spEdServiceCode          =   @spEdServiceCode     ) )

	 and ( (@active is null) or (prac_pss.active = @active) )

         and ( (@recID is null)  or (prac_pss.id = @recID ) )
  )
  )
  ,
  cte_p2
  as
  (
  select 
      p1.* 
    , codeValueAndName = p1.codeValue + ' ' + p1.codeName
  from cte_p1 as p1
  )
  select top (dbo.CONST_MAX_ROWS())
    p2.* 
  from cte_p2 as p2
  order by 
    p2.spEdServiceCode
)

GO

GRANT SELECT ON  [dbo].[PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW] TO [webuser]
GO
