
CREATE PROCEDURE [ML].[InsertClusterCLTickets]        
@IsEncrypt BIT      
AS                                                            
BEGIN                                                            
BEGIN TRY                
BEGIN TRAN            
 -- SET NOCOUNT ON added to prevent extra result sets from                                                            
 -- interfering with SELECT statements.                                                            
 SET NOCOUNT ON;                                          
 DECLARE @CL_Key nvarchar(6) = 'LT001', @NextJobRunDayCount Int = 5               
  DECLARE @ErrorMessage VARCHAR(MAX);                                                            
 SELECT @ErrorMessage = ERROR_MESSAGE()               
   --send failure notifiaction to environment users                      
  DECLARE @MailSubject NVARCHAR(500);                        
  DECLARE @MailBody  NVARCHAR(MAX);                      
  DECLARE @MailRecipients NVARCHAR(MAX);                      
  DECLARE @MailContent NVARCHAR(500);                      
  DECLARE @MailStatus CHAR(1);            
  DECLARE @ScriptName  NVARCHAR(100)  ;             
  DECLARE @ProfileName  NVARCHAR(50)='ApplensSupport';            
   DECLARE @BodyFormat  NVARCHAR(50)='HTML';            
--DECLARE @Script NVARCHAR(100) = (SELECT StepName FROM DE.JobStepMaster WHERE StepId = @ExecutedStep)                      
                        
  SELECT @MailSubject = CONCAT(@@servername, ': Notification -- New Model ALGO CL Clustering job got failed')                     
  SET @MailContent = 'Oops! Error Occurred while running New Model ALGO CL clustering job !'                      
  SET @MailStatus = 'E'                       
  SET @ScriptName = 'New Model ALGO CL Clustering'                      
  SELECT @MailBody =[dbo].[fn_FormatEmailBody](@ErrorMessage,@MailContent,@MailStatus,@ScriptName)                      
                      
  SELECT @MailRecipients =ConfigValue FROM [AVL].[AppLensConfig] WHERE ConfigId = 1               
                  
 --DECLARATION FOR JOB FAILURE                  
  DECLARE @JobName NVARCHAR(100)= 'New Model ALGO Clustering Job';                    
   DECLARE @JobStatusSuccess NVARCHAR(100)='Success';                    
   DECLARE @JobStatusFail NVARCHAR(100)='Failed';                    
   DECLARE @JobStatusInProgress NVARCHAR(100)='InProgress';                    
   DECLARE @JobId INT,@JobStatusId INT;                    
   DECLARE @DataSource NVARCHAR(50) = 'ESA';                     
   DECLARE @User NVARCHAR(50) = 'System';                    
   DECLARE @Date DateTime = GetDate();                    
                  
   --JOB INSERTION                   
                  
    SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName;                  
                  
   INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate)                     
      VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @User, @Date);                    
                    
      SET @JobStatusId= SCOPE_IDENTITY();                   
                                
  SELECT * Into #tmpClusteringCLProjects FROM (                                          
 SELECT                                              
 CLP.ClusterCLID,MLTRN.TransactionId,CLP.ProjectID, MLTRN.SignOffDate, MLTRN.SupportTypeId                                            
 FROM [ML].[ClusteringCLProjects] CLP                                                              
 INNER JOIN ML.TRN_MLTransaction MLTRN ON CLP.TransactionID = MLTRN.TransactionId                                          
 Where CONVERT(DATE, CLP.JobRunDate) <= CONVERT(DATE, GETDATE())                    
  AND CLP.IsDeleted=0 AND MLTRN.IsDeleted=0 AND MLTRN.IsActiveTransaction=1 --AND CLP.ClusterCLId in(82,81,80,79,78,77,76,75,10,14,1,69,5,9)                            
 )t                                         
                                        
 Exec [ML].[InsertClusterCLTickets_App]                                    
 Exec [ML].[InsertClusterCLTickets_Infra]                                         
                                              
  -- Audit Log                                              
 CREATE TABLE #Temp(ID INT IDENTITY(1, 1), TransactionId int,SupportTypeId int,ModelVersion int,ClusterTotal int)                                                          
 Insert  into #Temp select distinct(TransactionId), SupportTypeId,0 as ModelVersion ,0 as ClusterTotal from #tmpClusteringCLProjects CL                                                
                                                 
 --Update A set ModelVersion=AD.ModelVersion from #Temp A inner join [ML].[TRN_AuditLog] AD on AD.MLTransactionId = A.TransactionId                                                
                                                
  Update A set ModelVersion = (select max(ModelVersion)+1  as Model                                                                                  
 from [ML].[TRN_AuditLog] where MLTransactionId = a.TransactionId)                                                   
 from #Temp A                                                
                                                
 Update A set ClusterTotal= (select count(MLTransactionId)  as Total                                                                                  
 from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = a.TransactionId AND IsDeleted=0 AND ISNULL(ClusterID_Desc,0)= 0   
 AND ISNULL(ClusterID_Resolution,0) = 0)                                                  
 from #Temp A where A.SupportTypeId=1                                                
                                                
 --Update A set ResolutionTotal = (select count(ClusterID_Resolution)  as Total                                                                                  
 --from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = a.TransactionId AND ClusterID_Resolution!= 0)                              
 --from #Temp A where A.SupportTypeId=1                                                
                
 Update A set ClusterTotal= (select count(ClusterID_Desc)  as Total                                    
 from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = a.TransactionId AND IsDeleted=0 AND ISNULL(ClusterID_Desc,0) = 0   
 AND ISNULL(ClusterID_Resolution,0) = 0)                                                   
 from #Temp A where A.SupportTypeId=2                                                
                                                
 --Update A set ResolutionTotal = (select count(ClusterID_Resolution)  as Total                                                                                  
 --from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = a.TransactionId AND ClusterID_Resolution!= 0)                                                   
 --from #Temp A where A.SupportTypeId=2                                                
                                        
