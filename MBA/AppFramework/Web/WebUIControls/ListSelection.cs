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

namespace MBA
{

  /***************************************************************************
   * SelectionListItem */
  /**
   * 
   ***************************************************************************/

  public class SubmittedListItem
  {
    public long   selectionIdx;
    public string selectionSource;
    public long   selectionFor;
    public long   selectionFrom;
    public string selectionName;
    public long   selectionValue;
    public bool   selectionMarked;
    public string selectionInputId;

    public SubmittedListItem()
    {
    }
   
  }

  /***************************************************************************
   * SelectionList */
  /**
   * 
   ***************************************************************************/

  public class SubmittedList
  {
    
    public string id;
    public string json;
    public List<SubmittedListItem> list;
    
    public SubmittedList()
    {
      this.id   = "";
      this.list = new List<SubmittedListItem>();
      this.json = "[]";      
    }
    
    public SubmittedList (string id, string json)
    {
      this.id = id;
      this.loadJSON(id,json);
    }
    
    public SubmittedList (string id, List<SubmittedListItem> list)
    {
      this.id = id;
      this.loadList(id,list);
    }
    
    protected void _PopulateInputID(string inputID)
    {
      int idx = 0;
      foreach (SubmittedListItem item in this.list)
      {
        if (String.IsNullOrEmpty(item.selectionInputId)) this.list[idx].selectionInputId = inputID;
        idx++;
      }
    }
    
    public void loadJSON (string inputID, string json)
    {
      if (String.IsNullOrEmpty(json)) json = "[]";
      this.list = (List<SubmittedListItem>)JSON.fromJSONString(json, typeof(List<SubmittedListItem>));      
      _PopulateInputID(inputID);
      this.json = JSON.toJSONString(this.list);
    }
    
    public void loadList (string inputID, List<SubmittedListItem> list)
    {      
      this.list = list;
      
      _PopulateInputID(inputID);
      this.json = JSON.toJSONString(this.list);       
    }
        
  }


  /***************************************************************************
   * SelectionLists */
  /**
   * 
   ***************************************************************************/
     
  public class SubmittedLists
  {
        
    public List<SubmittedList> lists;

    public SubmittedLists()
    {
      this.lists = new List<SubmittedList>();
    }
    
    public void Add (string id, string json)
    {
      SubmittedList l = new SubmittedList(id,json);
      this.lists.Add(l);
    }
    
    public void Add (string id, List<SubmittedListItem> list)
    {
      SubmittedList l = new SubmittedList(id,list);
      this.lists.Add(l);
    }
    

    
    public List<SubmittedListItem> Combine (out bool hasEmptyLists)
    {
      hasEmptyLists = false;
      
      List<SubmittedListItem> listCombined = new List<SubmittedListItem>();
      
      foreach (SubmittedList sellist in this.lists)
      {
        if (sellist.list.Count == 0) hasEmptyLists = true;
        
        foreach(SubmittedListItem listitem in sellist.list)
        {
          listCombined.Add(listitem);
        }
      }
      return listCombined;
    }
            
  }
   
  /***************************************************************************
   * SelectionListItems */
  /**
   * 
   ***************************************************************************/

  public class SubmittedListItems
  {

    /***************************************************************************
     * jsonListToList */
    /**
     * Converts jsonList into .NET list
     ***************************************************************************/      

    public static List<SubmittedListItem> jsonListToList (string jsonList)
    {
      return (List<SubmittedListItem>) JSON.fromJSONString(jsonList, typeof(List<SubmittedListItem>));
    }

    /***************************************************************************
     * jsonListsToList */
    /**
     * Combines lists into one
     ***************************************************************************/      

    public static List<SubmittedListItem> jsonListsToList (List<string> jsonLists, out bool hasEmptyLists)
    {
      List<SubmittedListItem> itemsCombined = new List<SubmittedListItem>();
      hasEmptyLists = false;

      foreach (string jsonList in jsonLists)      
      {
        List<SubmittedListItem> items = jsonListToList(jsonList);
        if (items.Count == 0) hasEmptyLists = true;
        foreach (SubmittedListItem item in items)
        {
          itemsCombined.Add(item);
        }
      }
      return itemsCombined;
     } 
  }  
}

