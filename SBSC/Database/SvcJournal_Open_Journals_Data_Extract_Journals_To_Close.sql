USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Open_Journals_Data_Extract_Journals_To_Close') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Open_Journals_Data_Extract_Journals_To_Close
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Open_Journals_Data_Extract_Journals_To_Close] (
  @data xml
)    

returns 
table
as 
return
(
  select
      col.value('idx[1]',        'bigint')       as idx
    , col.value('journalID[1]',  'bigint')       as journalID
    , col.value('clientID[1]',   'bigint')       as clientID
    , col.value('clientName[1]', 'varchar(512)') as clientName
    , col.value('patID[1]',      'bigint')       as patID
    , col.value('patName[1]',    'varchar(512)') as patName
    , col.value('dos[1]',        'date')         as dos
    , col.value('userID[1]',     'bigint')       as userID
    , col.value('userGroup[1]',  'int')          as userGroup
    , col.value('userRank[1]',   'int')          as userRank
    , col.value('userIP[1]',     'varchar(500)') as userIP
    , col.value('pracID[1]',     'bigint')       as pracID
  from @data.nodes ('/SvcJournalOpenJournalsData/JournalToCloseRows/JournalToCloseRow') as xdata(col)
)

GO
