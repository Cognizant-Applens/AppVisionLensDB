/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetKATicketSummary]
  (	 
    @KAFilters  [AVL].[TVP_KEDB_KASearchFilters]  READONLY             
   
  )
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;

   --inserting into temp table  multiple comma separated values  
   DECLARE @AppIDs TABLE(ApplicationId BIGINT)  
   DECLARE @StatusDetails TABLE(Status NVarchar(20))  
   DECLARE @ServiceIDs TABLE(ServiceId BIGINT)  
   DECLARE @CauseCodeIds TABLE(CauseId BIGINT)  
   DECLARE @ResolutionIds TABLE(ResolutionId BIGINT)  
   Declare @isCognizant BIT  
   DECLARE @ProjectId BIGINT       
   SELECT @ProjectId = ProjectID  FROM    @KAFilters  
   SELECT @isCognizant = isCognizant FROM @KAFilters
     
	DECLARE @KATicketCount int  
	DECLARE @KAApprovedCount int	
	DECLARE @KAUsedCount int  
	DECLARE @KANotUsedCount int

  
   INSERT INTO @AppIDs  
     SELECT Item  FROM dbo.Split((SELECT AppID  FROM   @KAFilters),',')  
  
  INSERT INTO @StatusDetails  
     SELECT Item  FROM dbo.Split((SELECT [Status]  FROM   @KAFilters),',')  
  
   INSERT INTO @ServiceIDs  
    SELECT Item  FROM dbo.Split((SELECT [Service]  FROM   @KAFilters),',')  
  
  INSERT INTO @CauseCodeIds  
     SELECT Item  FROM dbo.Split((SELECT [CauseCode]  FROM   @KAFilters),',')  
  
  INSERT INTO @ResolutionIds  
     SELECT Item  FROM dbo.Split((SELECT ResolutionCode  FROM   @KAFilters),',')  
  

   IF @isCognizant = 1 
	  BEGIN 
			SELECT distinct KATicketId,KATD.Status,KATD.KAID into #temp FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock)  
			INNER JOIN  [AVL].[KEDB_TRN_KAServiceMapping] KASM (nolock) on KATD.KAID = KASM.KAID and KASM.Isdeleted=0  
			INNER JOIN  @ServiceIDs  Ser on Ser.ServiceId= KASM.ServiceId  
			INNER JOIN  @StatusDetails  S on S.Status= KATD.Status  
			INNER JOIN  @AppIDs  A on A.ApplicationId= KATD.ApplicationId  
			INNER JOIN  @CauseCodeIds  CC on CC.CauseId= KATD.CausecodeId  
			INNER JOIN  @ResolutionIds  RC on RC.ResolutionId= KATD.ResolutionId  
			WHERE ProjectID = @ProjectID and KATD.isdeleted=0 		 
  
			 SELECT @KATicketCount =count(KATicketId)  FROM #temp (NOLOCK)  
  
			 SELECT @KAApprovedCount =count(KATicketId)  FROM #temp (NOLOCK) where (status ='Approved')  
  
			 SELECT @KAUsedCount=Count(*)  FROM (SELECT KTM.KATicketId FROM #temp temp (NOLOCK) 
			 JOIN [AVL].[KEDB_TRN_KTicketMapping] KTM (NOLOCK) on temp.KATicketID=KTM.KATicketId ) as test  
  
			 SELECT @KANotUsedCount=Count(*) FROM #temp KTD  (NOLOCK) 
			 WHERE KTD.KAId not in (SELECT KTM.KAID from #temp temp (NOLOCK) JOIN [AVL].[KEDB_TRN_KARating_MapTicketId] KTM (NOLOCK) ON temp.KAId=KTM.KAID  
			 WHERE KTM.TicketId <> '' AND IsLinked=1   GROUP BY KTM.KAID) and KTD.Status='Approved'  
				  
			SELECT @KATicketCount as KATicketCount,@KAApprovedCount as ApprovedCount,  
			@KAUsedCount as KAUsed, @KANotUsedCount as KANotUsed  

		END

	ELSE

	 BEGIN 
			SELECT distinct KATicketId,KATD.Status,KATD.KAID into #temp1 FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) 
			INNER JOIN  @StatusDetails  S on S.Status= KATD.Status  
			INNER JOIN  @AppIDs  A on A.ApplicationId= KATD.ApplicationId  
			INNER JOIN  @CauseCodeIds  CC on CC.CauseId= KATD.CausecodeId  
			INNER JOIN  @ResolutionIds  RC on RC.ResolutionId= KATD.ResolutionId  
			WHERE ProjectID = @ProjectID and KATD.isdeleted=0 
  
			 SELECT @KATicketCount =count(KATicketId)  FROM #temp1 (NOLOCK)  
  
			 SELECT @KAApprovedCount =count(KATicketId)  FROM #temp1 (NOLOCK) where (status ='Approved')  
  
			 SELECT @KAUsedCount=Count(*)  FROM (SELECT KTM.KATicketId FROM #temp1 temp1 (NOLOCK) 
			 JOIN [AVL].[KEDB_TRN_KTicketMapping] KTM (NOLOCK) on temp1.KATicketID=KTM.KATicketId ) as test  
  
			 SELECT @KANotUsedCount=Count(*) FROM #temp1 KTD  (NOLOCK) 
			 WHERE KTD.KAId not in (SELECT KTM.KAID from #temp1 temp1 (NOLOCK) JOIN [AVL].[KEDB_TRN_KARating_MapTicketId] KTM (NOLOCK) ON temp1.KAId=KTM.KAID  
			 WHERE KTM.TicketId <> '' AND IsLinked=1  GROUP BY KTM.KAID) and KTD.Status='Approved'  
			  
			   SELECT @KATicketCount as KATicketCount,@KAApprovedCount as ApprovedCount,  
			   @KAUsedCount as KAUsed, @KANotUsedCount as KANotUsed  

		END
     
  END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	   
		EXEC AVL_InsertError '[AVL].[KEDB_GetKATicketSummary]  ', @ErrorMessage, 0,@ProjectID
		RETURN @ErrorMessage
  END CATCH  
END
