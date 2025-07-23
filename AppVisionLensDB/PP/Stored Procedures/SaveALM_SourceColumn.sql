/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveALM_SourceColumn]
(	         
	@ProjectID INT null,    
	@CreatedBy VARCHAR(100) null ,
	@SourceColumnList [PP].[TVP_ALM_SourceColumnList] READONLY,
    @IsResetDataSave int null
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON
declare @s int 
 declare @Tot int 
if(@IsResetDataSave=0)
 BEGIN
 set @s= (Select count(ProjectID) as s from PP.ALM_SourceColumn where ProjectID=@ProjectID)
IF(@s = 0)
   Begin 
    INSERT INTO PP.ALM_SourceColumn(ProjectID,ColumnName,IsDeleted,CreatedBy,CreatedDate)
      SELECT ProjectID,LTRIM(RTRIM(ColumnName)) AS ColumnName,IsDeleted,CreatedBy,CreatedDate FROM @SourceColumnList
   end
   else
   Begin 
    --set @Tot=( SELECT COUNT(*) FROM @SourceColumnList As s full outer Join PP.ALM_SourceColumn AS Al on s.ColumnName=Al.ColumnName where s.ProjectID =@ProjectID  and ISNULL(Al.ProjectID,'')='')
   set  @Tot=(SELECT COUNT(ProjectID) from @SourceColumnList As s where s.ProjectID=@ProjectID and not exists
(select LTRIM(RTRIM(ColumnName)) AS ColumnName from pp.ALM_SourceColumn sc where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and LTRIM(RTRIM(sc.ColumnName))=LTRIM(RTRIM(s.ColumnName))))
   
   IF(@tot >= 0)
   begin 
   INSERT INTO PP.ALM_SourceColumn(ProjectID,ColumnName,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
      SELECT s.ProjectID,LTRIM(RTRIM(s.ColumnName)) AS ColumnName,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.CreatedBy,s.CreatedDate FROM @SourceColumnList As s where s.ProjectID=@ProjectID and not exists
         (select LTRIM(RTRIM(ColumnName)) AS ColumnName   from pp.ALM_SourceColumn sc where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and LTRIM(RTRIM(sc.ColumnName))=LTRIM(RTRIM(s.ColumnName)))
   End 
   End 
END
ELSE
  BEGIN
   Delete from PP.ALM_SourceColumn where ProjectID=@ProjectID
   INSERT INTO PP.ALM_SourceColumn(ProjectID,ColumnName,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
      SELECT s.ProjectID,LTRIM(RTRIM(s.ColumnName)) AS ColumnName,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.CreatedBy,s.CreatedDate FROM @SourceColumnList As s where s.ProjectID=@ProjectID and not exists
         (select LTRIM(RTRIM(ColumnName)) AS ColumnName   from pp.ALM_SourceColumn sc where  sc.ProjectID=s.ProjectID  and  sc.ProjectID=@ProjectID and LTRIM(RTRIM(sc.ColumnName))=LTRIM(RTRIM(s.ColumnName)))
   
  END
 END TRY
  BEGIN CATCH
            DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE()
              ROLLBACK TRAN
              EXEC AVL_InsertError '[PP].[TVP_ALM_SourceColumnList]', @ErrorMessage, 0 ,@CreatedBy
  END CATCH

END
