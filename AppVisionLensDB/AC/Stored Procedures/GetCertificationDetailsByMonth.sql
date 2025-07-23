
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AC].[GetCertificationDetailsByMonth]    
	 @Month SMALLINT  NULL,
	 @Year INT  NULL
 AS
BEGIN    
 SET NOCOUNT ON;    
 BEGIN TRY   
	DECLARE @Zero SMALLINT = 0;
    SELECT DISTINCT 
			CategoryName,
			AwardName AS AwardReceived,
			EmployeeId AS AssociateID,
			EmployeeName AS AssociateName,
			CustomerName AS Account,
			BU.BusinessUnitName AS BusinessUnit,
			CONCAT(SUBSTRING( Certification.[Month], 1, 3 ),' - ',Certification.[Year]) AS AwardMonth			
        FROM [AC].[VW_GetCertificationDetails] Certification (NOLOCK)
        JOIN [MAS].[BusinessUnits] BU (NOLOCK) ON Certification.BUId =  BU.BusinessUnitId and BU.IsDeleted =@Zero
		WHERE Certification.[CertificationMonth]= @Month AND Certification.[Year] = @Year
		ORDER BY Certification.[EmployeeId] DESC;
 SET NOCOUNT OFF; 
 END TRY    
 BEGIN CATCH    
 DECLARE @errorMessage VARCHAR(MAX);    
    
   SELECT @errorMessage = ERROR_MESSAGE()    
    
   --INSERT Error        
   EXEC AVL_InsertError '[AC].[GetCertificationDetailsForMonth]',@errorMessage,'',0    
 END CATCH    
END
