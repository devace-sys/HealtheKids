using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;
using System.Reflection;
using System.Runtime.Remoting;

/***************************************************************************
 * Datagrid
/**
 * Attributes for tagging class properties and fields as datagrid columns.
 * The datagrid control itself.
 ****************************************************************************/   

namespace MBA
{  
  /***************************************************************************
   * IsDataGridCol */
  /**
   * Indicates this field or property should be used as a datagrid column
   * and specifies what column number it should be.
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class IsDataGridCol : System.Attribute
  {
    public int number;

    public IsDataGridCol ()
    {
      this.number = -1;
    }
    
    public IsDataGridCol (int number)
    {
      this.number = number;
    }
  }

  /***************************************************************************
   * DataGridColWidth */
  /**
   * Indicates the width of the column in px
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColWidth : System.Attribute
  {
    public int width;
    
    public DataGridColWidth (int width)
    {
      this.width = width;
    }
  }

  /***************************************************************************
   * DataGridColIsMultiLine */
  /**
   * Should be a text area
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColIsMultiLine : System.Attribute
  {
    public bool ismultiline;

    public DataGridColIsMultiLine (bool isMultiLine)
    {
        this.ismultiline = isMultiLine;
    }
  }
  
  /***************************************************************************
   * DataGridColTitle */
  /**
   * Friendly title 
   ****************************************************************************/   

  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColTitle : System.Attribute
  {
    public string title;

    public DataGridColTitle (string title)
    {
        this.title = title;
    }
  }
  
  /***************************************************************************
   * DataGridColGroup */
  /**
   * Denotes 2 or more columns that should be treated as a group
   * 
   ****************************************************************************/   

  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColGroup : System.Attribute
  {
    public string group;

    public DataGridColGroup (string group)
    {
      this.group = group;
    }
  }

  /***************************************************************************
   * DataGridColSection */
  /**
   * Denotes a section of columns
   ****************************************************************************/   

  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColSection : System.Attribute
  {
    public string section;

    public DataGridColSection (string section)
    {
      this.section = section;
    }
  }

  /***************************************************************************
   * DataGridColIsInputLabel */
  /**
   * This should be used as an input label in a datagrid.
   ****************************************************************************/   
 
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColIsInputLabel : System.Attribute
  {
    public bool islabel;

    public DataGridColIsInputLabel (bool islabel)
    {
        this.islabel = islabel;
    }
  }

  /***************************************************************************
   * DataGridColIsInputKey */
  /**
   * This should be used as an input key in a datagrid.
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColIsInputKey : System.Attribute
  {
    public bool iskey;

    public DataGridColIsInputKey (bool iskey)
    {
        this.iskey = iskey;
    }
  }
    
  /***************************************************************************
   * DataGridColCtrlCopy */
  /**
   * This column provides an input for a default value that can be copied down
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColCtrlCopy : System.Attribute
  {
    public bool ctrlcopy;

    public DataGridColCtrlCopy (bool ctrlcopy)
    {
      this.ctrlcopy = ctrlcopy;
    }
  }
  
  /***************************************************************************
   * DataGridColCtrlCopyAcross */
  /**
   * This column can be copied across to all like columns
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColCopyValueRight : System.Attribute
  {
    public bool copyvalueright;

    public DataGridColCopyValueRight (bool copyvalueright)
    {
      this.copyvalueright = copyvalueright;
    }
  }
    
  /***************************************************************************
   * DataGridColIsHidden */
  /**
   * This controls whether the column is visible or not
   ****************************************************************************/   
  
  [System.AttributeUsage(AttributeTargets.Property | AttributeTargets.Struct | AttributeTargets.Field)]
  
  public class DataGridColIsHidden : System.Attribute
  {
    public bool ishidden;

    public DataGridColIsHidden (bool ishidden)
    {
      this.ishidden = ishidden;
    }
  }
  
  /**************************************************************************
   * DatagridCol */
  /**
   * TableBox column definition
   *****************************************************************************/
  
  public class DataGridCol: IComparable<DataGridCol>
  {
    public int    number;
    public int    width;
    public bool   ismultiline;
    public string name;
    public string group;
    public string title;
    public string section;
    public string clienttype;
    public bool   ctrlcopy;
    public bool   islabel;
    public bool   iskey;
    public bool   ishidden;
    public bool   copyvalueright;

