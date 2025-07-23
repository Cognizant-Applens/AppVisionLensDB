/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[sp_GetESAID] --152
(
@projectid INT
)
AS
BEGIN
SET NOCOUNT ON;
	SELECT EsaProjectID as EsaProjectID 
	FROM [AVL].[MAS_ProjectMaster] (NOLOCK) 
	WHERE  IsDeleted=0 and ProjectID = @projectid
SET NOCOUNT OFF;
END


--select * from AVL.MAS_ProjectMaster where ProjectID=152
