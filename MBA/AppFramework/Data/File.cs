using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;
using MBA.IdentifyData;
using MBA.Reporting;

namespace MBA
{ 
  
  /***************************************************************************
   * FileStyle */
  /**
   * Basic style rules for the document
   **************************************************************************/  
  
  public class FileStyle
  {
    public int   base_font;
    public int   font_size;
    public Color font_color;
    public Color background_color;
  
    public FileStyle()
    {
      this.base_font        = File.BASE_FONT_TIMES_ROMAN;
      this.font_size        = File.FONT_SIZE_LEAF;
      this.font_color       = File.COLOR_BLACK;
      this.background_color = File.COLOR_WHITE;
    }    
  }
    
  /***************************************************************************
   * CellStyleColumn */
  /**
   * Basic style rules for a column and its cells
   **************************************************************************/  

  public class CellStyle:FileStyle
  {
    public int   alignment;          
    public int[] borders;    
    public Color border_color;
    
    public bool  bold;  
    
    public CellStyle():base()
    {
      this.alignment    = File.ALIGN_LEFT;  
      this.bold         = false; 
      this.border_color = File.COLOR_BLACK;
    }
    
    public int GetBorder()
    {
      int border = File.BORDER_NONE;
      if (this.borders != null)
      {
        foreach (int b in this.borders)
        {
          border = border | b;
        }
      }
      return border;
    }    
  }
  
  /***************************************************************************
   * Document */
  /**
   * Basic settings for the document
   **************************************************************************/     
  
  public class Document
  { 
    public int       orientation;
    public float     margin_top;
    public float     margin_bottom;
    public float     margin_left;
    public float     margin_right;  
   
    public FileStyle defaultStyle;
    
    public Document()
    {
      orientation = File.ORIENTATION_PORTRAIT;
      
      margin_top    = 1f;
      margin_bottom = 1f;
      margin_left   = 1f;
      margin_right  = 1f;
      
      defaultStyle  = new FileStyle(); // FileStyle constructor sets appropriate defaults.
    }
  
  }
  
  
  /***************************************************************************
   * File */
  /**
   * Data file base class
   **************************************************************************/   
 
  public abstract class File
  { 
   
   /***************************************************************************
     * META_X */
    /**
     * Various meta data strings
     ***************************************************************************/  
   
   public static readonly string META_DOCUMENT_AUTHOR = Constants.APP_TITLE + ", " + Messages.COPYRIGHT_2;
   
    /***************************************************************************
     * PAGE_SIZE_X */
    /**
     * The various page sizes we will use
     ***************************************************************************/   
    
    public static readonly int PAGE_SIZE_LETTER = 1;
           
 	  /***************************************************************************
     * ORIENTATION_X */
    /**
     * The various print orientations we will use
     ***************************************************************************/   
    
    public static readonly int ORIENTATION_PORTRAIT  = 1;
    public static readonly int ORIENTATION_LANDSCAPE = 2;
          
 	  /***************************************************************************
     * BASE_FONT_X */
    /**
     * The various base fonts
     ***************************************************************************/   
    
    public static readonly int BASE_FONT_TIMES_ROMAN      = 1;    
    public static readonly int BASE_FONT_TIMES_ROMAN_BOLD = 2;
 	  
 	  /***************************************************************************
     * FONT_SIZE_X */
    /**
     * The various font sizes we will use
     ***************************************************************************/   

    public static readonly int FONT_SIZE_TITLE_1            = 24;
    public static readonly int FONT_SIZE_TITLE_2            = 18;
    public static readonly int FONT_SIZE_TITLE_3            = 16;
    public static readonly int FONT_SIZE_COL_HDR            = 10;
    public static readonly int FONT_SIZE_BRANCH             = 14;   
    public static readonly int FONT_SIZE_LEAF               = 10;
    public static readonly int FONT_SIZE_AGGREGATE_LABEL_L1 = FONT_SIZE_LEAF; 
    public static readonly int FONT_SIZE_AGGREGATE_LABEL_L0 = FONT_SIZE_BRANCH;     
    public static readonly int FONT_SIZE_FOOTER             = 10;

 	  /***************************************************************************
     * COLOR_X */
    /**
     * The various colors we will use
     ***************************************************************************/   
    
