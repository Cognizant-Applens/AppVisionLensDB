/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
  
CREATE PROCEDURE [RLE].[DefaultOperationalRoleForESAUsers]
--(
--	@AssociateId NVARCHAR(50)
--)
 AS
  BEGIN      
	  SET XACT_ABORT ON;
	DECLARE @Date DateTime = GetDate();
	DECLARE @JobName VARCHAR(100)= 'Default Operational Role For SA+ ESA Users';
	DECLARE @JobStatusSuccess VARCHAR(100)='Success';
	DECLARE @JobStatusFail VARCHAR(100)='Failed';
	DECLARE @JobStatusInProgress VARCHAR(100)='InProgress';
	DECLARE @JobId int;
	DECLARE @JobStatusId int;
    
    DECLARE @CreatedBy VARCHAR(50) = 'SYSTEM'
    DECLARE @DataSource VARCHAR(50) = 'ESA'
    DECLARE @RoleName VARCHAR(50) = 'Operational'
    DECLARE @GroupName VARCHAR(50) = 'Delivery'
	DECLARE @Comments VARCHAR(100) = 'Default operational access provided for SA+'
    DECLARE @ApplensRoleID INT
    DECLARE @GroupId INT

	
	SELECT @JobId = JobID FROM MAS.JobMaster WHERE JobName = @JobName; 

	INSERT INTO MAS.JobStatus (JobId, StartDateTime, EndDateTime, JobStatus, JobRunDate, IsDeleted, CreatedBy, CreatedDate) 
			   VALUES(@JobId, @Date, @Date, @JobStatusInProgress, @Date, 0, @CreatedBy, @Date);

	SET @JobStatusId= SCOPE_IDENTITY();
    
    CREATE TABLE #tempProject(
      AssociateID [nvarchar](50) NOT NULL,
      ApplensRoleID [int] NOT NULL,
	  ProjectId [bigint] NULL,
	  GroupId [bigint] NULL,
	  IsDeleted [bit] NOT NULL,
	  CreatedBy [nvarchar](50) NULL,
	  CreatedDate [smalldatetime] NULL,
	  DataSource [varchar](100) NULL
	  )

	  CREATE TABLE #tempRoleMap(
	   RoleMappingID [bigint] NOT NULL,
	   AssociateID [nvarchar](50) NOT NULL
	   );

	   CREATE TABLE #tempRoleData(
	   RoleMappingID [bigint] NOT NULL,
	   AssociateID [nvarchar](50) NOT NULL,
	   ProjectId [bigint] NULL,
	   IsDeleted [bit] NOT NULL,
	   CreatedBy [nvarchar](50) NULL,
	   CreatedDate [smalldatetime] NULL,
	   DataSource [varchar](100) NULL
	   );
    
    SELECT @ApplensRoleID = ApplensRoleID
   FROM [MAS].[RLE_ROLES] WHERE RoleName = @RoleName

   SELECT @GroupId = GroupId
   FROM [MAS].[RLE_Groups] WHERE GroupName = @GroupName
    
	BEGIN TRY    
	BEGIN TRANSACTION
	
    INSERT INTO #tempProject
    SELECT DISTINCT assoc.AssociateID as AssociateID, @ApplensRoleID as ApplensRoleID,
	 pm.ProjectID as ProjectId, @GroupId as GroupId,
     CASE WHEN assoc.IsActive=1 THEN 0
	 ELSE 1 END as IsDeleted,
	 @CreatedBy as CreatedBy, GETDATE() as CreatedDate,
     @DataSource as DataSource
   FROM [AVL].[GradeRoleMapping] grm
   JOIN  [ESA].[ASSOCIATES] assoc
   ON grm.Grade = assoc.Grade
   JOIN [ESA].[PROJECTASSOCIATES] pa
   ON assoc.AssociateID = pa.AssociateID
   JOIN [AVL].[MAS_ProjectMaster] pm
   ON CONVERT(VARCHAR(50),pa.ProjectID) = pm.EsaProjectID
   WHERE 
   grm.IsActive = 1 and assoc.IsActive=1 and pm.IsDeleted=0 --and assoc.associateid=@AssociateId

   --All Projects which are either DataSource is PP or UI and inactive or the project entry is not there at present
   Select * into #NewProjects from (
		SELECT Distinct AssociateID,ProjectId FROM #tempProject
		EXCEPT
		SELECT Distinct src.AssociateID,src.ProjectId FROM #tempProject src
	join [RLE].[UserRoleMapping] tgt1 on tgt1.ApplensRoleID = src.ApplensRoleID AND tgt1.GroupId = src.GroupId
    AND tgt1.AssociateID = src.AssociateID
	join [RLE].[UserRoleDataAccess] tgt2
	on tgt1.RoleMappingID=tgt2.RoleMappingID
	where tgt2.ProjectID=src.ProjectId AND ((tgt1.DataSource='ESA' AND tgt2.DataSource='ESA') OR (tgt1.IsDeleted=0 AND tgt2.IsDeleted=0))
   )T

   --All Associates with data in #NewProjects which dont have rolemapping entry as ESA datasource
   Select * into #RoleMappingInsert from (
		SELECT Distinct AssociateID FROM #NewProjects
		EXCEPT
		SELECT Distinct src.AssociateID FROM #tempProject src
	join [RLE].[UserRoleMapping] tgt1 on tgt1.ApplensRoleID = src.ApplensRoleID AND tgt1.GroupId = src.GroupId
    AND tgt1.AssociateID = src.AssociateID
	join [RLE].[UserRoleDataAccess] tgt2
	on tgt1.RoleMappingID=tgt2.RoleMappingID
	where tgt2.ProjectID=src.ProjectId AND (tgt1.DataSource='ESA' AND tgt2.DataSource='ESA')
   )T


 --All rolemapping ids and project ids which have entry in rolemapping table as ESA datasource but no entry for the project
   INSERT INTO #tempRoleData(RoleMappingID, AssociateID, ProjectID,
            IsDeleted,CreatedBy,CreatedDate,DataSource)
   SELECT tgt1.RoleMappingID,src.AssociateID, src.ProjectId, src.IsDeleted,src.CreatedBy,src.CreatedDate,src.DataSource 
    from #tempProject src
	join #NewProjects src2 on src2.AssociateID = src.AssociateID AND src.ProjectId=src2.ProjectId
	join [RLE].[UserRoleMapping] tgt1 on tgt1.ApplensRoleID = src.ApplensRoleID AND tgt1.GroupId = src.GroupId AND tgt1.AssociateID = src.AssociateID
		And tgt1.DataSource=@DataSource
	join [RLE].[UserRoleDataAccess] tgt2 on tgt1.RoleMappingID=tgt2.RoleMappingID
    

 --New data insert in RoleMapping table
   INSERT INTO [RLE].[UserRoleMapping](AssociateID, GroupId, ApplensRoleID,
            DataSource,Comments,IsDeleted,CreatedBy,CreatedDate)
	OUTPUT INSERTED.RoleMappingId, INSERTED.AssociateId INTO #tempRoleMap
   SELECT DISTINCT AssociateID, @GroupId, @ApplensRoleID, @DataSource,@Comments,0,@CreatedBy,GETDATE()
    FROM #RoleMappingInsert
 
 --RoleMapping Ids for newly inserted data in Rolemapping table
   INSERT INTO #tempRoleData(RoleMappingID, AssociateID, ProjectID,
            IsDeleted,CreatedBy,CreatedDate,DataSource)
   SELECT RoleMappingID,tp.AssociateID, tp.ProjectId, IsDeleted,CreatedBy,CreatedDate,DataSource from #tempProject tp
		join #tempRoleMap trm on tp.AssociateID=trm.AssociateID
		join  #NewProjects rmi on tp.AssociateID=rmi.AssociateID and tp.ProjectId=rmi.ProjectId

