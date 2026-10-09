USE [spedmon]
GO

/* Routine was replaced with Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers.sql*/
/* TODO: Remove this file once we have updated all platforms */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_Data_Received_Parse_Assign_Line_Numbers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse_Assign_Line_Numbers]
GO

