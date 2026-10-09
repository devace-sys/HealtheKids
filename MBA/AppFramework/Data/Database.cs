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
using MBA.IdentifyData;

namespace MBA
{     
  /***************************************************************************
   * DatabaseExtensions */
  /**
   * Extension methods related to database tasks.
   ***************************************************************************/  
  
  public static class DatabaseExtensions
  {
   
    /***************************************************************************
     * ToDataTable */
    /**
     * Extends IEnumerable<T> with a method to return a DataTable.
     *
     * Loosely based on a method courtesey of Christian C. Salvadó 
     * http://stackoverflow.com/questions/523153/how-do-i-transform-a-listt-into-a-dataset/523168#523168
     * 
     ***************************************************************************/  
     
     public static DataTable ToDataTable<T> (this IEnumerable<T> collection)
     {
       DataTable      dt  = new DataTable("DataTable");
       Type           t   = typeof(T);
       
       // Get all of the members
       
       MemberInfo[] mia = t.GetMembers();
       
       // Sort by order of declaration
       
       Array.Sort (mia, new DeclarationOrderComparator());

       // Inspect the members and create the columns in the DataTable

       foreach (MemberInfo mi in mia)
       {
         // We are only interested in properties and fields

         if ((mi.MemberType == MemberTypes.Field) ||(mi.MemberType == MemberTypes.Property))
         {
           
           Type ColumnType;

           // Member is a field

           if (mi.MemberType == MemberTypes.Field)
           {
             FieldInfo fi = t.GetField(mi.Name);
             ColumnType   = fi.FieldType;
           }
           
           // Member is a property

           else
           {
             PropertyInfo pi = t.GetProperty(mi.Name);
             ColumnType = pi.GetType();
           }
           
           if ((ColumnType.IsGenericType))
           {
             ColumnType = ColumnType.GetGenericArguments()[0];
           }
           dt.Columns.Add(mi.Name, ColumnType);         
         }
       }
       
       // Populate the data table

       foreach (T item in collection)
       {
         DataRow dr = dt.NewRow();
         dr.BeginEdit();
         
         // Inspect the members again and create the rows
         
         foreach (MemberInfo mi in mia)
         {
           
           // Again we are only interested in fields and properties

           if ((mi.MemberType == MemberTypes.Field) ||(mi.MemberType == MemberTypes.Property))
           {
             
             // Get value from field

             if (mi.MemberType == MemberTypes.Field)
             {             
               FieldInfo fi = t.GetField(mi.Name);             
               if (fi.GetValue(item) != null)
               {
                 dr[fi.Name] = fi.GetValue(item);
               }
             }

             // Get value from property

             else
             {
               PropertyInfo pi = t.GetProperty(mi.Name);
               if (pi.GetValue(item, null) != null)
               {
                 dr[pi.Name] = pi.GetValue(item, null);
               }
             }           
           }
         }
         dr.EndEdit();
         dt.Rows.Add(dr);
       }
       
       return dt;
     }
  }

  /***************************************************************************
   * Database */
  /**
   * Database access tools for SQL Server
   ***************************************************************************/

  public class Database
  {
        
    public static int ROW_LIMIT_NONE   = 0;
    public static int ROW_LIMIT_TOP    = 1;
    public static int ROW_LIMIT_PAGED  = 3;
    public static int ROW_LIMIT_REPORT = 4;
    
    public static string SQL_PARM_NAME_PAGING_FIRST_ROW = "@firstRow";
    public static string SQL_PARM_NAME_PAGING_LAST_ROW  = "@lastRow";
    public static string SQL_PARM_NAME_PAGING_PAGE_NUM  = "@pageNumber";
    public static string SQL_PARM_NAME_PAGING_PAGE_SIZE = "@pageSize";
    
    public static string SQL_COL_NAME_PAGING_ROW_TOTAL  = "rowTotal";

    /***************************************************************************
     * openConn */
    /**
     * Opens a SQL Server database connection using the provided connection
     * string.
     * 
     * @param  connString      Connection string
     * @return                 SqlConnection
     ***************************************************************************/

    public static SqlConnection openConn(string connString)
    {
      try
      {
        SqlConnection conn = new SqlConnection(connString);
        conn.Open();
        return conn;
      }
      catch (Exception e){throw (e);}
    }
    
    /***************************************************************************
     * connInfo */
    /**
     * Parses but does not open a connection string and returns data about the
     * string in a SqlConnectionStringBuilder instance.
     * 
     * Technique courtesey of Ani
     * http://stackoverflow.com/a/4804099
     * 
     * @param  connString      Connection string
     * @return                 string
     ***************************************************************************/
    
    public static SqlConnectionStringBuilder connInfo (string connString)
    {
      
      SqlConnectionStringBuilder conninfo = null;
      
      try
      {        
        conninfo = new SqlConnectionStringBuilder(connString);       
      }
      catch (Exception e) {throw (e);}
      
      return conninfo;
    }
    
    /***************************************************************************
     * closeConn */
    /**
     * Properly closes a SQL Server connection.
     * Also takes care of rolling back any pending transactions (see link below) 
     * http://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.close.aspx
     * 
     * @param  conn      Sql Server Connection
     ***************************************************************************/

    public static void closeConn(SqlConnection conn)
    { 
      if (conn != null)
        conn.Dispose();
      return;
    }
    
    /***************************************************************************
     * SQLParm */
    /**
     * Creates a SqlParameter
     * 
     * @param  name      Name of parameter
     * @param  type      SqlDBType of parameter
     * @param  value     Incoming value (this should be typed)
     * @param  dir       Direction of the parameter (in, out, in/out)
     * @parm   size      Size of text parameter (-1 for max)
     ***************************************************************************/

    public static SqlParameter SqlParm(string name, SqlDbType type, object value, ParameterDirection dir, int size)
    {

      /*-------------------------------
       * Creates parameter for text 
       * types (hence the need for size)
       * If you do not want to pass a
       * value set it to null
       *------------------------------*/ 
      
      SqlParameter p = new SqlParameter(name,type,size);
     
      if (value == null)
      {
        value = System.DBNull.Value;
        p.IsNullable = true;
      }
      
      p.Value = value;
      p.Direction = dir;
      
      return p;
    } 

    public static SqlParameter SqlParm(string name, SqlDbType type, object value, ParameterDirection dir)
    {

      /*-------------------------------
       * Creates parameter for everything 
       * but text. If you do not want to 
       * pass a value set it to null
       *------------------------------*/ 

      SqlParameter p = new SqlParameter(name, type);
      if (value == null)
      {
        value = System.DBNull.Value;
        p.IsNullable = true;
      }
      p.Value = value;
      p.Direction = dir;

      return p;
    }
    
    /***************************************************************************
     * ListToDataTable<T> */
    /**
     * Creates a System.Data.DataTable of type T from List of type T
     *
     * @param  values       Incoming values of type T
     ***************************************************************************/
    
    public static DataTable ListToDataTable<T> (List<T> values)
    {
      DataTable dt = values.ToDataTable<T>();      
      return dt;
    }
    
    /***************************************************************************
     * SQLParmDataTable */
    /**
     * Creates a SqlParameter that contains a datatable
     * 
     * @param  name         Name of parameter
     * @param  values       Incoming values of type T
     * @param  tbltypename  Table structure type name
     ***************************************************************************/
    
    public static SqlParameter SqlParmDataTable<T> (string name, List<T> values, string tbltypename)
    {

      /*-------------------------------
       * Create data table from values
       *------------------------------*/ 

      DataTable dt = values.ToDataTable<T>();      

      /*-------------------------------
       * Create parameter
       *------------------------------*/ 

      SqlParameter p = new SqlParameter(name, SqlDbType.Structured);
      
      /*-------------------------------
       * Populate and return parameter
       *
       * Note: table valued parameters
       * are input only
       *------------------------------*/ 

      p.Direction = ParameterDirection.Input;
      p.TypeName  = tbltypename;     
      p.Value     = dt;

      return p;

    }

