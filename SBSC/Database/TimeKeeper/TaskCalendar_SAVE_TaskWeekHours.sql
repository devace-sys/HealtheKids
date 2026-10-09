USE [TimeKeeper]
GO

DROP PROCEDURE if exists [dbo].[TaskCalendar_SAVE_TaskWeekHours]
GO

CREATE PROCEDURE [dbo].[TaskCalendar_SAVE_TaskWeekHours]    
 (
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,            /* TODO: userGroup and userRank aren't being used in this SPROC.  I think we have to accept these params because the middleware
                                      usually or always passes them in?  */
  @jsonBlob        varchar(8000),

  @e_id        bigint,

  @editDelReason   VARCHAR(7000),  /* TODO: This is usually passed in by middleware into save SPROCs.  It's not actually being used right now in here */
  @msgNoRec   VARCHAR(100),
  @msgNoEdit       VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we haven't implemented editable/non-editable permissions on this record type, yet */
  @validateRec     bit, /* TODO: the middleware passes this arg into save sprocs but we're not implementing any save validation here */
  @spDetails       VARCHAR(8000) OUTPUT,
  @recordID        BIGINT OUTPUT
)  
AS    

BEGIN

  declare @errorstr varchar(max)  = ''

  declare @timestamp_now        as datetime = GETDATE()

  declare @tranOpen             as BIT    = 0        -- Is a transaction open    
  
  set @spDetails = ''  -- middleware will crash if this return param is left null.  Now you know!
  set @recordID = 0


  LINENO 41

  BEGIN TRY

   BEGIN TRANSACTION
    set @tranOpen = 1

    declare @tbl
 as TABLE ( 
  "day" smallint,
  "te_id" bigint,
  "taskID_orgID" varchar(15),
  "time_entry" varchar(9),
  "week_starting_monday" date,
  taskID bigint,
  orgID bigint,
  emp_id bigint,
  "minutes" int
)

INSERT INTO @tbl
SELECT
  *, @e_id,   datediff(minute, 0, time_entry) "minutes" FROM OPENJSON (
@jsonBlob
) WITH (
  "day" smallint '$.day',
  "te_id" bigint '$.te_id',
  "taskID_orgID" varchar(15) '$.taskID_orgID',
  "time_entry" varchar(9) '$.entry',
  "week_starting_monday" date '$.week_starting_monday',
  "taskID" varchar(15) '$.taskID',
  "orgID" varchar(15) '$.orgID'
);


UPDATE dbo.TimeEntries
SET
  numberMinutes = tbl."minutes"
FROM
dbo.TimeEntries te
JOIN @tbl tbl ON te.id = tbl.te_id


SELECT * FROM @tbl

DECLARE @iter INT =0
declare @ted_id int
WHILE ( @iter <= 6)
BEGIN
    declare @taskID bigint, @orgID bigint, @emp_id bigint = null, @minutes int, @week_starting_monday date
    select
      @taskID = taskID,
      @orgID = orgID,
      @minutes = "minutes",
      @emp_id = "emp_id",
      @week_starting_monday = week_starting_monday
    FROM @tbl WHERE ( "day" = @iter AND te_id IS NULL)

    SET @iter  = @iter  + 1

    if (@emp_id IS NULL)
      continue;

    declare @te_id bigint = null

    SELECT
      @te_id = id
    FROM [dbo].[TimeEntry_Day]
    WHERE (employeeID = @emp_id AND dateForTimeEntry = DATEADD(day, ( @iter - 2), @week_starting_monday ) )

    if (@te_id IS NULL AND @minutes > 0)
    begin
      INSERT INTO [dbo].[TimeEntry_Day]
      VALUES (@emp_id, DATEADD(day, ( @iter - 2), @week_starting_monday ) )
      SET @te_id = SCOPE_IDENTITY()
    end

    if (@minutes > 0)
      INSERT INTO [dbo].[TimeEntries]
      ([timeEntryDayID]
      ,[timeOfTask]
      ,[numberMinutes]
      ,[timeEntrytaskID]
      ,[orgClientID]
      ,[dateEntryCreated]
      ,[dateEntryUpdated]
    ) VALUES (
      @te_id,
      DATEADD(day, ( @iter - 1), @week_starting_monday ) ,
      @minutes,
      @taskID,
      @orgID,
      GETDATE(),
      GETDATE()
    )

    
END
   
  --END
     
  COMMIT TRANSACTION
  set @tranOpen = 0

  RETURN (0)

  END TRY
  
  BEGIN CATCH

    if (@tranOpen = 1)
    begin  
      rollback transaction
    end

    DECLARE @ErrorMessage  AS NVARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    

    SET @errorstr += ' - Ooops; ' + ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' line ' + CAST(ERROR_LINE() AS VARCHAR)

    --SET @spDetails = @errorstr  -- This should output the error to the browser.  Comment on production, uncomment on dev for diagnostics as needed.

    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);

  END CATCH
  
END
GO

grant execute on [TaskCalendar_SAVE_TaskWeekHours] to webuser
GO
