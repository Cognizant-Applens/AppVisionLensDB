  
--[ML].[SavePrerequisiteDetails_Test] 10337,0,1,'02-16-2020','03-19-2020','683989',1,1  
  
CREATE PROCEDURE [ML].[SavePrerequisiteDetails]   
(  
 @ID BIGINT, --ProjectID  
 @IsOptionalField BIT,  
 @DebtAttribute INT,  
 @FromDate DATETIME,  
 @ToDate DATETIME,  
 @UserID NVARCHAR(10),  
 @IsTicketDescMapped BIT,  
 @IsRegenerate BIT  
)  
AS  
BEGIN  
  BEGIN TRY  
     BEGIN TRAN  
     SET NOCOUNT ON;  
  DECLARE @Result BIT;  
  DECLARE @Count BIGINT;  
  DECLARE @LearingID BIGINT;  
  DECLARE @LearnIDML BIGINT;  
  DECLARE @RegenerateFromDate DATETIME;  
  
  SELECT @Count=COUNT(ID) FROM ML.ConfigurationProgress(NOLOCK) WHERE ProjectID=@ID AND IsDeleted= 0  
    
    
   
  
  SET @LearingID =(case when @IsRegenerate=0 then (SELECT TOP 1 ID FROM   ML.ConfigurationProgress(NOLOCK)  
                  WHERE  projectid = @ID   
                  AND IsDeleted = 0                    
                  ORDER  BY ID DESC )   
       else (SELECT TOP 1 ID FROM   ML.ConfigurationProgress(NOLOCK)  
                  WHERE  projectid = @ID   
                  AND IsDeleted = 0 AND ISNULL(IsMLSentOrReceived,'') <> 'Received'                    
                  ORDER  BY ID ASC) END)  
        
  
     SET @LearnIDML = ( CASE WHEN  @Count>2 THEN  
       (SELECT TOP 1 ID FROM   ML.ConfigurationProgress(NOLOCK)  
                  WHERE  projectid = @ID   
                  AND IsDeleted = 0   
                  AND ISNULL(IsMLSentOrReceived,'') ='Received'   
                  ORDER  BY ID DESC) END)  
  
  SET @RegenerateFromDate = (CASE WHEN @Count>2 THEN (Select CONVERT(DATE,MIN(CreatedDate)) FROM ML.TRN_PatternValidation(NOLOCK)  
         WHERE ProjectID=@ID and InitialLearningID=@LearnIDML)  
         ELSE CONVERT(DATE,@FromDate) END)  
  
  
  MERGE ML.ConfigurationProgress  as ILC  
  USING (VALUES (@ID,@IsOptionalField,@DebtAttribute,convert(date, @RegenerateFromDate),convert(date,@ToDate),@UserID,@IsTicketDescMapped))  
  as ILCC(ProjectId,IsOptionalField,DebtAttributeId,FromDate,ToDate,UserID,IsTicketDescMapped)  
  ON ILCC.ProjectId = ILC.ProjectId AND ILC.ID = isnull(@LearingID,'')  
  WHEN MATCHED    THEN   
     UPDATE  
  SET ILC.IsOptionalField =  ILCC.IsOptionalField,  
  ILC.DebtAttributeId = ILCC.DebtAttributeId,  
  ILC.FromDate = ILCC.FromDate,  
     ILC.ToDate = ILCC.ToDate,  
  ILC.ModifiedBy =ILCC.UserID,  
  ILC.ModifiedDate = GetDate(),  
  ILC.IsTicketDescriptionOpted=ILCC.IsTicketDescMapped,  
  ILC.IsWorkPatternPrereqCompleted=1  
      
  WHEN NOT MATCHED BY TARGET THEN  
       
  INSERT   
  (ProjectID,FromDate,ToDate,IsOptionalField,DebtAttributeId,IsNoiseEliminationSentorReceived  
  ,IsNoiseSkipped,IsSamplingSentOrReceived,IsSamplingInProgress,IsMLSentOrReceived  
  ,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsTicketDescriptionOpted,IsWorkPatternPrereqCompleted)  
  VALUES(ILCC.ProjectId,@RegenerateFromDate,CONVERT(DATE,@ToDate),ILCC.IsOptionalField,ILCC.DebtAttributeId,NULL,NULL,NULL,NULL,NULL,0,'SYSTEM',GETDATE(),NULL,NULL,ILCC.IsTicketDescMapped,1);  
    
        SET @Result = 1  
  SELECT @Result AS Result  
 SET NOCOUNT OFF  
  
   COMMIT TRAN  
  END TRY  
 BEGIN CATCH  
  ROLLBACK TRAN  
     SET @Result =0  
  SELECT @Result AS Result  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  -- Log the error message  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
                  
   END CATCH  
  
END