    /***************************************************************************
     * AttributeMatch */
    /**
     * Helper class used by findParameter.
     * Design pattern for predicates with paramters courtesy of Author Unknown 
     * http://www.codeproject.com/KB/cs/predicates.aspx
     * 
     ***************************************************************************/

     protected class AttributeMatch
     {
       public AttributeMatch(string namein) {_name = namein;}

       // Attribute name to match
       
       private string _name;
       public  string name { get { return _name; } set {_name = value; }}
    
       // Gets the predicate.
  
       public Predicate<SqlParameter> Match {get { return IsMatch; }}
       private bool IsMatch (SqlParameter sp){if (sp.ParameterName == _name){return true;}else{return false;}}
     }
    
    /***************************************************************************
     * findParameter */
    /**
     * Finds a given parameter by name in parms
     * 
     * @param  name      Name of parameter.
     * @param  parms     Parameter list to search
     ***************************************************************************/
        
    public static SqlParameter findParameter(string name, ref List<SqlParameter> parms)
    {
      /*-------------------------------  
       * If there is nothing to search
       * get out
       *------------------------------*/ 

      if (Util.IsNullOrEmpty(name))
        return null;
      
      if (parms == null) 
        return null;
      
      if (parms.Count == 0)
        return null;
        
      /*-------------------------------
       * If name does not start with
       * a @ append one.
       *------------------------------*/ 
      
      if (!name.StartsWith("@"))
        name = "@" + name;

      /*-------------------------------
       * Search list for the parameter
       *------------------------------*/ 
              
      SqlParameter sp = parms.Find(new AttributeMatch(name).Match);
      return sp;
    }

    /***************************************************************************
     * getParameterValue */
    /**
     * Finds a given parameter by name in parms and return its value
     * 
     * @param  name      Name of parameter
     * @param  parms     Parameter list to search
     ***************************************************************************/
    
    public static Object getParameterValue (string name, ref List<SqlParameter> parms)
    {
      /*-------------------------------
       * Search list for the parameter
       *------------------------------*/ 

      SqlParameter sp = findParameter(name, ref parms);
      
      /*-------------------------------
       * If nothing came back then 
       * get out.
       *------------------------------*/ 

      if (sp == null) 
        return null;
      
      if (sp.Value is DBNull) 
        return null;  // Handles database null

      /*-------------------------------
       * Otherwise return what was found
       *------------------------------*/ 
      
      return sp.Value;
    }
    
    /***************************************************************************
     * replaceParameterValue */
    /**
     * Finds a given parameter by name in parms and replaces its value with new value
     *  
     * @param  name      Name of parameter.  Name has to be @parmname.
     * @param  newvalue  New value of parameter.
     * @param  parms     Parameter list to search
     * @return           true  = replacement was a success
     *                   false = replacement did not work
     ***************************************************************************/
    
    public static bool replaceParameterValue (string name, Object newvalue, ref List<SqlParameter> parms)
    {
      /*-------------------------------
       * Search list for the parameter
       *------------------------------*/ 
       
      SqlParameter sp = findParameter(name, ref parms);
      
      /*-------------------------------
       * If nothing came back then 
       * get out
       *------------------------------*/ 
      
      if (sp == null)
        return false;
      
      /*-------------------------------
       * Get index of parameter and 
       * replace its value
       *------------------------------*/ 
      
      int idx          = parms.IndexOf(sp);      
      parms[idx].Value = newvalue;
      
      /*-------------------------------
       * Done
       *------------------------------*/ 
      
      return true;

    }
    
    /***************************************************************************
     * convertRecord */
    /**
     * Converts a single record into a one element array of rowtype.
     * 
     * @param   record    incoming record
     * @param   rowtype   desired rowtype
     * @return  Object containing the converted record
     *          (this still must be cast to be used) 
     ***************************************************************************/

    public static Object convertRecord (Record[] record, Type rowtype)
    {
      Object[] r = Database.convertRecords(record,rowtype);
      return r[0];
    }
    
    /***************************************************************************
     * convertRecordsToList */
    /**
     * Converts records into a List<Object> of rowtype
     * 
     * @param   records      incoming records
     * @param   rowtype      desired rowtype
     * @return  List<Object> containing the converted records.  These must be cast
     *                       to be used.
     ***************************************************************************/
    
    public static List<Object> convertRecordsToList (ref Record[] records, Type rowtype)
    {
      /*-------------------------------
       * Create a generic list and 
       * go through each record in 
       * records coverting it to 
       * an object of rowtype
       *------------------------------*/ 
     
      List<Object> newrows = new List<Object>();

      foreach (Record r in records)
      {

        /*-------------------------------
         * Create instance of the desired
         * type (row type)
         *------------------------------*/ 
     
        Object newrow = Activator.CreateInstance(rowtype);

        /*-------------------------------
         * Go through each database 
         * record.field
         *------------------------------*/ 

        foreach (Field f in r.fields)
        {
          
          /*-------------------------------
           * If the field is not null
           *------------------------------*/ 
          
          if (f.typename != "System.DBNull")            
          {            
            
            /*-------------------------------
             * Create an object that holds 
             * f.value
             *------------------------------*/ 
            
            Object[] values = new Object[] { f.value };
            
            /*-----------------------------------------------------------
             * Store that value in our new row
             * If the new row has a data member with the same name as the
             * database field.name it will get passed in.  This allows
             * for us to exclude fields from the result set by removing
             * their definition from the rowtype
             *----------------------------------------------------------*/ 
                          
            MemberInfo[] mi = rowtype.GetMember(f.name);
            if (mi != null)
            {
              if (mi.Length > 0)
              {
                if (mi[0].MemberType == MemberTypes.Field)
                {
                  try 
                  {                                        
                    rowtype.InvokeMember(f.name, BindingFlags.SetField, null, newrow, values);
                  }
                  catch(Exception e)
                  {
                    var errMsg =  @"There is a problem with populating " + f.name + ". " + e.Message;
                    throw new Exception(errMsg,e);
                  }
                }
              }
            }
          }
        }
                  
        /*-------------------------------
         * Add our new row
         *------------------------------*/ 
        
        newrows.Add(newrow);
      
      }
      
      return newrows;      
    
    }
    
    public static Object[] convertRecords(Record[] records, Type rowtype)
    {
      
      List<object> newrows = convertRecordsToList(ref records, rowtype);
      
      /*-------------------------------
       * Return new rows array
       *------------------------------*/ 
        
      return newrows.ToArray();

    }
    
    /***************************************************************************
     * convertParameters */
    /**
     * Extracts parameters from return db and returns in an instance of
     * return type.  This should be called prior to records being extracted
     * 
     * @param   rd           ReturnDB object
     * @param   returnType   Return type
     * @return  object of type returnType 
     ***************************************************************************/

    public static Object convertParameters(ReturnDB rd, Type returnType)
    {

      Object ro = Activator.CreateInstance(returnType);
      
      /*-----------------------------------------------------------
       * If rd contains parameters and the array of parameters is 
       * not empty extract the parameters and store in the return
       * type instance.  If the return type object has a data 
       * method with the same name as the parameter and the 
       * parameter is not null
       *----------------------------------------------------------*/ 

      if (rd.parameters != null)
      {
        if (rd.parameters.Length > 0)
        {
          foreach (Parameter p in rd.parameters)
          {        
            if (p.typename != "System.DBNull")
            {
              MemberInfo[] mi = returnType.GetMember(p.name);
              if (mi != null)
              {
                if (mi.Length != 0)
                {
                  Object[] values = new Object[] { p.value };
                  returnType.InvokeMember(p.name,BindingFlags.SetField,null,ro,values);
                }
              }
            }
          }
        }
      }
      return ro;
    }

    public delegate void RecordStructure     (ref Object rs, int numRecs);   
    public delegate void RecordConvert       (ref Object rs, int recNum, Object r);   
    public delegate void RecordConvertSingle (ref Object rs, Object r);
    
