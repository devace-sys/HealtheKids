USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_CAN_USER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STORED_FILE_CAN_USER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[STORED_FILE_CAN_USER_VIEW] (
    @userID                          bigint
  , @userGroup                       int
  , @userRank                        int 
  , @userRole                        bigint  
  , @userClientID                    bigint
  , @storedFileServiceClassPartID    bigint
  , @userGroupServiceClassNameID     bigint
  , @userPracID                      bigint 
  , @fileRecID                       bigint
  , @fileUserID                      bigint
  , @fileUserPracID                  bigint
  , @fileClientID                    bigint  
  , @filePracID                      bigint
  , @filePatID                       bigint
  , @fileGroupIdDisp                 bigint 
  , @assumeUserCanView               bit 
  , @fileClassID                     bigint
  , @isConfidentialPracticeFile      bit
  , @okToShareFileWithParentGuardian bit
  , @okToShareFileWithPatient        bit
) 
RETURNS BIT AS     
BEGIN    

/*###########################################################################
  #                         Bypass rules check
  #             Bypass this function and its rules checks?
  ###########################################################################*/

if (isnull(@assumeUserCanView,0) = 1) return 1

/*###########################################################################
  #                    Basic File Rule For ANY FILE
  #                   Author can see their own record
  #       Applies to all users and all files including confidential
  ###########################################################################*/
    
if (@userID = @fileUserID) return 1  /* File was created by user then they can see the record */

/*###########################################################################
  #
  #                    Confidential Practice File Rules
  #
  #           For records that the author has marked Confidential
  #  If the record (file) is confidential then it will only be viewable by: 
  #
  #  1. The records author
  #  2. Their assigned supervisior (if applicable)
  #
  ###########################################################################*/

if (@isConfidentialPracticeFile = 1)
begin

  /* If we reach this point then the record was not authored by the user (otherwise they 
   * would already have access) so we have to perform user group specific checks
   * as each user group has different rules. */

  /*------------------------------------*/
  /* Client Users                       */ 
  /*------------------------------------*/  

  if (@userGroup = 1) 
  begin
  
    /* If file is not associated with users client ID then access denied */    

    if (@userClientID != @fileClientID) return 0

    /* If the user is a practitioner */  

    if (@userRole = 7) 
    begin 

      /* Determine if the user is the record authors direct assigned supervisor */
      
	  if (@fileUserPracID is null) return 0
	  if (@userPracID     is null) return 0

	  /* Find an active supervision record */
      
	  if exists (
        select top 1
          ppdss.ID 
        from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss 
        where (
            ((ppdss.active = 1) and (ppdss.SUPERVISED_PRAC_ID = @fileUserPracID)) /* Use index */
        and (ppdss.SUPERVISING_PRAC_ID = @userPracID)
		and (ppdss.SHARE_NOTES = 0)
		and (ppdss.relationshipTypeID = 10)
        --and (ppdss.SHARE_NOTES = 1)       
	    )  
      )
	  begin
	    return 1
      end

	  if exists (
        select top 1    
          t0.SUPERVISED_PRAC_ID 
        from dbo.PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE (@userClientID, @userPracID, @fileUserPracID) as t0
        where (
              ((t0.departmentHeadsCanViewSupervisedPracsSvcRecs = 1) and (t0.departmentHeadsCanViewSupervisedPracsStoredFiles  = 1))
		   or (t0.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1)
		)
      )
	  begin
	    return 1
	  end

	  /* Otherwise access denied */
	  
	  return 0
  
	end /* user is a prac*/
	
	/* Other client user groups are not supported at this time as we do not have
	 * a supervision tracking system for them so access denied. */

    return 0
  
  end /* User is with a client*/

  /*------------------------------------*/
  /* Practi-Cal Users                  */ 
  /*------------------------------------*/  

  if (@userGroup = 2) 
  begin
    /* No supervision tracking system, nothing else to do, access denied. */
    return 0
  end

  /*------------------------------------*/
  /* Third Party Users                  */ 
  /*------------------------------------*/  

  if (@userGroup = 3)
  begin
    /* No supervision tracking system, nothing else to do, access denied. */
    return 0
  end
  
  /* If we reach this point its an unsupported user group so access denied*/
  return 0

