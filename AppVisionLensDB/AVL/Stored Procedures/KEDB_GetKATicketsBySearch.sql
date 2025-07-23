
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetKATicketsBySearch] 
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
   DECLARE @PageNo INT  
   DECLARE @Rows INT
 
  
    SELECT @ProjectId = ProjectID  FROM    @KAFilters  
	SELECT @PageNo = PageNumber  FROM    @KAFilters  
    SELECT @Rows = RowspPage  FROM    @KAFilters  
	SELECT @isCognizant = isCognizant FROM @KAFilters
 
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
  ; With [VersionCTE](KAticketID,VersionNo)
  As
  (
  SELECT KATD.KATicketId,CAST((isNull(count(KAVD.KATicketId), 0) + 1) AS VARCHAR(5)) + '.0' as VersionNo
  FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) 
  LEFT JOIN [AVL].[KEDB_TRN_KATicketVersionDetails] KAVD (nolock) on KAVD.KATicketId = KATD.KATicketId
  WHERE  KATD.isdeleted=0    
  group by KATD.KATicketId
  )
		SELECT Distinct KATD.KAId,KATD.ProjectId,KATD.KATicketId,KATD.CreatedBy,KATD.KATitle,KATD.Status,KATD.Effort,  
		 '' as Review,KATD.authorname as EmployeeName,VCTE.VersionNo as VersionNo 
		 FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock)  
		INNER JOIN  [AVL].[KEDB_TRN_KAServiceMapping] KASM (nolock) on KATD.KAID = KASM.KAID and KASM.Isdeleted=0  
		INNER JOIN  @ServiceIDs  Ser on Ser.ServiceId= KASM.ServiceId  
		INNER JOIN  @StatusDetails  S on S.Status= KATD.Status  
		INNER JOIN  @AppIDs  A on A.ApplicationId= KATD.ApplicationId  
		INNER JOIN  @CauseCodeIds  CC on CC.CauseId= KATD.CausecodeId  
		INNER JOIN  @ResolutionIds  RC on RC.ResolutionId= KATD.ResolutionId  
		LEFT JOIN [VersionCTE] VCTE (nolock) on VCTE.KATicketId = KATD.KATicketId
		WHERE KATD.ProjectID = @ProjectID and KATD.isdeleted=0    
		ORDER BY KATD.KATicketId    
  END

  ELSE

  BEGIN 
  ; With [VersionCTE](KAticketID,VersionNo)
  As
  (
  SELECT KATD.KATicketId,CAST((isNull(count(KAVD.KATicketId), 0) + 1) AS VARCHAR(5)) + '.0' as VersionNo 
  FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) 
  LEFT JOIN [AVL].[KEDB_TRN_KATicketVersionDetails] KAVD (nolock) on KAVD.KATicketId = KATD.KATicketId
  WHERE  KATD.isdeleted=0    
  group by KATD.KATicketId
  )
		SELECT Distinct KATD.KAId,KATD.ProjectId,KATD.KATicketId,KATD.CreatedBy,KATD.KATitle,KATD.Status,KATD.Effort,  
		 '' as Review,KATD.authorname as EmployeeName, VCTE.VersionNo as VersionNo 
		 FROM  [AVL].[KEDB_TRN_KATicketDetails] KATD (nolock) 		 
		INNER JOIN  @StatusDetails  S on S.Status= KATD.Status  
		INNER JOIN  @AppIDs  A on A.ApplicationId= KATD.ApplicationId  
		INNER JOIN  @CauseCodeIds  CC on CC.CauseId= KATD.CausecodeId  
		INNER JOIN  @ResolutionIds  RC on RC.ResolutionId= KATD.ResolutionId  
		LEFT JOIN VersionCTE VCTE (nolock) on VCTE.KATicketId = KATD.KATicketId
		WHERE KATD.ProjectID = @ProjectID and KATD.isdeleted=0     
		ORDER BY KATD.KATicketId 
   END

     
  END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()	   
		EXEC AVL_InsertError '[AVL].[KEDB_GetSearchKATickets]  ', @ErrorMessage, 0,@ProjectID
		RETURN @ErrorMessage
  END CATCH   
END
