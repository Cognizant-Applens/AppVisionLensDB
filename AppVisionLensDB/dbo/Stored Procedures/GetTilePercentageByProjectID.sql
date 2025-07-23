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
-- Author      : 835658           
-- Create date : May 10, 2021            
-- Description : Get the Top Filters By EmployeeID                
-- Revision    :            
-- Revised By  :            
-- =========================================================================================            
--[dbo].[GetTilePercentageByProjectID]   '659978'     
      
  
CREATE PROC [dbo].[GetTilePercentageByProjectID]           
@EsaProjectID  NVARCHAR(100)          
AS          
BEGIN       
SET NOCOUNT ON;
BEGIN TRY              
              
declare @ProjectID BIGINT        
declare @CustomerID BIGINT        
DECLARE @ProjectName NVARCHAR(50)        
        
Select @ProjectID = ProjectID, @CustomerID = CustomerID, @ProjectName = ProjectName from avl.mas_projectmaster (NOLOCK)        
where Esaprojectid = @Esaprojectid and isdeleted = 0         
        
--Get the Project Details & Service Catalog Tile Progress        
DECLARE @IsInfra BIT;        
   DECLARE @CountInfra SMALLINT;        
   DECLARE @OPLCount SMALLINT;        
   DECLARE @ValuesCount SMALLINT;        
   DECLARE @OPLCISCount SMALLINT;        
   DECLARE @TotalCount SMALLINT;        
   DECLARE @TotalCISCount SMALLINT;        
      SET @OPLCount = (SELECT COUNT(ProjectScope) FROM PP.OplEsaData(NOLOCK) where  ProjectId = @ProjectID AND IsDeleted = 0)        
      SET @OPLCISCount = (SELECT count(ProjectScope) FROM PP.OplEsaData(NOLOCK) where  ProjectId = @ProjectID       
   AND ProjectScope = 3 AND IsDeleted = 0)               
   SET @ValuesCount = (SELECT COUNT(ID) FROM PP.ProjectAttributeValues(NOLOCK) where ProjectId = @ProjectID         
   AND AttributeID = 1 and IsDeleted=0)        
   SET @CountInfra = (SELECT COUNT(ID) FROM PP.ProjectAttributeValues (NOLOCK) where ProjectId = @ProjectID         
   AND AttributeID = 1 and AttributeValueID = 3 AND IsDeleted=0)        
   SET @TotalCISCount = (@OPLCISCount + @CountInfra)        
   SET @TotalCount = (@OPLCount + @ValuesCount)        
   IF (@TotalCISCount = 1 AND @TotalCount =1)        
   BEGIN        
   SET @IsInfra = 1        
   END        
   ELSE        
   BEGIN        
   SET @IsInfra = 0        
   END        
               
