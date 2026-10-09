using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace MBA
{
  public class FormatStrings
  {
    public const string NUMBER_FINANCIAL             = "#,0.00;(#,#.00);0.00";
    public const string NUMBER_FINANCIAL_NO_ZERO     = "#,0;(#,#);0";
    public const string PERCENTAGE_FINANCIAL         = @"#,0\%;(#,#\%);0\%'";  // Note percentage is escaped to avoid calculation
    public const string DATETIME_MM_DD_YYYY          = "MM/dd/yyyy";
    public const string DATETIME_YYYY_MM_DD          = "yyyy/MM/dd";
    public const string DATETIME_YYYY_MM_DD_HTML_5   = "yyyy-MM-dd";
  }
}
