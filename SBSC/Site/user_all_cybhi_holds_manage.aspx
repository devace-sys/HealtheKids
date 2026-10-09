<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_cybhi_holds_manage.aspx.cs" Inherits="Spedmon.UserAllCybhiHoldsManage" %>
<%//##################################################################################################################%>
<%//#                                               Markup %>
<%//##################################################################################################################%>


<div class="alert alert-warning text-center">

  <p>The manage missing students information functionality has moved to its own dedicated page</p>

  <Spedmon:LinkInternal
           ID         = "gotomanageoverall"
           title       = "Manage Students With Missing Info"
           label       = "Manage Students With Missing Info"
           faClass     = "fa fa-link"
           url         = "user_all_manage_patients_with_missing_info.aspx"
           openNew     = "false"
           subWindow   = "false"
           runat       = "server" />
 
</div>