    public static readonly Color COLOR_BLACK      = Color.Black;
    public static readonly Color COLOR_WHITE      = Color.White;    
    public static readonly Color COLOR_DARK_GREY  = Color.FromArgb (255, 100, 100, 100);
    public static readonly Color COLOR_LIGHT_GREY = Color.FromArgb (255, 221, 221, 221);
    public static readonly Color COLOR_DARK_RED   = Color.FromArgb (255, 139, 0, 0);
    public static readonly Color COLOR_DARK_GREEN = Color.FromArgb (255, 0, 100, 0);
    
    /**************************************************************************
     * ALIGN_X */
    /**
     * For a given dataclass, determine the cells alignment.
     * These alignments are the same as the PDF alignments
     ***************************************************************************/
  
    public static readonly int ALIGN_LEFT   = 0;
    public static readonly int ALIGN_CENTER = 1;
    public static readonly int ALIGN_RIGHT  = 2;
    
    /**************************************************************************
     * BORDER_X */
    /**
     * For a given dataclass, determine the cells alignment.
     * These borders are the same as the PDF borders
     ***************************************************************************/

    public static readonly int BORDER_NONE   = 0;   
    public static readonly int BORDER_TOP    = 1;
    public static readonly int BORDER_BOTTOM = 2;
    public static readonly int BORDER_LEFT   = 4;
    public static readonly int BORDER_RIGHT  = 8;
        
    /**************************************************************************
     * DetermineCellAlignment */
    /**
     * For a given dataclass, determine the cells alignment.
     ***************************************************************************/
        
    protected static int DetermineCellAlignment (IdentifiedValue.DataClass dc)
    {
      int align = ALIGN_LEFT;  // Default alignment is left
      
      if (dc == IdentifiedValue.DataClass.NUMBER) align = ALIGN_RIGHT;
	    if (dc == IdentifiedValue.DataClass.TEXT)   align = ALIGN_LEFT;
	    if (dc == IdentifiedValue.DataClass.BOOL)   align = ALIGN_CENTER;
      if (dc == IdentifiedValue.DataClass.DATE)   align = ALIGN_CENTER;
     
      return align;
      
    }
          
    /**************************************************************************
     * DetermineCellBorders */
    /**
     * For a given node or column determine what kind of borders the cell
     * should have.
     ***************************************************************************/
    
    protected static int[] DetermineCellBorders  (InputColumnDefinition d)
    {
      List<int> borders = new List<int>();
      
      borders.Add(BORDER_BOTTOM);
      
      if (d.style_border_left)   borders.Add(BORDER_LEFT);
      if (d.style_border_right)  borders.Add(BORDER_RIGHT);
      
      return borders.ToArray();

    }
    
    protected static int[] DetermineCellBorders (DataTreeNode f)
    {            
      List<int> borders = new List<int>();
      
      if (f.style_border_left)                 borders.Add(BORDER_LEFT);
      if (f.style_border_right)                borders.Add(BORDER_RIGHT);
      if (f.rowtype == RowAttribute.AGGREGATE) borders.Add(BORDER_TOP);      
      
      return borders.ToArray();
    }
 	 
 	  protected static int[] DetermineCellBorders (int agrTitlePos)
 	  {
      List<int> borders = new List<int>();
      borders.Add(BORDER_NONE);
      return borders.ToArray();
 	  }
 	   
 	  /**************************************************************************
     * DetermineCellStyleTitle */
    /**
     * 
     ***************************************************************************/ 	  
 	  
 	  protected static CellStyle DetermineCellStyleTitle (TitleOrFooter title)
 	  {
 	    CellStyle cs = new CellStyle();
      
      cs.alignment = ALIGN_CENTER;
      
      if (title.position == 1) 
      {
        cs.font_size = FONT_SIZE_TITLE_1;
		    cs.bold = true;
		  }
		  
		  if (title.position == 2) cs.font_size = FONT_SIZE_TITLE_2;
		  if (title.position == 3) cs.font_size = FONT_SIZE_TITLE_3;
      
      return cs;
      
 	  }
 	  
 	  /**************************************************************************
     * DetermineCellStyleFooter */
    /**
     * 
     ***************************************************************************/ 
 	  
