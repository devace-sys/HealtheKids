use users
go

------------------------------------------------

use users
go

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RoleData]') 
         AND name = 'reqPatAsc'
)
BEGIN
    ALTER TABLE dbo.RoleData
    ADD reqPatAsc bit not null default(0)
END

GO

------------------------------------------------

use users
go

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RoleData]') 
         AND name = 'ascPatWithAcct'
)
BEGIN
    ALTER TABLE dbo.RoleData
    ADD ascPatWithAcct bit not null default(0)
END
GO

------------------------------------------------

use users
go

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RoleData]') 
         AND name = 'canHaveMultiClientPatAsc'
)
BEGIN
    ALTER TABLE dbo.RoleData
    ADD canHaveMultiClientPatAsc bit not null default(0)
END
GO
------------------------------------------------

use users
go

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RoleData]') 
         AND name = 'canChangeToDifferentRole'
)
BEGIN
    ALTER TABLE dbo.RoleData
    ADD canChangeToDifferentRole bit not null default(1)
END
GO

------------------------------------------------
use users
go

update RoleData
  set canChangeToDifferentRole = 0
where userGroup = 3
go

------------------------------------------------

use users
go

update RoleData
  set canChangeToDifferentRole = 0
where id = 7
go

------------------------------------------------

use users
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FILE_EXPORT_SOURCES]') AND type IN (N'U'))
BEGIN
        CREATE TABLE [FILE_EXPORT_SOURCES] (
            id                                          bigint                  NOT NULL ,
           appName              varchar(50)        not null,
           [name]                  varchar(256)    NOT NULL ,  -- human legible; does nothing in the script logic

         
                        created                                 datetime                NOT NULL,
                        createdBy                               bigint                  NOT NULL,

                        lastUpdated                     datetime                NULL,
                        lastUpdatedBy                   bigint                  NULL,
                        active                                  bit                     NOT NULL DEFAULT(1)

        )
END
GO

------------------------------------------------

use users
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FILE_EXPORT_PUBLICATIONS]') AND type IN (N'U'))
BEGIN
        CREATE TABLE [FILE_EXPORT_PUBLICATIONS] (
              id                   bigint             NOT NULL,
              appName              varchar(50)        not null,
			  fileSourceID         int                NOT NULL ,
              [name]               varchar(50)        NOT NULL ,
              schedule             varchar(100)       NOT NULL,

                        created                                 datetime                NOT NULL,
                        createdBy                               bigint                  NOT NULL,

                        lastUpdated                     datetime                NULL,
                        lastUpdatedBy                   bigint                  NULL,
                        active                                  bit                     DEFAULT(1)

        )
END
GO

------------------------------------------------

use users
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FILE_EXPORT_SUBSCRIPTIONS]') AND type IN (N'U'))
BEGIN
        CREATE TABLE [FILE_EXPORT_SUBSCRIPTIONS] (
                id                   bigint identity(1,1) not null,
				appName              varchar(50)        not null,
                clientID            bigint         NOT NULL ,
                publicationID       bigint         NOT NULL ,
                [format]             smallint           NOT NULL ,                
				destinationFolder   varchar(512)   NOT NULL ,

                        created                                 datetime                NOT NULL,
                        createdBy                               bigint                  NOT NULL,

                        lastUpdated                     datetime                NULL,
                        lastUpdatedBy                   bigint                  NULL,
                        active                                  bit                     DEFAULT(1)

        )
END
GO

------------------------------------------------

use users
go
