
USE SPEDMON
GO
 
 
IF EXISTS (
  SELECT * FROM sys.objects
  WHERE object_id = OBJECT_ID('dbo.CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT')
        AND type in (N'P', N'PC')
)
DROP PROCEDURE dbo.CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT] (
 
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
 
  , @clientID          bigint

  , @fyear_id          bigint
  , @quarternum        bigint

  , @importDataJSON    varchar(max)
  , @editDelReason     varchar(7000)
  , @validateRec       bit
  , @saveType          int
  , @recID             bigint
  , @msgNoRec          varchar(1000)
  , @msgNoEdit         varchar(1000)
  , @msgDupRec         varchar(1000)
  , @msgDataError      varchar(1000)
  , @msgNotActive      varchar(1000)
  , @recordID          bigint        output
  , @spDetails         varchar(8000) output
  , @jsonData          varchar(max)  output
)
 
AS
BEGIN
 
SET NOCOUNT ON
 
 
DECLARE @ErrorMessage  AS NVARCHAR(4000) = ''
DECLARE @ErrorSeverity AS INT
DECLARE @ErrorState    AS INT
 
declare @noIssues      AS int = 1
 
declare @tranOpen               as bit = 0
declare @today                  as datetime
declare @structuredDataImportID as bigint
 
declare @paidResources as table (
      IDX                               int identity(1,1)
    , ROW_NUM                           int
 
    , employeeFullName                  varchar(255)
    , employeeNumber                    varchar(255)  -- is stored as a string in the database;
                                                      -- however it seems that non-numeric values are being erased
                                                      -- from this field during the spreadsheet import
  
    , resourceNum                       bigint
 
    , FTE                               real
    , Gross                             real
    , Net                               real
 
    , Wrk_Cmp                           real

    , Unemp                             real
    , FICA                              real

    , HW                                real
    , Medicare                          real

    , Ret_Empr                          real
    , OPEB                              real

    , Total_Employer_Paid_Benefits      real

    , PERS_Reduct_Amt                   real

    , Total_Employer_Paid_Benefits_W_hw real
 
    , prac_id                           bigint
    
    -- TODO: maybe later on we'll support multiple quarters in one import 

    , FOUND                     bit            default(0)

    , IS_IN_ROSTER              bit            default(0)
 
  unique clustered (IDX)
)
 
 
declare @maxIdxPracErrs                   as int           = 0
declare @currIdxPracErrs                  as int           = 1
 
declare @currPracID                    as bigint        = null

--declare @pracFound                     as bit           = 0
 
--declare @rowNum                       as int           = 0

--declare @lastName                     as varchar(255)  = ''
--declare @firstName                    as varchar(255)  = ''

declare @spDetailMsg                  as varchar(1000) = ''
 
declare @savesAttempted       as int           = 0
declare @savesOK              as int           = 0
 
declare @spSaveDetails as varchar(8000) = ''
declare @spSaveRecID     as bigint        = 0
declare @spSaveType      int
 
/*############################################################################
 *# Init
 *############################################################################*/
 
set @spDetails  = ''
set @recordID   = 0
set @jsonData   = '{}'
set @tranOpen   = 0
set @today      = getdate()
 
BEGIN TRY
 
/*############################################################################
 *# Exit if key values are not passed
 *############################################################################*/
 
IF (@clientID IS NULL) RAISERROR ('clientID is required',   11, 1)
 
/*############################################################################
 *# Parse imported data
 *############################################################################*/
 
