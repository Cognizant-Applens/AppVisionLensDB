/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetResolutionWorkbenchDetails]  
(  
	@SearchFilters [AVL].[TVP_KEDB_ResolutionWorkbenchFilters] READONLY
)
AS
BEGIN	

    BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @FilterText VARCHAR(120)
	DECLARE @searchText varchar(120)		
	DECLARE @AccountId BIGINT
	DECLARE @ProjectIds TABLE(ProjectId BIGINT)
	DECLARE @TicketId [varchar](100) 	
	DECLARE @AllSelectCheck [varchar](50)
	DECLARE @KATitleCheck  [varchar](50)
	DECLARE @KADescriptionCheck  [varchar](50)
	DECLARE @ActivityDescriptionCheck  [varchar](50)
	DECLARE @KeyWordCheck  [varchar](50)
	DEclare @tempResolutionWorkbench TABLE(KAID BIGINT,KATicketid nvarchar(50))
	Declare @CauseCodeCheck [varchar](50)
	Declare @ResolutionCodeCheck [varchar] (50)

	DECLARE @FilterField VARCHAR(500)

	SELECT @searchText = SearchKey  FROM  @SearchFilters


	INSERT INTO @ProjectIds
     SELECT Item  FROM dbo.Split((SELECT ProjectId  FROM   @SearchFilters),',')

	SELECT 
		@KATitleCheck = KATitleEnable,--(CASE WHEN KATitleEnable =1 THEN 'RW.KATitle,' ELSE '' END ),
		@KADescriptionCheck = KADescriptionEnable, --(CASE WHEN KADescriptionEnable =1 THEN 'RW.Description,' ELSE '' END),
		@KeyWordCheck = KeyWordEnable ,-- (CASE WHEN KeyWordEnable =1 THEN 'RW.KeyWords,' ELSE '' END),
		@ActivityDescriptionCheck = ActivityDescriptionEnable, -- (CASE WHEN ActivityDescriptionEnable =1 THEN 'RW.ActivityDescription,' ELSE '' END) ,
		@CauseCodeCheck = CauseCodeEnable, --(Case when CauseCodeEnable =1 then 'RW.CauseCode,' ELSE '' END ),
		@ResolutionCodeCheck = ResolutionCodeEnable --(Case when ResolutionCodeEnable =1 then 'RW.ResolutionCode,' ELSE '' END)
	FROM @SearchFilters
	
	-- for more than one word
set @FilterText =@searchText

SELECT a.* into #tempKADetails from (
SELECT KAId,KATicketID,ProjectId,KATitle,Status,CauseCodeId,ResolutionId,Description,
 KeyWords,AuthorName,Effort,AutomationScope,CreatedBy,CreatedOn,
 Isdeleted,ApplicationId,Remarks from  [AVL].[KEDB_TRN_KATicketDetails]  With (NOLOCK)
where  Isdeleted=0 and Status='Approved' 
union 
SELECT R.KAId,R.KAticketid,
R.ProjectId,R.KATitle,R.Status,R.CauseCodeId,R.ResolutionId,R.Description,
R.KeyWords,R.AuthorName,R.Effort,R.AutomationScope,R.CreatedBy,R.CreatedOn,
R.Isdeleted,R.ApplicationId,R.Remarks 
from (select KAV.KAId,KAV.KATicketID,KAV.ProjectId,KAV.KATitle,KAV.Status,KAV.CauseCodeId,KAV.ResolutionId,KAV.Description,
 KAV.KeyWords,KAV.AuthorName,KAV.Effort,KAV.AutomationScope,KAV.CreatedBy,KAV.CreatedOn,
 KAV.Isdeleted,KAV.ApplicationId,KAV.Remarks,
             row_number()over(partition by KAV.KAticketID  order by KAV.KAID desc)  as rn
       from [AVL].KEDB_TRN_KATicketVersionDetails KAV With (NOLOCK)    
	   inner join [AVL].[KEDB_TRN_KATicketDetails] KA on KAV.KATicketID=KA.KATicketID
	   where KAV.KATicketID not in (SELECT KATicketID from  [AVL].[KEDB_TRN_KATicketDetails]  With (NOLOCK)
where  Isdeleted=0 and Status='Approved' )
        ) as R
where R.rn = 1 )a
If(@KATitleCheck =1)
begin
	insert INTO @tempResolutionWorkbench
		SELECT DISTINCT KA.KAId, KATicketID 	FROM #tempKADetails KA With (NOLOCK)
		JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
	    WHERE 	KA.IsDeleted = 0 AND KA.Status ='Approved' and
		KA.KATitle like '%' + @FilterText + '%'
end
If(@KADescriptionCheck =1)
begin
	insert INTO @tempResolutionWorkbench
		SELECT DISTINCT KA.KAId, KATicketID 	FROM #tempKADetails KA With (NOLOCK)
		JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
	    WHERE 	KA.IsDeleted = 0 AND KA.Status ='Approved' and
		KA.Description like '%' + @FilterText + '%'
		
end
If(@KeyWordCheck =1)
begin
	insert INTO @tempResolutionWorkbench
		SELECT DISTINCT KA.KAId, KATicketID FROM #tempKADetails KA With (NOLOCK)
		JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
		WHERE 	KA.IsDeleted = 0 AND KA.Status ='Approved' and
		KA.KeyWords like '%' + @FilterText + '%'
	
