USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_DATA_TO_CLAIMS_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_DATA_TO_CLAIMS_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_DATA_TO_CLAIMS_DATA] (
    @clientID         bigint
  , @groupID          bigint
  , @planType         int
  , @dos              date
  , @nameID           int
  , @svcDetFlag1      bit
  , @svcDetFlag2      bit 
  , @svcDetFlag3      bit 
  , @svcDetFlag4      bit
  , @numMins          int
  , @numTrips         int
  , @numMiles         decimal(7,1)
  , @billingProgramID tinyint
)
 
/***************************************************************************    
 * SERVICE_DATA_TO_CLAIMS_DATA */    
/**    
 * Generate claims data from service data
 *
 * @param   clientID      Client ID
 * @param   groupID       Allied disp group id for rendering prac
 * @param   planType      Plan type
 * @param   dos           Date of service
 * @param   nameID        Name ID of service selection
 * @param   svcDetFlag1   Service detail flag 1
 * @param   svcDetFlag2   Service detail flag 2
 * @param   svcDetFlag3   Service detail flag 3
 * @param   svcDetFlag4   Service detail flag 4 
 * @param   numMins       For minute based services, the number of minutes
 * @param   numTrips      For mile based services, the number of trips
 * @param   numMiles      For mile based services, the number of miles
 *
 * @returns Table of claim data
 *
 ***************************************************************************/ 
      
RETURNS @claims_data TABLE (
    CLAIM_NUM                int
  , PROCEDURE_ID             bigint
  , PROCEDURE_PROC_MOD_COMBO varchar(100)
  , NUM_UNITS                int
)
AS     
BEGIN

/*####################################################################
  # Scalar variables
  ####################################################################*/     

declare @num_sel_recs                                      as int = null
declare @selection_procedure_id                            as int = null
declare @select_proc_for_claim_using_child_procs           as bit = null
declare @select_proc_for_claim_using_name_id_and_proc_data as bit = null
declare @select_proc_for_claim_using_svc_det_flags         as bit = null
declare @select_proc_for_claim_using_num_mins              as bit = null
declare @select_proc_for_claim_using_num_mins_min_count    as int = null
declare @select_proc_for_claim_using_num_mins_max_count    as int = null
declare @time_unit_mins_start_1                            as int = null
declare @time_unit_mins_end_1                              as int = null
declare @time_unit_mins_round_at_1                         as int = null
declare @time_unit_mins_start_2                            as int = null
declare @time_unit_mins_end_2                              as int = null
declare @time_unit_mins_round_at_2                         as int = null
declare @service_type_id                                   as int = null
declare @procedure_is_cpt_procedure                        as bit = null
declare @procedure_claim_span_2                            as bit = null
declare @service_entry_minutes_required                    as bit = null
declare @service_entry_miles_required                      as bit = null
declare @service_entry_svc_detail_flags_required           as bit = null
declare @svc_det_flags_value                               as int = null
declare @proc_id                                           as int = null
declare @min_units_1                                       as int = null
declare @max_units_1                                       as int = null
declare @min_units_2                                       as int = null
declare @max_units_2                                       as int = null

declare @svc_sel_procedure_unit_type                       as varchar(50)
declare @svc_sel_procedure_min_units                       as int = null
declare @svc_sel_procedure_max_units                       as int = null

declare @first_idx                                         as int = 0
declare @last_idx                                          as int = 0
declare @curr_idx                                          as int = 0
declare @unitCount                                         as int = 0
declare @minCount                                          as int = 0
declare @procedureSelectionMode                            as tinyint = 0

/*####################################################################
  # Table variables
  ####################################################################*/     

declare @all_associated_service_proc_recs as table (
    SERVICE_TYPE_ID                         int
  , SERVICE_NAME_ID                         int
  , SERVICE_NAME                            varchar(100)
  , SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED bit
  , SERVICE_ENTRY_MINUTES_REQUIRED          bit
  , SERVICE_ENTRY_MILES_REQUIRED            bit

  , PROCEDURE_ID                            bigint
  , PROCEDURE_PARENT_PROCEDURE_ID           bigint
  , PROCEDURE_PROC_MOD_COMBO                varchar(100)
  , PROCEDURE_NAME                          varchar(100)

  , PROCEDURE_IS_SERVICE_SELECTION    bit
  , PROCEDURE_IS_CPT_PROCEDURE        bit
  , PROCEDURE_CLAIM_SPAN_2            bit
  , PROCEDURE_HAS_22                  bit
  , PROCEDURE_TRANS_PROC_NUM          int
  , PROCEDURE_MIN_UNITS               int
  , PROCEDURE_MAX_UNITS               int

  , SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS                           bit
  , SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA                 bit
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS                         bit
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE        int
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE int
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS                              bit
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT                    int
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT                    int
  , TIME_UNIT_MINS_START                                              int
  , TIME_UNIT_MINS_END                                                int
  , TIME_UNIT_MINS_ROUND_AT                                           int
  , PROCEDURE_UNIT_TYPE                                               varchar(50)
)

