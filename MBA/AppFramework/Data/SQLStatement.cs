using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using MBA.Reporting;

namespace MBA
{
  
  public enum SQLResultSetPurpose
  {
	  VIEW,
    REPORT
  };


  /***************************************************************************
   * SQLStatement */
  /**
   * Helper class to create a SQL string
   ***************************************************************************/   
  
  public class SQLStatement
  {
    
   /*-------------------------------------------------------------------------
    *                  Constructors and protected methods
    *------------------------------------------------------------------------*/

    protected SQLResultSetPurpose _purpose  = new SQLResultSetPurpose();
    
    protected Arguments _colsDisplay  = new Arguments();
    protected Arguments _colsSort     = new Arguments();
    protected Arguments _pageRowOrder = new Arguments();  // For paging

    protected string    _colsFrom     = "";
    protected string    _colsWhere    = "";
    protected bool      _skipOrderBy  = false;

    protected  List    <InputColumnDefinition>   _inputFieldDefinitions; 
    public     List    <InputColumnDefinition>   InputFieldDefinitions   { get {return _inputFieldDefinitions;} }

    /*public SQLStatement()
    {
      this._inputFieldDefinitions = new List<InputFieldDefinition>();
      this._purpose = SQLResultSetPurpose.VIEW;
    }*/
    
    /*public SQLStatement(string colsFrom)
    {
      this._colsFrom  = colsFrom;
      this._purpose   = SQLResultSetPurpose.VIEW;
      this._inputFieldDefinitions = new List<InputFieldDefinition>();
    }*/

    public SQLStatement(string colsFrom, SQLResultSetPurpose purpose)
    {
      this._colsFrom  = colsFrom;
      if (Util.IsNullOrEmpty(_colsFrom)) throw new MBA.Critical("You must provide a from");
      this._purpose   = purpose;
      this._inputFieldDefinitions = new List<InputColumnDefinition>();
    }

    /***************************************************************************
     * createSelect */
    /**
     * Creates the "SELECT " portion of the SQL string.  If no columns are
     * provided, a default column of * is provided and SELECT * is returned
     * 
     * @return   SELECT portion of SQL string
     ***************************************************************************/
    
    protected string createSelect()
    {
      if (_colsDisplay.isEmpty) _colsDisplay.add("*");
      return "select " + _colsDisplay.ToString();
    }
    
    /***************************************************************************
     * createFrom */
    /**
     * Creates the "FROM " portion of the SQL string.  If no from definition
     * has been provided an expection is thrown.
     * 
     * @return   FROM portion of SQL string
     ***************************************************************************/

    protected string createFrom()
    {
      return " from " + _colsFrom;
    }

    /***************************************************************************
     * createWhere */
    /**
     * Creates the "WHERE " portion of the SQL string.  If no where definition
     * has been provided a blank string is returned because the WHERE clause is
     * not necessary.
     * 
     * @return   WHERE portion of SQL string 
     ***************************************************************************/

    protected string createWhere()
    {
      if (Util.IsNullOrEmpty(_colsWhere)) return "";
      return " where " + _colsWhere;
    }

    /***************************************************************************
     * createOrderBy */
    /**
     * Creates the "ORDER BY " portion of the SQL string.  If no columns
     * has been provided a blank string is returned because the ORDER BY clause
     * is not necessary.  Also if a pageroworder has been defined we skip it.
     * 
     * @return ORDER BY portion of SQL string 
     ***************************************************************************/

    protected string createOrderBy()
    {
      if (!_pageRowOrder.isEmpty) return ""; 
      if (_colsSort.isEmpty)      return "";
      return " order by " + _colsSort.ToString();
    }
  
    /***************************************************************************
     * createSQLString */
    /**
     * Creates the SQL String
     * 
     * @return SQL String
     ***************************************************************************/

    protected string createSQLString()
    {
      return createSelect() + createFrom() + createWhere() + createOrderBy() ;
    }
    
    /***************************************************************************
     * coltoPageRowOrderCol */
    /**
     * Converts a col to a pageroworder friendly column
     * The page row order works with the outer query.  For example if your
     * have a column defined as 'clientID as [Client ID]' then page row order
     * expects to see [Client ID] not clientID.
     * 
     * @param  col    Column in
     * @return string
     ***************************************************************************/    
    
