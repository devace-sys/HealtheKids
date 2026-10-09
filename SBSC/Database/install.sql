/*-------------------------------------------------------------------
 * install.sql
 * Install various T-SQL objects for the Spedmon database
 * Invoked using SQLCMD
 * Example:
 * SQLCMD -E -S"PCALDEVOLD\SQLEXPRESS2008" -dSPEDMON -i install.sql
 *------------------------------------------------------------------*/



SET NOCOUNT ON
GO


/*-------------------------------
 * Objects that are no longer
 * needed should have drop
 * commands placed in
 * clean_up.sql
 *------------------------------*/

PRINT 'Cleaning up old objects'
:r clean_up.sql

/*-------------------------------
 * Database changes (if any)
 *------------------------------*/

PRINT 'Applying database changes'
:r CHANGES.sql

GO
EXEC sp_addmessage
  @msgnum = 53003, @severity = 11, @msgtext = 'FROM_CLIENT flat file not accepted by error-checking heuristic.  Not committed.', @lang = 'us_english',
  @with_log = 'TRUE', @replace = 'REPLACE';
GO

/*-------------------------------
 * Install objects
 *
 * Please note:
 *
 * - ALL t-sql objects need to be
 *   scripted out and the scripts
 *   MUST end with a GO
 * - All objects need to be included
 *   below using this format
 *   :r <filename.sql>
 * - All objects MUST be included
 *   below in order of dependecy
 *------------------------------*/

PRINT 'Installing our objects'

/*################################
  #
  #   TimeKeeper Database
  #
  ################################*/

:r TimeKeeper\TIMESHEET_GetEmployeeTimeVerficationByVerification.sql
:r TimeKeeper\AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId.sql
:r TimeKeeper\AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay.sql
:r TimeKeeper\AUTO_DeleteAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper\AUTO_InsertAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper\AUTO_GetAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper\TIMESHEET_CheckForUnVerifiedVerification.sql
:r TimeKeeper\TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime.sql
:r TimeKeeper\TIMESHEET_UpdateEmployeeTimeVerfication.sql
:r TimeKeeper\TIMESHET_GetEmployeeVerificationByNameDateRange.sql

:r TimeKeeper\TIMESHEET_FindEmployeeVerificationsByDateRange.sql

:r TimeKeeper\TIMESHET_GetEmployeeVerification.sql
:r TimeKeeper\TIMESHET_GetEmployeeVerificationByName.sql
:r TimeKeeper\TIMESHEET_InsertEmployeeTimeVerfication.sql
:r TimeKeeper\TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID.sql
:r TimeKeeper\TIMESHEET_GetEmployeesWhoGetPaidForHoliday.sql
:r TimeKeeper\TIMESHEET_CreateEmployee.sql
:r TimeKeeper\TIMESHEET_UpdateEmployee.sql
:r TimeKeeper\TIMESHEET_GetEmployeeSchedules.sql
:r TimeKeeper\TIMESHEET_GetHolidayByDate.sql
:r TimeKeeper\TIMESHEET_UpdateHolidaysThisYear.sql
:r TimeKeeper\TIMESHEET_DeleteHolidays.sql
:r TimeKeeper\TIMESHEET_GetHolidays.sql
:r TimeKeeper\TIMESHEET_CreateHolidayEntry.sql
:r TimeKeeper\TIMESHEET_GetSchedulesForEmployeesByDateRange.sql
:r TimeKeeper\TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF.sql
:r TimeKeeper\TIMESHEET_GetAutoPopulateTaskDays.sql
:r TimeKeeper\TIMESHEET_UpdateTimeEntryTaslEmplate.sql
:r TimeKeeper\TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee.sql
:r TimeKeeper\TIMESHEET_GetTimeEntriesByDateAndEmployee.sql
:r TimeKeeper\TIMESHEET_InsertTimeEntries.sql
:r TimeKeeper\TIMESHEET_InsertTimeEntryDay.sql
:r TimeKeeper\TIMESHEET_DeleteTimeEntries.sql
:r TimeKeeper\TIMESHEET_GetAutoSchedulerTimeEntryDay.sql
:r TimeKeeper\TIMESHEET_GetClient.sql
:r TimeKeeper\TIMESHEET_GetClientFavorites.sql
:r TimeKeeper\TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDay.sql
:r TimeKeeper\TIMESHEET_GetAutoTaskInfoForTimeEntry.sql
:r TimeKeeper\TIMESHEET_GetAutoPopulateTaskDays.sql
:r TimeKeeper\TIMESHEET_UpdateAutoPopulateTaskDetails.sql
:r TimeKeeper\TIMESHEET_UpdateScheduleTemplate.sql
:r TimeKeeper\TIMESHEET_InsertAutoPopulateTaskDetails.sql
:r TimeKeeper\TIMESHEET_InsertAutoPopulateTaskDays.sql
:r TimeKeeper\TIMESHEET_DeleteAutoPopulateTaskDays.sql
:r TimeKeeper\TIMESHEET_DeleteAutoPopulateTaskDetails.sql
:r TimeKeeper\TIMESHEET_GetAutoPopulateTaskDetails.sql
:r TimeKeeper\TIMESHEET_UpdateAutoPopulateTaskTemplate.sql
:r TimeKeeper\TIMESHEET_InsertAutoPopulateTaskTemplate.sql
:r TimeKeeper\TIMESHEET_GetAutoScheduleInfo.sql
:r TimeKeeper\TIMESHEET_UpdateEmployeeTemplateId.sql
:r TimeKeeper\TIMESHET_GetEmployeeTaskFavorites.sql
:r TimeKeeper\TIMESHET_GetEmployeeInfoDetail.sql
:r TimeKeeper\TIMESHEET_GetEmployeeList.sql
:r TimeKeeper\TIMESHEET_GetTaskInformation.sql
:r TimeKeeper\TIMESHEET_DeleteTimeEntryForMultipleClient.sql
:r TimeKeeper\TASK_CreateNew.sql
:r TimeKeeper\TASK_Update.sql
:r TimeKeeper\TIMESHEET_GetPresonInfo.sql
:r TimeKeeper\SCHEDULE_CreateNew.sql
:r TimeKeeper\SCHEDULE_CreateNewScheduleApproved.sql
:r TimeKeeper\SCHEDULE_GetScheduledByDate.sql
:r TimeKeeper\SCHEDULE_GetStartAndStopTimes.sql
:r TimeKeeper\SCHEDULE_GetStartAndStopTimesByScheduledDate.sql
:r TimeKeeper\SCHEDULE_GetStartAndStopTimesForScheduleTemplate.sql
:r TimeKeeper\SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate.sql
:r TimeKeeper\SCHEDULE_STOP_START_CreateNew.sql
:r TimeKeeper\SCHEDULE_TEMPLATE_STOP_START_CreateNew.sql
:r TimeKeeper\SCHEDULEStartAndStop_Delete.sql
:r TimeKeeper\SCHEDULEStartAndStop_Update.sql
:r TimeKeeper\SCHEDULEStartAndStopTemplate_Update.sql
:r TimeKeeper\SCHEDULETemplateStartAndStop_Delete.sql
:r TimeKeeper\TIMESHEET_CreateTimeEntry.sql
:r TimeKeeper\TIMESHEET_CreateTimeEntryDay.sql
:r TimeKeeper\TIMESHEET_DeleteTimeEntry.sql
:r TimeKeeper\TIMESHEET_GetEmployeeInfo.sql
:r TimeKeeper\TIMESHEET_GetPresonInfo.sql
:r TimeKeeper\TIMESHEET_GetSchedule.sql
:r TimeKeeper\TIMESHEET_GetTimeEntriesForEmployeeAndDate.sql
:r TimeKeeper\TIMESHEET_GetTimeEntry.sql
:r TimeKeeper\TIMESHEET_GetTimeEntryById.sql
:r TimeKeeper\TIMESHEET_GetTimeEntryDayForEmployeeAndDate.sql
:r TimeKeeper\TIMESHEET_UpdateTimeEntry.sql
:r TimeKeeper\PEOPLE_GetRecord.sql
:r TimeKeeper\TIMESHEET_SelectSpedmonUsers.sql
:r TimeKeeper\TIMESHEET_CheckForDelinquentEmployees.sql
:r TimeKeeper\TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary.sql

:r TimeKeeper\TIMESHEET_ViewEmployeeList.sql
:r TimeKeeper\ViewListOfFavoriteClients.sql
:r TimeKeeper\MoveToFavoriteClients.sql
:r TimeKeeper\RemoveFromFavoriteClients.sql
:r TimeKeeper\ViewListOfTasks.sql
:r TimeKeeper\MoveToFavoriteTasks.sql
:r TimeKeeper\RemoveFromFavoriteTasks.sql

:r TimeKeeper_TIMESHEET_ViewEmployeeList.sql
:r TIMEKEEPER_ViewListOfFavoriteClients.sql
:r TIMEKEEPER_MoveToFavoriteClients.sql
:r TIMEKEEPER_RemoveFromFavoriteClients.sql
:r TIMEKEEPER_ViewListOfTasks.sql
:r TIMEKEEPER_MoveToFavoriteTasks.sql
:r TIMEKEEPER_RemoveFromFavoriteTasks.sql


:r TimeKeeper\EMPLOYEE_DETAIL_PORTED.sql
:r TimeKeeper\EMPLOYEE_PAYROLL_PORTED.sql
:r TimeKeeper\EMPLOYEE_PAYROLL_BY_DAY.sql

:r TimeKeeper\EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS.sql

:r TimeKeeper_EMPLOYEE_PAYROLL_PORTED.sql
:r TimeKeeper_EMPLOYEE_DETAIL_PORTED.sql
:r TimeKeeper_EMPLOYEE_PAYROLL_BY_DAY.sql

:r TimeKeeper_EMPLOYEE_PAYROLL_SUBTOTALS_AND_ADJUSTMENTS.sql

:r TimeKeeper\PayrollAdj_SAVE.sql
:r TimeKeeper_PayrollAdj_SAVE.sql

:r InvoicesLastMonth.sql

:r TimeKeeper\TIMESHEET_ViewCalendarScheduledTasks.sql
:r TimeKeeper\TIMESHEET_ViewCalendarRecordedTasks.sql

:r TimeKeeper\TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks.sql
:r TimeKeeper\TIMESHEET_ViewCalendarCombinedScheduledRecordedTotals.sql
:r TimeKeeper\TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt.sql
:r TimeKeeper\TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance.sql

:r TimeKeeper\TaskCalendar_SAVE_TaskWeekHours.sql
:r TimeKeeper_TaskCalendar_SAVE_TaskWeekHours.sql

:r TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt.sql
:r TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance.sql


:r TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT.sql


/*################################
  #
  #   Spedmon Database
  #
  ################################*/

/* Time keeper "pass through" objects */

:r TimeKeeper_TIMESHEET_GetEmployeeTimeVerficationByVerification.sql
:r TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByTaskDaysId.sql
:r TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTimeByDay.sql
:r TimeKeeper_AUTO_DeleteAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper_AUTO_InsertAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper_TIMESHEET_CheckForUnVerifiedVerification.sql
:r TimeKeeper_TIMESHEET_InsertAutoPopulateScheduleStartAndStopTime.sql
:r TimeKeeper_AUTO_GetAutoPopulateTaskDaysStartStopTime.sql
:r TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication.sql
:r TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange.sql

:r TimeKeeper_TIMESHEET_FindEmployeeVerificationsByDateRange.sql


:r TimeKeeper_TIMESHET_GetEmployeeVerification.sql
:r TimeKeeper_TIMESHET_GetEmployeeVerificationByName.sql
:r TimeKeeper_TIMESHEET_InsertEmployeeTimeVerfication.sql
:r TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHolidayByEmployeeID.sql
:r TimeKeeper_TIMESHEET_GetEmployeesWhoGetPaidForHoliday.sql
:r TimeKeeper_TIMESHEET_CreateEmployee.sql
:r TimeKeeper_TIMESHEET_UpdateEmployee.sql
:r TimeKeeper_TIMESHEET_GetEmployeeSchedules.sql
:r TimeKeeper_TIMESHEET_GetHolidayByDate.sql
:r TimeKeeper_TIMESHEET_DeleteHolidays.sql
:r TimeKeeper_TIMESHEET_GetHolidays.sql
:r TimeKeeper_TIMESHEET_CreateHolidayEntry.sql
:r TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange.sql
:r TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF.sql
:r TimeKeeper_TIMESHEET_InsertTimeEntryDay.sql
:r TimeKeeper_TIMESHEET_GetAutoPopulateTaskDays.sql
:r TimeKeeper_TIMESHEET_UpdateTimeEntryTaslEmplate.sql
:r TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee.sql
:r TimeKeeper_TIMESHEET_GetTimeEntriesByDateAndEmployee.sql
:r TimeKeeper_TIMESHEET_InsertTimeEntries.sql
:r TimeKeeper_TIMESHEET_DeleteTimeEntries.sql
:r TimeKeeper_TIMESHEET_GetAutoSchedulerTimeEntryDay.sql
:r TimeKeeper_TIMESHEET_GetClient.sql
:r TimeKeeper_TIMESHEET_GetClientFavorites.sql
:r TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDay.sql
:r TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntryForSpecificDayForEmployee.sql
:r TimeKeeper_TIMESHEET_GetAutoTaskInfoForTimeEntry.sql
:r TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskDetails.sql
:r TimeKeeper_TIMESHEET_UpdateScheduleTemplate.sql
:r TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDetails.sql
:r TimeKeeper_TIMESHEET_InsertAutoPopulateTaskDays.sql
:r TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDays.sql
:r TimeKeeper_TIMESHEET_DeleteAutoPopulateTaskDetails.sql
:r TimeKeeper_TIMESHEET_GetAutoPopulateTaskDetails.sql
:r TimeKeeper_TIMESHEET_UpdateAutoPopulateTaskTemplate.sql
:r TimeKeeper_TIMESHEET_InsertAutoPopulateTaskTemplate.sql
:r TimeKeeper_TIMESHEET_GetAutoScheduleInfo.sql
:r TimeKeeper_TIMESHEET_UpdateEmployeeTemplateId.sql
:r TimeKeeper_TIMESHET_GetEmployeeTaskFavorites.sql
:r TimeKeeper_GetTaskTemplateInfo.sql
:r TimeKeeper_TIMESHET_GetEmployeeInfoDetail.sql
:r TimeKeeper_TIMESHEET_GetEmployeeList.sql
:r TimeKeeper_TIMESHEET_GetTaskInformation.sql
:r TimeKeeper_TIMESHEET_DeleteTimeEntryForMultipleClient.sql
:r TimeKeeper_TASK_CreateNew.sql
:r TimeKeeper_TASK_Update.sql
:r TimeKeeper_TIMESHEET_GetPresonInfo.sql
:r TimeKeeper_SCHEDULE_CreateNew.sql
:r TimeKeeper_SCHEDULE_CreateNewScheduleApproved.sql
:r TimeKeeper_SCHEDULE_GetScheduledByDate.sql
:r TimeKeeper_SCHEDULE_GetStartAndStopTimes.sql
:r TimeKeeper_SCHEDULE_GetStartAndStopTimesByScheduledDate.sql
:r TimeKeeper_SCHEDULE_GetStartAndStopTimesForScheduleTemplate.sql
:r TimeKeeper_SCHEDULE_GetTemplateStartAndStopTimesByScheduledDate.sql
:r TimeKeeper_SCHEDULE_STOP_START_CreateNew.sql
:r TimeKeeper_SCHEDULE_TEMPLATE_STOP_START_CreateNew.sql
:r TimeKeeper_SCHEDULEStartAndStop_Delete.sql
:r TimeKeeper_SCHEDULEStartAndStop_Update.sql
:r TimeKeeper_SCHEDULEStartAndStopTemplate_Update.sql
:r TimeKeeper_SCHEDULETemplateStartAndStop_Delete.sql
:r TimeKeeper_TIMESHEET_CreateTimeEntry.sql
:r TimeKeeper_TIMESHEET_CreateTimeEntryDay.sql
:r TimeKeeper_TIMESHEET_DeleteTimeEntry.sql
:r TimeKeeper_TIMESHEET_GetEmployeeInfo.sql
:r TimeKeeper_TIMESHEET_GetPresonInfo.sql
:r TimeKeeper_TIMESHEET_GetSchedule.sql
:r TimeKeeper_TIMESHEET_GetTimeEntriesForEmployeeAndDate.sql
:r TimeKeeper_TIMESHEET_GetTimeEntry.sql
:r TimeKeeper_TIMESHEET_GetTimeEntryById.sql
:r TimeKeeper_TIMESHEET_GetTimeEntryDayForEmployeeAndDate.sql
:r TimeKeeper_TIMESHEET_UpdateTimeEntry.sql
:r TimeKeeper_TIMESHEET_CheckForDelinquentEmployees.sql
:r TimeKeeper_TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary.sql
:r TimeKeeper_PEOPLE_GetRecord.sql
:r TimeKeeper_SelectSpedmonUsers.sql

