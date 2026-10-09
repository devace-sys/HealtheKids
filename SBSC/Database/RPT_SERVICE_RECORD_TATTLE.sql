USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SERVICE_RECORD_TATTLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SERVICE_RECORD_TATTLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_SERVICE_RECORD_TATTLE]     
(@clientID   int, 
 @groupID    int, 
 @pracID     int,   
 @startDate  datetime,    
 @endDate    datetime)     
 returns @recs table(                   
                     Client              nvarchar(max),     /* Columns in desired display order */
                     [Month/Year]        varchar(20),  
                     [Last Name]         nvarchar(100),
                     [First Name]        nvarchar(100), 
                     [Practitioner Type] nvarchar(max),
                     [Reporting Group]   nvarchar(max),
                     [Practitioner ID]   int                     
                     ) as
                       
/***************************************************************************
 * RPT_SERVICE_RECORD_TATTLE */
/**
 * Displays all active practitioners who have not entered or submitted work
 * for each month in the given date range.
 *
 * If practitioners do not provide us with service records for a given month
 * then the client could miss the oppurtunity to be reimbursed for eligible
 * services and thus lose revenue.
 * 
 * This report provides a management tool for clients by "tattling" on those
 * practitioners who have not provides us with service records.
 *
 * @param  clientID        ID of client or null for all clients
 * @param  groupID         ID of Group or null for all groups    
 * @param  pracID          ID of Practitioner or null for all practitioners
 * @param  startDate       Start date (required)  
 * @param  endDate         End date (required)
 * @return                 Table    
 ***************************************************************************/     
                       
begin

/*-------------------------------    
 * If the given dates are null
 * or @startDate > @endDate     
 * get out (return nothing)
 *------------------------------*/         
 
if ((@startDate is null) or (@endDate is null) or (@startDate > @endDate)) return
    
/*-------------------------------    
 * Setup query specific     
 * defaults.  Note the active    
 * flag is stored as a character    
 * in the database so we must    
 * generate an appropriate    
 * flag    
 *------------------------------*/    
     
insert into @recs

  select     
    
    q1.[Client],
    q1.[Month/Year],
    q1.[Last Name],
    q1.[First Name],
    q1.[Practitioner Type],
    q1.[Reporting Group],
    q1.[Practitioner ID]
  from 
    dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS(@clientID,@groupID,@pracID,@startDate,@endDate) AS q1
                    

return
end 


GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[RPT_SERVICE_RECORD_TATTLE] TO [webuser]
GO
