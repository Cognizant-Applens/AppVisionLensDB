/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[KEDB_UpdateKADetailReMap] 
  (	             
    @ProjectID BIGINT ,
	@SrcHealingTicketID NVARCHAR(100),
	@DesHealingTicketID NVARCHAR(100)=null,
	@UserId NVARCHAR(50),
	@ReMap bit=0,
	@HealTicketList dbo.SaveHealRemappingDetails READONLY
  )
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON;

    CREATE TABLE #TicketList 
              (
              ID INT IDENTITY
              ,TicketID VARCHAR(50)
              ,Ischecked VARCHAR(50)
              )

              INSERT INTO #TicketList               
              SELECT * FROM @HealTicketList 

 --create temp table
   CREATE TABLE #temp1(
	KAId [bigint] not NULL,
	KATicketID nvarchar(50) NULL,
	ServiceID [bigint] NULL
)

  CREATE TABLE #temp2(
	KAId [bigint] not NULL,
	KATicketID nvarchar(50) NULL,
	ServiceID [bigint] NULL
)

	CREATE TABLE #temp3   
(  
	KAId [bigint] not NULL,
	KATicketID nvarchar(50) NULL,
	ServiceID [bigint] NULL
)  

--Create temp variable for cursor
	DECLARE @kAId [bigint] 
	DECLARE @KATicketID nvarchar(50) 
	DECLARE @ServiceID [bigint] 

	--get KA with 
  insert into #temp1
Select TKD.KAId,TKD.KATicketID,TTD.ServiceID FROM  [AVL].[KEDB_TRN_KATicketDetails] TKD 
	JOIN [AVL].[KEDB_TRN_KTicketMapping] TKM ON TKD.KATicketID=TKM.KATicketId 	
	JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD ON HTD.HealingTicketID = TKM.KTicketId AND HTD.HealingTicketID=@SrcHealingTicketID
	JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM ON HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
	AND HPPM.ProjectID = @ProjectID
	JOIN [AVL].[DEBT_PRJ_HealParentChild] DPH ON DPH.ProjectPatternMapID = HTD.ProjectPatternMapID
	JOIN [AVL].[TK_TRN_TicketDetail] TTD ON TTD.TicketID=DPH.DARTTicketID AND TTD.ProjectID=@ProjectID
	JOIN #TicketList TL on TL.TicketID=TTD.TicketID
	WHERE DPH.MapStatus=1 AND TKM.IsDeleted=0 AND TTD.IsDeleted=0 AND DPH.IsDeleted=0 AND TKD.IsDeleted=0 AND HTD.IsDeleted = 0 AND HPPM.IsDeleted = 0
		GROUP BY TKD.KAId,TKD.KATicketID,TTD.ServiceID

	 insert into #temp2