declare @possible_claim_procs as table ( 
    IDX                            int identity(1,1)
  , UNIT_IDX                       int
  , PROCEDURE_ID                   bigint
)

declare @actual_claim_procs as table (
    CLAIM_NUM                      int
  , PROCEDURE_ID                   bigint
  , NUM_UNITS                      int 
)

declare @units TABLE (
    IDX               int
  , NUM_UNITS         int
  , NUM_MINS          int
  , NUM_TRIPS         int
  , NUM_MILES         int
)

/*####################################################################
  # Exit if parms that are required for ALL cases are not provided
  ####################################################################*/     

if (@clientID is null) return
if (@groupID  is null) return
if (@planType is null) return
if (@nameID   is null) return
if (@dos      is null) return

if (@billingProgramID is null) return

/*####################################################################
  # Get all service + procedure records that are associated with
  # the service selection.  This data will be referenced by
  # subsequent parts of this function.
  ####################################################################*/     

insert into @all_associated_service_proc_recs (
    SERVICE_TYPE_ID  
  , SERVICE_NAME_ID
  , SERVICE_NAME 

  , SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED
  , SERVICE_ENTRY_MINUTES_REQUIRED
  , SERVICE_ENTRY_MILES_REQUIRED

  , PROCEDURE_ID                  
  , PROCEDURE_PARENT_PROCEDURE_ID 
  , PROCEDURE_PROC_MOD_COMBO      
  , PROCEDURE_NAME                

  , PROCEDURE_IS_SERVICE_SELECTION                                    
  , PROCEDURE_IS_CPT_PROCEDURE                                        
  , PROCEDURE_CLAIM_SPAN_2
  , PROCEDURE_HAS_22
  , PROCEDURE_TRANS_PROC_NUM
  , PROCEDURE_MIN_UNITS
  , PROCEDURE_MAX_UNITS

  , SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS                           
  , SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA                 
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS                         
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE        
  , SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT
  , TIME_UNIT_MINS_START
  , TIME_UNIT_MINS_END
  , TIME_UNIT_MINS_ROUND_AT
  , PROCEDURE_UNIT_TYPE
)
select 
    svac.SERVICE_TYPE_ID  
  , svac.SERVICE_NAME_ID
  , svac.SERVICE_NAME 

  , svac.SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED
  , svac.SERVICE_ENTRY_MINUTES_REQUIRED
  , svac.SERVICE_ENTRY_MILES_REQUIRED

  , svac.PROCEDURE_ID                  
  , svac.PROCEDURE_PARENT_PROCEDURE_ID 
  , svac.PROCEDURE_PROC_MOD_COMBO      
  , svac.PROCEDURE_NAME                

  , svac.PROCEDURE_IS_SERVICE_SELECTION                                    
  , svac.PROCEDURE_IS_CPT_PROCEDURE                                        
  , svac.PROCEDURE_CLAIM_SPAN_2
  , svac.PROCEDURE_HAS_22
  , svac.PROCEDURE_TRANS_PROC_NUM
  , svac.PROCEDURE_MIN_UNITS
  , svac.PROCEDURE_MAX_UNITS

  , svac.SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS                           
  , svac.SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA                 
  , svac.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS                         
  , svac.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE        
  , svac.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE
  , svac.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
  , svac.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT
  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT = svac.SEL_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT

  , svac.TIME_UNIT_MINS_START
  , svac.TIME_UNIT_MINS_END
  , svac.TIME_UNIT_MINS_ROUND_AT
  , svac.PROCEDURE_UNIT_TYPE

from dbo.SERVICES_VIEW_ALL_CORE (  @clientID
                                 , @groupID
                                 , @planType
                                 , null         /* All service types */
                                 , @nameID
                                 , 1            /* In allowed procs */
                                 , 1            /* Active proc */
                                 , @dos
                                 , null         /* All associated proc recs */) as svac
order by 
  svac.PROCEDURE_IS_SERVICE_SELECTION desc      /* Puts service selection as top record */
option (recompile)

/*####################################################################
  # Validate and get service selection record data from the 
  # service + procedure records we retrieved.
  ####################################################################*/     

/*============================================================
 * Count the number of possible service selection recs available
 *============================================================*/     

