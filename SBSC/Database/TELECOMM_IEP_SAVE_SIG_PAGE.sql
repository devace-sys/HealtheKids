USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_IEP_SAVE_SIG_PAGE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_IEP_SAVE_SIG_PAGE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_IEP_SAVE_SIG_PAGE] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT 
  , @userIP                           varchar(500)
  , @userAgent						  varchar(8000)
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @formID                           varchar(256)
  , @formData                         varchar(max)
  , @editDelReason                    VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     
  , @recordID                  BIGINT        OUTPUT  
  , @jsonData                  varchar(max)  OUTPUT
  , @spDetails                 VARCHAR(8000) OUTPUT)     

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_IEP_SAVE_SIG_PAGE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                 as datetime 
declare @tranOpen              as bit      = 0
declare @formDataRecID         as bigint   = null

declare @formQuestions         as nvarchar(max)
declare @formAnswers           as varchar(max)
declare @purposeSpecificData   as varchar(max)
declare @clientID              as bigint
declare @patID                 as bigint
declare @meetingDate           as date
declare @iepFormType           as bigint
declare @fileName              as varchar(512)
declare @teleCommSessionID     as bigint
declare @storedFileUserID      as bigint
declare @storedFileUserGroup   as bigint
declare @storedFileUserRank    as bigint
declare @serverSessionID       as varchar(256)

declare @clientName            as nvarchar(1000)
declare @iepDateStr            as varchar(50)
declare @patName               as nvarchar(256)
declare @patDOBStr             as varchar(50)
declare @participantFormSigs   TABLE (
									  [idx]	                bigint
									, [title]	            varchar(256)
									, [signature]			varchar(281)
									, [dateSignedStr]		varchar(50)
									, [signed]              bit
									, [name]				varchar(256)
									, [signatureBase64]		varchar(max)
							    )
declare @participants			  as varchar(max)
declare @headerAnswersJSON		  as varchar(max)
								  
declare @pgSigSpecificData        as varchar(max)

declare @pgPrimarySigName         as varchar(512)
declare @pgPrimaryName            as varchar(256)
declare @pgPrimarySigRecordedOn   as varchar(100)
declare @pgPrimarySigRole         as varchar(512)
declare @pgPrimarySigSigned       as varchar(512)
declare @pgPrimarySigImgBase64    as varchar(max)

declare @pgSecondarySigName       as varchar(512)
declare @pgSecondaryName          as varchar(256)
declare @pgSecondarySigRecordedOn as varchar(100)
declare @pgSecondarySigRole       as varchar(512)
declare @pgSecondarySigSigned     as varchar(512)
declare @pgSecondarySigImgBase64  as varchar(max)

declare @pgLeaBopSigName          as varchar(512)
declare @pgLeaBopSigRecordedOn    as varchar(100)
declare @pgLeaBopSigRole          as varchar(512)
declare @pgLeaBopResponse         as varchar(512)
declare @pgLeaBopSignatureBase64  as varchar(max)
declare @footerAnswersJSON        as varchar(max)

/*============================================================
 * Init
 *============================================================*/  

set @recordID  = 0
set @today     = GETDATE()    
set @spDetails = ''
set @tranOpen  = 0
set @jsonData  = ''

			  
BEGIN TRY    

/* Note: Keep this in synch with the Spedmon.TeleCommSessionIEPSigPageDocData class */

set @jsonData = '{"fileName":""'
              + ',"formQuestionsJSON":""'
              + ',"formAnswersJSON":""'
			  + ',"clientIdStr":""'
              + ',"patIdStr":""'
              + ',"teleCommSessionID":0'
			  + ',"storedFileUserID":0'		      	  
			  + ',"storedFileUserGroup":0'
			  + ',"storedFileUserRank":0'
			  + ',"teleCommServerSessionID":""'
			  + ',"headerAnswersJSON":""'
			  + ',"footerAnswersJSON":""'
			  + '}'


/*============================================================
 * Verify parameters
 *============================================================*/  
        