insert into @paidResources (
      ROW_NUM
 
    , employeeFullName                  --varchar(255)
    , employeeNumber                    --varchar(255)  -- is stored as a string in the database
  
    , resourceNum                       --bigint
 
    --, FTE                               --real
    , Gross                             --real
    --, Net                               --real
 
    --, Wrk_Cmp                           --real

    --, Unemp                             --real
    --, FICA                              --real

    --, HW                                --real
    --, Medicare                          --real

    --, Ret_Empr                          --real
    --, OPEB                              --real

    , Total_Employer_Paid_Benefits      --real

    --, PERS_Reduct_Amt                   --real

    , Total_Employer_Paid_Benefits_W_hw --real
 
)
select

    --top 2000

    t1.ROW_NUM


  , employeeFullName   = trim(isnull(t1.employeeFullName,''))
  , employeeNumber     = trim(isnull(t1.employeeNumber,''))


  , resourceNum 
 
  --, FTE 

  , REPLACE(
      REPLACE( 
               REPLACE(
                 Gross
                 , ')'
                 , ''
               )
             , ','
             , ''
             )
      , '('
      , '-'   -- negative values coming in may be formated as (10,000) instead of -10,000
    )


  --, Net 
 
  --, Wrk_Cmp       -- int
  --, Unemp 
  --, FICA

  --, HW
  --, Medicare
  --, Ret_Empr
  --, OPEB

  , REPLACE(
      REPLACE( 
               REPLACE(
                 Total_Employer_Paid_Benefits
                 , ')'
                 , ''
               )
             , ','
             , ''
             )
      , '('
      , '-'   -- negative values coming in may be formated as (10,000) instead of -10,000
    )

  --, PERS_Reduct_Amt


  , REPLACE(
      REPLACE( 
               REPLACE(
                 Total_Employer_Paid_Benefits_W_hw
                 , ')'
                 , ''
               )
             , ','
             , ''
             )
      , '('
      , '-'   -- negative values coming in may be formated as (10,000) instead of -10,000
    )

 
FROM OPENJSON( @importDataJSON, '$.structuredDataRows' )
WITH (
      [ROW_NUM]           int           '$."rowNumIn"'

    , employeeFullName    varchar(255)  '$."rowData"."employeeFullName"'
    , employeeNumber      varchar(255)  '$."rowData"."employeeNumber"'
  
    , resourceNum         bigint        '$."rowData"."resource"'
 
    , FTE                 varchar(255)         '$."rowData"."FTE"'
    , Gross               varchar(255)          '$."rowData"."Gross"'
    , Net                 varchar(255)          '$."rowData"."Net"'
 
    , Wrk_Cmp             varchar(255)          '$."rowData"."Wrk_Cmp"'
    , Unemp               varchar(255)          '$."rowData"."Unemp"'

    , FICA                varchar(255)          '$."rowData"."FICA"'
    , HW                  varchar(255)          '$."rowData"."HW"'
    , Medicare            varchar(255)          '$."rowData"."Medicare"'

    , Ret_Empr            varchar(255)           '$."rowData"."Ret_Empr"'
    , OPEB                varchar(255)           '$."rowData"."OPEB"'

    , Total_Employer_Paid_Benefits         varchar(255)        '$."rowData"."Total_Employer_Paid_Benefits"'
    , PERS_Reduct_Amt                      varchar(255)        '$."rowData"."PERS_Reduct_Amt"'
    , Total_Employer_Paid_Benefits_W_hw    varchar(255)        '$."rowData"."Total_Employer_Paid_Benefits_W_hw"'

 
) as t1


-- iterative troubleshooting to find what cells/values aren't CASTing correctly

/* 
declare @xIdx bigint
declare @xIdxMax bigint
select @xIdxMax = MAX(ROW_NUM) FROM @paidResources
Select @xIdx    = MIN(ROW_NUM) FROM @paidResources

while (@xIdx <= @xIdxMax)
begin
  declare @rawTotal_Employer_Paid_Benefits_W_hw varchar(255)
  declare @rawGross                                varchar(255)

  SELECT
    @rawTotal_Employer_Paid_Benefits_W_hw =
    Total_Employer_Paid_Benefits_W_hw,
    @rawGross =
    Gross
  FROM @paidResources
  WHERE ROW_NUM = @xIdx

  SET @xIdx = @xIdx + 1

  BEGIN TRY
    declare @conv real = CAST(
      REPLACE( @rawTotal_Employer_Paid_Benefits_W_hw, ',', '') AS real)
  END TRY
  BEGIN CATCH

    SET @rawTotal_Employer_Paid_Benefits_W_hw = 
      @rawTotal_Employer_Paid_Benefits_W_hw  + ' ROW ' +  CAST(@xIdx as varchar)
    RAISERROR( @rawTotal_Employer_Paid_Benefits_W_hw, 13, 13)
  END CATCH

  BEGIN TRY
    declare @conv2 real = CAST(
      REPLACE( @rawGross, ',', '') AS real)
  END TRY
  BEGIN CATCH
    SET @rawGross = 
      @rawGross + ' ROW ' + CAST(@xIdx as varchar)

    RAISERROR( @rawGross, 13, 13)
  END CATCH

end
*/

 
update pr
  set pr.prac_id =  p_p.PRACTITIONER_ID,
      pr.FOUND   =  1
