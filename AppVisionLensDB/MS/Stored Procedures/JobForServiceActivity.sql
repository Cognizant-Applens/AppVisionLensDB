/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================  
-- Create date: <Create Date,,>  

-- Description: Job sp that updates,inserts service activity details and project master with mainspring data  

-- =============================================  
--EXEC [MS].[JobForServiceActivity] 
CREATE PROCEDURE [MS].[JobForServiceActivity]  

AS  

BEGIN
SET NOCOUNT ON;

--1) To Update the Project Master with Flag as 'Y'  

--UPDATE AVL.MAS_ProjectMaster SET IsMainSpringConfigured = 'Y'  

-- WHERE IsDeleted = 'N'  and EsaProjectID IN(SELECT DISTINCT ProjectID  from [CTSC00698426801].[Swiftalm].[Swiftalm].[CTS_AVM_DART_ACTIVITIES_VIEW])  

--2)Truncates the previous day records in   

--select * from MS.Everyday_Data 

--TRUNCATE TABLE MS.Everyday_Data

--3)Inserting the table with the present day data

		--INSERT INTO MS.Everyday_Data
		--SELECT
		--*
		--FROM [CTSC00698426801].[Swiftalm].[Swiftalm].[CTS_AVM_DART_ACTIVITIES_VIEW]
		--WHERE projectid IS NOT NULL

DECLARE @ccount INT

SET @ccount = 0

