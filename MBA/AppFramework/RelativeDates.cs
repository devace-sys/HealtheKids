using System;
using System.Text;
using System.Text.RegularExpressions;
using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;

namespace MBA
{

  /// <summary>
  /// A collection of utilities used to work with relative dates
  /// </summary>

  public sealed class RelativeDates:Dates
  {

    #region LocalClasses

    /*============================================================
     * Local Classes
     *============================================================*/

    /// <summary>
    /// Relative date range.
    /// </summary>

    public sealed class RelativeDateRange:DateRange, IEquatable<RelativeDateRange>
    {
      public RelativeDateRange()
      {
        //_useAllDates = false;
      }

      //private  bool   _useAllDates;
      //public   bool    UseAllDates   { get { return _useAllDates;}   set { _useAllDates   = value;} }

      private DateTime _relativeReferenceDate;      
      public DateTime  RelativeReferenceDate { get { return _relativeReferenceDate; } set { _relativeReferenceDate = value; } }

      public bool Equals (RelativeDateRange obj)
      {
        return ((this.StartDate == obj.StartDate) && (this.EndDate == obj.EndDate));
      }

      public override string ToString ()
      {
        string sd = StartDate.ToShortDateString();
        string ed = EndDate.ToShortDateString();
        return string.Format ("{0} - {1}", sd, ed);
      }
    }

    #endregion

    #region Constants

    /*============================================================
     * Constants
     *============================================================*/

    /*----------------------------
     * Relative date range patterns
     * (populated with values from
     *  enums in the constructor)
     *----------------------------*/

    private static readonly string _rdrPositions;       // Relative positions
    private static readonly string _rdrSpans;           // Relative spans
    private static readonly string _rdrSpanMods;        // Relative span modifications
    private static readonly string _rdrWhiteSpace;      // White space
    private static readonly string _rdrValidPositions;  // Valid positions
    private static readonly string _rdrValidSpans;      // Valid spans
    private static readonly string _rdrValidSpanMods;   // Valid span mods
    private static readonly string _rdrValid;           // Valid relative date


    private const string _msg_inv_dr_string = "Invalid relative date range string";
    private const string _msg_inv_dr        = "Invalid relative date range";

    #endregion

    #region Constructors

    /*============================================================
     * Constructors
     *============================================================*/

    static RelativeDates ()
    {
      /*----------------------------
       * Parse enums and create
       * validation patterns
       *----------------------------*/

       _rdrPositions      = Enums.EnumDescriptionOrNamesToString<RelativeDates.Position>("|");
       _rdrSpans          = Enums.EnumDescriptionOrNamesToString<RelativeDates.Unit>("|");
       _rdrSpanMods       = Enums.EnumDescriptionOrNamesToString<RelativeDates.Option>("|");

       _rdrWhiteSpace     = @"\s{0,}";

       _rdrValidPositions = @"^(" + _rdrPositions + @"|^)";
       _rdrValidSpans     = @"("  + _rdrSpans + @")";
       _rdrValidSpanMods  = @"("  + _rdrSpanMods + @"|$)";

       _rdrValid          = @"^"  + _rdrValidPositions
                                  + _rdrWhiteSpace
                                  + _rdrValidSpans
                                  + _rdrWhiteSpace
                                  + _rdrValidSpanMods
                                  + @"$";

    }

    #endregion

    #region Enums

    /*============================================================
     * Enums
     *============================================================*/

    /// <summary>
    /// Position represents a date with respect to a reference date
    /// date.
    /// </summary>

    public enum Position
    {
      [Description("")]
      none    = 0,
      last    = 1,
      @this   = 2,
      next    = 3
    }

    /// <summary>
    /// Unit represents the amount of time with respect to a reference date.
    /// </summary>

    public enum Unit
    {
      day          = 1,
      week         = 2,
      month        = 3,
      quarter      = 4,
      year         = 5,
      [Description("calendar year")]
      calendaryear = 6,
      [Description("fiscal year")]
      fiscalyear   = 7,
    }

    /// <summary>
    /// Calculation options.
    /// </summary>
    /// <remarks>
    /// Values are in powers of 2 so bitwise operations can be used.
    /// </remarks>

    [Flags]

    public enum Option : int
    {
      [Description("")]
      none     =  1,
      [Description("to date")]
      todate   = 2,
      [Description("to report")]      
      toreport = 4
    }

    #endregion

    #region Utilities

    /*============================================================
     * Utilities
     *============================================================*/

    private static DateTime ComputeReportingPeriodEndDate (DateTime reference,
                                                           Position position,
                                                           Unit span)
    {
      
      DateTime d = reference;
      return d;
    
    }
    