    /***************************************************************************
     * convertReturnDBToReturnInfoTable */
    /**
     * Converts the contents of rd to a ReturnInfoTable
     * 
     * @param   rd           ReturnDB object
     * @return  object of type ReturnInfoTable
     ***************************************************************************/
     
    public static ReturnInfoTable convertReturnDBToReturnInfoTable(ref ReturnDB rd)
    {
      ReturnInfoTable so = new ReturnInfoTable();            
      so.hasRecords      = rd.hasRecords;
      
      int numRows = 0;
      int numCols = 0;
      int i       = 0;
            
      /*-------------------------------
       * If there are no records
       * go ahead and get out
       *------------------------------*/ 
      
      if (!rd.hasRecords)
      {
        so.numCols = 0;
        so.numRows = 0;
        return so;      
      }     
      
      /*-------------------------------
       * Go through each row
       *------------------------------*/ 
      
      foreach (Record r in rd.records)
      { 
            
        /*-------------------------------
         * If this is the very first row
         * get the row count, column count,
         * and setup column data
         *------------------------------*/ 
        
        if (numRows == 0)
        {

          /*-------------------------------
           * Extract row and column counts
           * from rd
           * We will only need to do this once
           *------------------------------*/ 
          
          numRows    = rd.records.Length;           
          numCols    = r.fields.Length;             
          so.numCols = numCols;
          so.numRows = numRows;      

          /*-------------------------------
           * Setup the data table structures
           * for rows and columns
           *------------------------------*/ 
          
          so.colnames  = new string[numCols];       // Setup column array
          so.rowvalues = new RowValues[numRows];    // Setup row array
                    
          /*-------------------------------
           * Extract column names from 
           * rd.fields
           *------------------------------*/ 

          int k = 0; // Temp column count

          foreach (Field f in r.fields)
          {
            so.colnames[k] = f.name;                        
            k++;
          }
                                   
        } // End of init
       

      /*-------------------------------
       * Go through each column in the
       * given row and extract values
       *------------------------------*/ 

       int      j   = 0;       
       string[] row = new string[numCols];
              
       foreach (Field f in r.fields)
       {
         string value = f.value.ToString();         
         row[j] = value;
         j++;
       }
       
       RowValues rowvalue = new RowValues();
       rowvalue.values = row;
       
       so.rowvalues[i] = rowvalue;
              
       i++;        
      }

     /*-------------------------------
      * Return data
      *------------------------------*/                               
      
      return so;
    }
    
    /***************************************************************************
     * convertReturnDBToReturnDataTable*/
    /**
     * Converts ReturnDB into DataTableData for record display or report
     * generation.
     * 
     * TODO: Transfer some of this logic to the ReturnDataTable class itself
     * 
     * @param   rd           ReturnDB object
     * @returns              DataTableData
     ***************************************************************************/

