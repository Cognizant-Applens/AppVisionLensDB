/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetALMConfigrationCompletionPercentageForAllproject]
AS  
BEGIN    
SET NOCOUNT ON   
BEGIN TRY  
  

CREATE TABLE #temp1
(
ID INT IDENTITY(1,1),
CompletionPercentage INT,
)
CREATE TABLE #PROJECTLIST
(
ID INT IDENTITY(1,1),
PROJECTID BIGINT 
)


		DECLARE @Counter INT 
		DECLARE @TotalCounter INT
		DECLARE @ProjectID BIGINT
		Declare @Pre INT
		SET @Counter= 1

		IF NOT EXISTS(select PROJECTID from #PROJECTLIST )
		BEGIN
		INSERT INTO #PROJECTLIST
		select PROJECTID from pp.scopeofwork where isapplensASALM <> 1    
		END 
		SET @TotalCounter= (select count(PROJECTID) from #PROJECTLIST)

		WHILE ( @Counter <= @TotalCounter)
		BEGIN
		set @projectID = (select PROJECTID from #PROJECTLIST where id = @Counter)

		INSERT INTO #temp1 
		exec [PP].[GetALMProgressPercentage] @projectID

		SET @Counter  = @Counter  + 1

		END

		select PP.PROJECTID as ProjectID,TT.CompletionPercentage into #Finaldata from #temp1 TT 
		join #PROJECTLIST PP on TT.ID = PP.ID

		drop table #temp1
		drop table #PROJECTLIST

		select FA.ProjectID,CompletionPercentage from #Finaldata FA 
		join [AVL].[MAS_ProjectMaster] PP on PP.ProjectID = FA.projectID
		where CompletionPercentage = 100 and PP.IsDeleted = 0
END TRY  
BEGIN CATCH  
        
 DECLARE @ErrorMessage VARCHAR(MAX);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
    
 EXEC AVL_InsertError 'PP.GetALMProgressPercentage', @ErrorMessage, 0 ,''  
    
END CATCH  
  
SET NOCOUNT OFF  
  
END