Delete from #Temp where ModelVersion is null                                    
                                                
 INSERT INTO [ML].[TRN_AuditLog](MLTransactionId, SignOffDate,ModelVersion, Total, IsDeleted, CreatedBy,CreatedDate, LearningTypeKey, SignOffBy, ModifiedBy)                                                    
 Select TransactionId,GETDATE(),ModelVersion,ClusterTotal,0,'System',GETDATE(),@CL_Key,'System','System'  from #Temp                                                
                                             
                                         
                                         
  UPDATE A Set A.JobRunDate =DATEADD(Day, @NextJobRunDayCount, A.JobRunDate) FROM [ML].[ClusteringCLProjects] A                               
 Inner JOIN #tmpClusteringCLProjects B ON A.ClusterCLID=B.ClusterCLID                                          
                                        
  -- Logic to get the Ticket Description to decrypt                                            
 SELECT CAST(CLP.ProjectID as varchar(50)) ProjectID, CL.TicketId,CL.TicketDescription AS EncryptedTicketDescription,'' AS DecryptedTicketDescription,                             
 CL.TicketSummary As EncryptedSummaryDescription,'' As DecryptedSummaryDescription                                                           
 FROM ML.TRN_ClusteringTicketValidation_App CL                          
 INNER JOIN #tmpClusteringCLProjects CLP ON CL.MLTransactionId = CLP.TransactionID                                        
 WHERE (CL.DescriptionText = '' OR CL.DescriptionText IS NULL)  and  ISNULL(CL.TicketDescription,'') <> ''                                      
 AND CLP.SupportTypeId = 1  AND CL.ISDELETED =0                                      
                                                   
 SELECT CAST(CLP.ProjectID as varchar(50)) ProjectID, CL.TicketId,CL.TicketDescription AS EncryptedTicketDescription,'' AS DecryptedTicketDescription,                                                            
 CL.TicketSummary As EncryptedSummaryDescription,'' As DecryptedSummaryDescription                                                             
 FROM ML.TRN_ClusteringTicketValidation_Infra CL                                         
 INNER JOIN #tmpClusteringCLProjects CLP ON CL.MLTransactionId = CLP.TransactionID                                        
 WHERE (CL.DescriptionText = '' OR CL.DescriptionText IS NULL)  and  ISNULL(CL.TicketDescription,'') <> ''                                                      
  AND CLP.SupportTypeId = 2  AND CL.ISDELETED =0                                                         
                                                
   --Drop Table  #tmpClusteringCLProjects                                        
   --drop table #Temp          
         
   If @IsEncrypt = 0      
 BEGIN      
 Update A SET A.DescriptionText = A.TicketDescription, A.SummaryText= A.TicketSummary       
 FROM  [ML].[TRN_ClusteringTicketValidation_App] A      
 INNER JOIN #tmpClusteringCLProjects CLP ON A.MLTransactionId =CLP.TransactionId      
 WHERE CLP.SupportTypeId= 1 and A.IsDeleted=0  AND isnull(A.ClusterID_Desc,0) = 0    
      
 Update A SET A.DescriptionText = A.TicketDescription, A.SummaryText= A.TicketSummary       
 FROM  [ML].[TRN_ClusteringTicketValidation_Infra] A      
 INNER JOIN #tmpClusteringCLProjects CLP ON A.MLTransactionId =CLP.TransactionId      
 WHERE CLP.SupportTypeId= 2 and A.IsDeleted=0  AND isnull(A.ClusterID_Desc,0) = 0    
      
 END      
                   
  UPDATE MAS.JobStatus                     
   SET  JobStatus = Case when JobStatus=@JobStatusInProgress then                  
   @JobStatusSuccess ELSE JobStatus END, EndDateTime = GETDATE()                     
   WHERE ID = @JobStatusId              
               
   IF((Select JobStatus from MAS.JobStatus where ID = @JobStatusId)=@JobStatusFail)            
   BEGIN            
   -- --Send mail notification
   EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody            
   END            
  COMMIT TRAN                 