    public static ReturnDataTable convertReturnDBToReturnDataTable (ref ReturnDB rd)
    {
      ReturnDataTable so = new ReturnDataTable();
            
      so.hasRecords  = rd.hasRecords;
      
      int numRows        = 0;
      int numCols        = 0;
      int i              = 0;
      int numVisibleCols = 0;
         
      /*-------------------------------
       * If there are no records
       * go ahead and get out
       *------------------------------*/ 
      
      if (!rd.hasRecords)
        return so;

      /*-------------------------------
       * Regex def (with backref)
       * for column title replacement
       *------------------------------*/

      
      /* Original (now deprecated) 
       * matching :  cn(_col_label)
       * queried from db as : [cn(_col_label)]  
       */
      
      // @"^c(\d){1,}\(_col_label\)$"

      Regex colTitleReplacementSentinel1 = new Regex(@"^c(?<lblidx>\d{1,})\(_col_label\)$");
      
      /* Class field name friendly variant
       * matching : _cn_col_label
       * queried from db as : _cn_col_label
       */   
      
      // @"^_c(\d){1,}_col_label$" 

      Regex colTitleReplacementSentinel2 = new Regex(@"^_c(?<lblidx>\d{1,})_col_label$");

      /*-------------------------------
       * Go through each row
       *------------------------------*/ 
      
      foreach (Record r in rd.records)
      { 
            
        /*-------------------------------
         * If this is the very first row
         * get the row count, column count,
         * and setup column data
         *------------------------------*/ 
        
        if (numRows == 0)
        {

          /*-------------------------------
           * Extract row and column counts
           * from rd
           * We will only need to do this once
           *------------------------------*/ 
          
          numRows = rd.records.Length;           
          numCols = r.fields.Length;             
         
          /*-------------------------------
           * Setup the data table structures
           * for rows and columns
           *------------------------------*/ 
          
          so.aoColumns  = new aoColumn      [numCols];  // Setup column array
          so.aaData     = new Object        [numRows];  // Setup data array.  This will be an array of object[,]  
          so.iRecordPageSize = Rules.VIEW_TBL_PAGE_SIZE;

          //so.aaMetaData            = new aoRowMetaData [numRows];
          
          int k = 0; // Temp column count
          
          /*-------------------------------
           * Extract column data from rd.fields
           * We will only need to do this once
           * 
           * Note: If the database returns
           * a string value of an object
           * it will be considered a string.
           *------------------------------*/ 

          foreach (Field f in r.fields)
          {
            so.aoColumns[k] = new aoColumn();
            
            so.aoColumns[k].sTitle = f.name; // Column name
            
            bool   sortable                 = false;
            bool   visible                  = true;
            bool   colTitleReplacement      = false;
            string colTitleToReplace        = "";
            string colTitleReplacementValue = "";

            // Get total num of recs and also detect if records are paged

            if (f.name == SQL_COL_NAME_PAGING_ROW_TOTAL)
            {
              
              // For some reason casting an Int32 to Int64 causes an exception.  This takes care of it.

              if (f.typename == "System.Int32") 
                so.iTotalRecords = (int) f.value;
              else 
                so.iTotalRecords = (long) f.value;
              
              so.iTotalDisplayRecords = so.iTotalRecords;
              so.recordsPaged         = true;
            }

            // If column is predefined as a hidden column, hide it

            switch (f.name)
            {
              case "id":
              case "rowNum":
              case "rowTotal":  /* TODO: Refactor this switch into a collection type test.  This literal is in a constant value now but we can't use a constant in a switch*/
              case "rowOrder":
              case "pageNum":

              case "referenceID1":
              case "referenceID2":
              case "referenceID3":
              case "referenceID4":

             {
                visible = false;
                sortable = false;
                break;
              }
              default:
              {
                visible  = true;
                sortable = false;
                colTitleReplacement      = false;
                colTitleToReplace        = "";
                colTitleReplacementValue = "";
                break;
              }
            }
            
            // Columm is predefined as a label replacement - Pass 1
            // The first row value of cn(_col_label) or _cn_col_label will replace the column title for cn where n is an integer between 0 and 100.  
            // For example the first row value of c4(_col_label) will replace the column title for c4
                                                                         
            Match ctm1 = colTitleReplacementSentinel1.Match(f.name);
            Match ctm2 = colTitleReplacementSentinel2.Match(f.name);

            if ((ctm1.Success == true) || (ctm2.Success == true))
            {                                                                              
              visible                  = false;
              sortable                 = false;
              colTitleReplacement      = true;              
              if      (ctm1.Success) colTitleToReplace = @"c" + ctm1.Groups[@"lblidx"];
              else if (ctm2.Success) colTitleToReplace = @"c" + ctm2.Groups[@"lblidx"];             
              colTitleReplacementValue = f.value.ToString();
            }
            
            so.aoColumns[k].bSortable                = sortable;
            so.aoColumns[k].bVisible                 = visible;
            so.aoColumns[k].bSearchable              = false;
            so.aoColumns[k].colTitleReplacement      = colTitleReplacement;
            so.aoColumns[k].colTitleToReplace        = colTitleToReplace;
            so.aoColumns[k].colTitleReplacementValue = colTitleReplacementValue;

            if (visible)
            {
                numVisibleCols++;
            }
            
            string stype  = "string";             // Client side data type
            string sclass = "dt-string";          // Client side css class
                        
            // Based on identified value set our data type classes
            
            IdentifiedValue           iv        = IdentifiedValue.Parse(f.value);
            IdentifiedValue.DataClass dataclass = iv.dataClass;
            IdentifiedValue.DataType  datatype  = iv.dataType;
            
            switch (dataclass)
            {
              case IdentifiedValue.DataClass.DATE:
              {
                stype  = "date";
                sclass = "dt-date";
                
                break;
              }
              case IdentifiedValue.DataClass.BOOL:
              {
                stype  = "string";
                sclass = "dt-bool";
                break;
              }
              case IdentifiedValue.DataClass.NUMBER:
              {
                stype  = "numeric";
                sclass = "dt-numeric";
                break;
              }             
              case IdentifiedValue.DataClass.TEXT:
              default:
              {                
                stype  = "string";
                sclass = "dt-string";
                break;
              }
            
            }

            so.aoColumns[k].sType     = stype;
            so.aoColumns[k].sClass    = sclass;                      
            so.aoColumns[k].dataclass = dataclass;
            so.aoColumns[k].datatype  = datatype;
            
            // TODO: Specify additional options as desired
            
            k++;
          }
          
          so.numVisibleCols = numVisibleCols;
          
          // If the query did not return a row count in one of its columns
          // use our internal value

          if (so.iTotalRecords == 0)
          {
            so.iTotalRecords        = numRows;
            so.iTotalDisplayRecords = so.iTotalRecords;
            so.recordsPaged         = false;
            so.iTotalWidth = 0;
          }
                    
        } // End of init


        // Columm is predefined as a label replacement - Pass 2

        foreach (aoColumn col in so.aoColumns)
        {
          if (col.colTitleReplacement == true)
          {
              int ctridx =  so.FindColumnIndexByTitle(col.colTitleToReplace);
              if (ctridx != -1)
              {
                so.aoColumns[ctridx].sTitle = col.colTitleReplacementValue;
                
                /* If the replacement title is blank then this column is not used so hide it */

                if (String.IsNullOrWhiteSpace(so.aoColumns[ctridx].sTitle))
                {
                  so.aoColumns[ctridx].bVisible  = false;          
                  so.aoColumns[ctridx].bSortable = false;                                          
                }
              }
          }
        }

       // Go through each column for the given row (r)
       
       int j = 0;
       Object                  [] aoRow       = new Object          [numCols];

       foreach (Field f in r.fields)
       {
         Object            fvalue  = f.value;
         IdentifiedValue   iv      = IdentifiedValue.Parse(fvalue);
                           
         // Convert any data that needs to be converted for display purposes
         
         switch (f.typename)
         {
           case "System.DateTime":
           {
             fvalue = Convert.ToDateTime(f.value).ToShortDateString();
             break;
           }
           default:
           {
             fvalue = f.value;
             break;
           }
         }
         
         aoRow [j] = fvalue;
         j++;
       }
       
       so.aaData [i] = aoRow;
       
       i++;        
      
      }
      
     /*-------------------------------
      * Determine widths
      *------------------------------*/ 
      
      int colIdx = 0;
      int tempTotalWidth = 0;

     /*-------------------------------
      * Go through columns
      *------------------------------*/ 
      
      foreach (aoColumn c in so.aoColumns)
      {
       
        /*-------------------------------
         * Compute length of title
         * this will be our default
         * length
         *------------------------------*/ 

        int tempTitleLen = 0;
        int tempWidth = tempTitleLen;

        /*-------------------------------
         * For each visible column
         *------------------------------*/ 
        
        if (c.bVisible)
        { 
          if (!Util.IsNullOrEmpty(so.aoColumns[colIdx].sTitle)) tempTitleLen = so.aoColumns[colIdx].sTitle.Length;
          
          /*-------------------------------
           * Get the number of rows
           *------------------------------*/
          
          int tempLen = so.aaData.Length;
          
          /*-------------------------------
           * Get the length of the row
           * value for this given column
           * and store it in a hash table
           *------------------------------*/
          
          Hashtable tempCol = new Hashtable();
          
          foreach (Object[] o in so.aaData)
          {
            Object ov = o[colIdx];
            string tempField = "";
            if (ov.GetType() != typeof(DBNull)) tempField = Convert.ToString(ov);
            int tempFieldLen = 0;
            if (!Util.IsNullOrEmpty(tempField))  tempFieldLen = tempField.Length;
            if (!tempCol.Contains(tempFieldLen)) tempCol.Add(tempFieldLen,tempFieldLen);
          }
          
          int numVals    = tempCol.Count;
          int tempNumRow = 0;
          int tempMaxLen = 0;

         /*-------------------------------
          * If we have any values lets 
          * find the max
          *------------------------------*/

          if (numVals > 0)
          {
            
            /*-------------------------------
             * Create an array list to hold our
             * values and transfer the values
             *------------------------------*/            
            
            List<int> tempColVal = new List<int>(numVals);

            foreach (Object tv in tempCol.Values)
            {
              tempColVal.Add((int)tv);
            }
            
            /*-------------------------------
             * Sort the array list
             *------------------------------*/

            tempColVal.Sort();

            /*-------------------------------
            * The last value in our list
            * will be the max
            *------------------------------*/

            tempNumRow = tempColVal.Count - 1;
            tempMaxLen = tempColVal[tempNumRow];
          }
          
          if (tempTitleLen < tempMaxLen)
            tempWidth = tempMaxLen + 1;
          else 
            tempWidth = tempTitleLen;
        }
        
        if (tempWidth > 0) tempWidth = (tempWidth * 12); /* Generic em to px conversion*/
        tempTotalWidth = tempTotalWidth + tempWidth;
        so.aoColumns[colIdx].sWidth = tempWidth.ToString() + @"px";
        so.aoColumns[colIdx].iWidth = tempWidth;
        colIdx++;
      }
      
      so.iTotalWidth = tempTotalWidth;

      return so;
    }

    /***************************************************************************
     * convertReturnDBToReturnNamesValues */
    /**
     * Converts ReturnDB into ReturnNamesValues for option selection.
     * 
     * @param   rd           ReturnDB object
     * @returns              ReturnNamesValues
     ***************************************************************************/

    public static ReturnNamesValues convertReturnDBToReturnNamesValues (ref ReturnDB rd)
    {
      ReturnNamesValues so = new ReturnNamesValues();

      so = (ReturnNamesValues) Database.convertReturnDBToParmMultiRecord(
        ref rd,
        typeof(ReturnNamesValues),
        typeof(NameValue),
        delegate(ref Object rs, int i)           {ReturnNamesValues rso = (ReturnNamesValues) rs; rso.NamesValues = new NameValue[i];},
        delegate(ref Object rs, int i, Object r) {ReturnNamesValues rso = (ReturnNamesValues) rs; rso.NamesValues[i] = (NameValue) r;});

      return so;
    }
    
   /***************************************************************************
    * convertReturnDBToReturnSel */
    /**
    * Converts ReturnDB into ReturnSel for option selection.
    * 
    * @param   rd           ReturnDB object
    * @returns              ReturnSel
    ***************************************************************************/

    public static ReturnSel convertReturnDBToReturnSel (ref ReturnDB rd)
    {
      ReturnSel so = new ReturnSel();

      so = (ReturnSel) Database.convertReturnDBToParmMultiRecord(
        ref rd,
        typeof(ReturnSel),
        typeof(SelRec),
        delegate(ref Object rs, int i)           {ReturnSel rso = (ReturnSel) rs; rso.SelRecs = new SelRec[i];},
        delegate(ref Object rs, int i, Object r) {ReturnSel rso = (ReturnSel) rs; rso.SelRecs[i] = (SelRec) r;});

      return so;
    }
    