:r CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE.sql

/* CYBHI Licensed and associate group lists */

:r CYBHI_TRANSMISSION_GENERATION_VIEW_LICENSED_PRAC_GROUPS.sql
:r CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS.sql
:r CYBHI_VIEW_PARA_PROF_PRAC_GROUPS.sql
:r CYBHI_VIEW_CREDENTIALED_PRAC_GROUPS.sql
:r CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA.sql
:r CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS.sql

:r GENERATE_NUMBERS_TABLE.sql
:r PRINT_STATUS_MESSAGE.sql
:r GET_FILE_NAME_FROM_PATH_FILE_NAME.sql
:r WriteStringToFile.sql
:r ReadStringFromFile.sql
:r STRING_SPLIT_MAX.sql

:r X12Utilities.sql
:r Claims_835_Save_Data_Received.sql
:r Claims_835_Save_Data_Received_Parse.sql
:r Claims_835_Save_Data_Received_Parse_Assign_Line_Numbers.sql
:r Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PER.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_REF.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N4.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N3.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N1.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_QTY.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Adjustment.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code.sql

:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments.sql
:r Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes.sql

:r Claims_835_Save_Data_Received_Parse_Pivot.sql
:r Claims_835_Process_Data_Received.sql
:r Claims_835_Save_And_Process_File.sql

/* Views */

:r GENERATE_RANDOM_NUMBERS.sql
:r IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES.sql
:r CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES.sql
:r CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES.sql
:r GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA.sql
:r GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE.sql
:r GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE_GROUP_ID.sql
:r CDE_SCHOOLS_PUBLIC_SITES_CURRENT.sql
:r CDE_SCHOOLS_PRIVATE_SITES_CURRENT.sql
:r CDE_SCHOOLS_SITES_CURRENT.sql
:r CDE_SCHOOLS_SITES_CURRENT_WITH_CLIENT_SITES_XREF.sql
:r GENERATE_NEXT_CDS_7_X_CODE.sql
:r CLIENTS_Client_All.sql
:r CLIENTS_Client_Active_LEA.sql
:r CLAIM_PROCEDURES_WAITING_FOR_SPA.sql
:r WAITING_SERVICES_DATA_TEMP_ACTIONABLE.sql

:r View_Import_From_C_from_dhcs_ToSPED_Files.sql
:r View_Import_From_B_to_dhcs_ToSPED_Files.sql
:r View_Import_From_B_and_C_File_rows.sql

:r VIEW_PROMISED_SERVICES_IMPORTS.sql

:r View_RMTS_SMAA_Info_Unfiltered.sql

:r TRANSMISSION_RECORDS_ALL.sql
:r TRANSMISSION_RECORD_CLAIMS_ALL.sql
:r TRANSMISSION_SUMMARY_BY_CLIENT_837_ALL.sql
:r TRANSMISSION_GENERATIONS_ALL.sql
:r GROUPS_GROUP_SUPERVISED_SUPERVISOR.sql
:r PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR.sql
:r CIF_REQUESTS_PENDING_SUBMISSION.sql
:r CLAIM_PROCEDURES_SERVICE_NAMES_IN_CURRENT_USE.sql

:r SpEd_Service_GroupServiceClassNames.sql
:r SpEd_Service_GroupID_PlanID_NameID_Data.sql
:r SpEd_Service_Avg_Rate_Data.sql
:r SpEd_Service_GroupServiceClassNamesAgg.sql
:r SpEd_Service_GroupServiceClassNamesNotAssigned.sql
:r View_Latest_Successful_Total_Pop_Imports.sql

/* Constants */

:r CONST_MAX_ROWS.sql
:r CONST_SVC_REC_STATE_UNDEF.sql
:r CONST_MIN_DATETIME.sql
:r CONST_MIN_DATETIME_GREGORIAN.sql
:r CONST_MIN_DATETIME_TER.sql
:r CONST_MIN_DATETIME_1900_01_01.sql
:r CONST_MAX_DATETIME.sql
:r CONST_GROUP_TYPE_DISP.sql
:r CONST_GROUP_TYPE_REPT.sql
:r CONST_GROUP_TYPE_DISP_SUPER.sql
:r CONST_USER_GROUP_CLIENT.sql
:r CONST_USER_GROUP_SBS.sql
:r CONST_SAVE_TYPE_NEW.sql
:r CONST_SAVE_TYPE_COPY.sql
:r CONST_SAVE_TYPE_DEACTIVATE.sql
:r CONST_SAVE_TYPE_REACTIVATE.sql
:r CONST_SVC_REC_STATE_PORT_HEBS.sql
:r CONST_SAVE_TYPE_EDIT.sql
:r CONST_SVC_REC_STATE_HOLD.sql
:r CONST_SAVE_TYPE_DELETE.sql
:r CONST_CLAIM_PURPOSE_CORRECTION.sql
:r CONST_CLAIM_PURPOSE_LINE_1.sql
:r CONST_CLAIM_PURPOSE_LINE_2.sql
:r CONST_CLAIM_PURPOSE_LINE_3.sql
:r CONST_CLAIM_PURPOSE_LINE_4.sql
:r CONST_SERVICES_TRANSPORT.sql
:r CONST_SERVICES_TCM.sql
:r CONST_SERVICES_NON_BILL.sql
:r CONST_PLAN_IFSP.sql
:r CONST_PLAN_IEP.sql
:r CONST_PLAN_NONE.sql
:r CONST_PLAN_CYBHI.sql
:r CONST_PLAN_RU_HEALTH.sql
:r CONST_TIME_UNIT_MIN.sql
:r CONST_MIN_RND.sql
:r CONST_SERVICES_TREATMENT.sql
:r CONST_SERVICES_ASSESS.sql
:r CONST_RET_CODE_SESSION_EXPIRE.sql
:r CONST_REC_STATE_NEW.sql
:r CONST_RET_CRIT.sql
:r CONST_REC_STATE_DEL.sql
:r CONST_RET_ERR.sql
:r CONST_REC_STATE_MOD.sql
:r CONST_RET_FAT.sql
:r CONST_RET_INFO.sql
:r CONST_RET_SUCCESS.sql
:r CONST_TRANS_PROC_NUM_MILES.sql
:r CONST_RET_DUP_RECORD.sql
:r CONST_TRANS_PROC_NUM_TRIPS.sql
:r CONST_RET_WARN.sql
:r CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO.sql
:r CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK.sql
:r CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES.sql
:r CONST_PRAC_GROUP_DISP_LEA.sql
:r CONST_PRAC_GROUP_DISP_LEA_MAA.sql
:r CONST_PRAC_GROUP_REPT.sql
:r CONST_PRAC_GROUP_STATE_ADJUST_ID.sql
:r CONST_PRAC_GROUP_CRE_LIC_NOT_VER_ID.sql
:r CONST_PRAC_GROUP_TRANS_ID.sql
:r CONST_PRAC_GROUP_PROC_NOTE.sql
:r CONST_CLAIM_STATUS_SUB_PENDING.sql
:r CONST_CLAIM_STATUS_SUB_PAID.sql
:r CONST_CLAIM_STATUS_SUB_REJECT.sql
:r CONST_CLAIM_STATUS_NOT_SUB.sql
:r CONST_SVC_REC_STATE_NEW.sql
:r CONST_SVC_REC_STATE_MOD.sql
:r CONST_SVC_REC_STATE_SUB.sql
:r CONST_SVC_REC_STATE_ACCEPT.sql
:r CONST_SVC_REC_STATE_PAID.sql
:r CONST_SVC_REC_STATE_REJ.sql
:r CONST_SVC_REC_STATE_RESUB.sql
:r CONST_SVC_REC_STATE_CLOSED.sql
:r CONST_SVC_REC_STATE_DEL.sql
:r CONST_SVC_REC_STATE_CIF.sql
:r CONST_SVC_REC_AGE_CUTOFF.sql
:r CONST_RPT_ROW_TYPE_DETAIL.sql
:r CONST_RPT_ROW_TYPE_AGR.sql
:r CONST_MAX_DAILY_PRAC_MIN.sql
:r CONST_MAX_SVC_MIN.sql
:r CONST_MAX_SVC_MIN_HA.sql
:r CONST_MAX_TRIP_ONE_WAY_MILES.sql
:r CONST_MSG_PRAC_MAX_DAILY_MINS_REACHED.sql
:r CONST_MSG_SVC_MAX_MINS_REACHED.sql
:r CONST_MSG_ONE_WAY_TRIP_MILES_EXCEEDED.sql
:r CONST_MSG_CASELOAD_DATES_NEQ_DOS.sql
:r CONST_PARENT_GROUP_ID_HEALTH_AID.sql
:r CONST_STANDARD_BUDGET_TARGET_PER_PATIENT.sql
:r CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY.sql
:r CONST_CLAIM_STATUS_RECV_PROXY_PAID.sql
:r CONST_CLAIM_STATUS_RECV_PROXY_DENIED.sql
:r CONST_SERVICES_TMT_WHEN_BS.sql
:r CONST_SERVICES_TMT_WHEN_DS.sql
:r CONST_SERVICES_TMT_WHEN_AS.sql
:r CONST_SERVICES_TMT_HOW_IND.sql
:r CONST_SERVICES_TMT_HOW_GRP.sql
:r CONST_SERVICES_TRANS_LOCATION_HOME.sql
:r CONST_SERVICES_TRANS_LOCATION_SCHOOL.sql
:r CONST_SERVICES_TRANS_LOCATION_OFFSITE.sql
:r CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY.sql
:r CONST_SERVICES_TMT_EXP_MINS_FROM_SCHED.sql
:r CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL.sql
:r CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_FAV.sql
:r CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_NEW.sql
:r CONST_SVCJOURNAL_EVENT_TYPE_START_ACCOMPANY.sql
:r CONST_SVCJOURNAL_EVENT_TYPE_END_ACCOMPANY.sql
:r CONST_SVCJOURNAL_EVENT_TYPE_BREAK_ACCOMPANY.sql
:r CONST_SVCJOURNAL_CONT_SVC_EVENT_DEFAULT_NOTE.sql
:r CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY.sql
:r CONST_PATIENT_PLACE_TYPE_OTHER.sql
:r CONST_PLACE_FORMAT_TYPE_USPS_ADDRESS.sql
:r CONST_PLACE_SOURCE_TYPE_STUDENT_DATA.sql
:r CONST_PLACE_CLASS_CLIENT_SITE.sql
:r CONST_PLACE_CLASS_PATIENT_ADDRESS.sql
:r CONST_PLACE_FORMAT_TYPE_NOT_SPECIFIED.sql
:r CONST_PLACE_SOURCE_TYPE_MGMT_SCREEN.sql
:r CONST_GROUP_SERVICE_CLASS_PARTITION_PLAN_WRITER.sql
:r CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE.sql
:r CONST_SPEECH_ASSMT_SVC_DETAILS_REQUIRED_START_DATE.sql
:r CONST_RMTS_PARTICIPATION_REQUIRED_START_DATE.sql
:r CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE.sql
:r CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP.sql
:r CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS.sql
:r CONST_UNKNOWN_SCHOOL_NAME.sql
:r CONST_NON_PUBLIC_SCHOOL_NAME.sql
:r CONST_SVC_TRACKING_CLASS_SPED.sql
:r CONST_SVC_TRACKING_CLASS_NON_SPED.sql
:r CONST_SVC_TRACKING_CLASS_USER_PROVIDED.sql
:r CONST_MAX_MINS_DAILY.sql
:r CONST_MAX_MINS_WEEKLY.sql
:r CONST_MAX_MINS_MONTHLY.sql

/* General-purpose utility functions */

:r CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE.sql 
:r CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER.sql
:r TIME_HH_MM_ONLY.sql
:r BUILD_PLACE_ADDRESS_STRING.sql
:r BUILD_PLACE_ID_STRING.sql
:r SERVICES_CAN_SHOW_FOR_PLAN_TYPE.sql
:r RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL.sql
:r DATES_HAVE_OVERLAP.sql
:r CALC_STANDARD_DAY_OF_WEEK_NUMBER.sql
:r CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER.sql
:r DATE_GET_PREVIOUS_WEEKDAY.sql
:r CALC_CLOSEST_WEEKDAY.sql
:r AppendStringToFile.sql
:r AppendTableToTextfile.sql
:r CopyFile.sql
:r IS_STRING_TRIMMABLE.sql
:r IS_STRING_ALL_DIGITS.sql
:r IS_VALID_CSIS_SSID.sql
:r IS_VALID_NPI.sql
:r IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW.sql
:r IS_PATIENT_POSSIBLY_LEA_BOP_ELIG.sql
:r IS_AUTO_SELECT_ORP_DOC_POSSIBLE.sql
:r IS_ORP_COMPLIANT.sql
:r IS_CLIENT_PAYING_PER_BATCH_AS_OF_REF_DATE.sql
:r IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION.sql
:r RPT_DATE_FMT.sql
:r RPT_DATE_FMT_WITH_LEADING_ZEROS.sql
:r RPT_DATE_FMT_YYYY_MM_DD.sql
:r RPT_DATE_FMT_MONTH_YEAR.sql
:r RPT_DATE_FMT_STR_TO_DATE.sql
:r RPT_TIME_FMT.sql
:r RPT_TIME_FMT_HH_MM_SS.sql
:r RPT_NAME_TO_INITIALS.sql
:r bigint_2_hexstr.sql
:r hexstr_2_bigint.sql
:r HAS_MOD_IN_SLOT_NUM.sql
:r GENERATE_RANDOM_ALPHA_NUMERIC_STRING.sql
:r GENERATE_PRODUCT_KEY.sql
:r STRING_SPLIT.sql
:r HOLD_CLAIM_GET_COMMON_CLAIM_DATA.sql
:r STRING_UNESCAPE_JSON.sql
:r STRING_UNESCAPE_HTML.sql
:r STRING_STRIP_HTML.sql
:r IS_VALID_FY_ID_AND_QTR_NUM.sql
:r CALC_LEA_REIMBURSEMENT_GOAL_EXPECTED_PROGESS_BY_FY_MONTH.sql
:r CALC_PERCENTAGE.sql
:r CALC_PERCENTAGE_Fulfillment.sql
:r CALC_PROMISED_MINS_SATISFIED_AS_ROW.sql
:r CALC_PROMISED_MINS_SATISFIED.sql
:r SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES.sql
:r DATE_VALUE_OR_REPLACEMENT_IF_GT_LT.sql
:r SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT.sql

