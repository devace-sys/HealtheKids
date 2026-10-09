USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_PROXY_DISBURSE_VIEW_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_PROXY_DISBURSE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_PROXY_DISBURSE_VIEW_CORE]
(
)
 
returns

@claim_data table (
    PARENT_CLAIM_ID   bigint
  , CHILD_CLAIM_ID    bigint
  , NUM_MINS_PARENT   int
  , NUM_MINS_CHILD    int
  , NUM_UNITS_PARENT  int
  , NUM_UNITS_CHILD   int
  , DISBURSE_ON_MIN   bit
  , DISBURSE_ON_UNIT  bit
  , DISBURSE_FACTOR   decimal(18,2)
  unique clustered (PARENT_CLAIM_ID, CHILD_CLAIM_ID)
)
AS
BEGIN

/***************************************************************************    
 * CLAIMS_PROXY_DISBURSE_VIEW_CORE */    
/**    
 * Returns a table of claims and disbursement factors
 ***************************************************************************/        


/*###########################################################################
  # Pass 1
  ###########################################################################*/    

insert into @claim_data
select 
    [PARENT_CLAIM_ID]  = cc1.CLAIM_ID
  , [CHILD_CLAIM_ID]   = cc2.CLAIM_ID
  , [NUM_MINS_PARENT]  = 0
  , [NUM_MINS_CHILD]   = sr.numMins
  , [NUM_UNITS_PARENT] = cc1.SERVICE_UNITS
  , [NUM_UNITS_CHILD]  = cc2.SERVICE_UNITS
  , [DISBURSE_ON_MIN]  = case when cp1.UNIT_TYPE = 'MINUTES' and cp2.UNIT_TYPE = 'MINUTES' then 1 else 0 end
  , [DISBURSE_ON_UNIT] = case when cp1.UNIT_TYPE = 'TRIPS'   and cp2.UNIT_TYPE = 'TRIPS'   then 1
                              when cp1.UNIT_TYPE = 'MILES'   and cp2.UNIT_TYPE = 'MILES'   then 1
                              else 0 end
  , [DISBURSE_FACTOR]  = 0
from dbo.CLAIM_Claim           as cc1
join dbo.CLAIM_Procedures      as cp1 on cp1.PROCEDURE_ID         = cc1.PROCEDURE_ID

join dbo.CLAIM_Claim           as cc2 on cc2.REFERENCE_CLAIM_ID_1 = cc1.CLAIM_ID
join dbo.CLAIM_Procedures      as cp2 on cp2.PROCEDURE_ID         = cc2.PROCEDURE_ID

join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID              = cc2.CLAIM_ID
join dbo.SERVICE_RECORDS       as sr  on sr.id                    = src.svcRecID

where (
      (cc1.IS_PROXY = 1) 
  and (cc2.HAS_PROXY = 1)
  and (cp1.UNIT_TYPE in ('MINUTES','TRIPS','MILES'))
  and (cp2.UNIT_TYPE in ('MINUTES','TRIPS','MILES'))
)

/*###########################################################################
  # Pass 2
  ###########################################################################*/    

update @claim_data
  set NUM_MINS_PARENT = cs.TOT_NUM_MINS
from (
  select 
      PARENT_CLAIM_ID     as PAR_CLAIM_ID
    , SUM(NUM_MINS_CHILD) as TOT_NUM_MINS 
  from @claim_data 
  where (DISBURSE_ON_MIN = 1)
  group by PARENT_CLAIM_ID
) as cs
where cs.PAR_CLAIM_ID = PARENT_CLAIM_ID

/*###########################################################################
  # Pass 3
  ###########################################################################*/    

update @claim_data
  set DISBURSE_FACTOR = df.DF
from (
  select 
        [PAR_CLAIM_ID] = PARENT_CLAIM_ID
      , [CLD_CLAIM_ID] = CHILD_CLAIM_ID
      , [DF]           = (convert (decimal(18,2),NUM_MINS_CHILD)) / (convert (decimal(18,2),NUM_MINS_PARENT))
  from @claim_data 
  where ((DISBURSE_ON_MIN = 1) and (NUM_MINS_PARENT != 0))
) as df
where ( 
       (df.PAR_CLAIM_ID = PARENT_CLAIM_ID)
   and (df.CLD_CLAIM_ID = CHILD_CLAIM_ID)
   and (DISBURSE_ON_MIN = 1)
   and (NUM_MINS_PARENT != 0)
)

/*###########################################################################
  # Pass 4
  ###########################################################################*/    

update @claim_data
  set DISBURSE_FACTOR = df.DF
from (
  select 
        [PAR_CLAIM_ID] = PARENT_CLAIM_ID
      , [CLD_CLAIM_ID] = CHILD_CLAIM_ID
      , [DF]           = (convert (decimal(18,2),NUM_UNITS_CHILD)) / (convert (decimal(18,2),NUM_UNITS_PARENT))
  from @claim_data 
  where ((DISBURSE_ON_UNIT = 1) and (NUM_UNITS_PARENT != 0))
) as df
where ( 
       (df.PAR_CLAIM_ID = PARENT_CLAIM_ID)
   and (df.CLD_CLAIM_ID = CHILD_CLAIM_ID)
   and (DISBURSE_ON_UNIT = 1)
   and (NUM_UNITS_PARENT != 0)
)

return

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_PROXY_DISBURSE_VIEW_CORE] TO [webuser]
GO
  