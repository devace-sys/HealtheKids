using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA.Reporting
{
    public interface ListItemWImage
    {
        // https://stackoverflow.com/questions/1593413/how-to-implement-a-property-in-an-interface

        string title {get;}
        string description {get;}
        string finePrint {get;}
        string imgSrc {get;}

    }
}
