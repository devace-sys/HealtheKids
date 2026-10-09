using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MBA;
using MBA.IdentifyData;

/***************************************************************************
 * DataTree */
/**
 * A tree for data storage
 ***************************************************************************/  

namespace MBA.Reporting
{ 	
    
  /***************************************************************************
   * TreeNodeType */
  /**
   * Indicates the type of node
   * 
   * A root field is the root
   * A group field is a node
   * A data field is a leaf 
   * 
   ***************************************************************************/  
  
  public enum TreeNodeType
  {
	  ROOT,
    BRANCH, /* Coresponds to group */
    LEAF    /* Coresponds to data  */
  };

  
  /***************************************************************************
   * DataTreeNodeChildComparer */
  /**
   * A comparer for DataTreeNodeChild.  
   * Note we perform the comparison based on the childid only.
   ***************************************************************************/  

  public class DataTreeNodeChildComparer:IEqualityComparer<DataTreeNodeChild>
  {
    public bool Equals(DataTreeNodeChild x, DataTreeNodeChild y)
    {
      return x.childid.Equals(y.childid);
      //return ((x.childtype == y.childtype) && (x.childid.Equals(y.childid)));
    }
    
    public int GetHashCode(DataTreeNodeChild x)
    {
      return x.childid.GetHashCode();
      //return x.childtype.GetHashCode() + x.childid.GetHashCode();
    }

  }

  /***************************************************************************
   * DataTreeNodeChild */
  /**
   * A data tree child node
   ***************************************************************************/  

  public class DataTreeNodeChild
  {
    public RowAttribute childtype;
    public int childid;
   
   /*---------------------------------
	  * Constructors
	  *--------------------------------*/	
    
    public DataTreeNodeChild(RowAttribute type, int id)
    {
      this.childtype = type;
      this.childid   = id;
    }    
  }

  /***************************************************************************
   * DataTreeNode */
  /**
   * Represents a node in the data tree
   ***************************************************************************/     
	
  public class DataTreeNode
  {
	  public int             id;
	  public int             parentid;
	  public int             level;
    public string          key;
	  public int             position;     // Col position
	  public TreeNodeType    nodetype;
	  public bool            visible;
    public bool            headertitle;  // This node contains title data?
    public bool            contenttitle;
	  public Field           field;
    public IdentifiedValue identifiedValue;
	  public RowAttribute    rowtype;
	  public int             rptgroupid;
    public bool            startofrowdata;
	  public bool            endofrowdata;
    public bool            hasChildren;
    public bool            detailchildrenhaverowdata;
    public bool            aggregatechildrenhaverowdata;
    public bool            style_border_left;
    public bool            style_border_right;
    
    public Dictionary <DataTreeNodeChild,int> children;    
    
    // TODO: Cleaup needed.  This business of passing in information about this nodes source column needs to be cleaned up
    // We should have some sort of pointer to the nodes source column instead of passing and storing copies
    // of the various fields that we are storing.
    
	  public DataTreeNode(int id, 
                        int parentid, 
                        int level, 
                        int position, 
                        bool visible,
                        bool headertitle,
                        bool contenttitle,
                        TreeNodeType type, 
                        Field field, 
                        IdentifiedValue identifiedvalue, 
                        RowAttribute rowtype,
                        int rptgroupid,
                        bool style_border_left,
                        bool style_border_right)
	  {
	    this.id           = id;
	    this.parentid     = parentid;
	    this.level        = level;
	    this.position     = position;
	    this.nodetype     = type;
	    this.visible      = visible;
      this.headertitle  = headertitle;
      this.contenttitle = contenttitle;
      this.field        = field;
      
      this.identifiedValue      = identifiedvalue;
	    this.rowtype              = rowtype;
	    this.rptgroupid           = rptgroupid;
      this.style_border_left    = style_border_left;
      this.style_border_right   = style_border_right;
      
      this.startofrowdata               = false;
	    this.endofrowdata                 = false;
      this.detailchildrenhaverowdata    = false;
      this.aggregatechildrenhaverowdata = false;

      
      this.children             = new Dictionary<DataTreeNodeChild,int>(new DataTreeNodeChildComparer());
      this.hasChildren          = false;
	  }
					
   /***************************************************************************
    * AddChild */
   /**
    * Assigns the given node id as a child of this node.
    ***************************************************************************/    
		
    public void AddChild(RowAttribute type, int id)
    {
      DataTreeNodeChild key = new DataTreeNodeChild(type,id);
      AddChild(key);
    }
    
    protected void AddChild(DataTreeNodeChild key)
    {
      /*---------------------------------
	     * Check for self reference
	     *--------------------------------*/				
      
      if (key.childid == this.id)
        return;

      /*---------------------------------
	     * Check for existing child
       * If the child already exists
       * update an instance counter
	     *--------------------------------*/				
      
      int val = 0;
	    if (this.children.TryGetValue(key, out val))
	    {
		    this.children[key] = val + 1;
      }        	 

      /*---------------------------------
	     * Add child if its new
	     *--------------------------------*/				

      else
	    {
		    this.children.Add(key,1);
		    this.hasChildren = true;
      }
    }

   /***************************************************************************
    * childrenHaveRowData */
   /**
    * For the given row attribute indicate if this nodes children have row
    * data.  In terms of traversing a tree of nodes, this means that this
    * nodes children contains leaf level data.
    **************************************************************************/    

    public bool childrenHaveRowData(RowAttribute ra)
    {
      if (ra == RowAttribute.AGGREGATE) return this.aggregatechildrenhaverowdata;
      if (ra == RowAttribute.DETAIL)    return this.detailchildrenhaverowdata;
      return false;
    }

    /***************************************************************************
     * childrenHaveDetailAndAggregateRowData */
    /**
     * Indicates if this nodes children have BOTH detail and aggregate row data.
     **************************************************************************/    
    
    public bool childrenHaveDetailAndAggregateRowData()
    {
      return (this.detailchildrenhaverowdata && this.aggregatechildrenhaverowdata);
    }

