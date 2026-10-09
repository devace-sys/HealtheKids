USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_IN_PROCESS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_IN_PROCESS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_IN_PROCESS_VIEW] (
	   @userID            bigint
	 , @userGroup         int
	 , @userRank          int
	 , @clientID          bigint
	 , @currentStatus     int
	 , @assignedUserID    bigint
	 , @batchID           bigint
	 , @active            bit
	 , @term                     varchar(500)
	 , @recID                    bigint
	 , @workTypeID               bigint
	 , @showJustBatchesInProcess bit
)
     
RETURNS TABLE  

AS RETURN (

with
cte_p1
as
(
  select term = '%' + trim(isnull(@term,'')) + '%'
)
,
cte_p2
as
(
  select 
      ib2.*	
  from cte_p1 as p1

  cross apply (
    select 
        ib1.id /* Just return id */
	from dbo.INPUT_BATCHES as ib1
    where (
            (1=1)		
		and ((@batchID        is null) or (ib1.[id]                   = @batchID))       /* Clustered index*/
		and ((@term           is null) or (ib1.[File_Name]           like (p1.term)))    /*[FILE_NAME_WITH_ID_CLIENT_ID_PARENT_ID]*/ 
		and ((@clientID       is null) or (ib1.ClientID               = @clientID))      /*[CLIENT_ID_WITH_ID_FILENAME_FILELOC]*/
	    and ((@currentStatus  is null) or (ib1.Current_status_Code    = @currentStatus)) /*[CURR_STATUS_CODE]*/
		and ((@assignedUserID is null) or (ib1.Current_status_UserID2 = @assignedUserID)) /*[CURRENT_STATUS_USERID2_STATUS_CODE_WITH_ID_AND_EST_HOURS] */
		and ((@workTypeID     is null) or (ib1.Type_Of_Work           = @workTypeID))
	    and (ib1.Active = 1)
    )
  ) as ib2
  --(ib.current_Status_code NOT IN (320,330,340)) /* We exclude tolarge, corrupted, deleted */  
)
,
cte_p3
as
(
	select
	      id                   = ib.id
		, [name]               = ib.[File_Name]
		, clientName           = cc.CLIENT_NAME
	    , clientID             = ib.ClientID
		
		, batchInProcess = convert(bit,(case when ib.Current_status_Code in (10,30,50,60,70,100,110) then 1 else 0 end))

		, curStatusDescription = ibs.[Status]
			
		, dateReceived         = convert(date,ib.Date_Recieved)
		, dateReceivedStr      = dbo.RPT_DATE_FMT(ib.Date_Recieved)
		, dateReceivedStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(ib.Date_Recieved)
		
		, oldestDOS            = ib.Oldest_DOS
		, oldestDOSStr         = dbo.RPT_DATE_FMT(ib.Oldest_DOS)
		, oldestDOSStrYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(ib.Oldest_DOS)		
		
		, workTypeID           = wt.id
	    , workTypeName         = wt.WorkType
		
		, lastAssignedID       = ib.Current_status_UserID2
		, lastAssignedTo       = iif((um.UserID is not null), (isnull(um.LastName,N'') + N', ' + isnull(um.FirstName,'')), N'')
	  	
		, statusDate           = convert(date,ib.Current_Status_Date)
		, statusDateStr        = dbo.RPT_DATE_FMT(ib.Current_Status_Date)
		
		, pcalConsultant       = trim(isnull(cr.first_name,'') + ' ' + isnull(cr.last_name,''))
		
		, dateSent             = convert(date,ib.Date_Sent)
				
		, fileLoc              = ib.File_Location
		, [partial]            = ib.Partial_File
		, parentID             = ib.ParentBatchID
		, estInputHrs          = ib.Estimated_Input_Hours
		, userID1              = ib.Current_status_UserID1
		, prtNum               = ib.Priority_number
		, degOfDiff            = ib.Degree_Of_Difficulty
		, notes                = ib.Notes
		
	from cte_p2                             as p2
	join dbo.INPUT_BATCHES                  as ib  on ib.id           = p2.id
	join dbo.Input_Batches_Status			as ibs on ibs.Status_Code = ib.Current_status_Code		                                                       
	join dbo.CLIENTS_Client					as cc  on cc.CLIENT_ID    = ib.ClientID
	join dbo.TYPE_OF_WORK					as wt  on wt.id           = ib.Type_Of_Work

	left join users.dbo.users			    as uu  on uu.userrid      = ib.Current_status_UserID2
	left join users.dbo.Membership	        as um  on um.UserId       = uu.userid
	left join dbo.CLIENTS_Client_Reps		as cr  on cr.id           = cc.ClientRepIDLEACurrent	
)
select top (999999999999) 
  p3.* 
from cte_p3 as p3
where ( 
      (1=1)
  and ((@showJustBatchesInProcess is null) or (p3.batchInProcess = @showJustBatchesInProcess))
) 
order by 
  p3.[name] asc

)     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_IN_PROCESS_VIEW] TO [webuser]
GO