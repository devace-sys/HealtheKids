using System;
using System.Collections.Generic;
using System.Text;
using MBA;

namespace DatabaseManagement
{
  class Program:ConsoleApp
  {
    static int Main(string[] args)
    {
      
      string                   appname       = "Database Management";
      List<ConsoleAppSwitch>   switcheslist  = new List<ConsoleAppSwitch>();
      List<ConsoleAppArgument> argumentslist = new List<ConsoleAppArgument>();

      return MainMethodCall(ref appname, ref switcheslist, ref argumentslist, ref args,
      
      delegate{
      
      });
      
    }
  }
}
