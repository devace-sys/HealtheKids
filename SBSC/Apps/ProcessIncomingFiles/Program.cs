using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using Spedmon;
using MBA;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;


namespace Spedmon
{

    /***************************************************************************
     * FileUploadProcessIncomingFilesApp */
    /**
     * Application class
     ***************************************************************************/

    class FileUploadProcessIncomingFilesApp : ProcessUploadFile
    {

        /***************************************************************************
         * Main */
        /**
         * Entry point
         ***************************************************************************/
        static void Main(string[] args)
        {
            ProcessUploadFile.StartProcessingFiles(args);

            /*============================================================
             * Exit
             *============================================================*/

            exit();
        }
    }
}
