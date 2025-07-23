/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
  
  
CREATE PROCEDURE [AVL].[SaveTicketingModuleUserDetails]  
(  
  @ProjectID BIGINT,  
  @CustomerID BIGINT,  
  @CreatedBy NVARCHAR(100),  
  @TicketModuleUserDetails AS [AVL].[TVP_TicketModuleUserDetails] READONLY     
)  
AS  
BEGIN  
   BEGIN TRY  
   BEGIN TRANSACTION  
  DECLARE @IsDeleted   INT = 0  
  DECLARE @IsNonESAAuthorized INT = 0  
  DECLARE @IsCognizant  INT = 0  
     ---Insert User Service Level Mapping Table    
  
  DELETE B  
  FROM @TicketModuleUserDetails T   
  INNER JOIN [AVL].[UserServiceLevelMapping](NOLOCK) B  
   ON B.EmployeeID=T.EmployeeID   
  JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
   ON LM.EmployeeID=B.EmployeeID AND LM.CustomerID=B.CustomerID  
   AND LM.ProjectID=B.ProjectID     
  WHERE  B.CustomerID=@CustomerID and IsDeleted=@IsDeleted   
     
    
  INSERT INTO [AVL].[UserServiceLevelMapping]  
  (  
    EmployeeID,      
    ServiceLevelID,  
    CustomerID,  
    CreatedBy,  
    CreatedDate,  
    ProjectID  
   )     
  SELECT     
     EmployeeID,  
     ServiceLevel as ServiceLevelID,  
     @CustomerID as CustomerID,  
     @CreatedBy as CreatedBy,  
     GETDATE() as CreatedDate,   
     @ProjectID as ProjectID      
  FROM     
  (SELECT EmployeeID,   
    CASE WHEN UserServiceLevel1ID='Yes' THEN 1 ELSE 0 END L1,   
    CASE WHEN UserServiceLevel2ID='Yes' THEN 2 ELSE 0 END L2,   
    CASE WHEN UserServiceLevel3ID='Yes' THEN 3 ELSE 0 END L3,   
    CASE WHEN UserServiceLevel4ID='Yes' THEN 4 ELSE 0 END L4,   
    CASE WHEN UserServiceLevelOthers='Yes' THEN 5 ELSE 0 END L5       
  FROM @TicketModuleUserDetails TD  where  EXISTS ( SELECT EmployeeID FROM AVL.MAS_LoginMaster(NOLOCK) LM  
  WHERE LM.EmployeeID=TD.EmployeeID AND ProjectID=@ProjectID  
  AND CustomerID=@CustomerID and IsDeleted=@IsDeleted) ) p    
  UNPIVOT    
  (ServiceLevel FOR ServiceLevelID IN     
  ( L1, L2, L3, L4, L5 )    
  )AS unpvt  
  WHERE ServiceLevel<>0;  
     
     ---Update Login Master details ProjectWise  
  
  UPDATE  B  
  SET     B.TicketingModuleEnabled = CASE WHEN ISNULL(T.TicketingModuleEnabled,'') <> ''   
             THEN CASE WHEN T.TicketingModuleEnabled='Yes' THEN 1 ELSE 0 END ELSE B.TicketingModuleEnabled END,  
    B.ModifiedDate = GETDATE()  
  FROM @TicketModuleUserDetails T   
  INNER JOIN [AVL].MAS_LoginMaster(NOLOCK) B  
   ON B.EmployeeID=T.EmployeeID  
  WHERE B.IsDeleted=@IsDeleted  
   AND B.ProjectID=@ProjectID  
   AND B.CustomerID=@CustomerID  
   AND B.IsNonESAAuthorized=@IsNonESAAuthorized   
     
  
 CREATE TABLE #RoleDetails  
    (  
    EmployeeID varchar (50),  
    RoleName int  
    )  
