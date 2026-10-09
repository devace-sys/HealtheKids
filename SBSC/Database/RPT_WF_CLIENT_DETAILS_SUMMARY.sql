USE [SPEDMON]

GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('RPT_WF_CLIENT_DETAILS_SUMMARY') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_WF_CLIENT_DETAILS_SUMMARY]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_WF_CLIENT_DETAILS_SUMMARY]
(@clientID       BIGINT,
 @friday         datetime
)
RETURNS TABLE

AS
/***************************************************************************
 * RPT_WF_CLIENT_DETAILS_SUMMARY */
/**
 * Generates RPT_WF_CLIENT_DETAILS_SUMMARY report for each client
 * 
 * @param  clientID      
 
 * @return Table
 ***************************************************************************/

RETURN(

       select top (dbo.CONST_MAX_ROWS()) 
              cc.CLIENT_NAME,
              cc.CLIENT_CDS + ' - ' + cc.ShortName as ShortNameandCDS,
              cr.first_name+ ' '+cr.last_name as DistrictRep,               
              curWeek.TotalThisWeek,
              h.HoursOnHand,
              CONVERT(varchar(20),h.OldestDateOfService,111) as 'Oldest Date of Service',
              CONVERT(varchar(20),h.OldestRecievedDate,111)  as 'Oldest Recieved Date' 
         from HOURS_ON_HAND(NULL,@friday) as h 
       left join Clients_client cc          on cc.Client_id = h.Client_id 
       left join dbo.CLIENTS_Client_Reps cr on cr.id = cc.ClientRepIDLEACurrent
       left join (select ClientID,SUM(isnull(Estimated_Input_Hours,0)) as TotalThisWeek 
                    from INPUT_BATCHES 
                   where Date_Recieved >= dateadd(hh,12,DATEADD(dd,-7,@friday)) and 
                         Date_Recieved <= DATEADD(hh,12,@friday)
                  group by ClientID) curWeek on curWeek.ClientID = cc.CLIENT_ID
       where cc.client_id != 112 and
            ((@clientID  is null)  or (cc.Client_id = @clientID))
       order by client_name                   
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[RPT_WF_CLIENT_DETAILS_SUMMARY] TO [webuser]

GO

 

