using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA.IdentifyData;
using System.Web.Script.Serialization;

namespace MBA
{
  
  /***************************************************************************
   * ReturnDB */
  /**
   * Our internal return class for database i/o.  This is an intermediate 
   * structure that can be directly parsed for reports or processed further
   * to populate output classes.  For testing purposes you may also find
   * returning this class as part of a service call useful.
   ***************************************************************************/   

  public class ReturnDB : Return
  //TODO: figure out some way to have returnDB have built-in filtering, cacheing, paging, and subquerying functionality
  //this solves two problems: we, the developers, don't need to write an entirely new SQL query and C# method when we want to filter results
  //from a query that has already been written
  //secondly, maybe it would be nice if we didn't have to hit the database & run the query a second time when we want page 2 of a dataset
  {
    public ReturnDB ()                 : base()    {}
    public ReturnDB (string msg)       : base(msg) {}
    public ReturnDB (Exception e)      : base(e)   {}
    public ReturnDB (Warning e)        : base(e)   {}
    public ReturnDB (Critical e)       : base(e)   {}
    public ReturnDB (SessionExpired e) : base(e)   {}
    
    public CommandType    commandType;
    public string         commandText;
    
    public int          rowLimit;
    public bool         hasRecords;
    public bool         hasSpDetails;
    public bool         hasOutputParms;
    
    public Record[]     records; //instead of a generic, C-style array, maybe we could have some sort of indexed array, mapped array,
                                 //maybe a dictionary, idk.  I'm sure this has already been done before

    // as per StackExchange: "The nature of arrays is that their length is immutable. You can't add or delete any of the array items."
    // https://stackoverflow.com/a/457466

    //public ReturnDB(List<Record> list_of_records)
    //{
    //    records = list_of_records.ToArray();
    //}
    // TODO: Since I can't refactor the entire codebase to use a ReturnDB with a List inside it, I'll cast the array to a List as-needed, and then
    // convert back to an array, as using this constructor.

    public Parameter[]  parameters; 
           
    public string additionalDataStr = @"";    
  }
}
