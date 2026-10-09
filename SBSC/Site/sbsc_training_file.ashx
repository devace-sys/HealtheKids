<%@ WebHandler Language="C#" Class="Spedmon.SBSCTrainingFileHandler"%>

using System;
using System.Web;
using MBA;

namespace Spedmon
{
  public class SBSCTrainingFileHandler : MBA.MediaFileHandler
  {
    public SBSCTrainingFileHandler():base()
    {
	  this.FilesRoot = @"C:\spedmon\data\files\SBSC-Training\";
	}
  }
}
