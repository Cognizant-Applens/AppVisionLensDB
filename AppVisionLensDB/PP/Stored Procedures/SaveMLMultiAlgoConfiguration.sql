/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

 CREATE PROCEDURE PP.SaveMLMultiAlgoConfiguration  
(  
@ProjectId bigint,  
@EmployeeID NVARCHAR(50),  
@TvpMLMultiAlgorithms as [PP].[TVP_MLMultiAlgorithms] READONLY  
)  
AS  
  BEGIN     
 BEGIN TRY      
    BEGIN TRAN    
  SET NOCOUNT ON;   
  DECLARE @Result BIT;   
MERGE PP.MLMultiAlgoConfiguration MAC  
USING @TvpMLMultiAlgorithms TMAC  
ON MAC.ProjectID = @ProjectId AND MAC.AlgorithmId = TMAC.AlgorithmId  
WHEN MATCHED THEN  
UPDATE SET MAC.Preference = TMAC.Preference,MAC.Isdeleted = CASE WHEN TMAC.IsSelected =1 THEN 0 ELSE 1 END,MAC.ModifiedBy = @EmployeeID,MAC.ModifiedDate= GetDate()  
WHEN NOT MATCHED  THEN  
INSERT (  
ProjectID  
,AlgorithmId  
,Preference  
,IsDeleted  
,CreatedBy  
,CreatedDate  
,ModifiedBy  
,ModifiedDate  
)  
VALUES (  
@ProjectId,  
TMAC.AlgorithmId,  
TMAC.Preference,  
CASE WHEN TMAC.IsSelected =1 THEN 0 ELSE 1 END,  
@EmployeeID,  
GetDate(),  
NULL,  
NULL  
);  
  
   SET @Result = 1    
   Select @Result as Result    
  COMMIT TRAN    
 END TRY     
    
    BEGIN CATCH     
  SET @Result = 0    
  Select @Result as Result    
        DECLARE @ErrorMessage VARCHAR(MAX);     
        SELECT @ErrorMessage = ERROR_MESSAGE()     
        --INSERT Error       
  ROLLBACK TRAN    
        EXEC AVL_INSERTERROR  '[PP].[SaveMLMultiAlgoConfiguration]', @ErrorMessage,  0,     
        0     
    END CATCH     
  END