from @paidResources                     pr
join [dbo].[PRACTITIONER_Practitioner]  p_p on (p_p.clientEmployeeID = pr.employeeNumber)



join dbo.PRACTITIONER_Client            p_c on p_c.PRACTITIONER_ID = p_p.PRACTITIONER_ID
                                           AND p_c.CLIENT_ID = @clientID 

                                           AND p_p.ACTIVE = 1

; with inputrows_with_first_last_names as (
    SELECT
      IDX,
      employeeLastName   =  TRIM( SUBSTRING( employeeFullName,
                 0
                 ,
                 CHARINDEX(',' , employeeFullName , 0)
                 ) )
                 ,-- last_name


      employeeFirstName   = TRIM( SUBSTRING( employeeFullName,
                 CHARINDEX(',' , employeeFullName , 0)
                 + 1
                 ,
                 LEN( employeeFullName )
                 ) ) -- first_name
                 

       
    from @paidResources
  ),
  cte2_inputrows_with_first_last_names as (
    select
      IDX,
      employeeLastName,

      spacechar = ISNULL(
         CHARINDEX( ' ', employeeFirstName, 0)
         ,
         0
         ) ,

      employeeFirstName

      FROM  inputrows_with_first_last_names
  ),
  cte3_inputrows_with_first_last_names as (
    select
      IDX,
      employeeLastName,

      spacechar,

      employeeFirstName = 
        CASE WHEN  spacechar !=  0
        THEN
          TRIM (
            SUBSTRING( employeeFirstName , 0, spacechar )
          )
        ELSE  employeeFirstName
        END

      FROM  cte2_inputrows_with_first_last_names
  ),
  roster_list_with_first_last_names as (

    select
      prac_list.*, p_p.FIRST_NAME, p_p.LAST_NAME
    from
      [dbo].[CRCS_PRAC_SALARIES_VIEW_CORE] ( 
	                @clientID   
	              , @fyear_id
	              , @quarternum
	              , null
             ) prac_list
    JOIN
      [dbo].[PRACTITIONER_Practitioner]  p_p
      ON p_p.PRACTITIONER_ID = prac_list.pracID
  
)

update pr
  set 
      pr.IS_IN_ROSTER   =  1
from @paidResources                        pr
JOIN cte3_inputrows_with_first_last_names  input_rows
  ON pr.IDX = input_rows.IDX

JOIN roster_list_with_first_last_names     roster_list
  ON  roster_list.LAST_NAME  LIKE ( input_rows.employeeLastName + '%' )
      AND
      roster_list.FIRST_NAME LIKE ( input_rows.employeeFirstName + '%' )
                                           

if ( @validateRec = 1 )
BEGIN

select @maxIdxPracErrs = MAX(IDX) FROM @paidResources
set @currIdxPracErrs = 1

