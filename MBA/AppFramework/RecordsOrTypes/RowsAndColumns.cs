using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using MBA.Reporting;

using ca = MBA.ColumnAttribute;
using iv = MBA.IdentifyData.IdentifiedValue;

namespace MBA
{
  
  /***************************************************************************
   * InputColType */
  /**
   * Indicates the context in which the input columns should be interpretted.
   * 
   * A root field is the root
   * A group field is a node
   * A data field is a leaf 
   * 
   ***************************************************************************/  

  public enum InputColType
   {
     GROUP, 
     DATA
   };     
  
   
  /***************************************************************************
   * InputColumnDefinition */
  /**
   * Provides mapping for input columns
   ***************************************************************************/     
  
  public class InputColumnDefinition: IComparable<InputColumnDefinition>
  {        
    
    public const int WIDTH_NA = -1;

    public InputColType      inputcoltype;
    public ColumnAttribute[] colattributes;
    
    public bool           aggregate;
    public bool           meta;
    public bool           visible;
    public bool           headertitle;
    public bool           contenttitle;
    public int            titlelevel;
    public int            position;
    public string         name;
    public int            width;
		public string         formatstring;
    public iv.DataClass   dataclass;
    public bool           style_border_left;
    public bool           style_border_right;
    
	  /*---------------------------------
	   * Constructors
	   *--------------------------------*/
		     
    public InputColumnDefinition(int    position, 
                                 string name, 
                                 int    width,
                                 params ColumnAttribute[] attributes)
	  {
      this.position       = position;
	    this.name           = name;
      this.width          = width;
      
      this.colattributes  = attributes;

      this.inputcoltype   = InputColType.DATA;
      this.visible        = true;
      this.headertitle    = false;
      this.contenttitle   = false;
      this.titlelevel     = -1;
      this.meta           = false;
      this.aggregate      = false;
      this.formatstring   = "";
      this.dataclass      = iv.DataClass.TEXT;
      
      this.style_border_left  = false;
      this.style_border_right = false;
      
      foreach (ColumnAttribute colattribute in colattributes)
      {
        if (colattribute == ColumnAttribute.DATA_VIEW_GROUP)    this.inputcoltype   = InputColType.GROUP;
        if (colattribute == ColumnAttribute.HIDDEN)             this.visible        = false;
        
        if (ColumnAttributeUtils.isHeaderTitle (colattribute)) 
          this.headertitle = true;
        
        if (ColumnAttributeUtils.isContentTitle(colattribute))
          this.contenttitle = true;

        if (this.headertitle)
          this.titlelevel= ColumnAttributeUtils.DecodeHeaderTitleLevel(colattribute);

        if (this.contenttitle)
          this.titlelevel = ColumnAttributeUtils.DecodeContentTitleLevel(colattribute);

        if (colattribute == ca.META)                                 this.meta         = true;
        if (colattribute == ca.AGGREGATE)                            this.aggregate    = true;
        
        if (colattribute == ca.DATA_FORMAT_NUMBER_FINANCIAL)         this.formatstring = FormatStrings.NUMBER_FINANCIAL;
        if (colattribute == ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO) this.formatstring = FormatStrings.NUMBER_FINANCIAL_NO_ZERO;
        if (colattribute == ca.DATA_FORMAT_PERCENTAGE_FINANCIAL)     this.formatstring = FormatStrings.PERCENTAGE_FINANCIAL;
        if (colattribute == ca.DATA_FORMAT_DATETIME_MM_DD_YYYY)      this.formatstring = FormatStrings.DATETIME_MM_DD_YYYY;

        if (colattribute == ca.DATA_CLASS_BOOL)    this.dataclass = iv.DataClass.BOOL;
        if (colattribute == ca.DATA_CLASS_NUMBER)  this.dataclass = iv.DataClass.NUMBER;;
        if (colattribute == ca.DATA_CLASS_TEXT)    this.dataclass = iv.DataClass.TEXT;
        
        if (colattribute == ca.STYLE_BORDER_LEFT)  this.style_border_left  = true;
        if (colattribute == ca.STYLE_BORDER_RIGHT) this.style_border_right = true;
      }
	    
	    /*---------------------------------
	     * Assign default width
	     *--------------------------------*/
	   
	    if (this.width == WIDTH_NA)
	    {
	      this.width = iv.DataClassToCharWidth (this.dataclass);
	    }
      
      if (headertitle) this.visible = false;	    
      if (meta)        this.visible = false;

    }
    
    /*---------------------------------
	   * Interface methods
	   *--------------------------------*/		 	
	
	  /**************************************************************************
     * CompareTo */
    /**
     * Implements CompareTo method required by IComparable
     ***************************************************************************/

	  public int CompareTo (InputColumnDefinition other)
	  {
	    return this.position.CompareTo(other.position);
	  }  
  }
  
  /***************************************************************************
   * RowAttribute */
  /**
   * For row/column structures this provides meta data about rows
   ***************************************************************************/  
  
  public enum RowAttribute
  {
    DETAIL,
    AGGREGATE 
  }
   
  /***************************************************************************
   * ColumnAttribute */
  /**
   * For row/column structures this provides meta data about columns.
   ***************************************************************************/  

  public enum ColumnAttribute
  {
    DATA_VIEW_DATA,
    DATA_VIEW_GROUP,
    DATA_FORMAT_DATETIME_MM_DD_YYYY,
    DATA_FORMAT_NUMBER_FINANCIAL,
    DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO,
    DATA_FORMAT_PERCENTAGE_FINANCIAL,
    AGGREGATE,    
    META,
    SORT,
    DATA_CLASS_TEXT,
    DATA_CLASS_NUMBER,
    DATA_CLASS_BOOL,
    DISPLAY_HEADER_TITLE_1,
    DISPLAY_HEADER_TITLE_2,
    DISPLAY_HEADER_TITLE_3,
    DISPLAY_CONTENT_TITLE_4,
    DISPLAY_CONTENT_TITLE_5,
    STYLE_BORDER_LEFT,
    STYLE_BORDER_RIGHT,
    HIDDEN
  }
  
  /***************************************************************************
   * ColumnAttributeUtils */
  /**
   * Utilities for identifying and decoding column attributes
   ***************************************************************************/   
  
  public class ColumnAttributeUtils
  {  
    public static bool isHeaderTitle (ColumnAttribute ca)
    {
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_1) return true;
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_2) return true;
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_3) return true;
      return false;
    }
    
    public static int DecodeHeaderTitleLevel (ColumnAttribute ca)
    {
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_1) return 1;
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_2) return 2;
      if (ca == ColumnAttribute.DISPLAY_HEADER_TITLE_3) return 3;
      return -1;
    }

    public static bool isContentTitle (ColumnAttribute ca)
    {
      if (ca == ColumnAttribute.DISPLAY_CONTENT_TITLE_4) return true;
      if (ca == ColumnAttribute.DISPLAY_CONTENT_TITLE_5) return true;
      return false;
    }
    
    public static int DecodeContentTitleLevel (ColumnAttribute ca)
    {
      if (ca == ColumnAttribute.DISPLAY_CONTENT_TITLE_4) return 4;
      if (ca == ColumnAttribute.DISPLAY_CONTENT_TITLE_5) return 5;
      return -1;
    }
  }
}
