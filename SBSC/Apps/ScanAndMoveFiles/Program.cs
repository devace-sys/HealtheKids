using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;

namespace ScanAndMoveFiles
{
    class Program
    {

        static void Main(string[] args)
        {
            /* Start with arg validation */
            try
            {
                if (args.Count() != 4)
                    throw new ArgumentOutOfRangeException("Incorrect argument count.");

                DirectoryInfo frmDir = new DirectoryInfo(args[0]);
                DirectoryInfo toDir = new DirectoryInfo(args[1]);
                FileInfo vScanExec = new FileInfo(args[2]);

                if ((frmDir.Exists == false) || (toDir.Exists == false))
                    throw new ArgumentException("One or more of the specified directories do not exist.");
                if (vScanExec.Exists == false)
                    throw new ArgumentException("The script or application specified does not exist.");
                int MaxExitCode;
                if (int.TryParse(args[3], out MaxExitCode) == false)
                    throw new ArgumentException("Provided exit code is not an integer value");




                List<FileInfo> FullFileListing = new List<FileInfo>();

                Console.WriteLine(String.Format("Looking at files in {0}", frmDir.FullName));
                Console.WriteLine(String.Format("Moving files to {0}", frmDir.FullName));

                FullFileListing.AddRange(SubDirParse(frmDir));

                foreach (FileInfo f in FullFileListing)
                {
                    using (Process appProcess = new Process())
                    {
                        appProcess.StartInfo.FileName = vScanExec.FullName;
                        appProcess.StartInfo.Arguments = f.FullName;
                        appProcess.Start();
                        appProcess.WaitForExit();
                        Console.WriteLine(appProcess.ExitCode);

                        if ((appProcess.HasExited == true) && (appProcess.ExitCode <= MaxExitCode))
                        {
                            string fNewLoc = f.FullName.Replace(frmDir.FullName, toDir.FullName);
                            Directory.CreateDirectory(Path.GetDirectoryName(fNewLoc));
                            f.MoveTo(fNewLoc);
                        }
                        else
                            Console.WriteLine(String.Format("Application exited with invalid code {0} for file {1}",appProcess.ExitCode, f.FullName));
                    }
                }
                Console.WriteLine("Finished processing files.");

            }

            catch (ArgumentException inputEx)
            {
                HelpvErr(inputEx.Message);
            }
        }

       static List<FileInfo> SubDirParse(DirectoryInfo dir)
        {
            List<FileInfo> files = new List<FileInfo>();
            if (dir.GetDirectories().Count() == 0)
            {
                files.AddRange(dir.GetFiles());
                return files;
            }
            else
            {
                foreach (DirectoryInfo sub in dir.GetDirectories())
                {
                    files.AddRange(SubDirParse(sub));
                }
                files.AddRange(dir.GetFiles());
                return files;
            }
        }

       static void HelpvErr(String ErrMsg)
       {
           Console.Write(ErrMsg);
           Console.WriteLine();
           Console.WriteLine("Usage: scanandmovefiles.exe [source directory] [target directory] [application to run @ source directory] [acceptable codes for application]");
       }

    }
}
