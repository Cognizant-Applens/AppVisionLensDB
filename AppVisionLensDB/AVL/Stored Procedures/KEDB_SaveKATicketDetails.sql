  
CREATE PROCEDURE [AVL].[KEDB_SaveKATicketDetails]  
(  
 @KATicketDetails   [AVL].[TVP_KEDB_SaveKATicketDetails]  readonly,  
 @KAActivityDetails   [AVL].[TVP_KEDB_SaveKA_ActivityDetails]  readonly,  
 @KALinkDetails   [AVL].[TVP_KEDB_SaveKA_LinkDetails]   readonly,  
 @KAUploadDetails [AVL].[TVP_KEDB_SaveKA_UploadDetails] readonly  
 )  
 AS  
SET NOCOUNT ON;  
  BEGIN  
      BEGIN TRY  
    DECLARE @UserId NVarchar(50)=''  
    DECLARE @ProjectId BIGINT=0  
    DECLARE @KATicketSeq NVarchar(50)  
    DECLARE @KAId BIGINT  
    DECLARE @NEWKAID BIGINT; 
	DECLARE @DeleteKAID BIGINT; 
    DECLARE @UpdateNextVal BIT=0;  
    DECLARE @ServiceData TABLE (ServiceID  INT, KAID BIGINT)  
          DECLARE @tempKAData TABLE  
            (  
               KAID BIGINT, ProjectId Bigint,KATicketID NVARCHAR (50),KATitle NVARCHAR (1000),Status nvarchar(20) ,  
         ServiceIds nvarchar(250) ,CauseCodeId bigint,ResolutionId bigint,Description nvarchar(4000),  
      KeyWords nvarchar(300),AuthorName nvarchar(100),Effort Decimal(25,2), AutomationScope nvarchar(20),  
      ApprovedOrRejectedBy nvarchar(50) , ReviewComments nvarchar(250) ,  
      ApplicationId int,CreatedBy nvarchar(50) ,Remarks nvarchar(500)   
            )  
          DECLARE @tempActivityData TABLE  
            (  
               KAActivityID Bigint,KAId bigint,ActivityDescription nvarchar(4000),  
      Effort Decimal(25,2),IsAutomatable bit  
            )  
  
   DECLARE @tempKALinkData TABLE  
            (  
               KALinkID Bigint,KAId bigint,Link nvarchar(MAX),  
      LinkAlias nvarchar(200)  
            )  
     DECLARE @tempKAUploadData TABLE  
            (  
               [KAUploadID] Bigint,[KAId] bigint,[FileName] nvarchar(MAX)  
            )  
  
          DECLARE @IdTable TABLE  (insertedid BIGINT );  
  
          INSERT INTO @tempKAData  
   select  KAId,ProjectId,KATicketID, KATitle, Status, ServiceIds,CauseCodeId,  
    ResolutionId,Description,KeyWords,AuthorName,Effort,AutomationScope,ApprovedOrRejectedBy,  
    ReviewComments,ApplicationId,CreatedBy,Remarks  
   FROM @KATicketDetails  
   
   INSERT INTO @tempActivityData  
   SELECT  KAActivityId,KAId,ActivityDescription,Effort,IsAutomatable  
     FROM @KAActivityDetails  
  
     INSERT INTO @tempKALinkData  
         SELECT KALinkID, KAId, Link, LinkAlias FROM @KALinkDetails   
  
       INSERT INTO @tempKAUploadData  
         SELECT KAUploadID, KAId, FileName FROM @KAUploadDetails   
  
