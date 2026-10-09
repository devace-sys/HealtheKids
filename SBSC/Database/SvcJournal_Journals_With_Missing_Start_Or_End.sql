USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journals_With_Missing_Start_Or_End') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journals_With_Missing_Start_Or_End
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journals_With_Missing_Start_Or_End] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @pracID            BIGINT
)    

RETURNS 
TABLE
AS
RETURN
(
select 
  *
  , rank() over (ORDER BY q1.dosVal, q1.patName, q1.patID) AS [rowOrder]

from
(

  select 

    t2.*

  from dbo.SvcJournal_Journals_With_Missing_Start_Or_End_Core (  @userID
                                                               , @userGroup
                                                               , @userRank
                                                               , @clientID
                                                               , @pracID ) as t1
  join dbo.SvcJournal_Journals_View_Core (  @userID
                                          , @userGroup
                                          , @userRank
                                          , @clientID
                                          , null
                                          , null
                                          , 0
                                          , null ) as t2 on t2.id = t1.journalID
) as q1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journals_With_Missing_Start_Or_End] TO [webuser]
GO  