BEGIN TRANSACTION
set @tranOpen = 1

/*============================================================
 * Save "final" form data
 *============================================================*/  

exec users.dbo.TELECOMM_SESSION_SAVE_FORM_DATA_CORE
    @userID  
  , @userGroup
  , @userRank 
  , @userIP  
  , @userAgent 
  , @roomID   
  , @email  
  , @pin  
  , @formID 
  , @formData 
  , 1 /* Data finalized */
  , @editDelReason
  , @validateRec 
  , @saveType
  , @recID   
  , @MsgNoRec 
  , @MsgNoEdit
  , @MsgDupRec 
  , @MsgDataError 
  , @MsgNotActive 
  , @formDataRecID OUTPUT  
  , @spDetails     OUTPUT

/*============================================================
 * Generate signature page data
 *============================================================*/  

/*-------------------------------    
 * Get the form data we just saved
 *------------------------------*/  
 
select top 1   

    @clientID              = ts.clientID
  , @teleCommSessionID     = ts.id
  , @formQuestions         = ts.formsJSON
  , @formAnswers           = tsfd.formData
  , @meetingDate           = ts.meetingDate
  , @purposeSpecificData   = ts.purposeSpecificData
  , @storedFileUserID      = coalesce (ts.lastModifedBy, ts.createdBy)
  , @serverSessionID       = ts.serverSessionID
  
from users.dbo.TELECOMM_SESSIONS_FORM_DATA as tsfd 
join users.dbo.TELECOMM_SESSIONS           as ts  on ts.id = tsfd.telecommSessionID

where ((tsfd.id = @formDataRecID))

/*-------------------------------    
 * Extract the patient id 
 * and iep form type
 *------------------------------*/  

select top 1
    @patID       = t1.patID
  , @iepFormType = t1.iepFormType
from dbo.TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA(@purposeSpecificData) as t1

/*-------------------------------    
 * Get rest of userInfo 
 *------------------------------*/  

select top 1
    @storedFileUserGroup = ua.userGroupID 
  , @storedFileUserRank  = ua.userRank
from users.dbo.USERS_DATA_CORE(null,null,null,null,@storedFileUserID) as ua

/*-------------------------------    
 * Get participant attendance
 *------------------------------*/  
 
INSERT INTO @participantFormSigs 
 select 
     ts.[idx]
    ,ts.[title]
    ,ts.[signature]
    ,ts.[dateSignedStr]
	,ts.[signed]
	,ts.[name]
	,signatureBase64 = (select signature_base64
						FROM OPENJSON(ts.sigAdditionalData) 
						WITH (
							signature_base64       varchar(max)  '$."attendanceroster-signatureImgBase64"'								
						) as t1
						)
 from users.dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE (@teleCommSessionID, 'attendanceroster') as ts


set @participants = (
  
  select 
     tss.idx
    ,tss.signature
    ,tss.title
    ,tss.dateSignedStr
	,tss.signatureBase64
  from @participantFormSigs as tss
  where (tss.idx > 0)  
  order by tss.idx asc  
  FOR JSON AUTO
)


/* Undo escapes */

