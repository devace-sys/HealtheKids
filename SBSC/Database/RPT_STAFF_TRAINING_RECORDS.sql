USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_STAFF_TRAINING_RECORDS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_STAFF_TRAINING_RECORDS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_STAFF_TRAINING_RECORDS]()
returns @TRAININGRECORDS TABLE([Total Number of Tasks]                 decimal(5,2), 
                               [Number of Tasks Trained]               decimal(5,2),
                               [Total Number of Tasks NOT YET TRAINED] decimal(5,2),
                               [%Percentage of Tasks Trained]          decimal(5,2),
                               staffname                               varchar(100),
						       [1:1 - One on One Aide]                 decimal(5,2),
				  		       [CN - Counselor]                        decimal(5,2),
						       [HA - Health Aide]                      decimal(5,2),
						       [HS - Health Services]                  decimal(5,2),
						       [LVN - Licensed Vocational Nurse]       decimal(5,2),
						       [LMFT - Marriage & Family Therapist]    decimal(5,2),
						       [NPS - Non Public Schools or Agencies]  decimal(5,2),
						       [RN - Nurse (Registered Nurse)]         decimal(5,2),
						       [OT - Occupational Therapist]           decimal(5,2),
						       [PT - Physical Therapist]               decimal(5,2),
						       [TCM - Program Specialist]              decimal(5,2),
						       [PSY - Psychologist]                    decimal(5,2),
						       [SW - Social Worker]                    decimal(5,2),
						       [SP - Speech Language Pathologist]      decimal(5,2),
						       [Trans - Transportation]                decimal(5,2),
						       [AUD - Audiology]                       decimal(5,2),
						       Qforms                                  decimal(5,2)) 
						  
AS 
BEGIN

 /***************************************************************************    
  * RPT_STAFF_TRAINING_RECORDS.sql */    
 /**    
  * Returns a table of TRAINING_REOCRDS    
  *         
  * @return                 Table of Training Record data    
  *
  * when ever a new work type is added or deleted this methods needs to be changed, the 
  * @TRAININGRECORDS table has to be updated with the new work type
  ***************************************************************************/       

	declare @workcodes as varchar(max)
	declare @i as int 
	declare @count as int 

	declare @temptable table ([ID]                                    [smallint] IDENTITY(1,1) NOT NULL,
							  [Total Number of Tasks]                 decimal(5,2), 
							  [Number of Tasks Trained]               decimal(5,2),
							  [Total Number of Tasks NOT YET TRAINED] decimal(5,2),
							  [Percentage of Tasks Trained]           decimal(5,2),
							  staffname                               varchar(100),
							  [1-1]                                   decimal(5,2),
							  CN                                      decimal(5,2),
							  HA                                      decimal(5,2),
							  HS                                      decimal(5,2),
							  LVN                                     decimal(5,2),
							  LMFT                                    decimal(5,2),
							  NPS                                     decimal(5,2),
							  RN                                      decimal(5,2),
							  OT                                      decimal(5,2),
							  PT                                      decimal(5,2),
							  TCM                                     decimal(5,2),
							  PSY                                     decimal(5,2),
							  SW                                      decimal(5,2),
							  SP                                      decimal(5,2),
							  Trans                                   decimal(5,2),
							  AUD                                     decimal(5,2),
							  Qforms                                  decimal(5,2))
	                           
	declare @sql as nvarchar(max)

	insert into @temptable(staffname,[1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms)
	 select * from 
	(select workcode,ts.StaffName,rate from TYPE_OF_WORK as t 
		 join dbo.TRAINED_STAFF_VIEW(null,null,null,null) as ts on ts.WORKTYPE_ID = t.id)as d     
	pivot(sum(rate) for workcode in([1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms)) as p;

	select @count=COUNT(*) from @temptable
--insert row for total staff
	insert into @temptable(staffname,[1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms)
	select 'Total staff',COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),
		   COUNT(*),COUNT(*),COUNT(*),COUNT(*),COUNT(*),count(*) from @temptable
--insert row for total trained on each task
	insert into @temptable(staffname,[1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms)
	select 'Total Trained on this task',SUM([1-1]),SUM(CN),SUM(HA),SUM(HS),SUM(LVN),SUM(LMFT),SUM(NPS),SUM(RN),SUM(OT),SUM(PT),
		   SUM(tcm),SUM(psy),SUM(sw),SUM(sp),SUM(trans),sum(AUD),sum(Qforms) from @temptable where staffname != 'total staff'

	insert into @temptable(staffname,[1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms)
	select '%Trained - Work on the lowest',round(([1-1]/@count)*100,0),round((CN/@count)*100,0),round((HA/@count)*100,0),round((HS/@count)*100,0),
			round((LVN/@count)*100,0),round((LMFT/@count)*100,0),round((NPS/@count)*100,0),round((RN/@count)*100,0),round((OT/@count)*100,0),
			round((PT/@count)*100,0),round((TCM/@count)*100,0),round((PSY/@count)*100,0),round((SW/@count)*100,0),round((SP/@count)*100,0),
			round((Trans/@count)*100,0),round((AUD/@count)*100,0),round((Qforms/@count)*100,0) from @temptable where staffname = 'Total Trained on this task'
	        
	                          
	declare @count2 int
	declare @numTasksTrnd as decimal(5,2)
	select @i = 1,@count2 = COUNT(*)-3 from @temptable
	select @count = COUNT(*) from TYPE_OF_WORK


	while (@i <= @count2)
	begin                         
	select @numTasksTrnd = isnull([1-1],0)+isnull(CN,0)+isnull(HA,0)+isnull(HS,0)+isnull(LVN,0)+isnull(LMFT,0)+isnull(NPS,0)+isnull(RN,0)+
			 isnull(OT,0)+isnull(PT,0)+isnull(TCM,0)+isnull(PSY,0)+isnull(SW,0)+isnull(SP,0)+isnull(Trans,0)+isnull(AUD,0)+isnull(Qforms,0)  
	  from @temptable where ID = @i
	  
	update @temptable set [Total Number of Tasks]                 = @count,
						  [Number of Tasks Trained]               = @numtaskstrnd,
						  [Total Number of Tasks NOT YET TRAINED] = @count-@numTasksTrnd,
						  [Percentage of Tasks Trained]           = round((@numTasksTrnd/@count)*100,0)
	where id = @i
	                                                   
	set @i += 1           
	       
	end

	INSERT INTO @TRAININGRECORDS
	select [Total Number of Tasks],[Number of Tasks Trained],[Total Number of Tasks NOT YET TRAINED],
		   [Percentage of Tasks Trained],staffname,[1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,AUD,Qforms
	  from @temptable 
	        
	return
END
go
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[RPT_STAFF_TRAINING_RECORDS] TO [webuser]
GO

 


   
 