    private static DateTime ComputeRelativeReferenceDate(DateTime reference,
                                                         Position position,
                                                         Unit span)
    {

      DateTime d = reference;

     /*----------------------------
      * Determine amount of positive
      * or negative units to shift
      * reference
      *----------------------------*/

      int numof = 0;

      if (position == Position.last)  numof = -1;
      if (position == Position.@this) numof =  0;
      if (position == Position.next)  numof =  1;

     /*----------------------------
      * If there is a positive or
      * negative shift.  Add the
      * appropriate amount of
      * units
      *----------------------------*/

      if (numof != 0)
      {

        if (span == Unit.day)          return d.AddDays   (numof);
        if (span == Unit.month)        return d.AddMonths (numof);
        if (span == Unit.year)         return d.AddYears  (numof);
        if (span == Unit.calendaryear) return d.AddYears  (numof);
        if (span == Unit.fiscalyear)   return d.AddYears  (numof);

        if (span == Unit.quarter)
        {
          numof = numof * 3;
          return d.AddMonths(numof);
        }

        if (span == Unit.week)
        {
          numof = numof * 7;
          return d.AddDays (numof);
        }

      }

      return d;
    }


    private static bool ValidRelativeDateRangeString (string range)
    {
      return Regex.IsMatch (range, _rdrValid);
    }

    private static bool SplitRelativeDateRangeString (string range,
                                                      out string position,
                                                      out string span,
                                                      out string spanmod)
    {

      bool res = false;

      /*----------------------------
       * Clean up range string
       *----------------------------*/

      range = range.Trim().ToLower();

      /*----------------------------
       * Set default values
       *----------------------------*/

      position = String.Empty;
      span     = String.Empty;
      spanmod  = String.Empty;

      /*----------------------------
       * If the range string appears
       * to be valid extract the
       * various parts
       *----------------------------*/

      if (ValidRelativeDateRangeString(range))
      {
        position = Regex.Match(range, _rdrValidPositions).Value;
        span     = Regex.Match(range, _rdrSpans).Value;
        spanmod  = Regex.Match(range, _rdrSpanMods).Value;
        res      = true;
      }

      /*----------------------------
       * Otherwise let the caller
       * know the string was invalid
       *----------------------------*/

      else
      {
        position = String.Empty;
        span     = String.Empty;
        spanmod  = String.Empty;
        res      = false;
      }

      return res;
    }

    private static bool DecodeRelativeDateRangeStringParts (string posStr,
                                                            string spanStr,
                                                            string spanModStr,
                                                            out Position position,
                                                            out Unit span,
                                                            out Option spanMod)
    {

      /*----------------------------
       * Set defaults
       *----------------------------*/

      position = Position.@this;
      span     = Unit.day;
      spanMod  = Option.none;

      /*----------------------------
       * Decode position or use
       * default
       *----------------------------*/

      if (posStr != String.Empty)
      {
        posStr   = posStr.Replace(" ","");
        position = (Position) Enum.Parse (typeof(Position), posStr);
      }

      /*----------------------------
       * Decode span or use default
       *----------------------------*/

      if (spanStr != String.Empty)
      {
        spanStr = spanStr.Replace(" ","");
        span    = (Unit) Enum.Parse (typeof(Unit), spanStr);
      }

      /*----------------------------
       * Decode span modifier or use
       * default
       *----------------------------*/

      if (spanModStr != String.Empty)
      {
        spanModStr = spanModStr.Replace(" ","");
        spanMod    = (Option) Enum.Parse (typeof(Option), spanModStr);
      }

      return true;
    }

    #endregion

    #region ComputeDateRanges

   /*============================================================
    * Compute Date Ranges
    *============================================================*/

    /// <summary>
    /// Computes a <see cref="RelativeDateRange"/>
    /// from <paramref name="reference"/> and <paramref name="range"/>
    /// </summary>
    /// <returns>
    /// <see cref="System.DateTime"/>
    /// </returns>
    /// <param name='reference'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='range'>
    /// <see cref="System.String"/>
    /// </param>
    /// <summary>
    /// Computes the relative date range.
    /// </summary>
    /// <returns>
    /// The relative date range.
    /// </returns>
    /// <param name='reference'>
    /// Reference.
    /// </param>
    /// <param name='range'>
    /// Range.
    /// </param>
    /// <exception cref='ArgumentException'>
    /// Is thrown when <paramref name="range"/> is invalid
    /// </exception>

