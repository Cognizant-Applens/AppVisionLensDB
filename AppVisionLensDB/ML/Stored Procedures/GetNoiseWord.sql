-- ============================================= 
-- Author:    683989 
-- Create date: 04/01/2019 
-- Description:   SP user to get noise word,if IsTicketDescription is 1 called TicketDescriptional noiseword and 0 is called for optional  noiseword
-- [ML].[GetNoiseWord] '1000198081',0
-- =============================================  
CREATE PROCEDURE [ML].[GetNoiseWord] (                                                  
                  @ESAProjectID NVARCHAR(100),
				  @IsTicketDescription BIT 
				  ) 
AS 
  BEGIN 
      BEGIN TRY 
	  
	  SET NOCOUNT ON
	   
	   IF(@IsTicketDescription=1)
	   BEGIN
	 
		SELECT  DISTINCT TD.ProjectID,TicketDescNoiseWord AS NoiseWord
		FROM   ML.TicketDescNoiseWords TD WITH (NOLOCK) 
		JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) 
		ON PM.ProjectID=TD.ProjectID
		WHERE ESAProjectID=@ESAProjectID
		AND TD.IsActive = 0
		AND PM.IsDeleted = 0
	  END
	 ELSE
		BEGIN
		
			SELECT DISTINCT NW.ProjectID,OptionalFieldNoiseWord AS NoiseWord
			FROM   ML.OptionalFieldNoiseWords  NW WITH (NOLOCK)
			JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK)
			ON PM.ProjectID=NW.ProjectID
			WHERE ESAProjectID=@ESAProjectID
			AND NW.IsActive = 0
			AND PM.IsDeleted = 0
		END
			
		
      SET NOCOUNT OFF
	  END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 
          DECLARE @ErrorSeverity INT; 
          DECLARE @ErrorState INT; 

          SELECT @ErrorMessage = Error_message() 

          SELECT @ErrorSeverity = Error_severity() 

          SELECT @ErrorState = Error_state() 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[ML].[GetNoiseWord]', 
            @ErrorMessage, 
            @ESAProjectID, 
            0 
      END CATCH 
  END
