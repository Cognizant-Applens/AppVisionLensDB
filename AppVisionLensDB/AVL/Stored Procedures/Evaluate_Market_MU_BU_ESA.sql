
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] � [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
CREATE   PROCEDURE [AVL].[Evaluate_Market_MU_BU_ESA]      
AS      
BEGIN      
      
 BEGIN TRY      
  BEGIN TRAN       
      
      -- Market, Market Unit, BU and Account Mappings      
   TRUNCATE TABLE ESA.AccountHierarchyDetails      
      
   INSERT INTO ESA.AccountHierarchyDetails      
   SELECT A.[Peoplesoft_Customer_Id__C],      
    A.[Name],      
    m.MarketId ,      
    m.MarketName,      
    CA.[Global_Market_Id__c],      
    CA.[Global_Market__C],      
    rbu.BusinessId,      
    rbu.BusinessName,      
    CA.[VerticalID__c],      
    CA.[Vertical__c]      
   FROM [$(AVMCOEESADB)].[dbo].[CentralRepository_SFDC_Account] CA    
   JOIN [$(AVMCOEESADB)].[dbo].RHMSaccount A ON CA.Peoplesoft_Customer_Id__C = A.Peoplesoft_Customer_Id__C    
   JOIN [$(AVMCOEESADB)].[dbo].[RHMSSubBusinessUnit1] sbu ON sbu.Sbu1Id = A.SBU1_Id__c    
   JOIN [$(AVMCOEESADB)].[dbo].[RHMSCustomerBUHierarchyMapping] map on map.Sbu1Id = sbu.Sbu1Id AND map.ActiveFlag = 1 AND ISNULL(map.MarketID,'') <> ''    
   JOIN [$(AVMCOEESADB)].[dbo].[RHMSBusinessUnit] rbu on map.BusinessId = rbu.BusinessId and rbu.ActiveFlag=1    
   JOIN [$(AVMCOEESADB)].[dbo].[RHMSMarketUnit] mu ON mu.GlobalMarketId = map.GroupId    
   JOIN [$(AVMCOEESADB)].[dbo].[RHMSMarket] m ON map.MarketID = m.MarketId     
   WHERE map.[Sbu2Id] is NULL     
         
      
      -- Insert / Activate / De-activate Market      
   INSERT INTO ESA.Market      
    SELECT DISTINCT AH.Market_Id, AH.Market, 0, 'SYSTEM', GETDATE(), NULL, NULL      
    FROM ESA.AccountHierarchyDetails AH      
    LEFT JOIN ESA.Market M       
     ON M.MarketName = AH.Market      
    WHERE M.MarketName IS NULL      
      
      UPDATE M      
   SET M.IsDeleted = CASE WHEN AH.Market IS NULL THEN 1 ELSE 0 END,      
    M.ModifiedBy = CASE WHEN M.IsDeleted = (CASE WHEN AH.Market IS NULL THEN 1 ELSE 0 END)       
        THEN M.ModifiedBy ELSE 'SYSTEM' END,       
    M.ModifiedDateTime = CASE WHEN M.IsDeleted = (CASE WHEN AH.Market IS NULL THEN 1 ELSE 0 END)       
        THEN M.ModifiedDateTime ELSE GETDATE() END      
   FROM ESA.Market M      
   LEFT JOIN ESA.AccountHierarchyDetails AH      
    ON M.MarketName = AH.Market      
      
   -- Insert / Activate / De-activate Market Unit      
   INSERT INTO ESA.MarketUnit      
    SELECT DISTINCT AH.Global_Market_Id, AH.Global_Market, M.MarketID, 0, 'SYSTEM', GETDATE(), NULL, NULL      
    FROM ESA.AccountHierarchyDetails AH      
    JOIN ESA.Market M       
     ON M.MarketName = AH.Market      
    LEFT JOIN ESA.MarketUnit MU       
     ON MU.MarketUnitName = AH.Global_Market      
    WHERE MU.MarketUnitName IS NULL      
      
      UPDATE MU      
   SET MU.MarketID = (CASE WHEN MU1.MarketUnitID IS NULL THEN M.MarketID ELSE MU.MarketID END),       
       MU.IsDeleted = 0, MU.ModifiedBy = 'SYSTEM', MU.ModifiedDateTime = GETDATE()      
   FROM ESA.MarketUnit MU      
   JOIN ESA.AccountHierarchyDetails AH      
    ON MU.MarketUnitName = AH.Global_Market      
   JOIN ESA.Market M       
     ON M.MarketName = AH.Market      
   LEFT JOIN ESA.MarketUnit MU1       
     ON MU1.MarketID = M.MarketID AND MU1.MarketUnitName = MU.MarketUnitName      
   WHERE MU.IsDeleted = 1 OR MU.MarketID <> M.MarketID       
      
   UPDATE MU      
   SET MU.IsDeleted = 1, MU.ModifiedBy = 'SYSTEM', MU.ModifiedDateTime = GETDATE()      
   FROM ESA.MarketUnit MU      
   LEFT JOIN ESA.AccountHierarchyDetails AH      
    ON MU.MarketUnitName = AH.Global_Market      
   WHERE AH.Global_Market IS NULL      
      
   -- Insert / Activate / De-activate Business Unit      
   INSERT INTO ESA.ESABusinessUnit      
    SELECT DISTINCT MU.MarketUnitID, AH.BU_Id, AH.Bu, 0, 'SYSTEM', GETDATE(), NULL, NULL      
    FROM ESA.AccountHierarchyDetails AH      
    JOIN ESA.MarketUnit MU       
     ON MU.MarketUnitName = AH.Global_Market      
    LEFT JOIN ESA.ESABusinessUnit BU       
     ON BU.BusinessUnitName = AH.Bu      
    WHERE BU.BusinessUnitName IS NULL      
      
      UPDATE BU      
   SET BU.MarketUnitID = (CASE WHEN NBU.BusinessUnitID IS NULL THEN MU.MarketUnitID ELSE BU.MarketUnitID END),      
       BU.IsDeleted = 0,      
    BU.ModifiedBy = 'SYSTEM', BU.ModifiedDateTime = GETDATE()      
   FROM ESA.ESABusinessUnit BU      
   JOIN ESA.AccountHierarchyDetails AH      
    ON BU.BusinessUnitName = AH.Bu      
   JOIN ESA.MarketUnit MU      
     ON MU.MarketUnitName = AH.Global_Market      
   LEFT JOIN ESA.ESABusinessUnit NBU       
     ON MU.MarketUnitID = NBU.MarketUnitID AND NBU.BusinessUnitName = BU.BusinessUnitName      
   WHERE BU.IsDeleted = 1 OR BU.MarketUnitID <> MU.MarketUnitID       
         
   UPDATE BU      
   SET BU.IsDeleted = 1,      
    BU.ModifiedBy = 'SYSTEM', BU.ModifiedDateTime = GETDATE()      
   FROM ESA.ESABusinessUnit BU      
   LEFT JOIN ESA.AccountHierarchyDetails AH      
    ON BU.BusinessUnitName = AH.Bu      
   WHERE AH.Bu IS NULL      
      
     COMMIT TRAN      
 END TRY      
 BEGIN CATCH          
      
  ROLLBACK TRAN      
        
  DECLARE @ErrorMessage VARCHAR(MAX);      
  DECLARE @MailSubject  VARCHAR(MAX);        
  DECLARE @MailBody     VARCHAR(MAX);      
      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  SELECT @ErrorMessage AS ErrorMessage      
      
  SELECT @MailSubject = CONCAT(@@SERVERNAME,': ESA Job Failure Notification')      
      
  SELECT @MailBody = CONCAT('<font color="Black" face="Arial" Size = "2">Team, <br><br>Oops! Error Occurred in AppVision ESA  to Live Data Refresh during the ESA Job Execution!<br>      
       <br>Error: ', @ErrorMessage,      
       '<br><br>Regards,<br>Solution Zone Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')      
      
  INSERT INTO [$(AVMCOEESADB)].DBO.ESAJobErrors        
  (      
   JobName,      
   ErrorSource,      
   ErrorDescription,      
   CreatedBy,      
   CreatedDate,      
   ServerName      
  )         
  SELECT 'AppVision ESA to Live Data Refresh', '[AVL].[Evaluate_Market_MU_BU_ESA]', @ErrorMessage, '0', GETDATE(), @@SERVERNAME       
         
  -- Send Mail on Error      
  DECLARE @recipientsAddress NVARCHAR(4000) = '';      
  SET @recipientsAddress = (SELECT ConfigValue FROM AVL.AppLensConfig WHERE ConfigName='Mail' AND IsActive=1);         
           
		   EXEC [AVL].[SendDBEmail] @To=@recipientsAddress,
    @From='ApplensSupport@cognizant.com',
    @Subject =@MailSubject,
    @Body = @MailBody
            
 END CATCH        
         
END  