    protected string colToPageRowOrderCol (string col)
    {
      string newcol = Regex.Replace(col,@".{1,}\s{1,}as\s{1,}","");  // Removes 'as' portion
      newcol        = newcol.Trim();
      return newcol;
    }

    /***************************************************************************
     * createPageRowOrder */
    /**
     * Creates the page row order string used by paged queries
     * 
     * @return string
     ***************************************************************************/    

    protected string createPageRowOrder()
    {
      return _pageRowOrder.ToString();
    }

   /*-------------------------------------------------------------------------
    *                        Properties and Methods
    *------------------------------------------------------------------------*/

    /***************************************************************************
     * addDisplayColumn */
    /**
     * Adds a display column (column to the SELECT portion)
     *
     * @param  col        Column or columns to add
     * @param  pageRow    Include this column in the pageroworder string   
     ***************************************************************************/   

    public void addDisplayColumn (string col)
    {
      addDisplayColumn(col,false);
      return;
    }

    public void addDisplayColumn (string[] cols)
    {
      addDisplayColumn(cols, false);
      return;
    }

    public void addDisplayColumn (string[] cols, bool pageRow)
    {
      foreach (string col in cols) addDisplayColumn(col, pageRow);
    }
        
    public void addDisplayColumn (string col, bool pageRow)
    {
      _colsDisplay.add(col);
      if (pageRow)
        _pageRowOrder.add(colToPageRowOrderCol(col));       
      return;
    }
    
    /***************************************************************************
     * addRptColumn */
    /**
     * Adds a column (column to the SELECT portion) for reporting
     *
     * @param  position       Zero based ordinal position of column
     * @param  name           Column or columns to add
     * @param  formatstring   Format string to use when generating the formated 
     *                        string version of this column
     * @param  colattributes  The various attributes for this column
     ***************************************************************************/ 
         
    public void addRptColumn (int position, string name, params ColumnAttribute[] colattributes)
    {
      addRptColumn(position, name, InputColumnDefinition.WIDTH_NA , colattributes);
    }
    
    public void addRptColumn (int position, string name, int width, params ColumnAttribute[] colattributes)
    {
     /*---------------------------------
	    * Escape any spaces in our column 
      * name by wrapping it in brackets
	    *--------------------------------*/
      
      string _displaycol = "[" + name + "]";      
      
      addDisplayColumn(_displaycol);
      

      // If the column is a report group add it to the sort
      
      //if ((rptGroup) | (sortBy))
      //  addSortColumn(_displaycol);
      this._inputFieldDefinitions.Add(new InputColumnDefinition (position, name, width, colattributes));
    
    }

    /***************************************************************************
     * addDisplayColumnIfValueIsNull */
    /**
     * Adds a display column (column to the SELECT portion) if value is null.
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col        Column to add
     * @param  value      Value to test
     * @param  pageRow    Include this column in the pageroworder string   
     * ***************************************************************************/   
    
    public void addDisplayColumnIfValueIsNull (string col, Object value)
    {
      addDisplayColumnIfValueIsNull (col, value, false);
      return;
    }
    
    public void addDisplayColumnIfValueIsNull (string col, Object value, bool pageRow)
    {
      if (value == null)
      {
        _colsDisplay.add(col);
        if (pageRow) _pageRowOrder.add(colToPageRowOrderCol(col));
      }
      return;
    }

    /***************************************************************************
     * addDisplayColumnIfParmValueIsNull */
    /**
     * Adds a display column (column to the SELECT portion) if the parameter
     * referenced by name in parms is null.
     *
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col        Column to add
     * @param  name       Name of parameter in parms
     * @param  pageRow    Include this column in the pageroworder string   
     * @param  parms      SQL parameter collection
     * ***************************************************************************/   
    
    public void addDisplayColumnIfParmValueIsNull (string col, string name, ref List<SqlParameter> parms)
    {
      addDisplayColumnIfParmValueIsNull(col, name, false, ref parms);
      return;
    }

