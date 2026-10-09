<%@ WebHandler Language="C#" Class="Spedmon.HelpFileHandler"%>

using System;
using System.Web;
using MBA;

namespace Spedmon
{
  public class HelpFileHandler : MBA.MediaFileHandler
  {
    public HelpFileHandler():base()
    {
	  this.FilesRoot = @"C:\spedmon\data\files\help\";
	}
  }
}