--Get the Onboarding Setup Tile Progress        
DECLARE @ShowALMConfig    BIT   = 0            
  DECLARE @ShowITSMConfig    BIT   = 0            
        DECLARE @IsApplens           BIT   = 0        
  DECLARE @ALMConfigTileID   SMALLINT = 8         
  DECLARE @ITSMConfigTileID   SMALLINT = 9        
  DECLARE @WorkProfilerConfigTileID SMALLINT = 11        
  DECLARE @ALMPerc     INT   = 0           
  DECLARE @ITSMPerc     INT   = 0           
  DECLARE @WorkProfilerPerc   INT   = 0         
         
        SELECT @IsApplens = ISNULL(IsApplensAsALM, 0) FROM pp.ScopeOfWork (NOLOCK) WHERE ProjectID = @ProjectID            
          
  /* AttributeID =1 = ProjectScope*/            
  SELECT PAV.AttributeValueID AS 'AttributeValueID', ppav.AttributeValueName AS 'AttributeValueName'            
  INTO #ScopeDetails            
  FROM PP.ProjectAttributeValues PAV  (NOLOCK)          
  JOIN MAS.PPAttributeValues ppav (NOLOCK) ON pav.AttributeID = ppav.AttributeID             
   AND PAV.AttributeValueID = ppav.AttributeValueID AND ppav.AttributeID = 1 AND ppav.IsDeleted = 0           
  WHERE PAV.ProjectID = @ProjectID AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0           
          
  IF EXISTS ( SELECT TOP 1 1 FROM #ScopeDetails )            
  BEGIN            
            
   -- Check for either Development / Testing / Both Development & Testing        
   IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails WHERE AttributeValueID IN (1,4))            
   BEGIN            
          
    SET @ShowALMConfig = 1            
            
   END            
   -- Check for either Maintainence / CIS / Both Maintainence & CIS        
   IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails WHERE AttributeValueID IN (2,3))            
   BEGIN            
          
    SET @ShowITSMConfig = 1            
          
   END            
            
   END            
          
   DROP TABLE #ScopeDetails          
          
   -- Get ITSM Tile Progress Percentage when selected scope is Maintainence, CIS           
   IF (@ShowITSMConfig = 1)         
   BEGIN             
          
   SELECT TOP 1 @ITSMPerc = ISNULL(TileProgressPercentage, 0)        
   FROM PP.ProjectProfilingTileProgress (NOLOCK)       
   WHERE ProjectID = @ProjectID AND TileID = @ITSMConfigTileID AND IsDeleted = 0        
            
   END         
   -- Get ALM Tile Progress Percentage when selected scope is Development, Testing         
   IF (@IsApplens = 1 OR @ShowALMConfig = 1)         
   BEGIN             
          
   SELECT TOP 1 @ALMPerc = ISNULL(TileProgressPercentage, 0)        
   FROM PP.ProjectProfilingTileProgress  (NOLOCK)      
   WHERE ProjectID = @ProjectID AND TileID = @ALMConfigTileID AND IsDeleted = 0        
            
   END            
        
   -- Get Work Profiler Configuration Tile Progress Percentage        
   SELECT TOP 1 @WorkProfilerPerc = ISNULL(TileProgressPercentage, 0)        
   FROM PP.ProjectProfilingTileProgress  (NOLOCK)      
   WHERE ProjectID = @ProjectID AND TileID = @WorkProfilerConfigTileID AND IsDeleted = 0        
        
          DECLARE @CompletionPercn INT=0;             
          DECLARE @ItsmPercn INT;             
          DECLARE @UserCount INT;             
          DECLARE @Prereqdebt INT;             
          DECLARE @PrereqTicket INT;             
          DECLARE @TicketDescCount INT;             
          DECLARE @IsCognizant INT=0;             
          DECLARE @NoOfProjects INT;                
       DECLARE @ClosedScreenId INT;             
    DECLARE @AppInvProgress AS INT=0;          
     DECLARE @InFraInvProgress AS INT=0;          
     DECLARE @SupportType INT=0;                
          
          SET @NoOfProjects=(SELECT Count(*)             
                             FROM   avl.mas_projectmaster(nolock)             
                             WHERE  customerid = @CustomerId             
                                    AND isdeleted = 0)             
          SET @IsCognizant=(SELECT Count(1)             
                            FROM   avl.customer             
                            WHERE  customerid = @CustomerId             
                                   AND iscognizant = 1             
                                   AND isdeleted = 0)               
          SET @Prereqdebt=(SELECT Sum([completionpercentage])             
                           FROM   [AVL].[prj_configurationprogress](nolock)             
                           WHERE  [screenid] = 2             
                                  AND [itsmscreenid]IN( 4, 7, 8, 9)             
                                  AND projectid = @ProjectId             
                                  AND customerid = @CustomerId             
                                  AND isdeleted = 0)             
            
          IF EXISTS(SELECT completionpercentage             
                    FROM   [AVL].[prj_configurationprogress](nolock)             
                    WHERE  [screenid] = 2             
                           AND [itsmscreenid]IN( 6 ))             
            IF NOT EXISTS(SELECT 1             
                          FROM   [AVL].[tk_map_projectstatusmapping]  (NOLOCK)           
                          WHERE  projectid = @ProjectId             
                                 AND ticketstatus_id = 8             
                                 AND isdeleted = 0)             
              BEGIN             
                  SET @Prereqdebt=@Prereqdebt - 100             
              END             
            
          SET @TicketDescCount=(SELECT Count(*)             
                                FROM   [AVL].[itsm_prj_ssiscolumnmapping]             
                                WHERE  projectid = @ProjectId             
                                       AND isdeleted = 0             
                                       AND ( ( servicedartcolumn =             
                                               'TicketDescription'             
                                             )             
                                              OR ( servicedartcolumn =             
                                                   'Ticket Description' ) ))             
            
          IF( @TicketDescCount > 0 )             
            SET @PrereqTicket=100             
          ELSE             
            SET @PrereqTicket=0         
          
    SET @ClosedScreenId = (SELECT Max(itsmscreenid)             
                            FROM   avl.prj_configurationprogress             
                            WHERE  customerid = @CustomerId)           
          
            
 /***PROGRESS Based on Support Type****/            
           
