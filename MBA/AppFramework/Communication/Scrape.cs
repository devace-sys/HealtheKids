using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Net;
using HtmlAgilityPack;

namespace MBA
{
  
  /***************************************************************************
   * Scrape */
  /**
   * Our base class for site scraping.
   * TODO: This is not ready for use.  Finish.
   * TODO: Document methods
   ***************************************************************************/
  
  public class Scrape
  {
    public static ReturnScrape Get (string url, params NameValue[] parms)
    {
       ReturnScrape so = new ReturnScrape();
       
       so.doc    = new HtmlDocument();
       so.url    = url;
       so.parms  = parms;
       
       if (parms.Length > 0)
         so.link = Util.createLink(url, parms);
       else
         so.link = url;
         
       WebClient wc = new WebClient();                     
       wc.Encoding  = Encoding.UTF8;

       so.html      = wc.DownloadString(so.link);       
       so.doc.LoadHtml(so.html);
       
       return so;
         
    }
        
    public static HtmlNodeCollection SelectNodes (HtmlDocument doc, string path)
    {            
      return doc.DocumentNode.SelectNodes(path);
    }
    
    public static List<String> SelectNodeLines (HtmlDocument doc, string path)
    {
      List<String>       lines = new List<string>();
      HtmlNodeCollection nodes = Scrape.SelectNodes(doc,path);
      
      foreach (HtmlNode node in nodes)
      {
        lines.Add(node.InnerHtml);
      }
      
      return lines;
    }
      
  }
}
