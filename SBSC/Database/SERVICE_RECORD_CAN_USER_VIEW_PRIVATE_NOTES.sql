USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES](
    @userID                bigint
  , @srUserIDCreated       bigint
  , @srPracID              bigint
  , @srDOS                 datetime
  , @srGroupID             bigint
  , @srPracGrpSvcClsNameID bigint
  , @srClientID            bigint
) 
RETURNS bit
as 
begin

/*============================================================
 * If user created service record then user can view and exit
 *===========================================================*/  

if (@userID = @srUserIDCreated) return 1

declare @userPracId              as bigint = null
declare @userIsDeptHead          as bit    = null
declare @userDispGroupID         as bigint = null
declare @userPracGrpSvcClsNameID as bigint = null

/*============================================================
 * Look up calling users practitioner record (if any)
 *===========================================================*/  

select top 1 
  
    @userPracId              = prp.PRACTITIONER_ID
  , @userIsDeptHead          = isnull(prp.deptHead,0)
  , @userDispGroupID         = prg.GROUP_ID 
  , @userPracGrpSvcClsNameID = png.GROUP_SERVICE_CLASS_NAME_ID

from dbo.PRACTITIONER_Practitioner                         as prp
join dbo.PRACTITIONER_GROUPS                               as prg on ((prg.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (prg.GROUP_TYPE in (1,2)) and (prg.ACTIVE = 1))
join dbo.GROUP_Group                                       as gg  on ((gg.GROUP_ID = prg.GROUP_ID) and (gg.ACTIVE = 1))
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100) and (png.GROUP_ID = prg.GROUP_ID))

where 
  (prp.UserID = @userID)

/*============================================================
 * If none exists then user cannot view and exit
 *===========================================================*/  

if (@userPracId is null) return 0

/*============================================================
 * If calling user practitioner record is the same as the 
 * service record prac then user can view and exit
 *===========================================================*/  

if (@userPracId = @srPracID) return 1

/*============================================================
 * If users practice family and service records practice family
 * are not the same then exit
 *===========================================================*/  

if (@userPracGrpSvcClsNameID != @srPracGrpSvcClsNameID) return 0

/*============================================================
 * See if there is an active direct supervision relationship
 * between the practitioner who rendered the service and
 * the practitioner viewing the service record
 *===========================================================*/  

declare @pdsId as bigint = null

select top 1 
  @pdsID = pds.ID 
from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as pds
where (
      (pds.ACTIVE = 1)  
  and (pds.SUPERVISED_PRAC_ID = @srPracID)
  and (@srDOS between pds.START_DATE and (isnull(pds.END_DATE,getdate())))
  and (pds.SUPERVISING_PRAC_ID = @userPracId)
  and (pds.ID is not null)
  and (pds.SHARE_NOTES = 0)
  and (pds.relationshipTypeID = 10)
)

/*============================================================
 * If no relationhip exists then user cannot view unless
 * they are with a client that allows department heads to view
 * otherwise they can view and exit
 *===========================================================*/  

if (@pdsId is null) 
begin

  
  if (@userIsDeptHead = 0) return 0 

  /*============================================================
   * If this client allows department heads to view private 
   * notes and if the practitioner viewing the service record:
   * is a department head then allow
   *===========================================================*/  
  if exists (
    select top 1    
      t0.SUPERVISED_PRAC_ID 
    from dbo.PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE (@srClientID, @userPracId, @srPracID) as t0
    where (
         ((t0.departmentHeadsCanViewSupervisedPracsSvcRecs      = 1)
     and (t0.departmentHeadsCanViewSupervisedPracsPrivateNotes = 1))
	 or  (t0.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1)
	 )
  )
  begin
    return 1
  end

  /*============================================================
   * Otherwise do not allow
   *===========================================================*/  

  return 0 

end
else 
begin

  /*============================================================
   * Supervision relationship exists so allow
   *===========================================================*/  

  return 1
end

/*============================================================
 * If we reach this point assume user cannot view and exit
 *===========================================================*/  

return 0

end
    
go

