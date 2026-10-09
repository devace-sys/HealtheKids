using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace MBA.X12

{
	public static class ExtensionMethods
	{
		/// <summary>
    /// Extension method for <see cref="T:System.IO.TextReader"/> 
    /// Reads lines by delimeter character.
    /// Method courtesey of "Pete" <see cref="https://stackoverflow.com/a/6655492"/>
    /// </summary>
    /// <example>
    /// using (var sr = new StreamReader(@"c:\835_5010.x12", Encoding.Default))
    /// {
    ///   foreach (var segment in sr.ReadLines ('~'))
    ///       Console.WriteLine (segment);
    /// }
    /// </example>
    /// <returns>IEnumerable<string></returns>
    /// <param name="reader">Reader</param>
    /// <param name="delimiter">Delimiter character</param>

    public static IEnumerable <string> ReadLines (this TextReader reader, char delimiter)
		{
			var chars = new List<char>();
			while (reader.Peek() >= 0)
			{
			  char c = (char) reader.Read ();
        if (c == delimiter) {
          yield return new String(chars.ToArray());
          chars.Clear ();
          continue;
       }
       chars.Add(c);
      }
		}
        
    /// <summary>
    /// Adds item to ListBox in a thread safe fashion.  <see cref="T:System.Windows.Forms.ListBox"/> 
    /// This is a slightly modified version of extension method from
    /// Brett Dot Net <see cref="https://brettdotnet.wordpress.com/2014/06/06/c-add-an-item-to-a-winforms-listbox-thread-safe-extension/"/>
    /// </summary>
    /// <param name="lb">The list box</param>
    /// <param name="item">The item to add</param>

    public static void AddItemThreadSafe (this System.Windows.Forms.ListBox lb, object item)
    {      
      if (lb.InvokeRequired)
      {
          lb.Invoke(new MethodInvoker ( delegate {
            lb.Items.Add(item);           
            var idx = lb.Items.Count - 1;
            lb.SelectedIndex = idx;
          }));
      }
      else
      {
          lb.Items.Add(item);
          var idx = lb.Items.Count - 1;
          lb.SelectedIndex = idx;
      }
    }
	}
}