DECLARE @TaskMapping INT ;          
DECLARE @AppScopecount int=0;          
DECLARE @IsApp int =0;          
  SET @AppScopecount = (SELECT COUNT( DISTINCT AttributeValueID) FROM PP.ProjectAttributeValues (NOLOCK)          
  WHERE ProjectID=@ProjectID AND AttributeID=1 and IsDeleted=0 )          
          
 IF(@AppScopecount = 4)          
  BEGIN          
          
  SET @IsApp=3;--IF BOTH MAINTANANCE & CIS HAD BEEN SELECTED          
  END          
  ELSE IF (@AppScopecount = 1)          
  BEGIN          
          
     SELECT @IsApp = CASE           
                    WHEN  AttributeValueID = 2 THEN 1          
        WHEN  AttributeValueID = 3 THEN 2          
     WHEN AttributeValueID = 1  THEN 1          
     WHEN AttributeValueID = 4  THEN 1           
     END          
     FROM PP.ProjectAttributeValues (NOLOCK) WHERE ProjectID=@ProjectID and AttributeID=1   and IsDeleted=0            
  END             
          
  ELSE IF (@AppScopecount = 2 OR @AppScopecount = 3 )          
  BEGIN            
            
    IF EXISTS (SELECT TOP 1 1 FROM PP.ProjectAttributeValues (NOLOCK)         
                WHERE ProjectID=@ProjectID and AttributeID=1            
                and IsDeleted=0    and AttributeValueID  in (3))          
                BEGIN          
                    SET @IsApp=3          
                END          
                ELSE          
                BEGIN          
                    SET @IsApp=1          
                END          
                
  END          
          
  ELSE          
  BEGIN          
  SET @IsApp = 0           
  END          
          
Set @SupportType=@IsApp;          
IF @IsCognizant=1          
 BEGIN          
  SET @TaskMapping= (SELECT Count(ISNULL(InfraTaskID,0)) FROM AVL.InfraTaskMappingTransaction (NOLOCK) where CustomerID = @CustomerId          
      AND IsDeleted=0);          
 END          
ELSE          
 BEGIN          
  SET @TaskMapping= 1          
 --SET @SupportType = (SELECT ISNULL(SupportTypeId,0) FROM AVL.MAP_ProjectConfig WHERE ProjectID = @ProjectID)          
          
 END          
           