SET @ccount = (SELECT
		COUNT(*)
	FROM MS.Everyday_Data)

		IF (@ccount > 0) 
			BEGIN

					--SELECT * from MS.Data_Daily   
					TRUNCATE TABLE MS.Data_Daily
					--SElect * into MS.Data_Daily FROM  MS._Everyday_Data   
					--3)Inserting the table with the present day data  

					DELETE FROM MS.Everyday_Data
					WHERE ServiceOfferingLevel2 = '-99999'

					DELETE FROM MS.[Everyday_Data]
					WHERE ActivityName IS NULL

					DELETE FROM MS.[Everyday_Data]
					WHERE ServiceOfferingLevel3 IS NULL

					--SELECT 'MS._Everyday_Data'
					--select * from MS.Everyday_Data
					
				UPDATE ED SET ED.ServiceOfferingLevel3=MS.ServiceName FROM   MS.[Everyday_Data]  ED
				INNER JOIN AVL.TK_MAS_Service MS ON ED.ServiceOfferingLevel3=MS.MainspringServiceName
				WHERE MS.MainspringServiceName IS 	NOT NULL


					INSERT INTO MS.Data_Daily

						SELECT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,LTRIM(RTRIM(ServiceOfferingLevel3)) AS ServiceOfferingLevel3
							,LTRIM(RTRIM(ActivityName))
							,ActivityType
							,PMPlanBaselinedDate

						FROM MS.[Everyday_Data] where ProjectID IN(
						SELECT  EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) --WHERE (ISNULL(IsMigratedFromDART,0)IN(1,2))
						)

					--SELECT 'MS.Data_Daily'
					--SELECT * from MS.Data_Daily
					--where serviceofferinglevel3='Known Errors Resolution'  
					-----For standard proj added to mainspring project-----
					SELECT
						* INTO #NMainspringProj
					FROM (SELECT
							*
						FROM AVL.MAS_ProjectMaster
						WHERE (IsMainSpringConfigured = 'N'
						OR IsMainSpringConfigured IS NULL)
						AND IsDeleted = 0 --AND (ISNULL(IsMigratedFromDART,0) IN(1,2))
						) A

						--SELECT '#NMainspringProj'
						--SELECT * from #NMainspringProj

					SELECT
						* INTO #NMainspringProjFinallst
					FROM (SELECT
							*
						FROM #NMainspringProj
						WHERE EsaProjectID IN (SELECT DISTINCT
								ProjectID
							FROM MS.Data_Daily)) B

						--SELECT '#NMainspringProjFinallst'
						--SELECT * from #NMainspringProjFinallst

					DECLARE @ProjCount INT;
					DECLARE @NewProj BIGINT;
					SET @ProjCount = (SELECT
							COUNT(EsaProjectID)
						FROM #NMainspringProjFinallst)
					WHILE (@ProjCount > 0) 
					BEGIN
								SET @NewProj = (SELECT TOP 1
										ProjectID
									FROM #NMainspringProjFinallst)

									--SELECT '@NewProj'
									--SELECT @NewProj

						IF EXISTS (SELECT
										ProjectID
									FROM AVL.MAS_ProjectMaster
									WHERE ProjectID = @NewProj
									AND IsDebtEnabled = 'Y') 
						
								BEGIN
								--SELECT 'INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster IsDebtEnabled = y'

								INSERT INTO AVL.PRJ_MainspringAttributeProjectStatusMaster
									SELECT
										ServiceID
										,ServiceName
										,AttributeID
										,AttributeName
										,StatusID
										,StatusName
										,FieldType
										,GETDATE()
										,'Admin'
										,NULL
										,NULL
										,IsDeleted
										,@NewProj
										,TicketMasterFields
									FROM AVL.PRJ_StandardAttributeProjectStatusMaster
									WHERE Projectid = @NewProj  AND IsDeleted=0


								UPDATE m
								SET m.FieldType = d.FieldType
								FROM AVL.PRJ_MainspringAttributeProjectStatusMaster AS M
								INNER JOIN AVL.MAS_DebtAttributeStatusMaster AS D
									ON m.ServiceID = d.ServiceID
									AND m.AttributeID = d.AttributeID
									AND m.StatusID = d.StatusID
								WHERE D.FieldType = 'M'
								AND m.Projectid = @NewProj AND M.IsDeleted=0 AND D.ISDELETED =0 

								UPDATE m
								SET m.FieldType = d.FieldType
								FROM AVL.PRJ_MainspringAttributeProjectStatusMaster AS M
								INNER JOIN AVL.MAS_MainspringAttributeStatusMaster AS D
									ON m.ServiceID = d.ServiceID
									AND m.AttributeID = d.AttributeID
									AND m.StatusID = d.StatusID
								WHERE D.FieldType = 'M'
								AND m.Projectid = @NewProj AND M.IsDeleted=0 AND D.ISDELETED =0 


								DELETE FROM #NMainspringProjFinallst
								WHERE ProjectID = @NewProj
								SET @ProjCount = (SELECT
										COUNT(EsaProjectID)
									FROM #NMainspringProjFinallst)

							END
                        ELSE
						BEGIN
							IF NOT EXISTS (SELECT TOP(1) 1 FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A  
		WHERE A.Projectid=@NewProj AND A.IsDeleted=0 
	) 
	--SELECT 'INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster] '
						        INSERT INTO [AVL].[PRJ_MainspringAttributeProjectStatusMaster]
								SELECT
								[ServiceID],
								ServiceName,
								AttributeID,
								AttributeName,
								[StatusID],
								[StatusName],
								FieldType,
								GETDATE(),
								'system',
								NULL,
								NULL,
								IsDeleted,
								@NewProj,
								[TicketDetailFields]			 
							FROM [AVL].[MAS_MainspringAttributeStatusMaster]		
							WHERE IsDeleted=0
							    
					        UPDATE  A    
							SET     A.FieldType=B.FieldType ,    
							A.ModifiedBY = 'system' ,    
							A.ServiceId= B.ServiceId,    
							A.ModifiedDateTime = GETDATE()    
							FROM [AVL].[PRJ_MainspringAttributeProjectStatusMaster] A ,    
							[AVL].[PRJ_StandardAttributeProjectStatusMaster] B    
							WHERE   A.ProjectID = B.ProjectID   
							AND A.ServiceId= B.ServiceId
							AND A.StatusID=B.StatusID
							AND A.AttributeID=B.AttributeID    
							AND A.AttributeName=B.AttributeName
							AND A.Projectid=@NewProj
							AND B.FieldType = 'M'
							AND A.IsDeleted=0 AND B.ISDELETED =0 

							DELETE FROM #NMainspringProjFinallst
								WHERE ProjectID = @NewProj
								SET @ProjCount = (SELECT
										COUNT(EsaProjectID)
									FROM #NMainspringProjFinallst)

						END

					END



					UPDATE AVL.MAS_ProjectMaster
					SET IsMainSpringConfigured = 'Y',
					TicketAttributeIntegartion = 2

					WHERE IsDeleted = 0
					AND EsaProjectID IN (SELECT DISTINCT
							ProjectID
						FROM MS.Data_Daily)
					--AND (ISNULL(IsMigratedFromDART,0) IN(1,2))
					-- DROP TABLE #NMainspringProj
					--5)Inserting with current day projects  
					UPDATE DD SET DD.ServiceOfferingLevel3=MS.ServiceName FROM    MS.Data_Daily  DD
				INNER JOIN AVL.TK_MAS_Service MS ON DD.ServiceOfferingLevel3=MS.MainspringServiceName
				WHERE MS.MainspringServiceName IS 	NOT NULL
				UPDATE BA SET BA.ServiceOfferingLevel3=MS.ServiceName FROM   MS.BaseActivityoriginal  BA
				INNER JOIN AVL.TK_MAS_Service MS ON BA.ServiceOfferingLevel3=MS.MainspringServiceName
				WHERE MS.MainspringServiceName IS 	NOT NULL

					--UPDATE AVL.MAS_ProjectMaster SET IsC20MappingCompleted = 'N' ,IsC2AppServiceMapCompleted='N' ,C20MappingCompletedTimestamp=NULL,C20AppServiceMapCompletedTimestamp =NULL
					--WHERE IsDeleted = 'N'  and EsaProjectID IN (SELECT DISTINCT ProjectID fROM MS.Data_Daily )  
					TRUNCATE TABLE MS.Base2
					INSERT INTO MS.Base2
						SELECT DISTINCT
						ProjectID
						,CONVERT(DATE, MAX(PMPlanBaselinedDate)) AS Effectivedate
						,0 AS flag
						FROM MS.Data_Daily
						WHERE PMPlanBaselinedDate IS NOT NULL
						GROUP BY	ProjectID
						,PMPlanBaselinedDate

					--6)Resetting the original set projects to 0 for comparision  
					UPDATE MS.Base1
					SET flag = 0

					--7)Inserting into project set with new projects if an  

					INSERT INTO MS.Base1
						SELECT DISTINCT
						ProjectID
						,CONVERT(DATE, MAX(Effectivedate)) AS Effectivedate
						,1 AS flag
						FROM MS.Base2
						WHERE projectid NOT IN (SELECT
						projectid
						FROM MS.Base1)
						GROUP BY	ProjectID
						,Effectivedate
					--8)Updating the original project set with flag 1 if there is any change in current day feed  

					UPDATE B1
					SET	B1.Effectivedate = B2.Effectivedate
						,B1.flag = 1
					FROM MS.Base1 B1
					INNER JOIN MS.Base2 B2
					ON B1.Projectid = B2.Projectid
					WHERE B1.effectivedate < B2.effectivedate

					--9)Truncating the daily feed list of activities  

					TRUNCATE TABLE MS.BaseActivityDaily
					--9)Inserting the daily feed list of activities  

					INSERT INTO MS.BaseActivityDaily
						SELECT DISTINCT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,ServiceOfferingLevel3
							,ActivityName
							,ActivityType
							,PMPlanBaselinedDate
							,0 AS flag
						FROM MS.Data_Daily

					--10)Get new data from daily table  

					SELECT
						B.* INTO #MainspringBaseActivityoriginaltoInsert
					FROM (SELECT DISTINCT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,ServiceOfferingLevel3
							,ActivityName
							,ActivityType
							,NULL AS PMPlanBaselinedDate
							,1 AS flag
						FROM MS.BaseActivityDaily 
						EXCEPT 
						SELECT DISTINCT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,ServiceOfferingLevel3
							,ActivityName
							,ActivityType
							,NULL AS PMPlanBaselinedDate
							,1 AS flag
						FROM MS.BaseActivityoriginal) AS B

					--select * from MS.BaseActivityoriginal  

					--11) Inserting the new data into Original table(data from step 10)  
					DELETE FROM MS.BaseActivityoriginal
					WHERE flag = 2

					UPDATE MS.BaseActivityoriginal
					SET flag = 0
					WHERE flag = 1

					INSERT INTO MS.BaseActivityoriginal

						SELECT DISTINCT
							M1.ProjectID
							,M1.ProjectName
							,M1.ProjectCategory
							,M1.ServiceOfferingLevel2
							,M1.ServiceOfferingLevel3
							,M1.ActivityName
							,M1.ActivityType
							,B1.effectivedate AS PMPlanBaselinedDate
							,1 AS flag
						FROM #MainspringBaseActivityoriginaltoInsert M1
						INNER JOIN MS.Base1 B1
							ON B1.ProjectID = M1.ProjectID --and B1.flag=1  

					--12)To get the Service catlogue that has been disabled in Mainspring  

					SELECT
						B.* INTO #MainspringBaseActivityoriginaltoupdate
					FROM (SELECT DISTINCT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,ServiceOfferingLevel3
							,ActivityName
							,ActivityType
							,NULL AS PMPlanBaselinedDate
							,2 AS flag
						FROM MS.BaseActivityoriginal 
						EXCEPT 
						SELECT DISTINCT
							ProjectID
							,ProjectName
							,ProjectCategory
							,ServiceOfferingLevel2
							,ServiceOfferingLevel3
							,ActivityName
							,ActivityType
							,NULL AS PMPlanBaselinedDate
							,2 AS flag
						FROM MS.BaseActivityDaily) AS B

		--13) To update flag in original table for the data that has been disabled in mainspring  

					UPDATE MO
					SET	MO.flag = 2
					,MO.PMPlanBaselinedDate = B1.effectivedate
					FROM MS.BaseActivityoriginal MO
					INNER JOIN #MainspringBaseActivityoriginaltoupdate M1
					ON  MO.Projectid = M1.Projectid
						AND MO.ProjectName = M1.ProjectName
						AND MO.ProjectCategory = M1.ProjectCategory
						AND MO.ServiceOfferingLevel2 = M1.ServiceOfferingLevel2
						AND MO.ServiceOfferingLevel3 = M1.ServiceOfferingLevel3
						AND MO.ActivityName = M1.ActivityName
						AND MO.ActivityType = M1.ActivityType
					INNER JOIN MS.Base1 B1
						ON B1.Projectid = M1.Projectid

					--Drop table  #MainspringBaseActivityoriginaltoupdate   
					--14)To Unhide  the Service catlogue that was in disabled yesterday and active today in Mainspring  

					SELECT
						A2.* INTO #MainspringServiceMapingUpdate
					FROM (SELECT DISTINCT
							PM.EsaProjectID
							,PM.ProjectID
							,SM.ServiceID
							,SM.ServiceName
							,NULL AS CategoryID
							,NULL AS CategoryName
							,SAM.ActivityID
							,SAM.ActivityName
						FROM AVL.TK_MAS_Service(NOLOCK) SM
						INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) STM
							ON STM.ServiceTypeID = SM.ServiceType
							AND STM.ServiceTypeID = 4
						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SAM
							ON SAM.ServiceTypeID = STM.ServiceTypeID
							AND SAM.ServiceID = SM.ServiceID AND ISNULL(SAM.IsDeleted,0)=0
						INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
							ON PSAM.ServiceMapID = SAM.ServiceMappingID
							AND PSAM.IsDeleted = 0
						INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM
							ON PM.ProjectID = PSAM.ProjectID --AND ( ISNULL(PM.IsMigratedFromDART,0) IN(1,2) )
							) A2

					--15)To Unhide  the Service catlogue that was in disabled yesterday and active today in Mainspring(data from step 14)  

					UPDATE PSAM
					SET	PSAM.IsHidden = 0
						,PSAM.EffectiveDate = NULL
						,PSAM.IsMainspringData = 'Y'
					FROM AVL.TK_MAS_ServiceActivityMapping SMP
					INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
						ON PSAM.ServiceMapID = SMP.ServiceMappingID
						AND PSAM.IsDeleted = 0
					--From MAP.ServiceProjectMapping SMP  
					INNER JOIN #MainspringServiceMapingUpdate MS
						ON MS.ProjectID = PSAM.ProjectID
						AND SMP.ServiceID = MS.ServiceID
						AND SMP.ActivityID = MS.ActivityID
					INNER JOIN MS.BaseActivityDaily MSD
						ON MSD.ProjectID = MS.EsaProjectID
						AND SMP.ServiceName = MSD.ServiceOfferingLevel3
						AND SMP.ActivityName = MSD.ActivityName

					--16)To Hide the service catlogue that has been disabled in mainspring (flag set as 2 in original table)  

					DECLARE @NoofActivityHide INT
					SET @NoofActivityHide = 0
					SET @NoofActivityHide = (SELECT
							COUNT(PSAM.ActivityID)
						FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK) PSAM

						INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping SMP
							ON SMP.ServiceMapID = PSAM.ServiceMappingID
							AND SMP.IsDeleted = 0

						INNER JOIN #MainspringServiceMapingUpdate MS
							ON MS.ProjectID = SMP.ProjectID
							AND PSAM.ServiceID = MS.ServiceID
							AND PSAM.ActivityID = MS.ActivityID

						INNER JOIN MS.BaseActivityoriginal MSD
							ON MSD.ProjectID = MS.EsaProjectID
							AND PSAM.ServiceName = MSD.ServiceOfferingLevel3
							AND PSAM.ActivityName = MSD.ActivityName

						WHERE MSD.flag = 2
						AND (SMP.IsHidden = 0
						OR SMP.IsHidden IS NULL))



					UPDATE PSAM

					SET	PSAM.IsHidden = 1
						,PSAM.EffectiveDate = MSD.PMPlanBaselinedDate
						,PSAM.IsMainspringData = 'Y'

					--From MAP.ServiceProjectMapping SMP  
					FROM AVL.TK_MAS_ServiceActivityMapping SMP
					INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
						ON PSAM.ServiceMapID = SMP.ServiceMappingID
						AND PSAM.IsDeleted = 0
					INNER JOIN #MainspringServiceMapingUpdate MS
						ON MS.ProjectID = PSAM.ProjectID
						AND SMP.ServiceID = MS.ServiceID
						AND SMP.ActivityID = MS.ActivityID
					INNER JOIN MS.BaseActivityoriginal MSD
						ON MSD.ProjectID = MS.EsaProjectID
						AND SMP.ServiceName = MSD.ServiceOfferingLevel3
						AND SMP.ActivityName = MSD.ActivityName
					WHERE MSD.flag = 2
					AND (PSAM.IsHidden = 0
					OR PSAM.IsHidden IS NULL)



					--17)To Get the new service catlogue for all projects  

					SELECT
						* INTO #MainspringServiceMapingInsert
					FROM MS.BaseActivityoriginal
					WHERE flag = 1

					--select * from #MainspringServiceMapingInsert  

					--18)To insert the new services from mainspring into service master and category master in DART  
					SELECT
						* INTO #MainspringServiceMapingInsertForNewService
					FROM #MainspringServiceMapingInsert
					WHERE ServiceOfferingLevel3 NOT IN (SELECT DISTINCT
							ServiceName
						FROM [AVL].[TK_MAS_Service]
						WHERE ServiceType = 4)

					--select * from #MainspringServiceMapingInsertForNewService  
					--INSERT INTO MAS.ServiceMaster   

					--select DISTINCT MSI.ServiceOfferingLevel3,'MPS','N',GETDATE(),'SYSTEM',NULL,NULL,MSI.ServiceOfferingLevel3  
					--FROM #MainspringServiceMapingInsertForNewService MSI where MSI.ServiceOfferingLevel3 not in (SELECT DISTINCT ServiceName FROM MAS.ServiceMaster where ServiceType='MPS')  

					--19)To Get the standard service catlogue which are configured in mainspring and insert into ServiceProjectMapping  

					SELECT
						B.* INTO #MainspringServiceMapingInsertActivityforExisting
					FROM (SELECT
							A2.EsaProjectID
							,A2.ProjectID
							,A2.ServiceID
							,A2.ServiceName
							,NULL AS CategoryID
							,NULL AS CategoryName
							,A2.ActivityID
							,A2.ActivityName

						FROM (SELECT DISTINCT
								PM.EsaProjectID
								,PM.ProjectID
								,SM.ServiceID
								,SM.ServiceName
								,NULL AS CategoryID
								,NULL AS CategoryName
								,SM.ActivityID
								,SM.ActivityName

							FROM #MainspringServiceMapingInsert SMP

							INNER JOIN AVL.MAS_ProjectMaster PM
								ON PM.EsaProjectID = SMP.ProjectID
								AND PM.IsDeleted = 0
								AND PM.IsMainSpringConfigured = 'Y' --AND (ISNULL(PM.IsMigratedFromDART,0) IN(1,2))

							INNER JOIN AVL.TK_MAS_Service S
								ON S.ServiceName = SMP.ServiceOfferingLevel3

							INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) STM
								ON STM.ServiceTypeID = S.ServiceType
								AND STM.ServiceTypeID = 4

							INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
								ON SM.ServiceID = S.ServiceID
								AND SM.ActivityName = SMP.ActivityName AND ISNULL(SM.IsDeleted,0)=0) A2 EXCEPT SELECT
							EsaProjectID
							,ProjectID
							,ServiceID
							,ServiceName
							,CategoryID
							,CategoryName
							,ActivityID
							,ActivityName
						FROM #MainspringServiceMapingUpdate) B

					--select * from #MainspringServiceMapingInsertActivityforExisting  
					DECLARE @NoofstandardActivityAdded INT

					SET @NoofstandardActivityAdded = 0

					SET @NoofstandardActivityAdded = (SELECT
							COUNT(TM.ActivityID)
						FROM #MainspringServiceMapingInsertActivityforExisting(NOLOCK) TM

						INNER JOIN AVL.TK_MAS_Service S
							ON S.ServiceName = TM.ServiceName
						INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) STM
							ON STM.ServiceTypeID = S.ServiceType
							AND STM.ServiceTypeID = 4
						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON SM.ServiceID = TM.ServiceID
							AND SM.ActivityID = TM.ActivityID AND ISNULL(SM.IsDeleted,0)=0)


					DELETE D
						FROM #MainspringServiceMapingInsertActivityforExisting D

						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON D.ServiceName = SM.ServiceName
							AND D.ActivityName = SM.ActivityName AND ISNULL(SM.IsDeleted,0)=0
						INNER JOIN avl.TK_PRJ_ProjectServiceActivityMapping SMP
							ON SM.ServiceMappingID = SMP.ServiceMapID
							--ADDED extra condition bug fix
							AND SMP.ProjectID=D.ProjectID
							AND SMP.isdeleted = 0


					----------------------------------------------------------------------------------------------------
					INSERT INTO avl.TK_PRJ_ProjectServiceActivityMapping
						SELECT
							SM.ServiceMappingID AS serviceMapID
							,TM.ProjectID
							,0
							,GETDATE()
							,'System'
							,NULL
							,NULL
							,0
							,NULL
							,'Y'
						FROM #MainspringServiceMapingInsertActivityforExisting(NOLOCK) TM

						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON SM.ServiceID = TM.ServiceID
							AND SM.ActivityID = TM.ActivityID
							AND SM.ServiceTypeID = 4 AND ISNULL(SM.IsDeleted,0)=0


					--20)To get the Custom Activity that are configured in Mainspring  

					SELECT
						B.* INTO #MainspringServiceMapingInsertFinalList
					FROM (SELECT
							Projectid
							,ServiceOfferingLevel3
							,ActivityName
						FROM #MainspringServiceMapingInsert EXCEPT SELECT
							TM.esAProjectid AS Projectid
							,TM.ServiceName AS ServiceOfferingLevel3
							,TM.ActivityName
						FROM #MainspringServiceMapingInsertActivityforExisting(NOLOCK) TM

						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON Sm.ServiceID = TM.ServiceID
							AND SM.ActivityID = TM.ActivityID AND ISNULL(SM.IsDeleted,0)=0
							AND SM.ServiceTypeID = 4) B

					--select * from #MainspringServiceMapingInsertFinalList  


					--21)To fetch servicemappingid for the custom activity by considering the  minimum value of Service Category mapping id (Irrespective of any activity)  

					SELECT
						A2.* INTO #MainspringServiceMapingInsertFinalListSMID

					FROM (SELECT DISTINCT
							PM.EsaProjectID
							,PM.ProjectID
							,SM.ServiceID
							,SM.ServiceName
							,NULL AS CategoryID
							,NULL AS CategoryName
							,MIN(sm.ServiceMappingID) AS SerMapingID

						FROM #MainspringServiceMapingInsertFinalList SMP

						INNER JOIN AVL.MAS_ProjectMaster PM
							ON PM.EsaProjectID = SMP.ProjectID
							AND PM.IsDeleted = 0
							AND PM.IsMainSpringConfigured = 'Y' --AND (ISNULL(PM.IsMigratedFromDART,0) IN(1,2))

						INNER JOIN [AVL].[TK_MAS_Service] S
							ON S.ServiceName = SMP.ServiceOfferingLevel3

						--INNER JOIN MAS.CategoryMaster C ON C.CategoryName=SMP.ServiceOfferingLevel3  

						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON (SM.ServiceID = S.ServiceID
							AND SM.ServiceTypeID = 4
							AND Sm.IsDeleted = 0)

						--WHERE SM.CategoryID not in(12,13)  

						GROUP BY	Pm.EsaProjectID
									,Pm.ProjectID
									,SM.ServiceID
									,SM.ServiceName) A2

				  Select * into #tmp FROM
				  (Select a.ProjectID,b.ServiceID,b.ActivityID,b.ServiceName,b.ActivityName 
				  from avl.TK_PRJ_ProjectServiceActivityMapping a join AVL.TK_MAS_ServiceActivityMapping b 
				  on a.ServiceMapID=b.ServiceMappingID AND ISNULL(b.IsDeleted,0)=0)d

					SELECT
						c.* INTO #MainspringServiceMapingInsertFinalListtoInsert

					FROM (SELECT
							FL.Projectid AS ESAProjectid
							,PM.ProjectID
							,FL.serviceofferinglevel3
							,FL.Activityname
						FROM #MainspringServiceMapingInsertFinalList FL

						INNER JOIN AVL.MAS_ProjectMaster PM
							ON FL.Projectid = PM.EsaProjectID --AND (ISNULL(PM.IsMigratedFromDART,0) IN(1,2))

						WHERE FL.serviceofferinglevel3 IS NOT NULL EXCEPT SELECT DISTINCT
							PM.EsaProjectID
							,PM.ProjectID
							,SM.ServiceName
							,SM.ActivityName
						FROM #tmp SMP
						INNER JOIN AVL.MAS_ProjectMaster PM
							ON PM.ProjectID = SMP.ProjectID
							AND PM.IsDeleted = 0
							AND PM.IsMainSpringConfigured = 'Y' --AND (ISNULL(PM.IsMigratedFromDART,0) IN(1,2))

						INNER JOIN AVL.TK_MAS_ServiceActivityMapping SM
							ON SM.ServiceID = SMP.ServiceID
							AND SM.ServiceTypeID = 4 AND ISNULL(SM.IsDeleted,0)=0

						WHERE SM.ServiceTypeID = 4) AS c


					--22) To isert the Sevice Catlogue with custom activity into ServiceProjectMapping  
					CREATE TABLE #SPMDatainsertActivity([InsertCount] [int] IDENTITY (1, 1) NOT NULL,
					[ServiceMapID] [int] NOT NULL,
					[ProjectID] [int] NOT NULL,
					[ServiceID] [int] NOT NULL,
					[ServiceName] VARCHAR(50) NULL,
					[ServiceShortName] [varchar](50) NULL,
					[CategoryID] [int]  NULL,
					[CategoryName] [varchar](100) NULL,
					[ActivityID] [int] NULL,
					[ActivityName] [varchar](100) NULL,
					[EffortType] [varchar](100) NULL,
					[MaintenanceType] [varchar](50) NULL,
					[IsDeleted] BIT NULL,
					[CreatedDateTime] [datetime] NULL,
					[CreatedBY] [varchar](50) NULL,
					[ModifiedDateTime] [datetime] NULL,
					[ModifiedBY] [varchar](50) NULL,
					[ServiceType] [varchar](50) NULL,
					[IsHidden] [bit] NULL,
					[EffectiveDate] [datetime] NULL,
					[IsC20Configured] [bit] NOT NULL,
					[StdCategoryID] [int] NULL,
					[Categorization] [varchar](100) NULL,
					[IsMainspringData] [char](1) NULL,
					AutomatableTypeID INT NULL)

					--select * from #MainspringServiceMapingInsertFinalListtoInsert  

					INSERT INTO #SPMDatainsertActivity

						SELECT
							SMI.SerMapingID
							,SMI.ProjectID
							,SMI.ServiceID
							,SMI.ServiceName
							,SMI.ServiceName
							,SMI.CategoryID
							,SMI.CategoryName
							,NULL AS ActivityID
							,SIL.ActivityName
							,NULL
							,NULL
							,0
							,GETDATE()
							,'System'
							,NULL
							,NULL
							,4
							,0
							,NULL
							,0
							,SMI.CategoryID
							,'ENVA'
							,'Y'
								,NULL
						FROM #MainspringServiceMapingInsertFinalListtoInsert SIL
						INNER JOIN #MainspringServiceMapingInsertFinalListSMID SMI
							ON SMI.EsaProjectID = SIL.EsaProjectID
							AND SMI.ServiceName = SIL.ServiceOfferingLevel3
							WHERE SIL.ActivityName IS NOT NULL
					UPDATE #SPMDatainsertActivity SET AutomatableTypeID=1 WHERE ServiceID NOT IN(1,4,5,6,7,8,10,41)
					UPDATE #SPMDatainsertActivity SET AutomatableTypeID=2 WHERE ServiceID  IN(1,4,5,6,7,8,10,41)
					DECLARE @Count INT
					SET @Count = (SELECT COUNT(*) FROM #SPMDatainsertActivity) 
				IF (@Count > 0) 
				BEGIN

					DECLARE @Countmax INT
					SET @Countmax = 0
					SET @Countmax = (SELECT MAX(InsertCount) FROM #SPMDatainsertActivity)
					DECLARE @Countmin INT
					SET @Countmin = 0
					SET @Countmin = (SELECT MIN(InsertCount) FROM #SPMDatainsertActivity)

					DECLARE @maxmpsactivityid INT
					DECLARE @maxservicemapid INT
					SET @maxmpsactivityid = (SELECT MAX(ActivityID) FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK))
					SET @maxservicemapid = (SELECT ServiceMappingID FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK)
											WHERE ActivityID = @maxmpsactivityid)



					WHILE (@Countmin <= @Countmax) 
					BEGIN

					DECLARE @ServiceName NVARCHAR(200);
					DECLARE @ActivityName NVARCHAR(200);
					SET @ServiceName=(SELECT ServiceName FROM #SPMDatainsertActivity WHERE InsertCount = @Countmin)
					SET @ActivityName=(SELECT ActivityName FROM #SPMDatainsertActivity WHERE InsertCount = @Countmin)
					IF EXISTS(SELECT * FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK) WHERE IsDeleted=0
								AND ServiceName=@ServiceName AND ActivityName=@ActivityName)
					BEGIN
						SET @maxmpsactivityid = (SELECT ServiceMappingID FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK) 
											WHERE IsDeleted=0
											AND ServiceName=@ServiceName AND ActivityName=@ActivityName)
					END
					ELSE
						BEGIN
							SET @maxmpsactivityid = (SELECT MAX(ActivityID) + 1 FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK))
							INSERT INTO AVL.TK_MAS_ServiceActivityMapping
								SELECT
									B.ServiceType
									,A.ServiceID
									,A.ServiceName
									,A.ServiceShortName
									,@maxmpsactivityid AS ActivityID
									,A.ActivityName
									,A.EffortType
									,A.MaintenanceType
									,A.IsDeleted
									,A.CreatedDateTime
									,A.CreatedBY
									,A.ModifiedDateTime
									,A.ModifiedBY
									,NULL
									,A.Categorization
									,NULL
									,A.AutomatableTypeID
								FROM #SPMDatainsertActivity AS A
								LEFT JOIN AVL.TK_MAS_Service B
									ON A.ServiceID = B.ServiceID
								WHERE InsertCount = @Countmin
						END

					SET @maxservicemapid = (SELECT ServiceMappingID FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK) 
											WHERE IsDeleted=0
											AND ServiceName=@ServiceName AND ActivityName=@ActivityName)
					DECLARE @ProjectID INT;
					SET @ProjectID=(SELECT ProjectID FROM #SPMDatainsertActivity WHERE InsertCount = @Countmin)

					IF NOT EXISTS(SELECT * FROM AVL.TK_PRJ_ProjectServiceActivityMapping
						WHERE ProjectID=@ProjectID AND ServiceMapID=@maxservicemapid AND IsDeleted=0)
						BEGIN
							INSERT INTO AVL.TK_PRJ_ProjectServiceActivityMapping
							SELECT	@maxservicemapid AS ServiceMapID
								,A.ProjectID
								,A.IsDeleted
								,A.CreatedDateTime
								,A.CreatedBY
								,A.ModifiedDateTime
								,A.ModifiedBY
								,A.IsHidden
								,A.EffectiveDate
								,A.IsMainspringData
								FROM #SPMDatainsertActivity A
								WHERE A.InsertCount = @Countmin
							END
					SET @Countmin = @Countmin + 1
					END
					END
					--Count>0 end

					INSERT INTO MS.TRN_Job_Log
						SELECT
							'Mainspring Daily Job'
							,@NoofActivityHide
							,@NoofstandardActivityAdded
							,@Count
							,GETDATE()
					DROP TABLE #MainspringBaseActivityoriginaltoInsert
					DROP TABLE #MainspringBaseActivityoriginaltoupdate
					DROP TABLE #MainspringServiceMapingUpdate
					DROP TABLE #MainspringServiceMapingInsert
					DROP TABLE #MainspringServiceMapingInsertForNewService
					DROP TABLE #MainspringServiceMapingInsertActivityforExisting
					DROP TABLE #MainspringServiceMapingInsertFinalList
					DROP TABLE #MainspringServiceMapingInsertFinalListSMID
					DROP TABLE #SPMDatainsertActivity
					DROP TABLE #MainspringServiceMapingInsertFinalListtoInsert
			END 
		ELSE 
			BEGIN

			INSERT INTO MS.TRN_Job_Log

			SELECT
				'Mainspring Daily Job'
				,0
				,0
				,0
				,GETDATE()

			END

--EXEC MS.[InsertTicketAttributeToProject]

END