end /* Confidential file check */


/*###########################################################################
  #
  #                    Non Confidential File Rules
  # 
  ###########################################################################*/

/* 
 * TODO: Put globaly shared file access check here 
 * (files that all users can see regardless of affiliation) 
 */

/*###########################################################################
  # User group specific rules.
  ###########################################################################*/

/*------------------------------------*/
/* Practi-Cal Users                  */ 
/*------------------------------------*/  

if (@userGroup = 2) return 1  /* If the user is a Practi-cal staff member, they can see the record */

/*------------------------------------*/
/* Third Party Users                  */ 
/*------------------------------------*/  

if (@userGroup = 3)
begin
  
  /* Only third party parent/guardians (12), orps (11), and patients (18) have access to certain files.  
    Other roles in this user group do not have access to files at this time. */
  
  if (@userRole not in (11,12,18)) return 0 
  
  /* Check for specific access to ACTIVE service authorization request (SAR) included files
   * Note: File includes may not have the patient id associated with it.
   * This is for parent/guardians and orps 
   */

  if exists (
    select top 1 
      fti.uploadID
    from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS as sarau
    join dbo.SERVICE_AUTHORIZATION_REQUESTS                 as sar on ((sar.id = sarau.requestID) and (sar.active = 1))
	join dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE as fti on fti.requestID = sar.id
    where ((sarau.userID = @userID) and (fti.uploadID = @fileRecID))	
  )
  begin
    return 1
  end

  /* If we reach this point, if the user is an parent/guardian they might have access as long as
   * they have a relationship with a patient via associated patient person patID association
   * and they either have unconditional access to the file class or explicit access via flag
   */

  if (@userRole = 12) 
  begin
    	 
	/* If patient id is not saved with file upload then we need to get out */

	if (@filePatID is null) return 0
	
	/* Does the patient id associated with the file match a patient id associated with the parent/guardian.  
	 * If not get out. */
	
	if not exists (
	    select top 1 
		  ppvc.patientID 
		from dbo.PATIENT_PERSONS_VIEW_CORE (null, null, null, null, @filePatID, null, null, 1, null, @userID) as ppvc
	)
	begin
	  return 0
	end
	
	/* If we reach this point the file upload has a patient id associated with it and the parent guardian is associated with that patient id
	 * Now we need to check if the file class is one that a parent guardian is permitted to access 
	 * in all cases.  If its not one then we need to check if they have been given access. */
    
	/* Info request is allowed in all cases */
	
	if (@fileClassID in (635))
	begin 
	  return 1
	end
    
	/* Check if they can access via the flag */

	if (@okToShareFileWithParentGuardian = 1) return 1
		
	/* Otherwise get out */

	return 0
	    
  end /* parent/guardian */
  
  /* If we reach this point, if the user is an patient they might have access as long as
   * they have a relationship with a patient via associated patient user account patID association
   * and they either have unconditional access to the file class or explicit access via flag
   */

  if (@userRole = 18)
  begin
  	
    /* If patient id is not saved with file upload then we need to get out */

	if (@filePatID is null) return 0
	
	/* Does the patient id associated with the file match a patient id associated with the account.  
	 * If not get out. */
	
	if not exists (
	    select top 1 
		  puavc.patID
		from dbo.PATIENT_USER_ACCOUNTS_VIEW_CORE (null, null, null, null, @filePatID, 1, null, @userID) as puavc    
	)
	begin
	  return 0
	end

    /* Check if they can access via the flag */

	if (@okToShareFileWithPatient = 1) return 1

  end /* patient */

  /* If we reach this point and the the user is an orp professional they MIGHT have access 
   * as long as the file is an allowed file class and they have explicit access to a service auth
   * request.
   */

  if (@userRole = 11)
  begin
   
   /* If patient id is not saved with file upload then we need to get out */

	if (@filePatID is null) return 0
	
   /* If this is a file class that is NOT in the allowed list of file classes for ORPS then
    * access denied
	*/

   if (@fileClassID not in (3,4,5,6,7,8)) return 0

   /* If the file is associated with a patient for an ACTIVE service authorization request that they have been
    * given explicit access to then access granted.
	*/
   
   if exists ( 
 
    select top 1 
	    sar.id
    from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS as sarau
    join dbo.SERVICE_AUTHORIZATION_REQUESTS                 as sar on ((sar.id = sarau.requestID)
                                                                   and (sar.patID = @filePatID)
                                                                   and (sar.active = 1))
    where (sarau.userID = @userID)
   ) 
   
   begin
     return 1
   end
   
   /* If we reach this point then the ORP has no access */
   
   return 0
  
  end /* ORP specific */

  /* If we reach this point then the third party user has no access*/
  
  return 0

