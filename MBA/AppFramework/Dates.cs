using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace MBA
{

  /// <summary>
  /// A collection of utilities used to work with <see cref="System.DateTime"/> values
  /// </summary>

  public class Dates
  {

    #region LocalClasses

    /*============================================================
     * Local Classes
     *============================================================*/

    /// <summary>
    /// Date range.
    /// </summary>

    public class DateRange: IEquatable<DateRange>
    {

      public DateRange()
      {
      }

      protected DateTime       _referenceDate;
      protected DateTime       _startDate;
      protected DateTime       _endDate;
      
      public DateTime       ReferenceDate { get { return _referenceDate;} set { _referenceDate = value;} }
      public DateTime       StartDate     { get { return _startDate;}     set { _startDate     = value;} }
      public DateTime       EndDate       { get { return _endDate;}       set { _endDate       = value;} }
            
      public bool Equals (DateRange obj)
      {
        return ((this.StartDate == obj.StartDate) && (this.EndDate == obj.EndDate));
      }

      public override string ToString ()
      {
        string sd = StartDate.ToShortDateString();
        string ed = EndDate.ToShortDateString();
        return string.Format ("{0} - {1}", sd, ed);
      }
      
      public static List<DateRange> AllDaysDateRanges (DateTime startDate, DateTime endDate)
      {

        /*----------------------------
         * Create new list of date
         * ranges
         *----------------------------*/
        
        List<DateRange> drl = new List<DateRange>();                                  

        /*----------------------------
         * Initialize our date times
         *----------------------------*/
        
        DateTime        sdt  = Dates.StartDate(startDate); /* Calculate proper start date time*/
        DateTime        edt  = Dates.EndDate(endDate);     /* Calculate proper end date time*/
        DateTime        idt  = sdt;                        /* Set index date time to start date time */

        /*----------------------------
         * If the start date is after
         * the end date, get out
         *----------------------------*/
        
        if (sdt > edt) return drl;
        
               
        /*----------------------------
         * Generate list
         *----------------------------*/
        
        while (idt <= edt)
        {
          DateRange dr = new DateRange();        /* Create new date range (dr) */                      
          dr.StartDate = Dates.StartDate(idt);   /* Add start date time to dr */
          dr.EndDate   = Dates.EndDate(idt);     /* Add end date time to dr */       
          drl.Add(dr);                           /* Add dr to list*/
          idt = idt.AddDays(1);                  /* Advance idt by one day */
        }        
        
        /*----------------------------
         * Return list
         *----------------------------*/

        return drl;          
      }
    }

    #endregion

    #region Constants

    /*============================================================
     * Constants
     *============================================================*/

    /*----------------------------
     * Calendar Year Defaults
     *----------------------------*/

    protected const int CY_START_MONTH = 1;  // Start month
    protected const int CY_START_DAY   = 1;  // Start day
    protected const int CY_END_MONTH   = 12; // End month
    protected const int CY_END_DAY     = 31; // End day

    /*----------------------------
     * Fiscal Year Defaults
     *----------------------------*/

    protected const int FY_START_MONTH = 7;  // Start month
    protected const int FY_START_DAY   = 1;  // Start day
    protected const int FY_END_MONTH   = 6;  // End month
    protected const int FY_END_DAY     = 30; // End day

    #endregion

    #region Constructors

    /*============================================================
     * Constructors
     *============================================================*/

    static Dates()
    {
    }

    #endregion

    #region Utility

    /*============================================================
     * Utility
     *============================================================*/

    /// <summary>
    /// Returns <see cref="DateStart"/> of <paramref name="value"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>

    public static DateTime DateOnly(DateTime value)
    {
      DateTime d = value.Date;
      return StartDate(d);
    }

    /// <summary>
    /// Returns the difference in months
    /// between <paramref name="date1"/> and <paramref name="date2"/>
    /// </summary>
    /// <remarks>
    /// Courtesey of Adam Ralph
    /// http://stackoverflow.com/a/4639057
    /// </remarks>
    /// <returns>
    /// <see cref="System.Int32"/>
    /// </returns>
    /// <param name='date1'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='date2'>
    /// <see cref="System.DateTime"/>
    /// </param>

    public static int DateDiffInMonths (DateTime date1, DateTime date2)
    {
      int numMonths = ((date1.Year - date2.Year) * 12) + date1.Month - date2.Month;
      return numMonths;
    }

    /// <summary>
    /// Determine if <paramref name="value"/>
    /// is between <see cref="DateStart"/> of <paramref name="date1"/>
    /// and <see cref="DateEnd"/> of <paramref name="date2"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.Bool"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='date1'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='date2'>
    /// <see cref="System.DateTime"/>
    /// </param>

    public static bool DateIsBetween (DateTime value, DateTime date1, DateTime date2)
    {
      long vticks  = DateOnly(value).Ticks;
      long d1ticks = StartDate(date1).Ticks;
      long d2ticks = EndDate(date2).Ticks;

      if ((vticks >= d1ticks) && (vticks <= d2ticks))
        return true;
      else
        return false;
    }

    /// <summary>
    /// Returns <paramref name="value"/> with the earliest possible time component
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartDate (DateTime value)
    {
      int yy = value.Year;
      int mm = value.Month;
      int dd = value.Day;
      int h  = 0;
      int m  = 0;
      int s  = 0;
      int ms = 0;

      return new DateTime(yy,mm,dd,h,m,s,ms);
    }

    /// <summary>
    /// Returns <paramref name="value"/> with the latest possible time component
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndDate (DateTime value)
    {
      int yy = value.Year;
      int mm = value.Month;
      int dd = value.Day;
      int h  = 23;
      int m  = 59;
      int s  = 59;
      int ms = 999;

      return new DateTime(yy,mm,dd,h,m,s,ms);
    }

    public static bool ComputeFiscalYear (DateTime reference,
                                          out DateTime startDate,
                                          out DateTime endDate)
    {
      return ComputeFiscalYear(FY_START_MONTH,
                               FY_START_DAY,
                               FY_END_MONTH,
                               FY_END_DAY,
                               reference,
                               out startDate,
                               out endDate);
    }

    /// <summary>
    /// Computes the fiscal year.
    /// </summary>
    /// <returns>
    /// The fiscal year.
    /// </returns>
    /// <param name='monthStart'>
    /// If set to <c>true</c> month start.
    /// </param>
    /// <param name='dayStart'>
    /// If set to <c>true</c> day start.
    /// </param>
    /// <param name='monthEnd'>
    /// If set to <c>true</c> month end.
    /// </param>
    /// <param name='dayEnd'>
    /// If set to <c>true</c> day end.
    /// </param>
    /// <param name='reference'>
    /// If set to <c>true</c> reference.
    /// </param>
    /// <param name='startDate'>
    /// If set to <c>true</c> start date.
    /// </param>
    /// <param name='endDate'>
    /// If set to <c>true</c> end date.
    /// </param>

    public static bool ComputeFiscalYear (int monthStart,
                                          int dayStart,
                                          int monthEnd,
                                          int dayEnd,
                                          DateTime reference,
                                          out DateTime startDate,
                                          out DateTime endDate)
    {

      int refYear   = reference.Year;
      int refMonth  = reference.Month;
      int yearStart = refYear;
      int yearEnd   = refYear;
      
      startDate = DateTime.Now;
      endDate   = DateTime.Now;
      
      string sDate = "";
      string eDate = "";

      /*----------------------------
       * Exit if fy start and end
       * values are invalid
       *----------------------------*/

      if ((monthStart < 1) || (monthStart > 12))   return false;
      if ((monthEnd   < 1) || (monthEnd   > 12))   return false;
      if ((dayStart   < 1) || (dayStart   > 31))   return false;
      if ((dayEnd     < 1) || (dayEnd     > 31))   return false;

      /*----------------------------
       * Compute fiscal year
       *----------------------------*/

      if ((refMonth >= monthStart) && (refMonth <= 12))
      {

        /*----------------------------
         * Fiscal year is between two
         * years and reference year is
         * in the 1st of those two years
         *----------------------------*/

         yearStart = refYear;
         yearEnd   = refYear + 1;
       }

       else if ((refMonth >= 1) && (refMonth <= monthEnd))
       {

         /*----------------------------
          * Fiscal year is between two
          * years and reference year is
          * in the 2nd of those two years
          *----------------------------*/

         yearStart = refYear - 1;
         yearEnd   = refYear;
       }

       else
       {

         /*----------------------------
          * Fiscal year is a calendar
          * year
          *----------------------------*/

         yearStart = refYear;
         yearEnd   = refYear;
       }

       /*----------------------------
        * Create start and end date
        * strings
        *----------------------------*/

       sDate = monthStart.ToString() + "/" + dayStart.ToString() + "/" + yearStart.ToString();
       eDate = monthEnd.ToString()   + "/" + dayEnd.ToString()   + "/" + yearEnd.ToString();

       /*----------------------------
        * Convert them to dates
        *----------------------------*/

       bool date1ok = DateTime.TryParse(sDate, out startDate);
       bool date2ok = DateTime.TryParse(eDate, out endDate);

       /*----------------------------
        * Set start date and end date
        * times
        *----------------------------*/

       startDate = Dates.StartDate (startDate);
       endDate   = Dates.EndDate   (endDate);

       /*----------------------------
        * Make sure the difference
        * is 12 months
        *----------------------------*/

      bool datediffok = true;

      if (DateDiffInMonths(startDate,endDate) != 12)
        datediffok = false;

      /*----------------------------
       * Return state of calculation
       *----------------------------*/

      bool state = date1ok && date2ok && datediffok;

      return state;

    }

    #endregion

    #region Display

    /*============================================================
     * Display
     *============================================================*/

    /// <summary>
    /// Compares <paramref name="value"/> to <paramref name="reference"/> and
    /// generates a friendly English comparison ("5 days ago", "5 days from now")
    /// </summary>
    /// <remarks>
    /// Based on http://stackoverflow.com/a/628203
    /// </remarks>
    /// <returns>
    /// <see cref="System.String"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='reference'></param>
    /// <see cref="System.DateTime"/>
    /// <param name='approximate'>
    /// <see cref="System.Bool"/>
    /// </param>

    public static string ToFriendlyCompareString(DateTime reference, DateTime value, bool approximate)
    {

      StringBuilder sb = new StringBuilder();

      string suffix = (value > reference) ? " from now" : " ago";

      TimeSpan timeSpan = new TimeSpan(Math.Abs(reference.Subtract(value).Ticks));

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
    /// Returns <see cref="System.String"/> containing
    /// <see cref="System.DateTime.ToLongDateString"/> and
    /// <see cref="System.DateTime.ToLongTimeString"/>
    /// representations of <paramref name="value"/>
    /// </summary>
    /// <param name='value'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <returns>
    /// <see cref="System.String"/>
    /// </returns>

    public static string ToLongDateAndTimeString(DateTime value)
    {
      StringBuilder sb = new StringBuilder();
      sb.Append(value.ToLongDateString());
      sb.Append(" ");
      sb.Append(value.ToLongTimeString());
      string s = sb.ToString();
      return s;
    }

    #endregion

    #region Day

    /*============================================================
     * Day
     *============================================================*/

    /// <summary>
    /// Returns <see cref="DateStart"/> of <see cref="System.DateTime.Today"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime StartOfDay ()
    {
      return StartOfDay(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="DateStart"/> of <paramref name="reference"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartOfDay(DateTime reference)
    {
      return StartDate (reference);
    }

    /// <summary>
    /// Returns <see cref="DateEnd"/> of <see cref="System.DateTime.Today"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime EndOfDay()
    {
      return EndOfDay (DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="DateEnd"/> of <paramref name="reference"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndOfDay(DateTime reference)
    {
      return EndDate (reference);
    }

    public static DateRange Day (DateTime reference)
    {
      DateRange r = new DateRange();
      r.ReferenceDate = reference;
      r.StartDate     = StartOfDay(reference);
      r.EndDate       = EndOfDay(reference);
      return r;
    }

    #endregion

    #region Week

    /*============================================================
     * Week
     *============================================================*/

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the week that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime StartOfWeek ()
    {
      return StartOfWeek(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the week that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartOfWeek (DateTime reference)
    {
      DateTime d = reference;
      DateTime ds = d.AddDays(-1 * (int)(reference.DayOfWeek));
      return StartDate(ds);
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the week that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime EndOfWeek()
    {
      return EndOfWeek(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the week that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndOfWeek(DateTime reference)
    {
      DateTime sd = StartOfWeek(reference);
      DateTime d = sd.AddDays((int)(DayOfWeek.Saturday));
      return EndDate(d);
    }

    public static DateRange Week (DateTime reference)
    {
      DateRange r = new DateRange();

      r.ReferenceDate = reference;
      r.StartDate     = StartOfWeek(reference);
      r.EndDate       = EndOfWeek(reference);

      return r;
    }

    #endregion

    #region Month

    /*============================================================
     * Month
     *============================================================*/

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the month that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime StartOfMonth()
    {
      return StartOfMonth(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the month that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartOfMonth(DateTime reference)
    {
      int yy = reference.Year;
      int mm = reference.Month;
      int dd = 1;
      DateTime d = new DateTime(yy,mm,dd);
      return StartDate(d);
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the month that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime EndOfMonth()
    {
      return EndOfMonth(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the month that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndOfMonth(DateTime reference)
    {
      DateTime ds = StartOfMonth(reference).AddMonths(1).AddDays(-1);
      return EndDate(ds);
    }

    public static DateRange Month (DateTime reference)
    {
      DateRange r = new DateRange();

      r.ReferenceDate = reference;
      r.StartDate     = StartOfMonth(reference);
      r.EndDate       = EndOfMonth(reference);

      return r;
    }

    #endregion

    #region Quarter

    /*============================================================
     * Quarter
     *============================================================*/

    /// <summary>
    /// Returns the quarter number that <paramref name="reference"/> is part of
    /// </summary>
    /// <remarks>
    /// Based on http://stackoverflow.com/a/1492129
    /// </remarks>
    /// <returns>
    /// <see cref="System.Int32"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static int GetQuarterNumber (DateTime reference)
    {
      int qn = (reference.Month-1)/3+1;
      return qn;
    }

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the quarter that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <remarks>
    /// Based on http://stackoverflow.com/a/1492129
    /// </remarks>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartOfQuarter(DateTime reference)
    {
      int qn = GetQuarterNumber(reference);
      int mn = (qn-1)*3+1;
      DateTime ds = new DateTime(reference.Year,mn,1);
      return StartDate(ds);
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the quarter that
    /// <paramref name="reference"/> is part of
    /// </summary>
    /// <remarks>
    /// Based on http://stackoverflow.com/a/1492129
    /// </remarks>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndOfQuarter (DateTime reference)
    {
      DateTime sq = StartOfQuarter(reference);
      DateTime ds  = sq.AddMonths(3).AddDays(-1);
      return EndDate(ds);
    }

    public static DateRange Quarter (DateTime reference)
    {
      DateRange r = new DateRange();

      r.ReferenceDate = reference;
      r.StartDate     = StartOfQuarter(reference);
      r.EndDate       = EndOfQuarter(reference);

      return r;
    }

    #endregion

    #region CalendarYear

    /*============================================================
     * Calendar Year
     *============================================================*/

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the calendar year that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime StartOfCalYear()
    {
      return StartOfCalYear(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="StartDate"/> of the first day of the calendar year
    /// that <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime StartOfCalYear(DateTime reference)
    {
      int yy = reference.Year;
      DateTime d = new DateTime(yy,CY_START_MONTH,CY_START_DAY);
      return StartDate(d);
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the calendar year that
    /// <see cref="System.DateTime.Today"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>

    public static DateTime EndOfCalYear()
    {
      return EndOfCalYear(DateOnly(DateTime.Today));
    }

    /// <summary>
    /// Returns <see cref="EndDate"/> of the last day of the calendar year
    /// that <paramref name="reference"/> is part of
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// Reference <see cref="System.DateTime"/>
    /// </param>

    public static DateTime EndOfCalYear(DateTime reference)
    {
      int yy = reference.Year;
      DateTime d = new DateTime(yy,CY_END_MONTH,CY_END_DAY);
      return EndDate (d);
    }

    public static DateRange CalYear (DateTime reference)
    {
      DateRange r = new DateRange();

      r.ReferenceDate = reference;
      r.StartDate     = StartOfCalYear(reference);
      r.EndDate       = EndOfCalYear(reference);

      return r;
    }

    #endregion

  }
}



