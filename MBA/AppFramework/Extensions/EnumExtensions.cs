using System;
using System.Reflection;
using System.ComponentModel; 
using System.Linq;

namespace MBA
{
  /// <summary>
  /// Enumaration extensions
  /// </summary>

  public static class EnumExtensions
  {
    
    /// <summary>
    /// Returns the text contained in the description decorator
    /// </summary>
    /// <remarks>Based on Micheal Earl's method https://cerkit.com/2015/05/11/decorating-an-enum-with-the-description-attribute-for-later-use-csharp-dotnet/</remarks>
    /// <returns>
    /// String
    /// </returns>

    public static string GetDescription(this Enum en)
	  {
		  var attribute =
  			 en.GetType()
				.GetTypeInfo()
				.GetMember(en.ToString())
				.FirstOrDefault(member => member.MemberType == MemberTypes.Field)
				.GetCustomAttributes(typeof(DescriptionAttribute), false)
				.SingleOrDefault()
			  as DescriptionAttribute;
		  return attribute?.Description ?? en.ToString();
	  }
    
    /// <summary>
    /// Returns the value of the enum as an int
    /// </summary>
    /// <remarks>Enum must be declared with ints</remarks>
    /// <returns>
    /// String
    /// </returns>

    public static int GetValueAsInt (this Enum en)
    {
      return (int)(object)en;      
    }

    /// <summary>
    /// Returns the value of the enum as a string
    /// </summary>
    /// <remarks>Enum must be declared with ints</remarks>
    /// <returns>
    /// String
    /// </returns>

    public static string GetValueAsString (this Enum en)
    {  
      return GetValueAsInt(en).ToString();                            
    }

  }
}

