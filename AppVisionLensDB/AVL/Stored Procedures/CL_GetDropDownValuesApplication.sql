/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_GetDropDownValuesApplication] 
	
@projectID bigint,
@portfolioID bigint,
@CustomerID bigint
AS
BEGIN
BEGIN TRY
SELECT 
		DISTINCT AD.ApplicationID,
		ApplicationName 
FROM 
		AVL.BusinessClusterMapping BC 
JOIN 
		AVL.APP_MAS_ApplicationDetails AD
 ON 
		BC.BusinessClusterMapID=AD.SubBusinessClusterMapID
JOIN 
		AVL.APP_MAP_ApplicationProjectMapping AP 
ON
		AP.ApplicationID=AD.ApplicationID
WHERE	
		IsHavingSubBusinesss=0 
 AND
		 (BC.IsDeleted=0 or BC.IsDeleted is null)
AND 
		AD.SubBusinessClusterMapID=@portfolioID
 AND	
		BC.CustomerID=@CustomerID AND AP.IsDeleted=0 AND AP.ProjectID=@projectID;



	END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

	  
		EXEC AVL_InsertError '[AVL].[[CL_GetDropDownValuesApplication]]', @ErrorMessage, @portfolioID, 0 
		
	END CATCH  
END
