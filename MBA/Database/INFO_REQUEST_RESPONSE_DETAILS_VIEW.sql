USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INFO_REQUEST_RESPONSE_DETAILS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INFO_REQUEST_RESPONSE_DETAILS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INFO_REQUEST_RESPONSE_DETAILS_VIEW]
(    
 
  @batchID     BIGINT,
  @irrID       BIGINT, 
  @status      int,  
  @token       varchar(100), 
  @recID       BIGINT,   
  @active      BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * INFO_REQUEST_RESPONSE_DETAILS_VIEW */    
/**    
 * Returns a table of INFO_REQUEST_RESPONSE_DETAILS that match the given parameters.    
 *    
 * @param  batchID         ID of Qform    
 * @param  irrID           ID of associated INFO_REQUEST_RESPONSE
 * @param  canEdit         If record can be edited by userID  
 * @param  recID           INFO_REQUEST_RESPONSE_DETAILS ID    
 * @return                 Table     
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
   select 
          irrd.Question,
          irrd.Answer,
          irrd.InfoRequestResponseID,
          irrd.Detail_Number as detailNum,
          irr.Token,
          irr.ReferenceID,
          irr.OldestDOSOnQform,
          irrd.id,           
          irrd.Active,
          irr.To_UserID,
          irr.Email_To,
          irrd.Standard_QuestionID,
          irrd.Question_Type,
          isExpired = case when irr.Expiration_Date > getdate() then 0
                      else 1 end,
          irr.RespondedOn,
          irr.OpenedOn,
          irr.To_PracID,
          irr.Status,
          cca.REP_NAME as Repname,
		  cca.REP_EMAIL as RepEmail,
		  cca.REP_PHONE as RepPhone

  from dbo.INFO_REQUEST_RESPONSE_DETAILS irrd
  join dbo.INFO_REQUEST_RESPONSE irr on irr.id = irrd.InfoRequestResponseID     
  left join SPEDMON.dbo.CLIENTS_Client_All as cca on cca.CLIENT_ID = irr.ClientID
  ) as irrv
  where   ((@recID      is null) or (irrv.id                    = @recID))   and
          ((@irrID      is null) or (irrv.InfoRequestResponseID = @irrID))   and
          ((@token      is null) or (irrv.token                 = @token))   and
          ((@batchID    is null) or (irrv.ReferenceID           = @batchID)) and 
          ((@status     is null) or (irrv.Status                = @status))  and           
          ((@active     is null) or (irrv.ACTIVE                = @active))
 
  order by id
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INFO_REQUEST_RESPONSE_DETAILS_VIEW] TO [webuser]
GO
