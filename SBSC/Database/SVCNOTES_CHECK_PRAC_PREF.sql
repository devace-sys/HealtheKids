USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CHECK_PRAC_PREF') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CHECK_PRAC_PREF
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SVCNOTES_CHECK_PRAC_PREF
(
  @pracID                 INT,  
  @inputPracID            INT    OUTPUT,
  @mustUseNoteType        BIGINT OUTPUT,
  @currentTemplateID      BIGINT OUTPUT,
  @mustSetAPreference     BIT    OUTPUT,
  @canChangePreference    BIT    OUTPUT,
  @currentPreferenceID    BIGINT OUTPUT,
  @typePrefID             BIGINT OUTPUT, /* What the note type is either from template or preference */
  @prefNote               VARCHAR(8000) OUTPUT,
  @shortPrefDesc          VARCHAR(8000) OUTPUT,
  @longPrefDesc           VARCHAR(8000) OUTPUT,
  @mustUseReason          VARCHAR(8000) OUTPUT,
  @useFormattedNotes      BIT    OUTPUT  /* Use formatted notes flag either from template or preference */
)

AS
BEGIN

/***************************************************************************    
 * SVCNOTES_CHECK_PRAC_PREF */    
/**    
 * Checks service note requirements for given practitioner 
 *    
 * @param   pracID               Practitioner id to check
 *
 * @returns inputPracId          Practitioner id stored
 * @returns mustUseNoteType      Service note type that must be used
 * @returns mustSetAPreference   0 = Practitioner does not need to set a preference
 *                               1 = Practitioner must set a preference
 *
 * @returns canChangePreference  0 = Practitioner can change their preference
 *                               1 = Practitioner cannot change their preference
 * @returns typePrefID           Service note type practitioner is using
 * @returns prefNote             The text the practitioner provided for "other"
 * @returns shortPrefDesc        The short description field for the note type
 * @returns longPrefDesc         The long description field for the note type
 * @returns mustUseReason        If a practitioner MUST use a note type this is the reason why
 * @returns useFormattedNotes    Practitioner is using formatted notes
 ***************************************************************************/     

  /*============================================================
   * Init output parms
   *============================================================*/  
  
  set @inputPracID           = 0
  set @mustUseNoteType       = 0
  set @currentTemplateID     = 0
  set @mustSetAPreference    = 0  
  set @canChangePreference   = 0
  set @currentPreferenceID   = 0
  set @typePrefID            = 0
  set @useFormattedNotes     = 0
  set @prefNote              = ''
  set @shortPrefDesc         = ''
  set @longPrefDesc          = ''
  set @mustUseReason         = ''
  
  /*============================================================
   * Verify incoming parameters that are essential for proper op
   *============================================================*/  
    
  IF (@pracID IS NULL) RAISERROR ('pracID is required', 11, 1)    

  /*============================================================
   * Determine if practitioner MUST use a given note format   
   *============================================================*/  
  
  select 
    @mustUseNoteType   = MustUseNote,
    @currentTemplateID = TemplateID
  from SVCNOTE_TEMPLATE_PREFERENCE_PRAC(@pracID) 
  
  /*============================================================
   * Determine what note format the practitioner is using
   *============================================================*/  
               
  select 
    @inputPracID         = inputPracID,
    @typePrefID          = typePrefID,
    @currentPreferenceID = PreferenceID,
    @currentTemplateID   = TemplateID,
    @useFormattedNotes   = UseFormattedNotes,
    @shortPrefDesc       = isnull(ShortPrefDesc,''),
    @longPrefDesc        = isnull(LongPrefDesc,''),
    @mustUseReason       = isnull(Reason_Template_applied,''),
    @prefNote            = isnull(prac_note,'')
  from 
    dbo.SVCNOTE_PRAC_PREF_VALUE_VIEW (@pracID)        
 
  /*============================================================
   * If we do not have a template or preference then
   * the practitioner must choose a preference and they can
   * change the preference
   *============================================================*/  
  
  if ((@mustUseNoteType is null) and ((@typePrefID is null) and (@useFormattedNotes is null)))
  begin
    set @mustUseNoteType     = 0
    set @mustSetAPreference  = 1
    set @canChangePreference = 1
    set @currentPreferenceID = 0
    set @typePrefID          = 0
    set @useFormattedNotes   = 0
    set @currentTemplateID   = 0
    set @currentPreferenceID = 0
    return (0)
  end
    
  /*============================================================
   * If there is a template already set then the practitioner
   * does not need to set a preference and they cannot set or
   * change what format of notes they can use
   *============================================================*/  

  if ((@mustUseNoteType is not null) and ((@typePrefID is not null) and (@useFormattedNotes is not null)))
  begin
    set @mustSetAPreference    = 0
    set @canChangePreference   = 0
    set @currentPreferenceID   = 0
    return (0)
  end
  
  /*============================================================
   * If there is no template and we have data on what note format
   * the practitioner has set as their preference then the 
   * practitioner does not need to set a preference but they
   * can change it
   *============================================================*/  

  if ((@mustUseNoteType is null) and ((@typePrefID is not null) and (@useFormattedNotes is not null)))
  begin
    set @mustUseNoteType       = 0
    set @mustSetAPreference    = 0
    set @canChangePreference   = 1
    set @currentTemplateID     = 0
    return (0)
  end


  /*============================================================
   * If we reach this point there is a problem with the data   
   *============================================================*/  

  RAISERROR ('Data error', 11, 1)    
  
  /*============================================================   
   * Done
   *============================================================*/  

  return (0)  

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCNOTES_CHECK_PRAC_PREF] TO [webuser]
GO

