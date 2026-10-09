<%@Page Language="C#" CodeBehind="browser_unsup.aspx.cs" Inherits="Spedmon.BrowserUnsupMsg" %>

<Spedmon:WebMsgProblem runat="server">
You are seeing this message because the application that you use to access the Internet (web browser) is either:
<ul>
<li>an old version of a supported web browser, for example Internet Explorer 6</li>
<li>a web browser we have not tested with this web application</li>
</ul>
</Spedmon:WebMsgProblem>

<Spedmon:WebMsgSolution runat="server">
This web application supports two most current versions of Firefox, Chrome, Safari, Internet Explorer, and Edge.
Please install and try one of these browsers.
</Spedmon:WebMsgSolution>
