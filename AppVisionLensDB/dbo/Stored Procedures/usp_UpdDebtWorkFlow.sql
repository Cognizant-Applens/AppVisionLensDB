/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--=========================================
-- Program Name:[usp_UpdDebtWorkFlow] 
-- Author: 
-- Description: To update the DebtWorkFlow.
--Created Date:
--Modified Date Modified By version Description: Dinesh K on 03-Apr for CAST
--==========================================


CREATE PROCEDURE [dbo].[usp_UpdDebtWorkFlow]            

    @DatalakePath VARCHAR(50) = NULL,           

    @DebtAnalysisWorkflowId INT  = NULL,

    @ModifiedBy CHAR(11) = NULL

AS  

BEGIN  

 SET NOCOUNT ON;

  

		IF(@DebtAnalysisWorkflowId > 0 AND @DebtAnalysisWorkflowId IS NOT NULL)

		BEGIN

			UPDATE dbo.DebtAnalysisWorkflow SET

			DatalakePath = @DatalakePath,

			ModifiedBy = @ModifiedBy,

			ModifiedDate = GETDATE() WHERE DebtAnalysisWorkflowId = @DebtAnalysisWorkflowId

			

			SELECT DebtAnalysisWorkflowId,

			DebtAnalysisId,

			RFPVersion,

			DatalakePath

			FROM dbo.DebtAnalysisWorkflow

		END		

				

END	

	

 SET NOCOUNT OFF;
