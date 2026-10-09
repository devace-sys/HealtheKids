USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID](
    @selectionID varchar(8000)
  , @forSpaID    bigint output
  , @clientID    bigint output
  , @fyID        bigint output
  , @pracID      bigint output
  , @isIFSPorIEP bit    output
  , @groupID     bigint output
  , @nameID      bigint output)  
AS    
BEGIN    


/*============================================================
 * Parse selectionID
 *
 * We are expecting a composite ID of the form
 * 
 *   forSpaID-clientID-fyID-pracID-isIFSPorIEP-groupID-nameID
 * 
 * For example
 *
 *   1-198-24-2589758-1-248-20
 *
 * Note: The built in STRING_SPLIT for SQL Server does not
 * guarantee the order of parsing so we are using
 * an alternative that does.
 *============================================================*/  

declare @selectionIdParts as table (
   id   int      
  ,part varchar(255)
)   

declare @selectionIDRegen as varchar(8000) = ''
declare @numParts         as int           = 0

insert into @selectionIdParts
select t1.* from dbo.STRING_SPLIT(@selectionID, '-',1) as t1

select @numParts = count(id) from @selectionIdParts

if (@numParts != 7)
begin
  RAISERROR ('Incomplete or blank selection ID', 11, 1)    
end

select top 1 @forSpaID    = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 1
select top 1 @clientID    = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 2
select top 1 @fyID        = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 3
select top 1 @pracID      = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 4
select top 1 @isIFSPorIEP = convert(bit,sip.part)    from @selectionIdParts as sip where sip.id = 5
select top 1 @groupID     = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 6
select top 1 @nameID      = convert(bigint,sip.part) from @selectionIdParts as sip where sip.id = 7

/*============================================================
 * Make sure all parts were extracted
 *============================================================*/  

IF (@forSpaID    IS NULL) RAISERROR ('forspa id is required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('client id is required',       11, 1)    
IF (@fyID        IS NULL) RAISERROR ('fiscal year id is required',  11, 1)    
IF (@pracID      IS NULL) RAISERROR ('practitioner id is required', 11, 1)    
IF (@isIFSPorIEP IS NULL) RAISERROR ('isIFSPorIEP is required',     11, 1)    
IF (@groupID     IS NULL) RAISERROR ('group id is required',        11, 1)    
IF (@nameID      IS NULL) RAISERROR ('name id is required',         11, 1)    

/*============================================================
 * Regenerate selection ID
 *============================================================*/  

set @selectionIDRegen = dbo.CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID (@forSpaID,@clientID,@fyID,@pracID,@isIFSPorIEP,@groupID,@nameID)

/*============================================================
 * Make sure passed in and regenerated match (this is a 
 * sanity check against problems with the string split)
 *============================================================*/  

if (@selectionID != @selectionIDRegen)
begin
  RAISERROR ('Invalid selection ID', 11, 1)    
end


return(0)

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID] TO [webuser]
GO
