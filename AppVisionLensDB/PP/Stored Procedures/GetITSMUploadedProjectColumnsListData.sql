/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetITSMUploadedProjectColumnsListData]
 (	         
	@ProjectID INT  
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON   
 		
	CREATE TABLE #AllData (
    ProjectID int,
    ServiceDartColumn  VARCHAR(MAX)
);	
INSERT INTO #AllData (ProjectID,ServiceDartColumn)
select ProjectID,ServiceDartColumn from AVL.[ITSM_PRJ_SSISExcelColumnMapping] (NOLOCK) as a  where ProjectID=@ProjectID and IsDeleted=0 and ServiceDartColumn is not null
Union
select ProjectID,ProjectColumn from [AVL].[ITSM_PRJ_SSISExcelColumnMapping] (NOLOCK) where ProjectID=@ProjectID and IsDeleted=0 and ServiceDartColumn is not null
union
select ProjectID,ProjectColumn from AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) where ProjectID=@ProjectID and IsDeleted=0

select ProjectID,ServiceDartColumn as ITSM_Source_ColumnID ,ServiceDartColumn from #AllData (NOLOCK) where ServiceDartColumn is not null and ServiceDartColumn<>'' 
  --SELECT ServiceDartColumn as  ITSM_Source_ColumnID, ProjectID, ServiceDartColumn,ProjectColumn,  IsDeleted  
  --  FROM  [AVL].[ITSM_PRJ_SSISExcelColumnMapping] where ProjectId=20027 and IsDeleted=0 and ServiceDartColumn is not null
  drop table #AllData
  SET NOCOUNT OFF
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetITSMUploadedProjectColumnsListData]', @ErrorMessage, 0 ,0
  END CATCH

END