    /***************************************************************************
     * childrenHaveDetailOrAggregateRowData */
    /**
     * Indicates if this nodes children have EITHER detail or aggregate row data.
     ***************************************************************************/    
    
    public bool childrenHaveDetailOrAggregateRowData()
    {
      return (this.detailchildrenhaverowdata || this.aggregatechildrenhaverowdata);
    }

    /***************************************************************************
     * childrenHaveJustDetailRowData */
    /**
     * Indicates if this nodes children has ONLY detail row data.
     ***************************************************************************/    
    
    public bool childrenHaveJustDetailRowData()
    {
      if (this.detailchildrenhaverowdata == true)
        if (this.aggregatechildrenhaverowdata == false)
          return true;
      return false;
    }

    /***************************************************************************
     * childrenHaveJustAggregateRowData */
    /**
     * Indicates if this nodes children has ONLY aggregate row data.
     ***************************************************************************/    
    
    public bool childrenHaveJustAggregateRowData()
    {
      if (this.aggregatechildrenhaverowdata == true)
        if (this.detailchildrenhaverowdata == false)
          return true;
      return false;
    }

    /***************************************************************************
     * viewChildren */
    /**
     * Returns a list of ids for this nodes children (if any).
     ***************************************************************************/    
    
    public List<int> viewChildren()
    {
      List<int> clist = new List<int>();
      
      /*---------------------------------
	     * We want the children output in
       * order of row type, details first
	     *--------------------------------*/	

      foreach (int c in viewChildren(RowAttribute.DETAIL))
        clist.Add(c);

      foreach (int c in viewChildren(RowAttribute.AGGREGATE))
        clist.Add(c);

      return clist;
    }

    /***************************************************************************
     * viewChildren */
    /**
     * Returns a list of ids for this nodes children (if any) that match the 
     * given row attribute.
     ***************************************************************************/    

    public List<int> viewChildren(RowAttribute ctype)
    {
      List<int> clist = new List<int>();

      foreach (DataTreeNodeChild c in this.children.Keys)
      {
        if (c.childtype == ctype)
          clist.Add(c.childid);
      }
      return clist;
    }        
  }

  /***************************************************************************
   * TraverseNodesOperation */
  /**
   * Delegate for tree node operations
   ***************************************************************************/  
     
  public delegate void TraverseNodesOperation (ref DataTree dt, ref DataTreeNode f, params Object[] args);

  /***************************************************************************
   * TraverseNodesCallback */
  /**
   * Delegate for tree node work
   ***************************************************************************/  

  public delegate void TraverseNodesCallback  (params Object[] args);
  
  /***************************************************************************
   * DataTree */
  /**
   * Provides a hierarchial structure for traversing and processing data
   ***************************************************************************/  

  public class DataTree
  {    
	  
    public static int  MAX_ALLOWED_ROWS    = 100000; // 65535
		public static int  ROOT_NODE_ID        = 0;
    public static int  NULL_ID_OR_INDEX    = -1;
    public static int  NULL_POSITION       = -1;
    public static int  ROOT_LEVEL          = 0;
    public static int  RPT_GROUP_ID_DETAIL = -1;

	  public  int    idCtr;                 // Unique id generate for each output field
	  public  int    rowCtr;                // Total # of rows
	  public  int    dataFieldCtr;          // Total # of data fields          
	  public  int    groupFieldCtr;         // Total # of group fields
	  public  int    maxGroupID;            // Maximum possible group ID	
    public  int    levelCtr;              // Total # of levels (0 based) groupFieldCtr + 2		
    	 	  
    public     List       <InputColumnDefinition>  InputColumnDefinitions;   // Input field mappings
	  public     Dictionary <string, int>            BranchKeys;               // Unique keys that identifiy branches
	  public     List       <DataTreeNode>           Nodes;                    // The tree nodes
	  public     List       <TitleOrFooter>          displayTitles;            // Titles for this view extracted from data
    public     List       <TitleOrFooter>          displayFooters;           // Footers for this view extracted from data
		 
	 /*---------------------------------
	  * Constructors
	  *--------------------------------*/
	   
   public DataTree()
	 {
	  			
	   /*---------------------------------
	    * Init our various counters
	    *--------------------------------*/	
			
	   this.idCtr         = 1;  // Unique output field ids (id 0 is used by root)
	   this.rowCtr        = 1;  // Number of rows imported
	   this.levelCtr      = 1;  // Number of levels (level 0 is used by root)
	   this.groupFieldCtr = 0;  // Number of group fields
	   this.dataFieldCtr  = 0;  // Number of data fields
     this.maxGroupID    = 0;  // Max group id
         							  
     /*---------------------------------
	    * Init structures
	    *--------------------------------*/	
			
	   this.BranchKeys                = new Dictionary<string, int>();	     // Branch keys
     this.InputColumnDefinitions    = new List<InputColumnDefinition>();   // Input column definitions
	   this.Nodes                     = new List<DataTreeNode>();            // Nodes
     this.displayTitles             = new List<TitleOrFooter>();           // Titles and footers from data
     this.displayFooters            = new List<TitleOrFooter>();
	   
     /*---------------------------------
	    * Create root field 
	    * The root field is a special 
	    * group field that does not show 
	    * up in the input field defs
	    * Its simply a placeholder.
	    * However it does take a level and
	    * an id
	    *--------------------------------*/	
				
	   Field f            = new Field();						
	   f.name             = "root";
	   f.value            = "";		 									
	   IdentifiedValue iv = IdentifiedValue.Parse(f.value);
     RowAttribute         rt = RowAttribute.DETAIL;
     f.typename         = iv.typename;
	   this.Nodes.Add(new DataTreeNode(ROOT_NODE_ID, 
	                                   NULL_ID_OR_INDEX, 
	                                   ROOT_LEVEL, 
	                                   NULL_POSITION, 
	                                   false, 
	                                   false, 
	                                   false, 
	                                   TreeNodeType.ROOT, 
	                                   f, 
	                                   iv, 
	                                   rt, 
	                                   RPT_GROUP_ID_DETAIL, 
	                                   false, 
	                                   false));			
	 }

