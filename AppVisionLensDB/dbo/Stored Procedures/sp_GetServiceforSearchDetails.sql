/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[sp_GetServiceforSearchDetails]-- 0,0,35606
    @servid INT = 0 , 
    @actid INT = 0 ,
    @projid INT = 0
AS 
    BEGIN    
BEGIN TRY
BEGIN TRAN

		SET NOCOUNT ON;
		DECLARE @IsMainspringConfig CHAR; 
		Create table #tmpServiceProjectMapping
		(
			ServProjMapID  VARCHAR(50),
			ServiceMapID VARCHAR(50),
			ServiceID  varchar (50),
			ServiceName VARCHAR(max),
			ServiceTypeName VARCHAR(50),
			ActivityID varchar(50),
			ActivityName varchar(max),
			EffortType VARCHAR(50),
			MaintenanceType VARCHAR(50),
			ProjectID VARCHAR(50),
			IsDeleted bit
		)
--		DECLARE @IsMainspringConfig CHAR;
--	SET @IsMainspringConfig=(SELECT IsMainSpringConfigured FROM AVL.MAS_ProjectMaster 
--							 WHERE ProjectID=@projid)
--IF @IsMainspringConfig ='Y'
--	BEGIN
--			SELECT * INTO #tmpServiceProjectMapping1
--		FROM avl.TK_PRJ_ProjectServiceActivityMapping
--		WHERE   IsDeleted = 0 AND ServiceType !='MPS' AND 
--				ProjectID = (CASE @projid
--                                    WHEN 0 THEN ProjectID
--                                    ELSE @projid
--                             END)

--        SELECT DISTINCT
--                ServProjMapID ,
--                ServiceMapID ,
--                ServiceID ,
--                LTRIM(RTRIM(ServiceName))  +  
--                CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping1 servCount  
--						   WHERE servCount.ServiceID=SPM.ServiceID AND servCount.ProjectID=SPM.ProjectID AND servCount.IsDeleted = 0 AND ISNULL(servCount.IsHidden,0)=0)=0  
--					  THEN ' (Hidden)'  
--					 ELSE ''  
--				END AS ServiceName  ,      
--                ActivityID ,
--                LTRIM(RTRIM(ActivityName))  +  
--                CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping1 actCount  
--						   WHERE actCount.ServiceID=SPM.ServiceID AND actCount.ActivityID=SPM.ActivityID AND actCount.ProjectID=SPM.ProjectID AND actCount.IsDeleted = 0 AND ISNULL(actCount.IsHidden,0)=0)=0  
--					  THEN ' (Hidden)'  
--					 ELSE ''  
--				END AS ActivityName ,				
--                EffortType ,
--                MaintenanceType ,
--                ProjectID
--        FROM    #tmpServiceProjectMapping1 SPM
--        WHERE   IsDeleted = 0
--                AND ServiceID = ( CASE @servid
--                                    WHEN 0 THEN ServiceID
--                                    ELSE @servid
--                                  END )              
--                AND ActivityID = ( CASE @actid
--                                     WHEN 0 THEN ActivityID
--                                     ELSE @actid
--                                   END )    
                                   
                                   
	
