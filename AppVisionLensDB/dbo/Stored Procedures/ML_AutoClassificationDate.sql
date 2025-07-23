/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_AutoClassificationDate]
(
@ProjectID NVARCHAR(200),
@UserId NVARCHAR(10)
)
AS 
BEGIN
BEGIN TRY
select ISNULL(CONVERT(varchar(10),debt.MLSignOffDate,110),'') AS MLSignOffDate
from [AVL].[Debt_MAS_ProjectDebtDetails] debt join [AVL].[MAS_ProjectMaster] prj 
on prj.EsaProjectID =debt.EsaProjectID where prj.projectid=@projectid AND prj.IsDeleted=0
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_AutoClassificationDate] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