IF(@SupportType<3)          
BEGIN          
 IF(@SupportType <= 1)          
 BEGIN          
   /**SupportType = Applicaion Inventry (1)**/          
          
   /**Applicaion Inventry**/          
    IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM  (NOLOCK)           
    WHERE PM.ProjectID=@ProjectID )            
     BEGIN            
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
         FROM   avl.prj_configurationprogress (NOLOCK)            
             WHERE  screenid = 1             
                 AND customerid = @CustomerId);             
        PRINT @CompletionPercn            
     END                
    ELSE            
     BEGIN            
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
         FROM   avl.prj_configurationprogress (NOLOCK)            
             WHERE  screenid = 1             
                 AND customerid = @CustomerId);             
            
      IF @CompletionPercn<100            
      BEGIN            
      SET @CompletionPercn=@CompletionPercn+25;            
      END            
          
     END            
          
     PRINT @CompletionPercn             
              
     SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)            
          
 END          
 ELSE          
 BEGIN          
  /**SupportType = Infra Inventry (2)**/          
          
  /**Applicaion Inventry**/          
   IF NOT EXISTS(SELECT 1 FROM AVL.InfraTowerProjectMapping IPM              
       WHERE IPM.ProjectID=@ProjectID AND IPM.IsEnabled = 1 AND IPM.IsDeleted=0)            
    BEGIN            
     SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
      FROM   avl.prj_configurationprogress (NOLOCK)            
            WHERE  screenid = 17             
              AND customerid = @CustomerId AND IsDeleted =0);        
       PRINT @CompletionPercn            
    END            
    ELSE            
    BEGIN            
     SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
      FROM   avl.prj_configurationprogress  (NOLOCK)           
            WHERE  screenid = 17             
              AND customerid = @CustomerId AND IsDeleted =0);     
            
     IF @CompletionPercn<100            
     BEGIN            
     SET @CompletionPercn=@CompletionPercn+25;            
     END            
    END          
    IF(@IsCognizant=1)          
    BEGIN          
    SET @CompletionPercn = CASE WHEN (@TaskMapping <> 0 and @CompletionPercn >= 50 and @CompletionPercn <= 75) THEN @CompletionPercn+25 ELSE @CompletionPercn  END          
    END          
    SET @CompletionPercn =  CASE WHEN (@CompletionPercn > 100) THEN 100 ELSE @CompletionPercn END               
    PRINT @CompletionPercn           
           
   SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)          
             
 END           
