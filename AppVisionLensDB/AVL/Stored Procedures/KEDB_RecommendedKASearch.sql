/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_RecommendedKASearch]
(  
	@SearchFilters [AVL].[TVP_KEDB_ResolutionWorkbenchFilters] READONLY,
	@IsCognizant BIT	
)
AS
BEGIN

	BEGIN TRY
 	SET NOCOUNT ON;
  	
	DECLARE @ProjectIds TABLE(ProjectId BIGINT)
	DECLARE @ProjectId VARCHAR(100)
	DECLARE @AccountId BIGINT
	DECLARE @ApplicationId BIGINT
	DECLARE @ServiceId BIGINT
	DECLARE @CauseCodeMapID BIGINT
	DECLARE @ResolutionCodeMapID BIGINT		
	DECLARE @TicketId VARCHAR(100)	

	INSERT INTO @ProjectIds  -- having account level projectids
    SELECT Item  FROM dbo.Split((SELECT ProjectId  FROM  @SearchFilters),',')  
	
	select @ProjectId = AccountId FROM @SearchFilters  -- ticket relevant projectid
	select @TicketId = TicketId FROM @SearchFilters  -- ticket relevant projectid

	SELECT KAId, KATicketID, KATitle, AuthorName, [Status], [Description], KeyWords, 
	CauseId, CauseCode,ResolutionId, ResolutionCode,
	ProjectId, ApplicationId, ApplicationName, ActivityDescription 
	INTO #tempResolutionWorkbench FROM (

	SELECT DISTINCT KA.KAId,KA.KATicketID,KA.KATitle,KA.AuthorName, 
	KA.[Status],KA.[Description],KA.KeyWords,C.CauseID,	C.CauseCode,
	R.ResolutionID,	R.ResolutionCode,KA.ProjectId,AD.ApplicationID, AD.ApplicationName,
	ActivityDescription = STUFF
    ((
		SELECT DISTINCT ','+ CAST(KAAD.ActivityDescription AS VARCHAR(400))  
         	FROM AVL.KEDB_TRN_KATicketActivityDetails KAAD  
           Join  [AVL].[KEDB_TRN_KATicketDetails] t  on t.KAID = KAAD.KAID 	and KAAD.IsDeleted=0 and t.KAId = KA.KAId											
      	FOR XMl PATH('') 
   	  ),1,1,'' 
	 )  
	FROM [AVL].[KEDB_TRN_KATicketDetails] KA (NOLOCK)
	JOIN [AVL].[DEBT_MAP_CauseCode] C  (NOLOCK) ON KA.CauseCodeId = C.CauseID AND C.IsDeleted=0
	JOIN [AVL].[DEBT_MAP_ResolutionCode] R (NOLOCK)  ON KA.ResolutionId = R.ResolutionID  AND R.IsDeleted=0	
    JOIN @ProjectIds P  ON P.ProjectId = KA.ProjectId 
	
	JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON KA.ApplicationId=AD.ApplicationID AND AD.IsActive=1
	JOIN AVL.APP_MAP_ApplicationProjectMapping AP (NOLOCK) ON AD.ApplicationID=AP.ApplicationID	AND AP.IsDeleted=0	AND AP.ProjectId = P.ProjectId

	WHERE KA.IsDeleted = 0 AND KA.Status ='Approved') AS #tempResolutionWorkbench	



	-- GET VALUES FROM TICKET TABLE
	SELECT   @ApplicationID = ApplicationID,
			 @ServiceID= ServiceID,
			 @CauseCodeMapID= CauseCodeMapID, 
			 @ResolutionCodeMapID= ResolutionCodeMapID		 			 
	FROM  [AVL].[TK_TRN_TicketDetail] TD 	
	WHERE ProjectID = @ProjectId AND TicketID = @TicketID  AND IsDeleted = 0

	IF @IsCognizant = 1
	BEGIN
		-- APPLY VALUES from ticket table
		SELECT DISTINCT KAId, KATicketID, KATitle, AuthorName, [Status], [Description], KeyWords, 
		CauseId, CauseCode, ResolutionCode, ResolutionId, 
		ProjectId, ApplicationId, ApplicationName, ActivityDescription INTO #tempResolutionWithFilter FROM
		(SELECT DISTINCT RW.KAId, KATicketID, KATitle, AuthorName, [Status], [Description], KeyWords, 
		CauseId, CauseCode, ResolutionCode, ResolutionId, 
		ProjectId, ApplicationId, ApplicationName, ActivityDescription from
		#tempResolutionWorkbench RW 	
		JOIN [AVL].[KEDB_TRN_KAServiceMapping] KA_SM (NOLOCK) ON RW.KAId = KA_SM.KAID
		WHERE RW.ApplicationId =  @ApplicationID  
		OR RW.CauseId = @CauseCodeMapID 
		OR RW.ResolutionID = @ResolutionCodeMapID
		OR KA_SM.ServiceID = @ServiceId) 	
		AS #tempResolutionWithFilter
	
		SELECT * FROM #tempResolutionWithFilter  
	
		--Service Details Table
		SELECT DISTINCT 
		SM.ServiceID , SM.ServiceName , temp_KA.KAId	
		from #tempResolutionWithFilter temp_KA 	
		JOIN [AVL].[KEDB_TRN_KAServiceMapping] KA_S (NOLOCK) ON temp_KA.KAId=KA_S.KAID
		JOIN AVL.TK_MAS_ServiceActivityMapping SM (NOLOCK) ON KA_S.ServiceID= SM.ServiceID --AND SM.IsDeleted=0
		JOIN AVL.TK_PRJ_ProjectServiceActivityMapping SPM (NOLOCK)  ON SPM.ServiceMapID = SM.ServiceMappingID --AND SPM.IsDeleted=0  	
		JOIN @ProjectIds P ON SPM.ProjectID = P.ProjectId
		WHERE KA_S.IsDeleted=0 AND SM.IsDeleted=0 AND SPM.IsDeleted=0

		--Rating details table
		SELECT KA_R.KAID,Sum(rating) TotalRating,Count(rating) RatingCount from AVL.KEDB_TRN_KARating_MapTicketId KA_R
		JOIN #tempResolutionWithFilter temp_KA on KA_R.KAID=temp_KA.KAId GROUP BY KA_R.KAID

		DROP TABLE #tempResolutionWithFilter
	END
	ELSE
	BEGIN
		-- APPLY VALUES from ticket table
		SELECT DISTINCT KAId, KATicketID, KATitle, AuthorName, [Status], [Description], KeyWords, 
		CauseId, CauseCode, ResolutionCode, ResolutionId, 
		ProjectId, ApplicationId, ApplicationName, ActivityDescription INTO #tempWithoutService FROM
		(SELECT DISTINCT RW.KAId, KATicketID, KATitle, AuthorName, [Status], [Description], KeyWords, 
		CauseId, CauseCode, ResolutionCode, ResolutionId, 
		ProjectId, ApplicationId, ApplicationName, ActivityDescription from
		#tempResolutionWorkbench RW 			 
		WHERE RW.ApplicationId =  @ApplicationID  
		OR RW.CauseId = @CauseCodeMapID 
		OR RW.ResolutionID = @ResolutionCodeMapID)		 
		AS #tempWithoutService  

		select * from #tempWithoutService
		
		--Rating details table
		SELECT KA_R.KAID,Sum(rating) TotalRating,Count(rating) RatingCount from AVL.KEDB_TRN_KARating_MapTicketId KA_R
		JOIN #tempWithoutService temp_KA on KA_R.KAID=temp_KA.KAId GROUP BY KA_R.KAID
		
		DROP TABLE #tempWithoutService
	END
 
 	DROP TABLE #tempResolutionWorkbench	 

	END TRY
		  
	  BEGIN catch
          DECLARE @ErrorMessage VARCHAR(2000);
          SELECT @ErrorMessage = Error_message()	
        
      END catch

END