:r PATIENT_PROMISED_SERVICES_LATEST_DATA.sql

:r PERSONS_FIND_EXISTING.sql
:r PATIENT_SITES_GET.sql
:r Practitioner_Patient_Scheduled_Services_View_Latest_Related_To_SpEdSvc_Code_Core.sql
:r Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core.sql
:r STRING_REMOVE_NON_ASCII.sql
:r STRING_REMOVE_NON_ALPHA_NUMERIC.sql
:r STRING_REMOVE_EXTRA_SPACES.sql
:r IS_TERM_IN_TAGS.sql
:r STRING_REMOVE_CHARS.sql
:r DETERMINE_PROCEDURE_SELECTION_MODE.sql
:r Practitioner_Qualifications_Parse_JSON_Data.sql
:r Practitioner_Qualifications_View_Core.sql
:r PRACTITIONERS_UPDATE_SITES.sql

/* Patient unique identifier redudancy checks */

:r PATIENT_FIND_REDUNDANT_CSIS_VALUES.sql
:r PATIENT_FIND_REDUNDANT_BIC_VALUES.sql
:r PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES.sql
:r PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES.sql
:r PATIENT_FIND_REDUNDANT_RECORDS_CORE.sql

:r PARSE_EMAIL.sql

/* Patient cleanup checks */

:r PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE.sql
:r PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE.sql

/* Department head related */

:r PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE.sql

/* Caseload utility */

:r PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW.sql

:r SELPA_RELATED_CLIENTS_VIEW_CORE.sql
:r SELPA_RELATED_CLIENTS_VIEW.sql

/* CDE service delivery compliance scoring */

:r CALC_IN_CDE_BUCKET_A.sql
:r CALC_IN_CDE_BUCKET_B.sql
:r CALC_IN_CDE_BUCKET_C.sql
:r CALC_IN_CDE_BUCKET_NAME.sql

/* Our equivalant bucket rating */

:r CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING.sql

/* Date test */

:r DATE_IS_WEEKDAY.sql

/* Date gen functions */

:r CALC_START_END_DATES_BY_WORK_DAY.sql
:r CALC_START_END_DATES_BY_DAY.sql
:r GET_START_END_DATES_BY_WORK_DAY.sql

:r CALC_START_END_DATES_BY_WORK_WEEK.sql
:r CALC_START_END_DATES_BY_WEEK.sql
:r GET_START_END_DATES_BY_WORK_WEEK.sql

:r CALC_START_END_DATES_BY_WORK_MONTH.sql
:r CALC_START_END_DATES_BY_MONTH.sql
:r GET_START_END_DATES_BY_WORK_MONTH.sql

:r CALC_START_END_DATES_BY_WORK_YEAR.sql
:r CALC_START_END_DATES_BY_YEAR.sql

:r FORM_BUILDER_COMBINE_QA_JSON_DATA.sql
:r FORM_BUILDER_JSON_QA_DATA_TO_HTML.sql
:r FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT.sql
:r FORM_BUILDER_JSON_QA_DATA_TO_TEXT.sql
:r IS_PRAC_SUPERVISED_BY_PRAC.sql

/* Patient goal tracking */

:r PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON.sql
:r PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT.sql
:r SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE.sql

/* Retroactive claiming for SPAs */

:r CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID.sql
:r CLAIM_RETROACTIVE_FOR_SPA_PARSE_SELECTION_ID.sql

:r CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE.sql
:r CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE.sql
:r CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW.sql
:r CLAIM_RETROACTIVE_FOR_SPA_POTENTIAL_REIMBURSE_SUMS.sql
:r CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE.sql
:r CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE.sql

:r PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM.sql
:r PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM.sql

/* Direct Supervision part 1/2 */

:r PRACTITIONER_GROUP_REQUIRES_DIRECT_SUPERVISION.sql
:r PRACTITIONER_HAS_QUALIFIED_DIRECT_SUPERVISION.sql
:r PRAC_DIRECT_SUPERVISION_HOLD_CLAIM.sql

/* RMTS part 1/2 */

:r RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE.sql
:r RMTS_HOLD_CLAIM.sql

:r CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE.sql
:r PATIENT_VIEW_KNOWN_BICS.sql
:r PATIENT_VIEW_CLAIMS_837_835_XREF_CORE.sql
:r CLAIM_TCM_FLAG_HISTORY_VIEW.sql
:r COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE.sql
:r PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST.sql
:r GET_DISP_GROUP_FROM_PRAC_ID.sql
:r GET_PLAN_WRITER_SVC_CLASS_NAME_ID_FROM_GROUP_ID.sql
:r GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID.sql
:r GET_STD_SVC_CLASS_NAME_ID_FROM_GROUP_ID.sql
:r GET_ORP_SVC_CLASS_NAME_ID_FROM_PRAC_ID.sql
:r GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI.sql
:r IS_ORP_REQUIRED_FOR_SVC.sql
:r BUILD_NOTE_TEMPLATE_TEXT.sql
:r BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAMES_SAVE.sql
:r ORP_DOCUMENT_STANDARD_SELECTION_NAMES_DELETE.sql
:r ORP_DOCUMENTS_DATA_CORE.sql
:r ORP_DOCUMENT_IS_IN_ACTIVE_USE.sql
:r ORP_DOCUMENTS_VIEW_CORE.sql
:r ORP_DOCUMENTS_VIEW.sql

:r ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA.sql
:r GET_ORP_PRAC_NPI_DATA.sql
:r RPT_DETERMINE_ORP_STATUS.sql
:r RPT_NON_ORP_COMPLIANT_SVCS.sql
:r CLAIMS_NOT_SUBMITTED_CURRENT_ORP_STATUS_VIEW.sql
:r UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA.sql

:r CLEAN_PATIENT_DATA_NAMES.sql
:r CLEAN_PATIENT_DATA_CSIS_SSID.sql
:r CLEAN_PATIENT_DHCS_NAMES.sql
:r CLEAN_PATIENT_CASELOAD_AND_GROUP_DATA.sql
:r CLEAN_PATIENT_DATA.sql
:r CLAIM_DETAIL_CODES_UPDATE_REQUIRED_REMINDER.sql
:r PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS.sql

:r CALC_CLAIM_AMOUNT.sql
:r CALC_REIMBURSE_ESTIMATE.sql
:r CLAIMS_AMOUNT_CALC.sql

:r TIME_STR_TO_TIME_VAL.sql
:r CALC_HUMAN_BYTE_SIZE.sql
:r CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS.sql
:r CALC_HUMAN_FRIENDLY_RELATIVE_DATE.sql
:r CLAIM_PROCEDURE_PROC_MOD_COMBO_STRS_TO_FIELDS.sql
:r CLAIM_PROCEDURE_COMPARE.sql
:r CALC_OVERLAP_TIME_AB_CD.sql
:r TIME_ROUND_15_MIN.sql
:r GENERATE_NEW_UNIQUE_ID.sql
:r CREATE_UNIQUE_ID.sql
:r levenshtein.sql
:r DATE_SEQUENCE.sql
:r YEAR_RANGE_SEQUENCE.sql
:r YEAR_RANGE_WINDOW.sql
:r DATE_CREATE_FROM_PARTS.sql
:r DATE_TIME_COMBINE.sql
:r CREATE_CONCAT_NAME.sql
:r CALC_DIFFERENCE.sql
:r BANKERS_ROUND.sql
:r RPT_PAD_LEFT.sql
:r RPT_WEEKDAYS_SELECTED.sql
:r RPT_FRQ_DUR.sql
:r RPT_TMT_SCHEDULE.sql
:r RPT_PROC_MOD_COMBO.sql
:r STRING_SUB.sql
:r STRING_WRAP.sql
:r STRING_REMOVE_LEADING_ZEROS.sql
:r CREATE_NAME_PAT.sql
:r CREATE_SEARCH_PAT.sql
:r IS_PRAC_GROUP_MAA_NOT_MAA_PAIR.sql
:r IS_PRAC_GROUP_SAME_BASE.sql
:r CALC_YEAR_QUARTERS.sql
:r CALC_12_MONTHS_TABLE.sql
:r CALC_TIME_SLOTS.sql
:r GET_FY_START_OR_END.sql
:r DATE_IN_WHAT_FY.sql
:r DATE_IS_IN_FY_QTR.sql
:r DATE_MONTH_START_END.sql
:r CALC_AGE_IN_MONTHS.sql
:r CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM.sql
:r DATE_OR_MIN_MAX.sql
:r UPDATE_DETAILS.sql
:r YN_TO_BIT.sql
:r FLAG_STRING_TO_BIT.sql
:r CALC_AGE.sql
:r CALC_OLDEST_DOS_ALLOWED.sql
:r CALC_TRIP_MILES.sql
:r CALC_TOTAL_TRIPS_4.sql
:r CLAIM_STATUS_TO_NAME.sql
:r DATE_START.sql
:r DATE_START_OR_NULL.sql
:r DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL.sql
:r DATE_ONLY.sql
:r CALC_AGE_IN_DAYS.sql
:r CALC_TOTAL_MILES_4.sql
:r DATE_END.sql
:r DATE_IS_PAST.sql
:r DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE.sql
:r BIT_TO_YN.sql
:r BIT_TO_MSG.sql
:r ProcedureType.sql
:r STRING_FIND.sql
:r RPT_ROUND_FMT.sql
:r RPT_BIT_TO_YN.sql
:r RPT_BIT_TO_YNU.sql
:r RPT_BIT_TO_YNB.sql
:r RPT_MINUTES_OR_START_END_MILES.sql
:r CALC_MON_TO_FRI_DATES_FOR_START_DATE.sql
:r CALC_LAST_OR_NEXT_N_WEEK_START_AND_END_DATES.sql
:r RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS.sql
:r CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE.sql
:r CLAIM_PROCEDURES_UPDATE_SERVICE_FEES.sql
:r BUILD_PLR_ID_STRING.sql
:r BUILD_SERVICE_DETAILS_STRING.sql
:r BUILD_SERVICE_NAME_STRING.sql
:r BUILD_FULL_SERVICE_NAME_STRING.sql
:r BUILD_SVC_NOTES_TEXT.sql
:r CDS_7_IS_X_CODE.sql

:r SITE_IS_UNKNOWN_FLAG.sql
:r GET_SITE_ID_UNKNOWN_SCHOOL.sql
:r GET_SITE_ID_NON_PUBLIC_SCHOOL.sql


:r GET_SITE_INFO_UNKNOWN_SCHOOL.sql
:r GET_SITE_INFO_NON_PUBLIC_SCHOOL.sql

:r CREATE_OR_GET_SITE_INFO_UNKNOWN_SCHOOL_CORE.sql
:r CREATE_OR_GET_SITE_INFO_NON_PUBLIC_SCHOOL_CORE.sql


:r SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE.sql
:r SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED.sql
:r SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY.sql
:r SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE.sql
:r PATIENT_VIEW_CLAIM_STATUS_STATISTICS.sql
:r PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS.sql

:r CLAIMS_DENIED_VIEW_DATA_CORE.sql
:r CLAIMS_DENIED_VIEW_CORE.sql
:r CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE.sql
:r CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE.sql
:r CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE.sql

:r CLAIM_RESUBMIT_DENIED_CORE.sql
:r CLAIM_RESUBMIT_DENIED.sql
:r CLAIMS_RESUBMIT_DENIED.sql
:r CLAIMS_RESUBMIT_FOR_PATIENTS.sql

:r GROUPS_VIEW_CORE_2.sql
:r PRACTITIONER_GROUPS_VIEW_CORE.sql
:r GROUPS_VIEW_CORE.sql
:r GROUP_REPT_VIEW_ALL.sql
:r GROUP_DISP_VIEW_ALL.sql
:r GROUP_DISP_SUPER_VIEW_ALL.sql
:r PRACTITIONER_GROUPS_VIEW_DISP.sql
:r PRACTITIONER_GROUPS_VIEW_REPT.sql
:r GROUPS_VIEW.sql
:r CLAIM_RECORDS_PAID.sql
:r CLAIM_RECORDS_PAID_BY_DOS.sql
:r INPUT_NOTES_PAT.sql
:r SERVICE_RECORD_LAST_MODIFIED_BY.sql
:r INPUT_NOTES_CLIENT.sql
:r INPUT_NOTES_PRAC.sql
:r CLAIM_RECORDS_VIEW.sql
:r MULTI_DATE_PARSE.sql
:r MULTI_RECORD_ID_PARSE.sql
:r PARSE_PLACE_ID_STRING.sql
:r STRING_IS_NULL_OR_EMPTY.sql
:r STRING_HAS_VALUE.sql
:r INT_HAS_VALUE.sql
:r INT_CAPPED_AT_MAX.sql
:r INT_CAPPED_AT_MIN.sql
:r STRING_COALESCE.sql
:r PATIENT_Audit.sql
:r PRACTITIONERS_Audit.sql
:r SERVICE_RECORD_Audit.sql
:r STRING_CREATE.sql
:r STRING_FOUND.sql
:r DATE_IS_PAST_CURRENT.sql
:r GROUP_FIND_PARENT.sql
:r CALC_AGE_CURRENT.sql
:r CALC_TOTAL_MILES_8.sql
:r CALC_TOTAL_TRIPS_8.sql
:r AGE_IEP_TO_PLAN_TYPE.sql
:r PLAN_TYPE_TO_NAME.sql
:r RPT_TRIPS_MILES.sql
:r PAT_ELIGIBILITY_FLAG_VALUE.sql
:r MAN_PAGE_TO_SERVICE_TYPE.sql
:r SERVICE_TYPE_TO_NAME.sql
:r PAT_ELIGIBILITY_ESTIMATE.sql


:r SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME.sql
:r SERVICE_RECORD_SELECTION_ID_TO_ATTENDANCE_FLAGS.sql
:r SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS.sql
:r PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE.sql
:r SERVICE_STATE_TO_NAME.sql
:r SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG.sql
:r SERVICE_RECORD_IS_EDITABLE.sql

:r SITE_PLACES_VIEW_CORE.sql
:r SITE_PLACES_VIEW.sql
:r SITES_AUDIT.sql
:r SITES_Save.sql
:r SITES_Delete.sql
:r SITES_Undelete_Core.sql
:r SITES_Undelete.sql
:r SITES_VIEW.sql
:r CLIENTS_VIEW.sql
:r CLIENTS_VIEW_ALL.sql
:r CLIENT_VIEW_GROUPS.sql
:r PRACTITIONER_VIEW_GROUP_HISTORY_CORE.sql
:r PRACTITIONER_VIEW_GROUP_HISTORY.sql
:r PRAC_VIEW_GROUP_ASSIGNMENTS.sql
:r SERVICE_RECORDS_VIEW_EDITABLE.sql
:r SERVICES_VIEW_ALL_CORE.sql
:r SERVICES_GENERATE_AND_VIEW_ALT_MODALITY.sql
:r SERVICES_VIEW_ALL.sql
:r SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID.sql

:r PATIENT_PERSONS_VIEW_CORE.sql
:r PATIENT_USER_ACCOUNTS_VIEW_CORE.sql

:r SERVICE_NAME_LOOKUP.sql
:r DATE_RANGE_SPLIT.sql
:r RPT_SERVICE_RECORD_TATTLE_CORE.sql --TODO: deprecated; believed to no longer be in use; remove when safe
:r RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS.sql  --TODO: deprecated; believed to no longer be in use; remove when safe
:r RPT_SERVICE_RECORD_TATTLE.sql  --TODO: deprecated; believed to no longer be in use; remove when safe
:r RPT_TATTLETALE.sql
:r CASELOAD_VIEW_BY_DATE.sql

