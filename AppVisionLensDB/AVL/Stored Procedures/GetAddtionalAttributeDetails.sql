/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetAddtionalAttributeDetails]
AS
SET NOCOUNT ON
 SELECT  EscalatedFlagCustomerId AS Id,[Escalated Flag Customer]  AS Value FROM AVL.ITSM_MAS_EscalatedFlagCustomer With (NOLOCK);
 SELECT  NatureOfTheTicketId AS Id,[Nature Of The Ticket]  AS Value FROM AVL.ITSM_MAS_Natureoftheticket With (NOLOCK);
 SELECT  OutageFlagId AS Id,[Outage Flag]  AS Value FROM AVL.ITSM_MAS_OutageFlag With (NOLOCK);
 SELECT  WarrantyIssueId AS Id,[Warranty Issue]  AS Value FROM AVL.ITSM_MAS_WarrantyIssue With (NOLOCK);
 SELECT AvoidableFlagID AS Id,AvoidableFlagName AS Value FROM AVL.DEBT_MAS_AvoidableFlag With (NOLOCK) where IsDeleted=0;
 SELECT ResidualDebtID AS Id,ResidualDebtName AS Value FROM AVL.DEBT_MAS_ResidualDebt With (NOLOCK);
  SELECT [MetSLAId] AS Id,[MetSLAName] AS Value FROM [AVL].[TK_MAS_MetSLACondition] With (NOLOCK)
  --UNION
  --SELECT  0 AS [MetSLAId],'N/A' AS Value


RETURN 0