 	  protected static CellStyle DetermineCellStyleFooter (TitleOrFooter footer)
 	  {
 	   	CellStyle cs = new CellStyle();
      
      cs.alignment  = ALIGN_CENTER;
      cs.font_size  = FONT_SIZE_FOOTER;
      cs.bold       = false;   
      cs.font_color = COLOR_DARK_GREY;         
      return cs;
 	  }
 	  
 	  /**************************************************************************
     * DetermineCellStyleColumn */
    /**
     * 
     ***************************************************************************/ 
 	  
 	  protected static CellStyle DetermineCellStyleColumn (InputColumnDefinition d)
    {
      CellStyle cs = new CellStyle();
      
      cs.alignment        = DetermineCellAlignment(d.dataclass);
      cs.borders          = DetermineCellBorders(d);            
      cs.bold             = true;
      cs.font_size        = FONT_SIZE_COL_HDR;
      cs.font_color       = COLOR_BLACK;
      cs.background_color = COLOR_WHITE;
      return cs;
    }
     	  
 	  protected static CellStyle DetermineCellStyleColumn (DataTreeNode f, string evenodd)
    {
      CellStyle cs = new CellStyle();            
      
      cs.alignment        = DetermineCellAlignment(f.identifiedValue.dataClass);
      cs.borders          = DetermineCellBorders(f);      
      
      cs.font_color       = COLOR_BLACK;
      cs.background_color = COLOR_WHITE;
      cs.bold             = false;
      
      if (f.identifiedValue.valueIsPositive) cs.font_color = COLOR_DARK_GREEN;
      if (f.identifiedValue.valueIsNegative) cs.font_color = COLOR_DARK_RED;
            
      if (f.rowtype == RowAttribute.DETAIL)
      {
        if (f.nodetype == TreeNodeType.BRANCH) 
        {
          cs.font_size = FONT_SIZE_BRANCH;
          cs.bold      = true;
        }
        
        if (evenodd == "even") cs.background_color = COLOR_LIGHT_GREY;
        if (evenodd == "odd")  cs.background_color = COLOR_WHITE;       
      }      
      
      if (f.rowtype  == RowAttribute.AGGREGATE)
      {
        if (f.nodetype == TreeNodeType.LEAF)
        {
          cs.bold = true;          
        }
      }
                  
      return cs;
      
    }

    public static string[] SplitColHeaderIntoParts (string value, int colsize)
	  {
	    string[] parts;
	    if (value.Length > colsize)
	    {
        char[] delim = {' ','/','\\'};
        parts = value.Split(delim,StringSplitOptions.RemoveEmptyEntries);
	    }
	    else
	    {
	      parts = new string[1];
	      parts[0] = value;
	    }
	    
	    return parts;

	  }
	  
	  /***************************************************************************
     * GenerateFileName */
    /**
     * Combines folder, name, and extension into a filename
     * 
     * @param  folder     Path to file (optional)
     * @param  name       Name of the file (no extension)
     * @param  extension  File extension
     **************************************************************************/           

    public static string GenerateFileName (string name, string extension)
    {
      return GenerateFileName("", name, extension);
    }

    public static string GenerateFileName (string folder, string name, string extension)
    {
      string _filename;
      string _folder;
      string _name;
      string _extension;
            
      if (Util.IsNullOrEmpty(folder))    _folder = "" ; else _folder    = folder.Trim();
      if (Util.IsNullOrEmpty(name))      return ""    ; else _name      = name.Trim();
      if (Util.IsNullOrEmpty(extension)) return ""    ; else _extension = extension.Trim().Replace(".","");
            
      if (!Util.IsNullOrEmpty(_folder))
        _filename = System.IO.Path.Combine(_folder,_name);
      else
        _filename = _name;
      
      _filename = _filename + "." + _extension;
      
      return _filename;
    
    }
 	      
    /***************************************************************************
     * WriteBytes */
    /**
     * Write the contents of a byte array out to a file
     * 
     * @param  filename   Full path and filename
     * @param  file       Byte array containing file data
     **************************************************************************/   

    public static void WriteBytes (string filename, ref Byte[] file)
    {
      System.IO.File.WriteAllBytes(filename, file);      
    }
    
  }
}