    public int CompareTo(DataGridCol obj)
    {
      /*-------------------------------
       * Impements required method
       *------------------------------*/
            
      if ((obj != null) && (obj is DataGridCol))
      {
        /*-------------------------------
         * Cast obj as DataGridCol
         *------------------------------*/

        DataGridCol dc = (DataGridCol) obj;
        
        /*-------------------------------
         * Perform comparison on column
         * number.
         * 
         * Note: The integer CompareTo
         * method is already implemented 
         * so we are taking advantage of
         * this by just calling it.
         *------------------------------*/

        return this.number.CompareTo(dc.number);
      }
      else
      {
        throw new Critical(@"Object must be of type DataGridCol");
      }      
    }
  }
  
  /**************************************************************************
   * DataGrid */
  /**
   * Data entry grid control
   ****************************************************************************/

  public class DataGrid : WebUIControlDataFields
  {
    public DataGrid ()                                                                  : base("input", true )              { }
    public DataGrid (string name, string value, string classAssembly, string className) : base("input", true, name, value)  {this.classAssembly = classAssembly; this.className = className;}

    protected  string    _classAssembly;
    protected  string    _className;
    protected  string    _onRowFocusIn;
    protected  string    _onRowFocusOut;
    protected  string    _onCellFocusIn;
    protected  string    _onCellFocusOut;
    protected  string    _onRowAdd;
    protected  string    _onRowRemove;
    
    protected  bool      _sortRowsByKey = true;
    protected  string    _onClearButtonClick;
    protected bool       _showControls = true;
    protected bool       _addRemoveButtonForEachBodyRow = false;
    public     string   classAssembly  { get { return _classAssembly;  } set { _classAssembly = value; } }
    public     string   className      { get { return _className;      } set { _className     = value; } }

    public     string   onRowFocusIn   { get { return _onRowFocusIn;   } set { _onRowFocusIn  = value; } } 
    public     string   onRowFocusOut  { get { return _onRowFocusOut;  } set { _onRowFocusOut = value; } } 
    
    public     string   onCellFocusIn  { get { return _onCellFocusIn;  } set { _onCellFocusIn  = value; } } 
    public     string   onCellFocusOut { get { return _onCellFocusOut; } set { _onCellFocusOut = value; } } 
    public     string   onRowAdd       { get { return _onRowAdd;       } set { _onRowAdd       = value; } }
    public     string   onRowRemove    { get { return _onRowRemove;    } set { _onRowRemove    = value; } }
    
    public     bool     sortRowsByKey  { get { return _sortRowsByKey;  } set { _sortRowsByKey  = value; } }
    
    public     string   onClearButtonClick { get { return _onClearButtonClick; } set { _onClearButtonClick = value; } }
    public     bool     addRemoveButtonForEachBodyRow {get { return _addRemoveButtonForEachBodyRow; } set { _addRemoveButtonForEachBodyRow = value; } }     
    
    public bool showControls { get { return _showControls;} set {_showControls = value;} }
    
    /***************************************************************************
     * setParentStepLabel */
    /**
     * Finds ctrls parent step control (if it exists) sets its label using 
     * the value of this control
     * 
     * @param  labelText       text to display in label
     * @return                 Step control or null
     ***************************************************************************/   

    public new Step setParentStepLabel ()
    {
      return setParentStepLabel(@"Details Entered or Updated");
    }

