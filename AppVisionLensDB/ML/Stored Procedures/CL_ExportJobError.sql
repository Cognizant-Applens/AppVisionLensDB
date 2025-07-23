/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[CL_ExportJobError] 
  -- Add the parameters for the stored procedure here 
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
      SET @ContLearningID=(SELECT TOP 1 ContLearningID 
                           FROM   ML.CL_PRJ_ContLearningState 
                           WHERE  ProjectID = @ProjectID 
                                  AND IsDeleted = 0 
                           ORDER  BY ContLearningID DESC) 

      SET @ContLearningID=ISNULL(@ContLearningID,0)
      

      BEGIN TRY 
          BEGIN TRAN 

          IF @ProjectID = 0 
            BEGIN 
                INSERT INTO ML.CL_ProjectJobDetails 
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
                FROM   ML.CL_ProjectJobDetails 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate
                       AND (ISNULL(IsDeleted,0) = 0 ) 

                UPDATE C 
                SET    PresentStatus = 5, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                FROM   ML.CL_PRJ_ContLearningState C 
                       INNER JOIN ML.CL_ProjectJobDetails P 
                               ON P.ProjectID = C.ProjectID 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate 
                       AND ISNULL(C.IsDeleted, 0) = 0 
                       AND CAST(P.CreatedDate AS DATE) = @CurrentDate
                       AND P.IsDeleted = 0 
                       AND PresentStatus = 3 

                UPDATE ML.CL_ProjectJobDetails 
                SET    StatusForJob = 1, 
                       HasError = 1, 
                       IsDeleted = 1, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate
                       AND ( ISNULL(IsDeleted, 0) = 0 )
                           

                UPDATE [ML].[CL_ContLearningMLJobStatus] 
                SET    CLJobStatus = 0 ,
				       ModifiedDate = GETDATE(),
					   ModifiedBy = 'SYSTEM'
                WHERE  ISNULL(IsDeleted, 0) = 0 
            END 
          ELSE 
            BEGIN 
                UPDATE [ML].[CL_ContLearningMLJobStatus] 
                SET    CLJobStatus = 0, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 
                       AND ContLearningID = @ContLearningID 

                UPDATE ML.CL_PRJ_ContLearningState 
                SET    PresentStatus = 5, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 
                       AND ContLearningID = @ContLearningID 

                UPDATE ML.CL_ProjectJobDetails 
                SET    StatusForJob = 1, 
                       HasError = 1, 
                       IsDeleted = 1, 
                       ModifiedBy = 'SYSTEM', 
                       ModifiedDate = GETDATE() 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate 
                       AND ISNULL(IsDeleted, 0) = 0 
                       AND ProjectID = @ProjectID 

                INSERT INTO ML.CL_ProjectJobDetails 
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
                FROM   ML.CL_ProjectJobDetails 
                WHERE  CAST(JobDate AS DATE) = @CurrentDate 
                       AND ISNULL(ISDELETED, 0) = 0 
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
            'ML.CL_EXPORTJOBERROR', 
            @ErrorMessage, 
            @ProjectID, 
            @ContLearningID 
      END CATCH 
  END
