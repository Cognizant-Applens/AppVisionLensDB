/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Annadurai
-- Create date : 06.07.2019
-- Description : Procedure used to get SharePath Details from dbo.TicketUploadProjectConfiguration table
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [dbo].[ProjectMigration_GetSharePathProjectID]
(
	@ESAProjectID nvarchar(max)
)
AS
BEGIN

	DECLARE @CustomerIds NVARCHAR(MAX)
	DECLARE @ESAProjectIds NVARCHAR(MAX)
	DECLARE @IsDeleted INT = 0;
    DECLARE @ProjectDetailsITSM TABLE 
	( 
		CustomerID INT,
		ProjectID INT
	)

	INSERT INTO @ProjectDetailsITSM
		SELECT DA.CustomerID AS CustomerID, PM.ProjectID  
		FROM AVL.MAS_ProjectMaster (NOLOCK) PM
		JOIN AVL.Customer (NOLOCK) DA 
			ON DA.CustomerID = PM.CustomerID AND DA.IsDeleted = @IsDeleted AND PM.IsDeleted = @IsDeleted 
		WHERE PM.ESAProjectID = @ESAProjectID	

	SELECT TUPC.TicketUploadPrjConfigID, PM.EsaProjectID, TUPC.ProjectID, 
		   TUPC.TicketSharePathUsers
	FROM [dbo].[TicketUploadProjectConfiguration] (NOLOCK) TUPC
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM 
		ON TUPC.ProjectID = PM.ProjectID AND PM.IsDeleted = @IsDeleted
	JOIN AVL.Customer (NOLOCK) cust 
		ON cust.CustomerID = PM.CustomerID AND cust.IsDeleted = @IsDeleted
	JOIN @ProjectDetailsITSM prjdet 
		ON prjdet.CustomerID = cust.CustomerID AND prjdet.ProjectID = PM.ProjectID

END
