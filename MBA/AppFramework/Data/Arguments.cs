using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  
  /***************************************************************************
   * Arguments */
  /**
   * Helper class to create an argument string
   *
   * @param  delimiter    Delimiter to seperate arguments in string.  If none
   *                      is supplied Arguments.defaultDelimiter
   ***************************************************************************/   
  
  public class Arguments
  {

   /*-------------------------------------------------------------------------
    *                  Constructors and protected methods
    *------------------------------------------------------------------------*/

    protected   String         _delm;       // Delimiter to use
    protected   List<String>   _args;       // Arguments list
       
    public Arguments():this(Arguments.defaultDelimiter){}
    public Arguments(string delimiter)
    {
      _delm = delimiter;
      _args = new List<String>();
    }

    /***************************************************************************
     * join */
    /**
     * Creates our argument string
     *
     * @return   Argument string
     ***************************************************************************/   
    
    protected string join()
    {
      if (_args.Count == 0) return "";
      if (_args.Count == 1) return _args[0];
      return String.Join(_delm,_args.ToArray());
    }
   
   /*-------------------------------------------------------------------------
    *                        Properties and Methods
    *------------------------------------------------------------------------*/

    /***************************************************************************
     * add */
    /**
     * Adds an argument to the argument string
     *
     * @param  arg  Argument to add
     * @param  args Arguments to add
     ***************************************************************************/   

    public void add (string arg)
    { 
     // TODO: Make more robust by searching and replacing old argument with same name
      _args.Add(arg);
      return;
    }

    public void add (string[] args)
    {
      foreach (string arg in args) _args.Add(arg);
      return;
    }

    /***************************************************************************
     * count */
    /**
     * Returns the number of arguments in the string
     *
     * @param    arg    Argument to add
     * @return   Number of arguments
     ***************************************************************************/   
    
    public int count {get{return _args.Count;}}

    /***************************************************************************
     * delimiter */
    /**
     * Returns the delimiter used
     *
     * @return   Delimiter used
     ***************************************************************************/   
   
    public string delimiter {get{return _delm;}}

    /***************************************************************************
     * isEmpty */
    /**
     * Returns true if the argument string is blank
     *
     * @return   true  = argument string is empty (no arguments)
     *           false = argument string has arguments
     ***************************************************************************/   

    public bool isEmpty {get{if (_args.Count == 0) return true; else return false;}}
    
    /***************************************************************************
     * ToString */
    /**
     * Returns the argument string
     *
     * @return   Argument string
     ***************************************************************************/   

    public override string ToString()
    {
      string ts = this.join();
      return ts;
    }

    /***************************************************************************
     * view */
    /**
     * Returns the arguments
     *
     * @return   Argument string
     ***************************************************************************/   
    
    public string[] view {get{return _args.ToArray();}}

    
    /*-------------------------------------------------------------------------
     *                  Static properties and methods
     *------------------------------------------------------------------------*/

    
    /***************************************************************************
     * defaultDelimiter */
    /**
     * The default delimiter for toString()
     ***************************************************************************/   
    
    public static string defaultDelimiter = ",";

    
    /***************************************************************************
     * concat */
    /**
     * Combines two Arguments objects into one
     *
     * @param    args1      Arguments object
     * @param    args2      Arguments object
     * @param    delimiter  Delimiter to use for new Arguments object
     * @return   Arguments object
     ***************************************************************************/   
    
    public static Arguments concat(Arguments args1, Arguments args2)
    {
      return concat(args1,args2,Arguments.defaultDelimiter);
    }

    public static Arguments concat(Arguments args1, Arguments args2, string delimiter)
    {
      Arguments argsOut  = new Arguments(delimiter);
      if (!args1.isEmpty) argsOut.add(args1.view);
      if (!args2.isEmpty) argsOut.add(args2.view);
      return argsOut;
    }
    
  }
}
