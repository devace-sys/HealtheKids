using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA.Reporting
{
    public interface DataFileDistributable
    {
        // https://stackoverflow.com/questions/1593413/how-to-implement-a-property-in-an-interface
        int status {get;}
        string message {get;}

        Byte[] DataToPDF();
        Byte[] DataToXLS();
        Byte[] DataToHTML();

        string GenerateFileName(string ext);

    }
}
