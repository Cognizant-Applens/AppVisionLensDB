/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetTicketModuleAttributes]

@serviceid INT,
@ProjectId VARCHAR(50)
AS

begin

DECLARE @TicketAttributeIntegration INT
DECLARE @IsDebt VARCHAR(5)
DECLARE @IsMainspring VARCHAR(5)
SET @TicketAttributeIntegration = (SELECT isnull(TicketAttributeIntegartion,0) AS tt FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId AND IsDeleted = 0)
SET @IsDebt = (SELECT isnull(IsDebtEnabled,0) AS d FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId)
SET @IsMainspring = (SELECT isnull(IsMainSpringConfigured,0) AS m FROM AVL.MAS_ProjectMaster WHERE ProjectID = @ProjectId)
end
