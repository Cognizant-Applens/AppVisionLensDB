CREATE PROCEDURE [ML].[Infra_InsertMLJobId] (@ID BIGINT, 
                                     @InitialLearningID NVARCHAR(50), 
                                     @MLJobId           NVARCHAR(500) = null, 
                                     @JobType           NVARCHAR(10), 
                                     @JobMessage        NVARCHAR(MAX), 
                                     @UserID            NVARCHAR(20),                                      
									 @MLJobState BIT 
									
									 ) 
AS 
  BEGIN 
  SET NOCOUNT ON
      BEGIN TRY 
          BEGIN TRAN 
          
			IF @MLJobState = 0
			BEGIN
			INSERT INTO ML.InfraTRN_MLJobStatus	
                      (ProjectID, 
                       InitialLearningID, 
                       JobIdFromML,                        
                       InitiatedBy, 
                       JobMessage, 
                       JobType, 
                       CreatedOn, 
                       CreatedBy, 
                       IsDeleted) 
          VALUES     (@ID, 
                      @initialLearningId, 
                      null,                  
                      @UserID, 
                      'Sent', 
                      @JobType, 
                      GETDATE(), 
                      @UserID, 
                      0) 

			END
			ELSE
			BEGIN
				UPDATE IL SET IL.JobIdFromML=@MLJobId
				FROM ML.InfraTRN_MLJobStatus	IL
				WHERE IL.ProjectID= @ID
				AND IL.InitialLearningID= @InitialLearningID
				AND IL.JobIdFromML IS NULL
			END               

           

		  SELECT TOP 1 ID FROM ML.InfraTRN_MLJobStatus (NOLOCK)
		  WHERE ProjectID=@ID AND 
		  InitialLearningID= @InitialLearningID AND 
		  JobType = @JobType
		  ORDER BY CreatedOn DESC

		  COMMIT TRAN

      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[ML].[Infra_InsertMLJobId] ', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
	  SET NOCOUNT OFF
  END