   /***************************************************************************
    * convertReturnDBToReturnSelection */
    /**
    * Converts ReturnDB into ReturnSelections for option selection.
    * 
    * @param   rd           ReturnDB object
    * @returns              ReturnSelection
    ***************************************************************************/

    public static ReturnSelections convertReturnDBToReturnSelections (ref ReturnDB rd)
    {
      ReturnSelections so = new ReturnSelections();

      so = (ReturnSelections) Database.convertReturnDBToParmMultiRecord(
        ref rd,
        typeof(ReturnSelections),
        typeof(Selection),
        delegate(ref Object rs, int i)           {ReturnSelections rso = (ReturnSelections) rs; rso.Selections = new Selection[i];},
        delegate(ref Object rs, int i, Object r) {ReturnSelections rso = (ReturnSelections) rs; rso.Selections[i] = (Selection) r;});

      return so;
    }
    
    /***************************************************************************
     * convertReturnDBToParmsSingleRecord*/
    /**
     * Extracts paramters and records from return db and returns in an instance of
     * return type.  Since returnDB is expected to only contain one record this
     * record is stored in a data method of type RecordType.
     *
     * Please Note:
     * 
     * Each delegate must create a copy by reference of rs and cast it as the desired
     * return type.  This copy of rs is then used to perform instance specific work.
     *
     * Sample Call
     * 
     * ReturnDB rd = Database.execQuery(connMBA,sql,false,parms);
     * return (ReturnPatient) Database.convertReturnDBToParmSingleRecord
     *                        (ref rd,
     *                        typeof(ReturnPatient),
     *                        typeof(Patient),
     *                        delegate(ref Object rs, int i)
     *                          {ReturnPatient rso = (ReturnPatient) rs; rso.patient = new Patient();},
     *                        delegate(ref Object rs, Object r)
     *                          {ReturnPatient rso = (ReturnPatient) rs; rso.patient = (Patient) r;});            
     * 
     * @param   rd           ReturnDB object
     * @param   returnType   Return type
     * @param   recordType   Record type
     * @param   ri           Delegate for record structure instance
     * @param   rcs          Delegate for single record conversion to data method 
     * @return  object of type returnType 
     ***************************************************************************/
    
    public static Object convertReturnDBToParmSingleRecord (ref ReturnDB rd, Type returnType, Type recordType, RecordStructure ri, RecordConvertSingle rcs)
    {
      return convertReturnDBToObject(ref rd, returnType, recordType, ri, null,true,rcs);
    }

    /***************************************************************************
     * convertReturnDBToParmsMultiRecord*/
    /**
     * Extracts paramters and records from return db and returns in an instance of
     * return type.  Since returnDB is expected to contain multiple records the records
     * are stored in a array of recordType.  
     *
     * Please Note:
     * 
     * Each delegate must create a copy by reference of rs and cast it as the desired
     * return type.  This copy of rs is then used to perform instance specific work.
     * 
     * Sample Call
     * 
     * ReturnDB rd = view(connMBA,Constants.PROC_ENT_TYPE_PRAC,pracID,Constants.PROC_REC_TYPE_NONE,0,plan);
     * return (ReturnProceduresSimple) Database.convertReturnDBToParmMultiRecord
     *                                 (ref rd,
     *                                  typeof(ReturnProceduresSimple),
     *                                  typeof(ProcedureSimple),
     *                                  delegate(ref Object rs, int i)
     *                                    {ReturnProceduresSimple rso = (ReturnProceduresSimple) rs; rso.ProceduresSimple = new ProcedureSimple[i];},
     *                                  delegate(ref Object rs, int i, Object r)
     *                                   {ReturnProceduresSimple rso = (ReturnProceduresSimple) rs; rso.ProceduresSimple[i] = (ProcedureSimple) r;});
     * @param   rd           ReturnDB object
     * @param   returnType   Return type
     * @param   recordType   Record type
     * @param   ri           Delegate for record structure instance
     * @param   rc           Delegate for record conversion to array element
     * @return  object of type returnType 
     ***************************************************************************/

    public static Object convertReturnDBToParmMultiRecord (ref ReturnDB rd, Type returnType, Type recordType, RecordStructure ri, RecordConvert rc)
    {
      return convertReturnDBToObject(ref rd, returnType, recordType,ri,rc,false,null);
    }

    /***************************************************************************
     * convertRecordsAndParameters */
    /**
     * Extracts everything from return db and returns in an instance of
     * return type.
     * 
     * @param   rd           ReturnDB object
     * @param   returnType   Return type
     * @param   recordType   Record type
     * @param   ri           Delegate for record structure instance
     * @param   rc           Delagate for record conversion 
     * @param   singleRecord If only one record is returned dont send back an 
     *                       array but just create a single instance of ReturnType
     * @param   rcs          Delegate for single record conversion to data method 
     * @return  object of type returnType 
     ***************************************************************************/

    protected static Object convertReturnDBToObject(ref ReturnDB        rd, 
                                                    Type                returnType, 
                                                    Type                recordType, 
                                                    RecordStructure     ri, 
                                                    RecordConvert       rc, 
                                                    bool                singleRecord, 
                                                    RecordConvertSingle rcs)
    { 
     
     /*-------------------------------
     * Create instance of return type
     *------------------------------*/ 
     
     Object so = Activator.CreateInstance(returnType);

     /*---------------------------------------
     * If rd contains any parameters search
     * for like named fields in our return type
     * (returnType) and populate the fields in 
     * so (instance of returnType) with the
     * parameter values.  For example if rd
     * contains a parameter called recordID and
     * returnType contains a field called recordID
     * and the parameter and field are matching
     * data types so.recordID will be populated
     * with the value of parameter recordID. 
     *----------------------------------------*/ 
      
      if (rd.parameters != null){                               // rd.parameter array is not null
        if (rd.parameters.Length > 0){                          // or an empty array
          foreach (Parameter p in rd.parameters){               // Go through each parameter        
            if (p.typename != "System.DBNull"){                 // and as long as the parameter is not null
              MemberInfo[] mi = returnType.GetMember(p.name);   // Search for a coresponding field in the return type
              if (mi != null){                                  
                if (mi.Length != 0){                                                       
                  if (mi[0].MemberType == MemberTypes.Field){   // If one is found that is not a not a method
                    Object[] values = new Object[] { p.value }; // Populate it
                    returnType.InvokeMember
                     (p.name,BindingFlags.SetField,null,so,values);
                  }
                }
              }
            }
          }
        }
      }
           
      /*---------------------------------------
      * At this point if rd contained any 
      * parameters they are now stored in so
      * Now we look for records......
      * If rd contains any records search
      * for like named fields in our record
      * type (recordType)and populate the 
      * fields with coresponding record values.
      *----------------------------------------*/ 

      if (rd.records != null){                                   // rd.record array is is not null  
        if (rd.records.Length >0){                               // or empty
          List<object> newrows = new List<object>();             // Create a generic list to temp hold recs
          foreach (Record r in rd.records){                      // Go through each database record            
            Object newrow = 
              Activator.CreateInstance(recordType);              // Create an instance of our recordType
            foreach (Field f in r.fields){                       // Go through each database record.field
              if (f.typename != "System.DBNull"){                // As long as the field is not null
                MemberInfo[] mi = recordType.GetMember(f.name);  // Search for a coresponding field in recordType
                if (mi != null){
                  if (mi.Length > 0){
                    if (mi[0].MemberType == MemberTypes.Field){     // If one is found that is not a method
                        Object[] values = new Object[] { f.value }; // Populate it
                        recordType.InvokeMember
                          (f.name, BindingFlags.SetField, null, newrow, values);
                    }
                  }
                }
              }  
            }
            newrows.Add(newrow);                                    // Add our new row to our temp list
          }   
          
         /*---------------------------------------
         * Now we need to convert everything
         * to the specific types we need.  We do 
         * this through delegates and passing 
         * our structures as references
         *----------------------------------------*/ 

         Object[] recs = newrows.ToArray();        // Generate an array from our generic list
         
         if (!singleRecord)
         {
           ri(ref so,recs.Length);                 // Pass control to record structure instantiate delegate
           for (int i=0;i<recs.Length;i++)
           {
             Object rec = recs[i];                 // Create the appropriate sized array            
             rc(ref so,i,rec);                     // Pass control to record convert delegate
           }
         }
         else
         {
           // Single record case
           Object rec = recs[0];
           rcs(ref so,rec);                 
         }
        }
       }  
       return so;
    }

