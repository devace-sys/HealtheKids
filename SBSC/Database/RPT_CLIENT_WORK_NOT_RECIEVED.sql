USE [SPEDMON]
GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLIENT_WORK_NOT_RECIEVED') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLIENT_WORK_NOT_RECIEVED
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[RPT_CLIENT_WORK_NOT_RECIEVED]     
(@date DATETIME)     
 RETURNS  @clienttable TABLE  (
                               Client_Name       nvarchar(max),
                               MonthYear         varchar(20),
							   District_Rep      nvarchar(100),                      
                               [%Submitted]      varchar(5),                              
                               Revenue           money,
                               [%notSubmitted]   varchar(5),
                               LostRevenue       money) AS

/***************************************************************************    
 * RPT_CLIENT_WORK_NOT_RECIEVED */    
/**    
 * Returns a table.    
 *    
 * @param  date            date    
 * @return                 Table of data    
 ***************************************************************************/     

BEGIN
/*------------------------------------
 * Temp table to store the client info.
 *-------------------------------------*/                      

declare @temp table (id int identity(1,1) primary key,
                     client_id     bigint,
                     client_name   nvarchar(max),
                     District_Rep  nvarchar(100))
insert into @temp
 select CLIENT_ID,CLIENT_NAME,cr.first_name +', '+last_name
   from CLIENTS_Client cc join 
        CLIENTS_Client_Reps cr on cc.ClientRepIDLEACurrent = cr.id  
   where LEA = 1 and CLIENT_ID != 112   
 
/*------------------------------------
 * Declare variables 
 *-------------------------------------*/                            
 declare @notsubprcntg     varchar(5)
 declare @percentage       varchar(5)
 declare @p                decimal(10,2)
 declare @clientid         int
 declare @numactiveprac    decimal(10,2)
 declare @numpracsubmitted decimal(10,2)
 declare @clientname       nvarchar(max) 
 declare @count            int
 declare @revenue          money
 declare @lostrevenue      money
 declare @currentID        int
 declare @startdate        datetime
 declare @enddate          datetime
 declare @mYear            varchar(20)
 declare @districtRep      varchar(50)

/*---------------------------------------------------------------
 * Get the first day of month,last day of month and monthYear from 
 * @date into startdate,enddate and mYear variables respectively.
 *---------------------------------------------------------------*/ 
select @startdate = startDate,@enddate = endDate,@mYear = monthYear 
  from DATE_RANGE_SPLIT(@date,@date)


set @currentID = 1

select @count  = COUNT(*) from @temp

while (@currentID <= @count)                        
begin
 
/*------------------------------------------
 * Loop through each row in client info table 
 *------------------------------------------*/  
 
select @clientid = client_id,@clientname = client_name,@districtRep = District_Rep from @temp where id = @currentID
   
 -- clean up the variables used in calculations
    set @revenue          = 0
    set @lostrevenue      = 0
    set @numactiveprac    = 0
    set @notsubprcntg     = ''
    set @percentage       = ''
    set @p                = 0
    set @numpracsubmitted = 0
    	
	select @revenue = sum(AMOUNT_PAID * EDSPERCENT) from
	       CLAIM_Claim               as c    
      join CLAIM_Claim_Adjudication  as ca on ca.CLAIM_ID = c.CLAIM_ID    
                                          and c.service_date between @startdate and @enddate                                                                                           
      where CLIENT_ID = @clientid 
	 
/*------------------------------------
 * Get the number of active practitioners
 * for each client 
 *-------------------------------------*/    
 
	  select @numactiveprac = count(*)
	  from PRACTITIONER_Practitioner pp join
	       PRACTITIONER_Groups pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID join
	       GROUP_GROUP         gr on gr.group_ID        = pg.GROUP_ID
                                 and gr.group_Type      < 3 
                                 and (gr.GROUP_ID      <> 152) join 	                             
		   PRACTITIONER_Client pc on pc.PRACTITIONER_ID = pp.PRACTITIONER_ID
		                         and pc.CLIENT_ID       = @clientid
		                         and (pc.DATE_START is null or pc.DATE_START <= @startdate)
		                         and (pc.DATE_END   is null or pc.DATE_END   >= @enddate)
		                         and pp.ACTIVE          = 1 
		                         and pp.CONCAT_NAME    != 'STATE, ADJUSTMENT'
		                         
 if (@numactiveprac = 0) 
 begin
  set @currentid += 1
  continue		                        
 end       
/*------------------------------------
 * Get the number of practitioners who
 * submitted work in the given date range
 *-------------------------------------*/ 
	                          
	select @numpracsubmitted = count(distinct [practitioner id])  
	  from dbo.RPT_SERVICE_RECORD_TATTLE_CORE(@clientid,null,null,@startdate,@enddate)   
	                                         
    set @numpracsubmitted = @numactiveprac - @numpracsubmitted   
/*------------------------------------
 * Calculate the percentage of practitioners
 * who submitted work. 
 *-------------------------------------*/     
	 
	if (@numactiveprac > 0)
	 set @p = (@numpracsubmitted/@numactiveprac)*100
	else
	 set @p = 100 
	 
    set @p            = round(@p,0)
    set @percentage   = CONVERT(varchar,floor(@p))
    set @percentage   = @percentage + '%' 
    set @notsubprcntg = CONVERT(varchar,floor(100 - @p))
    set @notsubprcntg = @notsubprcntg + '%'
    
    if ((@p>0) and (@revenue >= 0))
      set @lostrevenue  = (@revenue/@p) * (100 - @p)
    else
      set @lostrevenue = 0
 
    insert into @clienttable values (@clientname,@mYear,@districtRep,@percentage,@revenue,@notsubprcntg,@lostrevenue)
 
    set @percentage = ''
 
 set @currentID = @currentID + 1  
end 
 
/*------------------------------------
 * Insert a row for Grand total
 *-------------------------------------*/   
   
 select @revenue          = sum(revenue),
        @lostrevenue      = sum(lostrevenue) 
   from @clienttable
  
 insert into @clienttable values ('zzGrand Total','','','',@revenue,'',@lostrevenue)
 
RETURN

END 
                              
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLIENT_WORK_NOT_RECIEVED] TO [webuser]
GO   