    protected override void Render(HtmlTextWriter writer)
    {      
      /*-------------------------------
       * Check for row definition class
       * assembly and name
       *------------------------------*/

      if ( Util.IsNullOrEmpty (_classAssembly) ) throw new Critical ("Class assembly is required");
      if ( Util.IsNullOrEmpty (_className)     ) throw new Critical ("Class name is required");
           
      /*-------------------------------
       * If we reach this point 
       * attempt to create an instance
       * of the class passed in
       *------------------------------*/

      ObjectHandle rc;

      try
      {
       rc = Activator.CreateInstance (_classAssembly, _className);
      }
      catch (Exception err)
      {
        throw new Critical ("Could not create instance of " + _className);
      }
      
      /*-------------------------------
       * If we reach this point 
       * using reflection retrieve the
       * classes members
       *------------------------------*/

      Type         rt   = rc.Unwrap().GetType();
      MemberInfo[] rmi  = rt.GetMembers();
      
      /*-------------------------------
       * If we reach this point 
       * traverse this list and build
       * another list we can use to
       * create our client side class
       *------------------------------*/

      int numKeys            = 0;
      int numCols            = 0;

      List<DataGridCol> colsList = new List<DataGridCol>();

      foreach (MemberInfo m in rmi)
      {

        /*-------------------------------
         * We only care about properties
         * and fields.
         *------------------------------*/
        
        if (m.MemberType == MemberTypes.Property | m.MemberType == MemberTypes.Field)
        {
          
          /*-------------------------------
           * Futhermore we only care about
           * those properies or fields that
           * have been tagged as being
           * a datagrid column.
           * To test this we extract the
           * IsDataGridCol attribute 
           * if it exists.
           *------------------------------*/

          IsDataGridCol[]           pn        = (IsDataGridCol[])            m.GetCustomAttributes (typeof(IsDataGridCol),           true);
          DataGridColIsMultiLine[]  piml      = (DataGridColIsMultiLine[])   m.GetCustomAttributes (typeof(DataGridColIsMultiLine),  true);
          
          bool   isColumn      = (pn.Length   > 0) ? true : false;
          bool   isMultiLine   = (piml.Length > 0) ? piml[0].ismultiline : false;
      
          /*-------------------------------
           * If this field or property is
           * tagged as a datagrid column
           * continue.
          *------------------------------*/

          if (isColumn)
          {

            /*-------------------------------
             * Create a datagrid column
             *------------------------------*/

            DataGridCol dc = new DataGridCol();

            /*-------------------------------
             * Update our column count
             *------------------------------*/

            numCols++;

            /*-------------------------------
             * Extract remaining meta data
             * defined in attributes
             *------------------------------*/

            DataGridColWidth[]        pcw  = (DataGridColWidth[])         m.GetCustomAttributes (typeof(DataGridColWidth),        true);
            DataGridColTitle[]        pt   = (DataGridColTitle[])         m.GetCustomAttributes (typeof(DataGridColTitle),        true);
            DataGridColGroup[]        pg   = (DataGridColGroup[])         m.GetCustomAttributes (typeof(DataGridColGroup),        true);
            DataGridColSection[]      ps   = (DataGridColSection[])       m.GetCustomAttributes (typeof(DataGridColSection),      true);
            DataGridColCtrlCopy[]     pc   = (DataGridColCtrlCopy[])      m.GetCustomAttributes (typeof(DataGridColCtrlCopy),     true);
            DataGridColIsInputLabel[] pil  = (DataGridColIsInputLabel[])  m.GetCustomAttributes (typeof(DataGridColIsInputLabel), true);
            DataGridColIsInputKey[]   pik  = (DataGridColIsInputKey[])    m.GetCustomAttributes (typeof(DataGridColIsInputKey),   true);
            DataGridColIsHidden[]     pih  = (DataGridColIsHidden[])      m.GetCustomAttributes (typeof(DataGridColIsHidden),     true);            

            DataGridColCopyValueRight[] pcva = (DataGridColCopyValueRight[]) m.GetCustomAttributes (typeof(DataGridColCopyValueRight), true);
            
           /*-------------------------------
            * Identify .NET datatype of 
            * member and translate it to
            * a client side (javascript)
            * data type.
            *------------------------------*/

            string mType = "";
            string dType = "";
          
            // Seperate datatype from name

            string [] mNameParts = m.ToString().Split(' ');          
          
            if (mNameParts != null) 
            if (mNameParts.Length > 0) mType = mNameParts[0];
          
            // Strip out nullable info

            mType = mType.Replace("System.Nullable`1[","");
            mType = mType.Replace("]","");
            
            // Strip out system. prefix if it exists
            mType = mType.Replace("System.","");
            
            // Lowecase and trim
            
            mType = mType.ToLower().Trim();
            
            switch (mType)
            {
              case "datetime" : { dType = WEB_UI_FIELD_DATA_DATE;   break; }
              case "boolean"  : { dType = WEB_UI_FIELD_DATA_FLAG;   break; }              
              case "single"   : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }            
              case "double"   : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }            
              case "decimal"  : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }
              case "int16"    : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }
              case "int32"    : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }
              case "int64"    : { dType = WEB_UI_FIELD_DATA_NUMBER; break; }
              case "string"   : { if      (isMultiLine == false) dType = WEB_UI_FIELD_DATA_TEXT;  
                                  else if (isMultiLine == true)  dType = WEB_UI_FIELD_DATA_TEXT_AREA;
                                  else                           dType = WEB_UI_FIELD_DATA_TEXT;  
                                  break;}
              default         : { dType = WEB_UI_FIELD_DATA_TEXT;   break; }
            }
            
           /*-------------------------------
            * Provide defaults or 
            * substitute values for
            * meta data
            *------------------------------*/
         
