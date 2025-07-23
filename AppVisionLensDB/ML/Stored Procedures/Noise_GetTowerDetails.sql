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
-- Author:  Bala      
-- Create date: 23-03-2022      
-- Description:       
-- =============================================      
CREATE PROCEDURE [ML].[Noise_GetTowerDetails]       
 -- Add the parameters for the stored procedure here      
       
 @ProjectID bigint        
AS      
BEGIN      
BEGIN TRY      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
    -- Insert statements for procedure here      
 SELECT distinct IT.ProjectID, TD.InfraTowerTransactionID AS Tower,TD.TowerName FROM AVL.InfraTowerProjectMapping IT       
    JOIN AVL.InfraTowerDetailsTransaction TD       
    ON IT.TowerID=TD.InfraTowerTransactionID AND IT.IsDeleted=0 AND TD.IsDeleted=0      
    AND IT.IsEnabled=1        
    WHERE IT.ProjectID=@ProjectID      
      
      
       
END TRY      
BEGIN CATCH       
        DECLARE @ErrorMessage VARCHAR(MAX);       
      
        SELECT @ErrorMessage = Error_message()       
      
        ROLLBACK TRAN       
      
        --INSERT Error           
        EXEC Avl_inserterror       
        '[ML].[Noise_GetTowerDetails]',       
        @ErrorMessage,       
        @ProjectID ,      
  0      
END CATCH       
END
