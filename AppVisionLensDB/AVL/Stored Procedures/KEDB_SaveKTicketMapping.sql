CREATE PROCEDURE [AVL].[KEDB_SaveKTicketMapping]  
(  
 @KTicketMapping  [AVL].[TVP_KEDB_KTicketMap]  readonly  
 )  
 AS  
SET NOCOUNT ON;  
  BEGIN  
      BEGIN TRY  
    DECLARE @UserId NVarchar(50)=''  
    DECLARE @ProjectId BIGINT=0  
    DECLARE @KATicketId NVarchar(50)=''  
  
   DECLARE @tempKMapping TABLE  
            (  
               KTicketId NVARCHAR (50),KATicketID NVARCHAR (50),IsMapped bit,  
      CreatedBy nvarchar(50),ProjectID BigInt  
            )  
  INSERT INTO @tempKMapping  
   select  KTicketId,KATicketID,IsMapped,CreatedBy,ProjectID  
   FROM @KTicketMapping  
  
    SELECT @KATicketId = KATicketID from @tempKMapping  
  
 IF ( @KATicketId != '')  
 BEGIN  
  
  MERGE INTO [AVL].[KEDB_TRN_KTicketMapping] AS target  
          using (SELECT KTicketId,KATicketID,IsMapped,CreatedBy,ProjectID  FROM   @tempKMapping) AS source  
               ON source.KATicketID = target.KATicketId  AND  
         source.ProjectID = target.ProjectID  and source.KTicketId = target.KTicketId       
  
          WHEN matched THEN  
            UPDATE SET   ModifiedBy =source.Createdby,ModifiedOn=getdate()  
   
         WHEN NOT MATCHED BY target THEN  
            INSERT (KTicketId,KATicketID,IsMapped,ProjectID,CreatedBy,CreatedOn,Isdeleted )  
            VALUES ( source.KTicketId,source.KATicketID,source.IsMapped,source.ProjectID,  
     source.createdBy,Getdate(),0);  
 
     END  

	 UPDATE DE SET DE.DartStatusId= CASE    
	 WHEN KA.Status = 'Saved' THEN 4   
	 WHEN KA.Status = 'Submitted' THEN 4   
	 WHEN KA.Status = 'Rejected' THEN 4  
     WHEN KA.Status = 'Approved' THEN 8  
     ELSE 12 END   
     FROM AVL.DEBT_TRN_HealTicketDetails DE  
     JOIN @tempKMapping K ON DE.HealingTicketID=K.KTicketId  
	 JOIN [AVL].[KEDB_TRN_KTicketMapping] KT ON KT.KTicketId=K.KTicketId
     JOIN [AVL].[KEDB_TRN_KATicketDetails] KA ON KA.KATicketId=KT.KATicketId  
	 WHERE KA.Isdeleted=0
   END TRY  
  
      BEGIN catch  
          DECLARE @ErrorMessage VARCHAR(2000);  
          SELECT @ErrorMessage = Error_message()  
    Select @UserId=CreatedBy,@ProjectID=ProjectId  from @tempKMapping  
    EXEC AVL_InsertError '[AVL].[KEDBSaveKATicketDetails]', @ErrorMessage,0,@ProjectID  
      END catch  
  END