END           
ELSE          
BEGIN          
             
    ------------Dev/Testing--------------------          
 IF(@SupportType=4)          
 BEGIN          
          
   /**Applicaion Inventry**/          
    IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM             
    WHERE PM.ProjectID=@ProjectID )            
     BEGIN            
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
         FROM   avl.prj_configurationprogress (NOLOCK)            
             WHERE  screenid = 1             
                 AND customerid = @CustomerId);             
        PRINT @CompletionPercn            
     END                
    ELSE            
     BEGIN            
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage             
         FROM   avl.prj_configurationprogress (NOLOCK)            
             WHERE  screenid = 1             
                 AND customerid = @CustomerId);             
            
      IF @CompletionPercn<100            
      BEGIN            
      SET @CompletionPercn=@CompletionPercn+25;            
      END            
          
     END            
          
     PRINT @CompletionPercn           
          
   /**ITSM**/           
   /**Exclude 12 Screen for non impact of older project configeration **/                       
    declare @ADProjects int;      
     
 Select PRA.ESAProjectid,ESACustomerId,PM.Projectid into #tempAccessRole from RLE.VW_ProjectLevelRoleAccessDetails PRA (NOLOCK)   
  JOIN AVL.MAS_ProjectMaster(NOLOCK) PM           
    ON PM.ESAProjectID=PRA.ESAProjectID AND ISNULL(PM.IsDeleted,0)=0 where PM.Projectid=@projectid    
          
   set @ADProjects=(select distinct LM.ProjectID          
 FROM #tempAccessRole(NOLOCK) LM              
 JOIN AVL.Customer(NOLOCK) Cust           
  ON LM.ESACustomerID=Cust.ESA_AccountID AND ISNULL(Cust.IsDeleted,0) = 0          
 LEFT JOIN PP.ScopeOfWork(NOLOCK) SW           
  ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0          
  LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PAV          
    ON PAV.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0          
  LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK) PTP          
    ON PTP.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0          
 WHERE LM.ProjectID=@ProjectId           
 AND Cust.CustomerID=@CustomerId --AND ISNULL(IsApplensAsALM,0) <> 1           
 AND PAV.AttributeValueID IN(1,4)           
 AND PTP.TileID = 5 AND PTP.TileProgressPercentage = 100)          
          
 if(@ProjectId=@ADProjects)          
          
 begin          
          
 SET @ItsmPercn=100;          
          
 end            
 end          
   ELSE          
     BEGIN          
    -------------------------------------END-------------          
 /**SupportType = Application/Infra Inventry (3)**/          
          
          
 /**Applicaion Inventry**/          
   DECLARE @InfrProjectapping INT = CASE WHEN EXISTS (SELECT TOP 1  1 FROM AVL.InfraTowerProjectMapping IPM                    
         WHERE IPM.ProjectID=@ProjectID AND IPM.IsEnabled = 1 AND IPM.IsDeleted=0) THEN 1 ELSE 0 END          
   DECLARE @ApplicationProjectmapping INT = CASE WHEN EXISTS (SELECT TOP 1 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM             
         WHERE PM.ProjectID=@ProjectID ) THEN 1 ELSE 0 END          
           
    IF (@InfrProjectapping =0 and @ApplicationProjectmapping =0 )          
      BEGIN            
          
      IF @IsCognizant=1          
      BEGIN          
        
      SELECT @AppInvProgress=ISNULL(SUM(completionpercentage),0)         
            FROM avl.prj_configurationprogress (NOLOCK)        
            WHERE screenid =1 AND customerid = @CustomerId AND IsDeleted =0          
       SELECT @InFraInvProgress=ISNULL(SUM(completionpercentage),0)         
            FROM AVL.prj_configurationprogress (NOLOCK)        
            WHERE screenid =17 AND customerid = @CustomerId AND IsDeleted =0         
          
       set @InFraInvProgress = CASE WHEN (@TaskMapping <> 0 and @InFraInvProgress >= 50 and @InFraInvProgress < 75) THEN @InFraInvProgress+25 ELSE @InFraInvProgress  END           
       SET @CompletionPercn=(@AppInvProgress+@InFraInvProgress)/2;          
          
      END          
      ELSE          
       BEGIN          
        DECLARE @IsUploadCompleted INT;          
        SET @IsUploadCompleted=(SELECT TOP 1 CompletionPercentage FROM avl.prj_configurationprogress             
              WHERE customerid = @CustomerId AND ScreenID=17 AND IsDeleted=0)          
        IF ISNULL(@IsUploadCompleted,0) >=50          
         BEGIN          
         SET @CompletionPercn=(SELECT (SUM(completionpercentage) +25)/2           
             FROM   avl.prj_configurationprogress  (NOLOCK)           
             WHERE  screenid in ( 17, 1 )           
             AND customerid = @CustomerId AND IsDeleted =0)          
         END          
        ELSE          
         BEGIN          
          SET @CompletionPercn=(SELECT (SUM(completionpercentage))/2           
             FROM   avl.prj_configurationprogress (NOLOCK)          
             WHERE  screenid in ( 17, 1 )           
             AND customerid = @CustomerId AND IsDeleted =0)          
         END          
          
       END          
                
      END          
     ELSE            
     BEGIN            
     SET @AppInvProgress=(SELECT isnull(SUM(completionpercentage),0)  FROM   avl.prj_configurationprogress (NOLOCK) WHERE  screenid =1 AND customerid = @CustomerId AND IsDeleted =0)          
     SET @InFraInvProgress=(SELECT isnull(SUM(completionpercentage),0)  FROM   avl.prj_configurationprogress (NOLOCK) WHERE  screenid =17 AND customerid = @CustomerId AND IsDeleted =0)          
     SET @AppInvProgress =  CASE WHEN (@AppInvProgress > 75) THEN 75 ELSE @AppInvProgress END           
     set @InFraInvProgress = CASE WHEN (@TaskMapping <> 0 and @InFraInvProgress >= 50 and @InFraInvProgress < 75) THEN @InFraInvProgress+25 ELSE @InFraInvProgress  END          
     SET @CompletionPercn=(@AppInvProgress+@InFraInvProgress)/2          
      IF @CompletionPercn<100            
       BEGIN            
         SET @CompletionPercn=          
        (SELECT CASE WHEN (@InfrProjectapping =1 and @ApplicationProjectmapping =0) OR (@InfrProjectapping =0 and @ApplicationProjectmapping =1)           
          THEN @CompletionPercn+13           
          ELSE @CompletionPercn+25 END AS CompletionPercn)          
       END            
     END            
    SET @CompletionPercn =  CASE WHEN (@CompletionPercn > 100) THEN 100 ELSE @CompletionPercn END              
          
    SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)          
             
