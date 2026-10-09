USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @pracID         INT,
 @patID          INT,
 @dosSvcs        varchar(1000),
 @isIEP          BIT,
 @nameID         INT,
 @excludeRecID   BIGINT,
 @referenceLinkURL varchar(1000)
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_SERVICE_CHECK_DUPS */    
 /**    
  * Checks dups
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(
  select

    [Record],
    [Reference] = ReferenceURL


 /*-------------------------------
  * Retrieve service history
  * for the given patient for last
  * 13 months
  *------------------------------*/

from dbo.PATIENT_VIEW_SERVICE_HISTORY_13M(@userID, 
                                        @userGroup, 
                                        @userRank, 
                                        @clientID, 
                                        @patID, 
                                        @nameID,
                                        @excludeRecID,
                                        @referenceLinkURL) as sh
join                                         
(
  select 
    ds.date as [dos], 
    q1.procID

   /*-------------------------------
    * Generate table of dates
    * from @dosMulti 
    *------------------------------*/

  from dbo.MULTI_DATE_PARSE(@dosSvcs,',')  as ds
  cross apply
  (
    /*-------------------------------
     * Generate potential procID
     * taking into account the
     * - practitioner group
     * - patient age on DOS
     * - plan type
     * - service requested (nameID)
     *------------------------------*/
     
    select 
      procID
    from SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP (@clientID,
                                            @pracID,
                                            @patID,
                                            ds.date,
                                            @isIEP,
                                            @nameID,
                                            0,
                                            null,
                                            1,
											null) as sv
   ) as q1

 /*-------------------------------
  * Look for potential duplicates
  *------------------------------*/

) as q2 on q2.dos = sh.dos and q2.procID = sh.procID1


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS] TO [webuser]
GO   