while (@currIdxPracErrs <= @maxIdxPracErrs)
begin
 
  --set @savesAttempted = 0
  --set @savesOK        = 0
    
 
  declare  @currCSVRownum          bigint

  declare  @currEmployeeFullName   varchar(255)

  --declare  @currEmployeeLastName   varchar(255)
  --declare  @currEmployeeFirstName   varchar(255)


  declare  @currEmployeeNumber     varchar(255)

  declare @currFound                  bit = 0

  declare @currInRoster               bit = 0
 
  --IF (@currIdxPracErrs > 1)
  --  SET @jsonData = @jsonData + ', '
 
  SELECT

    @currEmployeeFullName   =  employeeFullName  ,

    /*
    @currEmployeeLastName   =  TRIM( SUBSTRING( employeeFullName,
                 0
                 ,
                 CHARINDEX(',' , employeeFullName , 0)
                 ) )
                 ,-- last_name


    @currEmployeeFirstName   = TRIM( SUBSTRING( employeeFullName,
                 CHARINDEX(',' , employeeFullName , 0)
                 + 1
                 ,
                 LEN( employeeFullName )
                 ) ) -- first_name
                 ,
    */

    @currEmployeeNumber     =  employeeNumber,
    @currFound              = FOUND,
    @currInRoster           = IS_IN_ROSTER,
    @currCSVRowNum          = ROW_NUM
 
  FROM   @paidResources
  WHERE  IDX = @currIdxPracErrs

  /*
  declare @spacechar int = ISNULL(
         CHARINDEX( ' ', @currEmployeeFirstName, 0)
         ,
         0
       )

  if (
       @spacechar != 0
  )
  BEGIN

      SET @currEmployeeFirstName
        = TRIM (
            SUBSTRING( @currEmployeeFirstName , 0, @spacechar )
          )

  END
  */

  if (         @currFound = 0
       AND  @currInRoster = 1 )
  BEGIN

    declare @likelyMatchErr bit = 0

    /*

    -- always echo-out errors if there are notes and scribbles in the ID field
    BEGIN TRY
      select CAST( @currEmployeeNumber as bigint )
    END TRY
    BEGIN CATCH
      -- if not a number
      SET @likelyMatchErr = 1
    END CATCH


    if ( ISNULL( LEN(@currEmployeeNumber) , 0) =  0 )
      SET @likelyMatchErr = 1

    */

    -- otherwise, don't echo-out errors if the incoming payroll row doesn't appear to be a pracitioner;
    -- could be a substitute teacher or something.
    -- query PRACTITIONER_Practitioner by first and last name,
    -- but first, trim middle initial from @currEmployeeFirstName



    --if ( @likelyMatchErr = 0 )
        
        SET @likelyMatchErr = 1
        

    if (@likelyMatchErr = 1)
    BEGIN

      -- if this currect prac isn't already in the warning string
      
      if(
        ISNULL( 
          CHARINDEX(
            ' #' +
                CAST( ISNULL( @currEmployeeNumber, '' ) as varchar )
            ,
            @spDetails
            ,
            0
          )
          ,
          0) = 0
      )
      BEGIN

        set @spDetails =
          dbo.UPDATE_DETAILS(
            @spDetails
            , 'Issue processing row number ' +
                CAST( @currCSVRowNum as varchar ) + ' ' +
                'from your file ' + 
                '(the practitioner ' + 
                CAST( ISNULL(  REPLACE( @currEmployeeFullName , ',', '' ), '' ) as varchar ) + ' #' +
                CAST( ISNULL( @currEmployeeNumber, '' ) as varchar ) + ') ' +
                ' - This EmployeeNumber does not match an existing practitioner record in our system.  '
            , dbo.CONST_RET_WARN()
          ) ;

      END  -- if not already in the warning string

    END -- if @likelyMatchErr = 1
    
  END  -- if @currFound = 0
 
  -- increment to next row
  set @currIdxPracErrs = @currIdxPracErrs + 1

end  --while

