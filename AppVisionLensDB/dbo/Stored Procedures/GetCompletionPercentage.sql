/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROC [dbo].[GetCompletionPercentage]     
(      
 @CustomerId INT=NULL,       
 @ProjectId  INT=NULL      
)       
AS       
  BEGIN       
      BEGIN try       
    DECLARE @Esaprojectid nvarchar(50);    
          DECLARE @Prerequistie INT;       
          DECLARE @CompletionPercn INT=0;       
          DECLARE @ItsmPercn INT;       
    DECLARE @Toolscatalogperc INT;    
          DECLARE @UserCount INT;       
          DECLARE @UserCountTicket INT;       
          DECLARE @UserCountDebt INT;       
          DECLARE @DebtConfig INT;        
          DECLARE @TicketConfig INT;          
          DECLARE @Prereqdebt INT;       
          DECLARE @PrereqTicket INT;       
          DECLARE @TicketDescCount INT;       
          DECLARE @DebtPrereq INT;       
          DECLARE @IsCognizant INT=0;       
          DECLARE @NoOfProjects INT;          
       DECLARE @ClosedScreenId INT;       
    DECLARE @AppInvProgress AS INT=0;    
     DECLARE @InFraInvProgress AS INT=0;    
     DECLARE @SupportType INT=0;    
    
     Select @Esaprojectid = Esaprojectid from avl.mas_projectmaster WITH(NOLOCK)  
  where projectid = @projectid and isdeleted = 0    
    
          SET @NoOfProjects=(SELECT Count(1)       
                             FROM   avl.mas_projectmaster(nolock)       
                             WHERE  customerid = @CustomerId       
                                    AND isdeleted = 0)       
          SET @IsCognizant=(SELECT Count(1)       
                            FROM   avl.customer WITH(NOLOCK)      
                            WHERE  customerid = @CustomerId       
                                   AND iscognizant = 1       
                                   AND isdeleted = 0)         
          SET @Prereqdebt=(SELECT Sum([completionpercentage])       
                           FROM   [AVL].[prj_configurationprogress](nolock)       
                           WHERE  [screenid] = 2       
                                  AND projectid = @ProjectId       
                                  AND customerid = @CustomerId  
								  AND [itsmscreenid]IN( 4, 7, 8, 9)
                                  AND isdeleted = 0)       
      
          IF EXISTS(SELECT completionpercentage       
                    FROM   [AVL].[prj_configurationprogress](nolock)       
                    WHERE  [screenid] = 2       
                           AND [itsmscreenid]IN(6))       
            IF NOT EXISTS(SELECT 1       
                          FROM   [AVL].[tk_map_projectstatusmapping] (nolock)        
                          WHERE  projectid = @ProjectId       
                                 AND ticketstatus_id = 8       
                                 AND isdeleted = 0)       
              BEGIN       
                  SET @Prereqdebt=@Prereqdebt - 100       
              END       
      
          SET @TicketDescCount=(SELECT Count(1)       
                                FROM   [AVL].[itsm_prj_ssiscolumnmapping] WITH(NOLOCK)         
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
      
          SET @DebtPrereq=CONVERT(INT, ( CONVERT(DECIMAL(18, 2), (       
                                         @Prereqdebt + @PrereqTicket )) / 500 )       
                                                       * 100)       
    
    SET @ClosedScreenId = (SELECT Max(itsmscreenid)       
                            FROM   avl.prj_configurationprogress  WITH(NOLOCK)        
                            WHERE  customerid = @CustomerId)     
    
      
 /***PROGRESS Based on Support Type****/      
     
DECLARE @TaskMapping INT ;    
DECLARE @AppScopecount int=0;    
DECLARE @IsApp int =0;    
  SET @AppScopecount = (SELECT COUNT( DISTINCT AttributeValueID) FROM PP.ProjectAttributeValues WITH(NOLOCK)      
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
     FROM PP.ProjectAttributeValues WITH(NOLOCK)   WHERE ProjectID=@ProjectID and AttributeID=1   and IsDeleted=0      
  END       
    
  ELSE IF (@AppScopecount = 2 OR @AppScopecount = 3 )    
  BEGIN      
      
    IF EXISTS (SELECT TOP 1 1 FROM PP.ProjectAttributeValues WITH(NOLOCK)    
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
  SET @TaskMapping= (SELECT Count(ISNULL(InfraTaskID,0)) FROM AVL.InfraTaskMappingTransaction WITH(NOLOCK) where CustomerID = @CustomerId    
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
    IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM  WITH(NOLOCK)        
    WHERE PM.ProjectID=@ProjectID )      
     BEGIN      
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
         FROM   avl.prj_configurationprogress WITH(NOLOCK)      
             WHERE  screenid = 1       
                 AND customerid = @CustomerId);       
        PRINT @CompletionPercn      
     END          
    ELSE      
     BEGIN      
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
         FROM   avl.prj_configurationprogress WITH(NOLOCK)         
             WHERE  screenid = 1       
                 AND customerid = @CustomerId);       
      
      IF @CompletionPercn<100      
      BEGIN      
      SET @CompletionPercn=@CompletionPercn+25;      
      END      
    
     END      
    
     PRINT @CompletionPercn     
    
        
     --insert into @tempitsm exec [dbo].[ITSM_CalculateProgressBarPercentage] @ProjectID,@CustomerId    
    
     --select @ItsmPercn =STATUSProgress from @tempitsm    
     SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)    
    
    
   /**ITSM**/     
   /**Exclude 12 Screen for non impact of older project configeration **/                 
    --SET @ItsmPercn=CASE WHEN @IsCognizant = 1 THEN (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
    --           Sum(       
    --           completionpercentage)) /       
    --           1000       
    --              ) * 100       
    --            )       
    --          FROM   avl.prj_configurationprogress       
    --          WHERE  screenid = 2       
    --            AND customerid = @CustomerId       
    --            AND projectid = @ProjectId and ITSMScreenId <> 12)    
    --      ELSE  (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
    --         Sum(       
    --         completionpercentage)) /       
    --         1000       
    --            ) * 100)       
    --         FROM   avl.prj_configurationprogress       
    --         WHERE  screenid = 2       
    --           AND customerid = @CustomerId       
    --           AND projectid = @ProjectId) END      
      
 END    
 ELSE    
 BEGIN    
  /**SupportType = Infra Inventry (2)**/    
    
  /**Applicaion Inventry**/    
   IF NOT EXISTS(SELECT 1 FROM AVL.InfraTowerProjectMapping IPM  WITH(NOLOCK)        
       WHERE IPM.ProjectID=@ProjectID AND IPM.IsEnabled = 1 AND IPM.IsDeleted=0)      
    BEGIN      
     SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
      FROM   avl.prj_configurationprogress  WITH(NOLOCK)        
            WHERE  screenid = 17       
              AND customerid = @CustomerId AND IsDeleted =0);       
       PRINT @CompletionPercn      
    END      
    ELSE      
    BEGIN      
     SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
      FROM   avl.prj_configurationprogress WITH(NOLOCK)         
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
    
   /**ITSM**/     
   --insert into @tempitsm exec [dbo].[ITSM_CalculateProgressBarPercentage] @ProjectID,@CustomerId    
    
   --  select @ItsmPercn =STATUSProgress from @tempitsm    
   SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)    
   --SET @ItsmPercn=CASE WHEN @IsCognizant = 1 THEN (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
   --            Sum(       
   --            completionpercentage)) /       
   --            1000       
   --               ) * 100       
   --            )       
   --          FROM   avl.prj_configurationprogress       
   --          WHERE  screenid = 2   and ITSMScreenId<>3    
   --            AND customerid = @CustomerId       
   --            AND projectid = @ProjectId)     
   --        ELSE  (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
   --            Sum(       
   --            completionpercentage)) /       
   --            1000       
   --               ) * 100)       
   --            FROM   avl.prj_configurationprogress       
   --            WHERE  screenid = 2       
   --              AND customerid = @CustomerId       
   --              AND projectid = @ProjectId) END       
    
 END     