if((select ApprovedOrRejectedBy from @tempKAData) <> '')  
 BEGIN  
 print 'new'  
 if(((select Status from @tempKAData) = 'Approved') and (select Count(*) FROM [AVL].[KEDB_TRN_KATicketDetails] where  KATicketID = (select KATicketID from @tempKAData)) >= 5)  
 BEGIN  
 SET @DeleteKAID = (select top 1 KAID from [AVL].[KEDB_TRN_KATicketVersionDetails] where KATicketID = (select KATicketID from @tempKAData) AND IsDeleted=0 order by CreatedOn asc);  
 UPDATE [AVL].[KEDB_TRN_KATicketVersionDetails] SET IsDeleted = 1 where  KAID = @DeleteKAID  
 DELETE FROM [AVL].[KEDB_TRN_KATicketActivityDetails] where  KAID = @DeleteKAID  
 DELETE FROM [AVL].[KEDB_TRN_KATicketLinkDetails] where  KAID = @DeleteKAID  
 DELETE FROM [AVL].[KEDB_TRN_KAUploadedFileDetails] where  KAID = @DeleteKAID 
 	  SELECT @DeleteKAID as DeletedKAID  
 END  
  
   UPDATE KTD   SET KTD.ApprovedOrRejectedBy = temp.ApprovedOrRejectedBy,KTD.ReviewComments = temp.ReviewComments,  
    KTD.Status = temp.Status,ModifiedBy =temp.ApprovedOrRejectedBy,ModifiedOn=getdate()  
     FROM [AVL].[KEDB_TRN_KATicketDetails]  AS KTD INNER JOIN @tempKAData AS temp  
      ON KTD.KAId = temp.KAId  
   --Audit KA  
    INSERT INTO [AVL].[KEDB_AuditWorkLog]  
    SELECT  KAId,ProjectId,Status,ReviewComments,ApprovedOrRejectedBy,GETDATE() FROM @tempKAData  
 END  
ELSE  
 BEGIN  
  print 'new1'  
   SELECT @KAId
   = KAId, @UserId=CreatedBy,@ProjectId= ProjectId,@KATicketSeq = KATicketID FROM @KATicketDetails  
     
   INSERT INTO @ServiceData(ServiceID)  
   SELECT Item  FROM dbo.Split((SELECT ServiceIds  FROM   @KATicketDetails),',')   
   
-- get the Ka sequence id based on project  
   --SElECT  @KATicketSeq = KATicketID  FROM  @tempKAData  
    IF (@KATicketSeq = '' OR @KATicketSeq IS NULL )  
    BEGIN  
  EXEC [AVL].[KEDB_GetKASequenceID]  @ProjectId,'KA',@UserId,@KATicketSeq OUTPUT    
  SET @UpdateNextVal =1   
    End  
    IF((select KA.status from [AVL].[KEDB_TRN_KATicketDetails] KA  
    inner join @tempKAData temp ON temp.KATicketID=KA.KATicketID and   
    temp.ProjectID = KA.ProjectID and KA.isdeleted=0)='Approved' )  
  
    BEGIN  
    print 'p'  
     INSERT INTO [AVL].[KEDB_TRN_KATicketVersionDetails]  
     (ProjectId,KAId,KATicketID,KATitle,Status,CauseCodeId,ResolutionId,Description,  
        KeyWords,AuthorName,Effort,AutomationScope,CreatedBy,CreatedOn,Isdeleted,ApplicationId,Remarks )  
     SELECT source.ProjectId,source.KAId,source.KATicketID,source.KATitle,source.Status,  
        source.CauseCodeId,source.ResolutionId,source.Description,source.Keywords,source.AuthorName,  
        source.Effort,source.AutomationScope,source.createdBy,Getdate(),0,source.ApplicationId,source.Remarks  
        FROM [AVL].[KEDB_TRN_KATicketDetails] source   
        inner join @tempKAData temp ON temp.KATicketID=source.KATicketID and   
        temp.ProjectID = source.ProjectID and source.isdeleted=0  
  
                update KA set KA.IsDeleted=1 FROM [AVL].[KEDB_TRN_KATicketDetails] KA  
       inner join @tempKAData temp ON temp.KATicketID=KA.KATicketID and   
        temp.ProjectID = KA.ProjectID  