:r CALC_PERIOD_FIRST_OR_LAST_NUM.sql
:r CLIENT_ATTENDENCE_CALENDAR_SCHEDULE_DOS_DETAIL.sql
:r CALC_EXPECTED_MINUTES.sql
:r RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL.sql
:r RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE.sql

:r PRACTITIONERS_DATA_CORE.sql
:r PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID.sql
:r PRACTITONERS_VIEW_USERS.sql
:r PRACTITONERS_VIEW_CORE.sql
:r PRACTITONERS_VIEW_EDITABLE.sql
:r PRACTITONERS_VIEW.sql
:r RPT_CRC_Claims.sql
:r RPT_CLIENT_WORK_NOT_RECIEVED.sql
:r RPT_COMBINED_1on1_BY_PAYMENT_DATE.sql
:r RPT_COMBINED_1on1_BY_SERVICE_DATE.sql
:r RPT_CLAIMS_PAID_BY_DATE_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_BY_PRAC_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_1P_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_1P.sql
:r RPT_CLAIMS_PAID_BY_DATE_2P_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_2P.sql
:r CALC_ELIGIBILITY.sql
:r DOS_DOB_IEP_TO_PLAN_TYPE.sql
:r DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE.sql
:r PAT_SITE_ON_DOS.sql
:r PAT_DOS_ELIGIBILITY.sql
:r SERVICES_VIEW_REFERENCE.sql
:r SERVICES_VIEW_BY_PRAC_PAT_PLAN.sql
:r PRAC_VIEW_BY_CLIENT.sql
:r SERVICE_RECORDS_DATA_CORE.sql
:r SERVICE_RECORDS_VIEW_CORE.sql
:r RPT_RMTS_MOMENT_SERVICE_RECORDS.sql
:r PATIENT_ELIGIBILITY.sql
:r SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP.sql
:r SERVICES_VIEW.sql
:r SERVICES_TMT_TCM_TRAN_VIEW.sql
:r SERVICE_RECORDS_VIEW.sql

-- patient data imports parse 1 of 2
:r Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use.sql
:r Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON.sql
:r Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON.sql
:r Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core.sql
:r Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core.sql

:r PATIENT_PROMISED_SERVICES_VIEW_CORE.sql
:r PATIENT_PROMISED_SERVICES_VIEW.sql

--:r PRACTITIONERS_PATIENTS_VIEW.sql
:r PATIENTS_DATA_CORE.sql
:r PATIENTS_VIEW_CORE.sql
:r PATIENTS_SITES_VIEW_CURRENT.sql
--:r PATIENTS_SITES_VIEW_CUST.sql    -- not currently being used
:r PATIENTS_VIEW.sql
:r PATIENT_VIEW_ELIGIBILITY_INFO.sql
:r PATIENT_VIEW_SERVICE_HISTORY_CORE.sql
:r PATIENT_VIEW_SERVICE_HISTORY.sql
:r PATIENT_VIEW_SERVICE_HISTORY_13M.sql
:r PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS.sql
:r PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS.sql
:r PATIENT_VIEW_SHORT_SERVICE_HISTORY.sql

/* Raw closure table methods */

:r CLOSURE_VERIFY_NODE_EXISTS.sql
:r CLOSURE_CHECK_CYCLES.sql

:r CLOSURE_CREATE_IDENTITY.sql
:r CLOSURE_CREATE_LINK.sql
:r CLOSURE_DELETE_LINK.sql

:r CLOSURE_TYPE_TREE_VIEW.sql
:r CLOSURE_TREE_RELTYPE_DEPTH_VIEW.sql


/*************************************/
:r SVCNOTES_DELETE_NOTEANSWERS.sql
:r SVCNOTES_RESET_NOTE_ANSWERS.sql
:r SVCNOTES_DELETE_NOTE.sql
:r SVCNOTES_RESET_NOTE.sql
:r SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS.sql
:r SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD.sql

:r CALC_Claims_Units_For_Time_Unit_Range.sql
:r CALC_Claims_Units_For_Time_Unit_Fixed.sql
:r CALC_Claims_Units_For_Time_Units.sql
:r CALC_Claims_Procedures.sql
:r CALC_Claims_Units.sql
:r CALC_Claims_Procedures_Units.sql
:r CALC_Claims.sql

:r SERVICE_DATA_TO_CLAIMS_DATA.sql
:r SERVICE_RECORD_MANAGE_CLAIMS_CORE.sql

:r SERVICE_RECORD_INITIATE_CIF_Core.sql
:r SERVICE_RECORD_DELETE_CORE.sql
:r SERVICE_RECORD_Delete.sql
:r SERVICE_RECORD_Delete_Batch.sql
:r SERVICE_RECORD_Delete_Inline.sql

:r PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core.sql
:r PATIENT_PROMISED_SERVICE_Delete_Inline.sql
:r PATIENT_PROMISED_SERVICE_Save_Core.sql
:r PATIENT_PROMISED_SERVICE_Save.sql

:r SERVICE_RECORD_INITIATE_CIF.sql
:r SERVICE_RECORD_INITIATE_CIF_BATCH.sql
:r SERVICE_RECORD_Generate_Claims_For_HEBS.sql
:r PATIENT_PLACES_SAVE_CORE.sql
:r PATIENT_Save.sql
:r PATIENTS_Delete.sql
:r PRACTITIONERS_Save.sql
:r PRACTITIONERS_Delete.sql

:r PRACTITIONER_FLAG_CURRENTLY_W_CLIENT.sql

:r PRACTITIONERS_ASSIGN_USER_CORE.sql
:r PRACTITIONERS_ASSIGN_USER.sql
:r CLIENTS_AUDIT.sql
:r CLIENTS_Save.sql
:r CLIENTS_Delete.sql

:r SERVICE_RECORD_BATCH_ID_Create.sql
:r SERVICE_RECORD_BATCH_ID_Assign.sql

:r SVCNOTES_CREATE_CLOSURE_CHILD.sql
:r SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION.sql
:r SVCNOTES_CREATE_CLOSURE_QUESTION_SUBSET.sql
:r SVCNOTES_CREATE_CLOSURE_CHILD_ANSWER.sql
:r SVCNOTES_CREATE_CLOSURE_ANSWER_SUBSET.sql
:r SVCNOTES_CREATE_CLOSURE_QUESTION_PROGRESSION.sql
:r SVCNOTES_DELETE_CLOSURE_LINKAGE.sql
:r SVCNOTES_CREATE_CLOSURE_QUESTION_ANSWER_PROGRESSION.sql

:r SVCNOTES_NOTE_QUESTION_ANSWER_BUILD_HEADER.sql
:r SVCNOTES_NOTE_QUESTION_ANSWERS_VIEW.sql
:r SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW.sql
:r SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW.sql
:r SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW.sql

:r SVCNOTES_NOTE_QUESTIONS_VIEW.sql
:r SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW.sql

:r SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID.sql
:r SVCNOTES_NOTE_QUESTION_GET_PREVIOUS_ID.sql
:r SVCNOTES_NOTE_QUESTION_GET_NEXT_ID.sql

:r SVCNOTE_PRAC_PREF.sql
:r SVCNOTE_TEMPLATE_PREFERENCE_PRAC.sql
:r SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE.sql
:r SVCNOTE_PRAC_PREF_VALUE_VIEW.sql
:r SVCNOTES_CHECK_PRAC_PREF.sql
:r SVCNOTE_PREFERENCE_TYPES_VIEW.sql
:r SVCNOTES_PRAC_PREFERENCE_SAVE.sql
:r SVCNOTES_NOTES_VIEW.sql
--:r SVCNOTES_NOTE_SELECTIONS_VIEW.sql
:r SVCNOTES_CREATE_NOTE.sql
:r SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD.sql
:r SVCNOTES_CREATE_QUESTION.sql
:r SVCNOTES_CREATE_ANSWER.sql
:r SVCNOTES_CREATE_PRAC_FAV_ANSWER.sql
:r SVCNOTES_CREATE_CUSTOM_ANSWER.sql

:r SVCNOTES_APPEND_NOTE_NOTEANSWER.sql
:r SVCNOTES_APPEND_NOTE_NOTEANSWERS.sql
:r SVCNOTES_Preference_Template_Create.sql

/* Practitioner group association */

:r PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW.sql

/* Practitioner group supervisors and supervised groups */

:r GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE.sql
:r GROUPS_SUPERVISED_VIEW.sql
:r GROUPS_SUPERVISING_VIEW.sql
:r GROUPS_SUPERVISED_BY_GROUP_ID_VIEW.sql
:r GROUPS_SUPERVISING_GROUP_ID_VIEW.sql

:r PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW.sql
:r PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW.sql
:r PRACTITIONERS_SUPERVISING_GROUP_ID_VIEW.sql
:r PRACTITIONERS_SUPERVISING_PRAC_ID_VIEW.sql

/* Service journal */

:r SvcJournal_Related_Svc_Records_Data_Core.sql
:r SvcJournal_Can_Edit.sql
:r SVCJOURNAL_JOURNAL_REOPEN_CORE.sql

/* Service records to approve Part 1/2 */

:r SERVICE_RECORDS_APPROVAL_ASSIGN_OR_UNASSIGN_SUPERVISOR_BY_PRAC_ID.sql
:r SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE.sql
:r SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PRAC_ID.sql

/* Undelete/Reactivate procedures */

:r PRACTITIONERS_Undelete_Core.sql
:r PRACTITIONERS_Undelete.sql
:r PATIENTS_Undelete_Core.sql
:r PATIENTS_Undelete.sql

/* Service record saves */

:r SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS.sql
:r SERVICE_RECORD_SAVE_REACTIVATE_PRAC_OR_PAT_CORE.sql

:r SERVICE_RECORD_VIEW_REDUNDANT_ENTRIES_CORE.sql

/* Add a new sql */
:r SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE.sql
:r SERVICE_RECORD_Save_Core.sql
:r SERVICE_RECORD_Save.sql
:r SERVICE_RECORD_Save_Batch.sql
:r SERVICE_RECORD_Save_Batch_One_On_One.sql
:r SERVICE_RECORD_Save_Batch_Multi_Encounter.sql
:r SERVICE_RECORD_Save_Vision_Hearing_Screening.sql
:r SERVICE_RECORD_Save_Batch_Caseload_For_Dos_Save.sql
:r SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc.sql

:r SERVICE_RECORD_Save_Inline.sql
:r SERVICE_RECORD_Flag_Existing_As_RMTS_Moment.sql
:r SERVICE_RECORD_Clone_Core.sql

:r RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC.sql
:r RMTS_LaunchAutoMatch.sql

:r CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW.sql
:r CLAIMS_PROCESSING_EXCEPTION_VIEW.sql
:r CLAIMS_PROCESSING_EXCEPTIONS_Audit.sql
:r CLAIMS_PROCESSING_EXCEPTION_Save.sql
:r CLAIMS_PROCESSING_EXCEPTION_Delete.sql
:r CLAIMS_EXCEPTIONS_APPLY.sql
:r CLIENT_REPS_VIEW.sql
:r COMPANIES_VIEW.sql
:r CLAIM_PROCEDURES_VIEW.sql
:r CLAIM_PROCEDURES_Audit.sql
:r CLAIM_PROCEDURES_Save.sql
:r CLAIM_PROCEDURES_Delete.sql
:r CLAIM_IEPandIFSPNames_LIST_VIEW.sql
:r CLAIM_NoPlanNames_LIST_VIEW.sql
:r CLAIM_PROCEDURE_FEES_VIEW.sql
:R CLAIM_PROCEDURE_FEES_Audit.sql
:r CLAIM_PROCEDURE_FEES_Save.sql
:r CLAIM_PROCEDURE_FEES_Delete.sql
--:r PATIENTS_VIEW_SEL.sql
:r MANAGE_INDEXES.sql
:r INPUT_BATCHES_Audit.sql
:r INPUT_BATCHES_VIEW.sql
:r INPUT_BATCHES_SAVE.sql
:r INPUTBATCHES_Save.sql
:r INPUTBATCHES_Delete.sql
:r INPUT_BATCHES_FILE_LIST_CORE.sql
:r INPUT_BATCHES_FILE_LIST_LAST_14.sql
:r STAFF_PROMISED_HOURS_VIEW.sql
:r STAFF_PROMISED_HOURS_Save.sql
:r TRAINED_STAFF_VIEW.sql
:r TRAINED_STAFF_Save.sql
:r STAFF_TrainedandAvailable_VIEW.sql
:r STAFF_AUDIT_REVIEW_Save.sql
:r RPT_AUDIT_REVIEW.sql
:r RPT_STAFF_TRAINING_RECORDS.sql
:r NORMALIZE_PATIENT_ELIGIBILITY_RECORD.sql
:r NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS.sql
:r PATIENTS_VIEW_CLAIMABLE.sql
:r CLAIM_PAID_BY_DATE_PAT_PRAC_COMBOS.sql
:r CLAIM_PAID_BY_DATE_PAT_PRAC_COMBOS_WITH_CASEMIS.sql
:r RPT_CLAIMS_PAID_BY_DATE_BY_PAT_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE.sql
:r RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS.sql
--:r RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_1P.sql
:r RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P.sql
-- MAA cross queries start
:r PRACTITONERS_VIEW_LEA_MAA_XREF_CORE.sql
:r PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH.sql
-- MAA cross queries end
:r CLIENT_PRAC_PAT_MIN_MAX_SVC_DATES.sql
--:r PATIENTS_PRAC_CASE_LOAD_ADD.sql
--:r PATIENTS_PRAC_CASE_LOAD_REM.sql
:r CASELOAD_View.sql
:r CASELOAD_Audit.sql
:r CASELOAD_Save.sql
:r CASELOAD_Delete.sql

--Workflow 2.0
:r STAFF_REVIEW_Save.sql
:r STAFF_REVIEW_Delete.sql
:r RPT_STAFF_REVIEWS.sql
:r RPT_PRACTITONERS_REVIEWS.sql
:r PRACTITIONERS_REVIEW_Save.sql
:r PRACTITIONERS_REVIEW_Delete.sql
:r PRACTITIONERS_SENT_EMAIL_INFO_Save.sql

-- Report subscription and distribution

:r DECODE_FLAG.sql
:r IS_EMAIL_IN_CLIENT_DOMAIN.sql
:r REPORT_PUBLICATION_VIEW.sql
:r REPORT_PUBLICATION_SUBSCRIBERS_Audit.sql
:r REPORT_PUBLICATION_SUBSCRIBER_Save.sql
:r REPORT_PUBLICATION_SUBSCRIBER_VIEW.sql
:r REPORT_PUBLICATION_SUBSCRIBER_Delete.sql
:r REPORT_PUBLICATION_SUBSCRIPTIONS_Audit.sql
:r REPORT_PUBLICATION_SUBSCRIPTION_Save.sql
:r REPORT_PUBLICATION_SUBSCRIPTION_Delete.sql
:r REPORT_PUBLICATION_SUBSCRIPTION_VIEW.sql
:r REPORT_PUBLICATION_DISTRIBUTION_VIEW.sql
:r REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save.sql
:r REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY.sql
:r DATE_WEEK_NUMBERS.sql
:r REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE.sql
:r REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE.sql
:r REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE.sql
:r REPORT_PUB_MAN_DIST_VIEW.sql
:r REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES.sql
:r REPORT_PUBLICATION_MISSING_REF_DATES.sql
-- Throw away code, remove when done
:r REPORT_PUBLICATION_SUBSCRIBER_SUBSCRIPTION_IMPORT.sql
-- End of throw away code

--Worflow 3.0

