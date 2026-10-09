using System;

/// <summary>
/// Exit codes for end points
/// </summary>

[Flags]
public enum ExitCodes : int
{
    Success                          = 0
  , NoArgumentsProvided              = 1 << 0
  , NoFileNameProvided               = 1 << 1
  , FileDoesNotExist                 = 1 << 2
  , EmptyZip                         = 1 << 3
  , UnzipFailed                      = 1 << 4
  , WrapFileFailed                   = 1 << 5
  , GettingParsingInfoFailed         = 1 << 6
  , GeneratingCSVImportFailed        = 1 << 7
  , ExtractingSummaryDataFailed      = 1 << 8
  , ExtractingDetailDataFailed       = 1 << 9
  , Generating835ContentReportFailed = 1 << 10  
  , GeneratingXMLImportFailed        = 1 << 11
  , GenerateCleanUnwrappedFailed     = 1 << 12
  , UnknownError                     = 1 << 13
}