select @num_sel_recs = COUNT(SERVICE_NAME_ID) from @all_associated_service_proc_recs where (PROCEDURE_IS_SERVICE_SELECTION = 1) option (recompile)

/*============================================================
 * If this count IS NOT 1 then get out!!!
 *============================================================*/     

if (@num_sel_recs != 1) return

/*============================================================
 * Retrieve selection data we will use for further validation
 * and processing.
 *============================================================*/     

select top 1  
    @selection_procedure_id                             = t1.PROCEDURE_ID
  , @service_type_id                                    = t1.SERVICE_TYPE_ID
  , @procedure_is_cpt_procedure                         = t1.PROCEDURE_IS_CPT_PROCEDURE
  , @select_proc_for_claim_using_child_procs            = t1.SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS
  , @select_proc_for_claim_using_name_id_and_proc_data  = t1.SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA
  , @select_proc_for_claim_using_svc_det_flags          = t1.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS
  , @select_proc_for_claim_using_num_mins               = t1.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
  , @select_proc_for_claim_using_num_mins_min_count     = t1.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT  
  , @select_proc_for_claim_using_num_mins_max_count     = t1.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT  
  , @procedure_claim_span_2                             = t1.PROCEDURE_CLAIM_SPAN_2
  , @service_entry_minutes_required                     = t1.SERVICE_ENTRY_MINUTES_REQUIRED
  , @service_entry_miles_required                       = t1.SERVICE_ENTRY_MILES_REQUIRED
  , @service_entry_svc_detail_flags_required            = t1.SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED
 
  , @svc_sel_procedure_unit_type                        = t1.PROCEDURE_UNIT_TYPE
  , @svc_sel_procedure_min_units                        = t1.PROCEDURE_MIN_UNITS
  , @svc_sel_procedure_max_units                        = t1.PROCEDURE_MAX_UNITS

from @all_associated_service_proc_recs as t1
where 
  (t1.PROCEDURE_IS_SERVICE_SELECTION = 1)
option (recompile)

/*####################################################################
  # Exit if parms that are service type specific are not passed
  ####################################################################*/     

/*============================================================
 * If minutes are required 
 *============================================================*/     

if (@service_entry_minutes_required = 1)
begin

  /*-------------------------------    
   * Get out if not provided
   *------------------------------*/   

  if (@numMins is null) return

end

/*============================================================
 * If trips/miles are required 
 *============================================================*/     

if (@service_entry_miles_required = 1)
begin
  
  /*-------------------------------    
   * Get out if not provided
   *------------------------------*/   

  if (@numTrips is null) return
  if (@numMiles is null) return

end

/*============================================================
 * If detail flags are required check to see if they were
 * provided then compute integer value of flags
 *============================================================*/     

if (@service_entry_svc_detail_flags_required = 1)
begin

  /*-------------------------------    
   * Get out if flags were not
   * provided
   *------------------------------*/   

  if (@svcDetFlag1 is null) return
  if (@svcDetFlag2 is null) return
  if (@svcDetFlag3 is null) return
  if (@svcDetFlag4 is null) return

  /*-------------------------------    
   * Compute flags value
   *------------------------------*/   

  set @svc_det_flags_value = 0  
  set @svc_det_flags_value = case when (@svcDetFlag1 = 1) then 1 else 0 end
                           + case when (@svcDetFlag2 = 1) then 2 else 0 end
                           + case when (@svcDetFlag3 = 1) then 4 else 0 end 
                           + case when (@svcDetFlag4 = 1) then 8 else 0 end

end

/*####################################################################
  # Determine procedure selection mode
  ####################################################################*/     

set @procedureSelectionMode = 0

set @procedureSelectionMode = dbo.DETERMINE_PROCEDURE_SELECTION_MODE (
    1 /*@procedure_is_service_selection */
  , @procedure_is_cpt_procedure 
  , @select_proc_for_claim_using_child_procs
  , @select_proc_for_claim_using_name_id_and_proc_data 
  , @select_proc_for_claim_using_svc_det_flags 
  , @service_entry_svc_detail_flags_required 
  , @select_proc_for_claim_using_num_mins 
  , @select_proc_for_claim_using_num_mins_min_count 
)

if (@procedureSelectionMode = 0)
begin
  /* Unknown mode */
  return
end

/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  ||
  ||                     LEA BOP Billing Program               
  ||
  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

if (@billingProgramID = 1)
begin

/*####################################################################
  # Procedure Selection Mode 1
  # Procedure selection based on details selected
  # 1 to 4 claim lines possible
  ####################################################################*/     