:r LEA_FY_PermanentData.sql
:r LEA_FY_PermData_Tbl_Defs.sql
:r HOURS_ON_HAND.sql
:r MEDI_CAL_ELIGIBILITY_DATA.sql
:r HOLIDAYS.sql
:r RPT_AnI_WEEKLY.sql
:r HOURS_LEFTOVER.sql
:r HOURS_ASSIGNED.sql
:r RPT_SBSC_STAFF_HOURS_SUMMARY.sql
:r RPT_WF_CLIENT_DETAILS_SUMMARY.sql

-- Calendars and Bell Schedules

-- Years

:r CLIENT_ATTENDANCE_YEARS_VIEW.sql

-- Day types

:r CLIENT_ATTENDANCE_DAY_TYPES_Audit.sql
:r CLIENT_ATTENDANCE_DAY_TYPES_Save.sql
:r CLIENT_ATTENDANCE_DAY_TYPES_VIEW.sql

-- Calendars

:r CLIENT_ATTENDANCE_CALENDAR_Audit.sql
:r CLIENT_ATTENDANCE_CALENDAR_VIEW.sql
:r CLIENT_ATTENDANCE_CALENDAR_Save.sql

:r CLIENT_ATTENDANCE_CALENDAR_DATES_Audit.sql
:r CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW.sql
:r CLIENT_ATTENDANCE_CALENDAR_DATES_Save.sql
:r CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE.sql
:r CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE.sql

-- Schedules

:r CLIENT_ATTENDANCE_SCHEDULE_Audit.sql
:r CLIENT_ATTENDANCE_SCHEDULE_VIEW.sql
:r CLIENT_ATTENDANCE_SCHEDULE_Save.sql

:r CLIENT_ATTENDANCE_SCHEDULE_TIMES_Audit.sql
:r CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW.sql
:r CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save.sql

:r CLIENT_ATTENDANCE_DAY_TYPES_DELETE.sql
:r CLIENT_ATTENDANCE_SCHEDULE_TIMES_DELETE.sql
:r CLIENT_ATTENDANCE_SCHEDULE_DELETE.sql
:r CLIENT_ATTENDANCE_CALENDAR_DATES_DELETE.sql
:r CLIENT_ATTENDANCE_CALENDAR_DELETE.sql

-- One on one aide assignment

:r ONE_ON_ONE_AIDE_TYPES_VIEW.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_Audit.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_Save.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_Delete.sql
:r ONE_ON_ONE_AIDE_PROCS_VIEW.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY.sql
:r ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED.sql

-- Patient Groups

:r PRACTITIONER_PATIENT_GROUP_Audit.sql
:r PRACTITONER_PATIENT_GROUPS_Save.sql
:r PRACTITONER_PATIENT_GROUPS_View.sql
:r PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED.sql
:r SERVICE_RECORD_Save_Batch_Group_Service.sql
:r PRACTITONER_PATIENT_GROUPS_Delete.sql

-- Workflow Work control

:r INPUT_BATCHES_WORK_CONTROL_Audit.sql
:r INPUT_BATCHES_WORK_CONTROL_View.sql
:r INPUT_BATCHES_WORK_CONTROL_Save.sql
:r INPUT_BATCHES_WORK_CONTROL_Delete.sql
:r INPUT_BATCHES_WORK_CONTROL_CHECK.sql

-- Recurring Services

:r RECURRING_SERVICES_Audit.sql
:r RECURRING_SERVICES_CHECK_DUPS.sql
:r RECURRING_SERVICES_SAVE_REACTIVATE_PRAC_OR_PAT_CORE.sql
:r RECURRING_SERVICES_Save.sql
:r T_SQL_JSON.sql
:r RECURRING_SERVICES_VIEW_DETAILS_PRAC.sql
:r RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_MIN_BASED.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_MIN_BASED_JSON.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED.sql
:r RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED_JSON.sql
:r RECURRING_SERVICES_VIEW.sql
:r RECURRING_SERVICES_Delete.sql
:r RECURRING_SERVICES_OpEnd.sql

-- Claims held/release proxy

:r CLAIMS_TO_SUBMIT_VIEW_CORE.sql
:r SERVICE_SLOTS_VIEW_CORE.sql
:r CLAIMS_TO_HOLD_VIEW_CORE.sql
:r CLAIMS_TO_RELEASE_VIEW_CORE.sql
:r CLAIMS_HOLD_PROCESS.sql
:r CLAIMS_PROXY_CREATE.sql
--:r CLAIMS_PROXY_Open.sql
:r CLAIMS_RELEASE_PROCESS.sql
:r CLAIMS_HOLD_RELEASE_PROCESS.sql
:r CLAIMS_PROXY_DISBURSE_VIEW_CORE.sql

--Proxy Claim Disbursal to Orig Claims
:r Claims_Proxy_Disburse.sql

--Student Data Tracking

:r STUDENT_DATA_TRACKING_VIEW.sql
:r STUDENT_DATA_TRACKING_Audit.sql
:r STUDENT_DATA_TRACKING_RECORD_Save.sql
:r STUDENT_DATA_TRACKING_RECORD_Delete.sql

:r STUDENT_DATA_FILES_TO_REQUEST.sql

:r STUDENT_DATA_FILE_TYPES_View.sql
:r STUDENT_DATA_FILE_TYPES_Save.sql
:r STUDENT_DATA_FILE_TYPE_Delete.sql

:r CLIENT_STUDENT_DATA_FILES_VIEW.sql
:r CLIENT_STUDENT_DATA_FILES_Audit.sql
:r CLIENT_STUDENT_DATA_FILES_Save.sql
:r CLIENT_STUDENT_DATA_FILES_Delete.sql

:r CLIENT_STUDENT_DATA_CONTACT_VIEW.sql
:r CLIENT_STUDENT_DATA_CONTACT_Audit.sql
:r CLIENT_STUDENT_DATA_CONTACT_Save.sql

-- Qforms project
:r STAMPS_Audit.sql
:r STAMP_Save.sql
:r STAMP_Delete.sql
:r STAMPS_VIEW.sql

-- CDE Schools Data

:r CDE_SCHOOLS_SITES_CURRENT_VIEW.sql
:r CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW.sql
:r CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW.sql
:r CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW.sql
:r CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW.sql

:r CONST_FILE_UPLOAD_STATUS_INITIAL.sql
:r CONST_FILE_UPLOAD_STATUS_DATA_FORM_CANCEL_OR_RESET.sql
:r CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE.sql
:r FILE_UPLOAD_SET_STATUS.sql
:r FILE_UPLOAD_SAVE.sql
:r FILE_UPLOAD_CANCEL_OR_RESET.sql

-- File class and types

:r FILE_CLASS_VIEW.sql
:r FILE_CLASS_AND_TYPE_CORE_VIEW.sql
:r FILE_UPLOAD_CLASS_VIEW.sql
:r FILE_UPLOAD_TYPE_VIEW.sql
:r FILE_UPLOAD_REQUEST_SAVE.sql

:r FILE_UPLOADS_PROCESSING_UPDATE_STATUS_MAN.sql

-- Generic entity view

:r STRING_SPLIT_TO_PART_BY_IDX.sql
:r PARSE_SEARCH_TERM.sql
:r SPEDMON_ENTITIES_VIEW_CORE.sql
:r SPEDMON_ENTITIES_VIEW.sql

-- Claim transmission

:r CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS.sql
:r CLAIMS_TRANSMISSION_LIST_VIEW.sql
:r Claims_Transmission_ReportHowMuch.sql
:r Claims_TransmissionRecord_HowMuch.sql
:r Claims_Generate_Claims_For_Transmission.sql

-- Claim Posting
:r CLAIMS_POST_835_FIND_ERR_CODE.sql
:r Claims_Post_835_File.sql

-- Data Driven Web Forms

:r FORM_CREATE_FORM.sql

:r FORM_CREATE_PART.sql

:r FORM_CREATE_FROMWHAT_PART.sql
:r FORM_CREATE_SELECTBOX_PART.sql
:r FORM_CREATE_SEARCHBOX_PART.sql


:r FORM_CREATE_FLAT_PART.sql
:r FORM_CREATE_TEXTBOX_PART.sql
:r FORM_CREATE_NOTEBOX_PART.sql
:r FORM_CREATE_DATEBOX_PART.sql
:r FORM_CREATE_YESNOBOX_PART.sql
:r FORM_CREATE_CHECKBOX_PART.sql
:r FORM_CREATE_NUMBERBOX_PART.sql
:r FORM_CREATE_NUMBERSLIDER_PART.sql
:r FORM_CREATE_FILEBOX_PART.sql

:r FORM_CREATE_PAGE.sql

:r FORM_CREATE_STARTING_PAGE.sql

:r FORM_CREATE_PAGE_PART_CONDITION.sql

:r FORM_CREATE_CONDITION_PAGE_LINK.sql

:r FORM_PAGE_CLEAR.sql

:r FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE.sql
:r FORM_PAGES_PARTS_SELECT_ENTITY_VIEW.sql

:r FORM_FORM_VIEW.sql
:r FORM_PAGES_VIEW.sql
:r FORM_PAGES_PARTS_VIEW.sql
:r FORM_PAGES_PARTS_REQ_ENT_VIEW.sql

:r FORM_FORM_SUBMIT.sql
:r FORM_PAGE_SUBMIT.sql
:r FORM_PAGE_PART_SUBMIT.sql
:r FORM_FORM_CANCEL.sql

:r FORM_CONDITION_OPERATOR_COMPARE.sql
:r FORM_CONDITION_OPENPAGE_NULLSET.sql
:r FORM_CONDITION_OPENPAGE_OPCOMSET.sql
:r FORM_CONDITION_OPENPAGE_VIEW.sql
:r FORM_CONDITION_NEXT_OPENPAGE.sql
:r FORM_CONDITION_PREV_PAGE.sql

:r FORM_REQUEST_STATUS_VIEW.sql

:r FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP.sql
:r FORM_PAGE_PART_COMPLETE_FILE_UPLOAD.sql

:r FORM_FORM_COMPLETE.sql
:r FORM_FORM_COPY_SUBMITTED_INTO_NEW.sql
:r FORM_SUBMITTED_DATA_VIEW_CORE.sql
:r FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF.sql
:r FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE.sql
:r FILE_UPLOAD_GENERATE_FILE_AS_NAME.sql
:r FILE_UPLOAD_VIEW_FILE_STORAGE_DATA.sql
:r FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA.sql
:r FILE_UPLOAD_DATA_RECORD_CORE.sql
:r FILE_UPLOADS_PROCESSING_VIEW.sql

:r FILE_UPLOAD_VIEW_CORE.sql
:r FILE_UPLOAD_VIEW.sql
:r FILE_UPLOAD_VIEW_RPT.sql
:r FILE_UPLOAD_VIEW_STATUS.sql
:r FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE.sql
:r FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE.sql
:r FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE.sql
:r FILE_UPLOAD_POST_PROCESS_INCOMING_FILE.sql
:r FILE_UPLOAD_VIEW_FORM_DATA.sql

/* Alteration to invoice collection date - this wasn't integrated previously */

:r Clients_Post_Invoice_Collection_Date.sql
:r SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC.sql
:r SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE.sql
:r SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE.sql
:r SERVICE_RECORDS_VIEW_SVC_NOTES.sql
:r INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE.sql
:r INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW.sql
:r INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO.sql

/* Create invoice routine */

:r Clients_Create_Invoice.sql

/* Service records to approve Part 2/2 */

:r SERVICE_RECORDS_REVIEW_VIEW_CORE.sql
:r SERVICE_RECORDS_APPROVAL_VIEW_CORE.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_SUMMARY.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_DETAIL.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_PRAC_SUPERVISORS_VIEW_CURRENT.sql
:r SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY.sql
:r SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE.sql
:r SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE.sql
:r SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_DETAIL.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_JOURNAL_ID.sql
:r SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID.sql
:r SERVICE_RECORDS_REVIEW_AUDIT_VIEW.sql
:r PRAC_REC_VIEW.sql

:r INPUT_BATCHES_VIEW_CORE.sql

:r INPUT_BATCHES_WORK_PICKER_VIEW.sql

:r INPUT_BATCHES_WORK_PICKER.sql

:r WORKFLOW_REPORTS_VIEW.sql


/* Stored file */

:r STORED_FILE_WORK_BATCH_VIEW.sql

-- Service authorization (E Authorize)

:r SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE.sql

:r PATIENT_PERSON_ASSIGN_USER_CORE.sql
:r PATIENTS_ASSIGN_USER_CORE.sql

:r SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW.sql
:r SERVICE_AUTHORIZATION_REQUEST_COMMON.sql
:r SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA.sql
:r SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL.sql
:r SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA.sql
:r SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED.sql
:r SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED.sql
:r SERVICE_AUTHORIZATION_REQUEST_IS_CLOSE_AND_SAVE_NEW_ALLOWED.sql
:r SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE.sql
:r SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE.sql
:r SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE.sql
:r SERVICE_AUTHORIZATION_REQUESTS_VIEW.sql
:r SERVICE_AUTHORIZATION_REQUEST_SET_STATUS.sql
:r SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_DELETE.sql
:r SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES.sql
:r SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_SAVE.sql
:r SERVICE_AUTHORIZATION_REQUEST_DELETE_AND_SAVE_NEW.sql
:r SERVICE_AUTHORIZATION_REQUEST_CLOSE_AND_SAVE_NEW.sql
:r SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE.sql
:r SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE.sql
:r SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING.sql
:r SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW.sql
:r SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE.sql

-- Service Journal Part 1/2

:r SvcJournals_Custom_Types.sql
:r SvcJournal_Prac_Training_Parse_PracIDs_Core.sql
:r SvcJournal_Prac_Training_Parse_PracIDs.sql
:r SvcJournal_View_Prescribed_Orders_Prac_Training_Details.sql
:r SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_DELETE_CORE.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE.sql
:r SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_DELETE.sql

-- Note LIBRARY

:r NOTE_LIBRARY_TEMPLATES_VIEW_CORE.sql
:r NOTE_LIBRARY_TEMPLATES_VIEW.sql

:r NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE.sql
:r NOTE_LIBRARY_SAVED_NOTES_VIEW.sql
:r NOTE_LIBRARY_SAVED_NOTE_SAVE.sql
:r NOTE_LIBRARY_SAVED_NOTE_DELETE.sql

-- Groups Service Classes

:r CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA.sql
:r GROUPS_SERVICE_CLASS_VIEW_CORE.sql
:r GROUPS_SERVICE_CLASS_VIEW.sql
:r SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE.sql
:r SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT.sql

-- Patient Caseload and Patient Group Reloaded

:r PRACTITIONER_CASELOAD_MEMBER_Delete_Core.sql
:r PRACTITIONER_CASELOAD_MEMBER_Save_Core.sql

:r PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE.sql
:r PRACTITIONER_CASELOAD_MEMBER_SAVE.sql
:r PRACTITIONER_CASELOAD_MEMBER_DELETE.sql
:r PRACTITIONER_CASELOAD_MEMBERS_VIEW.sql
:r PATIENTS_EXPECTED_SERVICES_VIEW.sql

:r PRACTITIONER_PATIENT_GROUP_SAVE.sql
:r PRACTITIONER_PATIENT_GROUP_DELETE.sql
:r PRACTITIONER_PATIENT_GROUPS_View.sql

:r PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE.sql
:r PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE.sql
:r PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW.sql
:r SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service.sql
:r PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE.sql

-- Service Journals Part 2/2

:r SvcJournal_View_Service_Description_Prac_Training_Details.sql
:r SvcJournal_View_Service_Description_Prac_Training_Details_JSON.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_View.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_Save.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE_CORE.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE.sql
:r SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE.sql

:r SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE.sql
:r SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW.sql
:r SVCJOURNAL_JOURNAL_ORDERS_PROFILES_SAVE.sql
:r SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE.sql