end /* Third party user */

/*------------------------------------*/
/* Client Users                       */ 
/*------------------------------------*/  

if (@userGroup = 1) 
begin
  
  /* If file is not associated with users client ID then access denied */
  
  if (@userClientID != @fileClientID) return 0
    
  /* If the user role is a client role that can see all files associated with client
   * then access granted 
   */
    
  if ((@userRole) in (5,10)) return 1
  
   /* If the user is a practitioner */
      
  if (@userRole = 7)
  begin
   
   /* Blank fillable PDF for client */        
   if (@fileClassID = 60)
   begin
     return 1
   end

   /* If there is no prac associated with the file then 
      attempt to find the pracID based on the fileUserID */
   
   if (@filePracID is null)
   begin
     select top 1 
       @filePracID = prp.PRACTITIONER_ID 
     from dbo.PRACTITIONER_Practitioner as prp
     join dbo.PRACTITIONER_Client       as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
     where (
           (prp.UserID = @fileUserID)
       and (prc.CLIENT_ID = @fileClientID)
     )
	 option (recompile)
   end

	/* Files pracID check.  If user is in a group "family" associated with the file based on 
     * the pracId stored with the file, they can see the record
     */
    
	if exists (    
      select top 1 
        prg.GROUP_ID
      from dbo.PRACTITIONER_Practitioner as prp 
      join dbo.PRACTITIONER_GROUPS       as prg on prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                and prg.GROUP_TYPE in (1,2)                                              
      join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS      as pngd on ((pngd.GROUP_SERVICE_CLASS_PARTITION_ID = @storedFileServiceClassPartID) and (pngd.GROUP_ID = prg.GROUP_ID)) /* Uses index */
                                                                             
      where (
            (prp.PRACTITIONER_ID = @filePracID)                                                                             
        and (pngd.GROUP_SERVICE_CLASS_NAME_ID = @userGroupServiceClassNameID)
      )	  
   )
   begin
     return 1
   end
   
   /* Files dispGroupID check.
    * If user is in a group "family" associated with the file based on 
    * the dispGroupID stored with the file, they can see the record
    */
    if exists (   	
	  select top 1
        pngd.GROUP_ID
	  from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as pngd 
	  where (
	        (pngd.GROUP_SERVICE_CLASS_PARTITION_ID = @storedFileServiceClassPartID) 
		and (pngd.GROUP_ID = @fileGroupIdDisp) 
      ) /* Uses index */
    )
	begin
	  return 1
	end  
       
	
	

   
    /* If we reach this point access denied */
	return 0
    
  end /* Practitioner */
  
  /* If we reach this point access denied */
  return 0  

end /* Client user */

/* If we get here then its unexpected */

return 0

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STORED_FILE_CAN_USER_VIEW] TO [webuser]
GO