    public static RelativeDateRange ComputeRelativeDateRange (DateTime reference, string range)
    {
      RelativeDateRange dr = new RelativeDateRange();
      
      if (Util.IsNullOrEmpty(range)) 
      return dr;
      
     /*----------------------------
      * Range string parts
      *----------------------------*/

      string posStr;
      string spanStr;
      string spanModStr;

     /*----------------------------
      * Range enums
      *----------------------------*/

      Position position;
      Unit     span;
      Option  spanMod;

     /*----------------------------
      * Split the range string
      * Decode it
      * Compute relative date range
      *----------------------------*/

       if (SplitRelativeDateRangeString (range, out posStr, out spanStr, out spanModStr))

         /*----------------------------
          * Decode it
          *----------------------------*/

         if (DecodeRelativeDateRangeStringParts(posStr,spanStr,spanModStr,out position, out span, out spanMod))

           /*----------------------------
            * Compute relative date range
            *----------------------------*/

           dr = ComputeRelativeDateRange(reference, position, span, spanMod);

         else

           throw new ArgumentException(_msg_inv_dr_string);

       else

         throw new ArgumentException(_msg_inv_dr);

       return dr;
    }

    /// <summary>
    /// Computes a <see cref="RelativeDateRange"/>
    /// from <paramref name="reference"/>, <paramref name="position"/>, <paramref name="span"/>
    /// and <paramref name="spanmod"/>
    /// </summary>
    /// <returns>
    /// <see cref="RelativeDateRange"/>
    /// </returns>
    /// <param name='reference'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='position'>
    /// <see cref="Position"/>
    /// </param>
    /// <param name='span'>
    /// <see cref="Unit"/>
    /// </param>
    /// <param name='spanmod'>
    /// <see cref="Option"/>
    /// </param>
    /// <exception cref='ArgumentException'>
    /// Is thrown when any of the parameters are invalid
    /// </exception>

    public static RelativeDateRange ComputeRelativeDateRange (DateTime reference,
                                                              Position position,
                                                              Unit span,
                                                              Option spanmod)
    {
      return ComputeRelativeDateRange(reference,
                                      position,
                                      span,
                                      spanmod,
                                      FY_START_MONTH,
                                      FY_START_DAY,
                                      FY_END_MONTH,
                                      FY_END_DAY);
    }

    /// <summary>
    /// Computes a <see cref="RelativeDateRange"/>
    /// from <paramref name="reference"/>, <paramref name="position"/>, <paramref name="span"/>
    /// and <paramref name="spanmod"/>.  Also allows you to change the fiscal year.
    /// </summary>
    /// <returns>
    /// <see cref="RelativeDateRange"/>
    /// </returns>
    /// <param name='reference'>
    /// <see cref="System.DateTime"/>
    /// </param>
    /// <param name='position'>
    /// <see cref="Position"/>
    /// </param>
    /// <param name='span'>
    /// <see cref="Unit"/>
    /// </param>
    /// <param name='spanmod'>
    /// <see cref="Option"/>
    /// </param>
    /// <param name='fyMonthStart'><See cref="System.int"/> Fiscal Year Month Start</param>
    /// <param name='fyDayStart'><See cref="System.int"/> Fiscal Year Day Start</param>
    /// <param name='fyMonthEnd'><See cref="System.int"/> Fiscal Year Month End</param>
    /// <param name='fyDayEnd'><See cref="System.int"/> Fiscal Year Day End</param>
    /// <exception cref='ArgumentException'>
    /// Is thrown when any of the parameters are invalid
    /// </exception>