--	END
--ELSE
--	BEGIN
		set @IsMainspringConfig = (Select ISNULL(IsMainSpringConfigured,'N') from AVL.MAS_ProjectMaster where ProjectID = @projid)
			
		IF(@IsMainspringConfig = 'Y')
		BEGIN
					INSERT into #tmpServiceProjectMapping
					SELECT 
						SPM.ServProjMapID ,
						SPM.ServiceMapID ,
						SAM.ServiceID, 
						SAM.ServiceName,
						ST.ServiceTypeName,
						SAM.ActivityID,
						SAM.ActivityName,
						SAM.EffortType ,
						SAM.MaintenanceType ,
						SPM.ProjectID,
						SPM.IsDeleted
						FROM avl.TK_MAS_ServiceType ST 
						JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID
						JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID
						WHERE   SPM.IsDeleted = 0 AND SAM.IsDeleted = 0 AND ST.Isdeleted = 0 AND SAM.ServiceTypeID not in (4) and 
						SAM.ServiceID<>41 AND
								SPM.ProjectID = (CASE @projid
													WHEN 0 THEN ProjectID
													ELSE @projid
											 END) 


        SELECT DISTINCT
                ServProjMapID ,
                ServiceMapID ,
                ServiceID ,
                LTRIM(RTRIM(ServiceName)) AS ServiceName,   
    --             + CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping servCount  
				--		   WHERE servCount.ServiceID=SPM.ServiceID AND servCount.ProjectID=SPM.ProjectID AND servCount.IsDeleted = 0 AND ISNULL(servCount.IsHidden,0)=0)=0  
				--	  THEN ' (Hidden)'  
				--	 ELSE ''  
				--END AS ServiceName  ,              
                ActivityID ,
                LTRIM(RTRIM(ActivityName)) AS ActivityName, 
				--+     CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping actCount  
				--		   WHERE actCount.ServiceID=SPM.ServiceID AND actCount.ActivityID=SPM.ActivityID AND actCount.ProjectID=SPM.ProjectID AND actCount.IsDeleted = 0 AND ISNULL(actCount.IsHidden,0)=0)=0  
				--	  THEN ' (Hidden)'  
				--	 ELSE ''  
				--END AS ActivityName ,				
                EffortType ,
                MaintenanceType ,
                ProjectID
        FROM    #tmpServiceProjectMapping SPM
        WHERE   IsDeleted = 0
                AND ServiceID = ( CASE @servid
                                    WHEN 0 THEN ServiceID
                                    ELSE @servid
                                  END )               
                AND ActivityID = ( CASE @actid
                                     WHEN 0 THEN ActivityID
                                     ELSE @actid
                                   END )    
                                   
                                   
			END
		ELSE
		  BEGIN
					INSERT into #tmpServiceProjectMapping
					SELECT 
						SPM.ServProjMapID ,
						SPM.ServiceMapID ,
						SAM.ServiceID, 
						SAM.ServiceName,
						ST.ServiceTypeName,
						SAM.ActivityID,
						SAM.ActivityName,
						SAM.EffortType ,
						SAM.MaintenanceType ,
						SPM.ProjectID,
						SPM.IsDeleted
						FROM avl.TK_MAS_ServiceType ST 
						JOIN avl.TK_MAS_ServiceActivityMapping SAM ON SAM.ServiceTypeID = ST.ServiceTypeID
						JOIN avl.TK_PRJ_ProjectServiceActivityMapping SPM ON SPM.ServiceMapID = SAM.ServiceMappingID
						WHERE   SPM.IsDeleted = 0 AND SAM.IsDeleted = 0 AND ST.Isdeleted = 0 AND --SAM.ServiceTypeID not in (4) and 
								SPM.ProjectID = (CASE @projid
													WHEN 0 THEN ProjectID
													ELSE @projid
											 END)--) PS


        SELECT DISTINCT
                ServProjMapID ,
                ServiceMapID ,
                ServiceID ,
                LTRIM(RTRIM(ServiceName)) AS ServiceName,   
    --             + CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping servCount  
				--		   WHERE servCount.ServiceID=SPM.ServiceID AND servCount.ProjectID=SPM.ProjectID AND servCount.IsDeleted = 0 AND ISNULL(servCount.IsHidden,0)=0)=0  
				--	  THEN ' (Hidden)'  
				--	 ELSE ''  
				--END AS ServiceName  ,              
                ActivityID ,
                LTRIM(RTRIM(ActivityName)) AS ActivityName, 
				--+     CASE WHEN (SELECT COUNT(*) FROM #tmpServiceProjectMapping actCount  
				--		   WHERE actCount.ServiceID=SPM.ServiceID AND actCount.ActivityID=SPM.ActivityID AND actCount.ProjectID=SPM.ProjectID AND actCount.IsDeleted = 0 AND ISNULL(actCount.IsHidden,0)=0)=0  
				--	  THEN ' (Hidden)'  
				--	 ELSE ''  
				--END AS ActivityName ,				
                EffortType ,
                MaintenanceType ,
                ProjectID
        FROM    #tmpServiceProjectMapping SPM
        WHERE   IsDeleted = 0
                AND ServiceID = ( CASE @servid
                                    WHEN 0 THEN ServiceID
                                    ELSE @servid
                                  END )               
                AND ActivityID = ( CASE @actid
                                     WHEN 0 THEN ActivityID
                                     ELSE @actid
                                   END )    
                                

		  END
                                               
		
		SET NOCOUNT OFF;
		COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.sp_GetServiceforSearchDetails', @ErrorMessage, 0 ,0
		
	END CATCH  
    END
