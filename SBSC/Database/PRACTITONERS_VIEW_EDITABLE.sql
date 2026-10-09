USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_EDITABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_EDITABLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITONERS_VIEW_EDITABLE] (
   @clientID   as   bigint
 , @recID      as   bigint
 , @userID     as   bigint
 , @userGroup  as   int
 , @userRank   as   int
)

returns table
as

/***************************************************************************
 * PRACTITONERS_VIEW_EDITABLE */
/**
 * Internal helper query for PRACTITIONERS_VIEW.
 * Indicates which practitioner records are editable by userID
 *
 * @param  clientID        Client ID
 * @param  recID           Practitioner id
 * @param  userID          User ID (Required)
 * @param  userGroup       User group (Required)
 * @param  userRank        User rank (Required)
 * @return                 Practitioner records that can be edited
 ***************************************************************************/

return (

select id

/*-------------------------------
 * Active and inactive practitioners
 * can be edited.  Note if the
 * user is a client user the
 * @clientID is passed, forcing
 * the selection to just be from
 * that client
 *------------------------------*/

from dbo.PRACTITONERS_VIEW_CORE (0,@clientID,null,null,null,null,null,null, null,@recID,null) as p

where

(1=1)

)
GO
