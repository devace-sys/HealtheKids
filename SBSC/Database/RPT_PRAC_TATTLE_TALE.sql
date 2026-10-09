USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_PRAC_TATTLE_TALE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_PRAC_TATTLE_TALE]
GO

USE [spedmon]
GO

CREATE FUNCTION [dbo].[RPT_PRAC_TATTLE_TALE] (
    @userID               bigint
  , @userGroup            int
  , @userRank             int
  , @clientID             bigint
  , @repID                bigint
  , @rptGroupID           bigint
  , @groupSvcClassNameID  bigint
  , @pracID               bigint
  , @refDate              datetime
)
returns 
table
as
return
(
  select top (dbo.CONST_MAX_ROWS())
    rpt.* 
  from dbo.RPT_PRAC_TATTLE_TALE_CORE (@userID,@userGroup,@userRank,@clientID,@repID,@rptGroupID,@groupSvcClassNameID,@pracID,@refDate) as rpt
  order by 
      rpt.clientName
	, rpt.reportingGroup
	, rpt.pracName
)
      
GO
  
USE [spedmon]
GO

GRANT SELECT ON  [dbo].[RPT_PRAC_TATTLE_TALE] TO [webuser]
GO
  
