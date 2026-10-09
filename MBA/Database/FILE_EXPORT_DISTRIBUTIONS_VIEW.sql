USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_EXPORT_DISTRIBUTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION dbo.FILE_EXPORT_DISTRIBUTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FILE_EXPORT_DISTRIBUTIONS_VIEW] (
     @userID         bigint
   , @userGroup      int  
   , @userRank       int
   , @appName        varchar(50)
   , @clientID       bigint 
)    

RETURNS TABLE
 
 /****************************************************************************    
  * FILE_EXPORT_DISTRIBUTIONS_VIEW */    
 /**    
  * Returns distribution list for file exports app
  *
  * Note: This is for automation use only and the column names are partially
  * compatible with rptDist
  *
  * @return table 
  ****************************************************************************/                         
     
AS RETURN
(
   SELECT

		ex_f_subs.[id]    ,     
		ex_f_srcs.[name]        as   distributionSourceName  ,
        fileSourceID            as   DataSource          ,       
        ex_f_pubs.[name]        as   PublicationName     , 
        ex_f_pubs.schedule      as   Schedule            ,
        ex_f_subs.[format]      as   fileTypeRequested   ,      
        ex_f_subs.publicationID      ,
        ex_f_subs.destinationFolder  ,
        ex_f_subs.clientID                

   FROM     dbo.FILE_EXPORT_SOURCES        as ex_f_srcs
   JOIN     dbo.FILE_EXPORT_PUBLICATIONS   as ex_f_pubs  ON   ex_f_srcs.id  = ex_f_pubs.fileSourceID
   JOIN     dbo.FILE_EXPORT_SUBSCRIPTIONS  as ex_f_subs  ON   ex_f_pubs.id  = ex_f_subs.publicationID
   WHERE   (
      (1=1)
	  and ((@clientID IS NULL) or (ex_f_subs.clientID = @clientID ))
	  AND (ex_f_srcs.[active] = 1)
      AND (ex_f_pubs.[active] = 1)
      AND (ex_f_subs.[active] = 1)     
   )
)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FILE_EXPORT_DISTRIBUTIONS_VIEW] TO [webuser]
GO   
