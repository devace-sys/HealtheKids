
using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{
   
  public class NewsletterPageContentPrivateViw : Spedmon.NewsletterPageViewContentHandler
  {
    
    public NewsletterPageContentPrivateViw()
    {

      this._permittedRoles = Spedmon.Constants.ROLE_ALL;  // todo: double-check, triplecheck permissions on this


      this._cbReturnNewsletterPage = delegate()
      {

        return Spedmon.NewsletterPages.returnContentSelection ( dbConnApp, log, uInfo, recID );

      };


    }
  }
}