print 'k'  
    INSERT INTO [AVL].[KEDB_TRN_KATicketDetails]  
     (ProjectId,KATicketID,KATitle,Status,CauseCodeId,ResolutionId,Description,  
        KeyWords,AuthorName,Effort,AutomationScope,CreatedBy,CreatedOn,Isdeleted,ApplicationId,Remarks)  
     SELECT source.ProjectId,source.KATicketID,source.KATitle,source.Status,  
        source.CauseCodeId,source.ResolutionId,source.Description,source.Keywords,source.AuthorName,  
        source.Effort,source.AutomationScope,source.createdBy,Getdate(),0,source.ApplicationId,source.Remarks  
        FROM @KATicketDetails source  
    print 'end'  
  
     INSERT  into @IdTable  
     SELECT @@IDENTITY as insertedid   
  
             SELECT @NEWKAID = insertedid   from @IdTable  
       DELETE FROM [AVL].[KEDB_TRN_KATicketActivityDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KATicketActivityDetails]  
     ([KAId],[ActivityDescription],[Effort],[IsAutomatable],[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn )  
     (SELECT @NEWKAID,ActivityDescription,Effort,IsAutomatable,0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempActivityData)  
  
     --KA Link   
     DELETE FROM [AVL].[KEDB_TRN_KATicketLinkDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KATicketLinkDetails]  
     ([KAId], Link, LinkAlias ,[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)  
     (SELECT @NEWKAID, Link,  LinkAlias , 0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempKALinkData)  
    
    --KA Upload   
     DELETE FROM [AVL].[KEDB_TRN_KAUploadedFileDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KAUploadedFileDetails]  
     ([KAId], [FileName],[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)  
     (SELECT @NEWKAID, [FileName],0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempKAUploadData)  
       
      Update  @ServiceData  SET KAId = @NEWKAID    
    END  
    ELSE  
    BEGIN  
        
      MERGE INTO [AVL].[KEDB_TRN_KATicketDetails] AS target  
      using (SELECT ProjectId,KATicketID, KATitle, Status,CauseCodeId,  
      ResolutionId,Description,KeyWords,AuthorName,Effort,AutomationScope,ApprovedOrRejectedBy,  
      ReviewComments,CreatedBy,ApplicationId ,KAID,Remarks FROM   @tempKAData) AS source  
      ON source.KATicketID = target.KATicketID  AND  
        source.ProjectID = target.ProjectID   AND  target.isdeleted=0  
  
      WHEN matched THEN  
     UPDATE SET   KATitle= source.KATitle,Status = source.Status,  
     CauseCodeId = source.CauseCodeId,  
     ResolutionId = source.ResolutionId,Description = source.Description,  
     KeyWords = source.KeyWords,Effort = source.Effort,  
     AutomationScope = source.AutomationScope,ApprovedOrRejectedBy=source.ApprovedOrRejectedBy,  
     ReviewComments = source.ReviewComments,ModifiedBy =source.Createdby,  
     ModifiedOn=getdate(),AuthorName=source.AuthorName,  
     ApplicationId = source.ApplicationId,  
     Remarks=source.Remarks  
       
   
     WHEN NOT MATCHED BY target THEN  
     INSERT (ProjectId,KATicketID,KATitle,Status,CauseCodeId,ResolutionId,Description,  
        KeyWords,AuthorName,Effort,AutomationScope,CreatedBy,CreatedOn,Isdeleted,ApplicationId,Remarks )  
     VALUES ( source.ProjectId,@KATicketSeq,source.KATitle,source.Status,  
        source.CauseCodeId,source.ResolutionId,source.Description,source.Keywords,source.AuthorName,  
        source.Effort,source.AutomationScope,source.createdBy,Getdate(),0,source.ApplicationId,source.Remarks)  
             output inserted.KAId INTO @IdTable;  
          
     -- remove and insert to avoid duplication  
      
     SELECT @NEWKAID = insertedid   from @IdTable  
       DELETE FROM [AVL].[KEDB_TRN_KATicketActivityDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KATicketActivityDetails]  
     ([KAId],[ActivityDescription],[Effort],[IsAutomatable],[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn )  
     (SELECT @NEWKAID,ActivityDescription,Effort,IsAutomatable,0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempActivityData)  
  
     --KA Link   
     DELETE FROM [AVL].[KEDB_TRN_KATicketLinkDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KATicketLinkDetails]  
     ([KAId], Link, LinkAlias ,[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)  
     (SELECT @NEWKAID, Link,  LinkAlias , 0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempKALinkData)  
    
    --KA Upload   
     DELETE FROM [AVL].[KEDB_TRN_KAUploadedFileDetails] where KAID = @NEWKAID  
     INSERT INTO [AVL].[KEDB_TRN_KAUploadedFileDetails]  
     ([KAId], [FileName],[IsDeleted],CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)  
     (SELECT @NEWKAID, [FileName],0, @UserId, GETDATE(), @UserId, GETDATE() FROM @tempKAUploadData)  
     Update  @ServiceData  SET KAId = @NEWKAID   
          END     
  
   --Service details  
   
  MERGE INTO [AVL].[KEDB_TRN_KAServiceMapping] as TARGET  
       USING (SELECT ServiceID,KAID  FROM   @ServiceData) AS source  
     ON source.KAID = target.KAID  AND   
        source.ServiceID = target.ServiceID  
         
     WHEN MATCHED THEN  
      UPDATE SET isdeleted=0,  
      ModifiedBy=@UserId ,  
      ModifiedOn=GETDATE()  
    
    WHEN Not MATCHED BY TARGET THEN  
    INSERT (KAID,ServiceID,Isdeleted, CreatedBy , CreatedOn )  
     VALUES ( (select insertedid from @IdTable),  
      source.ServiceID,0, @UserId, GETDATE()) ;  
          
   DECLARE @ServiceId BIGINT  
    SELECT @ServiceId = KAID FROM @ServiceData  
    If ( @ServiceId = 0 )  
    BEGIN  
    UPDATE  @ServiceData  
    SET KAID= (select insertedid from @IdTable)  
    END  
   -- removed   
    UPDATE [AVL].[KEDB_TRN_KAServiceMapping]  
    SET IsDeleted = 1,  
    ModifiedBy = @UserId,  
    ModifiedOn = GETDATE()  
     
    WHERE KAID in ( SELECT DISTINCT KAID FROM @ServiceData)  
      AND ServiceID  not in  (SELECT DISTINCT ServiceID FROM @ServiceData)  
    -- if all applications are deleted  
     IF( SELECT COuNT(ServiceID) FROM @ServiceData ) =0   
     BEGIN  
      UPDATE [AVL].[KEDB_TRN_KAServiceMapping]  
    SET IsDeleted = 1  
    WHERE KAID in ( SELECT DISTINCT KAID FROM @tempKAData)  
     END  
  
    IF  (@UpdateNextVal =1)  
    BEGIN  
    UPDATE [AVL].[TK_MAP_AHIDGeneration]   
    SET NextId = NextId+1,  
    ModifiedBy =@UserId,  
    ModifiedDate=GETDATE()  
    WHERE ProjectId = @ProjectId AND Category ='KA' AND Isdeleted =0  
    END  
  
      Select  @KATicketSeq as KATicketID,@NEWKAID as KAID
	  
    
  --Audit KA  
    INSERT INTO [AVL].[KEDB_AuditWorkLog]  
    SELECT  @NEWKAID,ProjectId,  
     CASE  
      WHEN (SELECT KAId FROM @tempKAData)= 0 AND (Select Status from @tempKAData)!='Submitted' THEN 'Created'  
      WHEN (SELECT KAId FROM @tempKAData)= 0 AND (Select Status from @tempKAData)='Submitted' THEN 'Submitted'  
      WHEN (SELECT KAId FROM @tempKAData) > 0 AND (Select Status from @tempKAData)='Saved' THEN 'Modified'  
      ELSE (Select Status from @tempKAData) END  
     ,ReviewComments,CreatedBy,GETDATE() FROM @tempKAData  
END  
      END try  
  
      BEGIN catch  
          DECLARE @ErrorMessage VARCHAR(2000);  
          SELECT @ErrorMessage = Error_message()  
    Select @UserId=CreatedBy,@ProjectID=ProjectId  from @tempKAData  
          EXEC AVL_InsertError '[AVL].[KEDBSaveKATicketDetails]', @ErrorMessage,@UserId,@ProjectID  
      END catch  
  END  