            int     number         = (pn.Length   > 0) ? pn[0].number           : numCols;
            bool    isInputLabel   = (pil.Length  > 0) ? pil[0].islabel         : false;
            bool    isInputKey     = (pik.Length  > 0) ? pik[0].iskey           : false;
            bool    ctrlCopy       = (pc.Length   > 0) ? pc[0].ctrlcopy         : false;
            string  title          = (pt.Length   > 0) ? pt[0].title            : m.Name;
            string  group          = (pg.Length   > 0) ? pg[0].group            : "";
            string  section        = (ps.Length   > 0) ? ps[0].section          : "";
            bool    isHidden       = (pih.Length  > 0) ? pih[0].ishidden        : false;
            bool    copyValueRight = (pcva.Length > 0) ? pcva[0].copyvalueright : false;
          
            int width = 0;
            
            if (pcw.Length > 0)
            {
              width = pcw[0].width;
            }
            else
            {
              switch (dType)
              {
                case WEB_UI_FIELD_DATA_FLAG:      {width = 60;  break;}
                case WEB_UI_FIELD_DATA_NUMBER:    {width = 70;  break;}
                case WEB_UI_FIELD_DATA_DATE:      {width = 100; break;}
                case WEB_UI_FIELD_DATA_TEXT:      {width = 250; break;}
                case WEB_UI_FIELD_DATA_TEXT_AREA: {width = 250; break;}
                default:                          {width = 300; break;}
              }
            }
           
                     
           /*-------------------------------
            * Count keys
            * 1 and only one key is required
            *------------------------------*/

            if (isInputKey) numKeys++;
                     
            /*-------------------------------
            * Populate col def and add to
            * the list
            *------------------------------*/
          
            dc.number         = number;
            dc.width          = width;
            dc.ismultiline    = isMultiLine;
            dc.title          = title;
            dc.islabel        = isInputLabel;
            dc.iskey          = isInputKey;
            dc.ctrlcopy       = ctrlCopy;
            dc.name           = m.Name;
            dc.group          = group;
            dc.section        = section;
            dc.clienttype     = dType;
            dc.ishidden       = isHidden;                        
            dc.copyvalueright = copyValueRight;

            colsList.Add(dc);
          }
        }
      }

     /*-------------------------------
      * Make sure an input key is 
      * defined.  If not let developer 
      * know.
      *------------------------------*/

      if (numKeys != 1) throw new Critical ("There are " + numKeys + " input keys defined.  1 and only 1 input key is required.");
       
     /*-------------------------------
      * Sort our list (by column number)
      *------------------------------*/
  
      colsList.Sort();
      
     /*-------------------------------
      * Serialize col list and pass it
      * to the client side control
      * via opts
      *------------------------------*/

      string colsDef = JSON.toJSONString(colsList);
      
      string prms    = @"{";
      
      prms = prms + @"""aCols"":" + colsDef;
      prms = prms + @",""onRowFocusIn"":function(e){"    + _onRowFocusIn    + "}";
      prms = prms + @",""onRowFocusOut"":function(e){"   + _onRowFocusOut   + "}";
      prms = prms + @",""onCellFocusIn"":function(e){"   + _onCellFocusIn   + "}";
      prms = prms + @",""onCellFocusOut"":function(e){"  + _onCellFocusOut  + "}";
      prms = prms + @",""sortRowsByKey"":" + Util.netBoolToJSBool(_sortRowsByKey);
      prms = prms + @",""showControls"":"  + Util.netBoolToJSBool(_showControls);
      prms = prms + @",""onRowAdd"":function(dgObj,rowObj){"      + _onRowAdd        + "}";
      prms = prms + @",""onRowRemove"":function(dgObj,rowObj){"   + _onRowRemove     + "}";
      prms = prms + @",""onClearButtonClick"":function(){"        + _onClearButtonClick + "}";
      prms = prms + @",""addRemoveButtonForEachBodyRow"":" + Util.netBoolToJSBool(_addRemoveButtonForEachBodyRow);
      prms = prms + @"}";
      
     this.addAttribute("type", "text", ATTR_HTML_TAG);
     
     /*-------------------------------
      * Let client know this is a 
      * client side control and render
      *------------------------------*/
      
      this.addAttribute("spedmonDataGrid", prms, ATTR_JS_PAGE_LOAD_METHOD);      
      base.Render(writer);
    }
    
    // TODO: Why did I put this in?  Loading values?
    
    /*internal void RenderControl(ref HtmlTextWriter writer)
    {
      throw new NotImplementedException();
    }*/
  }
}