    /***************************************************************************
     * extractParameters */
    /**
     * Extracts parameters from a SQLParameter collection into a less complex 
     * array.  Also examines the parameter list and sets flags for
     * later processing.
     * 
     * @param   parms        incoming parameters
     * @param   si           ReturnDB instance from execSQL, etc 
     * @return  so           ReturnDB si with parameters populated  
     ***************************************************************************/

    protected static ReturnDB extractParameters(SqlParameterCollection parms, ref ReturnDB si, ref DetailsLog log)
    {
      ReturnDB so = si;
            
      Parameter[] po = new Parameter[parms.Count];
      int i=0;
      so.hasSpDetails   = false;
      so.hasOutputParms = false;
      foreach (SqlParameter p in parms)
      {
        po[i]           = new Parameter();
        po[i].name      = p.ParameterName.Replace("@","");
        po[i].typename  = p.DbType.ToString();
        po[i].value     = p.Value;
        po[i].direction = p.Direction.ToString().ToLower();
        if (po[i].direction == "output") so.hasOutputParms  = true;
        if (po[i].name      == "spDetails")
        {
          log.addDetails((string) po[i].value);
        }
        i++;
      }
      so.parameters = po;
      return so;
     }

    /***************************************************************************
     * execScalar */
    /**
     * Executes sql that returns a single scalar value.
     * 
     * If you need to execute a stored procedure that returns a result set
     * use execQuery.
     * 
     * @param   conn         SQL Connection
     * @param   sql          SQL test ie select dbo.RPT_DATE_FMT(@testDate) or select getdate()
     * @param   parms        SQL parameter list 
     * @parm    returnValue  value returned as object.  You must convert to use.
     * @return  true if sucessful call, false if not
     ***************************************************************************/
    
     public static bool execScalar (SqlConnection conn, string sql, List<SqlParameter> parms, out Object returnValue)
     {

      returnValue = null;
      SqlCommand cmd = null;
      
      try
      {
        
        /*---------------------------------------
         * Setup command
         *--------------------------------------*/ 
        
        cmd                = new SqlCommand(sql, conn);       // Pass in sql that calls fn
        cmd.CommandTimeout = Rules.DB_CMD_TIMEOUT;            // Set timeout        
        cmd.CommandType    = CommandType.Text;                // Indicate commmand is sql text
        
        /*---------------------------------------
         * Pass in parameters (if any) 
         *--------------------------------------*/ 
                
        if (parms != null)
          foreach (SqlParameter parm in parms)
            cmd.Parameters.Add(parm);
                
        /*---------------------------------------
         * Execute database command and return
         * value
         *--------------------------------------*/ 

        returnValue = cmd.ExecuteScalar();
        return true;

        
      }
      catch(Exception e)
      {
        returnValue = null;
        return false;
      }
      finally
      {
        
        /*---------------------------------------
         * Cleanup tasks
         *----------------------------------------*/ 
         
        if (cmd != null)
        {
          cmd.Parameters.Clear();  // Subsequent calls were causing an issue with parameters... this is the fix (http://blog.benhall.me.uk/2007/04/sqlparameter-is-already-contained-by.html)
          cmd.Dispose();
        }
      }

    }
   
    /***************************************************************************
     * execSproc */
    /**
     * Executes stored procedure that DOES NOT return a result set.
     * 
     * If you need to execute a stored procedure that returns a result set
     * use execQuery.
     * 
     * @param   conn         SQL Connection
     * @param   spname       Stored procedure name
     * @param   parms        SQL parameter list 
     * @param   tx           SQL transaction
     * @return  ReturnDB 
     ***************************************************************************/

    public static ReturnDB execSproc(SqlConnection conn, DetailsLog log, string spname)                          {return execSproc (conn, log, spname, null,  null) ;}
    public static ReturnDB execSproc(SqlConnection conn, DetailsLog log, string spname, List<SqlParameter> parms){return execSproc (conn, log, spname, parms, null);}
    public static ReturnDB execSproc(SqlConnection conn, DetailsLog log, string spname, List<SqlParameter> parms, SqlTransaction tx)
    {

      /*--------------------------------------
       * Get cancellation token (if it exists)
       * Note: Currently only supported for
       * web requests.
       * TODO: Uncomment out if we can make this 
       * work properly with stored procedures 
       * that have transactions       
       *--------------------------------------*/ 
      
       //bool hasCancellationToken = false;
       //System.Threading.CancellationToken cancellationToken;
     
       //try 
       //{ 
       //  var rd = MBA.HttpApplication.retrieveRequestResponse();
       //  cancellationToken = rd.cancellationToken;
       //  hasCancellationToken = true;
       //}
       //catch
       //{
       //   hasCancellationToken = false;
       //}
      
      SqlCommand cmd = null;
      
      try
      {
        
        /*---------------------------------------
         * Setup our return class
         *--------------------------------------*/ 

        ReturnDB so   = new ReturnDB();
        so.hasRecords = false;                                   // There are no records expected
        so.records    = null;
        so.rowLimit   = ROW_LIMIT_NONE;

        /*---------------------------------------
         * Workaround for parameter sniffing
         * 
         * Note: This costs us one extra trip
         * to the server per stored procedure call
         * but its worth it.
         * 
         * See: 
         * http://dba.stackexchange.com/a/2503
         *----------------------------------------*/ 
        
        SqlCommand arithabortCmd  = new SqlCommand("SET ARITHABORT ON", conn);
        arithabortCmd.CommandType = CommandType.Text;
        arithabortCmd.ExecuteNonQuery(); 
        
        /*---------------------------------------
         * Setup command
         *--------------------------------------*/ 
        
        cmd                = new SqlCommand(spname, conn);       // Pass in stored procedure name        
        cmd.CommandTimeout = Rules.DB_CMD_TIMEOUT;               // Set timeout        
        cmd.CommandType    = CommandType.StoredProcedure;        // Indicate commmand is a stored procedure
        if (tx != null) cmd.Transaction = tx;                    // Indicate this is part of a transaction if neccessary     
        
        /*---------------------------------------
         * Pass in parameters (if any) 
         *--------------------------------------*/ 
                
        if (parms != null)
          foreach (SqlParameter parm in parms)
            cmd.Parameters.Add(parm);

        /*---------------------------------------
         * Wire up command cancel 
         * Note: Currently only setup for 
         * web requests.
         * 
         * TODO: Uncomment out if we can make this 
         * work properly with stored procedures 
         * that have transactions
         *--------------------------------------*/ 
       
        //if (hasCancellationToken == true)
        //{
        //    /* Setup delegate to cancel db Command if the request is cancelled */            
        //    Action actionCancelCmd = delegate () { cmd.Cancel();};             
        //    cancellationToken.Register( actionCancelCmd);                   
        //}
                
        /*---------------------------------------
         * Execute database command
         *--------------------------------------*/ 

        cmd.ExecuteNonQuery();
        
        /*---------------------------------------
         * Extract any return parameters
         *--------------------------------------*/ 
        
        so.commandText = cmd.CommandText;
        so.commandType = cmd.CommandType;
        so             = extractParameters (cmd.Parameters,ref so,ref log);
                        
        
        /*---------------------------------------
         * Return results
         *--------------------------------------*/ 

        return so;
      }
      catch(SqlException e)
      {
        
        /*---------------------------------------
         * Catch and convert the following SQL
         * exceptions: 
         * 
         *   - Deadlock  
         *   - Timeout
         *   - Session Expired
         *   - Password lock
         * 
         * Pass all other execeptions along
         *----------------------------------------*/ 

        if (e.Number == 1205)
        {
                  
          /*---------------------------------------
           * Deadlock
           *---------------------------------------*/ 
  
          throw new Critical(Messages.DB_DEADLOCK);
        }
        else if (e.Number == -2)
        {
          /*---------------------------------------
           * Time out
           *----------------------------------------*/ 

          throw new Critical(Messages.DB_TIME_OUT);
        }
        else
        {
          
          /*---------------------------------------
           * Session expired, password lock, or
           * other
           *----------------------------------------*/ 
          
          int cd = e.Class;
          
          if (cd == Return.RET_SESSION_EXPIRE)
            throw new SessionExpired(e.Message);
          else if (cd == Return.RET_PASSWORD_LOCK)
            throw new PasswordLock(e.Message);
          else if (cd == Return.RET_SUBSCRIPTION_REQUIRED)
            throw new SubscriptionRequired(e.Message);
          else 
            throw e;
        }
      }
      finally
      {
        
        /*---------------------------------------
         * Cleanup tasks
         *----------------------------------------*/ 
         
        if (cmd != null)
        {
          cmd.Parameters.Clear();  // Subsequent calls were causing an issue with parameters... this is the fix (http://blog.benhall.me.uk/2007/04/sqlparameter-is-already-contained-by.html)
          cmd.Dispose();
        }
      }

    }
    
