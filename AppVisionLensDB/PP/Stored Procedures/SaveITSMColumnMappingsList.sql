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
-- Description : Procedure to save the column mapping list  
-- Revision    :
-- Revised By  :
-- ========================================================================================= 

CREATE PROCEDURE [PP].[SaveITSMColumnMappingsList]
(	         
	@ProjectID Bigint  Null,    
	@CreatedBy VARCHAR(100) null,
	@SupportTypeID int NULL,
	@ColumnMappingsList [PP].[TVP_ITSM_SourceAndDestinationColumnMappingDataList] READONLY
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
 declare @RowCount int  
 set @RowCount= (Select count(ProjectId) as Row_Count from [AVL].[ITSM_PRJ_SSISColumnMapping] where ProjectID=@ProjectID and IsDeleted=0)

 IF(@RowCount = 0)
   Begin 
    INSERT INTO [AVL].[ITSM_PRJ_SSISColumnMapping] (ProjectId,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
      SELECT CL.ProjectId,IC.ColumnName,CL.MappedColumnName,CL.IsDeleted,CL.CreatedBy,CL.CreatedDate,CL.CreatedBy,CL.CreatedDate FROM @ColumnMappingsList CL
	  LEFT JOIN MAS.ITSM_Columnname IC ON CL.SourceColumnName=IC.ColumnID --where IC.SupportTypeID=@SupportTypeID
   end
   else
   Begin 
   --Update [AVL].[ITSM_PRJ_SSISColumnMapping]  set IsDeleted=1 where ProjectID=@ProjectID and IsDeleted=0
   Delete from [AVL].[ITSM_PRJ_SSISColumnMapping] where ProjectID=@ProjectID   
    
	INSERT INTO [AVL].[ITSM_PRJ_SSISColumnMapping] (ProjectId,ServiceDartColumn,ProjectColumn,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
    SELECT CL.ProjectId,IC.ColumnName,CL.MappedColumnName,CL.IsDeleted,CL.CreatedBy,CL.CreatedDate,CL.CreatedBy,CL.CreatedDate FROM @ColumnMappingsList CL
	  LEFT JOIN MAS.ITSM_Columnname IC ON CL.SourceColumnName=IC.ColumnID --where IC.SupportTypeID=@SupportTypeID
	 
   End 

 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[SaveITSMColumnMappingsList]', @ErrorMessage, 0 ,@CreatedBy
  END CATCH

END
