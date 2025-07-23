/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--exec GetResidualDetail 44670,222,299

CREATE PROCEDURE [dbo].[GetResidualDetail]
	-- Add the parameters for the stored procedure here
	@ProjectID int,
	@ApplicationID int,
	@RowID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select ReasonForResidual,ExpectedCompletionDate  from [AVL].[Debt_MAS_ProjectDataDictionary] (NOLOCK)
	where ProjectID = @ProjectID and ApplicationID = @ApplicationID and ID = @RowID
	SET NOCOUNT OFF;
END
