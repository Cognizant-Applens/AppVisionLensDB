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
-- Create date : 18/05/20200
-- Description : Get Saved Column Mapping Data
-- Revision    :
-- Revised By  :
--[PP].[GetITSMSavedColumnMappingData]  9829
-- ========================================================================================= 
CREATE PROCEDURE [PP].[GetITSMSavedColumnMappingData]
 (	         
	@ProjectID INT  
)
AS
 BEGIN
 BEGIN TRY
 SET NOCOUNT ON
   
 
  --SELECT ColumnMapId as MappedColumnSerialId,ALMColID as StandardColumnId,ProjectColumn as UploadedFileColumnName,
  --ProjectId,IsDeleted       
  --  FROM  [PP].[ALM_MAP_ColumnName]	 where ProjectId=@ProjectID and IsDeleted=0

	select IPS.ServiceDartColumn,COALESCE(NULLIF(IPS.ProjectColumn,''), '0') as ProjectColumn ,IPS.IsDeleted,IPS.SOURCEINDEX,IPS.DESTINATIONINDEX, IPS.ProjectId--,IPSC.SSIScmID 
	from AVL.ITSM_PRJ_SSISColumnMapping AS IPS 
	--left join MAS.ITSM_Columnname  AS IMS on IPS.ServiceDartColumn=IMS.ColumnName
	--left join [AVL].[ITSM_PRJ_SSISExcelColumnMapping]  AS IPSC on IPS.ProjectColumn=IPSC.ProjectColumn
	where IPS.ProjectId=@ProjectID and  IPS.IsDeleted=0 --and --IPS.ProjectColumn <>''--and IPSC.ProjectId=@ProjectID  and  IPSC.IsDeleted=0 

 END TRY
  BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);
		 SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError '[PP].[GetITSMSavedColumnMappingData]', @ErrorMessage, 0 ,0
  END CATCH

END
