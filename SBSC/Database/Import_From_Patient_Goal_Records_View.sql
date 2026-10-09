USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Import_From_Patient_Goal_Records_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Import_From_Patient_Goal_Records_View
GO

CREATE FUNCTION dbo.Import_From_Patient_Goal_Records_View (
      @userID    bigint
    , @userGroup int
    , @userRank  int
    , @clientID  bigint
    , @patID     bigint
    , @dos       date
    , @term      varchar(256) /* possible future use */
    , @active    bit
    , @recID     bigint
)
RETURNS TABLE
AS
RETURN
(
    with
	cte_p1
	as
	(
	  select top 1 dos = convert(date,(isnull(@dos,getdate())))
	)
	select 
	  t2.*
	from cte_p1 as p1
	cross apply (
	  select 
        t1.*
      from dbo.Import_From_Patient_Goal_Records_View_Core (
          @clientID
        , @patID
        , p1.dos
		, @term
        , @active
        , @recID ) as t1
    ) as t2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[Import_From_Patient_Goal_Records_View] TO [webuser]
GO