INSERT INTO #RoleDetails   
SELECT TM.EmployeeID,RM.RoleID FROM @TicketModuleUserDetails TM  
JOIN [PP].[ALM_RoleMaster](NOLOCK) RM ON RM.RoleName =TM.RoleName AND RM.IsDeleted = 0  
  
 IF EXISTS(SELECT 1 FROM #RoleDetails)  
 BEGIN   
MERGE [PP].[ALM_MAP_UserRoles] UR  
 USING #RoleDetails RD  
 ON RD.EmployeeId = UR.EmployeeId  
 WHEN MATCHED THEN   
UPDATE  SET UR.RoleId = RD.RoleName,  
 UR.IsDeleted = 0,  
 UR.ModifiedBy = @CreatedBy,  
 UR.ModifiedDate = GetDate()  
WHEN NOT MATCHED BY TARGET THEN                
INSERT (EmployeeID,RoleID,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)                
VALUES (RD.EmployeeID,RD.RoleName,0,@CreatedBy,GetDate(),null,null);                
  
 END  
 DROP TABLE #RoleDetails  
    
  
-- MultiSelect POD Details   
  
  
CREATE TABLE #PODDetails  
    (  
    UserID varchar (10),  
    PODDetails int  
    )  
Insert into #PODDetails   
 select LM.UserID,PP.PODDetailID  
 from   
 @TicketModuleUserDetails TM  
LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON TM.EmployeeID = LM.EmployeeID  
left join PP.Project_PODDetails PP on PP.PODName in (SELECT Item FROM dbo.Split((select TM1.PODDetails from  @TicketModuleUserDetails TM1 where TM1.EmployeeID = TM.EmployeeID), ','))  
WHERE LM.ProjectID = @ProjectID AND LM.IsDeleted = @IsDeleted  
  
  
  
 IF EXISTS(SELECT 1 FROM #PODDetails)  
 BEGIN   
  
 -- DROP Application Scope   
 DELETE FROM ADM.AssociateAttributes  WHERE UserId in (SELECT LM.UserId FROM @TicketModuleUserDetails TM LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON TM.EmployeeID = LM.EmployeeID)  
  
 -- Updating AppApplicationScope   
 INSERT INTO ADM.AssociateAttributes  
      (  
        UserId,  
        PODDetailID,  
        CCARole,  
        IsDeleted,  
        CreatedDate,  
        CreatedBy,  
        ModifiedDate,  
        ModifiedBy  
       )   
 SELECT     
       PD.UserId AS UserId,  
       PD.PODDetails,  
       NULL AS CCARole,  
       0 AS IsDeleted,  
       GETDATE() AS CreatedDate,  
       @CreatedBy AS CreatedBy,  
       NULL AS ModifiedDate,  
       NULL AS ModifiedBy  
       FROM #PODDetails PD  
        
 END  
 DROP TABLE #PODDetails  
 --Commented for Multi Select POD Details--START  
    --CREATE TABLE #PODDetails  
    --(  
    --UserID varchar (10),  
    --PODDetails nvarchar (300),  
    --IsExits bit   
    --)  
    --INSERT INTO #PODDetails (UserID,PODDetails,IsExits) SELECT LM.UserID,T.PODDetails,0  FROM @TicketModuleUserDetails T INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
    --   ON T.EmployeeID = LM.EmployeeID WHERE LM.ProjectID = @ProjectID AND LM.IsDeleted = @IsDeleted  
  
    --UPDATE PD SET PD.IsExits = 1,PD.PODDetails = PP.PODDetailID FROM ADM.AssociateAttributes AA INNER JOIN  #PODDetails PD ON AA.Userid = PD.UserID  
    --  INNER JOIN PP.Project_PODDetails PP ON PP.PODName = PD.PODDetails  where PP.IsDeleted = @IsDeleted AND  
    --  AA.IsDeleted = @IsDeleted AND PP.ProjectID = @ProjectID  
  
    --UPDATE AA SET AA.PODDetailID = PD.PODDetails,AA.ModifiedDate = GETDATE(),AA.ModifiedBy = @CreatedBy FROM ADM.AssociateAttributes AA INNER JOIN  #PODDetails PD ON AA.Userid = PD.UserID  
    --  where  AA.IsDeleted = @IsDeleted AND PD.IsExits = 1  
  
    --INSERT INTO  ADM.AssociateAttributes  
    --  (  
    --    UserId,  
    --    PODDetailID,  
    --    CCARole,  
    --    IsDeleted,  
    --    CreatedDate,  
    --    CreatedBy,  
    --    ModifiedDate,  
    --    ModifiedBy  
    --   )     
    --  SELECT     
    --   PD.UserID AS UserId,  
    --   PP.PODDetailID,  
    --   NULL AS CCARole,  
    --   0 AS IsDeleted,  
    --   GETDATE() AS CreatedDate,  
    --   @CreatedBy AS CreatedBy,  
    --   NULL AS ModifiedDate,  
    --   NULL AS ModifiedBy  
    --  FROM   PP.Project_PODDetails PP INNER JOIN #PODDetails  PD ON PP.PODName = PD.PODDetails  
    --  where   PD.IsExits = 0 AND PP.IsDeleted = @IsDeleted AND PP.ProjectID = @ProjectID  
  
--Commented for Multi Select POD Details--END  
   --END   
     
        ------Login Master Update Account Level  
  
  UPDATE  B  
  SET     B.TSApproverID = CASE WHEN T.TSApproverID = ''   
         THEN B.TSApproverID ELSE T.TSApproverID END,      
    B.ClientUserID = CASE WHEN ISNULL(T.ClientUserID,'') <> ''   
         THEN CASE WHEN ISNULL(BAG.AssignmentGroupMapID,'') <> '' THEN B.ClientUserID ELSE T.ClientUserID END ELSE B.ClientUserID END,  
    B.TimezoneID = CASE WHEN ISNULL(T.TimeZoneName,'') <> ''    
         THEN TZ.TimezoneID ELSE B.TimezoneID END,   
    B.MandatoryHours = CASE WHEN T.MandatoryHours = '' THEN B.MandatoryHours ELSE  T.MandatoryHours END      
  FROM @TicketModuleUserDetails T   
  INNER JOIN [AVL].MAS_LoginMaster(NOLOCK) B  
   ON B.EmployeeID=T.EmployeeID and B.CustomerID=@CustomerID  
  LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TZ  
   ON TZ.TimeZoneName=T.TimeZoneName  
        LEFT JOIN AVL.BOTAssignmentGroupMapping(NOLOCK) BAG  
   ON BAG.ProjectID=B.ProjectID   
   AND BAG.AssignmentGroupName=T.ClientUserID  
  WHERE B.IsDeleted=@IsDeleted  
  
  
  
  
  
  
  --UPDATE B  
  --SET    B.RoleID=RM.RoleID from  
  --LEFT JOIN [PP].[ALM_RoleMaster] (NOLOCK) RM ON  T.RoleName = RM.RoleName     
      
  --Left join [PP].[ALM_MAP_UserRoles] B on T.RoleName = RM.RoleName  
  --Left join @TicketModuleUserDetails_Roles T   
  -- WHERE B.IsDeleted=@IsDeleted and T.RoleName = RM.RoleName  
  
  SELECT @@rowcount as 'RowCount'  
  
  --Select top 100 * from [PP].[ALM_MAP_UserRoles] order by createddate desc  
  
 COMMIT TRAN  
  
  END TRY  
  BEGIN CATCH    
  
  ROLLBACK TRAN  
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --- Insert Error Message ---  
  EXEC AVL_InsertError '[AVL].[TVP_TicketModuleUserDetails]', @ErrorMessage, 0, 0  
                 
  END CATCH  
END
