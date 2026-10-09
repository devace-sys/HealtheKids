use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].PRINT_STATUS_MESSAGE') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE PRINT_STATUS_MESSAGE
GO

CREATE PROCEDURE PRINT_STATUS_MESSAGE ( 
  @msgStr varchar(512) = ''
)
AS
BEGIN
  declare @timeStampStr as varchar(25) = convert(varchar(25), getdate(), 120) 
  RAISERROR ('[%s] %s',0, 1,@timeStampStr,@msgStr) WITH NOWAIT	
END
GO
 
GRANT EXECUTE ON  [dbo].[PRINT_STATUS_MESSAGE] TO [webuser]
GO