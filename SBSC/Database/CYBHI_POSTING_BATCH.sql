use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_POSTING_BATCH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_POSTING_BATCH
end
GO

CREATE PROCEDURE dbo.CYBHI_POSTING_BATCH (
    @path          varchar(255)  = ''
  , @notifyEmails  varchar(5000) = ''
)
AS
BEGIN
  
set nocount on
declare @jsonData as varchar(max) = '[]'

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Starting'

/*---------------------------------------------------------------------------------------------------------*/

if (len(@path) = 0) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Path required'
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Done'
  return(0)
end

if (len(@notifyEmails) = 0) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Notification emails required'
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Done'
  return(0)
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Init'

declare @msg as varchar(512)  = ''

set @msg = 'CYBHI Posting Batch - 835 file folder : ' + @path
exec dbo.PRINT_STATUS_MESSAGE @msg

set @msg = 'CYBHI Posting Batch - Email List : ' + @notifyEmails
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Calling Posting All Routine'

exec dbo.CYBHI_POSTING_ALL @path, N'*.edi', 0 /* @test */, 0 /*@userID */, @jsonData output

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting Batch - Done'
return(0)

END
GO
