/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[SP_GetScreenAccess](      
@CustomerID int,      
@EmployeeID varchar(50)      
)      
AS      
BEGIN    
SET NOCOUNT ON;
BEGIN TRY        
        
DECLARE @DebtConfig INT=0        
DECLARE @TicketConfig INT=0        
DECLARE @ITSMPerc INT=0        
DECLARE @AppInvenPercn INT=0        
DECLARE @ScreenId INT = 2    
DECLARE @AppInventoryScreenId INT = 1  
DECLARE @IsEnable INT = 1 
DECLARE @ESACustomerID INT

SELECT Associateid,ESACustomerID,      
ApplensRoleID,RoleName  INTO #tempAssociateRoleData      
FROM RLE.VW_ProjectLevelRoleAccessDetails(NOLOCK) ecpm       
Where ecpm.Associateid = @EmployeeID  

SET @ESACustomerID= (SELECT Esa_AccountID FROM avl.Customer (NOLOCK) WHERE customerid=@CustomerID and IsDeleted=0)

SET @DebtConfig=(SELECT TOP 1 completionpercentage         
                           FROM   avl.prj_configurationprogress  (nolock)       
                           WHERE  screenid = 5         
                                  AND customerid = @CustomerId         
                                  and completionpercentage>=100)        
        
SET @TicketConfig=(SELECT TOP 1 completionpercentage         
                             FROM   avl.prj_configurationprogress (nolock)        
                             WHERE  screenid = 4         
                                    AND customerid = @CustomerId and completionpercentage>=100);         
DECLARE @IsCognizant INT=0;         
SET @IsCognizant=(SELECT Count(1)         
                            FROM   avl.customer (nolock)        
                            WHERE  customerid = @CustomerId         
                                   AND iscognizant = 1         
                                   AND isdeleted = 0)         
IF( @IsCognizant > 0 )         
        
            BEGIN         
                SET @ITSMPerc=(SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),         
                                                      Sum(         
                                                      completionpercentage)) /         
                                                      1100         
                                                                   ) * 100         
                                       )         
                                FROM   avl.prj_configurationprogress (nolock)       
                                WHERE  screenid = 2         
                                       AND customerid = @CustomerId         
                                      );         
            END         
    ELSE         
            BEGIN         
                SET @ITSMPerc=(SELECT CONVERT(INT, ( CONVERT(DECIMAL(18, 2),         
                                                      Sum(         
                                                      completionpercentage)) /         
                                                      900         
                                                                   ) * 100)         
                                FROM   avl.prj_configurationprogress (nolock)        
                                WHERE  screenid = 2         
                                       AND customerid = @CustomerId         
                                     );         
            END         
        
        
    SET @AppInvenPercn=(SELECT TOP 1 completionpercentage         
                                FROM   avl.prj_configurationprogress (nolock)       
                                WHERE  screenid = 1         
                                       AND customerid = @CustomerId                  
            );         
        
        
SELECT  ERM.RoleId,RM.RoleName,'        ' RoleType  INTO #RoleMaster FROM AVL.EmployeeRoleMapping ERM (nolock)       
JOIN AVL.EmployeeCustomerMapping ECM (nolock)ON ERM.EmployeeCustomerMappingId=ECM.Id AND ECM.EmployeeId=@EmployeeID        
JOIN #tempAssociateRoleData RM (nolock) ON RM.ApplensRoleID=ERM.RoleId        
AND ECM.CustomerId=@CustomerID        
        
UPDATE #RoleMaster SET RoleType='Admin'  WHERE RoleName LIKE '%Admin%'        
UPDATE #RoleMaster SET RoleType='User'  WHERE RoleName NOT LIKE '%Admin%'        
        
IF NOT EXISTS(SELECT TOP 1 1 FROM AVL.MAP_CustomerScreenMapping (nolock) WHERE CustomerID=@CustomerID AND ScreenID = @ScreenId)        
BEGIN        
 INSERT INTO AVL.MAP_CustomerScreenMapping([CustomerID],[ScreenID],[IsEnabled],CreatedDate,CreatedBy)        
 VALUES(@CustomerID,@ScreenId,@IsEnable,GETDATE(),@EmployeeID)        
END       
ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM AVL.MAP_CustomerScreenMapping (NOLOCK) WHERE CustomerID=@CustomerID AND ScreenID = @AppInventoryScreenId)  
BEGIN  
 INSERT INTO AVL.MAP_CustomerScreenMapping([CustomerID],[ScreenID],[IsEnabled],CreatedDate,CreatedBy)  
 VALUES(@CustomerID,@AppInventoryScreenId,@IsEnable,GETDATE(),@EmployeeID)  
END  
   
IF NOT EXISTS(SELECT TOP 1 1 FROM AVL.MAP_CustomerScreenMapping (nolock) WHERE CustomerID=@CustomerID AND ScreenID = 5)        
BEGIN        
 INSERT INTO AVL.MAP_CustomerScreenMapping([CustomerID],[ScreenID],[IsEnabled],CreatedDate,CreatedBy)        
 VALUES(@CustomerID,5,@IsEnable,GETDATE(),@EmployeeID)        