	/*---------------------------------
	 * Input Fields 
	 *--------------------------------*/
			    			
	public void AddInputFieldDefinitions(List<InputColumnDefinition> definitions)
  {
    foreach (InputColumnDefinition def in definitions)
      AddInputFieldDefinition(def);
  }
  
  public void AddInputFieldDefinition(InputColumnDefinition def)
  {
      this.InputColumnDefinitions.Add(def);
     
     /*---------------------------------
	    * Updates field counters
	    *--------------------------------*/
     			
	   if (def.inputcoltype == InputColType.DATA)
	     this.dataFieldCtr++;
	   else
	     this.groupFieldCtr++;
	  
     /*---------------------------------
	    * Updates level counter
	    *--------------------------------*/
			
	   this.levelCtr = this.groupFieldCtr + 1;  // +2 takes into account the root and the data level  
     
     /*---------------------------------
	    * Updates max group id
	    *--------------------------------*/
     
     this.maxGroupID = Util.maxIntInBits(groupFieldCtr);      
    
  	 /*---------------------------------
	    * Sorts by position
	    *--------------------------------*/
		
	   this.InputColumnDefinitions.Sort();

  }

  public int FindDataStartPosition(RowAttribute ra)
  {    
    List<InputColumnDefinition> defs = ViewInputColumnDefinitionsRowData(ra);

    foreach (InputColumnDefinition def in defs)
      if (def.inputcoltype == InputColType.DATA)
        return def.position;
    return -1;
  }

  protected InputColumnDefinition FindFieldDefinition (int position)
	{
	  return this.InputColumnDefinitions.Find(delegate(InputColumnDefinition f) { 
	    return f.position == position;});					
	}
	
	protected InputColumnDefinition FindFieldDefinition (string name)
	{
	  return this.InputColumnDefinitions.Find(delegate(InputColumnDefinition f) { 
	   return f.name == name;});					
	}
	
  public List<InputColumnDefinition> ViewInputColumnDefinitions()
  {
    return this.InputColumnDefinitions;
  }

  public List<InputColumnDefinition> ViewInputColumnDefinitions(InputColType ft)
	{
    return this.InputColumnDefinitions.FindAll(delegate(InputColumnDefinition f) { 
      return f.inputcoltype == ft;}); 
	}
  
  public List<InputColumnDefinition> ViewInputColumnDefinitionsRowData()
  {
    return this.ViewInputColumnDefinitionsRowData(RowAttribute.DETAIL);
  }

  public List<InputColumnDefinition> ViewInputColumnDefinitionsRowData(RowAttribute ra)
  {
    
    /*---------------------------------
	   * Retrieve all of the input
     * column definitions that could
     * contain row data
	   *--------------------------------*/
    
    List<InputColumnDefinition> defs1 = ViewInputColumnDefinitions(InputColType.DATA);
    
    /*---------------------------------
	   * If the request was for detail
     * row column headers, return
	   *--------------------------------*/

    if (ra == RowAttribute.DETAIL)
      return defs1;

    List<InputColumnDefinition> defs2 = new List<InputColumnDefinition>();

    foreach (InputColumnDefinition def in defs1)
    {
      if (def.aggregate == true)
        defs2.Add(def);
    }
    
    return defs2;

  }
	   
	/*---------------------------------
	 * Branch Keys
	 *--------------------------------*/

	protected class BranchKeyValue
  {
    public bool   newkey;
	  public string key;
	  public int    value;
  }
		
	protected BranchKeyValue HashBranchKey(string key)
	{
	  BranchKeyValue k = new BranchKeyValue();
	  
    k.key    = key;
	  k.value  = NULL_ID_OR_INDEX;
	  k.newkey = false;
			
	  int val;
	  
    /*---------------------------------
	   * This branch key exists in the
     * hash table.
     * 
     * We don't need to add it.
     * 
     * Return the id of its coresponding
     * tree node so we can reference it.
	   *--------------------------------*/
			
	  if (this.BranchKeys.TryGetValue(key, out val))
    {				
		  k.value = val;
	  }

	  /*---------------------------------
	   * This is a new branch key.
	   * 
     * Store it in the hash table
     * 
     * Assign a new id for a new tree 
     * node
     * 
     * Return the new id so we can
     * reference it.
	   *--------------------------------*/

    else
	  {	    				
		  k.value  = this.idCtr;
	 	  k.newkey = true;
	    BranchKeys.Add(k.key,k.value);
		  this.idCtr++;		    
	  }	  

	  return k;
	}
	
  /***************************************************************************
   * AddRecords */
  /**
   * Main entry point for adding records
   ***************************************************************************/    
		
	public void AddRecords (Record[] records)
	{
			
	  //int colIdx = 0;
			
	  if (records.Length == 0)
	  {
	    throw new Warning("No records to add");
	  }
			
	  if (records.Length > MAX_ALLOWED_ROWS)
	    throw new Warning("The number of records exceeds the maximum number allowed.  The results will be truncated.");

			
    /*---------------------------------
	   * Extract column names for field
	   * definitions
	   *--------------------------------*/		
	  
	  /*foreach (Field f in records[0].fields)
	  {
      //TODO: Make a find index of
      InputColumnDefinition fd = FindFieldDefinition(colIdx);
	    if (fd != null)
        this.InputColumnDefinitions[colIdx].name = f.name;
	    colIdx++;
	  }*/
    
    /*---------------------------------
	   * Add Records
	   *--------------------------------*/			
    
    int recctr   = 1;
    int rectotal = records.Length;

	  foreach (Record r in records)
	  {	    					
      if (!AddRecord (r,recctr,rectotal)) break;	    
      recctr++;
    }	  			

	}		

  /***************************************************************************
   * AddRecord */
  /**
   * 
   ***************************************************************************/    

