using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.IO;
using MySql.Data.MySqlClient;

namespace MantisProjects
{ 
  
  /***************************************************************************
   * MantisEntry */
  /**
   * Mantis entry.  Could be a project or an issue
   * 
   ***************************************************************************/  
  
  class MantisEntry
  {
    public enum EntryType {Project, Issue}
    
    public EntryType etype {get; set;}
    public int    level    {get; set;}
    public uint   id       {get; set;}
    public string name     {get; set;}

    public MantisEntry()
    {
    }
    
    public MantisEntry(EntryType etype, int level, uint id, string name)
    {
      this.etype = etype;
      this.level = level;
      this.id    = id;
      this.name  = name;
    }
    
    public string ToListItem()    
    {
      string cls   = this.etype.ToString();            
      string style = "margin-left:" + this.level.ToString() + "em;";            
      string li    = @"<li class=""" + cls + @""" style=""" + style + @""">" + this.name + @"</li>";      
      return li;    
    }
    
    public override string ToString()
    {
      StringBuilder _entry = new StringBuilder();      
      
      
      string lvl = "".PadRight(this.level,' ');
      
      
      int linpad = 120 - this.level;
      string lin = "".PadRight(linpad,'-');

      string lvllin = lvl + lin;
      
      if (this.etype == EntryType.Project)
      {
        _entry.AppendLine("");
        _entry.AppendLine(lvllin);
      }
      
      _entry.Append(lvl);
      
      if (this.etype == EntryType.Project)
        _entry.Append(" * ");

      if (this.etype == EntryType.Issue)
        _entry.Append("  - ");
      
      _entry.Append(this.name);
      _entry.Append(" [");
      _entry.Append(this.id.ToString());
      _entry.Append("]");
      
      if (this.etype == EntryType.Project)
      {
        _entry.AppendLine("");
        _entry.AppendLine(lvllin);
      }

      return _entry.ToString();
    }
  
  }

  /***************************************************************************
   * MainClass */
  /**
   * The program 
   * 
   ***************************************************************************/          
  
  class MainClass
	{

		protected static int               level;
		protected static string            connectionString;  
    protected static List<MantisEntry> entries;
    
    /***************************************************************************
     * OutputEntry */
    /**
     * Output a mantis entry
     * 
     ***************************************************************************/      				
		
		public static void OutputEntry (MantisEntry.EntryType etype, 
		                                int    level, 
		                                uint   id, 
		                                string name, 
		                                ref List<MantisEntry> entries)
    {      
      MantisEntry entry = new MantisEntry(etype,level,id,name); 
      entries.Add(entry);    
    }    
    
    /***************************************************************************
     * ViewIssues */
    /**
     * View mantis issues associated with a given project id
     * 
     ***************************************************************************/      				
		
		public static void ViewIssues (uint projectid, int level)
		{
		  /*-------------------------------
       * Note: We have to use a dedicated
       * database connection
       *------------------------------*/			
       				  		  
		  IDbConnection dbcon;
		  dbcon = new MySqlConnection(connectionString);
		  
		  try
		  {		  
       
        /*-------------------------------
         * Open connection
         *------------------------------*/		
        
        dbcon.Open();
         
		    /*-------------------------------
         * Create our command
         *------------------------------*/			
		    
		    IDbCommand dbcmd = dbcon.CreateCommand();
              
	      string sql = "select b.id, summary, description, status from mantis_bug_table as b " +
                     "left join mantis_bug_text_table as bt on bt.id = b.id " +
                     "where project_id = @pid and status <> 90;";
       
	      dbcmd.CommandText = sql;

        /*-------------------------------
         * Create parameters
         *------------------------------*/			 		 
		    
		    System.Data.IDbDataParameter parm = dbcmd.CreateParameter();
		    
        parm.ParameterName = "@pid";		 
		    parm.DbType        = DbType.UInt32;
		    parm.Direction     = ParameterDirection.Input;
		    parm.Value         = projectid;
      
        /*-------------------------------
         * Add them
         *------------------------------*/	
        
        dbcmd.Parameters.Add(parm);

 		    /*-------------------------------
         * Prepare command and execute
         *------------------------------*/		
		    
		    dbcmd.Prepare();		 
		    IDataReader reader = dbcmd.ExecuteReader(CommandBehavior.SingleResult);
						
		    /*-------------------------------
         * Retrieve results
         *------------------------------*/			

		    while(reader.Read())
	      {            		
  		    /*-------------------------------
           * Issue id and name
           *------------------------------*/			

		      uint   id   = (uint)   reader["id"];
	        string name = (string) reader["summary"];
	        
          OutputEntry (MantisEntry.EntryType.Issue,
                       level, 
                       id, 
                       name, 
                       ref entries);
		    }
         	      
			  /*-------------------------------
         * Cleanup and close
         *------------------------------*/	
       
	      reader.Close();
        reader = null;
        dbcmd.Dispose();
        dbcmd = null;
      
      }
		  catch(Exception e)
		  {
		    Console.WriteLine(e.ToString());
		  }
		  finally
		  {
		    dbcon.Close();
        dbcon = null;
      }
		}
		
		/***************************************************************************
     * ViewProjects */
    /**
     * View all child projects of a given parentID
     * 
     ***************************************************************************/      				
		
		public static void ViewProjects(uint parentID, ref int level)		
		{
		  
		  /*-------------------------------
       * Note: We have to use a dedicated
       * database connection
       *------------------------------*/			
		  
		  IDbConnection dbcon;
		  dbcon = new MySqlConnection(connectionString);		  
      
      try
		  {		
  		  
  		  /*-------------------------------
         * Open connection
         *------------------------------*/			
  		    		
        dbcon.Open();
         
  		  /*-------------------------------
         * Create our command
         *------------------------------*/			

		    IDbCommand dbcmd = dbcon.CreateCommand();
       
       
	      string sql = "select " +
                     "mpt.* " +
                     "from mantis_project_hierarchy_table as mph " +
                     "join mantis_project_table as mpt on mpt.id = mph.child_id " +
                     "where status <> 50 and parent_id = @pid order by name;";
       
	      dbcmd.CommandText = sql;

  		  /*-------------------------------
         * Create parameters
         *------------------------------*/			
		 		 
		    System.Data.IDbDataParameter parm = dbcmd.CreateParameter();
        
        parm.ParameterName = "@pid";		 
		    parm.DbType        = DbType.UInt32;
		    parm.Direction     = ParameterDirection.Input;
		    parm.Value         = parentID;

  		  /*-------------------------------
         * Add them
         *------------------------------*/			

        dbcmd.Parameters.Add(parm);

  		  /*-------------------------------
         * Prepare command and execute
         *------------------------------*/			

		    dbcmd.Prepare();		 
		    IDataReader reader = dbcmd.ExecuteReader(CommandBehavior.SingleResult);
       			
		    /*-------------------------------
         * Retrieve results
         *------------------------------*/			

		    while(reader.Read())
	      {            		
  		    
  		    /*-------------------------------
           * Project id and name
           *------------------------------*/			

		      uint   id     = (uint) reader["id"];
	        string name   = (string) reader["name"];
		      
		      OutputEntry (MantisEntry.EntryType.Project, 
		                   level, 
		                   id, 
		                   name, 
		                   ref entries);
		     
		      /*-------------------------------
           * View issues for this project
           *------------------------------*/
		      
		      ViewIssues(id, level);
		      		     
		      /*-------------------------------
           * View this projects sub projects
           *------------------------------*/
		      
		      level++;
		      ViewProjects(id, ref level);
          level--;
        }
        
		    /*-------------------------------
         * Cleanup and close
         *------------------------------*/			
       
	      reader.Close();
        reader = null;
        dbcmd.Dispose();
        dbcmd = null;
		  }
		  catch (Exception e)
		  {
		    Console.WriteLine(e.Message);
		  }
		  finally
		  {
		    dbcon.Close();
        dbcon = null;
      }
    }

		/***************************************************************************
     * Main */
    /**
     * Entry point for application
     * 
     ***************************************************************************/      				

    public static void Main (string[] args)
		{
		  try
		  {			
		    connectionString =
              "Server=sbscitdev.help4schools.com;" +
              "Database=bugtracker;" +
              "User ID=mantis;" +
              "Password=plmitrb71;" +
              "Pooling=true";         	    
      
        entries      = new List<MantisEntry>();      
		    level        = 0;
		    uint startid = 184; // 184 is start of SBSC

        ViewProjects(startid, ref level);			
      
        using (TextWriter writer = File.CreateText(@"c:\mantis.html"))
        {      
          writer.WriteLine(@"<!DOCTYPE html>");
          writer.WriteLine(@"<html>");
          writer.WriteLine(@"<head>");
          writer.WriteLine(@"<title>Mantis</title>");
          writer.WriteLine(@"<style type=""text/css"">");
          writer.WriteLine(@"li.Project{font-weight:bold;}");
          writer.WriteLine(@"li.Issue{font-weight:normal;padding-left:1em;}");          
          writer.WriteLine(@"</style>");
          
          writer.WriteLine(@"</head>");
          writer.WriteLine(@"<body>");
          writer.WriteLine(@"<ul style=""list-style-type: none;"">");
          foreach(MantisEntry entry in entries)
          {
            writer.WriteLine(entry.ToListItem());
          }
          writer.WriteLine("</ul>");
          writer.WriteLine(@"</body>");
          writer.WriteLine(@"</html>");

        }
      }
      catch (Exception e)
      {
        Console.WriteLine(e.Message);
      }
      finally
      {
        
      }
    }
  }
}
