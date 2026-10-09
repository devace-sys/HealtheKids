using System;
using System.Text;

namespace MBA
{
  /// <summary>
  /// Date time extensions.
  /// </summary>

  public static class DateTimeExtensions
  {
    
    /// <summary>
    /// Creates a string containing YYYYMMDD
    /// </summary>
    /// <returns>
    /// The date formatted 
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>

    public static string ToYYYYMMDDString (this DateTime value)
    {
      return value.ToString("yyyyMMdd");       
    }

    /// <summary>
    /// Creates a string containing YYYYMMDDHHMMSS
    /// </summary>
    /// <returns>
    /// The date formatted 
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>

    public static string ToYYYYMMDDHHMMSSString (this DateTime value)
    {
       return value.ToString("yyyyMMddHHmmss");
    }
    
    /// <summary>
    /// Creates an HTML compliant string containing the date only
    /// </summary>
    /// <returns>
    /// The date formatted 
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>

    public static string ToHTML5DateString (this DateTime value)
    {
      return value.ToString("yyyy-MM-dd");       
    }
    
    /// <summary>
    /// Creates an HTML5 compliant string containing hours and minutes
    /// </summary>
    /// <returns>
    /// The date formatted 
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>
    /// hh:mm:ss
    public static string ToHTML5TimeString (this DateTime value)
    {
      return value.ToString("HH:mm");       
    }
    
    /// <summary>
    /// Creates an HTML5 compliant string containing the time only with seconds
    /// </summary>
    /// <returns>
    /// The date formatted 
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>
    /// hh:mm:ss
    public static string ToHTML5TimeStringWithSeconds (this DateTime value)
    {
      return value.ToString("HH:mm:ss");       
    }
        
    /// <summary>
    /// Creates a string containing both the long date string and long time string
    /// </summary>
    /// <returns>
    /// The long date and time string.
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>

    public static string ToLongDateAndTimeString(this DateTime value)
    {
      StringBuilder sb = new StringBuilder();
      sb.Append(value.ToLongDateString());
      sb.Append(" ");
      sb.Append(value.ToLongTimeString());
      string s = sb.ToString();
      return s;
    }

    /// <summary>
    /// Creates a string containing both the short date string and short time string
    /// </summary>
    /// <returns>
    /// The short date and time string.
    /// </returns>
    /// <param name='value'>
    /// Date time value
    /// </param>

    public static string ToShortDateAndTimeString(this DateTime value)
    {
      StringBuilder sb = new StringBuilder();
      sb.Append(value.ToShortDateString());
      sb.Append(" ");
      sb.Append(value.ToShortTimeString());
      string s = sb.ToString();
      return s;
    }

    /// <summary>
    /// Compares a supplied date to the current date and generates a friendly English
    /// comparison ("5 days ago", "5 days from now")
    /// Courtesey of http://stackoverflow.com/a/628203
    /// </summary>
    /// <param name="date">The date to convert</param>
    /// <param name="approximate">When off, calculate timespan down to the second.
    /// When on, approximate to the largest round unit of time.</param>
    /// <returns></returns>

    public static string ToRelativeDateString(this DateTime value)
    {
      return ToRelativeDateString(value, true);
    }

    public static string ToRelativeDateString(this DateTime value, bool approximate)
    {

      StringBuilder sb = new StringBuilder();

      string suffix = (value > DateTime.Now) ? " from now" : " ago";

      TimeSpan timeSpan = new TimeSpan(Math.Abs(DateTime.Now.Subtract(value).Ticks));

      if (timeSpan.Days > 0)
      {
        sb.AppendFormat("{0} {1}",
          timeSpan.Days, (timeSpan.Days > 1) ? "days" : "day");
        if (approximate) return sb.ToString() + suffix;
      }
      if (timeSpan.Hours > 0)
      {
        sb.AppendFormat("{0}{1} {2}", (sb.Length > 0) ? ", " : string.Empty,
          timeSpan.Hours, (timeSpan.Hours > 1) ? "hours" : "hour");
        if (approximate) return sb.ToString() + suffix;
      }
      if (timeSpan.Minutes > 0)
      {
        sb.AppendFormat("{0}{1} {2}", (sb.Length > 0) ? ", " : string.Empty,
          timeSpan.Minutes, (timeSpan.Minutes > 1) ? "minutes" : "minute");
        if (approximate) return sb.ToString() + suffix;
      }
      if (timeSpan.Seconds > 0)
      {
        sb.AppendFormat("{0}{1} {2}", (sb.Length > 0) ? ", " : string.Empty,
          timeSpan.Seconds, (timeSpan.Seconds > 1) ? "seconds" : "second");
        if (approximate) return sb.ToString() + suffix;
      }
      if (sb.Length == 0) return "right now";

      sb.Append(suffix);
      return sb.ToString();
    }
    
    
    /// <summary>
    /// Get start of week date
    /// Courtesey of https://stackoverflow.com/a/38064
    /// </summary>
    /// <param name="dt">The datetime object to extend</param>
    /// <param name="startOfWeek">Day of week to use for start</param>
    
    public static DateTime StartOfWeek (this DateTime dt, DayOfWeek startOfWeek)
    {
        int diff = dt.DayOfWeek - startOfWeek;
        if (diff < 0)
        {
            diff += 7;
        }
        return dt.AddDays(-1 * diff).Date;
    }
    
  }
}