	protected bool AddRecord (Record r, int recctr, int rectotal)
	{
	  
	  /*---------------------------------
	   * Parse record seperating 
	   * group and data fields
	   *--------------------------------*/			

	  List<Field> groupfields = new List<Field>();
	  List<Field> datafields  = new List<Field>();

	  int position             = 0;	  
    RowAttribute rowtype     = RowAttribute.DETAIL;
    int          rptgroupid  = RPT_GROUP_ID_DETAIL;
    bool         grandtotal  = false;
    
    foreach (Field f in r.fields)
	  {
	    /*---------------------------------
	     * Lookup column by position
	     *--------------------------------*/	
      
      InputColumnDefinition fd = this.FindFieldDefinition(position);		  	

      /*---------------------------------
	     * Perform operations on our static
       * value columns
	     *--------------------------------*/	
      
      if (recctr == 1)
      {
        
        /*---------------------------------
	       * If this column contains data we
         * want to include in the titles
         * add it to the titles
	       *--------------------------------*/	
        
        if (fd.headertitle)
          if (fd.titlelevel != -1)
            this.displayTitles.Add(new TitleOrFooter(f.value.ToString(), fd.titlelevel));
              
      }
      
      /*---------------------------------
	     * Determine column type
       * and store field in appropriate
       * array
	     *--------------------------------*/	

      if (fd.inputcoltype == InputColType.GROUP)
        groupfields.Add(f);
		  
      else if (fd.inputcoltype == InputColType.DATA)		  
        datafields.Add(f);
      
      else
        
        return false;
      
      /*---------------------------------
	     * Identify row types
       * 
       * Row types indicate what type of
       * data the row contains.. either
       * aggregate or detail data
	     *--------------------------------*/	
      
      if (f.name == Constants.RPT_COL_NAME_ROW_TYPE)
      {
        
        int v = Convert.ToInt32(f.value);
        
        if      (v == Constants.RPT_ROW_TYPE_AGR)    rowtype = RowAttribute.AGGREGATE;        
        else if (v == Constants.RPT_ROW_TYPE_DETAIL) rowtype = RowAttribute.DETAIL;        
        else                                         return false;
                                         
      }
      
      /*---------------------------------
	     * Identify aggregate level based
       * on group id
	     *--------------------------------*/	
                 	                      
      if ((f.name == Constants.RPT_COL_NAME_GROUP_ID))
      {
        rptgroupid  = Convert.ToInt32(f.value);        
        
        /*---------------------------------
	       * If this is an aggregate row and
         * its group id is the maximum possible
         * value for the number of groups we have
         * then this should be the grand total
	       *--------------------------------*/		

        if (rptgroupid == this.maxGroupID) grandtotal = true;
      }  
                             
      position++;
	  }  			
                          
    /*---------------------------------
	   * Add record
	   *--------------------------------*/		
    
    return this.AddRecord(groupfields, datafields, rowtype, rptgroupid, grandtotal);	
	}
	  
  /***************************************************************************
   * AssignChildren */
  /**
   * 
   ***************************************************************************/    
	
	protected void AssignChildrenHaveRowData(int id, RowAttribute rowtype)
	{
	  if (id > NULL_ID_OR_INDEX)
	  {
	    int idx = FindIndexOf(id);   
		  if (idx != NULL_ID_OR_INDEX)
      {
		    if (rowtype == RowAttribute.DETAIL)
          this.Nodes[idx].detailchildrenhaverowdata = true;
        else
          this.Nodes[idx].aggregatechildrenhaverowdata = true;
      }
	  }			
	}

  /***************************************************************************
   * AssignEndOfRowData */
  /**
   * 
   ***************************************************************************/    

	protected void AssignEndOfRowData(int id)
	{
	  if (id > NULL_ID_OR_INDEX)
	  {
	    int idx = FindIndexOf(id);
		  if (idx != NULL_ID_OR_INDEX)
		    this.Nodes[idx].endofrowdata = true;
	  }	
	}

  /***************************************************************************
   * AssignStartOfRowData */
  /**
   * 
   ***************************************************************************/    
	
	protected void AssignStartOfRowData(int id)
	{
	  if (id > NULL_ID_OR_INDEX)
	  {
	    int idx = FindIndexOf(id);
		  if (idx != NULL_ID_OR_INDEX)
		    this.Nodes[idx].startofrowdata = true;
	  }			
	}
				
  /***************************************************************************
   * AssignChildNode */
  /**
   * 
   ***************************************************************************/    

  protected bool AssignChildNode(int parentid, int id, RowAttribute rowtype, InputColumnDefinition icd)
	{
	  
    /*---------------------------------
	   * No circular references allowed
	   *--------------------------------*/  	

     if (parentid == id)
       return false;
    
    /*---------------------------------
	   * Adds id as a child of parentid
     * or as an aggregate entry
     * based on rowtype
	   *--------------------------------*/  	
   
    if (parentid > NULL_ID_OR_INDEX)
	  {
			  
      /*---------------------------------
	     * If parentid is legit look for
	     * its index
	     *--------------------------------*/
	    
		  int idx = FindIndexOf(parentid);
		
		  /*---------------------------------
	     * If the index was located
	     * add id as a child of parentid
       * 
	     * If the index was not located
	     * something is wrong.
	     *--------------------------------*/
	    		  
      if (idx != NULL_ID_OR_INDEX)
      {        
        this.Nodes[idx].AddChild(rowtype,id);
      }
      else
      {
        return false;
      }
    }
    else
    {
      return false;
    }
    return true;
  }

  /***************************************************************************
   * AddRecord */
  /**
   * 
   ***************************************************************************/    
		
