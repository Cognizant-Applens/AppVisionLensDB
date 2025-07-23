/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--[MS].[GetSupportCategory] 12223
CREATE PROCEDURE [MS].[GetSupportCategory](
@ProjectId bigint=NULL
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;

SELECT B.ProjectSUPPORTCATEGORYID AS MainspringSupportCategoryID,SUPPORTCATEGORYName AS MainspringSupportCategoryName
FROM [MAS].[SupportCategory] A With (NoLock)
INNER JOIN [MS].[ProjectSupportCategory] B With (NoLock)
ON A.SUPPORTCATEGORYID=B.SUPPORTCATEGORYID
WHERE B.ProjectID =@ProjectId AND A.IsDeleted=0 AND B.Isdeleted =0

END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[MS].[GetSupportCategory]', @ErrorMessage, @ProjectId
	END CATCH  
END
