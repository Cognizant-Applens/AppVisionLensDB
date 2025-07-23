/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC  ProjectDebtDetailsdate 89401
CREATE PROCEDURE [dbo].[ProjectDebtDetailsdate]
	-- Add the parameters for the stored procedure here
	@ProjectID int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--IF EXISTS(SELECT 1 FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID AND IsDDAutoClassifiedDate IS NOT NULL AND IsDeleted = 0)
	--BEGIN
	--	SELECT  max(EffectiveDate) AS IsDDAutoClassifiedDate FROM AVL.Debt_MAS_ProjectDataDictionary WHERE ProjectID = @ProjectID AND IsDeleted = 0
	--END
	--ELSE
	--BEGIN
		SELECT  IsDDAutoClassifiedDate AS IsDDAutoClassifiedDate FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0
	--END
	SET NOCOUNT OFF;

END
