using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;


/**************************************************************************
 * LinkedListBox */
/**
 * renders a list of linkedList
 * 
 * @param  name             name
 * @param  value            value
 ****************************************************************************/
public class LinkedList
{
    public LinkedList(string elemMkup)
    {
        elementMkup = elemMkup;
    }
    public string elementMkup;
}

namespace MBA
{

    /**************************************************************************
     * LinkedListBox */
    /**
     * renders a list of linkedList
     * 
     * @param  name             name
     * @param  value            value
     ****************************************************************************/

    public class LinkedListBox : ControlBase
    {
        protected List<LinkedList> listItems = new List<LinkedList>();
        protected string _parentClass   = "spedmon-linked-list-box-parent";
        protected string _childrenClass = "spedmon-linked-list-box-child";

        public string parentClass   { get { return _parentClass; }   set { _parentClass = value;   } }
        public string childrenClass { get { return _childrenClass; } set { _childrenClass = value; } }

        public void addLinkedList(LinkedList item)
        {
            listItems.Add(item);
        }

        public LinkedListBox() : base() { }

        protected override void Render(HtmlTextWriter writer)
        {
            // render a UL element with li children
            writer.Write(@"<ul id=""{0}"" class=""{1}"">", ID, _parentClass); /* Open UL item */
            
            // for each item on the list, render an li element
            foreach (var ll in listItems)
            {
                writer.Write(@"<li class=""{0}"">{1}</li>", _childrenClass, ll.elementMkup);
            }

            writer.Write(@"</ul>"); /* Close UL item */
            base.Render(writer);
        }
    }
}
