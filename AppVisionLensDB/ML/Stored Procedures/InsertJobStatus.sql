
CREATE PROCEDURE [ML].[InsertJobStatus]   --'IL_Classification_Services_ContinuousLearning','Started', 0,null   
 -- Add the parameters for the stored procedure here      
 (@JobName varchar(200),      
  @Status varchar(100),      
  @Id int=0,      
  @ExceptionMsg nvarchar(4000))      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
 DECLARE @JobId int = (Select JobId from MAS.JobMaster(NOLOCK) WHERE JobName =@JobName )      
  declare @stime datetime;    
 declare @etime datetime;    
 DECLARE @d date = CURRENT_TIMESTAMP;      
    
 DECLARE @MrngStartTime datetime=(SELECT SMALLDATETIMEFROMPARTS(YEAR(@d), MONTH(@d), DAY(@d), 10, 00));      
    DECLARE @MrngEndTime datetime=(SELECT SMALLDATETIMEFROMPARTS(YEAR(@d), MONTH(@d), DAY(@d), 12, 00));      
 DECLARE @EveStartTime datetime=(SELECT SMALLDATETIMEFROMPARTS(YEAR(@d), MONTH(@d), DAY(@d), 16,00));      
 DECLARE @EveEndTime datetime=(SELECT SMALLDATETIMEFROMPARTS(YEAR(@d), MONTH(@d), DAY(@d), 18, 00));      
 if (getdate() <=@MrngEndTime)    
 begin    
 set @stime = @MrngStartTime    
 set @etime = @MrngEndTime    
 end    
 else    
 begin    
  set @stime = @EveStartTime    
 set @etime = @EveEndTime    
 end    
      
    
 IF(@Status='Started')      
 BEGIN       
    INSERT INTO MAS.JobStatus      
 VALUES (@JobId,getdate(),getdate(),@Status,null,getdate(),null,null,null,0,@JobName,GETDATE())      
       
 SET @Id= (SELECT TOP 1 Id FROM MAS.JobStatus(NOLOCK) WHERE JobId=@JobId AND JobStatus=@Status ORDER BY CreatedDate desc)      
      
 END      
 ELSE IF(@Status='Success')      
 BEGIN      
 UPDATE MAS.JobStatus SET EndDateTime = getdate(),Jobstatus = @Status where id =@Id      
 END      
    ELSE IF(@Status='Failed')      
 BEGIN      
 UPDATE MAS.JobStatus SET Jobstatus = @Status,Remarks=@ExceptionMsg where id =@Id      
 END      
       
 IF(@JobName <> 'CL_Clustering')      
 BEGIN      
 IF(@Status='Started' AND       
 (GetDate() between @stime AND @etime))      
 BEGIN       
 IF NOT EXISTS(SELECT TOP 1 Id FROM MAS.JobStatus(NOLOCK) WHERE JobId=@JobId AND Isnull(Remarks,'') <> ''      
 AND (CreatedDate between @stime AND @etime) AND JobStatus<>'Failed'      
 AND (GetDate() between @stime AND @etime)      
 )      
 BEGIN      
 UPDATE MAS.JobStatus SET Remarks='Mailer Start Sent' WHERE ID = @Id       
 SELECT @Id AS ID,1 AS IsMailer,@Status AS Status       
 END      
 ELSE      
 BEGIN      
  SELECT @Id AS ID,0 AS IsMailer,@Status AS Status       
  --  SELECT @Id AS ID,1 AS IsMailer,@Status AS Status      
 END      
        
 END      
 ELSE IF(@Status='Success' AND       
 (GetDate() between @stime AND @etime))      
 BEGIN       
 IF NOT EXISTS(SELECT TOP 1 Id FROM MAS.JobStatus(NOLOCK) WHERE JobId=@JobId AND Remarks <>'Mailer Start Sent'      
 AND (CreatedDate between @stime AND @etime) AND JobStatus<>'Failed'      
 AND (GetDate() between @stime AND @etime))      
 BEGIN      
 UPDATE MAS.JobStatus SET Remarks='Mailer Success Sent' WHERE ID = @Id       
 SELECT @Id AS ID,1 AS IsMailer,@Status AS Status       
 END      
 ELSE      
 BEGIN      
  SELECT @Id AS ID,0 AS IsMailer,@Status AS Status      
    --SELECT @Id AS ID,1 AS IsMailer,@Status AS Status    
 END      
 END      
 ELSE IF(@Status='Failed')      
 BEGIN      
  SELECT @Id AS ID,1 AS IsMailer,@Status AS Status       
 END      
 ELSE      
 BEGIN      
  SELECT @Id AS ID,0 AS IsMailer,@Status AS Status      
 -- SELECT @Id AS ID,1 AS IsMailer,@Status AS Status     
 END      
 END      
 ELSE      
 BEGIN      
  SELECT @Id AS ID,1 AS IsMailer,@Status AS Status       
      
 END      
END 