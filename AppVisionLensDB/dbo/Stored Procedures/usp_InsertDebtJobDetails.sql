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
-- Program Name:[usp_InsertDebtJobDetails]
-- Author: 
-- Description: To Insert Debt Job Details.
--Created Date:
--Modified Date Modified By version Description: Dinesh K on 03-Apr for CAST
--==========================================

CREATE PROCEDURE [dbo].[usp_InsertDebtJobDetails]                                      

	@JobId VARCHAR(100),

	@DebtAnalysisId INT,

	@DebtAnalysisWorkflowId INT,

	@StageId INT,

	@CreatedBy CHAR(11),

	@SolutionId INT

AS     

   BEGIN                                       

        SET NOCOUNT ON;

        

        INSERT INTO dbo.DebtJobDetails(JobId, DebtAnalysisId, DebtAnalysisWorkflowId, StageId, SolutionId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)

        VALUES(

        @JobId,

        @DebtAnalysisId,

        @DebtAnalysisWorkflowId,

        @StageId,

		@SolutionId,

        @CreatedBy,

        GETDATE(),

        @CreatedBy,

        GETDATE())

       

      SET NOCOUNT OFF;   

 END
