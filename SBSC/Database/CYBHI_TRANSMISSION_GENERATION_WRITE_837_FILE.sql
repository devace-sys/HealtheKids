use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_WRITE_837_FILE') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_WRITE_837_FILE
end
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_WRITE_837_FILE (  
    @transmissionID bigint       
  , @path         varchar(255) = 'C:\spedmon\data\import-export\claims\'
)
AS
BEGIN

  declare @fileContent as varchar(max) = ''
  declare @fileName    as varchar(100) = ''

  set nocount on

  select top 1 
      @fileContent = t1.fileContent
    , @fileName    = t1.[fileName]
  from dbo.CYBHI_CLAIM_TRANSMISSIONS as t1
  where 
    (t1.id = @transmissionID)

  if (@fileName = '') return(0)

  exec dbo.writestringtofile @fileContent, @path, @Filename
  return(0)

END
GO