    /***************************************************************************
     * execQuery */
    /**
     * Executes a static query
     * 
     * @param   conn         SQL Connection
     * @param   sql          SQL or stored procedure name
     * @param   sp           True if sql is a stored procedure name 
     * @param   parms        SQL parameter list 
     * @param   tx           SQL transaction
     * @param   rowLimit     Limits the # of rows returned
     *                       0 = No limit
     *                       1 = Top x rows (x = page size)
     *                       2 = Progressive top (not yet implemented)
     *                       3 = Paged 
     * @param   pageSize     Size of page
     * @param   pageNum      What page to return
     * @return  ReturnDB 
     ***************************************************************************/

    public static ReturnDB execQuery(SqlConnection conn, DetailsLog log, string sql)                                                       {return execQuery (conn, log, sql, false, null,  null);}
    public static ReturnDB execQuery(SqlConnection conn, DetailsLog log, string sql, bool sp)                                              {return execQuery (conn, log, sql, sp,    null,  null);}
    public static ReturnDB execQuery(SqlConnection conn, DetailsLog log, string sql, bool sp, List<SqlParameter> parms)                    {return execQuery (conn, log, sql, sp,    parms, null);}
    public static ReturnDB execQuery(SqlConnection conn, DetailsLog log, string sql, bool sp, List<SqlParameter> parms, SqlTransaction tx) {return execQuery (conn, log, sql, sp,    parms, tx, ROW_LIMIT_NONE, 0, 0, "");}       
    public static ReturnDB execQuery(SqlConnection conn, DetailsLog log, string sql, bool sp, List<SqlParameter> parms, SqlTransaction tx, int rowlimit, int pagesize, int pagenumber, string pageroworder)
    {
       
      /*--------------------------------------
       * Get cancellation token (if it exists)
       * Note: Currently only supported for
       * web requests.
       *--------------------------------------*/ 
      
       bool hasCancellationToken = false;
       System.Threading.CancellationToken cancellationToken;

       if (HttpContext.Current is null)
       {
           hasCancellationToken = false;
       }
       else
       { 
         try 
         { 
           var rd = MBA.HttpApplication.retrieveRequestResponse();
           cancellationToken = rd.cancellationToken;
           hasCancellationToken = true;
         }
         catch
         {
            hasCancellationToken = false;
         }
       }
       SqlCommand cmd = null;
      
      try
      {
        
        /*--------------------------------------
         * Setup our return class
         *--------------------------------------*/ 
      
        ReturnDB so = new ReturnDB();
        
        /*---------------------------------------
         * Apply row limits (queries only)
         *--------------------------------------*/ 

        so.rowLimit = rowlimit;

        if (!sp)
        {

          /*---------------------------------------
           * Top <pagesize>
           *--------------------------------------*/ 
          
          if (rowlimit == ROW_LIMIT_TOP)
          {
            
            /*---------------------------------------
             * See if supplied sql already has a top
             * keywork after the first select keyword
             *--------------------------------------*/        
            
            string topPat = @"^select\s{1,}top";
            string selPat = @"^select\s{1,}";

            bool hasTop   = Regex.IsMatch(sql,topPat,RegexOptions.IgnoreCase);
            string topKw  = "select top " + pagesize.ToString() + " ";
            
            /*---------------------------------------
             * If the start of the sql is "top free"
             * add a top keyword right after select
             *--------------------------------------*/        

            if (!hasTop)
            {
              string newSql = Regex.Replace(sql,selPat,topKw,RegexOptions.IgnoreCase);
              sql = newSql;
            }

            /*---------------------------------------
             * Otherwise wrap it in a top select
             *--------------------------------------*/        

            else
            {
              sql = topKw + "* from (" + sql + ") as q1";           
            }

          }
          
          /*---------------------------------------
           * Paging
           *--------------------------------------*/ 

          else if (rowlimit == ROW_LIMIT_PAGED)
          {
                    
            /*---------------------------------------
             * Calculate first and last row
             *--------------------------------------*/ 

            int firstrow = 0;
            int lastrow  = 0;
          
            firstrow = (pagenumber - 1) * pagesize + 1;
            lastrow  = (pagenumber - 1) * pagesize + pagesize;
          
            /*---------------------------------------
             * Add paging parameters
             *--------------------------------------*/ 

            parms.Add(Database.SqlParm(SQL_PARM_NAME_PAGING_FIRST_ROW,  SqlDbType.Int, firstrow,   ParameterDirection.Input));
            parms.Add(Database.SqlParm(SQL_PARM_NAME_PAGING_LAST_ROW,   SqlDbType.Int, lastrow,    ParameterDirection.Input));
            parms.Add(Database.SqlParm(SQL_PARM_NAME_PAGING_PAGE_NUM,   SqlDbType.Int, pagenumber, ParameterDirection.Input));
            parms.Add(Database.SqlParm(SQL_PARM_NAME_PAGING_PAGE_SIZE,  SqlDbType.Int, pagesize,   ParameterDirection.Input));

            /*---------------------------------------
             * See if page row order was passed
             *--------------------------------------*/ 

            bool noPageRowOrder = Util.IsNullOrEmpty(pageroworder);
           
            /*---------------------------------------
             * If pagerow order has not been supplied
             * warn the user
             *--------------------------------------*/ 
            
            if (noPageRowOrder) throw new MBA.Critical("Must provide page row order");
                        
            /*---------------------------------------
             * Otherwise use pageroworder as passed
             *--------------------------------------*/ 

            pageroworder = "order by " + pageroworder;
           
            /*---------------------------------------
             * Test for presense of ORDER BY clause
             * in incoming SQL.  Note we are 
             * searching the string from right to
             * left.
             *--------------------------------------*/ 

            Match m          = Regex.Match(sql, @"order by", RegexOptions.IgnoreCase | RegexOptions.RightToLeft);
            bool  hasOrderBy = m.Success;
           
            /*---------------------------------------
             * If an ORDER BY clause exists remove it
             * ORDER BY is allowed within a CTE if you
             * provide a TOP clause but they kill
             * performance
             *--------------------------------------*/ 
            
            if (hasOrderBy) sql = sql.Remove(m.Index);
         
            StringBuilder sb = new StringBuilder();

            /*---------------------------------------
             * Wrap sql in a cte and use the cte
             * to control the paging
             *--------------------------------------*/ 

            sb.Append(";with pagedRecords as (");
            sb.Append("select row_number() over(");
            sb.Append(pageroworder);                          // Row numbering sort
            sb.Append(") as rowNum,");
            sb.Append("count(*) over() as ");
            sb.Append(SQL_COL_NAME_PAGING_ROW_TOTAL);
            sb.Append(",");                                   // Total number of rows found in base query (sql)
            sb.Append("*");                                   // Columns
            sb.Append(" from(");
            sb.Append(sql);                                   // sql
            sb.Append(") as q1 )");
            sb.Append("select * from pagedRecords where rowNum between ");
            sb.Append(SQL_PARM_NAME_PAGING_FIRST_ROW);
            sb.Append(" and ");
            sb.Append(SQL_PARM_NAME_PAGING_LAST_ROW);
            sb.Append(" order by rowNum asc");
            
            sql = sb.ToString();
          }         
                   
          
          /*---------------------------------------
           * Workaround for parameter sniffing
           * 
           * Note: Since the bulk of our queries are
           * either parameterized or dynamic 
           * parameter sniffing is an undesirable
           * pre-optimization.
           * 
           * See: 
           * 
           * http://pratchev.blogspot.com/2007/08/parameter-sniffing.html
           * http://www.simple-talk.com/sql/t-sql-programming/parameter-sniffing/
           *----------------------------------------*/ 
          
          sql = sql + " OPTION (RECOMPILE);";
          
          
        }
                
        /*---------------------------------------
         * Setup query or command
         *----------------------------------------*/ 
        
        cmd                = new SqlCommand (sql, conn);           // Pass in query or command
        cmd.CommandTimeout = Rules.DB_CMD_TIMEOUT;                 // Set timout
        if (tx != null) cmd.Transaction = tx;                      // Indicate this is part of a transaction if neccessary
      
        /*---------------------------------------
         * Determine if this is a query or
         * command
         *----------------------------------------*/ 

        if (sp)
          cmd.CommandType = CommandType.StoredProcedure; 
        else 
          cmd.CommandType = CommandType.Text;
      
        
        /*---------------------------------------
         * Pass in parameters (if any) 
         *--------------------------------------*/ 
      
        if (parms != null)
           foreach (SqlParameter parm in parms)
             cmd.Parameters.Add(parm);
                
        /*---------------------------------------
         * Wire up command cancel 
         * Note: Currently only setup for 
         * web requests.
         *--------------------------------------*/ 
       
        if (hasCancellationToken == true)
        {
            /* Setup delegate to cancel db Command if the request is cancelled */            
            Action actionCancelCmd = delegate () { cmd.Cancel();};             
            cancellationToken.Register( actionCancelCmd);                   
        }

        /*---------------------------------------
         * Execute query or command
         *--------------------------------------*/ 
       
        SqlDataReader dr = cmd.ExecuteReader();
              
        /*---------------------------------------
         * Extract rows (if any)
         *----------------------------------------*/ 
     
        List <Record> rows    = new List<Record>();
        bool          hasRecs = dr.HasRows;
        int           rowCt   = 0;
     
        while (dr.Read())
        {
          Record rec = new Record();
          rec.fields = new Field[dr.VisibleFieldCount];
        
          for (int i = 0; i < dr.VisibleFieldCount; i++)
          {
            rec.fields[i]                 = new Field();           
            rec.fields[i].name            = dr.GetName(i);
            rec.fields[i].value           = dr.GetValue(i);
            rec.fields[i].typename        = rec.fields[i].value.GetType().ToString();            
          }
        
          rows.Add(rec);
          rowCt++;
        }

        dr.Close();
       
        so.commandText = cmd.CommandText;
        so.commandType = cmd.CommandType;
        so.hasRecords  = hasRecs;
        so.records     = rows.ToArray();

        /*---------------------------------------
         * Extract any return parameters 
         *----------------------------------------*/ 
      
        so = extractParameters(cmd.Parameters,ref so,ref log);

        /*---------------------------------------
         * Return results
         *--------------------------------------*/ 

        return so;

      }
      catch(SqlException e)
      {
        
        /*---------------------------------------
         * Catch and convert the following SQL
         * exceptions: 
         * 
         *   - Deadlock  
         *   - Timeout
         *   - Session Expired
         *   - Password lock
         * 
         * Pass all other execeptions along
         *----------------------------------------*/ 

        if (e.Number == 1205)
        {
                  
          /*---------------------------------------
           * Deadlock
           *---------------------------------------*/ 
  
          throw new Critical(Messages.DB_DEADLOCK);
        }
        else if (e.Number == -2)
        {
          /*---------------------------------------
           * Time out
           *----------------------------------------*/ 

          throw new Critical(Messages.DB_TIME_OUT);
        }
        else
        {
          /*---------------------------------------
           * Session expired, password lock, or
           * other
           *----------------------------------------*/ 

          int cd = e.Class;
          if (cd == Return.RET_SESSION_EXPIRE)
            throw new SessionExpired(e.Message);
          else if (cd == Return.RET_PASSWORD_LOCK)
            throw new PasswordLock(e.Message);
          else
            throw e;
        }
      }
      finally
      {
        /*---------------------------------------
         * Cleanup tasks
         *---------------------------------------*/
          
        if (cmd != null)
        {
          cmd.Parameters.Clear();  // Subsequent calls were causing an issue with parameters... this is the fix (http://blog.benhall.me.uk/2007/04/sqlparameter-is-already-contained-by.html)
          cmd.Dispose();
        }
      }
    }

