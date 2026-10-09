USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY]
(@clientID   as int,
 @patID      as int,
 @pracID     as int,
 @dos        as datetime,
 @svcType    as int,
 @tmtWhen    as int,
 @tmtHow     as int,
 @isOneOnOne as bit,
 @active     as bit)

/***************************************************************************    
 * RECURRING_SERVICES_MIN_PASED_PROCS_EXPD_SUMMARY */    
/**    
 * Returns summary of possible minute based services that patients in the 
 * recurring services system could receive on this day
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   patID           Patient ID you wish to work with or null for all
 * @param   pracID          Practitioner ID you wish to work with or null for all
 * @param   dos             Date of service
 * @param   svcType         Type of service (excluding transportation)
 * @param   tmtWhen         When 
 * @param   tmtHow          How
 * @param   isOneOnOne      null = Ignore 
                            0    = Show all except these 
                            1    = Show just these
 * @param   active          0 = Inactive 1 = Active
 ***************************************************************************/   
 
RETURNS TABLE 
AS 
RETURN
(

/*============================================================
 * Output
 *============================================================*/

select 
  @dos as [dos],
  clientID,
  patID,
  procID,
  sum(numMinsExpd) as numMinsExpd
  
from RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL(@clientID,
                                                    @patID,
                                                    @pracID,
                                                    @dos,
                                                    @svcType,
                                                    @tmtWhen,
                                                    @tmtHow,
                                                    @isOneOnOne,
                                                    @active)
group by
  clientID,
  patID,
  procID
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY] TO [webuser]
GO