:r SvcJournal_Event_Selections_Core.sql
:r SvcJournal_Event_Selections.sql
:r SvcJournal_Journal_Entries_View_Core.sql
:r SvcJournal_Journal_Entries_View.sql
:r SvcJournal_Journals_View_Core.sql
:r SvcJournal_Journals_View.sql
:r SvcJournal_Journals_With_Missing_Start_Or_End_Core.sql
:r SvcJournal_Journals_With_Missing_Start_Or_End.sql
:r SvcJournal_View_Core.sql
:r SvcJournal_View.sql
:r SvcJournal_Journal_Entries_Validate.sql
:r SvcJournal_Journal_Journal_Validate.sql
:r SvcJournal_Journal_Entries_Validate_Missing_Orp.sql
:r SvcJournal_Journal_Validate.sql
:r SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW.sql
:r SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE.sql
:r SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW.sql


:r SvcJournal_Journal_Service_Blocks_By_Prac_View_Core.sql
:r SvcJournal_Journal_Service_Blocks_View_Core.sql
:r SvcJournal_Journal_Service_Blocks_Every_15_View_Core.sql
:r SvcJournal_Journal_Report_Part_Entries_Every_15_View.sql
:r SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View.sql
:r SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View.sql
:r SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View.sql
:r SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core.sql
:r SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core.sql
:r SvcJournal_Compare_Prev_to_Curr_Core.sql

:r SVCJOURNAL_MANAGE_SERVICE_RECORDS.sql
:r SVCJOURNAL_JOURNAL_SAVE_CORE.sql
:r SVCJOURNAL_JOURNAL_SAVE.sql
:r SVCJOURNAL_JOURNAL_ENTRY_SAVE_CORE.sql
:r SVCJOURNAL_JOURNAL_ENTRY_SAVE.sql
:r SVCJOURNAL_JOURNAL_DELETE.sql
:r SVCJOURNAL_JOURNAL_CLOSE.sql
:r SVCJOURNAL_JOURNAL_REOPEN.sql
:r SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW.sql
:r SVCJOURNAL_JOURNAL_ENTRY_DELETE.sql

:r SvcJournal_Generate_Open_Journals_Data.sql
:r SvcJournal_Open_Journals_Data_Extract_Journals_To_Close.sql
:r SVCJOURNAL_JOURNALS_AUTO_DELETE.sql
:r SvcJournal_Journals_Auto_Close.sql

:r SvcJournal_Recent_Procedure_Entries_View.sql

:r SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE.sql

:r STORED_FILE_CAN_USER_VIEW.sql
:r STORED_FILE_VIEW.sql
:r STORED_FILE_VIEW_INFO.sql
:r STORED_FILE_SAVE.sql
:r STORED_FILE_FLAG_AS_CONFIDENTIAL.sql
:r STORED_FILE_FLAG_AS_NON_CONFIDENTIAL.sql
:r STORED_FILE_DELETE.sql

:r SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS.sql

:r SITES_REFRESH_PCAL_CDE_XREF_TABLES.sql
:r SITES_UPDATE_DATA_FROM_CDE.sql
:r FILE_UPLOAD_GENERATE_AND_SEND_REVIEW_REMINDER.sql

:r PATIENT_PLACES_VIEW_CORE.sql
:r PATIENT_PLACES_VIEW.sql
:r PATIENT_PLACES_VIEW_INFO.sql
:r PATIENT_PLACES_SAVE.sql

:r TRANSPORTATION_MGMT_VIEW.sql
:r TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE.sql

:r TRANSPORTATION_MGMT_PLACES_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_PLACES_VIEW.sql

:r TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW.sql
:r TRANSPORTATION_MGMT_TRIP_CALCULATION_Save_Core.sql
:r TRANSPORTATION_MGMT_TRIP_CALCULATION_Save.sql

:r TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE.sql

:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DELETE.sql

:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_CORE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER.sql
:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE.sql

:r TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE.sql

:r TRANSPORTATION_MGMT_GENERATE_ROUTE_SHEET_CODE.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEET_SAVE_CORE.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE.sql

:r TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW.sql

:r TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_DUP_ROUTE_DATA_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS.sql

:r TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW.sql
:r TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE.sql

:r TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_REPORT_VIEW.sql
:r TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_STATUS_REPORT_VIEW.sql

:r TRANSPORTATION_MGMT_BUS_DRIVERS_VIEW.sql
:r TRANSPORTATION_MGMT_BUS_DRIVERS_SAVE.sql
:r TRANSPORTATION_MGMT_BUS_DRIVERS_DELETE.sql

:r PERSONS_CLASS_VIEW_CORE.sql
:r PERSONS_CLASS_VIEW.sql

:r PERSONS_SAVE_CORE.sql
:r PERSONS_DELETE_CORE.sql


:r PATIENT_PERSONS_VIEW.sql
:r PATIENT_PERSONS_SAVE.sql
:r PATIENT_PERSON_RECS_VIEW.sql


:r PATIENT_USER_ACCOUNTS_RECS_VIEW.sql

:r DIAGNOSIS_TEMPLATES_VIEW_CORE.sql
:r DIAGNOSIS_TEMPLATES_VIEW.sql
:r DIAGNOSIS_TEMPLATES_SAVE.sql
:r DIAGNOSIS_TEMPLATES_DELETE.sql

:r PLAN_WRITER_PLANS_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_VIEW.sql
:r PLAN_WRITER_PLANS_SAVE_CORE.sql
:r PLAN_WRITER_PLANS_SAVE.sql
:r PLAN_WRITER_PLANS_Delete.sql
:r PLAN_WRITER_PLANS_CHANGE_AUTHOR.sql

:r PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW.sql

:r PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW.sql

:r PLAN_WRITER_PLANS_SIGNATURES_VIEW.sql

:r PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW.sql

:r PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_DIAGNOSES_VIEW.sql

:r PLAN_WRITER_PLANS_ALL_INFO_Save.sql
:r PLAN_WRITER_PLANS_ALL_INFO_SAVE_NO_JSON.sql
:r PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE.sql
:r PLAN_WRITER_PLANS_FOR_PATIENT_VIEW.sql

:r PLAN_WRITER_PLANS_CONDITIONS_SERVICE_DESCRIPTIONS_TOGGLE_FLAGGED_FOR_USE_CORE.sql
:r PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_TOGGLE_FLAGGED_FOR_USE_CORE.sql


:r TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE.sql
:r TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE.sql

/* Transmission_by_generation */
:r Claims_837_Data_Sent_Parse_Into_Text_Columns.sql
:r Claims_Write_5010_837_File.sql

:r CLAIM_PROCEDURES_TRANSMITTABLE.sql
:r CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET.sql
:r TRANSMISSION_GENERATION_CLIENT_PROCESS_DENIAL_RESUBMISSIONS.sql
:r TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT.sql
:r CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES.sql
:r CLAIMS_TRANSMISSION_LIST_VIEW_CLIENT_TRANSPORTATION.sql
:r TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS.sql
:r TRANSMISSION_GENERATION_APPLY_PROXY_HOLD_LOOPS.sql
:r TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS.sql
:r TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS.sql
:r TRANSMISSION_GENERATION_APPLY_HOLDS.sql
:r TRANSMISSION_GENERATION_CREATE.sql
:r TRANSMISSION_GENERATION_APPEND_CLAIMS_CORE.sql
:r TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS.sql
:r TRANSMISSION_GENERATION_APPEND_CLIENT_CLAIMS.sql
:r TRANSMISSION_GENERATION_APPEND_CLAIMS.sql
:r TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS.sql
:r CLAIMS_HOWMUCH_CALCULATE.sql
:r Claims_Create_Transmission.sql
:r TRANSMISSION_GENERATION_CREATE_TRANSMISSION.sql
:r TRANSMISSION_GENERATION_HOWMUCH.sql
:r CLAIMS_TRANSMISSION_TRANSMIT_837.sql
:r TRANSMISSION_GENERATION_837_PROCESS.sql
:r TRANSMISSION_GENERATION_CLIENT_837_BY_DATES.sql
:r TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR.sql
:r TRANSMISSION_GENERATION_CLIENT_837_RETROACTIVE_FOR_SPA.sql
:r TRANSMISSION_GENERATION_CLIENT_837_CIF_VOID.sql
:r TRANSMISSION_GENERATION_CLIENT_837.sql
:r TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS.sql
:r TRANSMISSION_GENERATION_BATCH_837.sql
:r Claims_TransmissionRecord_HowMuch.sql
:r PATIENTS_VIEW_MERGE.sql
:r ARCHIVE_BICS_AND_RESUBMIT_CLAIMS.sql
:r PATIENTS_MERGE.sql
:r UPDATE_CLIENT_FY_TOTALS.sql
:r GET_FY_TOTALS_LAST_7_CORE.sql
:r COMPUTE_FY_TOTALS_LAST_7_CORE.sql
:r FY_TOTALS_LAST_7_ONTHEFLY.sql

:r RPT_POSSIBLE_PAT_MERGES_NEEDED.sql

----BATCH Reports

:r RPT_MISSING_ASSESSMENTS_CORE.sql
:r RPT_MISSING_ASSESSMENTS_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY.sql
:r RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY.sql

:r RPT_SPEDCARE_WEEKLY_REPORT.sql
:r RPT_BATCHES_ASSIGNED_NOT_DONE.sql
:r INPUT_BATCHES_STATUS_VIEW.sql
:r RPT_BATCHES_IN_PROCESS.sql
:r RPT_Batches_About_To_AGE_OUT.sql
:r RPT_BatchesNeedingPriorityReview.sql
:r RPT_CountOfBatchesInProcessbyStatus.sql
:r RPT_CountBatchesReadyToAssignByTypeOfWork.sql
:r RPT_Claims_Transmissions_Summary.sql
:r RPT_INPUT_STAFF_TRAINING_IN_PROCESS.sql
:r RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW.sql

-- Uncomment if we are actually using this
--:r NON_SBSC_SVCREC_ENTRY_CHECK.sql

-- Physician based standards

:r CLIENT_PBS_DOCUMENTATION_VIEW.sql
:r CLIENT_PBS_DOCUMENTATION_SAVE.sql
:r CLIENT_PBS_DOCUMENTATION_DELETE.sql

:r UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES.sql
:r UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_BY_CLIENT.sql
:r UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD.sql
:r RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT.sql

:r UPDATE_WAITING_WORK_JOURNALS_SERVICES_DATA.sql

-- School session 1/2

:r CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION.sql
:r CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION.sql
:r CLIENT_SCHOOL_SESSION_CALC_DATES_NOT_IN_SESSION.sql

-- Promised SpEd services

:r PATIENT_PROMISED_SERVICES_CUSTOM_TYPES.sql
:r Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat.sql

:r PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT.sql
:r PATIENT_PROMISED_SERVICES_UPCOMING_IEPS_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_RECENT_IEPS_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED.sql
:r RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE.sql
:r PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES.sql
:r SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN.sql
:r SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW.sql
:r SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_DATA_FOR_A_SLOT.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_MINUTES_SATISFIED_FOR_SLOT_VIA_SERVICE_MINUTES_AS_ROW.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS_DETAILS.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS_SUMMARY.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_PLAN_DATES_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_REF_DATE_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_VIEW_CORE.sql
:r PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW.sql

-- Promised non IEP

:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE.sql

-- By grp svc class and svctype

:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE.sql
:r PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_SUMMARY_VIEW_DATA_CORE.sql

:r RPT_PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE.sql
:r RPT_MISSING_TREATMENTS_SPED_DATA_CORE.sql
:r RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE.sql
:r RPT_MISSING_TREATMENTS_DATA_CORE.sql
:r RPT_MISSING_TREATMENTS_CORE.sql
:r RPT_MISSING_TREATMENTS_FOR_A_PATIENT.sql
:r RPT_MISSING_TREATMENTS_DETAILS.sql
:r RPT_MISSING_TREATMENTS_SUMMARY.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_SUMMARY.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_SUMMARY.sql
:r Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt.sql
:r Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt.sql
:r RPT_CDE_COMPLIANCE_OVERALL_SUMMARY.sql

---claims entity related
:r RPT_POTENTIAL_LOST_REIMBURSEMENT.sql
:r RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW.sql
:r RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL.sql
:r RPT_Claims_Waiting_For_Next_Transmission_Summary.sql
:r POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW.sql
:r POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW.sql
:r CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE.sql

:r POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE.sql
:r POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE.sql
:r POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH.sql

:r POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW.sql

:r WORK_BATCHES_NOT_INPUT_VIEW_CORE.sql
:r RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS.sql

-- Temp orp associotion screens related

:r SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE.sql
:r SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY.sql

-- CDE data related
:r PUBLIC_SCHOOLS_IMPORT.sql

-- Student data related
:r JSON_FIND_INSURANCE_CARRIERS_BY_NAME.sql
:r INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME.sql
:r FROM_CLIENT_PATIENT_MATCH_HEURISTIC.sql
:r FROM_CLIENT.sql -- A routine

:r Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View.sql
:r Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans.sql

-- patient data imports parse 2 of 2

:r Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core.sql
:r Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core.sql

:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL.sql

:r Patient_Data_Imports_Generate_SpEd_Data_File_Summary_Rows.sql
:r Patient_Data_Imports_Parse_And_Update_SpEd_Data.sql
:r Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old.sql

:r FROM_CLIENT_PROMISED_SERVICES_PROCESS_UPDATES_CORE.sql
:r FROM_CLIENT_PROMISED_SERVICES_PROCESS_UPDATES.sql
:r FROM_CLIENT_PROMISED_SERVICES.sql -- the so-called A+1/2 rtn

:r TO_DHCS_ROWS.sql -- B routine

:r TO_DHCS.sql -- B routine
:r FROM_DHCS.sql -- C routine
:r FROM_DHCS_x.sql -- legacy C routine - little or no statistics logged, no resubmittal logic

:r PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT.sql

:r PATIENT_DATA_IMPORT_TO_DHCS.sql

:r PATIENT_DATA_IMPORT_ELIG_MATCH_FLAG_SCHEDULE_TONIGHT.sql
:r PATIENT_DATA_IMPORT_ELIG_MATCH_FLAG_UNSCHEDULE.sql

-- Invoice reconcilliation tools

:r RPT_CLAIMS_TRANSMITTED_AND_POSTED_CORE.sql

-- Transmission Rollback

:r TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES.sql
:r TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES.sql
:r TRANSMISSION_RECORD_ROLLBACK.sql

-- Telehealth

:r PATIENT_EMAIL_ADDRESS_MANAGE_CORE.sql
:r PATIENT_PHONE_NUMBER_MANAGE_CORE.sql
:r TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA.sql
:r TELECOMM_HEALTH_SAVE_SERVICE_RECORDS.sql
:r TELECOMM_SESSIONS_HEALTH_VIEW_CORE.sql
:r TELECOMM_SESSIONS_HEALTH_VIEW.sql

-- Virtual IEP

:r TELECOMM_IEP_TYPES_VIEW.sql
:r TELECOMM_IEP_TYPES_Save.sql
:r TELECOMM_IEP_TYPES_Delete.sql
:r TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA.sql
:r TELECOMM_IEP_SAVE_SIG_PAGE.sql
:r TELECOMM_SESSIONS_IEP_VIEW_CORE.sql
:r TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED.sql
:r TELECOMM_SESSIONS_IEP_VIEW.sql

-- Practitioner Preference Sped Services

:r PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE.sql

:r PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE.sql
:r PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW.sql

-- RMTS Part 2/2

:r RMTS_CURRENT_QUARTERS_VIEW_CORE.sql
:r RMTS_CURRENT_QUARTERS_VIEW.sql

