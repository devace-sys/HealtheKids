USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_VIEW_PCAL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USERS_VIEW_PCAL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[USERS_VIEW_PCAL] (
    @userID             bigint
  , @userGroup          int
  , @userRank           int
  , @lname              NVARCHAR(50)    
  , @fname              NVARCHAR(50)
  , @isInputStaff       bit
  , @isClientConsultant bit    
  , @canEdit            bit
  , @active             bit
  , @recID              bigint )

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * USERS_VIEW_PCAL */
/**
 * Displays pcal users only
 *
 * @return                 Table of user data
 ***************************************************************************/ 
    
with
cte_p1
as
(
  select   
    
      u.userrid          as id  
    , name               = m.LastName + ', ' + m.FirstName
    , u.UserName         as userName
    , m.LastName         as lastName    
    , m.FirstName        as firstName
    , rd.id              as roleID
    , r.RoleName         as roleName
    , active             = convert(bit, case when r.RoleID = dbo.CONST_ROLE_INACTIVE() then 0 else 1 end)
    , isInputStaff       = convert(bit, case when (rd.id in (3,4)) then 1 else 0 end)
    , isClientConsultant = convert(bit, case when (rd.id in (2,9)) then 1 else 0 end)    
  
  from dbo.Users        as u
  join dbo.Membership   as m  on m.UserId  = u.UserID
  join dbo.UsersInRoles as ur on ur.UserID = u.UserID
  join dbo.Roles        as r  on r.RoleId  = ur.RoleID
  join dbo.RoleData     as rd on rd.RoleId = r.RoleID
  
  where (
        (m.SBSC_Employee = 1)
    and ((@recID is null) or (u.userrid = @recID))
  )
 )
 ,
 
 cte_p2
 as
 (
   select *    
   from cte_p1    
   where (
         (1=1)
     and ((@active             is null) or (active             = @active))
     and ((@isInputStaff       is null) or (isInputStaff       = @isInputStaff))
     and ((@isClientConsultant is null) or (isClientConsultant = @isClientConsultant))
   )
   
 )
 
 select top (dbo.CONST_MAX_ROWS()) *  
 from cte_p2
 where (
       (1=1)
   and ((@lname is null) or (lastName  like (isnull(@lname,'') + '%'))) 
   and ((@fname is null) or (firstName like (isnull(@fname,'') + '%')))
 )
 order by name
 
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USERS_VIEW_PCAL] TO [webuser]
GO
