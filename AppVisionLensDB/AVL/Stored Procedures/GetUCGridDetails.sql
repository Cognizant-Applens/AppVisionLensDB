/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetUCGridDetails]
AS
BEGIN
      BEGIN TRY 
		SET NOCOUNT ON;


SELECT UseCaseId,
UseCaseTitle,
ApplicationName,
Technology,
SupportLevel,
ToolName,
AutomationFeasibility,
ToolClassification,
Tags,
BusinessProcess,
SubBusinessProcess,
OverallEffortSpent,
AverageNoofOccurrences,
SBUName,
AccountName,
ReferenceID,
EU.CreatedBy FROM AVL.Effort_UseCaseDetails EU
LEFT JOIN AVL.Effort_UseCaseRatings UR ON UR.UseCaseDetailID = EU.UseCaseDetailID 
      END TRY
	  BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE()   
          EXEC AVL_INSERTERROR 'AVL.GetUCGridDetails',  @ErrorMessage,  0 
      END CATCH 
END
