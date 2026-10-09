using System;
using System.Collections;
using System.Collections.Generic;
using MBA;
using NCrontab;
using System.Text.RegularExpressions;
using System.ComponentModel;

namespace MBA
{

  /// <summary>
  /// Methods used to calculate recurrance
  /// </summary>

  public class Schedule
  {


  // TODO: Finish comments
  
  //* * * * *
  //- - - - -
  //| | | | |
  //| | | | +----- day of week (0 - 6) (Sunday=0)
  //| | | +------- month (1 - 12)
  //| | +--------- day of month (1 - 31)
  //| +----------- hour (0 - 23)
  //+------------- min (0 - 59)

    // MINUTES HOURS DAYS MONTHS DAYS-OF-WEEK
    // http://code.google.com/p/ncrontab/
    // Time is set to last minute of day to allow longest possible run time

    #region Constructors

    /*============================================================
     * Constructors
     *============================================================*/

    public Schedule ()
    {
    }

    #endregion

    #region Constants

    /*============================================================
     * Constants
     *============================================================*/

    public const string CRONTAB_NONE                   = @"";
    public const string CRONTAB_DAILY                  = @"59 23 * * *";
    public const string CRONTAB_START_OF_EVERY_WEEK    = @"59 23 * * 0";        // 23:59 every Sunday
    public const string CRONTAB_START_OF_EVERY_MONTH   = @"59 23 1 * *";        // 23:59 the first day of every month
    public const string CRONTAB_START_OF_EVERY_QUARTER = @"59 23 1 1,4,7,10 *"; // 23:59 the first day of Jan, Apr, Jul, Oct
    public const string CRONTAB_START_OF_EVERY_YEAR    = @"59 23 1 1 *";        // 23:59 the first day of Jan

    public const string DATE_PART_NONE    = @"";
    public const string DATE_PART_DAY     = @"dd";
    public const string DATE_PART_WEEK    = @"wk";
    public const string DATE_PART_MONTH   = @"mm";
    public const string DATE_PART_QUARTER = @"qq";
    public const string DATE_PART_YEAR    = @"yy";
    
    public const int SELECTION_NONE                   = 99;
    public const int SELECTION_DAILY                  = 10;
    public const int SELECTION_START_OF_WEEK          = 20;
    public const int SELECTION_START_OF_MONTH         = 30;
    public const int SELECTION_START_OF_QUARTER       = 40;
    public const int SELECTION_START_OF_YEAR          = 50;
   
    public enum ScheduleSelection
    {      
     
      [Description("Daily")]
      DAILY = SELECTION_DAILY
       
    , [Description("Weekly")] 
      START_OF_WEEK  = SELECTION_START_OF_WEEK

    , [Description("Monthly")]  
      START_OF_MONTH = SELECTION_START_OF_MONTH

    , [Description("Quarterly")]   
      START_OF_QUARTER = SELECTION_START_OF_QUARTER
    
    , [Description("Yearly")]   
      START_OF_YEAR = SELECTION_START_OF_YEAR
    
    , [Description("None")]
      NONE = SELECTION_NONE
     
  }


/*
   ('Daily',     'Start of every day',     '59 23 * * *',        'dd' , 10, 1)
 , ('Weekly',    'Start of every week',    '59 23 * * 0',        'wk' , 20, 1)
 , ('Monthly',   'Start of every month',   '59 23 1 * *',        'mm' , 30, 1)
 , ('Quarterly', 'Start of every quarter', '59 23 1 1,4,7,10 *', 'qq' , 40, 1)
 , ('Yearly',    'Start of every year',    '59 23 1 1 *',        'yy' , 50, 1)
 , ('None',      'No schedule',            '',                   ''   , 99 ,1)
*/

    #endregion

    public static bool IsValueAScheduledDate (DateTime value, string crontab)
    {
      DateTime d = GetScheduledDate(value, crontab);
      return IsValueAScheduledDate (value, d);
    }

    public static bool IsValueAScheduledDate (DateTime value, DateTime scheduledDate)
    {
      DateTime d1 = Dates.StartDate(scheduledDate);
      DateTime d2 = Dates.StartDate(value);
      return d1.Equals(d2);
    }
                                                   
    public static DateTime GetScheduledDate (DateTime reference, string crontab)
    {
      // Gets next occurrence of the schedule with respect to reference
      DateTime basedate = Dates.StartDate(reference);
      CrontabSchedule s = GetSchedule(crontab);
      return s.GetNextOccurrence(basedate);      
    }

    public static IEnumerable<DateTime> GetScheduledDates (DateTime startDate,
                                                           DateTime endDate,
                                                           string crontab)
    {
      // Gets all occurrences of schedule between startDate and endDate
      DateTime sd = Dates.StartDate(startDate);
      DateTime ed = Dates.EndDate(endDate);
      CrontabSchedule s = GetSchedule(crontab);
      return s.GetNextOccurrences(sd,ed);           
    }

    private static CrontabSchedule GetSchedule (string crontab)
    {
     // Generates schedule object from crontab string
     CrontabSchedule s = CrontabSchedule.Parse(crontab);
     return s; 
    }
    
  }
}



