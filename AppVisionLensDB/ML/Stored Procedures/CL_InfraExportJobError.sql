/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[CL_InfraExportJobError]
	@ProjectID BIGINT 
  AS 
  BEGIN 
    SET  NOCOUNT ON 
      DECLARE @ContLearningID INT; 
	  DECLARE @CurrentDate DATE
	  DECLARE @JBDate DATETIME
	  SET @CurrentDate = CAST(GETDATE() AS DATE)
	  DECLARE @NextDayID INT = 5
      SET @JBDate= DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID) 
      SELECT TOP 1 @ContLearningID=ISNULL(ContLearningID,0)
                           FROM   ML.CL_PRJ_InfraContLearningState 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = 0 
                           ORDER  BY ContLearningID DESC     
      BEGIN TRY 
          BEGIN TRAN 
		
          IF @ProjectID = 0 
            BEGIN
				with CTE_CL_InfraProjectJobDetails(ProjectID,JobDate,IsDeleted) as
				(
					SELECT ProjectID, CAST(JobDate AS DATE),ISNULL(IsDeleted,0)
					FROM ML.CL_InfraProjectJobDetails WITH(NOLOCK)   
				)
                INSERT INTO ML.CL_InfraProjectJobDetails 
                            ([ProjectID], 
                             [JobDate], 
                             [StatusForJob], 
                             [CreatedBy], 
                             [CreatedDate], 
                             [IsDeleted]) 
                SELECT ProjectID, 
                       @JBDate, 
                       0, 
                       'SYSTEM', 
                       GETDATE(), 
                       0 
                FROM   CTE_CL_InfraProjectJobDetails 
                WHERE  JobDate = @CurrentDate
                       AND (IsDeleted = 0 ) 

                UPDATE C 
                SET    PresentStatus = 5, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                FROM   ML.CL_PRJ_InfraContLearningState C 
                       INNER JOIN ML.CL_InfraProjectJobDetails P 
                               ON P.ProjectID = C.ProjectID 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate 
                       AND ISNULL(C.IsDeleted, 0) = 0 
                       AND CAST(P.CreatedDate AS DATE) = @CurrentDate
                       AND P.IsDeleted = 0 
                       AND PresentStatus = 3 

                UPDATE ML.CL_InfraProjectJobDetails 
                SET    StatusForJob = 1, 
                       HasError = 1, 
                       IsDeleted = 1, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate
                       AND ( ISNULL(IsDeleted, 0) = 0 )
                           

                UPDATE [ML].[CL_InfraContLearningMLJobStatus] 
                SET    CLJobStatus = 0 ,
				       ModifiedDate = GETDATE(),
					   ModifiedBy = 'SYSTEM'
                WHERE  ISNULL(IsDeleted, 0) = 0 
            END 
          ELSE 
            BEGIN 
                UPDATE [ML].[CL_InfraContLearningMLJobStatus] 
                SET    CLJobStatus = 0, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 
                       AND ContLearningID = @ContLearningID 

                UPDATE ML.CL_PRJ_InfraContLearningState 
                SET    PresentStatus = 5, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 
                       AND ContLearningID = @ContLearningID 

                UPDATE ML.CL_InfraProjectJobDetails 
                SET    StatusForJob = 1, 
                       HasError = 1, 
                       IsDeleted = 1, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate 
                       AND ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 
				
				;with CTE_CL_InfraProjectJobDetail(ProjectID,JobDate,IsDeleted) as
				(
					SELECT ProjectID, CAST(JobDate AS DATE),ISNULL(IsDeleted,0)
					FROM ML.CL_InfraProjectJobDetails WITH(NOLOCK)   
				)

                INSERT INTO ML.CL_InfraProjectJobDetails 
                            ([ProjectID], 
                             [JobDate], 
                             [StatusForJob], 
                             [CreatedBy], 
                             [CreatedDate], 
                             [IsDeleted]) 
                SELECT ProjectID, 
                       @JBDate, 
                       0, 
                       'SYSTEM', 
                       GETDATE(), 
                       0 
                FROM   CTE_CL_InfraProjectJobDetail 
                WHERE  JobDate = @CurrentDate 
                       AND ISDELETED = 0 
                       AND ProjectID = @ProjectID 

                UPDATE AVL.MAS_ProjectDebtDetails 
                SET    ISCLSIGNOFF = 0, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  ProjectID = @ProjectID 
                       AND ISCLSIGNOFF = 1; 
            END 
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
	      ROLLBACK TRAN 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            'ML.CL_InfraExportJobError', 
            @ErrorMessage, 
            @ProjectID, 
            @ContLearningID 
      END CATCH 
  END
