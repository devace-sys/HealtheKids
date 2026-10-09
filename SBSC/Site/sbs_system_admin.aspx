<%@Page Language="C#" CodeBehind="sbs_system_admin.aspx.cs" Inherits="Spedmon.SystemAdmin"%>

<%/************************/%>
<%/* System Admin         */%>
<%/* System Administration*/%>
<%/************************/%>

<Spedmon:Button ID="cde"  onclick="$.spedmonWebUI.dialogGetCdeDirectoryEntry()"         runat="server">CDE Directory Scraper Lookup Test</Spedmon:Button>
<Spedmon:Button ID="usps" onclick="$.spedmonWebUI.dialogValidateAddress()"              runat="server">USPS Validate Address API Test</Spedmon:Button>
<Spedmon:Button ID="goog" onclick="$.spedmonWebUI.dialogComputeDistanceAndTravelTime()" runat="server">Google Distance Matrix API Test</Spedmon:Button>