    public static RelativeDateRange ComputeRelativeDateRange (DateTime reference,
                                                              Position position,
                                                              Unit span,
                                                              Option spanmod,
                                                              int fyMonthStart,
                                                              int fyDayStart,
                                                              int fyMonthEnd,
                                                              int fyDayEnd)
    {

      RelativeDateRange dr = new RelativeDateRange();

      
      /*----------------------------
       * Save reference date
       *----------------------------*/

      dr.ReferenceDate = reference;           
            
      /*----------------------------
       * Compute relative reference
       * date and save it
       *----------------------------*/

      dr.RelativeReferenceDate = ComputeRelativeReferenceDate (reference, position, span);

      /*----------------------------
       * Date range for today
       *----------------------------*/

      if (span == Unit.day)
      {
        dr.StartDate = Dates.StartOfDay (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfDay   (dr.RelativeReferenceDate);
      }

      /*----------------------------
       * Date range for week
       *----------------------------*/

      else if (span == Unit.week)
      {
        dr.StartDate = Dates.StartOfWeek (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfWeek   (dr.RelativeReferenceDate);
      }

      /*----------------------------
       * Date range for month
       *----------------------------*/

      else if (span == Unit.month)
      {
        dr.StartDate = Dates.StartOfMonth (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfMonth   (dr.RelativeReferenceDate);
      }

      /*----------------------------
       * Date range for quarter
       *----------------------------*/

      else if (span == Unit.quarter)
      {
        dr.StartDate = Dates.StartOfQuarter (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfQuarter   (dr.RelativeReferenceDate);
      }

      /*----------------------------
       * Date range for calendar year
       *----------------------------*/

      else if (span == Unit.year)
      {
        dr.StartDate = Dates.StartOfCalYear (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfCalYear   (dr.RelativeReferenceDate);
      }
      else if (span == Unit.calendaryear)
      {
        dr.StartDate = Dates.StartOfCalYear (dr.RelativeReferenceDate);
        dr.EndDate   = Dates.EndOfCalYear   (dr.RelativeReferenceDate);
      }

      /*----------------------------
       * Date range for fiscal year
       *----------------------------*/

      else if (span == Unit.fiscalyear)
      {
                            
        DateTime startDate = new DateTime();
        DateTime endDate   = new DateTime();

        ComputeFiscalYear(fyMonthStart,
                          fyDayStart,
                          fyMonthEnd,
                          fyDayEnd,
                          dr.RelativeReferenceDate,
                          out startDate,
                          out endDate);

         dr.StartDate = startDate;
         dr.EndDate   = endDate;
       }

      /*----------------------------
       * Unknown
       *----------------------------*/

      else
      {
        throw new ArgumentException(_msg_inv_dr);
      }
     
      /*----------------------------
       * If span to date is specified
       * and it is a valid option
       * (only works with this, and
       * last) then we want to 
       * substitute the reference 
       * date for the end date we
       * calculated
       *----------------------------*/
      
      if (spanmod == Option.todate)
      {  
        if (position != Position.next)
          if (DateIsBetween(dr.ReferenceDate,dr.StartDate,dr.ReferenceDate))
            dr.EndDate = EndDate(dr.ReferenceDate);
      }
      
      /*----------------------------
       * If span to report is 
       * specified and it is a valid
       * option (only works with
       * fiscal years and this)
       *----------------------------*/
      
      if    ((spanmod == Option.toreport) 
         && (span     == Unit.fiscalyear) 
         && (position == Position.@this))
      {        
        
        /*----------------------------
         * Determine if the date is the
         * start of a new fiscal year
         * or if it is in the first
         * month of a new fiscal year
         *----------------------------*/   
      
        bool isStartOfNewFY   = false;
        bool isFirstMonthOfFY = false;
            
        int m = dr.RelativeReferenceDate.Month;
        int d = dr.RelativeReferenceDate.Day;
            
        if (m == fyMonthStart)
        {      
          isFirstMonthOfFY = true;
              
          if (d == fyDayStart)
            isStartOfNewFY = true;  
        }
             
        /*----------------------------
         * New start and end dates
         *----------------------------*/   
            
        DateTime sDate = dr.StartDate;
        DateTime eDate = dr.EndDate;
          
        /*----------------------------
         * If the date is :
         *
         * - NOT The first day of the 
         *   new fiscal year
         * - NOT in the first month
         *   of the new fiscal year
         *   
         * Then we are want to use
         * the fiscal year we already
         * calculated BUT we substitute
         * last months end date for
         * the end date
         *----------------------------*/
            
        if ((!isStartOfNewFY) && (!isFirstMonthOfFY))
        {            
          sDate = dr.StartDate;
          eDate = EndDate(Dates.StartOfMonth(dr.ReferenceDate).AddDays(-1));
        }

        /*----------------------------
         * If the date is :
         *
         * - NOT The first day of the 
         *   new fiscal year
         * - BUT is in the first month
         *   of the new fiscal year
         * 
         * Then we are want to use
         * the fiscal year we already
         * calculated BUT we substitute
         * this months end date for
         * the end date
         *----------------------------*/
        
        if ((!isStartOfNewFY) && (isFirstMonthOfFY))
        {
          sDate = dr.StartDate;
          eDate = EndDate(EndOfMonth(dr.ReferenceDate));
        }        
        
        /*----------------------------
         * If the date is :
         *
         * - IS the first day of the 
         *   new fiscal year
         * 
         * Then we want to calculate
         * the dates for the fiscal
         * year that JUST ended and
         * use those for our start
         * and end dates
         *----------------------------*/
        
        if ((isStartOfNewFY) && (isFirstMonthOfFY))
        {          
          /* Reference date - 1 should put us in the last year */
              
          DateTime rDate = dr.RelativeReferenceDate.AddDays(-1);              
              
          ComputeFiscalYear(fyMonthStart,
                            fyDayStart,
                            fyMonthEnd,
                            fyDayEnd,
                            rDate,
                            out sDate,
                            out eDate);          
        } 
        
        /*----------------------------
         * Replace the dates
         *----------------------------*/ 
        
        dr.StartDate = sDate;
        dr.EndDate   = eDate;       
    
      }          
      
                                 
      /*----------------------------
       * All done, return daterange
       *----------------------------*/

      return dr;
    }

    #endregion

  }
}

