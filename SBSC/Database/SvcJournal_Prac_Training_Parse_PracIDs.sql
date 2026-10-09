USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Prac_Training_Parse_PracIDs') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Prac_Training_Parse_PracIDs
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Prac_Training_Parse_PracIDs] (
    @clientID       bigint
  , @pracIDsStr     varchar(8000)
  , @recID          bigint
)   
RETURNS

@recs table (
    recID          bigint
  , pracIDsStr     varchar(8000)
  , pracNamesStr   varchar(max)
  , pracTitlesStr  varchar(max)
)
AS
BEGIN

declare @pracs as table (
      idx       int
    , pracID    bigint
    , pracName  varchar(500)
    , pracTitle varchar(500)
)

declare @pracNamesStr as varchar(max)
declare @pracTitlesStr as varchar(max)

insert into @pracs
select * from dbo.SvcJournal_Prac_Training_Parse_PracIDs_Core (@clientID, @pracIDsStr)

select @pracNamesStr = substring (
  (select '|' + s.pracName 
    from (
      select pracName from @pracs 
    ) as s 
    for xml path('')
  ) ,2,200000) 
   
select @pracTitlesStr = substring (
  (select '|' + s.pracTitle
     from (
       select pracTitle from @pracs
     ) as s  
     for xml path('')
   ),2,200000) 
   
insert into @recs values (@recID, @pracIDsStr, @pracNamesStr,@pracTitlesStr)
return

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Prac_Training_Parse_PracIDs] TO [webuser]
GO  