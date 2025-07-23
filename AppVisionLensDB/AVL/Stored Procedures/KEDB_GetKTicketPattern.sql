/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_GetKTicketPattern] 
  (	             
    @ProjectID BIGINT ,
	@HealingTicketID NVARCHAR(100),
	@UserId NVARCHAR(50),
	@ChildTicketId NVARCHAR(1000) 
  )
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;

 DECLARE @ChildTicketIds TABLE(MappedTicketId NVARCHAR(1000))

 CREATE TABLE #KTicket_ProjectPatternMapping(
	[HealingTicketID] [varchar](50) NULL,
	[ProjectID] [int] NOT NULL,
	[ApplicationID] [int] NULL,	
	[ResolutionCodeId] [varchar](50) NULL,
	[CauseCodeId] [varchar](50) NULL
)

	INSERT INTO @ChildTicketIds  
    SELECT Item  FROM dbo.Split(@ChildTicketId,',')

	INSERT INTO #KTicket_ProjectPatternMapping
				Select distinct HealingTicketID,ProjectID,ApplicationID
				--ApplicationID = xDim.value('/x[1]','varchar(max)') 
				, ResolutionCode = xDim.value('/x[2]','varchar(max)') 
				,CauseCode= xDim.value('/x[3]','varchar(max)')
				
				From  (Select   HealingTicketID,HPPM.ProjectID AS ProjectID,HPPM.ApplicationID,
				   CAST('<x>' + replace(HealPattern,'-','</x><x>')+'</x>' as xml) as xDim
						FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM With (nolock) 
						INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD  (nolock)
						ON HTD.ProjectPatternMapID = HPPM.ProjectPatternMapID
						 INNER JOIN AVL.APP_MAP_ApplicationProjectMapping  APM (nolock) on 
						  APM.ApplicationID = HPPM.ApplicationID and APM.IsDeleted=0
						  INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON 
						  APM.ApplicationID=AD.ApplicationID AND AD.IsActive=1
						WHERE HPPM.ProjectID=@ProjectID
						 AND ISNULL(HPPM.ManualNonDebt,0) != 1 and HTD.TicketType ='K' 
						 AND patternstatus=1 and HPPM.IsDeleted=0
						 AND HealingTicketID = @HealingTicketID
						) as A 

 
       SELECT * INTO #TicketMasterDetails FROM [AVL].[TK_TRN_TicketDetail] TM With (NOLOCK)
	   INNER JOIN @ChildTicketIds CT ON TM.TicketID = CT.MappedTicketId
	   WHERE ProjectID = @ProjectId
	   DECLARE @SID INT =0
       
	  SELECT top 1 HealingTicketID,ApplicationID as ApplicationName, ResolutionCodeId,
		  CauseCodeId, ServiceId  = STUFF
    ((
		SELECT DISTINCT ','+ CAST(ServiceID AS VARCHAR(400)) 
		    FROM  [AVL].[DEBT_PRJ_HealParentChild] HPC With (nolock)	   	
	         INNER JOIN #TicketMasterDetails TM (NOLOCK) ON  TM.TicketID = HPC.DARTTicketID AND 
		     TM.IsDeleted =0 AND TM.ProjectID = @ProjectID 
		     AND HealingTicketID = @HealingTicketID AND HPC.IsDeleted=0 AND TM.IsDeleted=0			
      	FOR XMl PATH('') 
   	  ),1,1,''
	 ) 
		FROM #KTicket_ProjectPatternMapping HTD
		

		drop table #KTicket_ProjectPatternMapping
		drop table #TicketMasterDetails
		SET NOCOUNT OFF
		 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetKTicketPattern] ', @ErrorMessage,@UserId,@ProjectID
		RETURN @ErrorMessage
  END CATCH   
END
