using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;

/***************************************************************************
 * UserDefinedFunctions */
/**
 * Various CLR user defined functions
 * Some code courtesey of
 * http://justgeeks.blogspot.com/2008/08/adding-regular-expressions-regex-to-sql.html
 ***************************************************************************/      	

namespace MBA
{
  public class UserDefinedFunctions
  {
    public static readonly RegexOptions Options = RegexOptions.IgnorePatternWhitespace | RegexOptions.Multiline;

    [SqlFunction]
    public static SqlBoolean RegexMatch(SqlChars input, SqlString pattern)
    {
        Regex regex = new Regex(pattern.Value, Options);
        return regex.IsMatch(new string(input.Value));
    }

    [SqlFunction]
    public static SqlString RegexReplace(SqlString expression, SqlString pattern, SqlString replace)
    {
      if (expression.IsNull || pattern.IsNull || replace.IsNull)
        return SqlString.Null;

      Regex r = new Regex(pattern.ToString());
      return new SqlString(r.Replace(expression.ToString(), replace.ToString()));
    }

    // returns the matching string. Results are separated by 3rd parameter
    [SqlFunction]
    public static SqlString RegexSelectAll(SqlChars input, SqlString pattern, SqlString matchDelimiter)
    {
      Regex regex = new Regex(pattern.Value, Options);
      Match results = regex.Match(new string(input.Value));

      StringBuilder sb = new StringBuilder();
      while (results.Success)
      {
        sb.Append(results.Value);
        results = results.NextMatch();

        // separate the results with newline|newline
        
        if (results.Success)
        {
          sb.Append(matchDelimiter.Value);
        }
      }

      return new SqlString(sb.ToString());

    }

    // returns the matching string
    // matchIndex is the zero-based index of the results. 0 for the 1st match, 1, for 2nd match, etc
    
    [SqlFunction]
    public static SqlString RegexSelectOne(SqlChars input, SqlString pattern, SqlInt32 matchIndex)
    {
      Regex regex = new Regex(pattern.Value, Options);
      Match results = regex.Match(new string(input.Value));

      string resultStr = "";
      int index = 0;

      while (results.Success)
      {
        if (index == matchIndex)
        {
          resultStr = results.Value.ToString();
        }

        results = results.NextMatch();
        index++;

      }

      return new SqlString(resultStr);

    }

  };     
}