  protected bool AddRecord (List<Field>  groupfields, 
                            List<Field>  datafields, 
                            RowAttribute rowtype,
                            int          rptgroupid,
                            bool grandtotal)
  {
	    
    /*---------------------------------
	   * If the internal record limit has 
	   * been reached do not allow the 
	   * record to be added
	   *--------------------------------*/  			
      
	   if (this.rowCtr >= MAX_ALLOWED_ROWS) return false;
          
    /*---------------------------------
	   * Test group and data field
     * collection counts.  They must 
     * match the defined lengths.
     * No jagged data is allowed.
	   *--------------------------------*/ 
    
    if (groupfields.Count != groupFieldCtr)
      return false;
    
    if (datafields.Count != dataFieldCtr)
      return false;

    /*---------------------------------
	   * Test group fields to make sure
     * the collection is a valid
     * collection
	   *--------------------------------*/ 

    if (!grandtotal)
    {
      int  groupfieldnum        = 0;    
      bool lastgroupfieldisnull = false;
    
      foreach (Field f in groupfields)
	    {      
        string groupvalue = f.value.ToString();
        bool   gvne       = Util.IsNullOrEmpty(groupvalue);
      
        if (gvne)
        {
          /*---------------------------------
	         * The first field must NOT be null
           * and this also takes care of the
           * case where ALL the fields are null
           * by virtue that if all the fields
           * are null then the first field 
           * would also be null.
	         *--------------------------------*/ 
        
          if (groupfieldnum == 0) 
            return false;        
        }
        else
        {
          /*---------------------------------
	         * Nulls are allowed but only if they
           * are in a contiguous block at the
           * end of the fields.  "Holes" in
           * the middle are not allowed.
	         *--------------------------------*/ 
        
          if (lastgroupfieldisnull) 
            return false;

          /*---------------------------------
	         * Update last group field is null
           * flag
	         *--------------------------------*/ 

          lastgroupfieldisnull = gvne;
          groupfieldnum++;
        }
      }
    }

    /*---------------------------------
	   * If we reach this point we can
	   * attempt to add the record.
     * 
     * The first group field will 
     * be a child of the root node.
	   *--------------------------------*/  			

	  int    parentid            =  ROOT_NODE_ID;      
	  int    id                  =  NULL_ID_OR_INDEX;  
	  int    level               =  ROOT_LEVEL + 1;    
    string bkey                =  "";
    bool   lastgroupistitle    = false;

    /*---------------------------------
	   * For each group field that has 
	   * been passed in
	   *--------------------------------*/  			
      	  
	  foreach (Field f in groupfields)
	  {
       
      /*---------------------------------
	     * Lookup the column definition by
       * field.name and parse field.value
	     *--------------------------------*/  			

      InputColumnDefinition icd = this.FindFieldDefinition(f.name);
      IdentifiedValue       iv  = IdentifiedValue.Parse(f.value, icd.formatstring);
          
      /*---------------------------------
 	     * Generate a branch key based
       * on the current group field 
       * string values and all previous 
       * group field string values
	     *--------------------------------*/  			

       if (!iv.valueIsNullOrEmpty)
       {
         /*---------------------------------
 	        * The value is NOT null
          * Add this field to the key
    	    *--------------------------------*/  
         
         bkey = bkey + iv.valueStr.Replace(" ","*") + "|";
         lastgroupistitle = icd.headertitle;
       }
       else
       {  
         /*---------------------------------
	        * The value IS NULL therefore 
          * STOP processing the group
          * fields.
          * 
          * There should not be any
          * additional key construction
          * required since the only valid
          * valid location for null group
          * fields are at the end of the
          * collection of group fields
	        *--------------------------------*/  	
         
         break;
       }
       
       /*---------------------------------
	      * If we reach this point hash our
        * key and return the node id of
	      * the key.  
        * 
        * The id will either be a new id
        * or the id of an existing branch.
        *--------------------------------*/  			

       BranchKeyValue k   = HashBranchKey(bkey);
	     id                 = k.value;
	   
		  /*---------------------------------
	     * If the key was not found then
	     * this is a new branch node so
	     * add the branch to our nodes
	     *--------------------------------*/  			

		  if (k.newkey)     
	      this.Nodes.Add(new DataTreeNode(id, parentid, level, icd.position, icd.visible, icd.headertitle, icd.contenttitle, TreeNodeType.BRANCH, f, iv, rowtype, rptgroupid, icd.style_border_left, icd.style_border_right));

      /*---------------------------------
	     * Adds id as a child or aggregate
       * entry of parentid if applicable
       * and assign row membership
	     *--------------------------------*/  	
      
      AssignChildNode(parentid, id, rowtype, icd);
		
      /*---------------------------------
	     * The next group field will be
	     * a child of this field so
	     * establish that relationship and
	     * hierarchy.
	     *--------------------------------*/  			

		  parentid = id;					
      level++;
							
	 }
	      
   /*---------------------------------
	  * Save the id that will be used for
	  * the first data field, we will use
	  * it later
	  *--------------------------------*/  			
      
	 int firstDataId = this.idCtr;
	     
   /*---------------------------------
	  * For each data field that has
	  * been passed in
	  *--------------------------------*/  			
    
   foreach(Field f in datafields)
	 {		        
    
     /*---------------------------------
	    * Identify the value
	    *--------------------------------*/  			

     InputColumnDefinition icd = this.FindFieldDefinition(f.name);		        
     IdentifiedValue       iv  = IdentifiedValue.Parse(f.value, icd.formatstring);    
          
     /*---------------------------------
	    * Determine if it should be 
      * visible based on if the
      * column visibility setting and
      * if the last column in the parent
      * group has been marked as a title
      * group
	    *--------------------------------*/  			
     
     bool viv = (icd.visible) && (!lastgroupistitle);
  
     /*---------------------------------
	    * If the row is an aggregate 
      * do not store fields that are
      * not identified as aggregate
      * columns.  This helps eliminate
      * the storage of empty values.
	    *--------------------------------*/  			    	
         
     if (rowtype == RowAttribute.AGGREGATE)
       if (!icd.aggregate)
         continue;
     
     /*---------------------------------
	    * Store field 
	    *--------------------------------*/  			

		 id = this.idCtr;

     this.Nodes.Add(new DataTreeNode(id, parentid, level, icd.position, viv, false, false, TreeNodeType.LEAF, f, iv, rowtype, rptgroupid, icd.style_border_left, icd.style_border_right));
				
	   /*---------------------------------
	    * Adds id as a child or aggregate
      * entry of parentid if applicable
      * and assign row membership
	    *--------------------------------*/  
		 
     AssignChildNode(parentid, id, rowtype, icd);
				
	   /*---------------------------------
	    * Advance id counter
	    *--------------------------------*/  			

		 this.idCtr++;     

	 }
  
	 /*---------------------------------
	  * The last id used should be the
	  * last data id
	  *--------------------------------*/  	  		
	  
	 int lastDataId = id;
			
	 /*---------------------------------
	  * Flag start/end data
	  *--------------------------------*/  

   AssignChildrenHaveRowData(parentid,rowtype);
	 AssignStartOfRowData(firstDataId);
	 AssignEndOfRowData(lastDataId);
			
	 /*---------------------------------
	  * Update status
	  *--------------------------------*/  

	 //this.UpdateStatus("Record added " + this.rowCtr.ToString());	
	  
	 /*---------------------------------
	  * Advance row counter
	  *--------------------------------*/  			
	
	 this.rowCtr++; 	  	  	  	  
	 return true;
 }
    