:r RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE.sql
:r RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE.sql
:r RMTS_PARTICIPANTS_POSSIBLE_VIEW.sql
:r RMTS_PARTICIPANTS_INCLUDED_VIEW.sql
:r RMTS_PARTICIPANTS_EXCLUDED_VIEW.sql
:r RMTS_PARTICIPATION_ROSTER_VIEW.sql
:r RMTS_PARTICIPATION_ROSTER_SAVE.sql
:r RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW.sql
:r RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW.sql

:r RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW.sql
:r RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW.sql

:r RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR.sql

:r RMTS_UploadXLSJson.sql
:r RPT_RMTS_MOMENT_SERVICE_RECORDS.sql

:r RPT_RMTS_MOMENTS_VIEW.sql

:r RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE.sql
:r RMTS_MOMENT_MATCH_SERVICE_RECORD.sql

:r RMTS_UNDO_AUDITMATCH_SVCREC.sql
:r RMTS_MOMENT_FLAG_COMPLETE.sql
:r RMTS_MOMENT_FLAG_INCOMPLETE.sql

:r RMTS_MOMENT_REVIEW.sql

:r RMTS_MOMENT_FLAG_MSGSENT.sql

:r SERVICE_RECORD_Save_And_RMTS_Moment_Match.sql

:r RMTS_PARTICIPANTS_VIEW_CORE.sql
:r RMTS_PARTICIPANTS_VIEW.sql
:r RMTS_PARTICIPANTS_SAVE_CORE.sql
:r RMTS_PARTICIPANTS_SAVE.sql
:r RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE.sql
:r RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW_CORE.sql
:r RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW.sql
:r RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW_CORE.sql
:r RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW.sql
:r RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1.sql

:r RMTS_PARTICIPANTS_WO_SVCRECS_VIEW.sql
:r RMTS_PARTICIPANT_FLAG_DEFERRALREASON.sql
:r RMTS_MOMENT_FLAG_DEFERRALREASON.sql

:r RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED.sql
:r RMTS_MOMENTS_2A_ACTIONREQUIRED_WWO_DEFERRALS_VIEW.sql

:r CRCS_PRACS_VIEW_CORE.sql

:r CRCS_PRAC_SALARIES_RATE_REBASING_VIEW_CORE.sql
:r CRCS_PRAC_SALARIES_RATE_REBASING_VIEW.sql

:r CRCS_PRAC_HOURS_FY_SAVE.sql

-- Direct supervision

:r PRACTITIONER_DIRECT_SUPERVISORS_VIEW.sql
:r PRACTITIONER_DIRECT_SUPERVISORS_SAVE.sql
:r PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_SAVE.sql
:r PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW.sql
:r PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_DELETE.sql
:r PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_UNDELETE.sql

-- User denial resubmission

:r CLAIM_Denied_Resubmit_Disposition_View.sql
:r CLAIM_Denied_Resubmit_Disposition_Save.sql

:r PRACTITIONER_CASELOAD_UPCOMING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE.sql
:r PRACTITIONER_CASELOAD_MISSING_POSSIBLE_PATIENT_ASSESSMENT_VIEW_CORE.sql
:r PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW.sql
:r PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW.sql
:r PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW.sql

:r CLAIM_PROCEDURES_FOR_GROUP_INFO_VIEW.sql


/* Client Contacts */

:r CLIENT_CONTACT_ROLES_VIEW.sql
:r CLIENT_CONTACTS_SAVE.sql
:r CLIENT_CONTACTS_VIEW.sql
:r CLIENT_CONTACTS_DELETE.sql

/* Client Contracts */

:r CLIENT_CONTRACTS_SAVE.sql
:r CLIENT_CONTRACTS_VIEW.sql
:r CLIENT_CONTRACTS_DELETE.sql

:r CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE.sql
:r RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY.sql
:r RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS.sql

/* Patient Contacts */

:r PATIENT_PERSONS_DELETE.sql

/* MCAL Consent */

:r PATIENT_PARENT_MCAL_CONSENT_VIEW.sql
:r PATIENT_PARENT_MCAL_CONSENT_SAVE.sql
:r PATIENT_PARENT_MCAL_CONSENT_CLIENT_DEFAULT_BILLING_MESSAGE_SAVE.sql

/* MCAL Outreach */
:r PATIENT_MCAL_OUTREACH_NOTES_SAVE.sql

/* Additions to service auth requests */
:r SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW.sql



:r CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE.sql


:r CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW.sql
:r CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW.sql
:r CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE_CORE.sql
:r CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SAVE.sql


:r CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_CORE.sql
:r CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE.sql
:r CLAIM_SERVICE_NAME_XREF_AND_XFORM_DELETE_MULTI.sql

:r CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_MULTICLONE.sql
:r CLAIM_SERVICE_NAME_XREF_AND_FORMDATA_JSON_MULTISAVE.sql

:r SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME.sql

/* Patient goals */

:r PATIENT_GOALS_VIEW_DEFAULT_DATES.sql
:r PATIENT_GOALS_DELETE.sql
:r PATIENT_GOALS_VIEW.sql
:r PATIENT_GOALS_SAVE.sql
:r PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW.sql

/* CIF request management */

:r CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS.sql
:r CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1.sql
:r CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2.sql
:r CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS.sql
:r CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS.sql
:r CIF_REQUESTS_UPDATE_RESOLUTIONS.sql
:r CIF_REQUEST_UPDATE_WITH_CIF_DOCUMENT_DATA.sql

/* Patient SpEd tab */

:r SPED_DISABILITY_CODES_VIEW.sql
:r SPED_SERVICE_FREQUENCY_VIEW.sql
:r SPED_SERVICE_PROVIDER_VIEW.sql
:r SPED_SERVICE_LOCATION_VIEW.sql
:r SPED_SERVICE_VIEW.sql
:r SPED_LANGUAGES_VIEW.sql
:r SPED_REFERRING_PARTY_VIEW.sql
:r SPED_PLAN_TYPE_VIEW.sql



:r CLIENTS_NOTES_TOPICS_VIEW.sql
:r CLIENTS_Notes_VIEW.sql


:r CLIENTS_Notes_SAVE.sql
:r CLIENTS_Notes_DELETE.sql

/* CRCS */

:r COMPANY_FISCAL_YEARS_VIEW_CORE.sql
:r COMPANY_FISCAL_YEARS_VIEW.sql
:r COMPANY_FISCAL_QUARTERS_VIEW_CORE.sql
:r COMPANY_FISCAL_QUARTERS_VIEW.sql
:r CRCS_PRAC_SALARIES_VIEW_CORE.sql
:r CRCS_PRAC_SALARIES_VIEW.sql
:r CRCS_PRAC_SALARY_SAVE.sql
:r CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE.sql
:r CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW.sql
:r CRCS_PRAC_SALARIES_BEFORE_19_20_FY_SAVE.sql
:r CRCS_PRAC_SALARIES_UNION_VIEW.sql
:r CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE.sql
:r CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS.sql
:r CRCS_CONTRACTOR_COSTS_VIEW_CORE.sql
:r CRCS_CONTRACTOR_COSTS_VIEW.sql
:r CRCS_CONTRACTOR_COSTS_SAVE.sql
:r CRCS_OTHER_COSTS_VIEW_CORE.sql
:r CRCS_OTHER_COSTS_VIEW.sql
:r CRCS_OTHER_COSTS_SAVE.sql
:r CRCS_OTHER_COSTS_DEFER.sql
:r CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE.sql
:r CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_VIEW.sql
:r CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_SAVE.sql
:r CRCS_MED_EQUIPMENT_DEPRECIATION_COSTS_DELETE.sql
:r CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE.sql
:r CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW.sql
:r CRCS_TRANSPORTATION_PERSONNEL_COSTS_SAVE.sql
:r CRCS_TRANSPORTATION_PERSONNEL_COSTS_DELETE.sql
:r CRCS_TRANSPORTATION_PERSONNEL_COSTS_DEFER.sql
:r CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE.sql
:r CRCS_TRANSPORTATION_OTHER_COSTS_VIEW.sql
:r CRCS_TRANSPORTATION_OTHER_COSTS_SAVE.sql
:r CRCS_TRANSPORTATION_OTHER_COSTS_DELETE.sql
:r CRCS_TRANSPORTATION_OTHER_COSTS_DEFER.sql
:r CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_VIEW_CORE.sql
:r CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_VIEW.sql
:r CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_SAVE.sql
:r CRCS_TRANSPORTATION_EQUIPMENT_DEPRECIATION_COSTS_DELETE.sql
:r CRCS_CATEGORY_DEFER.sql
:r CRCS_CATEGORY_DEFERRAL_VIEW.sql
:r CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE.sql
:r CRCS_COMPLETION_STATUS_VIEW.sql
:r CRCS_PROGRAM_INFO_VIEW_CORE.sql
:r CRCS_PROGRAM_INFO_VIEW.sql
:r CRCS_PROGRAM_INFO_SAVE.sql
:r CRCS_PROGRAM_INFO_NUM_TRIPS.sql
:r CRCS_GROUPS_VIEW_CORE.sql
:r CRCS_PRAC_SALARIES_TOTALS_VIEW_CORE.sql
:r CRCS_PRAC_SALARIES_TOTALS_VIEW.sql
:r CRCS_OTHER_COSTS_TOTALS_VIEW_CORE.sql
:r CRCS_OTHER_COSTS_TOTALS_VIEW.sql
:r CRCS_CONTRACTOR_COSTS_TOTALS_VIEW_CORE.sql
:r CRCS_CONTRACTOR_COSTS_TOTALS_VIEW.sql
:r CRCS_COMPLETION_TOTALS_RPT_VIEW.sql
:r CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW.sql
:r CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW_CORE.sql
:r CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW.sql
:r CRCS_CATEGORY_COMPLETED_VIEW.sql
:r CRCS_CATEGORY_COMPLETED_SAVE.sql
:r CRCS_SEND_COMPLETED_NOTIFICATION.sql
:r CALC_CRCS_TRANSPORTATION_RATE_AMOUNT.sql
:r CRCS_TRANSPORTATION_VEHICLE_DATA_SAVE.sql
:r CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW.sql

:r CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT.sql

:r LEC_OR_LGA_VIEW_CORE.sql
:r LEC_OR_LGA_VIEW.sql


/* Helper routines for creating services and procedures */

:r Claim_Procedures_Service_Names_Create_Core.sql
:r Claim_Procedures_Generate_New_Procedures_Data_Core.sql
:r Claim_Procedures_Services_Create.sql

/* adapted match */

:r FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY.sql
:r SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE.sql
:r SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE.sql

:r Patient_Data_Imports_Match_Heuristic.sql

/* Structured data import */

:r Structured_Data_Imports_Save_Core.sql
:r STRUCTURED_DATA_IMPORT_GET_FIELD_MAPPING.sql
:r STRUCTURED_DATA_IMPORT_GET_INPUT_DATA.sql

:r STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML.sql

:r Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html.sql
:r Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html.sql
:r Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html.sql

:r SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE.sql

:r Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client.sql
:r Patient_Data_Imports_Cleanup_Unknown_Sites.sql
:r Patient_Data_Imports_Manage_Sites.sql
:r Patient_Data_Imports_Save_Core.sql
:r Patient_Data_Imports_Match_Pop_Data.sql
:r Patient_Data_Imports_Match_SpecEd_Data.sql
:r Patient_Data_Imports_Save.sql
:r Patient_Data_Imports_View_Core.sql
:r Patient_Data_Imports_View.sql
:r Patient_Data_Imports_Get_Import_Results.sql
:r Patient_Data_Imports_Match.sql

:r INSURANCE_CARRIERS_VIEW.sql
:r PATIENT_INSURANCE_CARRIERS_VIEW.sql
:r PATIENT_INSURANCE_CARRIERS_SAVE.sql
:r INSURANCE_CARRIERS_SAVE.sql
:r INSURANCE_CARRIERS_DELETE.sql

:r Patient_insurance_Carriers_Data_Imports_Save.sql

:r Rmts_Participants_Data_Imports_Save_Core.sql
:r Rmts_Participants_Data_Imports_Match_Pop_Data_Core.sql
:r Rmts_Participants_Data_Imports_Save.sql
:r Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core.sql
:r Rmts_Participants_Data_Imports_Not_In_SpEdCare_View.sql
:r Rmts_Participants_Data_Imports_Not_In_SpEdCare_Delete.sql
:r Rmts_Participants_Data_Imports_Assign_Prac.sql

:r Rmts_Moment_Data_Imports_Save_Core.sql
:r Rmts_Moment_Data_Imports_Save.sql

/* Patient data reminder */
:r IS_REF_DATE_CRON_TAB_SELECTION_VALUE.sql
:r Patient_Data_Imports_Generate_Request_Data_Recipient_List.sql

/* Reoccuring messages */

:r GENERATE_REOCCURRING_MESSAGES.sql

/* Claims Paid */

:r CLAIMS_PAID_CURR_AND_PREVIOUS_FY.sql

/* School session 2/2  */

:r CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE.sql
:r CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE.sql
:r CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW.sql

:r CLIENT_SCHOOL_SESSION_BREAK_SAVE.sql
:r CLIENT_SCHOOL_SESSION_BREAK_DELETE.sql
:r CLIENT_SCHOOL_SESSION_BREAKS_VIEW.sql

:r GET_SERVICE_NAME_ID_REPLACEMENT_FOR_GROUP_CHANGE.sql
:r SERVICE_RECORD_Bulk_Update_For_Prac_Group_Change.sql

/* Medi-Cal Benefits */

:r PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE.sql
:r PATIENTS_CURRENT_MCAL_BENEFITS_VIEW.sql

/* Services By Prac Report */

:r RPT_PRACTITIONERS_REVIEW_CORE.sql
:r SERVICE_MINS_BY_PRAC_RPT.sql
:r SERVICE_COUNTS_BY_PRAC_RPT.sql

/* Client Compliance */
:r CLIENT_COMPLIANCE_TASKS_VIEW_CORE.sql
:r CLIENT_COMPLIANCE_TASKS_VIEW.sql
:r CLIENT_COMPLIANCE_TASK_SAVE.sql

:r CLIENT_COMPLIANCE_ITEM_SAVE_CORE.sql
:r CLIENT_COMPLIANCE_ITEM_SAVE.sql
:r CLIENT_COMPLIANCE_ITEMS_VIEW_CORE.sql
:r CLIENT_COMPLIANCE_ITEMS_VIEW.sql

:r CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE.sql
:r CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE.sql
:r CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE.sql
:r CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW.sql

:r CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL.sql


:r CLIENT_COMPLIANCE_ITEMS_DELETE.sql


/* Client Invoices */

:r CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC.sql
:r CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI.sql

:r CLIENT_INVOICES_VIEW.sql

:r CLIENT_INVOICES_SAVE_CORE.sql

:r CLIENT_INVOICES_SAVE.sql

:r CLIENT_INVOICES_TOTALS_VIEW.sql

:r CLIENT_INVOICES_DISTRIBUTED_DATE_UPDATE_MULTI.sql

/* SELPAS */

:r SELPA_CODES_VIEW.sql

:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH.sql

/* Input Batches */

:r STORED_FILE_WORKFLOW_VIEW_FILE_RECORD.sql
:r INPUT_BATCHES_IN_PROCESS_VIEW.sql
:r INPUT_BATCHES_WORK_TYPE_VIEW.sql
:r INPUT_BATCHES_IN_PROCESS_DELETE.sql

:r SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc.sql
:r SERVICE_RECORD_DATA_INCOMPLETE_VIEW.sql
:r SERVICE_RECORD_DATA_INCOMPLETE_SAVE.sql
:r SERVICE_RECORD_DATA_INCOMPLETE_DELETE.sql

/* Client domains*/

:r CLIENTS_DOMAINS_VIEW.sql
:r CLIENTS_DOMAINS_SAVE.sql
:r CLIENTS_DOMAINS_DELETE.sql

