
USE SPEDMON
GO

/*-------------------------------
 * Drop objects that depend on
 * type.  Note: Make sure you
 * recreate these objects after
 * running this.
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE
GO

/*-------------------------------
 * Drop type
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'ServiceJournalPractitionerTrainingDetails')
DROP TYPE ServiceJournalPractitionerTrainingDetails
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE ServiceJournalPractitionerTrainingDetails AS TABLE
(
    pracID       bigint            
  , pracName     varchar(1000)   /* Label */
  , pracTitle    varchar(1000)   /* Label */
  , trainingDate varchar(100)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON TYPE::ServiceJournalPractitionerTrainingDetails TO [webuser]
GO