END     
ELSE    
BEGIN    
       
    ------------Dev/Testing--------------------    
 IF(@SupportType=4)    
 BEGIN    
   /**SupportType = Applicaion Inventry (1)**/    
    
   /**Applicaion Inventry**/    
    IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM WITH(NOLOCK)        
    WHERE PM.ProjectID=@ProjectID )      
     BEGIN      
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
         FROM   avl.prj_configurationprogress WITH(NOLOCK)         
             WHERE  screenid = 1       
                 AND customerid = @CustomerId);       
        PRINT @CompletionPercn      
     END          
    ELSE      
     BEGIN      
       SET @CompletionPercn=(SELECT TOP 1 completionpercentage       
         FROM   avl.prj_configurationprogress WITH(NOLOCK)         
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
    
   set @ADProjects=(select distinct pm.ProjectID    
 FROM AVL.MAS_LoginMaster(NOLOCK) LM    
 JOIN AVL.MAS_ProjectMaster(NOLOCK) PM     
  ON PM.ProjectID=LM.ProjectID AND ISNULL(PM.IsDeleted,0)=0    
 JOIN AVL.Customer(NOLOCK) Cust     
  ON LM.CustomerID=Cust.CustomerID AND ISNULL(Cust.IsDeleted,0) = 0    
 LEFT JOIN PP.ScopeOfWork(NOLOCK) SW     
  ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0    
  LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PAV    
    ON PAV.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0    
  LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK) PTP    
    ON PTP.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0    
 WHERE pm.ProjectID=@ProjectId AND ISNull(LM.IsDeleted,0) = 0     
 AND LM.CustomerID=@CustomerId --AND ISNULL(IsApplensAsALM,0) <> 1     
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
   DECLARE @InfrProjectapping INT = CASE WHEN EXISTS (SELECT TOP 1  1 FROM AVL.InfraTowerProjectMapping IPM  WITH(NOLOCK)               
         WHERE IPM.ProjectID=@ProjectID AND IPM.IsEnabled = 1 AND IPM.IsDeleted=0) THEN 1 ELSE 0 END    
   DECLARE @ApplicationProjectmapping INT = CASE WHEN EXISTS (SELECT TOP 1 1 FROM AVL.APP_MAP_ApplicationProjectMapping PM  WITH(NOLOCK)         
         WHERE PM.ProjectID=@ProjectID ) THEN 1 ELSE 0 END    
     
    IF (@InfrProjectapping =0 and @ApplicationProjectmapping =0 )    
      BEGIN      
    
      IF @IsCognizant=1    
      BEGIN    
  
      SELECT @AppInvProgress=ISNULL(SUM(completionpercentage),0)   
            FROM avl.prj_configurationprogress WITH (NOLOCK)  
            WHERE screenid =1 AND customerid = @CustomerId AND IsDeleted =0    
       SELECT @InFraInvProgress=ISNULL(SUM(completionpercentage),0)   
            FROM AVL.prj_configurationprogress WITH (NOLOCK)  
            WHERE screenid =17 AND customerid = @CustomerId AND IsDeleted =0   
    
       set @InFraInvProgress = CASE WHEN (@TaskMapping <> 0 and @InFraInvProgress >= 50 and @InFraInvProgress < 75) THEN @InFraInvProgress+25 ELSE @InFraInvProgress  END     
       SET @CompletionPercn=(@AppInvProgress+@InFraInvProgress)/2;    
    
      END    
      ELSE    
       BEGIN    
        DECLARE @IsUploadCompleted INT;    
        SET @IsUploadCompleted=(SELECT TOP 1 CompletionPercentage FROM avl.prj_configurationprogress WITH(NOLOCK)         
              WHERE customerid = @CustomerId AND ScreenID=17 AND IsDeleted=0)    
        IF ISNULL(@IsUploadCompleted,0) >=50    
         BEGIN    
         SET @CompletionPercn=(SELECT (SUM(completionpercentage) +25)/2     
             FROM   avl.prj_configurationprogress  WITH(NOLOCK)     
             WHERE  screenid in ( 17, 1 )     
             AND customerid = @CustomerId AND IsDeleted =0)    
         END    
        ELSE    
         BEGIN    
          SET @CompletionPercn=(SELECT (SUM(completionpercentage))/2     
             FROM   avl.prj_configurationprogress WITH(NOLOCK)       
             WHERE  screenid in ( 17, 1 )     
             AND customerid = @CustomerId AND IsDeleted =0)    
         END    
    
       END    
          
      END    
     ELSE      
     BEGIN      
     SET @AppInvProgress=(SELECT isnull(SUM(completionpercentage),0)  FROM   avl.prj_configurationprogress WITH(NOLOCK)   WHERE  screenid =1 AND customerid = @CustomerId AND IsDeleted =0)    
     SET @InFraInvProgress=(SELECT isnull(SUM(completionpercentage),0)  FROM   avl.prj_configurationprogress  WITH(NOLOCK)  WHERE  screenid =17 AND customerid = @CustomerId AND IsDeleted =0)    
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
    
   /**ITSM**/     
  --insert into @tempitsm exec [dbo].[ITSM_CalculateProgressBarPercentage] @ProjectID,@CustomerId    
    
  --   select @ItsmPercn =STATUSProgress from @tempitsm    
  SET @ItsmPercn = dbo.GetItsmPercentage(@ProjectID)    
   --SET @ItsmPercn=CASE WHEN @IsCognizant =1 THEN (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
   --            Sum(       
   --            completionpercentage)) /       
   --            1100       
   --               ) * 100       
   --              )       
   --            FROM   avl.prj_configurationprogress       
   --            WHERE  screenid = 2       
   --              AND customerid = @CustomerId       
   --              AND projectid = @ProjectId)     
   --        ELSE  (SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),       
   --            Sum(       
   --            completionpercentage)) /       
   --            1000       
   --               ) * 100)       
   --            FROM   avl.prj_configurationprogress       
   --            WHERE  screenid = 2       
   --              AND customerid = @CustomerId       
   --              AND projectid = @ProjectId) END    
       
    
