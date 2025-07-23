/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [PP].[SaveTowerAssignmentGroupMappingData]            
@ProjectID BIGINT,             
@EmployeeID varchar(30),            
@TowerAssignmentGroupMapping AS [AVL].[TVP_TowerAssignmentGroupMapping] READONLY            
AS            
BEGIN            
BEGIN TRY            
            
CREATE TABLE #FinalSaveData            
(            
ProjectID BIGINT,           
AssignementGroupMapID bigint,            
AssignmentGroupName varchar(max),           
TowerId bigint,          
TowerName varchar(max)           
            
)         
DECLARE @CustomerId BIGINT; SELECT TOP 1 @CustomerId=CustomerId from AVL.MAS_ProjectMaster where ProjectID=@ProjectID    
            
INSERT INTO #FinalSaveData            
SELECT @ProjectID, AG.AssignmentGroupMapID,TVP.AssignmentGroupMapName,TD.InfraTowerTransactionID, TVP.TowerName          
From @TowerAssignmentGroupMapping TVP          
join AVL.BOTAssignmentGroupMapping AG on AG.AssignmentGroupName=Ltrim(Rtrim(TVP.AssignmentGroupMapName)) and AG.SupportTypeID=2 and AG.ProjectID= @ProjectID       
left join AVL.InfraTowerDetailsTransaction TD on TD.TowerName=Ltrim(Rtrim(TVP.[TowerName]))  and Customerid=@CustomerId       
          
            
UPDATE TAG set IsDeleted=1            
from PP.TowerAssignmentGroupMapping TAG            
join AVL.BOTAssignmentGroupMapping AG ON AG.AssignmentGroupMapID = TAG.AssignmentGroupMapId          
join #FinalSaveData Temp on Temp.AssignmentGroupName=AG.AssignmentGroupName            
 where TAG.ProjectID=@ProjectID            
            
 DELETE #FinalSaveData where ProjectID=@ProjectID and TowerId is NULL            
            
MERGE PP.TowerAssignmentGroupMapping AS TAG            
USING #FinalSaveData AS Temp             
ON (TAG.ProjectID=@ProjectID and TAG.AssignmentGroupMapID=Temp.AssignementGroupMapID and TAG.TowerId = Temp.TowerId)             
--When records are matched, update the records if there is any change            
WHEN MATCHED            
THEN UPDATE SET TAG.IsDeleted=0,TAG.ModifiedBy=@EmployeeID,TAG.ModifiedDate=GETDATE()            
--When no records are matched, insert the incoming records from source table to target table            
WHEN NOT MATCHED BY TARGET             
THEN INSERT (ProjectID,AssignmentGroupMapID,TowerId,IsDeleted,CreatedBy,CreatedDate)             
VALUES (Temp.ProjectID,Temp.AssignementGroupMapID,Temp.TowerId,0,@EmployeeID,GETDATE());            
            
            
SELECT @@rowcount as 'RowCount'            
            
END TRY             
BEGIN CATCH            
DECLARE @ErrorMessage VARCHAR(MAX);            
SELECT            
 @ErrorMessage = ERROR_MESSAGE()            
EXEC AVL_InsertError '[PP].[SaveTowerAssignmentGroupMappingData]'            
      ,@ErrorMessage            
      ,0            
      ,0            
END CATCH            
            
END
