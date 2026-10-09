
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_Preference_Template_Create') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_Preference_Template_Create
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_Preference_Template_Create
(
@Template_Rule_Sequence		bigint,
@Client_ID					bigint,
@Group_ID					bigint,
@PracID						bigint,
@SvcNote_Preference			bigint, 
@UserID						bigint,
@Reason_Template_Applied	varchar(max),

@NewTemplateID				bigint output
)

AS

BEGIN

/* See if there's an active template for this client_group_prac tuple */
declare @TempID bigint = null
set @TempID = (select top 1 snpt.id from SVCNOTE_PREFERENCE_TEMPLATES snpt where snpt.Client_ID = @Client_ID and (snpt.Group_ID = @Group_ID or @Group_ID is null) and (snpt.PracID = @PracID or @PracID is null) and snpt.Active = 1)

IF @TempID is not null
BEGIN
	/* If there is, close it out */
	update SVCNOTE_PREFERENCE_TEMPLATES 
	set Active = 0,
		ClosedByUserID = @UserID,
		Closed_Date = GETDATE()
	where id = @TempID
	
END
/* Create new template preference entry */

insert into SVCNOTE_PREFERENCE_TEMPLATES (Template_Rule_Sequence,Client_ID,Group_ID,PracID,SvcNote_Preference,CreatedByUserID,Created_Date, Active, Reason_Template_Applied)
	VALUES(@Template_Rule_Sequence,@Client_ID,@Group_ID,@PracID,@SvcNote_Preference,@UserID,GETDATE(),1,@Reason_Template_Applied)


set @NewTemplateID = SCOPE_IDENTITY()


END
GO