END
ELSE -- @validateRec = 0
BEGIN
 
  BEGIN TRANSACTION
 
  set @tranOpen = 1
 
  exec dbo.Structured_Data_Imports_Save_Core
    @userID
 ,  @userGroup
 ,  @userRank
 ,  @clientID
 ,  @importDataJSON
 ,  1 /* @skipDupCheck*/
 ,  @editDelReason
 ,  @validateRec
 ,  @saveType
 ,  @recID
 ,  @msgNoRec
 ,  @msgNoEdit
 ,  @msgDupRec
 ,  @msgDataError
 ,  @msgNotActive
 ,  @spDetails                                 OUTPUT
 ,  @structuredDataImportID  OUTPUT
 
  COMMIT TRANSACTION
 
  set @tranOpen = 0
  set @recordID = @structuredDataImportID

  
  BEGIN TRANSACTION
 
  set @tranOpen = 1

  ; with paid_resource_totals_by_pracid_and_rsrc as
   (
       SELECT
          resourceNum , prac_id , @fyear_id fyear_id, @quarternum quarternum,
          SUM(Gross ) Gross , SUM( Total_Employer_Paid_Benefits_W_hw ) Total_Employer_Paid_Benefits_W_hw

          -- CASE WHEN resourceNum >= 3000 AND resourceNum < 5999 THEN 1 ELSE 0 END is_fed
       FROM @paidResources

       WHERE prac_id IS NOT NULL
         -- very important

       GROUP BY
         resourceNum , prac_id
   ),

   paid_resource_totals_by_pracid_w_is_fed as
   (
       SELECT
          prac_id , fyear_id , quarternum ,
          Gross , Total_Employer_Paid_Benefits_W_hw ,
          CASE WHEN resourceNum >= 3000 AND resourceNum < 5999 THEN 1 ELSE 0 END is_fed ,
          resourceNum
       FROM paid_resource_totals_by_pracid_and_rsrc
   ),
   paid_resource_totals_by_pracid_and_isfed as (
       SELECT
         b_p_i.prac_id , b_p_i.fyear_id, b_p_i.quarternum,
         SUM(b_p_i.Gross ) Gross , SUM( b_p_i.Total_Employer_Paid_Benefits_W_hw ) Total_Employer_Paid_Benefits_W_hw ,
         -- STRING_AGG( CAST( d.resourceNum as varchar(max) ) , ', ' )  resourceNums,
         resourceNums,
         b_p_i.is_fed
       FROM paid_resource_totals_by_pracid_w_is_fed b_p_i
       
         JOIN (
           SELECT
             prac_id , fyear_id , quarternum , is_fed,
             STRING_AGG( CAST( resourceNum as varchar(max) ) , ', ' )  resourceNums
             
             FROM paid_resource_totals_by_pracid_w_is_fed 

             GROUP BY prac_id , fyear_id , quarternum , is_fed
         ) d  ON
              d.prac_id        = b_p_i.prac_id
              AND d.fyear_id   = b_p_i.fyear_id
              AND d.quarternum = b_p_i.quarternum
              and d.is_fed     = b_p_i.is_fed

       
       GROUP BY
         b_p_i.prac_id , b_p_i.fyear_id , b_p_i.quarternum , b_p_i.is_fed
         ,
         resourceNums
   ),
   
   /*
   ,
   crcs_prac_ids_and_numbers as (
     SELECT
       p_p.PRACTITIONER_ID prac_id,
       p_p.clientEmployeeID
     FROM  [dbo].[CRCS_PRAC_SALARIES] crcs_salaries
     JOIN  dbo.PRACTITIONER_Practitioner p_p
       ON  crcs_salaries.clientID      = @clientID
       AND crcs_salaries.fiscalYearID  = @fyear_id
       AND crcs_salaries.quarterNumber = @quarternum
       AND p_p.PRACTITIONER_ID = p_p.PRACTITIONER_ID
   ),
   */
   
   crcs_salaries_full_joind_needs_updates as (
     SELECT
       federalSalary   = is_fed.Gross ,
       federalBenefits = is_fed.Total_Employer_Paid_Benefits_W_hw ,
       salary          = is_notfed.Gross ,
       benefits        = is_notfed.Total_Employer_Paid_Benefits_W_hw ,

       
       prac_id    = ISNULL( is_fed.prac_id,  is_notfed.prac_id )   ,
       fyear_id   = ISNULL( is_fed.fyear_id, is_notfed.fyear_id ) ,
       quarternum = ISNULL( is_fed.quarternum, is_notfed.quarternum )  ,

       federalResourceNums =  is_fed.resourceNums

     FROM  paid_resource_totals_by_pracid_and_isfed is_fed

     FULL JOIN  paid_resource_totals_by_pracid_and_isfed is_notfed
       ON  is_fed.prac_id = is_notfed.prac_id
         AND is_fed.is_fed = 1 AND is_notfed.is_fed = 0
         
     WHERE 

           ISNULL(is_fed.is_fed, 1) = 1 AND ISNULL(is_notfed.is_fed, 0) = 0
   )
   
   UPDATE  crcs_salaries

      SET  crcs_salaries.federalSalary   = _new_vals.federalSalary ,
           crcs_salaries.federalBenefits = _new_vals.federalBenefits ,
           crcs_salaries.salary          = _new_vals.salary ,
           crcs_salaries.benefits        = _new_vals.benefits ,

           
           crcs_salaries.federalSalaryResourceCode = 
             CASE WHEN _new_vals.federalSalary > 0  -- if federal salary exists
               THEN
                 SUBSTRING( federalResourceNums, 1, 49)  -- use relevant resource code
               ELSE crcs_salaries.federalSalaryResourceCode  -- otherwise leave as is
               END
           ,
           crcs_salaries.federalBenefitsResourceCode = 
             CASE WHEN _new_vals.federalBenefits > 0  -- if federal benefits exists
               THEN
                 SUBSTRING( federalResourceNums, 1, 49 )  -- use relevant resource code
               ELSE crcs_salaries.federalBenefitsResourceCode  -- otherwise leave as is
               END
               

   FROM  [dbo].[CRCS_PRAC_SALARIES] crcs_salaries

   JOIN  crcs_salaries_full_joind_needs_updates  _new_vals
   
   ON 
         
             crcs_salaries.fiscalYearID  = _new_vals.fyear_id
         AND crcs_salaries.quarterNumber = _new_vals.quarternum
         AND crcs_salaries.pracID        = _new_vals.prac_id

         AND crcs_salaries.active = 1

         AND crcs_salaries.clientID = @clientID


  -- violating the DRY principle here;
  -- I wish I had been smart enough to figure out how these two queries would be different
  -- as I started writing them

  ; with paid_resource_totals_by_pracid_and_rsrc as
   (
       SELECT
          resourceNum , prac_id , @fyear_id fyear_id, @quarternum quarternum,
          SUM(Gross ) Gross , SUM( Total_Employer_Paid_Benefits_W_hw ) Total_Employer_Paid_Benefits_W_hw

          -- CASE WHEN resourceNum >= 3000 AND resourceNum < 5999 THEN 1 ELSE 0 END is_fed
       FROM @paidResources

       WHERE prac_id IS NOT NULL
         -- very important

       GROUP BY
         resourceNum , prac_id
   ),
   paid_resource_totals_by_pracid_w_is_fed as
   (
       SELECT
          prac_id , fyear_id , quarternum ,
          Gross , Total_Employer_Paid_Benefits_W_hw ,
          CASE WHEN resourceNum >= 3000 AND resourceNum < 5999 THEN 1 ELSE 0 END is_fed ,
          resourceNum
       FROM paid_resource_totals_by_pracid_and_rsrc
   ),
   paid_resource_totals_by_pracid_and_isfed as (
       SELECT
         b_p_i.prac_id , b_p_i.fyear_id, b_p_i.quarternum,
         SUM(b_p_i.Gross ) Gross , SUM( b_p_i.Total_Employer_Paid_Benefits_W_hw ) Total_Employer_Paid_Benefits_W_hw ,
         -- STRING_AGG( CAST( d.resourceNum as varchar(max) ) , ', ' )  resourceNums,
         resourceNums,
         b_p_i.is_fed
       FROM paid_resource_totals_by_pracid_w_is_fed b_p_i
       
         JOIN (
           SELECT
             prac_id , fyear_id , quarternum , is_fed,
             STRING_AGG( CAST( resourceNum as varchar(max) ) , ', ' )  resourceNums
             
             FROM paid_resource_totals_by_pracid_w_is_fed 

             GROUP BY prac_id , fyear_id , quarternum , is_fed
         ) d  ON
              d.prac_id        = b_p_i.prac_id
              AND d.fyear_id   = b_p_i.fyear_id
              AND d.quarternum = b_p_i.quarternum
              and d.is_fed     = b_p_i.is_fed

       
       GROUP BY
         b_p_i.prac_id , b_p_i.fyear_id , b_p_i.quarternum , b_p_i.is_fed
         ,
         resourceNums
   ),
   
   /*
   ,
   crcs_prac_ids_and_numbers as (
     SELECT
       p_p.PRACTITIONER_ID prac_id,
       p_p.clientEmployeeID
     FROM  [dbo].[CRCS_PRAC_SALARIES] crcs_salaries
     JOIN  dbo.PRACTITIONER_Practitioner p_p
       ON  crcs_salaries.clientID      = @clientID
       AND crcs_salaries.fiscalYearID  = @fyear_id
       AND crcs_salaries.quarterNumber = @quarternum
       AND p_p.PRACTITIONER_ID = p_p.PRACTITIONER_ID
   ),
   */
   
   -- this last CTE is really the only difference, between the two sets of CTEs
   crcs_salaries_full_joind_needs_inserts as (
     SELECT
       federalSalary   = is_fed.Gross ,
       federalBenefits = is_fed.Total_Employer_Paid_Benefits_W_hw ,
       salary          = is_notfed.Gross ,
       benefits        = is_notfed.Total_Employer_Paid_Benefits_W_hw ,

       
       federalSalaryResourceCode = 
             CASE WHEN is_fed.Gross > 0  -- if federal salary exists
               THEN
                 SUBSTRING( is_fed.resourceNums, 1, 49)  -- use relevant resource code
               ELSE NULL  -- crcs_salaries.federalSalaryResourceCode  -- otherwise leave as is
               END
       ,

       federalBenefitsResourceCode = 
             CASE WHEN is_fed.Total_Employer_Paid_Benefits_W_hw > 0  -- if federal benefits exists
               THEN
                 SUBSTRING( is_fed.resourceNums, 1, 49)  -- use relevant resource code
               ELSE NULL -- crcs_salaries.federalBenefitsResourceCode  -- otherwise leave as is
               END
       ,
       prac_id    = ISNULL( is_fed.prac_id,  is_notfed.prac_id )   ,
       fyear_id   = ISNULL( is_fed.fyear_id, is_notfed.fyear_id ) ,
       quarternum = ISNULL( is_fed.quarternum, is_notfed.quarternum ) 

     FROM  paid_resource_totals_by_pracid_and_isfed is_fed

     FULL JOIN  paid_resource_totals_by_pracid_and_isfed is_notfed
       ON  is_fed.prac_id = is_notfed.prac_id
         AND is_fed.is_fed = 1 AND is_notfed.is_fed = 0

     -- this LEFT JOIN and WHERE clause appears to be the only difference,
     -- at first glance, between the two sets of CTEs
     LEFT JOIN 
       (
         select pracID, fiscalYearID, quarterNumber, MAX(id) id
         FROM
         [dbo].[CRCS_PRAC_SALARIES]
         WHERE "active" = 1
         GROUP BY pracID, fiscalYearID, quarterNumber
       ) crcs_salaries_top_1_active

       ON  crcs_salaries_top_1_active.pracID = ISNULL( is_fed.prac_id, is_notfed.prac_id )

         AND crcs_salaries_top_1_active.fiscalYearID  = ISNULL (is_fed.fyear_id, is_notfed.fyear_id)
         AND crcs_salaries_top_1_active.quarterNumber = ISNULL (is_fed.quarternum, is_notfed.quarternum)
         
     WHERE crcs_salaries_top_1_active.id IS NULL  -- OR   crcs_salaries.active = 0

           AND

           ISNULL(is_fed.is_fed, 1) = 1 AND ISNULL(is_notfed.is_fed, 0) = 0
   )
   
   -- UPDATE  crcs_salaries
   INSERT INTO [dbo].[CRCS_PRAC_SALARIES]
   (federalSalary , federalBenefits , salary , benefits , federalSalaryResourceCode , federalBenefitsResourceCode ,
    pracID, fiscalYearID, quarterNumber, clientID)

   SELECT
    federalSalary , federalBenefits , salary , benefits ,

     federalSalaryResourceCode , federalBenefitsResourceCode ,

    prac_id, fyear_id, quarternum, @clientID

  FROM crcs_salaries_full_joind_needs_inserts


  commit transaction  
  --rollback TRANSACTION
 
  set @tranOpen = 0
  set @recordID = @structuredDataImportID

 
END


 
/*############################################################################
 *# Generate JSON for reporting/feedback purposes and exit
 *############################################################################*/
 
set @jsonData = convert(varchar(max),(select * from @paidResources FOR JSON AUTO))
RETURN(0)
 
END TRY
BEGIN CATCH
 
 
  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/
 
  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
        set @tranOpen = 0
  end
 
 
  -- Error or raise error with severity 11 to 19 will be caught here
 
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()
 
   if (@ErrorSeverity > 11)
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'
 
  -- Reraise the error so it returns back to the server
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
 
 
END CATCH
END
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CRCS_CALC_SALARY_BREAKDOWNS_FROM_PAYROLL_BULK_IMPORT] TO [webuser]
GO