  /*---------------------------------
	 * Find nodes
	 *--------------------------------*/  			
		
	public int FindIndexOf(int id)
	{
	  /*---------------------------------
	   * Find the index of the node that
	   * has the given id
	   *--------------------------------*/		

	  if ((id > NULL_ID_OR_INDEX) && (id < this.Nodes.Count))
	  {
	    /*---------------------------------
	     * If id is legit, no records have
	     * been removed, and the list has not
	     * been sorted the index of the
	     * output field should be the given id
	     *--------------------------------*/		

		  int idx = id;
				
	    /*---------------------------------
	     * See if this is actually the case
	     * and if so return idx
	     *--------------------------------*/		

		  if (this.Nodes[idx].id == id) 
		    return idx;
		
		  /*---------------------------------
	     * Otherwise search for it and
	     * return the result
	     * 
	     * Note this search is o(n).
	     *--------------------------------*/		
		
		  return this.Nodes.FindIndex(delegate(DataTreeNode f) {return f.id == id;});
	  }
	
    /*---------------------------------
	   * If we reach this point we found
	   * nothing
	   *--------------------------------*/		
		
    return NULL_ID_OR_INDEX;

	}
   
  /***************************************************************************
   * Traverse */
  /**
   * This is our core traversal method
   * 
   * @param  dtree        A datatree instance
   * @param  id           Starting node id (usually root)
   * @param  safetyCtr    Counter used for safe recursion
   * @param  levelCtr     Counter used to determine what level we are at
   * ***************************************************************************/	
   
  public static bool TraverseNodes ( ref DataTree dt,
                                     int id, 
                                     ref int safetyCtr,
                                     ref int levelCtr,
		                                 TraverseNodesOperation op,
                                     TraverseNodesOperation enter,
                                     TraverseNodesOperation exit,
                                     TraverseNodesOperation childrenenter,
                                     TraverseNodesOperation childrenexit)
		                         
	{	  

  
    /*---------------------------------
	   * Update safety counter and get
	   * out if we are in trouble.
	   *--------------------------------*/  			 
	  
	  safetyCtr++;	 
	  
	  if (safetyCtr > dt.idCtr) 
	    return false;
	  			
    /*---------------------------------
	   * Find where the output field with 
	   * the given id is stored
	   *--------------------------------*/  			 
			
	  int idx = dt.FindIndexOf(id);
	  if (idx == -1) return false;

	  /*---------------------------------
	   * Retrieve it
	   *--------------------------------*/  			 
			
	  DataTreeNode node = dt.Nodes[idx];				          

    /*---------------------------------
	   * Enter
	   *--------------------------------*/  			 

    if (enter != null)
      enter(ref dt, ref node, levelCtr);    
	                
    /*---------------------------------
	   * Operation
	   *--------------------------------*/  			 

    if (op != null)
      op(ref dt, ref node);    
            
    /*---------------------------------
	   * Process children
	   *--------------------------------*/  			 
        
    if (node.hasChildren)
    {
      /*---------------------------------
	     * Child enter
       * levelCtr passed
	     *--------------------------------*/       

      levelCtr++;
                
      if (childrenenter != null)
        childrenenter(ref dt, ref node, levelCtr);     
      
      /*---------------------------------
	     * Retrieve children and determine
       * what types of children are 
       * available
	     *--------------------------------*/  
          
      List <int> detChildren = node.viewChildren(RowAttribute.DETAIL);
      List <int> agrChildren = node.viewChildren(RowAttribute.AGGREGATE);
      
      bool hasDetChildren = (detChildren.Count > 0) ? true : false;
      bool hasAgrChildren = (agrChildren.Count > 0) ? true : false;      
      
      /*---------------------------------
	     * Process detail children
       * 
       * Note: This is our main engine
       * for walking the tree
	     *--------------------------------*/  
     
      if (hasDetChildren)
      {
        /*---------------------------------
	       * Child enter
         * levelCtr & row attribute passed
	       *--------------------------------*/       
                
        if (childrenenter != null)
          childrenenter(ref dt, ref node, levelCtr, RowAttribute.DETAIL);
        
        /*---------------------------------
	       * Recurse
	       *--------------------------------*/       
       
        foreach (int childid in detChildren)
          if (!TraverseNodes(ref dt, childid, ref safetyCtr, ref levelCtr, op, enter, exit, childrenenter, childrenexit)) 
		        return false;
        
        /*---------------------------------
	       * Child exit
         * levelCtr & row attribute passed
	       *--------------------------------*/       

        if (childrenexit != null)
          childrenexit(ref dt, ref node, levelCtr, RowAttribute.DETAIL);    
      
      }
      
      /*---------------------------------
	     * Process aggregate children
       * 
       * Note: We should only go one level
       * deeper for these and we want
       * to keep the context of the output
       * at the same level as the parent
	     *--------------------------------*/  

      if (hasAgrChildren)
      {   
        /*---------------------------------
	       * Child enter
         * levelCtr & row attribute passed
	       *--------------------------------*/ 
        
        if (childrenenter != null)
          childrenenter(ref dt, ref node, levelCtr, RowAttribute.AGGREGATE);   
        
        /*---------------------------------
	       * Recurse
         * 
         * We do not pass the child 
         * enter or exit delegates becase
         * there should be no children
         * for this children to recurse
         * into.
	       *--------------------------------*/ 

        foreach (int childid in agrChildren)
          if (!TraverseNodes(ref dt, childid, ref safetyCtr, ref levelCtr, op, enter, exit, null, null)) 
		        return false;
        
        /*---------------------------------
	       * Child exit
         * levelCtr & row attribute passed
	       *--------------------------------*/ 

        if (childrenexit != null)
          childrenexit(ref dt, ref node, levelCtr, RowAttribute.AGGREGATE);    
      }
      
      /*---------------------------------
	     * All children exit
       * levelCtr passed
	     *--------------------------------*/       

      levelCtr--;

      if (childrenexit != null)
        childrenexit(ref dt, ref node, levelCtr);     

    } 
    
    /*---------------------------------
	   * Exit
	   *--------------------------------*/  			 

    if (exit != null)
      exit(ref dt, ref node);    	                
       	                
	  /*---------------------------------
	   * Done
	   *--------------------------------*/  			 
	  
	  return true;
	}