end
If(@ActivityDescriptionCheck =1)
begin
	insert INTO @tempResolutionWorkbench
		SELECT DISTINCT KA.KAId, KATicketID FROM #tempKADetails KA With (NOLOCK)
		JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
		JOiN  AVL.KEDB_TRN_KATicketActivityDetails KAAD on  KA.KAID = KAAd.KAId and KAAD.IsDeleted=0
		WHERE 	KA.IsDeleted = 0 AND KA.Status ='Approved' and
		KAAD.ActivityDescription like '%' + @FilterText + '%'
	
end
If(@CauseCodeCheck =1)
begin
insert INTO @tempResolutionWorkbench
	SELECT DISTINCT KA.KAId, KATicketID	FROM #tempKADetails KA With (NOLOCK)
	JOIN [AVL].[DEBT_MAP_CauseCode] C (NOLOCK) ON KA.CauseCodeId = C.CauseID AND C.IsDeleted=0
	JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
    WHERE C.CauseCode like '%' + @FilterText + '%'
	and KA.IsDeleted = 0 AND KA.Status ='Approved' 
end	
If(@ResolutionCodeCheck =1)
begin
insert INTO @tempResolutionWorkbench
	SELECT DISTINCT KA.KAId, KATicketID	FROM #tempKADetails KA With (NOLOCK)
	JOIN [AVL].[DEBT_MAP_ResolutionCode] R (NOLOCK) ON KA.ResolutionId = R.ResolutionID  AND R.IsDeleted=0
	JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
    WHERE  R.ResolutionCode like '%' + @FilterText + '%'
	and KA.IsDeleted = 0 AND KA.Status ='Approved' 
end	
	select distinct KAID,KATicketid into #KAIDs from @tempResolutionWorkbench
	
	--select * from @tempResolutionWorkbench
	SELECT DISTINCT KA.KAId, KA.KATicketID, KA.KATitle, KA.AuthorName, KA.[Status],
	 KA.[Description], KA.KeyWords,
	 ServiceID = STUFF
    ((
		SELECT DISTINCT ','+ CAST(KASM.ServiceID AS VARCHAR(400))  
         	FROM [AVL].[KEDB_TRN_KAServiceMapping] KASM With (nolock) 
            join #KAIDs t on t.KAID = KASM.KAId
            JOIN AVL.TK_MAS_ServiceActivityMapping SM (NOLOCK) ON KASM.ServiceID= SM.ServiceID AND SM.IsDeleted=0
			JOIN AVL.TK_PRJ_ProjectServiceActivityMapping SPM (NOLOCK)  ON SPM.ServiceMapID = SM.ServiceMappingID AND SPM.IsDeleted=0  
			JOIN @ProjectIds P  ON SPM.ProjectID = P.ProjectId				
      	FOR XMl PATH('') 
   	  ),1,1,''
	 ), 
	C.CauseID as CauseId,C.CauseCode,
	R.ResolutionCode as ResolutionCode,R.ResolutionID as ResolutionId, KA.ProjectId, 
	AD.ApplicationID, AD.ApplicationName
	into #tempResolutionWithFilter
	FROM #tempKADetails KA With (NOLOCK)
	JOIN [AVL].[DEBT_MAP_CauseCode] C (NOLOCK) ON KA.CauseCodeId = C.CauseID AND C.IsDeleted=0
	JOIN [AVL].[DEBT_MAP_ResolutionCode] R (NOLOCK) ON KA.ResolutionId = R.ResolutionID  AND R.IsDeleted=0
	JOIN @ProjectIds P ON KA.ProjectId = P.ProjectId
	join #KAIDs t on t.KAID = KA.KAId
	JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON KA.ApplicationId=AD.ApplicationID AND AD.IsActive=1
	JOIN AVL.APP_MAP_ApplicationProjectMapping AP (NOLOCK) ON AD.ApplicationID=AP.ApplicationID	AND AP.IsDeleted=0	AND AP.ProjectId = P.ProjectId			
	WHERE 	KA.IsDeleted = 0 AND KA.Status ='Approved'
	


	SELECT * FROM #tempResolutionWithFilter

	--Service Details Table
	SELECT DISTINCT 
	SM.ServiceID , SM.ServiceName , temp_KA.KAId	
	from #tempResolutionWithFilter temp_KA With (NOLOCK)
	JOIN [AVL].[KEDB_TRN_KAServiceMapping] KA_S (NOLOCK) ON temp_KA.KAId=KA_S.KAID
	JOIN AVL.TK_MAS_ServiceActivityMapping SM (NOLOCK) ON KA_S.ServiceID= SM.ServiceID --AND SM.IsDeleted=0
	JOIN AVL.TK_PRJ_ProjectServiceActivityMapping SPM (NOLOCK)  ON SPM.ServiceMapID = SM.ServiceMappingID --AND SPM.IsDeleted=0  
	JOIN @ProjectIds P ON SPM.ProjectID = P.ProjectId
	WHERE KA_S.IsDeleted=0 AND SM.IsDeleted=0 AND SPM.IsDeleted=0


	SELECT KA_R.KAID,Sum(rating) TotalRating,Count(rating) RatingCount from AVL.KEDB_TRN_KARating_MapTicketId KA_R With (NOLOCK)
	JOIN #tempResolutionWithFilter temp_KA (NOLOCK) on KA_R.KAID=temp_KA.KAId GROUP BY KA_R.KAID
 	
	DROP TABLE #KAIDs	
	DROP TABLE #tempResolutionWithFilter 
	Drop Table #tempKADetails
	SET NOCOUNT OFF
	 END try

      BEGIN catch
          DECLARE @ErrorMessage VARCHAR(2000);
          SELECT @ErrorMessage = Error_message()
		
         EXEC AVL_InsertError '[AVL].[KEDB_GetResolutionWorkbenchDetails]', @ErrorMessage,'',0
      END catch
END
