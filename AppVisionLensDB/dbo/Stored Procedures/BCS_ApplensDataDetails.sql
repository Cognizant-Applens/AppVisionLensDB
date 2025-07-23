/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_ApplensDataDetails]
AS
select PriorityID,PriorityName from [AVL].[TK_MAS_Priority]  
select DARTStatusID,DARTStatusName from [AVL].[TK_MAS_DARTTicketStatus] WHERE IsDeleted = 0  
select TicketTypeID,TicketTypeName from [AVL].[TK_MAS_TicketType] WHERE IsDeleted = 0 AND SupportTypeId IN ( 1,3)