  /***************************************************************************
   * TraverseForReport */
  /**
   * This traversal method is used to help create reports
   * 
   * @param  dtree        A datatree instance
   * @param  id           Starting node id (usually root)
   * @param  safetyCtr    Counter used for safe recursion
   * @param  levelCtr     Counter used to determine what level we are at
   * ***************************************************************************/	
	
	public static bool TraverseForReport ( ref DataTree dtree,
	                                       int id, 
                                         ref int safetyCtr,
                                         ref int levelCtr,                                       
                                         TraverseNodesCallback  startheader,
                                         TraverseNodesCallback  headerop,
                                         TraverseNodesCallback  endheader,
                                         GenericCallBack        startbody,
                                         TraverseNodesOperation startrow,
                                         TraverseNodesOperation nodeop,
                                         TraverseNodesOperation endrow,
                                         GenericCallBack        endbody)
	{
	  bool   skipChildNodes = false;
	  string rowEvenOdd     = "even"; // Start with even to start with odd
	  int    numVisibleCols = 0;
    
	  /*---------------------------------
	   * Node enter
	   *--------------------------------*/ 

	  TraverseNodesOperation nodeenter = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    /*---------------------------------
	     * Skip if applicable
	     *--------------------------------*/ 
      
      if (f.nodetype == TreeNodeType.ROOT)    return;
      if (f.headertitle)                      return;
      if (!f.visible)                         return;
      if (skipChildNodes)                     return;
      
      int    startRowPad   = 0;
      int    agrTitlePos   = -1;
      int    agrTitleSpan  = -1;
      string agrTitleLabel = "";
      
      string rowType     = "";
      string rowStripe   = "";
            
      /*---------------------------------
	     * If the node is a branch then
       * there should be only one value
       * to display and its both the
       * start and end of a row
	     *--------------------------------*/ 

      if((f.nodetype == TreeNodeType.BRANCH))
      {
                
        /*-------------------------------
         * Reset row striping
         *------------------------------*/ 
        
        // TODO: There is a bug when we have less than two detail columns before our aggregates for padding
        
        rowEvenOdd             = "even";                        // Start with even to start with odd       
        startRowPad            = f.position - 1;                
        rowType                = f.rowtype.ToString().ToLower();        
        rowStripe              = "";                            // None for branches
        agrTitleLabel          = "";
        agrTitlePos            = -1;
        agrTitleSpan           = -1;
        
        startrow(ref dt, ref f, rowType, rowStripe, startRowPad, agrTitlePos, agrTitleLabel, agrTitleSpan);
        
        return;
      }
      
      /*---------------------------------
	     * Otherwise the node is a leaf and
       * the leaves constitute our detail
       * row data
	     *--------------------------------*/ 

      if (f.nodetype == TreeNodeType.LEAF) 
      {

        /*---------------------------------
	       * If this is our first leaf in the
         * row, start a new row
	       *--------------------------------*/ 

        if (f.startofrowdata)
        {
          /*-------------------------------
           * Determine row striping
           *------------------------------*/ 
                    
          if (f.rowtype == RowAttribute.DETAIL)
          {
            if (rowEvenOdd == "even") rowEvenOdd = "odd";
            else                      rowEvenOdd = "even";                       
          }
          
          /*---------------------------------
	         * Start a new row
	         * Since this is a tree we need to
           * fill in any missing columns with
           * filler columns
	         *--------------------------------*/ 
           
           rowType     = f.rowtype.ToString().ToLower();
           startRowPad = f.position - 1;
           
          /*-------------------------------
           * If its a detail row
           *------------------------------*/ 

           if (f.rowtype == RowAttribute.DETAIL)
           {
             rowStripe      = rowEvenOdd;
             agrTitlePos    = -1;
             agrTitleLabel  = "";
             agrTitleSpan   = -1;
           } 
           
          /*-------------------------------
           * If its a aggregate row
           *------------------------------*/ 
           
           else
           {            
             
             rowStripe     = "";
             agrTitlePos   = -1;
             agrTitleLabel = "";             
             agrTitleSpan  = -1;
                                     
             /*-------------------------------
              * If we have room for a 
              * aggregate title
              *------------------------------*/ 

             if (startRowPad > 0)
             {
                                                                     
               /*-------------------------------
                * Determine column title should
                * be placed in
                *------------------------------*/ 
               
               agrTitlePos = f.level - 1;             
	             
	             if (agrTitlePos < 0) agrTitlePos = 0;	        
	             
               /*-------------------------------
                * Determine title itself and 
                * its col span
                *------------------------------*/ 

	             agrTitleSpan = 1;
	             
	             if      (agrTitlePos >  1)  agrTitleLabel = "Sub Total";
	             else if (agrTitlePos == 1)  agrTitleLabel = "Total";
	             else if (agrTitlePos == 0) 
	             {	               
	               
	               // Grand total needs maximum amount of available space
	               
	               agrTitleLabel = "Grand Total";	             
  	             agrTitleSpan  = startRowPad;
	               startRowPad   = 1;                // We will have one pad cell with a multi-col span           	             
	             }

	             else agrTitleLabel = "Total";	           

	           }
           }
                                                         
           startrow(ref dt, ref f, rowType, rowStripe, startRowPad, agrTitlePos, agrTitleLabel, agrTitleSpan);
           
        }        
      }
      return;  
	  };

