USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SERVICE_HISTORY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SERVICE_HISTORY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SERVICE_HISTORY]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @patID          INT,
 @nameID         INT,
 @startDOS       DATETIME,
 @endDOS         DATETIME
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_SERVICE_HISTORY */    
 /**    
  * Returns service history for a given patient and date range.  Also 
  * provides a count of duplicate records.  A record is considered a duplicate
  * if there is more than one dos + proc mod combo + patient.
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @param  nameID        Service
  * @param  startDOS      Start date
  * @param  endDOS        End date
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select

  /*-------------------------------
   * Row number column taking into
   * account duplicate grouping
   *------------------------------*/

  convert(varchar(10),[Rz]) + ' - ' +
  convert(varchar(10),[Rx]) + '/' +
  convert(varchar(10),[Ry]) as [RowNum],
  
  [id],
  [dos],
  [dosFmt],
  [Practitioner],
  [Service],
  [numMins_tripsMiles]  as [MinsOrTripsMiles],
  [Procedure 1],
  [Procedure 2],
  [Reference],
  [ProcID1],
  [ProcID2],  
  [Rx],
  [Ry],
  [Rz],
  ([Ry] - 1) as [DupCnt] 
from
(
  select top (dbo.CONST_MAX_ROWS()) 
    
    [id],
    [dos],
    [dosFmt],
    [Practitioner],    
    [Service],
    [numMins_tripsMiles],
    [Procedure 1],
    [Procedure 2],
    [Reference],
    [ProcID1],
    [ProcID2],
        
    /*-------------------------------
     * x of y in row group z
     * this is x
     *------------------------------*/

    ROW_NUMBER() OVER (PARTITION BY [dos], [ProcID1] ORDER BY [id]) as Rx,

    /*-------------------------------
     * x of y in row group z
     * this is y
     *------------------------------*/

    (COUNT(1) OVER (PARTITION BY [dos], [ProcID1])) as Ry,

    /*-------------------------------
     * x of y in row group z
     * this is z
     *------------------------------*/
     
    dense_rank() over (order by [dos],[ProcID1]) as [Rz]
    
  
  from dbo.PATIENT_VIEW_SERVICE_HISTORY_CORE(@userID, 
                                             @userGroup, 
                                             @userRank, 
                                             @clientID, 
                                             @patID, 
                                             @nameID, 
                                             dbo.DATE_OR_MIN_MAX(@startDOS,-1), 
                                             dbo.DATE_OR_MIN_MAX(@endDOS,1))
  order by [dos] asc ,[id] asc, [Procedure 1] asc
) as q1

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SERVICE_HISTORY] TO [webuser]
GO   