Select TKD.KAId,TKD.KATicketID,TTD.ServiceID FROM  [AVL].[KEDB_TRN_KATicketDetails] TKD 
	JOIN [AVL].[KEDB_TRN_KTicketMapping] TKM ON TKD.KATicketID=TKM.KATicketId 
	JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD ON HTD.HealingTicketID = TKM.KTicketId AND HTD.HealingTicketID=@SrcHealingTicketID
	JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM ON HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
	AND HPPM.ProjectID = @ProjectID
	JOIN [AVL].[DEBT_PRJ_HealParentChild] DPH ON DPH.ProjectPatternMapID = HTD.ProjectPatternMapID
	JOIN [AVL].[TK_TRN_TicketDetail] TTD ON TTD.TicketID=DPH.DARTTicketID  AND TTD.ProjectID=@ProjectID
	WHERE DPH.MapStatus=1 AND TKM.IsDeleted=0 AND TTD.IsDeleted=0 AND DPH.IsDeleted=0 AND TKD.IsDeleted=0 AND HTD.IsDeleted = 0 AND HPPM.IsDeleted = 0
		GROUP BY TKD.KAId,TKD.KATicketID,TTD.ServiceID

	--Get unique rows by comparing active and inactive ticket service
	insert into #temp3
		SELECT * FROM  #temp1 T2 WHERE  NOT EXISTS (SELECT *
        FROM  #temp2 T1
        WHERE
           T1.KATicketID = T2.KATicketID AND
           T1.ServiceID = T2.ServiceID)

	--iterate #temp3 with cursor to update KA service mapping 
	UPDATE TKM SET TKM.isdeleted=1,ModifiedBy=@UserId,ModifiedOn=GETDATE() FROM [AVL].[KEDB_TRN_KAServiceMapping] TKM 
			JOIN [AVL].[KEDB_TRN_KATicketDetails] TKD on TKD.KAId=TKM.KAID 
				JOIN #temp3 tem ON TKD.KATicketID=tem.KATicketID AND TKM.ServiceID=tem.ServiceID
	
	--To update KA service with Destination Healing Ticket ID
	if(@ReMap=1)
	BEGIN

		DELETE FROM #temp1

		INSERT INTO #temp1
		Select TKD.KAId,TKD.KATicketID,TTD.ServiceID FROM  [AVL].[KEDB_TRN_KATicketDetails] TKD 
			JOIN [AVL].[KEDB_TRN_KTicketMapping] TKM ON TKD.KATicketID=TKM.KATicketId 
			JOIN [AVL].[DEBT_TRN_HealTicketDetails] HTD ON HTD.HealingTicketID = TKM.KTicketId AND HTD.HealingTicketID=@DesHealingTicketID
			JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] HPPM ON HPPM.ProjectPatternMapID = HTD.ProjectPatternMapID
			AND HPPM.ProjectID = @ProjectID
			JOIN [AVL].[DEBT_PRJ_HealParentChild] DPH ON DPH.ProjectPatternMapID = HTD.ProjectPatternMapID
			JOIN [AVL].[TK_TRN_TicketDetail] TTD ON TTD.TicketID=DPH.DARTTicketID  AND TTD.ProjectID=@ProjectID
			WHERE DPH.MapStatus=1 AND TKM.IsDeleted=0 AND TTD.IsDeleted=0 AND DPH.IsDeleted=0 and TKD.IsDeleted=0
			AND HTD.IsDeleted = 0 AND HPPM.IsDeleted = 0
				GROUP BY TKD.KAId,TKD.KATicketID,TTD.ServiceID

			DECLARE @MyCursor CURSOR;
	SET @MyCursor = CURSOR FOR
    select * from #temp1

	OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
		INTO @kAId,@KATicketID,@ServiceID
		While @@FETCH_STATUS = 0
	Begin
		
		IF NOT EXISTS(SELECT * FROM [AVL].[KEDB_TRN_KAServiceMapping] TKM 
			WHERE TKM.KAID=@kAId and TKM.ServiceID=@ServiceID)
			BEGIN
				INSERT INTO [AVL].[KEDB_TRN_KAServiceMapping] 
				VALUES	(@kAId,@ServiceID,0,@UserId,GETDATE(),null,null)

			END
		ELSE
			BEGIN
				UPDATE TKM SET TKM.isdeleted=0 FROM [AVL].[KEDB_TRN_KAServiceMapping] TKM 
					WHERE TKM.KAID=@kAId and TKM.ServiceID=@ServiceID
			END

		 FETCH NEXT FROM @MyCursor 
		 INTO @kAId,@KATicketID,@ServiceID
	End
	CLOSE @MyCursor ;
    DEALLOCATE @MyCursor

	END

	--Drop temp table	
	drop table #temp1
	drop table #temp2
	drop table #temp3 

		 END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(4000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[KEDB_UpdateKADetailReMap] ', @ErrorMessage,@UserId,@ProjectID
		RETURN @ErrorMessage
  END CATCH   
END