	  /*---------------------------------
	   * Node exit
	   *--------------------------------*/ 

    TraverseNodesOperation nodeexit = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    /*---------------------------------
	     * Skip if applicable
	     *--------------------------------*/ 
            
      if (f.nodetype == TreeNodeType.ROOT)    return;
      if (f.headertitle)                      return;
      if (!f.visible)                         return;
      if (skipChildNodes)                     return;
       
      if((f.nodetype == TreeNodeType.BRANCH))
      {
                
        /*-------------------------------
         * Reset row striping
         *------------------------------*/ 
         
        endrow(ref dt, ref f);
        rowEvenOdd = "even"; // Start with even to start with odd
        return;
      }
      
      /*---------------------------------
	     * If the node is a leaf
	     *--------------------------------*/ 
            
      if (f.nodetype == TreeNodeType.LEAF)
      {

        /*---------------------------------
	       * If its the last leaf in the row
	       *--------------------------------*/ 
        
        if (f.endofrowdata)
        {              
           endrow(ref dt, ref f, args);
	      }
	    }   
	    return;
	  };
	  	  
	  /*---------------------------------
	   * Children enter
	   *--------------------------------*/ 

    TraverseNodesOperation childrenenter = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    /*---------------------------------
	     * Reset child node skip flag
	     *--------------------------------*/ 
   
      skipChildNodes = false;
     
      /*---------------------------------
	     * Determine if we need to skip
       * these child nodes
	     *--------------------------------*/ 
      
      if (args.Length == 2)
      {
        RowAttribute ra = (RowAttribute) args[1];
        if ((f.childrenHaveJustAggregateRowData()) && (ra == RowAttribute.AGGREGATE) && (f.headertitle))
          skipChildNodes = true;
      }
	  };
	  
	  /*---------------------------------
	   * Children exit
	   *--------------------------------*/ 
	  
	  TraverseNodesOperation childrenexit = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    /*---------------------------------
	     * Reset child node skip flag
	     *--------------------------------*/ 
   
      skipChildNodes = false;
	  };
	  
	  /*---------------------------------
	   * Node Operation
	   *--------------------------------*/ 
	   
	  TraverseNodesOperation op = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)	  
    {
      /*---------------------------------
	     * Skip if applicable
	     *--------------------------------*/ 
      
      if (f.nodetype == TreeNodeType.ROOT)    return;
      if (f.headertitle)                      return;
      if (!f.visible)                         return;
      if (skipChildNodes)                     return;
      
      int span = 1;
      
      if((f.nodetype == TreeNodeType.BRANCH))
        span = numVisibleCols;      
                         
      nodeop(ref dt, ref f, span);

    };
     

	  /*---------------------------------
	   * Process column headings
	   *--------------------------------*/ 
    
    List<int> colWidths   = new List<int>();
    int       totalWidths = 0;
    int       idx         = 0;    

    /*---------------------------------
	   * Determine # of visible columns
     * and add their widths to an
     * array.  These widths should
     * exists either as a result of
     * a width being specificed or
     * a default width being selected
     * based on data type.
	   *--------------------------------*/ 
    
    foreach (InputColumnDefinition def in dtree.ViewInputColumnDefinitions())
    {        
      
      if (!def.visible) continue;              /* Skip hidden columns */
      
      colWidths.Add(def.width);                /* Add individual width */
      totalWidths = totalWidths + def.width;   /* Add to total width   */
      
      numVisibleCols++;                        /* Add visible column to our count */
      
    }
    
    /*---------------------------------
	   * If total widths are 0
     * we have an issue
	   *--------------------------------*/ 

    if (totalWidths == 0) 
      throw new Critical(@"Total column width cannot be 0");
    
    /*---------------------------------
	   * Compute individual column
     * widths as a percentage of the
     * total width.
	   *--------------------------------*/ 

    float[] colWidthPcts = new float[numVisibleCols];
    float  totalWidthsf  = (float) totalWidths;
    
    idx = 0;
    
    foreach (int colWidth in colWidths)
	  {
	    float cw = (float) colWidth;
	    colWidthPcts[idx] = cw / totalWidthsf;
	    idx++;
	  } 
    
    /*---------------------------------
	   * Call our start header delegate
	   *--------------------------------*/ 

    startheader(numVisibleCols, 
                totalWidths, 
                colWidths.ToArray(), 
                colWidthPcts);
    
    /*---------------------------------
	   * For each visible column
	   *--------------------------------*/    
    
    idx = 0;
    
    foreach (InputColumnDefinition def in dtree.ViewInputColumnDefinitions())
    {        
      if (!def.visible) continue;    /* Skip hidden columns */      
      int   w   = colWidths[idx];    /* Get this columns width */
      float p   = colWidthPcts[idx]; /* Get this columns width as a percentage */
      
     /*---------------------------------
	    * Call our column header op
	    *--------------------------------*/ 
      
      headerop(def, 
               w,
               p, 
               idx);
      
      idx++;
    }
    
    /*---------------------------------
	   * Call our end header delegate
	   *--------------------------------*/ 
    
    endheader(numVisibleCols);
        
    /*---------------------------------
	   * Process Body
	   *--------------------------------*/ 
    
    startbody();
	  
	  /*---------------------------------
	   * Traverse Nodes
	   *--------------------------------*/ 
    
    bool result = TraverseNodes (ref dtree, 
                                 id, 
                                 ref safetyCtr, 
                                 ref levelCtr, 
                                 op, 
                                 nodeenter, 
                                 nodeexit, 
                                 childrenenter, 
                                 childrenexit);    
    
    endbody();
    
    return result;
   
	  }		
  }
}