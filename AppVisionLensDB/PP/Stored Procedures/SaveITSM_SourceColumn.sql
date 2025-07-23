/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : 
-- Create date : 28/07/2020
-- Description : Procedure to SourceColumn
-- Revision    :
-- Revised By  :
-- ========================================================================================= 

CREATE PROCEDURE [PP].[SaveITSM_SourceColumn]
(	         
	@ProjectID INT null,    
	@CreatedBy VARCHAR(100) null,
	@IsResetDataSave int null,
	@SourceColumnList [PP].[TVP_ITSM_SourceColumnList] READONLY
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
 declare @s int 
 declare @Tot int 
 if(@IsResetDataSave=0)
 BEGIN
 set @s= (Select count(ProjectID) as s from [AVL].[ITSM_PRJ_SSISExcelColumnMapping] (NOLOCK) where ProjectID=@ProjectID)
 IF(@s = 0)
   Begin 
    INSERT INTO [AVL].[ITSM_PRJ_SSISExcelColumnMapping](ProjectID,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDateTime)
      SELECT ProjectID,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDate FROM @SourceColumnList 
   end
   else
   Begin 
    --set @Tot=( SELECT COUNT(*) FROM @SourceColumnList As s full outer Join [AVL].[ITSM_PRJ_SSISExcelColumnMapping] AS Al on s.ColumnName=Al.ColumnName where s.ProjectID =@ProjectID  and ISNULL(Al.ProjectID,'')='')
   set  @Tot=(SELECT COUNT(ProjectID) from @SourceColumnList As s  where s.ProjectID=@ProjectID and not exists
   (select ServiceDartColumn from [AVL].[ITSM_PRJ_SSISExcelColumnMapping] sc (NOLOCK) where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and sc.ServiceDartColumn=s.ServiceDartColumn))
   
   IF(@tot >= 0)
   begin 
   INSERT INTO [AVL].[ITSM_PRJ_SSISExcelColumnMapping](ProjectID,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
      SELECT s.ProjectID,s.ServiceDartColumn,s.ProjectColumn,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.CreatedBy,s.CreatedDate FROM @SourceColumnList As s where s.ProjectID=@ProjectID and not exists
	  (select ServiceDartColumn from [AVL].[ITSM_PRJ_SSISExcelColumnMapping]sc (NOLOCK) where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and sc.ServiceDartColumn=s.ServiceDartColumn)
   End 
   End 
  END
ELSE
  BEGIN
   Delete from [AVL].[ITSM_PRJ_SSISExcelColumnMapping] where ProjectID=@ProjectID
   INSERT INTO [AVL].[ITSM_PRJ_SSISExcelColumnMapping](ProjectID,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
      SELECT s.ProjectID,s.ServiceDartColumn,s.ProjectColumn,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.CreatedBy,s.CreatedDate FROM @SourceColumnList As s where s.ProjectID=@ProjectID and not exists
	  (select ServiceDartColumn from [AVL].[ITSM_PRJ_SSISExcelColumnMapping]sc (NOLOCK) where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and sc.ServiceDartColumn=s.ServiceDartColumn)
   
  END
SET NOCOUNT OFF
 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[SaveITSM_SourceColumn]', @ErrorMessage, 0 ,@CreatedBy
  END CATCH

END
