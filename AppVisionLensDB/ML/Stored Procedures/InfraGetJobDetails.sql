CREATE PROCEDURE [ML].[InfraGetJobDetails]
	AS
BEGIN 
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
BEGIN TRY
BEGIN TRAN

DECLARE @JBDate DATETIME
DECLARE @NextDayID INT = 5
      SET @JBDate= DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID)

SELECT 
		CT.ProjectID,CT.ContLearningID,ML.OutputFileName,DataPath,ML.JobMessage 
FROM 
		ML.CL_PRJ_InfraContLearningState(NOLOCK) CT 
JOIN 
		ML.CL_InfraContLearningMLJobStatus(NOLOCK) ML 
ON 
		ML.ContLearningID=CT.ContLearningID 
AND 
		ML.ProjectID=CT.ProjectID 
WHERE 
		ML.CLJobStatus=2 
AND 
		CT.PresentStatus=3
AND		CT.IsDeleted=0 
AND     ML.IsDeleted=0;

INSERT INTO ML.CL_InfraProjectJobDetails 
                            ([ProjectID], 
                             [JobDate], 
                             [StatusForJob], 
                             [CreatedBy], 
                             [CreatedDate], 
                             [IsDeleted]) 
                SELECT DISTINCT CT.ProjectID, 
                       @JBDate, 
                       0, 
                       'SYSTEM', 
                       GETDATE(), 
                       0 
                FROM 
					ML.CL_PRJ_InfraContLearningState(NOLOCK) CT  
					JOIN 
							ML.CL_InfraContLearningMLJobStatus(NOLOCK) ML 
					ON 
							ML.ContLearningID=CT.ContLearningID 
					AND 
							ML.ProjectID=CT.ProjectID 
					WHERE 
							ML.CLJobStatus IN(1,2,3)
					AND 
							CT.PresentStatus=3;

UPDATE 
		CT 
SET 
		CT.PresentStatus=5 
FROM 
		ML.CL_PRJ_InfraContLearningState CT  
JOIN 
		ML.CL_InfraContLearningMLJobStatus ML 
ON 
		ML.ContLearningID=CT.ContLearningID 
AND 
		ML.ProjectID=CT.ProjectID 
WHERE 
		ML.CLJobStatus IN(1,3)
AND 
		CT.PresentStatus=3;
COMMIT TRAN				
END TRY  
BEGIN CATCH  
ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[ML].[InfraGetJobDetails] ', @ErrorMessage, 0,0
END CATCH
SET NOCOUNT OFF
END
