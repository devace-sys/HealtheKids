USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAFF_TrainedandAvailable_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STAFF_TrainedandAvailable_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[STAFF_TrainedandAvailable_VIEW]    
(
 @startdate    datetime,
 @date         datetime,
 @workType     int,
 @estHours     float)
   
 
 RETURNS @availableStaff TABLE(ID                 BIGINT,
                               NAME               VARCHAR(100),
                               RATING             VARCHAR(100),
                               RATE               DECIMAL(3,2),
                               SHIFTS             VARCHAR(100),
                               DAYHOURS           FLOAT,
                               WEEKHOURS          FLOAT,
                               ASSIGNEDHOURS      FLOAT)
 
 /***************************************************************************    
  * STAFF_TrainedandAvailable_VIEW */    
 /**    
  * Returns a table of STAFF_PROMISED_HOURS that match the given parameters    
  *    
  * @param  workTypeID      staff ID  
  * @param  startdate       startdate of the work week     
  * @return                 Table of Trained and Available staff    
  ***************************************************************************/     
  
AS BEGIN

if (@date is not null and @startdate is null)
select @startdate = WEEKSTART_DATE from dbo.STAFF_PROMISED_HOURS where day = @date 
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 insert into @availableStaff
   SELECT spv.staff_id  as id,
          spv.name as name,
          tr.RATING,
		  tr.RATE,      
          isnull(SHIFT_1,'')+','+ isnull(SHIFT_2,'')+','+ isnull(SHIFT_3,'') as Shifts,
          spv.DAYHOURS,   
          spv.WeekHours,      
          isnull(spv.AssignedHours,0)
     from STAFF_PROMISED_HOURS_VIEW(null,null,@startdate,@date,null,null) spv
   left join dbo.TRAINED_STAFF as ts          on ts.staff_ID = spv.staff_id
											 and ts.trained = 1
											 and ((@workType is null) or (ts.WORKTYPE_ID = @workType))
   left join  dbo.STAFF_TRAINING_RATES as tr  on ts.Rating = tr.RATING_ID                             
    where (isnull(spv.WeekHours,0) - isnull(spv.AssignedHours,0) > 0)
    order by spv.WeekHours desc
    
return                      
end
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[STAFF_TrainedandAvailable_VIEW ] TO [webuser]
GO
