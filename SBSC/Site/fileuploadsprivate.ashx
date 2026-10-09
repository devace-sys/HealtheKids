<%@ WebHandler Language="C#" Class="Spedmon.FileUploadsPrivatePage" %>

using System;
using System.Web;

namespace Spedmon
{
  public class FileUploadsPrivatePage : Spedmon.DataDrivenFormPageHandler
  {
    public FileUploadsPrivatePage():base(1, Spedmon.Constants.ROLE_ALL)
    {
    }
  }
}