END TRY                                                            
BEGIN CATCH                                                            
 ROLLBACK TRAN                                                       
                                                            
 --INSERT Error                        
 EXEC AVL_INSERTERROR '[ML].[InsertClusterCLTickets]', @ErrorMessage,0                    
                   
   BEGIN --JOB Failure UPDATION                     
   UPDATE MAS.JobStatus                     
   SET  JobStatus = @JobStatusFail, EndDateTime = GETDATE()                     
   WHERE ID = @JobStatusId                    
  END                  
                    
  BEGIN --ERROR VARIABLES DECLARATION                    
   DECLARE @HostName NVARCHAR(50) = (SELECT HOST_NAME());                    
   DECLARE @Associate NVARCHAR(50) = (SELECT SUSER_NAME());                    
   DECLARE @ErrorCode NVARCHAR(50) = (SELECT ERROR_NUMBER());                      
   DECLARE @ModuleName NVARCHAR(30) = 'LearningWeb';                    
   DECLARE @DbName NVARCHAR(30) = 'AppVisionLens';                    
   DECLARE @getdate  DATETIME = GETDATE();                    
   DECLARE @DbObjName NVARCHAR(50) = (OBJECT_NAME(@@PROCID));                    
  END                     
                    
  BEGIN -- LOGGING FRAMEWORK LOGGING                    
   EXEC [AppVisionLensLogging].[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',                    
              @ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,                    
              @JobStatusFail,NULL,NULL;                    
  END                    
                  
                  
                      
-- --Send mail notification     
EXEC [AVL].[SendDBEmail] @To=@MailRecipients,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody                
                  
                  
                  
                  
END CATCH                                                            
END


