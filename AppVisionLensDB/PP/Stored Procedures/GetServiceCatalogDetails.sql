/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
-- =========================================================================================      
-- Author      : Shobana      
-- Modified    : Arul      
-- Create date : Jun 16, 2020      
-- Description : Get Service Catalog Details]      
-- Revision    :      
-- Revised By  :      
-- [PP].[GetServiceCatalogDetails] 10337,'Get'      
-- ===========================================================================================      
CREATE  PROCEDURE [PP].[GetServiceCatalogDetails]      
@ProjectID BIGINT,      
@Mode NVARCHAR(20)      
AS       
  BEGIN       
 BEGIN TRY       
  SET NOCOUNT ON;      
  DECLARE @EsaProjectID NVARCHAR(100);      
  DECLARE @ProjectName  NVARCHAR(100);      
     DECLARE @LineOfService NVARCHAR(250) = NULL;      
  DECLARE @ProjectType nchar(10);      
  DECLARE @IsMainspring CHAR(1);      
  DECLARE @IsCognizant bit;      
  DECLARE @CustomerId bigint;      
  SET @CustomerId = (SELECT CustomerId FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE  ProjectId = @ProjectID AND IsDeleted = 0)      
  SET @IsCognizant = (SELECT IsCognizant FROM AVL.Customer where CustomerId = @CustomerId AND IsDeleted = 0)      
  SET @EsaProjectID=(SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID      
       AND IsDeleted=0)      
  SET @ProjectName=(SELECT ProjectName FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID      
       AND IsDeleted=0)      
        SET @IsMainspring=(SELECT ISNULL(IsMainSpringConfigured,'N') FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID)      
  CREATE TABLE #ProjectScopes (ScopeID INT NULL)      
  INSERT INTO #ProjectScopes      
  SELECT DISTINCT AttributeValueID FROM PP.ProjectAttributeValues WHERE ProjectID=@ProjectID      
  AND AttributeID=1 AND IsDeleted=0      
  SET @ProjectType=(SELECT A.ProjectType FROM ESA.Projects A JOIN AVL.MAS_ProjectMaster B ON      
   A.ID=B.EsaProjectID WHERE B.ProjectID=@ProjectID)      
     IF(@IsCognizant = 1)      
  BEGIN      
  SET @LineOfService=(SELECT TOP 1 Projectowningunit FROM ms.ProjectRegistrationDetails  WHERE EsaProjectID=@EsaProjectID and Type='Predominant' and TypeOfproject in ('Project', 'Group Project'))      
  IF(ISNULL(@LineOfService,'')='')                 
   BEGIN                  
   SET @LineOfService='ADM'                  
   END           
   END      
   ELSE      
   BEGIN      
   SET @LineOfService='ADM'      
   END      
  CREATE TABLE #ProjectScopesByService (ScopeID INT NULL)      
        
  IF EXISTS (SELECT TOP 1 1 FROM #ProjectScopes WHERE ScopeID in(1,4))      
  BEGIN      
   INSERT INTO #ProjectScopesByService VALUES(1)      
   INSERT INTO #ProjectScopesByService VALUES(3)      
  END      
      
  IF EXISTS (SELECT TOP 1 1 FROM #ProjectScopes WHERE ScopeID=2 AND @IsCognizant = 1)      
  BEGIN      
   INSERT INTO #ProjectScopesByService VALUES(2)      
   INSERT INTO #ProjectScopesByService VALUES(3)      
  END      
  IF NOT EXISTS (SELECT TOP 1 1 FROM #ProjectScopes)      
  BEGIN      
   INSERT INTO #ProjectScopesByService VALUES(3)      
  END      
      
  IF @Mode='Download'      
   BEGIN   
    SELECT DISTINCT  @EsaProjectID AS EsaProjectID,@ProjectName AS [Project Name],      
    ST.ServiceTypeName AS [Service Group],      
    CategoryName AS Category,MS.ServiceName AS [Service Name],SAM.ActivityName      
    FROM MAS.ServiceGroupCategoryMapping(NOLOCK) SGC      
    INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) ST ON SGC.ServiceGroupID=ST.ServiceTypeID AND ST.Isdeleted=0      
    INNER JOIN MAS.ServiceCategory(NOLOCK) SC ON SGC.ServiceCategoryID=SC.CategoryID AND SC.IsDeleted=0      
    INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON SGC.ServiceID=MS.ServiceID AND MS.IsDeleted=0 AND SGC.IsDeleted=0      
    INNER JOIN AVL.TK_MAS_ServiceActivityMapping(NOLOCK) SAM ON MS.ServiceID=SAM.ServiceID AND SAM.IsDeleted=0      
    INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM ON SAM.ServiceMappingID=PAM.ServiceMapID AND PAM.IsDeleted=0      
    AND PAM.ProjectID=@ProjectID      
    WHERE MS.ServiceID<>41      
    ORDER BY [Service Group],Category,[Service Name]      
   END      
      
  ELSE       
      
   BEGIN      
    CREATE TABLE #ServicesList      
    (      
    ServiceGroupID INT NULL,      
    ServiceGroup NVARCHAR(50) NULL,      
    ServiceCategoryID SMALLINT NULL,      
    Category  VARCHAR(50) NULL,      
          
    ServiceID INT NULL,      
    ServiceName NVARCHAR(100) NULL,      
    ScopeID INT NULL,      
    IsRetired BIT NULL,      
    RetirementDate DATETIME NULL,      
    IsMainspringData NVARCHAR(10) NULL,      
    [Status] NVARCHAR(100) NULL,      
    IsSelected INT NULL,      
    IsTicketTypeMapped INT NULL,      
    ActivityID Int Null,      
    ActivityName NVARCHAR(200) NULL,      
    IsActivitySelected INT NULL,      
    FTEPercenatge decimal(10, 2) null      
    )   
    INSERT INTO #ServicesList      
    SELECT DISTINCT        
    ServiceGroupID,      
    ST.ServiceTypeName AS ServiceGroup,      
    ServiceCategoryID , CategoryName AS Category,MS.ServiceID,MS.ServiceName,      
    MS.ScopeID,ISNULL(MS.IsRetired,0) AS IsRetired,RetirementDate,NULL AS IsMainspringData,      
    NULL AS Status,0 AS IsSelected,0 AS IsTicketTypeMapped,      
    MSAM.ActivityID,MSAM.ActivityName,NULL      
    ,FTE.FTEPercenatge       
    FROM MAS.ServiceGroupCategoryMapping(NOLOCK) SGC      
    INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) ST ON SGC.ServiceGroupID=ST.ServiceTypeID AND ST.Isdeleted=0      
    INNER JOIN MAS.ServiceCategory(NOLOCK) SC ON SGC.ServiceCategoryID=SC.CategoryID AND SC.IsDeleted=0      
    LEFT JOIN AVL.ProjectServiceTypeFTE(NOLOCK) FTE ON FTE.ProjectID=@ProjectID AND FTE.ServiceTypeID=SGC.ServiceCategoryID and FTE.IsDeleted=0      
    INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON SGC.ServiceID=MS.ServiceID AND MS.IsDeleted=0 AND SGC.IsDeleted=0      
    AND MS.ScopeID IN(SELECT DISTINCT ScopeID FROM #ProjectScopesByService)      
    INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) MSAM ON  MS.ServiceID=MSAM.ServiceID AND MSAM.IsDeleted=0 AND ISNULL(MSAM.IsMasterData,0)=1      
    WHERE MS.ServiceID<>41      
    ORDER BY ServiceGroup,Category,MS.ServiceName ASC      
      
 --Commented out since the activities from mainspring is not returned    
    
    IF(@IsMainspring ='Y')      
    BEGIN     
    INSERT INTO #ServicesList      
    SELECT DISTINCT        
    ServiceGroupID,      
    ST.ServiceTypeName AS ServiceGroup,      
    ServiceCategoryID , CategoryName AS Category,MS.ServiceID,MS.ServiceName,      
    MS.ScopeID,ISNULL(MS.IsRetired,0) AS IsRetired,RetirementDate,NULL AS IsMainspringData,      
    NULL AS Status,0 AS IsSelected,0 AS IsTicketTypeMapped,      
    MSAM.ActivityID,MSAM.ActivityName,NULL      
    ,FTE.FTEPercenatge       
    FROM MAS.ServiceGroupCategoryMapping(NOLOCK) SGC      
    INNER JOIN AVL.TK_MAS_ServiceType(NOLOCK) ST ON SGC.ServiceGroupID=ST.ServiceTypeID AND ST.Isdeleted=0      
    INNER JOIN MAS.ServiceCategory(NOLOCK) SC ON SGC.ServiceCategoryID=SC.CategoryID AND SC.IsDeleted=0      
    LEFT JOIN AVL.ProjectServiceTypeFTE(NOLOCK) FTE ON FTE.ProjectID=@ProjectID AND FTE.ServiceTypeID=SGC.ServiceCategoryID and FTE.IsDeleted=0      
    INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON SGC.ServiceID=MS.ServiceID AND MS.IsDeleted=0 AND SGC.IsDeleted=0      
  AND MS.ScopeID IN(SELECT DISTINCT ScopeID FROM #ProjectScopesByService)      
    INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) MSAM ON  MS.ServiceID=MSAM.ServiceID AND MSAM.IsDeleted=0      
    INNER JOIN AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM ON MSAM.ServiceMappingID=PSAM.ServiceMapID AND PSAM.IsDeleted=0      
    WHERE MS.ServiceID<>41 AND PSAM.ProjectID=@ProjectID AND ISNULL(MSAM.IsMasterData,0)!=1      
    ORDER BY ServiceGroup,Category,MS.ServiceName ASC      
    END      
      
    UPDATE #ServicesList SET IsRetired=0 WHERE RetirementDate > GETDATE() OR RetirementDate IS NULL      
      
    UPDATE SL      
    SET SL.IsSelected=1 FROM      
    AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    INNER JOIN avl.TK_MAS_ServiceActivityMapping MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    INNER JOIN #ServicesList SL ON MAS.ServiceID=SL.ServiceID      
    AND ISNULL(MAS.IsDeleted,0)=0      
    AND ISNULL(PAM.IsDeleted,0)=0       
    WHERE ProjectID=@ProjectID      
      
    DELETE FROM #ServicesList WHERE IsRetired=1 AND IsSelected !=1      
          
    UPDATE SL      
    SET SL.IsTicketTypeMapped=1 FROM #ServicesList SL      
    INNER JOIN AVL.TK_MAP_TicketTypeServiceMapping(NOLOCK) TTS ON SL.ServiceID=TTS.ServiceID      
    WHERE TTS.ProjectID=@ProjectID AND ISNULL(TTS.IsDeleted,0)=0       
      
    UPDATE SL      
    SET SL.IsMainspringData='Y' FROM      
    AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    INNER JOIN avl.TK_MAS_ServiceActivityMapping(NOLOCK) MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    INNER JOIN #ServicesList SL ON MAS.ServiceID=SL.ServiceID      
    AND ISNULL(MAS.IsDeleted,0)=0      
    AND ISNULL(PAM.IsDeleted,0)=0 AND PAM.IsMainspringData='Y'      
    WHERE ProjectID=@ProjectID AND MAS.ServiceTypeID=4 AND SL.IsSelected=1      
      
      
    SELECT DISTINCT MAS.SERVICEID,COUNT(1) AS TotalCount INTO #MainspringServicesTotal      
    FROM      
    AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    INNER JOIN avl.TK_MAS_ServiceActivityMapping(NOLOCK) MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    INNER JOIN #ServicesList SL ON MAS.ServiceID=SL.ServiceID      
    AND ISNULL(MAS.IsDeleted,0)=0      
    AND ISNULL(PAM.IsDeleted,0)=0 AND PAM.IsMainspringData='Y'       
    WHERE  PAM.ProjectID=@ProjectID      
    GROUP BY MAS.SERVICEID      
      
    SELECT DISTINCT MAS.SERVICEID,COUNT(1) AS InActiveCount INTO #MainspringServicesInvalid      
    FROM      
    AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    INNER JOIN avl.TK_MAS_ServiceActivityMapping(NOLOCK) MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    INNER JOIN #ServicesList SL ON MAS.ServiceID=SL.ServiceID      
    INNER JOIN #MainspringServicesTotal MPS ON SL.ServiceID=MPS.ServiceID      
    AND ISNULL(MAS.IsDeleted,0)=0      
    AND ISNULL(PAM.IsDeleted,0)=0 AND PAM.IsMainspringData='Y' AND PAM.EffectiveDate <=GETDATE()       
    WHERE  PAM.ProjectID=@ProjectID AND MAS.ServiceID=MPS.ServiceID      
    GROUP BY MAS.SERVICEID      
      
    UPDATE  SL set [Status]='InActive'  FROM #MainspringServicesTotal TT      
    INNER JOIN #MainspringServicesInvalid  TI ON TT.ServiceID=TI.ServiceID      
    AND TT.TotalCount=TI.InActiveCount      
    INNER JOIN #ServicesList SL ON TT.ServiceID=SL.ServiceID      
          
    UPDATE SL      
    SET SL.IsActivitySelected=1 FROM      
    AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    INNER JOIN avl.TK_MAS_ServiceActivityMapping MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    INNER JOIN #ServicesList SL ON MAS.ActivityID=SL.ActivityID AND MAS.ServiceID=SL.ServiceID      
    AND ISNULL(MAS.IsDeleted,0)=0      
    AND ISNULL(PAM.IsDeleted,0)=0       
    WHERE ProjectID=@ProjectID      
               
    UPDATE SL      
                SET SL.IsTicketTypeMapped=1 FROM      
                #ServicesList SL      
                JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD ON WD.Project_Id=@ProjectID      
                AND SL.ServiceID=WD.ServiceId AND WD.IsDeleted=0 AND SL.ScopeID NOT IN(2)      
          
    UPDATE #ServicesList      
    SET IsTicketTypeMapped = 0  WHERE ISNULL(IsActivitySelected,0) = 0           
          
    --UPDATE SL      
    --SET SL.Status='InActive' FROM      
    --AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PAM       
    --INNER JOIN avl.TK_MAS_ServiceActivityMapping MAS ON PAM.ServiceMapID=MAS.ServiceMappingID       
    --INNER JOIN #ServicesList SL ON MAS.ServiceID=SL.ServiceID      
    --AND ISNULL(MAS.IsDeleted,0)=0      
    --AND ISNULL(PAM.IsDeleted,0)=0 AND PAM.IsMainspringData='Y'      
    --WHERE ProjectID=@ProjectID AND SL.IsSelected=1 AND PAM.EffectiveDate IS NOT NULL AND PAM.EffectiveDate <= GETDATE()       
          
    IF(LTRIM(RTRIM(@LineOfService))='ADM' AND LTRIM(RTRIM(Isnull(@ProjectType,'Null')))<>'SALES')      
    BEGIN      
    SELECT  DISTINCT  @EsaProjectID AS EsaProjectID,@ProjectName AS ProjectName,      
     ServiceGroupID,ServiceGroup,      
    ServiceCategoryID,Category,ServiceID,ServiceName,      
     ScopeID,ISNULL(IsRetired,0) AS IsRetired,ISNULL(IsMainspringData,'N') AS IsMainspringData,       
     ISNULL([Status],'Active') AS [Status],ISNULL(IsSelected,0) AS IsSelected,       
     ISNULL(IsTicketTypeMapped,0) AS IsTicketTypeMapped,      
     ActivityID,ActivityName,ISNULL(IsActivitySelected,0) AS IsActivitySelected      
     ,FTEPercenatge AS FTE      
     FROM #ServicesList        
     WHERE ServiceGroupID<>15      
     ORDER BY IsSelected DESC      
    END      
    ELSE IF(LTRIM(RTRIM(@LineOfService))='ADM' AND LTRIM(RTRIM(Isnull(@ProjectType,'Null')))='SALES')      
    BEGIN      
    SELECT  DISTINCT  @EsaProjectID AS EsaProjectID,@ProjectName AS ProjectName,      
     ServiceGroupID,ServiceGroup,      
    ServiceCategoryID,Category,ServiceID,ServiceName,      
     ScopeID,ISNULL(IsRetired,0) AS IsRetired,ISNULL(IsMainspringData,'N') AS IsMainspringData,       
     ISNULL([Status],'Active') AS [Status],ISNULL(IsSelected,0) AS IsSelected,       
     ISNULL(IsTicketTypeMapped,0) AS IsTicketTypeMapped,      
     ActivityID,ActivityName,ISNULL(IsActivitySelected,0) AS IsActivitySelected      
     ,FTEPercenatge AS FTE      
     FROM #ServicesList      
     WHERE ServiceGroupID=15      
     ORDER BY IsSelected DESC      
    END      
    ELSE IF(LTRIM(RTRIM(@LineOfService))<>'ADM' AND @LineOfService <>'')      
    BEGIN      
           SELECT  DISTINCT  @EsaProjectID AS EsaProjectID,@ProjectName AS ProjectName,      
     ServiceGroupID,ServiceGroup,      
     ServiceCategoryID,Category,ServiceID,ServiceName,      
     ScopeID,ISNULL(IsRetired,0) AS IsRetired,ISNULL(IsMainspringData,'N') AS IsMainspringData,       
     ISNULL([Status],'Active') AS [Status],ISNULL(IsSelected,0) AS IsSelected,       
     ISNULL(IsTicketTypeMapped,0) AS IsTicketTypeMapped,      
     ActivityID,ActivityName,ISNULL(IsActivitySelected,0) AS IsActivitySelected      
     ,FTEPercenatge AS FTE      
     FROM #ServicesList      
     WHERE ServiceGroupID IN(1,5,4)      
     ORDER BY IsSelected DESC      
     END      
     DROP TABLE #ServicesList      
      
   END      
  END TRY      
    BEGIN CATCH       
        DECLARE @ErrorMessage VARCHAR(MAX);       
        SELECT @ErrorMessage = ERROR_MESSAGE()       
        --INSERT Error           
        EXEC AVL_INSERTERROR  '[PP].[GetServiceCatalogDetails]', @ErrorMessage,  0, 0       
    END CATCH       
  END