END          
          
END          
        -----------**Final Calculation**----------------          
          
   /* 04thMarch2019 Slowness Issue - Begin*/          
   --SET @UserCount= (SELECT COUNT(RoleMappingID) FROM RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)              
   --WHERE RoleKey!='RLE015' AND Esaprojectid=@Esaprojectid)      
           
        
   SET @UserCount= (SELECT COUNT(RoleMappingID) FROM RLE.VW_ProjectLevelRoleAccessDetails(NOLOCK)        
   WHERE RoleKey!='RLE015' AND  Esaprojectid=@Esaprojectid)       
          
          SELECT DISTINCT  @Esaprojectid AS Esaprojectid, @ProjectName AS ProjectName,        
    (SELECT DISTINCT ISNULL(TP.TileProgressPercentage,0)         
  FROM [MAS].[ProjectProfilingTiles](NOLOCK) PT        
  LEFT JOIN [PP].[ProjectProfilingTileProgress](NOLOCK)  TP ON PT.TileID=TP.TileID and TP.ProjectID=@ProjectID and TP.IsDeleted=0        
  LEFT JOIN [pp].[Extended_ProjectDetails] (Nolock) EP on EP.ProjectID = @ProjectID        
  WHERE PT.TileID = 1) AS  ProjectDetailCompPerc,       
        
  (SELECT DISTINCT ISNULL(TP.TileProgressPercentage,0)         
  FROM [MAS].[ProjectProfilingTiles](NOLOCK) PT        
  LEFT JOIN [PP].[ProjectProfilingTileProgress](NOLOCK)  TP ON PT.TileID=TP.TileID and TP.ProjectID=@ProjectID and TP.IsDeleted=0        
  LEFT JOIN [pp].[Extended_ProjectDetails] (Nolock) EP on EP.ProjectID = @ProjectID        
  WHERE PT.TileID = 4) AS  ServiceCatalogCompPerc,        
        
  (SELECT CASE WHEN (@ShowITSMConfig = 1 AND @ShowALMConfig = 1) THEN (@ALMPerc + @ITSMPerc + @WorkProfilerPerc) / 3        
          WHEN (@ShowITSMConfig = 0 AND @ShowALMConfig = 1) THEN (@ALMPerc + @WorkProfilerPerc) / 2        
          WHEN (@ShowITSMConfig = 1 AND @ShowALMConfig = 0) THEN (@ITSMPerc + @WorkProfilerPerc) / 2        
          ELSE (@ALMPerc + @WorkProfilerPerc) / 2 END          
      ) AS AdaptorCompPerc,        
        
                          CASE WHEN @IsApp = 0 THEN 0 ELSE Isnull(@CompletionPercn, 0) END AS AppInventoryCompPerc,             
                          CASE             
                            WHEN @UserCount > 0 THEN 100       
                            ELSE 0             
                          END                        AS UserMgmtCompPerc        
          FROM   avl.prj_configurationprogress a  (NOLOCK)           
          
              
END TRY               
BEGIN CATCH                
              
  DECLARE @ErrorMessage VARCHAR(MAX);              
              
  SELECT @ErrorMessage = ERROR_MESSAGE()              
  ROLLBACK TRAN              
  --INSERT Error                  
  EXEC AVL_InsertError '[dbo].[GetTilePercentageByProjectID] ', @ErrorMessage, 0,@EsaProjectID              
                
 END CATCH         
 SET NOCOUNT OFF;
END
