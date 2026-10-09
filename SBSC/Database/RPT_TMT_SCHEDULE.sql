USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_TMT_SCHEDULE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_TMT_SCHEDULE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_TMT_SCHEDULE](
  @tmtFrqInd2 INT,
  @tmtDurInd2 INT,
  @tmtFrqGrp2 INT,
  @tmtDurGrp2 INT,

  @tmtFrqInd3 INT,
  @tmtDurInd3 INT,
  @tmtFrqGrp3 INT,
  @tmtDurGrp3 INT,

  @tmtFrqInd4 INT,
  @tmtDurInd4 INT,
  @tmtFrqGrp4 INT,
  @tmtDurGrp4 INT,

  @tmtFrqInd5 INT,
  @tmtDurInd5 INT,
  @tmtFrqGrp5 INT,
  @tmtDurGrp5 INT,

  @tmtFrqInd6 INT,
  @tmtDurInd6 INT,
  @tmtFrqGrp6 INT,
  @tmtDurGrp6 INT
)     

RETURNS VARCHAR(1000)
AS     
BEGIN    
  
  declare @tempout as varchar(1000)
  declare @durin   as varchar(50)  
  declare @ind     as varchar(50)
  declare @grp     as varchar(50)
  
  set @durin = 'min'
  set @ind   = 'Ind'
  set @grp   = 'Grp'
  
  set @tempout = ''
  
  if ((@tmtDurInd2 is not null) or (@tmtDurGrp2 is not null)) set @tempout = @tempout + '[Mon] '
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@ind, @tmtFrqInd2, @tmtDurInd2, @durin) 
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@grp, @tmtFrqGrp2, @tmtDurGrp2, @durin)

  if ((@tmtDurInd3 is not null) or (@tmtDurGrp3 is not null)) set @tempout = @tempout + '[Tue] '
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@ind, @tmtFrqInd3, @tmtDurInd3, @durin)
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@grp, @tmtFrqGrp3, @tmtDurGrp3, @durin)

  if ((@tmtDurInd4 is not null) or (@tmtDurGrp4 is not null)) set @tempout = @tempout + '[Wed] '
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@ind, @tmtFrqInd4, @tmtDurInd4, @durin)
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@grp, @tmtFrqGrp4, @tmtDurGrp4, @durin)

  if ((@tmtDurInd5 is not null) or (@tmtDurGrp5 is not null)) set @tempout = @tempout + '[Thu] '
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@ind, @tmtFrqInd5, @tmtDurInd5, @durin)
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@grp, @tmtFrqGrp5, @tmtDurGrp5, @durin)
  
  if ((@tmtDurInd6 is not null) or (@tmtDurGrp6 is not null)) set @tempout = @tempout + '[Fri] '
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@ind, @tmtFrqInd6, @tmtDurInd6, @durin)
  set @tempout = @tempout + dbo.RPT_FRQ_DUR(@grp, @tmtFrqGrp6, @tmtDurGrp6, @durin)
  
  RETURN @tempout
  
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_TMT_SCHEDULE] TO [webuser]
GO
