USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_PRAC_PREFERENCE_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_PRAC_PREFERENCE_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTES_PRAC_PREFERENCE_SAVE */    
/**    
 * Saves preference
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank
 * @param   pracID          Practitioner id
 * @param   prefType        Preference type id
 * @param   prefNote        Note for "other" option
 ***************************************************************************/     

CREATE PROCEDURE dbo.SVCNOTES_PRAC_PREFERENCE_SAVE
(
  @userID       bigint,
  @userGroup    int,
  @userRank     int,
  @pracID       int,
  @prefType     int,
  @prefNote     varchar(8000),
    
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,
  
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),   
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
)
AS
BEGIN

  
  /*============================================================
   * Init output parameters
   *============================================================*/  
    
  SET @recordID   = 0    
  SET @spDetails  = ''    
  
  /*============================================================
   * Init our working variables
   *============================================================*/  	

  declare @today as datetime  = getdate()
  declare @currentPrefRecID as bigint
  declare @mustUseNoteType  as bigint
  
  /*============================================================
   * Quickly check to see if the practitioner can set their
   * own pref
   *============================================================*/  	

  select 
    @mustUseNoteType = MustUseNote
  from SVCNOTE_TEMPLATE_PREFERENCE_PRAC(@pracID) 
  
  /*============================================================
   * If they cannot then exit
   *============================================================*/  	

  if (@mustUseNoteType is not null) return (0)
  
  /*============================================================
   * Find record
   *============================================================*/  	

  select @currentPrefRecID = id from SVCNOTE_PRAC_PREFERENCE where PracID = @pracID and Expired_Date is null
  
  /*============================================================
   * If it exists, update the existing record to indicate we
   * are closing it out
   *============================================================*/  	

  if (@currentPrefRecID is not null)
  begin
    update SVCNOTE_PRAC_PREFERENCE set Expired_Date = @today
    where @currentPrefRecID = id
  end
    
  /*============================================================
   * Insert new record
   *============================================================*/  	
  
  insert into SVCNOTE_PRAC_PREFERENCE 
    (PracID,
     SvcNote_TypePreference,
     Note,
     SetByUser,
     Created_Date)
   values 
    (@pracID,
     @prefType,
     @prefNote,
     @userID,
     @today)
  	
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[SVCNOTES_PRAC_PREFERENCE_SAVE] TO [webuser]

GO