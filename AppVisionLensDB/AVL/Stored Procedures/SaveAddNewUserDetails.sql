/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
  
CREATE PROCEDURE [AVL].[SaveAddNewUserDetails]      
(      
@CustomerID varchar(20),    
@ProjectID int,    
@UserDetails [AVL].[TVP_AddNewUser] READONLY      
)      
AS      
BEGIN      
BEGIN TRY  
BEGIN TRAN  
DECLARE @result bit;  
  
CREATE TABLE #UserDetailss(  
UserId BIGINT NOT NULL,  
OldEmployeeId NVARCHAR(50),  
NewEmployeeId NVARCHAR(50)  
)  
  
   SELECT * INTO #UDetails FROM @UserDetails   
  
   UPDATE UD SET UD.TimeZoneId = TZ.TimeZoneId  
   FROM #UDetails UD  
   JOIN [AVL].[MAS_TimeZoneMaster](NOLOCK) TZ  
   ON UD.TimeZoneName = TZ.TimeZoneName AND TZ.IsDeleted = 0  
   WHERE UD.TimezoneId = 0  
  
     
  
   INSERT INTO #UserDetailss  
   SELECT DISTINCT UserId, NULL  AS OldEmployeeId, EmployeeId as NewEmployeeId  
   FROM #UDetails  
   WHERE ISNULL(UserId,0) <> 0  
  
   UPDATE UD SET UD.OldEmployeeId = LM.EmployeeId  
   FROM #UserDetailss UD   
   JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
   ON UD.UserId = LM.UserId AND LM.ProjectId = @ProjectID  
     
   SELECT DISTINCT UserId,OldEmployeeId,NewEmployeeId  INTO #UserDetails  
   FROM #UserDetailss   
   WHERE OldEmployeeId <> NewEmployeeId  
  
  
   UPDATE LM SET LM.TSApproverID = UD.NewEmployeeId,ModifiedBy = 'AddNewUser',ModifiedDate = GetDate()  
   FROM AVL.MAS_LOGINMASTER(NOLOCK) LM  
   JOIN  #UserDetails UD (NOLOCK)   
   ON UD.OldEmployeeId = LM.TSApproverId AND LM.CustomerId = @CustomerId  
     
   MERGE AVL.MAS_LoginMaster LM USING  
   #UDetails T  
   ON ((LM.UserId = T.UserId) OR (LM.EmployeeId = T.EmployeeId AND LM.ProjectId = @ProjectId))  
   WHEN MATCHED THEN  
   UPDATE SET   
   LM.EmployeeId = T.EmployeeId,  
   LM.EmployeeEmail = T.EmployeeEmail,  
   LM.EmployeeName = T.EmployeeName,  
   LM.TSApproverID=T.TSApproverID,            
   LM.ClientUserID=RTRIM(LTRIM(T.ClientUserID)),            
   LM.TimezoneID=T.TimezoneId,            
   LM.MandatoryHours=T.MandatoryHours,            
   LM.ModifiedDate=GETDATE(),  
   LM.ModifiedBy = 'AddNewUser',  
   LM.IsDeleted = CASE WHEN IsNull(T.IsDeleted,1) = 1 THEN 0 ELSE  1 END  
   WHEN NOT MATCHED THEN   
  INSERT (CustomerID,ClientUserID,EmployeeID,EmployeeName,EmployeeEmail,TSApproverID,ProjectID,IsDeleted ,MandatoryHours,TimezoneID,CreatedBy, CreatedDate )     
VALUES(@CustomerID,RTRIM(LTRIM(T.ClientUserID)),T.EmployeeID,T.EmployeeName,T.EmployeeEmail,T.TSApproverID,@ProjectID,0,T.MandatoryHours,T.TimezoneID  
,'AddNewUser',GetDate());  
  
 SET @result= 1            
  SELECT @result AS RESULT       
COMMIT TRAN   
END TRY  
BEGIN CATCH    
ROLLBACK TRAN  
DECLARE @ErrorMessage VARCHAR(MAX);          
SELECT @ErrorMessage = ERROR_MESSAGE()   
 SET @result= 0        
  SELECT @result AS RESULT   
--- Insert Error Message ---          
EXEC AVL_InsertError '[AVL].[SaveAddNewUserDetails]', @ErrorMessage, 0, 0      
  
END CATCH  
END  