--New data insert in RoleDataAccess table
   INSERT INTO [RLE].[UserRoleDataAccess] (RoleMappingID, AssociateID, ProjectID,
            DataSource,IsDeleted,CreatedBy,CreatedDate)
   SELECT DISTINCT RoleMappingID,AssociateID, ProjectId, DataSource,IsDeleted,CreatedBy,CreatedDate
    FROM #tempRoleData src
   

   /****** Update associates who are existing in UserRoleMapping table ******/  
 UPDATE urda SET
 IsDeleted = 0,
 ValidTillDate=NULL,
 ModifiedBy = 'SYSTEM',
 ModifiedDate = GETDATE()
 FROM [RLE].[UserRoleMapping] urm
 join [RLE].[UserRoleDataAccess] urda on urm.RoleMappingID=urda.RoleMappingID
 WHERE EXISTS (
 SELECT TOP 1 1 FROM #tempProject tp
 WHERE tp.ApplensRoleID = urm.ApplensRoleID
 AND   tp.AssociateID = urm.AssociateID
 AND  tp.GroupId = urm.GroupId
 AND  tp.ProjectId = urda.ProjectID
 ) AND urda.DataSource='ESA' AND  urda.IsDeleted = 1

 UPDATE urm SET
 IsDeleted = 0,
 ValidTillDate=NULL,
 ModifiedBy = 'SYSTEM',
 ModifiedDate = GETDATE()
 FROM [RLE].[UserRoleMapping] urm
 WHERE EXISTS (      
   Select TOP 1 1 from [RLE].[UserRoleDataAccess] urda where urda.rolemappingid=urm.rolemappingid and IsDeleted=0
 )
 AND urm.DataSource ='ESA' AND  urm.IsDeleted = 1 AND  urm.ApplensRoleID = @ApplensRoleID  AND  urm.GroupId = @GroupId
 AND urm.AssociateID in (Select DISTINCT AssociateId from #tempProject)
 /****** End ******/  

    
  /****** Handling inactive associates ******/    
  UPDATE urda SET    
   IsDeleted = 1,    
   ModifiedBy = 'SYSTEM',    
   ModifiedDate = GETDATE()
   FROM [RLE].[UserRoleMapping] urm
   join [RLE].[UserRoleDataAccess] urda on urm.RoleMappingID=urda.RoleMappingID
   WHERE NOT EXISTS (      
   SELECT TOP 1 1 FROM #tempProject tp
   WHERE tp.ApplensRoleID = urm.ApplensRoleID
	AND   tp.AssociateID = urm.AssociateID
	AND  tp.GroupId = urm.GroupId
	AND  tp.ProjectId = urda.ProjectID
   ) AND urda.DataSource ='ESA' AND  urda.IsDeleted = 0 AND  urm.ApplensRoleID = @ApplensRoleID AND urm.GroupId = @GroupId
   AND urm.AssociateID in (Select DISTINCT AssociateId from #tempProject)

  UPDATE urm SET    
   IsDeleted = 1,    
   ModifiedBy = 'SYSTEM',    
   ModifiedDate = GETDATE()
   FROM [RLE].[UserRoleMapping] urm
   WHERE NOT EXISTS (      
   Select TOP 1 1 from [RLE].[UserRoleDataAccess] urda where urda.rolemappingid=urm.rolemappingid and urda.IsDeleted=0
   ) AND urm.DataSource ='ESA' AND  urm.IsDeleted = 0 AND  urm.ApplensRoleID = @ApplensRoleID  AND  urm.GroupId = @GroupId
   AND urm.AssociateID in (Select DISTINCT AssociateId from #tempProject)
  /****** End ******/    
    
  DROP TABLE #tempProject
  DROP TABLE #tempRoleMap
  DROP TABLE #tempRoleData
  DROP TABLE #RoleMappingInsert
  DROP TABLE #NewProjects
    
   COMMIT TRANSACTION    
    
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusSuccess, EndDateTime = GETDATE() WHERE ID = @JobStatusId    
     
 END TRY    
 BEGIN CATCH    
  Print 'Error'    
  IF (XACT_STATE()) = -1      
  BEGIN      
   ROLLBACK TRANSACTION;      
  END;      
  IF (XACT_STATE()) = 1      
  BEGIN      
   COMMIT TRANSACTION;         
  END;    
  UPDATE MAS.JobStatus Set JobStatus = @JobStatusFail, EndDateTime = GETDATE() WHERE ID = @JobStatusId    

  DECLARE @HostName NVARCHAR(50);    
  DECLARE @Associate NVARCHAR(50);    
  DECLARE @ErrorCode NVARCHAR(50);    
  DECLARE @ErrorMessage NVARCHAR(MAX);    
  DECLARE @ModuleName VARCHAR(30)='RoleAPI';    
  DECLARE @DbName VARCHAR(30)='AppVisionLens';    
  DECLARE @getdate  DATETIME=GETDATE();    
  DECLARE @DbObjName VARCHAR(50)=(OBJECT_NAME(@@PROCID));    
  SET @HostName=(SELECT HOST_NAME());    
  SET @Associate=(SELECT SUSER_NAME());    
  SET @ErrorCode=(SELECT ERROR_NUMBER());    
  SET @ErrorMessage=(SELECT ERROR_MESSAGE());    
    
    
  EXEC AppVisionLensLogging.[dbo].[InsertLog] 'Critical','ERROR',@HostName,@Associate,@getdate,NULL,'SQL',    
             @ModuleName,@JobName,@DbName,@DbObjName,@@SPID,@ErrorCode,@ErrorMessage,    
             @JobStatusFail,NULL,NULL    
 END CATCH    
END
