USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_NOTE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_NOTE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SVCNOTES_CREATE_NOTE
(
  @userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,  
  @clientID      BIGINT,
  @pracID        BIGINT,
  @groupID       BIGINT,
  @patID         BIGINT,  
  @dos           DATETIME, 
  @noteType      BIGINT,  
  @entryType     INT,
  @recordID      BIGINT OUTPUT
)

AS
BEGIN

/***************************************************************************    
 * SVCNOTES_CREATE_NOTE */    
/**    
 * Create a new service record note
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 *
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete  
 *  
 * @param   svcRecID        Service record to associate with this note
 * @returns recordID        New record id of the note
 ***************************************************************************/     

  /*============================================================
   * Init output parms
   *============================================================*/  
  
  set @recordID = null
 
  /*============================================================
   * Verify incoming parameters that are essential for proper op
   *============================================================*/  
    
  IF (@userID        IS NULL) RAISERROR ('userID is required',            11, 1)
  IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',         11, 1)    
  IF (@userRank      IS NULL) RAISERROR ('userRank is required',          11, 1)    
  
  /*============================================================
   * Lookup data
   *============================================================*/  

  declare @today              as datetime         = GETDATE()    
  declare @NoteRefKey         as uniqueidentifier = NEWID()
  
  /*============================================================
   * Create records
   *===========================================================*/
   
  insert into SvcNote_Notes 
  (
     ClientID
    ,PracID 
    ,GroupID
    ,PatID
    ,Dos
    ,NoteTypeID
    ,Created
    ,CreatedBy
    ,NoteRefKey
    ,Completed
    ,SvcRecEntryType
    ,active
    ,LastUpdated
    ,LastUpdatedBy	
  ) 
  values 
  (          
     @clientID
    ,@pracID
    ,@groupID
    ,@patID
    ,@dos
    ,@noteType
    ,@today
    ,@userID
    ,@NoteRefKey
    ,0
    ,@entryType
    ,1
    ,null
    ,null
  )	

  set @recordID = SCOPE_IDENTITY()  

 return (0)  

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCNOTES_CREATE_NOTE] TO [webuser]
GO