if (@procedureSelectionMode = 1)
begin

  /*############################################################
    # Select Procedure(s) and Calc Units
    ############################################################*/     

  /*============================================================
   * Assessements
   *============================================================*/     

  if (@service_type_id = dbo.CONST_SERVICES_ASSESS())
  begin

    /*-------------------------------    
     * Get possible procedures
     *------------------------------*/   

    insert into @possible_claim_procs (
	    UNIT_IDX           
      , PROCEDURE_ID
	)  
    select
       UNIT_IDX      = 1 /* Will always be 1 for this selection mode */
     , PROCEDURE_ID  
    from
    (
      select    
        *
        , [USE_PROCEDURE_FOR_CLAIM] = convert(bit, (case when (APPLY_MASK_RESULT = SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE) then 1 else 0 end))
      from
      (
        select 
          * 
          , [APPLY_MASK_RESULT] = (@svc_det_flags_value & SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE)
    
        from @all_associated_service_proc_recs
        where (
              (PROCEDURE_PARENT_PROCEDURE_ID             = @selection_procedure_id)
          and (PROCEDURE_IS_CPT_PROCEDURE                = 1)
          and (SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS = 1)
          and (PROCEDURE_CLAIM_SPAN_2                    = 0)
        )
      ) as t1
    ) as t2    
    where (USE_PROCEDURE_FOR_CLAIM = 1)
    option(recompile)

    /*-------------------------------    
     * Compute units one procedure
     * at a time
     *------------------------------*/   

    select @first_idx = min(idx) from @possible_claim_procs
    select @last_idx  = max(idx) from @possible_claim_procs
    select @curr_idx  = @first_idx

    while (@curr_idx <= @last_idx)
    begin
  
      set @proc_id     = null
      set @min_units_1 = null
      set @max_units_1 = null
      set @min_units_2 = null
      set @max_units_2 = null

      select top 1 
	    @proc_id = PROCEDURE_ID 
	  from @possible_claim_procs 
	  where (IDX = @curr_idx) 
	  option (recompile)
      
      select top 1 
          @min_units_1 = PROCEDURE_MIN_UNITS  
        , @max_units_1 = PROCEDURE_MAX_UNITS
        , @min_units_2 = null
        , @max_units_2 = null
      from @all_associated_service_proc_recs 
      where (PROCEDURE_ID = @proc_id)
      option (recompile)
      
	  insert into @actual_claim_procs (
	      CLAIM_NUM                     
        , PROCEDURE_ID     
        , NUM_UNITS  
	  )
      select top 1 
          CLAIM_NUM    = @curr_idx
        , PROCEDURE_ID = @proc_id
        , NUM_UNITS    = NUM_UNITS
      from dbo.CALC_CLAIMS_Units ( 
          @service_type_id
        , @procedure_claim_span_2
        , @min_units_1
        , @max_units_1
        , @min_units_2
        , @max_units_2
        , @numMins
        , @numTrips
        , @numMiles
       )
       where (IDX = 1)
       option(recompile)

       set @curr_idx = @curr_idx + 1
    end
  end
    
  /*============================================================
   * Other types of service are currently not supported
   *============================================================*/     

  else   
  begin
    return
  end

end

/*####################################################################
  # Procedure Selection Mode 2
  # Initial procedure selection and additional procedure selection
  # based on mins OR trip procedure selection and miles procedure 
  # selection.  1-2 claim lines possible.
  ####################################################################*/     

