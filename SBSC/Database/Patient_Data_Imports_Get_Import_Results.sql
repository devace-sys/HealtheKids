USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Get_Import_Results') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Get_Import_Results
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_Get_Import_Results] (
    @userID               BIGINT
  , @userGroup            INT
  , @userRank             INT
  , @clientID             bigint
  , @recID                bigint
  , @pcalStaff            bit
)

RETURNS TABLE

 /***************************************************************************
  * Patient_Data_Imports_Get_Import_Results */
 /**
  * Returns
  *
  * @return table
  ***************************************************************************/

AS RETURN

select top 1
    pdivc.*
  , sdi.importDataJSON
  , pdi.preImportAdditionalBadRowsJSONData
  , pdi.manageSitesJSONData
  , pdi.importResultsJSON
  
  , preImportExpectionRptHTML = dbo.Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html (
        pdi.preImportNumRowsSkipped
      , pdi.preImportNumColsSkipped
      , pdi.preImportNumAdditionalRowsSkipped
      , pdi.hasPreImportRowExceptions    
      , pdi.hasAdditionalBadRowExceptions
      , sdi.importDataJSON
	  , pdi.preImportAdditionalBadRowsJSONData)

  , manageSitesResultsRptHTML = dbo.Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html (pdi.manageSitesJSONData)
  , importResultsRptHTML      = dbo.Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html (pdi.importResultsJSON, @pcalStaff, sdi.id)

from dbo.Patient_Data_Imports_View_Core (@userID, @userGroup, @userRank, @clientID, null, null, null, @recID) as pdivc
join dbo.Patient_Data_Imports    as pdi on pdi.id = pdivc.id
join dbo.Structured_Data_Imports as sdi on sdi.id = pdivc.structuredDataImportID

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[Patient_Data_Imports_Get_Import_Results] TO [webuser]
GO
