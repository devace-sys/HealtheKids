using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Reflection;
using System.Collections.ObjectModel;
using System.Web;
using System.Text.RegularExpressions;
using System.Linq;

/***************************************************************************
 * Atributes */
/**
 * Custom attributes used to assign meta data to class members, properties,
 * fields, etc.
 * 
 * Usage:
 * 
 * [AtributeName("Value")]
 *
 * Example:
 * 
 * public SomeClass()
 * {
 *   [PropertyTitle("Date of Service")]
 *   public string dos;
 *   public string name;
 * }
 ****************************************************************************/   


namespace MBA
{
   
  /***************************************************************************
   * DeclarationOrderComparator */
  /**
   * Used to return the various members of a class in order of declaration
   * Very useful for preserving order for sub classes
   * 
   * Based on a class from Sebastien Mahe
   * http://www.sebastienmahe.com/v3/seb.blog/2010/03/08/c-reflection-getproperties-kept-in-declaration-order/
   ****************************************************************************/       
   
  public class DeclarationOrderComparator : IComparer
  {
    int IComparer.Compare(Object x, Object y)
    {
      MemberInfo first  = x as MemberInfo;
      MemberInfo second = y as MemberInfo;      
      
      if      (first.MetadataToken < second.MetadataToken) return -1;
      else if (first.MetadataToken > second.MetadataToken) return 1;
              
      return 0;
    }
  }  
}
