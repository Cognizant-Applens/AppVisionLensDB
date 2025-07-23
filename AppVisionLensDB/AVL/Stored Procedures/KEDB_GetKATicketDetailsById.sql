CREATE PROCEDURE [AVL].[KEDB_GetKATicketDetailsById] --'KA43478000003','103127','3','6022'   
(@KATicketId NVarchar(50),    
@ProjectId  NVarchar(max),  
@Key nvarchar(50)=0,  
@KAID nvarchar(50)=0  
)    
AS    
BEGIN      
BEGIN TRY     
  SET NOCOUNT ON;   
IF (@Key='1')  
BEGIN  
   DECLARE @Status varchar(50)=(SELECT Status FROM [AVL].[KEDB_TRN_KATicketDetails] WHERE KATicketId = @KATicketId AND IsDeleted=0)  
  IF(@Status='Approved' OR (SELECT COUNT(*) FROM [AVL].[KEDB_TRN_KATicketVersionDetails] WHERE KATicketId = @KATicketId)=0)  
  BEGIN  
   SET @KAID=  (SELECT KAId FROM [AVL].[KEDB_TRN_KATicketDetails] WHERE KATicketId = @KATicketId AND IsDeleted=0)  
  END  
  ELSE  
  BEGIN  
   SET @KAID=  (SELECT Top 1 KAId FROM [AVL].[KEDB_TRN_KATicketVersionDetails] WHERE KATicketId = @KATicketId AND IsDeleted=0 AND Status='Approved' Order by createdon desc)  
  END  
  END  
  DECLARE @ProjectIds TABLE(ProjectId BIGINT)    
  INSERT INTO @ProjectIds    
     SELECT Item  FROM dbo.Split((@ProjectId),',')    
  SELECT KATD.KAID, KATD.ProjectId,KATD.KATicketId,KATitle,Status,CauseCodeId,ResolutionId,    
  Description,KeyWords,Effort,AutomationScope,ApprovedOrRejectedBy,ReviewComments,AuthorName,    
  ApplicationId,KATD.CreatedBy,    
  ServiceId = STUFF    
    ((    
  SELECT DISTINCT ','+ CAST(KASM.ServiceID AS VARCHAR(400))      
          FROM [AVL].[KEDB_TRN_KAServiceMapping] KASM (nolock)     
           Join  [AVL].[KEDB_TRN_KATicketDetails] t (NOLOCK) on t.KAID = KASM.KAID            
     and KASM.IsDeleted=0 and t.KAId = KATD.KAId              
       FOR XMl PATH('')     
      ),1,1,''    
  ) ,    
   KTM.KTicketId,KATD.Remarks     
   FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock)    
   INNER JOIN @ProjectIds P ON P.ProjectId = KATD.ProjectId      
   LEFT JOIN AVL.KEDB_TRN_KTicketMapping KTM on KTM.KATicketId = KATD.KATicketId and KTM.IsDeleted=0      
   WHERE  KATD.KATicketId = @KATicketId AND KATD.KAID=@KAID    

   SELECT  KAActivityId,KAAD.KAID,ActivityDescription,KAAD.Effort,IsAutomatable      
   FROM  [AVL].[KEDB_TRN_KATicketActivityDetails] KAAD (nolock)    
   INNER JOIN  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) on KATD.KAID = KAAD.KAID    and KAAD.Isdeleted=0    
   INNER JOIN @ProjectIds P ON P.ProjectId = KATD.ProjectId    
   WHERE KATicketId = @KATicketId AND KATD.KAID=@KAID  order by KAActivityID    
--AND ProjectID = @ProjectID     
  SELECT  KALinkID,KALD.KAID,KALD.Link,KALD.LinkAlias      
   FROM  [AVL].[KEDB_TRN_KATicketLinkDetails] KALD (nolock)    
   INNER JOIN  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) on KATD.KAID = KALD.KAID    and KALD.Isdeleted=0    
   INNER JOIN @ProjectIds P ON P.ProjectId = KATD.ProjectId    
   WHERE  KATicketId = @KATicketId AND KATD.KAID=@KAID   
   SELECT KAUploadId,KALD.KAID,KALD.FileName   
   FROM  [AVL].[KEDB_TRN_KAUploadedFileDetails] KALD (nolock)    
   INNER JOIN  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) on KATD.KAID = KALD.KAID    and KALD.Isdeleted=0    
   INNER JOIN @ProjectIds P ON P.ProjectId = KATD.ProjectId    
   WHERE KATicketId = @KATicketId AND KATD.KAID=@KAID    
  END TRY    
  BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(4000);    
SELECT @ErrorMessage = ERROR_MESSAGE()        
  EXEC AVL_InsertError '[AVL].[KEDB_GetKATicketDetailsById]  ', @ErrorMessage, 0,@ProjectID    
  RETURN @ErrorMessage    
  END CATCH       
END