END    
    
END    
        -----------**Final Calculation**----------------    
          SET @Prerequistie=( @ItsmPercn + @CompletionPercn ) / 2;       
    
   /* 04thMarch2019 Slowness Issue - Begin*/ 
   
   SELECT A.RoleMappingID as RoleMappingId,RoleKey,Esaprojectid,Associateid into #UserCount FROM RLE.VW_ProjectLevelRoleAccessDetails A WITH(NOLOCK)   Where A.Esaprojectid=@Esaprojectid 

   SET @UserCount= (SELECT COUNT(RoleMappingID) FROM #UserCount (NOLOCK)        
   WHERE RoleKey!='RLE015' AND Esaprojectid=@Esaprojectid)       

   SET @UserCountTicket= (SELECT COUNT(A.RoleMappingID) FROM #UserCount (NOLOCK) A INNER JOIN        
   avl.employeescreenmapping B (NOLOCK) ON A.Associateid=B.EmployeeID        
         AND A.Esaprojectid=@Esaprojectid         
         WHERE B.CustomerID=@CustomerId AND B.AccessWrite=1 AND B.ScreenId=4)    
    
    SET @UserCountDebt= (SELECT COUNT(A.RoleMappingID) FROM #UserCount (NOLOCK) A INNER JOIN        
    avl.employeescreenmapping B (NOLOCK) ON A.Associateid=B.EmployeeID        
          AND A.Esaprojectid=@Esaprojectid         
          WHERE B.CustomerID=@CustomerId AND B.AccessWrite=1 AND B.ScreenId=5)    
    /* 04thMarch2019 Slowness Issue - End*/    
    
    /* Old Code - Begin*/    
         -- SET @UserCount=(SELECT Count(*)       
         --                 FROM   [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] EPM      
         ----avl.employeecustomermapping ECM       
         --                        --JOIN avl.employeeprojectmapping EPM ON EPM.employeecustomermappingid = ECM.id       
         --                        --JOIN avl.employeerolemapping ERM ON ERM.employeecustomermappingid = ECM.id       
         --                             WHERE EPM.roleid != 1 AND EPM.ProjectID = @ProjectId); --AND ECM.customerid = @CustomerId);       
    
          --SET @UserCountTicket=(SELECT Count(esm.screenid)       
          --                      FROM   avl.employeescreenmapping esm      
          --INNER JOIN [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ecprm on esm.EmployeeID=ecprm.EmployeeID and esm.CustomerID=ecprm.CustomerID      
          --                             --INNER JOIN avl.employeecustomermapping ON employeecustomermapping.id = employeecustomermappingid       
          --                      WHERE  esm.customerid = @CustomerId       
          --                             AND ( esm.accesswrite = 1 )       
          --                             AND esm.screenid = 4)       
        --  SET @UserCountDebt=(SELECT Count(esm.screenid)       
        --                      FROM   avl.employeescreenmapping esm      
        -- INNER JOIN [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ecprm on esm.EmployeeID=ecprm.EmployeeID and esm.CustomerID=ecprm.CustomerID      
        --                             --INNER JOIN avl.employeecustomermapping ON employeecustomermapping.id = employeecustomermappingid       
        --WHERE  esm.customerid = @CustomerId       
        --  AND ( esm.accesswrite = 1 )       
        --  AND esm.screenid = 5);     
  /* Old Code - Begin*/    
    
     PRINT @CompletionPercn      
          SET @DebtConfig=(SELECT TOP 1 completionpercentage       
                           FROM   avl.prj_configurationprogress  WITH(NOLOCK)        
                           WHERE  screenid = 5       
                                  AND customerid = @CustomerId       
                                  AND projectid = @ProjectId);       
          SET @TicketConfig=(SELECT TOP 1 completionpercentage       
                             FROM   avl.prj_configurationprogress   WITH(NOLOCK)       
                             WHERE  screenid = 4       
                                    AND customerid = @CustomerId    
                                    AND ( ( @IsCognizant = 0       
                                  AND projectid IS NULL )       
                                           OR ( @IsCognizant = 1       
                                                AND projectid = @ProjectId ) ));       
  SET @Toolscatalogperc=(SELECT TOP 1 completionpercentage       
                           FROM   avl.prj_configurationprogress  WITH(NOLOCK)        
                           WHERE  screenid = 16       
                                  AND customerid = @CustomerId       
                                  AND projectid = @ProjectId)    
  PRINT @CompletionPercn      
          SELECT DISTINCT CASE WHEN Isnull(@Prerequistie, 0)>100 THEN 100 ELSE Isnull(@Prerequistie, 0) END AS Prerequistie,       
                          CASE WHEN Isnull(@ItsmPercn, 0)>100 THEN 100 ELSE  Isnull(@ItsmPercn, 0) END  AS ITSMPerc,       
                          Isnull(@CompletionPercn, 0)AS AppInvenPercn,       
                          Isnull(@DebtConfig, 0)     AS DebtConfig,       
                          Isnull(@TicketConfig, 0)   AS TicketConfig,       
                          Isnull(@DebtPrereq, 0)     AS DebtPrereq,      
        ISNULL(@Toolscatalogperc,0) As Toolscatalogperc,     
                          CASE       
                            WHEN @UserCount > 0 THEN 100       
                            ELSE 0       
                          END                        AS UserCount,       
                          CASE       
                            WHEN @UserCountTicket > 0 THEN 100       
                            ELSE 0       
       END                        AS UserCountTicket,       
                          CASE       
                            WHEN @UserCountDebt > 0 THEN 100       
                            ELSE 0       
                          END                        AS UserCountDebt       
          FROM   avl.prj_configurationprogress a  WITH(NOLOCK)         
         END try       
      
      BEGIN catch       
          DECLARE @ErrorMessage VARCHAR(max);       
      
          SELECT @ErrorMessage = Error_message()       
      
          EXEC Avl_inserterror       
            '[dbo].[GetCompletionPercentage] ',       
            @ErrorMessage,       
            0,       
            @CustomerId       
      END catch       
  END