:r RPT_PRAC_TATTLE_TALE_CORE.sql
:r RPT_PRAC_TATTLE_TALE.sql

:r RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW.sql
:r RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE.sql
:r RMTS_ACTIVITY_CODE_CHANGE_REASON_DELETE.sql

:r RMTS_MOMENT_EDIT_PRAC_SEL.sql

:r SpEd_Document_Templates_Save.sql
:r SpEd_Document_Templates_View.sql
:r SpEd_Document_Templates_Delete.sql

:r SPED_GENDER_VIEW.sql
:r SPED_GRADE_VIEW.sql
:r SPED_LANGAUGE_VIEW.sql
:r SPED_PROGRAM_TYPES_VIEW.sql
:r SPED_RACE_VIEW.sql
:r SPED_SERVICE_SETTINGS_VIEW.sql
:r SPED_PATIENT_PRIMARY_RESIDENCE_VIEW.sql

:r RPT_SPED_SERVICES_FOR_SELPA_EXPORT_CORE.sql
:r RPT_SPED_SERVICES_FOR_SELPA_EXPORT.sql
:r RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS.sql
:r RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH.sql
:r RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY.sql

:r Patients_Promised_Services_CDE_Audits_Current_Save.sql
:r Patients_Promised_Services_CDE_Audits_Current_View.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_Save.sql
:r Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core.sql
:r Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_Delete_Inline.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_View.sql
:r Patients_Promised_Services_CDE_Audits_Current_Rpt_Compliance_Buckets_Summary.sql
:r Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View.sql

:r RPT_PATIENT_FIND_REDUNDANT_RECORDS.sql

:r SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW.sql

:r NEWSLETTER_PAGE_SAVE_CORE.sql
:r NEWSLETTER_PAGE_SAVE.sql

:r NEWSLETTER_PAGES_DATA_CORE.sql
:r NEWSLETTER_PAGES_VIEW_CORE.sql
:r NEWSLETTER_PAGES_VIEW.sql


:r NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST.sql

:r NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT.sql
:r NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL.sql

:r NEWSLETTER_PAGE_DELETE.sql

:r NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA.sql
:r NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL.sql

:r NEWSLETTER_PAGES_LOG_SENT_NOW.sql
:r NEWSLETTER_PAGES_RESET_AND_REPUBLISH.sql

:r NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH.sql


:r PATIENTS_Promised_Services_Delivery_Exceptions_Save.sql
:r PATIENTS_Promised_Services_Delivery_Exceptions_Delete.sql
:r PATIENTS_Promised_Services_Delivery_Exceptions_Flag_As_Reviewed.sql
:r PATIENTS_Promised_Services_Delivery_Exception_Added_Reasons_View.sql
:r PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons_View.sql
:r PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core.sql
:r PATIENTS_Promised_Services_Delivery_Exceptions_View_Core.sql
:r PATIENTS_Promised_Services_Delivery_Exceptions_View.sql

:r Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core.sql
:r PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE.sql
:r PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE.sql
:r Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save.sql

:r RPT_PRACTITIONERS_EFFICENCY_CORE.sql
:r RPT_PRACTITIONERS_EFFICENCY.sql

:r Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save.sql
:r Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace.sql
:r Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save.sql
:r Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_SpEdSvc_Summary_Rpt.sql
:r Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt.sql
:r Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt.sql
:r Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_Client_Summary_Rpt.sql

:r PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW.sql
:r PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE.sql
:r PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_DELETE.sql

:r CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW.sql
:r CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET.sql

:r Group_Discipline_Name_Create_Core.sql

/* PPS Setpoints */

:r Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save.sql
:r Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View.sql

/* Prac patient scheduled services */

:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW.sql
:r Practitioner_Patient_Scheduled_Service_Occurs_On_RefDate.sql
:r Practitioner_Patient_Scheduled_Service_Get_Start_Time_For_Dow.sql
:r Practitioner_Patient_Scheduled_Service_Occurs_When_Summary.sql
:r Practitioner_Patient_Scheduled_Services_Data_Core.sql
:r Practitioner_Patient_Scheduled_Services_View_Core.sql
:r Practitioner_Patient_Scheduled_Services_View.sql
:r Practitioner_Patient_Scheduled_Services_Save_Core.sql
:r Practitioner_Patient_Scheduled_Services_Save.sql
:r Practitioner_Patient_Scheduled_Services_Delete.sql
:r Practitioner_Patient_Scheduled_Services_Save_Multiple_Core.sql

/* Moved to here */

:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_AND_GET_NEW.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW.sql
:r PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_STATS_VIEW.sql

:r CYBHI_SITES_VIEW_DATA_CORE.sql
:r CYBHI_SITE_LIST_AUDIT_RPT.sql
:r CYBHI_Provider_Degrees_View.sql
:r CYBHI_Provider_Specialties_View.sql
:r CYBHI_PROVIDER_LIST_RPT_CORE.sql
:r CYBHI_PROVIDER_LIST_AUDIT_RPT.sql
:r CYBHI_PROVIDER_LIST_TPA_EXPORT_RPT.sql

/* SpEd non delivery reports */

:r PATIENT_PROMISED_SERVICES_SPED_SERVICES_NON_DELIVERY_DETAILS_VIEW_CORE.sql
:r PATIENT_PROMISED_SERVICES_SPED_SERVICES_PAT_ABSENT_STATS_DETAILS_VIEW_CORE.sql

/* Practice office */

:r PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED.sql
:r PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE.sql
:r PRACTICE_OFFICE_VISIT_REASONS_VIEW.sql
:r PRACTICE_OFFICE_VISIT_RESOLUTIONS_VIEW.sql

:r PRACTICE_OFFICE_VISITS_VIEW_CORE.sql
:r PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW.sql
:r PRACTICE_OFFICE_VISITS_VIEW.sql
:r PRACTICE_OFFICE_VISITS_SAVE.sql
:r PRACTICE_OFFICE_VISITS_DELETE.sql
:r PRACTICE_OFFICE_KIOSK_GET_BY_PTKN.sql
:r PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK_CORE.sql
:r PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK.sql
:r PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_WAITING_ROOM.sql
:r PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_PUBLIC_KIOSK.sql
:r PRACTICE_OFFICE_VISITS_START_VISIT.sql
:r PRACTICE_OFFICE_VISITS_END_VISIT.sql
:r PRACTICE_OFFICE_VISITS_SAVE_VISIT_IN_PROGRESS.sql

/* Allergies */

:r ALLERGIES_VIEW.sql

/* Patient Allergies */

:r PATIENT_ALLERGIES_SAVE.sql
:r PATIENT_ALLERGIES_VIEW.sql
:r PATIENT_ALLERGIES_DELETE.sql

/* Known Health Problems*/

:r KNOWN_HEALTH_PROBLEMS_VIEW.sql

/* Patient Known Health Problems */

:r PATIENT_KNOWN_HEALTH_PROBLEMS_SAVE.sql
:r PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW.sql
:r PATIENT_KNOWN_HEALTH_PROBLEMS_DELETE.sql

/* ICD 10 CM Codes */

:r ICD_10_CM_CODES_VIEW.sql

/* Patient diagnoses*/

:r PATIENT_DIAGNOSES_SAVE.sql
:r PATIENT_DIAGNOSES_VIEW.sql
:r PATIENT_DIAGNOSES_DELETE.sql

/* Patient vitals measurements */

:r PATIENT_VITALS_MEASUREMENTS_VIEW.sql
:r PATIENT_VITALS_MEASUREMENTS_SAVE.sql
:r PATIENT_VITALS_MEASUREMENTS_DELETE.sql

:r PRACTICE_OFFICE_VISIT_REASONS_SAVE.sql
:r UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS.sql
:r UPDATE_PATIENT_PROMISED_SERVICES_RECENT_IEPS.sql

/* Practice office kiosks */

:r PRACTICE_OFFICE_KIOSKS_SAVE.sql
:r PRACTICE_OFFICE_KIOSKS_VIEW.sql
:r PRACTICE_OFFICE_KIOSKS_DELETE.sql

:r KNOWN_HEALTH_PROBLEMS_SAVE.sql
:r ALLERGIES_SAVE.sql
:r KNOWN_HEALTH_PROBLEMS_DELETE.sql
:r ALLERGIES_DELETE.sql
:r PRACTICE_OFFICE_VISITS_EDIT_COMPLETED_VISIT.sql
:r PATIENT_CARE_NOTES_SAVE.sql
:r PATIENT_CARE_NOTES_VIEW.sql

:r PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL.sql
:r PRACTICE_OFFICE_VISIT_REASONS_DELETE.sql
:r PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE.sql
:r PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE.sql

:r CYBHI_PATS_VIEW_DATA_CORE.sql
:r CYBHI_PAT_LIST_RPT_CORE.sql
:r CYBHI_PAT_LIST_AUDIT_RPT.sql
:r CYBHI_PAT_LIST_EXPORT_RPT.sql

:r Claims_Write_5010_837P_File_CYBHI.sql

:r Patients_With_Missing_Info_View_Core.sql

:r PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_SAVE.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_VIEW.sql

:r PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL.sql

:r PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_UPDATE_REQUEST_SENT.sql

:r PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE.sql 
:r PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK.sql
:r PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL.sql

:r Patients_With_Missing_Info_View.sql
:r CYBHI_Holds_Missing_Info_Pats_View.sql

:r PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View.sql
:r RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS.sql

:r PATIENT_INFO_REQUESTS_RESPONSES_TO_AUTO_GENERATE_VIEW.sql

:r CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT.sql
:r CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE.sql

:r CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG.sql
:r CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG.sql

/* May need to move and consolidate get_possible_claims into generation */

:r CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE.sql
:r CYBHI_TRANSMISSION_GENERATION_GET_POSSIBLE_CLAIMS.sql
:r CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS.sql
:r CYBHI_TRANSMISSION_GENERATION_CREATE_TRANSMISSION_RECORD_SET.sql
:r CYBHI_TRANSMISSION_GENERATION_GET_SITES.sql
:r CYBHI_TRANSMISSION_GENERATION_APPLY_HOLDS.sql
:r CYBHI_TRANSMISSION_GENERATION_UPDATE_SERVICE_RECORDS_AND_CLAIMS.sql
:r CYBHI_TRANSMISSION_GENERATION_CREATE_837_FILE_CONTENT.sql
:r CYBHI_TRANSMISSION_GENERATION_WRITE_837_FILE.sql
:r CYBHI_TRANSMISSION_GENERATION.sql
:r CYBHI_TRANSMISSION_ROLLBACK.sql
:r CYBHI_TRANSMISSION_GENERATION_ALL.sql
:r CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS.sql

:r CYBHI_POSTING.sql
:r CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE.sql
:r CYBHI_CLAIMS_PAID_BY_SERVICE_RECORD_DETAILS_VIEW_CORE.sql

:r PRACTITIONER_SITES_VIEW.sql
:r PRACTITIONER_SITES_SAVE.sql

/*Referral System*/

:r PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE.sql
:r PRACTITIONER_PATIENT_REFERRALS_SAVE.sql
:r PRACTITIONER_PATIENT_REFERRAL_OPTIONS_SAVE.sql
:r STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE.sql
:r PRACTITIONER_PATIENT_REFERRALS_VIEW.sql
:r PRACTITIONER_PATIENT_REFERRAL_OPTIONS_VIEW.sql
:r PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN.sql

:r PATIENT_INFO_REQUESTS_FORM_OPTIONS_SAVE.sql
:r PATIENT_INFO_REQUESTS_FORM_OPTIONS_VIEW.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_SAVE.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW.sql

:r PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM.sql
:r PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_BY_PTKN.sql
:r PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT.sql

:r CYBHI_Program_Health_Stats_View.sql

:r Practitioner_Patient_Scheduled_Services_Save_Multiple.sql

:r PATIENT_Save_Profile.sql

/* Public insurance info request */

:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_PTKN_FOR_CLIENT.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_DELETE.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW.sql

:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_REJECT.sql
:r PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_ACCEPT.sql

:r PATIENT_Insurance_Delete_Core.sql
:r PATIENT_Insurance_Delete.sql
:r PATIENT_Insurance_Delete_Multi.sql

:r PATIENT_PROFILE_PICTURES_VIEW.sql
:r PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE.sql

:r CROSS_CLIENT_PATIENTS_VIEW.sql

:r RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED.sql
:r CYBHI_PROCESS_CLAIM_ACKNOWLEDGE_DATA.sql

:r STUDENT_INFORMATION_SYSTEMS_VIEW.sql

:r CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE.sql
:r CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE.sql
:r CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW.sql

:r PATIENT_IEP_SAVE.sql

:r Service_Records_Data_Imports_Save.sql
:r CYBHI_POSTING_ALL.sql
:r CYBHI_TRANSMISSION_GENERATION_BATCH.sql
:r CYBHI_POSTING_BATCH.sql
:r CYBHI_RESUBMIT_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS_CORE.sql
:r CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW.sql
:r CYBHI_Service_Selections_View.sql

:r CONTACT_METHODS_VIEW.sql
:r PATIENT_PRACTITIONERS_VIEW.sql

/*Parent_Patient portal*/
:r PATIENT_DATA_SAVE.sql
:r PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE.sql

/*Patient Portal Invite*/

:r PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE.sql	
:r PATIENT_PERSON_PORTAL_INVITE_SAVE.sql

:r PATIENT_PORTAL_INVITE_SAVE_CORE.sql	
:r PATIENT_PORTAL_INVITE_SAVE.sql

:r STORED_FILE_SHARE_WITH_PATIENT_ON.sql
:r STORED_FILE_SHARE_WITH_PATIENT_OFF.sql
:r STORED_FILE_SHARE_WITH_PARENT_GUARDIAN_ON.sql
:r STORED_FILE_SHARE_WITH_PARENT_GUARDIAN_OFF.sql

:r FILE_CLASS_SAVE.sql

/*Patient Goal Import*/
:r Import_From_Patient_Goal_Records_Save.sql
:r Import_From_Patient_Goal_Records_View_Core.sql
:r Import_From_Patient_Goal_Records_View.sql

:r CYBHI_CONSORTIUM_MEMBERS_VIEW.sql

:r CYBHI_SERVICE_RECORDS_ORP_REVIEWS_VIEW_CORE.sql
:r CYBHI_SERVICE_RECORDS_ORP_REVIEWS_VIEW.sql
:r CYBHI_SERVICE_RECORDS_ORP_REVIEWS_ACCEPT_OR_REJECT_REC.sql

:r SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW_CORE.sql
:r SERVICE_RECORDS_INTERNAL_REVIEWS_VIEW.sql
:r SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC.sql

:r SPED_ASSESSMENT_TOOLS_VIEW.sql
:r SPED_BASELINE_UNIT_VIEW.sql
:r SPED_PRESENT_LEVEL_VIEW.sql

:r RPT_CURRENT_AND_EXPIRING_ORDERS.sql

:r Claims_Post_Rollback.sql

:r SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm.sql
:r SPED_VEHICLE_ADAPTATIONS_VIEW.sql

:r CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE.sql
:r CYBHI_DENIED_CLAIMS_VIEW_CORE.sql

:r PATIENT_ACCOMMODATIONS_VIEW_CORE.sql
:r PATIENT_ACCOMMODATIONS_VIEW.sql
:r PATIENT_ACCOMMODATIONS_Delete_Inline.sql
:r PATIENT_ACCOMMODATIONS_Save_Core.sql
:r PATIENT_ACCOMMODATIONS_Save.sql
:r SPED_ACOMMODATION_LOOKUP_VIEW.sql


/* Keep spedcare weekly report extended at the end of this file */

:r RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE.sql
:r RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED.sql

/* Keep general data updates at the end of this file */

:r GENERAL_DATA_UPDATES.sql

PRINT 'Done'