select @participants = replace(@participants,'\','')

/*-------------------------------    
 * Get client info
 *------------------------------*/  

select top 1 
  @clientName = cca.CLIENT_NAME
from dbo.CLIENTS_Client as cca 
where (cca.CLIENT_ID = @clientID)

set @iepDateStr = dbo.RPT_DATE_FMT(@meetingDate)

/*-------------------------------    
 * Get patient info
 *------------------------------*/  

select top 1
  @patName   = trim(isnull(pap.FIRST_NAME,N'')) + N' ' + trim(isnull(pap.LAST_NAME,N''))
, @patDobStr = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
from dbo.PATIENTS_Patient as pap 
where pap.PATIENT_ID = @patID

/*-------------------------------    
 * Get primary parent/guardian 
 * IEP signature
 *------------------------------*/  

select top 1
    @pgPrimarySigName       = tss.[name]
  , @pgPrimaryName          = tss.[name]
  , @pgPrimarySigRecordedOn = tss.dateSignedStr
  , @pgSigSpecificData      = tss.sigAdditionalData
from users.dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE (@teleCommSessionID, 'pgiepapprovalprimary') as tss
order by 
  tss.signatureID desc

select
     @pgPrimarySigRole      = isnull(t1.parent_signature_role,      '')
   , @pgPrimarySigSigned    = isnull(t1.parent_signature_signed_iep,'')
   , @pgPrimarySigImgBase64 = isnull(t1.parent_signature_img_base64,'')
FROM OPENJSON(@pgSigSpecificData) 
WITH (
     parent_signature_role         varchar(512)  '$."parent-role"'
   , parent_signature_signed_iep   varchar(512)  '$."parent-signature-primary-signed-iep"'
   , parent_signature_img_base64   varchar(max)  '$."parent-signature-primary-signatureImgBase64"'
) as t1

/*-------------------------------    
 * Get secondary parent/guardian 
 * IEP signature
 *------------------------------*/  

select top 1
     @pgSecondarySigName       = tss.[name]
   , @pgSecondaryName          = tss.[name]
   , @pgSecondarySigRecordedOn = tss.dateSignedStr
   , @pgSigSpecificData        = tss.sigAdditionalData
from users.dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE (@teleCommSessionID, 'pgiepapprovalsecondary') as tss
order by 
  tss.signatureID desc


select
     @pgSecondarySigRole      = isnull(t1.parent_signature_role,      '')
   , @pgSecondarySigSigned    = isnull(t1.parent_signature_signed_iep,'')
   , @pgSecondarySigImgBase64 = isnull(t1.parent_signature_img_base64,'')
FROM OPENJSON(@pgSigSpecificData) 
WITH (
     parent_signature_role         varchar(512)  '$."parent-role"'
   , parent_signature_signed_iep   varchar(512)  '$."parent-signature-secondary-signed-iep"'
   , parent_signature_img_base64   varchar(max)  '$."parent-signature-secondary-signatureImgBase64"'
) as t1

/*-------------------------------    
 * Get LEA Billing Options 
 * program consent parental
 * response
 *------------------------------*/  

select top 1
     @pgLeaBopSigName       = tss.[name]
   , @pgLeaBopSigRecordedOn = tss.dateSignedStr
   , @pgSigSpecificData     = tss.sigAdditionalData
from users.dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE (@teleCommSessionID, 'leaboppgconsent') as tss
order by 
  tss.signatureID desc


select
     @pgLeaBopSigRole         = isnull(t1.parent_signature_role,'')
   , @pgLeaBopResponse        = isnull(t1.parent_response,'')
   , @pgLeaBopSignatureBase64 = isnull(t1.parent_signature_base64,'')
FROM OPENJSON(@pgSigSpecificData) 
WITH (
     parent_signature_role         varchar(512)  '$."parent-role"'
   , parent_response               varchar(512)  '$."lea-bop-consent-parent-response"'
   , parent_signature_base64       varchar(max)  '$."lea-bop-consent-parent-signatureImgBase64"'

) as t1

/*-------------------------------    
 * Check if sigs are complete
 * then generate the electronic
 * signature text for footer
 *------------------------------*/  

declare @pgPrimaryIsSigned   as bit = 0
declare @pgSecondaryIsSigned as bit = 0
declare @pgLeaBopIsSigned    as bit = 0

if (@pgPrimarySigSigned = 'signed')
begin
  set @pgPrimarySigName = 'Electronically signed by ' + @pgPrimarySigName
  set @pgPrimaryIsSigned = 1
end
else
begin
  set @pgPrimarySigName       = ''
  set @pgPrimarySigRecordedOn = ''
  set @pgPrimarySigRole       = ''
  set @pgPrimaryIsSigned      = 0
end

if (@pgSecondarySigSigned = 'signed')
begin
  set @pgSecondarySigName = 'Electronically signed by ' + @pgSecondarySigName
  set @pgSecondaryIsSigned = 1
end
else
begin
  set @pgSecondarySigName       = ''
  set @pgSecondarySigRecordedOn = ''
  set @pgSecondarySigRole       = ''
  set @pgSecondaryIsSigned      = 0
end

set @pgLeaBopIsSigned = 1
if (@pgLeaBopResponse = 'approved')
begin
  set @pgLeaBopSigName = 'Electronically approved by ' + @pgLeaBopSigName
end
else if (@pgLeaBopResponse = 'declined')
begin 
  set @pgLeaBopSigName = 'Electronically declined by ' + @pgLeaBopSigName
end
else
begin
  set @pgLeaBopSigName       = ''
  set @pgLeaBopSigRecordedOn = ''
  set @pgLeaBopSigRole       = '' 
  set @pgLeaBopIsSigned      = 0
end

/*-------------------------------    
 * Build the file name
 *------------------------------*/  

set @fileName = 'IEP-SIGNATURES' 

select top 1
  @fileName = @fileName 
            + '-' 
			+ isnull(t1.name,'')
from dbo.TELECOMM_IEP_TYPES as t1
where 
  (t1.id = @iepFormType)


set @fileName = @fileName 
              + '-' 
			  + convert(varchar,upper(replace(@patName,N' ',N'-')))
              + '-' 
			  + CONVERT(VARCHAR(4), DATEPART(YEAR, @meetingDate))
              + RIGHT('00' + CONVERT(VARCHAR(2), DATEPART(MONTH, @meetingDate)), 2)
              + RIGHT('00' + CONVERT(VARCHAR(2), DATEPART(DAY,   @meetingDate)), 2)			 
			  + '-' 
			  + convert(varchar,@formDataRecID)
			  
set @headerAnswersJSON = '{'
                       + '"clientName":"'   + isnull(@clientName,'') + '"'
			           + ',"patName":"'     + isnull(@patName,'')    + '"'
		               + ',"patDOBStr":"'   + isnull(@patDOBStr,'')  + '"'
                       + ',"iepDateStr":"'  + isnull(@iepDateStr,'') + '"'					   						   				   
                       + ',"participantRosterJSON":"' + isnull(@participants,'') +  '"'              
			           + '}'

set @footerAnswersJSON = '{'
                       + '"parent-signature-primary-signature":'             + '"' + isnull(@pgPrimarySigName,'')         + '"'
                       + ',"parent-signature-primary-date-signed":'          + '"' + isnull(@pgPrimarySigRecordedOn,'')   + '"'
                       + ',"parent-signature-primary-role":'                 + '"' + isnull(@pgPrimarySigRole,'')         + '"'
                       + ',"parent-signature-primary-signed-iep":'           + '"' + isnull(@pgPrimarySigSigned,'')       + '"'
                       + ',"parent-signature-primary-signatureImgBase64":'   + '"' + isnull(@pgPrimarySigImgBase64,'')    + '"'
																		     
                       + ',"parent-signature-secondary-signature":'          + '"' + isnull(@pgSecondarySigName,'')       + '"'
                       + ',"parent-signature-secondary-date-signed":'        + '"' + isnull(@pgSecondarySigRecordedOn,'') + '"'
                       + ',"parent-signature-secondary-role":'               + '"' + isnull(@pgSecondarySigRole,'')       + '"'
                       + ',"parent-signature-secondary-signed-iep":'         + '"' + isnull(@pgSecondarySigSigned,'')     + '"'
                       + ',"parent-signature-secondary-signatureImgBase64":' + '"' + isnull(@pgSecondarySigImgBase64,'')  + '"'

					   + ',"lea-bop-consent-parent-signature":'              + '"' + isnull(@pgLeaBopSigName   ,'')       + '"'
					   + ',"lea-bop-consent-parent-date-signed":'            + '"' + isnull(@pgLeaBopSigRecordedOn,'')    + '"'
					   + ',"lea-bop-consent-parent-role":'                   + '"' + isnull(@pgLeaBopSigRole,'')          + '"'
					   + ',"lea-bop-consent-parent-response":'               + '"' + isnull(@pgLeaBopResponse,'')         + '"'
                       + ',"lea-bop-consent-parent-signatureImgBase64":'     + '"' + isnull(@pgLeaBopSignatureBase64,'')  + '"'
					   + '}'

set @jsonData = '{"fileName":"' + @fileName + '"'
              + ',"formQuestionsJSON":"'  + STRING_ESCAPE (isnull(@formQuestions, ''),'JSON') + '"'
              + ',"formAnswersJSON":"'    + STRING_ESCAPE (isnull(@formAnswers  , ''),'JSON') + '"'
			  + ',"clientIdStr":"'        + convert (varchar,isnull(@clientID,0))             + '"'
              + ',"patIdStr":"'           + convert (varchar,isnull(@patID,0))                + '"'			  
              + ',"teleCommSessionID":'   + convert (varchar,isnull(@teleCommSessionID,0))		      	  
			  + ',"storedFileUserID":'    + convert (varchar,isnull(@storedFileUserID,0))		      	  
			  + ',"storedFileUserGroup":' + convert (varchar,isnull(@storedFileUserGroup,0))
			  + ',"storedFileUserRank":'  + convert (varchar,isnull(@storedFileUserRank,0))
			  + ',"teleCommServerSessionID":"' + STRING_ESCAPE (isnull(@serverSessionID,''),'JSON') + '"'
			  + ',"headerAnswersJSON":"'       + STRING_ESCAPE (isnull(@headerAnswersJSON, ''),'JSON')+ '"'			 			  
			  + ',"footerAnswersJSON":"'       + STRING_ESCAPE (isnull(@footerAnswersJSON, ''),'JSON')+ '"'			 			  
			  + '}'

IF (@validateRec = 1)    
BEGIN     
  
  -- Test if nobody has signed attendance roster
  if NOT EXISTS(SELECT * FROM @participantFormSigs s WHERE s.signed = 1)
  begin
    -- if test fails
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'No one has signed the attendance roster', dbo.CONST_RET_WARN())
  end
    
  -- Test if no parent has signed the IEP (primary and/or secondary).... if at least one slot is signed then its ok

  if ((@pgPrimaryIsSigned = 0) and (@pgSecondaryIsSigned = 0))
  begin
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'Parent(s) have not signed the IEP', dbo.CONST_RET_WARN())
  end
  
  -- Test if LEA BOP has beeen signed

  if (@pgLeaBopIsSigned = 0)
  begin
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'LEA BOP consent form has not been signed', dbo.CONST_RET_WARN())
  end

  -- Test if Form Questions exist
  /*
  if (trim(isnull(@formQuestions,'')) = '')
  begin
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'No form questions have been provided', dbo.CONST_RET_WARN())
  end
  */

  -- Test if Form Answers exist

  if (trim(isnull(@formAnswers,'')) = '')
  begin
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'No form answers have been provided', dbo.CONST_RET_WARN())
  end

   -- Test if parent has signed the iep but not the attendance
  
  if (@pgPrimaryIsSigned = 1)
  begin
	  if (NOT EXISTS(SELECT * FROM @participantFormSigs s WHERE s.signed = 1 and s.name = @pgPrimaryName))
	  begin
	     SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'Primary parent/guardian has signed the IEP but not the attendance roster', dbo.CONST_RET_WARN())
	  end
  end

  if ((@pgSecondaryIsSigned = 1) and (NOT EXISTS (SELECT * FROM @participantFormSigs s WHERE s.signed = 1 and s.name = @pgSecondaryName)))
  begin
      SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'Secondary parent/guardian has signed the IEP but not the attendance roster', dbo.CONST_RET_WARN())
  end

END

set @tranOpen = 0

COMMIT TRANSACTION

RETURN(0)    

END TRY    
BEGIN CATCH    
   
if (@tranOpen  = 1) ROLLBACK TRANSACTION

  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
         
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_IEP_SAVE_SIG_PAGE] TO [webuser]
GO