else if (@procedureSelectionMode = 2) 
begin

  /*############################################################
    # Select Procedure(s) and Get Parameter Data Needed for
    # Calling Unit Calculation Routine
    ############################################################*/     

  set @proc_id     = 0
  set @min_units_1 = 0
  set @max_units_1 = 0
  set @min_units_2 = 0
  set @max_units_2 = 0

  /*============================================================
   * Assessements
   * TCM
   * Treatment
   *============================================================*/     
  
  if 
  (
       (@service_type_id = dbo.CONST_SERVICES_ASSESS()     )
   or  (@service_type_id = dbo.CONST_SERVICES_TCM()        )
   or  (@service_type_id = dbo.CONST_SERVICES_TREATMENT()  )
  )

  begin
  
    /*-------------------------------    
     * Procedure 1
     *------------------------------*/   
     
    /* Get procedure id and min/max unit data */
 
    select top 1 
       @proc_id     = PROCEDURE_ID 
      ,@min_units_1 = PROCEDURE_MIN_UNITS  
      ,@max_units_1 = PROCEDURE_MAX_UNITS
    from @all_associated_service_proc_recs 
    where ( 
          (PROCEDURE_IS_CPT_PROCEDURE = 1)   /* Actual CPT proc */
      and (PROCEDURE_HAS_22           = 0)   /* No 22 modifier */
    )
	option (recompile)
      
    /* Store in possible claim procs */
    
    insert into @possible_claim_procs (
	    UNIT_IDX           
      , PROCEDURE_ID
	)
    select 
       UNIT_IDX     = 1         /* Match up with 1st unit record calculated*/
     , PROCEDURE_ID = @proc_id
      
    /*-------------------------------    
     * Procedure 2
     * If applicable
     *------------------------------*/   

    if (@procedure_claim_span_2 = 1)
    begin
          
      set @proc_id = null
      
      /* Get procedure id and min/max unit data */

      select top 1 
         @proc_id     = PROCEDURE_ID 
        ,@min_units_2 = PROCEDURE_MIN_UNITS  
        ,@max_units_2 = PROCEDURE_MAX_UNITS
      from @all_associated_service_proc_recs 
      where (
            (PROCEDURE_IS_CPT_PROCEDURE = 1)  /* Actual CPT proc*/
        and (PROCEDURE_HAS_22           = 1)  /* With a 22 modifier */        
      )
      option (recompile)
        
      /* Store in possible claim procs */

      insert into @possible_claim_procs ( 
	      UNIT_IDX           
        , PROCEDURE_ID
	  )
      select 
          UNIT_IDX     = 2         /* Match up with 2nd unit record calculated*/
        , PROCEDURE_ID = @proc_id
      
    end /* Proc 2*/           
  end /* Assmt, TCM, Treat */

  /*============================================================
   * Transportation
   *============================================================*/     

  else if ( @service_type_id = dbo.CONST_SERVICES_TRANSPORT() )
  
  begin
      
    /*-------------------------------    
     * Procedure 1
     *------------------------------*/   

    /* Get procedure id and min/max unit data */
    
    select top 1 
       @proc_id     = PROCEDURE_ID 
      ,@min_units_1 = PROCEDURE_MIN_UNITS  
      ,@max_units_1 = PROCEDURE_MAX_UNITS
    from @all_associated_service_proc_recs 
    where ( 
          (PROCEDURE_IS_CPT_PROCEDURE = 1)  /* Actual CPT procedure */
      and (PROCEDURE_TRANS_PROC_NUM   = 1)  /* Trips procedure for transportation */
    )
	option (recompile)
      
    /* Store in possible claim procs */
    
    insert into @possible_claim_procs (
	    UNIT_IDX           
      , PROCEDURE_ID
	)
    select 
       UNIT_IDX     = 1         /* Match up with 1st unit record calculated, numTrips*/
     , PROCEDURE_ID = @proc_id

    /*-------------------------------    
     * Procedure 2
     *------------------------------*/   
    
    set @proc_id = null
    
    /* Get procedure id and min/max unit data */

    select top 1 
       @proc_id     = PROCEDURE_ID 
      ,@min_units_2 = PROCEDURE_MIN_UNITS  
      ,@max_units_2 = PROCEDURE_MAX_UNITS
    from @all_associated_service_proc_recs 
    where ( 
          (PROCEDURE_IS_CPT_PROCEDURE = 1)  /* Actual CPT procedure */
      and (PROCEDURE_TRANS_PROC_NUM   = 2)  /* Miles procedure for transportation */
    )
	option (recompile)
        
    /* Store in possible claim procs */

    insert into @possible_claim_procs (
	    UNIT_IDX           
      , PROCEDURE_ID
	)

    select 
       UNIT_IDX       = 2          /* Match up with 2nd unit record calculated, numMiles */
     , PROCEDURE_ID   = @proc_id  
            
  end

  /*============================================================
   * Procedure selection for other service types in this mode
   * are currently not supported.
   *============================================================*/     
   
  else  
  begin
    return
  end

  /*############################################################
    # Calculate Units(s) and Get Actual Claim Procs
   *############################################################*/     

  /*============================================================
   * Calculate Units
   *============================================================*/     

  insert into @units (
      IDX        
    , NUM_UNITS
    , NUM_MINS 
    , NUM_TRIPS
    , NUM_MILES
  )
  select * 
  from dbo.CALC_CLAIMS_Units( 
     @service_type_id
    ,@procedure_claim_span_2
    ,@min_units_1
    ,@max_units_1
    ,@min_units_2
    ,@max_units_2
    ,@numMins
    ,@numTrips
    ,@numMiles
  )
  option (recompile)
      
  /*============================================================
   * Get actual claim procs.  Possible claim procedures that are
   * not used will be factored out as part of the join logic.
   *============================================================*/     
  
  insert into @actual_claim_procs (
	    CLAIM_NUM                     
      , PROCEDURE_ID     
      , NUM_UNITS  
  )
  select  
     t1.IDX           as CLAIM_NUM
    ,t1.PROCEDURE_ID      
    ,t2.NUM_UNITS
  from @possible_claim_procs as t1
  join @units                as t2 on t2.IDX = t1.UNIT_IDX  
  option (recompile)
      