    public void addDisplayColumnIfParmValueIsNull (string col, string name, bool pageRow, ref List<SqlParameter> parms)
    {
      Object value = Database.getParameterValue(name,ref parms);
      addDisplayColumnIfValueIsNull (col, value, pageRow);
      return;
    }

    /***************************************************************************
     * addSortColumn */
    /**
     * Adds a sort column (column to the ORDER BY portion)
     *
     * @param  col   Column to add
     ***************************************************************************/   
    
    public void addSortColumn (string col)
    {
      _colsSort.add(col);
      return;
    }
        
    public void addSortColumn (string[] cols)
    {
      foreach (string col in cols) _colsSort.add(col);
    }
    
    /***************************************************************************
     * addSortColumnIfValueIsNull */
    /**
     * Adds a sort column (column to the ORDER BY portion) if value is null.
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col     Column to add
     * @param  value   Value to test
     * ***************************************************************************/   
    
    public void addSortColumnIfValueIsNull (string col, Object value)
    {
      if (value == null) _colsSort.add(col);
      return;
    }

    /***************************************************************************
     * addSortColumnIfParmValueIsNull */
    /**
     * Adds a display column (column to the ORDER BY portion) if the parameter
     * referenced by name in parms is null.
     *
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col        Column to add
     * @param  name       Name of parameter in parms
     * @param  parms      SQL parameter collection
     * ***************************************************************************/   
    
    public void addSortColumnIfParmValueIsNull (string col, string name, ref List<SqlParameter> parms)
    {
      Object value = Database.getParameterValue(name,ref parms);
      addSortColumnIfValueIsNull(col, value);
      return;
    }


    /***************************************************************************
     * addPageOrderColumn */
    /**
     * Adds a page row ordering column
     *
     * @param  col   Column to add
     ***************************************************************************/   
    
    public void addPageOrderColumn (string col)
    {
      _pageRowOrder.add(col);
      return;
    }
        
    public void addPageOrderColumn (string[] cols)
    {
      foreach (string col in cols) _pageRowOrder.add(col);
    }
    
    /***************************************************************************
     * addSortColumnIfValueIsNull */
    /**
     * Adds a page row ordering column if value is null.
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col     Column to add
     * @param  value   Value to test
     * ***************************************************************************/   
    
    public void addPageOrderColumnIfValueIsNull (string col, Object value)
    {
      if (value == null) _pageRowOrder.add(col);
      return;
    }

    /***************************************************************************
     * addPageOrderColumnIfParmValueIsNull */
    /**
     * Adds a page row ordering column if the parameter
     * referenced by name in parms is null.
     *
     * This is useful for building queries where you do not want to display
     * a column if you are filtering by a value.
     * 
     * @param  col        Column to add
     * @param  name       Name of parameter in parms
     * @param  parms      SQL parameter collection
     * ***************************************************************************/   
    
    public void addPageOrderColumnIfParmValueIsNull (string col, string name, ref List<SqlParameter> parms)
    {
      Object value = Database.getParameterValue(name,ref parms);
      addPageOrderColumnIfValueIsNull(col, value);
      return;
    }

    /***************************************************************************
     * colsFrom */
    /**
     * Gets or sets the FROM portion of the SQL statement.  Required.
     ***************************************************************************/   
    
    public string colsFrom  {get{return _colsFrom;}  set {_colsFrom = value;}}

    /***************************************************************************
     * colsWhere */
    /**
     * Gets or sets the WHERE portion of the SQL statement.
     ***************************************************************************/   

    public string colsWhere {get{return _colsWhere;} set {_colsWhere = value;}}

    
    /***************************************************************************
     * pageRowOrder */
    /**
     * Returns the page row order (if any)
     *
     * @return string
     ***************************************************************************/   

    public string pageRowOrder()
    {
      return createPageRowOrder();
    }

    /***************************************************************************
     * ToString */
    /**
     * Returns the SQL statement 
     *
     * @return  SQL statement
     ***************************************************************************/   
    
    public override string ToString()
    {
      string ts = createSQLString();
      return ts;
    }

  }
}
