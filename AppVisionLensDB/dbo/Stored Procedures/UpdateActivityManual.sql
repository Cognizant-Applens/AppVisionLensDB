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
-- Author:  Gayatri  
-- Create date:    
-- Description: <Description,,>
--sp_helptext '[AVL].GetApplicationMappingCount'    
-- =============================================    
CREATE PROCEDURE [dbo].[UpdateActivityManual]     
 -- Add the parameters for the stored procedure here    
 @Manual bit,    
 @ActivityID bigint,    
 @BusinessProcessID bigint,    
 @AccountID bigint,    
 @CognizantID nvarchar(50)    
AS    
BEGIN    
 --DECLARE @BusinessProcessMapID BIGINT    
 -- SELECT @BusinessProcessMapID=BPMappingID    
 -- FROM dbo.BOM_BusinessProcessMapping    
 -- WHERE AccountID=@AccountID  AND BusinessProcessID= @BusinessProcessID    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    


 --DECLARE @Customer_ID INT
 --select @Customer_ID = CustomerID from AVL.Customer where ESA_AccountId=@AccountID

    
    
 DELETE FROM AVL.BOM_ActivityMap WHERE ActivityID=@ActivityID AND BusinessProcessId = @BusinessProcessID AND AccountID=@AccountID    
    
if @Manual=1    
 BEGIN    
  INSERT INTO AVL.BOM_ActivityMap (ActivityID,IsActive,CreatedBy,CreatedDate,    
         ModifiedBy,ModifiedDate,ApplicationID,Manual,BusinessProcessId,AccountId) VALUES (@ActivityID,    
         1,@CognizantID,GETDATE(),@CognizantID,GETDATE(),0,@Manual,@BusinessProcessID,@AccountID)    
 END    
    
     
     
END