end

/*####################################################################
  # Procedure Selection Mode 3
  # Single procedure selection based on num mins
  ####################################################################*/     

else if (@procedureSelectionMode = 3)
begin
 
 /*############################################################
   # Get unit limits
   ############################################################*/     

  set @min_units_1 = 0
  set @max_units_1 = 0
  
  select top 1 
      @min_units_1 = t1.PROCEDURE_MIN_UNITS
	, @max_units_1 = t1.PROCEDURE_MAX_UNITS
  from @all_associated_service_proc_recs as t1
  where (PROCEDURE_ID = @selection_procedure_id) 
  option(recompile)

  /*############################################################
    # Calc rounded minutes, select procedure, and calc units
    ############################################################*/     

  /*============================================================
   * Calculate rounded minutes (using unit calculator)
   * This is for any type of service
   *============================================================*/     
  
  /* Get unit count */

  set @unitCount = 0
  
  select top 1  
    @unitCount = t1.NUM_UNITS
  from dbo.CALC_CLAIMS_Units ( 
      2 /* We use a treatment to trigger the routine to calculate units from minutes */
    , 0 
    , @min_units_1 /* This will ensure the lowest possible # of minutes gets a service selection*/
    , @max_units_1 /* This will endure any number of minutes over the max gets the service selection that matches the max */
    , 0 
    , 0 
    , @numMins     /* Number of minutes the user entered*/
    , 0
    , 0
  ) as t1
  option (recompile)
  
  /* Calc minute count to use to match the procedure.  This is not the same minutes user entered.  Rather its 
   * the number of rounded minutes (calculated using the # of units and minute/per unit constant). */

  set @minCount = (@unitCount * dbo.CONST_TIME_UNIT_MIN())

  /*============================================================
   * Assessements
   *============================================================*/     

  if (@service_type_id = dbo.CONST_SERVICES_ASSESS())
  begin
    
	/*-------------------------------    
     * Get possible procedures
     *------------------------------*/   

     insert into @possible_claim_procs (
	     UNIT_IDX           
       , PROCEDURE_ID
	  )
 
      select top 1
		   UNIT_IDX = 1 /* Will always be 1 */
         , t1.PROCEDURE_ID    
      from @all_associated_service_proc_recs as t1
      where (
            (PROCEDURE_PARENT_PROCEDURE_ID                  = @selection_procedure_id)          
		and (PROCEDURE_IS_CPT_PROCEDURE                     = 1)          
		and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS           = 1)
        and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT = @minCount) /* This does the selection */
      ) 
      option(recompile)

	  /* Get units (will always be 1 unit as the procedure code indicates the minutes) */

	  insert into @units (   IDX
	                       , NUM_UNITS
						   , NUM_MINS
						   , NUM_TRIPS
						   , NUM_MILES)
      values     
       (1,1,@minCount,0,0)    
      option (recompile)
  end
  
  /*============================================================
   * Other types of service are currently not supported
   *============================================================*/     

  else   
  begin
    return
  end

  /*============================================================
   * Get actual claim procs.  Possible claim procedures that are
   * not used will be factored out as part of the join logic.
   *============================================================*/     
  
  insert into @actual_claim_procs (
	    CLAIM_NUM                     
      , PROCEDURE_ID     
      , NUM_UNITS  
  )
  select  
     t1.IDX           as CLAIM_NUM
    ,t1.PROCEDURE_ID      
    ,t2.NUM_UNITS
  from @possible_claim_procs as t1
  join @units                as t2 on t2.IDX = t1.UNIT_IDX  
  option (recompile)

end
else 
begin
  return
end

end /* LEA BOP*/

-------------------------------------------------------------------------------

/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  ||
  ||                      CYBHI Billing Program               
  ||
  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

else if (@billingProgramID = 2)
begin

/*####################################################################
  # Procedure Selection Mode 1
  # Procedure selection based on details selected
  # 1 to 4 claim lines possible
  ####################################################################*/     

if (@procedureSelectionMode = 1)
begin
  return /* Not supported */
end

/*####################################################################
  # Procedure Selection Mode 2
  # Initial procedure selection and additional procedure selection
  # based on mins.  1-2 claim lines possible.
  ####################################################################*/     