        /***************************************************************************
         * convertReturnDB to Datatable */
        /**
         *             
         ***************************************************************************/

        public static DataTable convertReturnDBToDatatable(ref ReturnDB rd)
        {

           
            int numRows = 0;
            int numCols = 0;

           // Create new DataTable 
              DataTable table = new DataTable();

           // Declare DataColumn and DataRow variables.
              DataColumn column;
              DataRow row; 


            /*-------------------------------
             * Go through each row
             *------------------------------*/
            
            foreach (Record r in rd.records)
            {

                /*-------------------------------
                 * If this is the very first row
                 * get the row count, column count,
                 * and setup column data
                 *------------------------------*/

                if (numRows == 0)
                {

                    /*-------------------------------
                     * Extract row and column counts
                     * from rd
                     * We will only need to do this once
                     *------------------------------*/

                    numRows = rd.records.Length;
                    numCols = r.fields.Length;

                    /*-------------------------------
                     * Setup the data table structures
                     * for rows and columns
                     *------------------------------*/
                    foreach (Field f in r.fields)
                    {
                         column = new DataColumn();
                         //if (!(f.identifiedvalue.valueType == typeof(DBNull)))
                             //column.DataType = f.identifiedvalue.valueType;
                             
                        // else
                         //{
                             switch (f.typename)
                             {
                                 case "System.DateTime":
                                     {
                                         column.DataType = typeof(DateTime);
                                         break;
                                     }
                                 case "System.Boolean":
                                     {
                                         column.DataType = typeof(bool);
                                         break;
                                     }
                                 case "System.Int32":
                                 case "System.Int64":
                                     {
                                         column.DataType = typeof(Int64);
                                         break;
                                     }
                                 case "System.String":
                                 default:
                                     {
                                         column.DataType = typeof(string);
                                         break;
                                     }
                             }

                         //}
                        
                         column.ColumnName = f.name;
                         table.Columns.Add(column);
                    }
                      
                }

                    int k = 0;                               
                    row = table.NewRow();
                    /*-------------------------------
                     * Extract column data from rd.fields
                     * We will only need to do this once                    
                     *------------------------------*/
                    foreach (Field f in r.fields)
                    {
                        row[k] = f.value;                       
                        k++;
                    }
                    table.Rows.Add(row);
                }

                       return table;
        }

    
  }
}
