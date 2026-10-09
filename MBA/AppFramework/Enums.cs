using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Text;

namespace MBA
{
  /// <summary>
  /// Various utilities used to help with Enums
  /// </summary>

  public class Enums
  {

    #region Constructors

    /*============================================================
     * Constructors
     *============================================================*/

    public Enums ()
    {
    }

    #endregion

    #region Utility

    /// <summary>
    /// Returns <see cref="System.String"/> containing either
    /// the name or description of <paramref name="value"/>.
    /// Description is provided if it exists, otherwise name is used.
    /// Description is defined using <see cref="System.ComponentModel.DescriptionAttribute"/>
    /// </summary>
    /// <example>
    /// <code>
    /// enum Flavors
    /// {
    ///  none          = 0,
    ///  chocolate     = 1,
    ///  [Description("chocolate mint")]
    ///  chocolatemint = 2,
    ///  vanilla       = 3
    /// }
    ///
    /// string dn1 = GetEnumDescriptionOrName(Flavors.chocolate);     // Returns name
    /// string dn2 = GetEnumDescriptionOrName(Flavors.chocolatemint); // Returns description
    /// </code>
    /// </example>
    /// <remarks>
    /// Courtesy of http://blog.spontaneouspublicity.com/associating-strings-with-enums-in-c
    /// </remarks>
    /// <returns>
    /// <see cref="System.String"/>
    /// </returns>
    /// <param name='value'>
    /// <see cref="System.Enum"/>
    /// </param>

    public static string GetEnumDescriptionOrName(Enum value)
    {

      FieldInfo fi = value.GetType().GetField(value.ToString());

      DescriptionAttribute[] attributes =
        (DescriptionAttribute[])fi.GetCustomAttributes(typeof(DescriptionAttribute), false);

      if (attributes != null && attributes.Length > 0)
        return attributes[0].Description;
      else
        return value.ToString();
    }

    /// <summary>
    /// Returns <see cref="System.Collections.Generic.IEnumerable"/> for <paramref name="T"/>
    /// </summary>
    /// <remarks>
    /// Courtesy of http://blog.spontaneouspublicity.com/associating-strings-with-enums-in-c
    /// </remarks>
    /// <returns>
    /// <see cref="System.Collections.Generic.IEnumerable"/>
    /// </returns>
    /// <param name='T'>
    /// <see cref="System.Enum"/>
    /// </param>
    /// <exception cref='ArgumentException'>
    /// Is thrown if <paramref name="T"/> is not a <see cref="System.Enum"/>
    /// </exception>

    public static IEnumerable<T> EnumToList<T>()
    {

      Type enumType = typeof(T);

      // Can't use generic type constraints on value types,
      // so have to do check like this

      if (enumType.BaseType != typeof(Enum))
        throw new ArgumentException("T must be of type System.Enum");

      Array enumValArray = Enum.GetValues(enumType);
      List<T> enumValList = new List<T>(enumValArray.Length);

      foreach (int val in enumValArray)
      {
        enumValList.Add((T)Enum.Parse(enumType, val.ToString()));
      }

      return enumValList;
    }

    /// <summary>
    /// Returns <see cref="System.String"/> containing delimited (with <paramref name="delimeter"/>
    /// contents of <paramref name="T"/>
    /// </summary>
    /// <remarks>
    /// Based on http://blog.spontaneouspublicity.com/associating-strings-with-enums-in-c
    /// </remarks>
    /// <returns>
    /// <see cref="System.String"/>
    /// </returns>
    /// <param name='T'>
    /// <see cref="System.Enum"/>
    /// </param>
    /// <param name='delimiter'>
    /// <see cref="System.String"/> containing delimiter string to use
    /// </param>
    /// <exception cref='ArgumentException'>
    /// Is thrown if <paramref name="T"/> is not a <see cref="System.Enum"/>
    /// </exception>

    public static string EnumDescriptionOrNamesToString<T> (string delimiter)
    {

      Type enumType = typeof(T);

      // Can't use generic type constraints on value types,
      // so have to do check like this

      if (enumType.BaseType != typeof(Enum))
        throw new ArgumentException("T must be of type System.Enum");

      Array enumValArray = Enum.GetValues(enumType);

      List<String> enumDescNames = new List<String>();

      foreach (int val in enumValArray)
      {
        string don = GetEnumDescriptionOrName((Enum)Enum.Parse(enumType, val.ToString()));
        if (!Util.IsNullOrEmpty(don))
          enumDescNames.Add(don);
      }

      return String.Join (delimiter,enumDescNames.ToArray());
    }

    /// <summary>
    /// Returns <see cref="System.String"/> containing pipe (|) delimited
    /// names of <paramref name="T"/> that are set by <paramref name="value"/>
    /// </summary>
    /// <remarks>
    /// Based on http://blog.spontaneouspublicity.com/associating-strings-with-enums-in-c
    /// </remarks>
    /// <returns>
    /// <see cref="System.String"/>
    /// </returns>
    /// <param name='T'>
    /// <see cref="System.Enum"/>
    /// </param>
    /// <param name='value'>
    /// <see cref="System.Int"/> containing value to test
    /// </param>
    /// <exception cref='ArgumentException'>
    /// Is thrown if <paramref name="T"/> is not a <see cref="System.Enum"/>
    /// </exception>    
    
    public static string WhatEnumFlagsAreSetNames<T> (int value)
    {

      Type enumType = typeof(T);

      // Can't use generic type constraints on value types,
      // so have to do check like this

      if (enumType.BaseType != typeof(Enum))
        throw new ArgumentException("T must be of type System.Enum");
            
      Array enumValArray = Enum.GetValues(enumType);

      List<String> enumDescNames = new List<String>();

      foreach (int val in enumValArray)
      {
        if ((value & val) == val)
        {
          string don = GetEnumDescriptionOrName((Enum)Enum.Parse(enumType, val.ToString()));        
          if (!Util.IsNullOrEmpty(don)) enumDescNames.Add(don);
        }
      }
           
     return String.Join ("|",enumDescNames.ToArray());
   }

    #endregion

  }
}