END 

IF NOT EXISTS(SELECT TOP 1 1 FROM  [avl].[employeescreenmapping] WHERE EmployeeID=@EmployeeID and CustomerID=@CustomerID)        
BEGIN  
IF EXISTS(SELECT TOP 1 1 FROM #tempAssociateRoleData (NOLOCK) where applensroleID=5 and esacustomerid=@ESACustomerID)
BEGIN
SELECT  [ScreenID],'7' as RoleID,0 as AccessRead,1 as AccessWrite
  INTO #Screenaccess7
  FROM [AVL].[ScreenMaster] (NOLOCK)
  where IsActive=1 AND ScreenID <> 17

merge avl.employeescreenmapping as target      
   using #Screenaccess7 as source      
   on (target.employeeid = @employeeid      
   and target.customerid=@customerid      
   and target.roleid =source.roleid      
   and target.screenid = source.screenid      
   and target.accessread=source.AccessRead      
   and target.accesswrite=source.AccessWrite      
   )      
   when not matched by target then      
   insert (employeeid,customerid,screenid,roleid,accessread,accesswrite)      
   values (@employeeid,@customerid,source.screenid, source.roleid,source.AccessRead,source.AccessWrite);

END
IF EXISTS(SELECT TOP 1 1 FROM #tempAssociateRoleData (NOLOCK) where applensroleID=4 and esacustomerid=@ESACustomerID)
BEGIN
 SELECT  [ScreenID],'3' as RoleID,0 as AccessRead,1 as AccessWrite
  INTO #Screenaccess3
  FROM [AVL].[ScreenMaster] (NOLOCK)
  where IsActive=1 AND ScreenID <> 17

merge avl.employeescreenmapping as target      
   using #Screenaccess3 as source      
   on (target.employeeid = @employeeid      
   and target.customerid=@customerid      
   and target.roleid =source.roleid      
   and target.screenid = source.screenid      
   and target.accessread=source.AccessRead      
   and target.accesswrite=source.AccessWrite      
   )      
   when not matched by target then      
   insert (employeeid,customerid,screenid,roleid,accessread,accesswrite)      
   values (@employeeid,@customerid,source.screenid, source.roleid,source.AccessRead,source.AccessWrite);

END

       
END 

SELECT * INTO #masterdata FROM(          
          
SELECT DISTINCT sm.screenid,sm.screenname,          
CASE WHEN um.[accessread]=0 AND um.accesswrite=1  THEN 'W'          
  WHEN um.[accessread]=1 AND um.accesswrite=1 THEN 'W'          
  ELSE 'R' END access           
FROM avl.screenmaster sm (nolock)          
 INNER JOIN [avl].[employeescreenmapping] (NOLOCK) um ON sm.screenid=um.screenid          
 INNER JOIN AVL.CUSTOMER C (NOLOCK) ON C.CUstomerID=um.CustomerID  and C.isdeleted=0    
 INNER JOIN #tempAssociateRoleData ecpm (nolock) ON um.employeeid=ecpm.Associateid AND C.ESA_AccountId=ecpm.ESAcustomerid         
WHERE C.customerid=@customerid AND ecpm.AssociateId=@employeeid AND (um.[accessread]=1 or um.accesswrite=1)          
 AND sm.screenid IN(SELECT cp.screenid FROM avl.map_customerscreenmapping cp         
        WHERE cp.customerid=@customerid AND cp.isenabled=1         
        UNION ALL SELECT         
4)         
        
UNION ALL        
SELECT 0,'Debt config 100%',''  WHERE @DebtConfig>=100        
UNION ALL        
SELECT -1,'Ticket config 100%',''  WHERE @TicketConfig>=100        
--and UM.RoleID not in (6,1)        
UNION ALL        
SELECT -2,'Itsm/App Inventory 100%','' WHERE @ITSMPerc>=100 AND @AppInvenPercn>=75        
        
)M        
        
IF EXISTS(SELECT 1 FROM #RoleMaster (nolock) WHERE Roletype ='Admin')        
BEGIN        
IF NOT EXISTS(SELECT 1 FROM #RoleMaster (nolock) WHERE Roletype ='User')        
 BEGIN        
  DELETE FROM #masterData WHERE ScreenID IN (9)        
 END        
 ELSE        
 BEGIN        
 INSERT INTO #masterData (ScreenID,ScreenName,Access)        
  SELECT -3,'Debt Dashboard','W' WHERE @DebtConfig>=100        
 END        
End        
        
SELECT ScreenID,ScreenName, CASE WHEN (Access = '' OR Access IS NULL) THEN 'W' else Access end   
AS Access FROM #masterData        
        
        
END TRY          
BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  --INSERT Error            
  EXEC AVL_InsertError '[dbo].[SP_GetScreenAccess] ', @ErrorMessage, 0 ,@CustomerID        
          
 END CATCH          
        SET NOCOUNT OFF;
        DROP TABLE #tempAssociateRoleData  
        DROP TABLE #RoleMaster  
        DROP TABLE #masterdata  
END


