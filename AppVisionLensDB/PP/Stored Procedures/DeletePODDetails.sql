/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[DeletePODDetails]
(
@PODDetailID BIGINT
)
AS
BEGIN 
SET NOCOUNT ON

	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM PP.Project_PODDetails WHERE PODDetailID=@PODDetailID)
		BEGIN

		DELETE FROM ADM.AssociateAttributes WHERE PODDetailID =@PODDetailID	
			DELETE FROM pp.Project_PODDetails WHERE PODDetailID=@PODDetailID --and ProjectID=@ProjectID

				--UPDATE PP.Project_PODDetails SET IsDeleted=1 WHERE PODDetailID=@PODDetailID;
		--UPDATE [ADM].[AssociateAttributes] SET IsDeleted=1 WHERE PODDetailID=@PODDetailID;
		SELECT TOP 1 1 as 'Result'
		END
	END TRY
	BEGIN CATCH
		
	END CATCH
	SET NOCOUNT OFF
END
