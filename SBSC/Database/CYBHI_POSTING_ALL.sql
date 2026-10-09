use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_POSTING_ALL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_POSTING_ALL
end
GO

CREATE PROCEDURE dbo.CYBHI_POSTING_ALL (
    @path         as nvarchar(512) = N'G:\spedmon\data\import-export\claims\cybhi\835\'
  , @filePattern  as nvarchar(255) = N'*.edi'
  , @test         as bit           = 1
  , @userID       as bigint        = -1
  , @jsonData     as varchar(max) output
)
AS
BEGIN
  
/*
Sample Use

use SPEDMON
go

declare @test     as bit           = 1
declare @userName as nvarchar(100) = N'awebb@help4schools.com'

------------------------------------------------------------------------------------------

declare @userID as bigint         = -1
declare @jsonData as varchar(max) = '[]'

select top 1 
  @userID = ua.userIDInt 
from users.dbo.USERS_ALL as ua 
where ( 
      (ua.userName    = N'awebb@help4schools.com')
  and (ua.userGroupID = 2 /* PCAL */)
)

exec dbo.CYBHI_POSTING_ALL  
      N'G:\spedmon\data\import-export\claims\cybhi\835\'
    , N'*.edi'
    , @test
    , @userID 
	, @jsonData output
*/

set nocount on
set @jsonData = '[]'

declare @pathFileName as nvarchar(512) = N''
declare @fileID       as bigint        = -1
declare @maxIdx       as int           = -1
declare @curIdx       as int           = 0
declare @msg          as varchar(512)  = ''

declare @pathFileNames as table (
    idx          int           identity(1,1)
  , pathFileName nvarchar(512) default(N'')
  , fileID       bigint        default(-1)  
unique clustered (idx)
)

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting All'
 
if (@userID = -1) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting All - No userid provided'
  return(0)
end

set @path = trim(@path)
if (len(@path) = 0)
begin
 exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting All - No path provided'
 return(0)
end

set @filePattern = trim(@filePattern)
if (len(@filePattern) = 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting All - No file pattern provided'
  return(0)
end  

insert into @pathFileNames (
  pathFileName
)
select 
  pathFileName = t1.full_filesystem_path 
from sys.dm_os_enumerate_filesystem(@path,@filePattern) as t1

if not exists (select top 1 * from @pathFileNames)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting All - No files found to post'
  return(0)
end  

select @curIdx = 1, @maxIdx = max(t1.idx) from @pathFileNames as t1

while (@curIdx <= @maxIdx)
begin
  
  select top 1 
    @pathFileName = pathFileName 
  from @pathFileNames as t1 
  where (t1.idx = @curIdx)
  
  set @msg = '========== ' + iif((@test=0),'Posting','Testing Posting') + ' ' + convert(varchar(50),@curIdx) + ' of ' + convert(varchar(50),@maxIdx) + ' =========='

  exec dbo.PRINT_STATUS_MESSAGE @msg
  exec dbo.PRINT_STATUS_MESSAGE @pathFileName
  
  exec dbo.CYBHI_POSTING @userID, @pathFileName, @test, @fileID output
  
  if (@test = 0)
  begin
    update @pathFileNames set fileID = @fileID where (idx = @curIdx)
  end

  set @curIdx = @curIdx + 1
end

set @jsonData = convert(varchar(max),(select * from @pathFileNames FOR JSON AUTO, INCLUDE_NULL_VALUES ))

return(0)

END
GO
