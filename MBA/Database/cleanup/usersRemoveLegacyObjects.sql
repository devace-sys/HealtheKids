use users

/***************************************************************************
 * RemoveLegacyDBObjects.sql */
/**
 *                     ******** WARNING ********
 *        ******** DO NOT RUN THIS ON A PRODUCTION DATABASE ********
 *
 * Removes stored procedures, user defined functions, tables, and other
 * objects that are NOT used by Spedcare.
 ***************************************************************************/

/*-------------------------------
 * Stored Procedures
 *------------------------------*/
 
drop procedure dbo.Membership_ChangePasswordQuestionAndAnswer
drop procedure dbo.Membership_CreateUser
drop procedure dbo.Users_CreateUser
drop procedure dbo.Users_DeleteUser
drop procedure dbo.UsersInRoles_AddUsersToRoles
drop procedure dbo.UsersInRoles_FindUsersInRole
drop procedure dbo.UsersInRoles_GetUsersInRoles
drop procedure dbo.UsersInRoles_IsUserInRole
drop procedure dbo.Roles_RoleExists
drop procedure dbo.Roles_GetAllRoles
drop procedure dbo.Roles_DeleteRole
drop procedure dbo.Roles_CreateRole
drop procedure dbo.UsersInRoles_RemoveUsersFromRoles
drop procedure dbo.Membership_FindUsersByEmail
drop procedure dbo.Membership_FindUsersByName
drop procedure dbo.Membership_GetAllUsers
drop procedure dbo.Membership_GetNumberOfUsersOnline
drop procedure dbo.Membership_GetPassword
drop procedure dbo.Membership_GetPasswordWithFormat
drop procedure dbo.Membership_GetUserByEmail
drop procedure dbo.Membership_GetUserByName
drop procedure dbo.Membership_GetUserByUserId
drop procedure dbo.Membership_ResetPassword
drop procedure dbo.Membership_SetPassword
drop procedure dbo.Membership_UnlockUser
drop procedure dbo.Membership_UpdateUser
drop procedure dbo.Membership_UpdateUserInfo
drop procedure dbo.UsersInRoles_GetRolesForUser
drop procedure dbo.Users_GetGUID_ByUserName
drop procedure dbo.Membership_GetPendingUsers
drop procedure dbo.UsersActivity_AddActivity
drop procedure dbo.UsersActivity_AddDeActivity
drop procedure dbo.Membership_GetUserByUserName
drop procedure dbo.Membership_GetUsersByUserName
drop procedure dbo.Membership_GetUsersByEMail
drop procedure dbo.Membership_GetUsersByGivenName
drop procedure dbo.Membership_GetUsersToView
drop procedure dbo.Membership_GetUsersByClientID
drop procedure dbo.Membership_GetUsersBySiteID
drop procedure dbo.Membership_GetUsersByLetters
drop procedure dbo.Membership_UpdateUserData
drop procedure dbo.UsersInRoles_UpdateRole
drop procedure dbo.Membership_CheckUserAuth