else if (@procedureSelectionMode = 2) 
begin

  /*############################################################
    # Select Procedure(s) and Get Parameter Data Needed for
    # Calling Unit Calculation Routine
    ############################################################*/     

  set @proc_id                   = 0
  set @min_units_1               = 0
  set @max_units_1               = 0
  set @min_units_2               = 0
  set @max_units_2               = 0
  set @time_unit_mins_start_1    = 0
  set @time_unit_mins_end_1      = 0
  set @time_unit_mins_round_at_1 = 0
  set @time_unit_mins_start_2    = 0
  set @time_unit_mins_end_2      = 0
  set @time_unit_mins_round_at_2 = 0

  /*-------------------------------    
   * Procedure 1
   *------------------------------*/   
     
  /* Get procedure id and min/max unit data */
 
  select top 1 
      @proc_id                   = t1.PROCEDURE_ID 
    , @min_units_1               = t1.PROCEDURE_MIN_UNITS  
    , @max_units_1               = t1.PROCEDURE_MAX_UNITS
	, @time_unit_mins_start_1    = t1.TIME_UNIT_MINS_START
	, @time_unit_mins_end_1      = t1.TIME_UNIT_MINS_END
	, @time_unit_mins_round_at_1 = t1.TIME_UNIT_MINS_ROUND_AT
  from @all_associated_service_proc_recs as t1
  where ( 
        (t1.PROCEDURE_IS_CPT_PROCEDURE = 1)   /* Actual CPT proc */
    and (t1.PROCEDURE_HAS_22           = 0)   /* No 22 modifier */
  )
  option (recompile)
      
  /* Store in possible claim procs */
    
  insert into @possible_claim_procs (
	  UNIT_IDX           
    , PROCEDURE_ID
  )
  select 
     UNIT_IDX     = 1         /* Match up with 1st unit record calculated*/
   , PROCEDURE_ID = @proc_id
      
  /*-------------------------------    
   * Procedure 2
   * If applicable
   *------------------------------*/   

  if (@procedure_claim_span_2 = 1)
  begin
          
    set @proc_id = null
      
    /* Get procedure id and min/max unit data */

    select top 1 
        @proc_id                   = t1.PROCEDURE_ID 
      , @min_units_2               = t1.PROCEDURE_MIN_UNITS  
      , @max_units_2               = t1.PROCEDURE_MAX_UNITS
	  , @time_unit_mins_start_2    = t1.TIME_UNIT_MINS_START
	  , @time_unit_mins_end_2      = t1.TIME_UNIT_MINS_END
	  , @time_unit_mins_round_at_2 = t1.TIME_UNIT_MINS_ROUND_AT
    from @all_associated_service_proc_recs as t1 
    where (
          (t1.PROCEDURE_IS_CPT_PROCEDURE = 1)  /* Actual CPT proc*/
      and (t1.PROCEDURE_HAS_22           = 1)  /* With a 22 modifier */        
    )
    option (recompile)
        
    /* Store in possible claim procs */

    insert into @possible_claim_procs ( 
	    UNIT_IDX           
      , PROCEDURE_ID
	)
    select 
        UNIT_IDX     = 2         /* Match up with 2nd unit record calculated*/
      , PROCEDURE_ID = @proc_id
      
    end /* Proc 2*/           
   
   /*############################################################
     # Calculate Units(s) and Get Actual Claim Procs
     ############################################################*/     

	declare @encounter as bit = 0

	/*============================================================
     * Determine if this is an encounter	 
     *============================================================*/     

	if (    (@svc_sel_procedure_unit_type = 'SERVICE')
        and (@svc_sel_procedure_min_units = 0)
        and (@svc_sel_procedure_max_units = 1)
		and (@procedure_is_cpt_procedure  = 1))
	begin
	  set @encounter = 1
	end
	else
	begin
	  set @encounter = 0
	end

	
	/*============================================================
     * If encounter then number of units is always 1 and number
	 * of procs is always 1
     *============================================================*/     
	
	if (@encounter = 1)
	begin
	
	  insert into @units (
          IDX        
        , NUM_UNITS
        , NUM_MINS 
        , NUM_TRIPS
        , NUM_MILES
      )
	  select 
	      IDX       = 1
	    , NUM_UNITS = 1
	    , NUM_MINS  = @numMins
        , NUM_TRIPS = 0
        , NUM_MILES = 0
	end
	
	/*============================================================
     * If not encounter then calculate units
     *============================================================*/     
	
	else
	begin
	
	  insert into @units (
          IDX        
        , NUM_UNITS
        , NUM_MINS 
        , NUM_TRIPS
        , NUM_MILES
      )
	  select 
	      IDX       = t1.idx 
	    , NUM_UNITS = t1.numUnitsAssigned
	    , NUM_MINS  = t1.numMinsApplied
        , NUM_TRIPS = 0
        , NUM_MILES = 0
	  from dbo.CALC_Claims_Units_For_Time_Units (    
         @procedure_claim_span_2
       , @min_units_1 
       , @max_units_1 
       , @min_units_2
       , @max_units_2
       , @time_unit_mins_start_1
       , @time_unit_mins_end_1
       , @time_unit_mins_round_at_1
       , @time_unit_mins_start_2
       , @time_unit_mins_end_2
       , @time_unit_mins_round_at_2 
       , @numMins  
     ) as t1
     option(recompile)
   end  

   /*============================================================
    * Get actual claim procs.  Possible claim procedures that are
    * not used will be factored out as part of the join logic.
    *============================================================*/     
  
    insert into @actual_claim_procs (
	      CLAIM_NUM                     
        , PROCEDURE_ID     
        , NUM_UNITS  
    )
    select  
        t1.IDX           as CLAIM_NUM
      , t1.PROCEDURE_ID      
      , t2.NUM_UNITS
    from @possible_claim_procs as t1
    join @units                as t2 on t2.IDX = t1.UNIT_IDX  
    option (recompile)

  end /* Mode 2 */

  /*####################################################################
    # Procedure Selection Mode 3
    # Single procedure selection based on num mins
    ####################################################################*/     

  else if (@procedureSelectionMode = 3)
  begin
    
	
	declare @minMins as int = 0
	declare @maxMins as int = 0
    
	select 
		 @minMins = min(t1.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT)
      ,  @maxMins = max(t1.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT)
    from @all_associated_service_proc_recs as t1
    where (
          (PROCEDURE_PARENT_PROCEDURE_ID                  = @selection_procedure_id)          
	  and (PROCEDURE_IS_CPT_PROCEDURE                     = 1)          
	  and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS           = 1)
    )

    /*-------------------------------    
     * Get possible procedure
     *------------------------------*/   

	if (@numMins between @minMins and @maxMins)
	begin
      
      insert into @possible_claim_procs (
	      UNIT_IDX           
        , PROCEDURE_ID
	  )
      select top 1
		     UNIT_IDX = 1 /* Will always be 1 */
           , t1.PROCEDURE_ID    
      from @all_associated_service_proc_recs as t1
      where (
            (PROCEDURE_PARENT_PROCEDURE_ID                  = @selection_procedure_id)          
	    and (PROCEDURE_IS_CPT_PROCEDURE                     = 1)          
	    and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS           = 1)
        and (@numMins between     SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT 
	                          and SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT)
      ) 
      option(recompile)
    end
	else
	begin
      
	  /* Mins is over most max so we pick the most max procedure */

	  if (@numMins > @maxMins)
	  begin
	    insert into @possible_claim_procs (
	        UNIT_IDX           
          , PROCEDURE_ID
	    )
        select top 1
		       UNIT_IDX = 1 /* Will always be 1 */
             , t1.PROCEDURE_ID    
        from @all_associated_service_proc_recs as t1
        where (
              (PROCEDURE_PARENT_PROCEDURE_ID                  = @selection_procedure_id)          
	      and (PROCEDURE_IS_CPT_PROCEDURE                     = 1)          
	      and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS           = 1)
          and (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT = @maxMins)
        ) 
        option(recompile)
	  end
	  
	end

	/*============================================================
    * Get actual claim procs.  Possible claim procedures that are
    * not used will be factored out as part of the join logic.
    *============================================================*/     
  
    insert into @actual_claim_procs (
	      CLAIM_NUM                     
        , PROCEDURE_ID     
        , NUM_UNITS  
    )
    select  
        t1.IDX           as CLAIM_NUM
      , t1.PROCEDURE_ID      
      , 1
    from @possible_claim_procs as t1
    option (recompile)

  end /* Mode 3*/
end /* CYBHI */
else
begin
  return
end /* Unknown billing program */

/*####################################################################
  # Output
 *####################################################################*/     

insert into @claims_data
select 
   t2.CLAIM_NUM
 , t2.PROCEDURE_ID
 , t1.PROCEDURE_PROC_MOD_COMBO
 , t2.NUM_UNITS
from @all_associated_service_proc_recs as t1
join @actual_claim_procs               as t2 on t2.PROCEDURE_ID = t1.PROCEDURE_ID
option (recompile)
      
return

END
GO

