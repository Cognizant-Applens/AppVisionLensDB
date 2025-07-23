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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [AVL].[APP_INV_CheckDuplicateRowsforUpload]
@Mode varchar(max)=null,
	@CustomerId bigint=null
AS
BEGIN
BEGIN TRY
	
	SET NOCOUNT ON;

if @Mode='HierarchyCheck'
BEGIN
     SELECT
    Hierarchy1,Hierarchy2,Hierarchy3,Hierarchy4,Hierarchy5,Hierarchy6,ApplicationName,CustomerId, COUNT(*) AS [Count]
FROM
    ApplicationHierarchyTemp
GROUP BY
    Hierarchy1,Hierarchy2,Hierarchy3,Hierarchy4,Hierarchy5,Hierarchy6,ApplicationName,CustomerId
HAVING 
    COUNT(*) > 1
DECLARE @IsDuplicated bigint
SET @IsDuplicated=(SELECT @@ROWCOUNT )
	IF @IsDuplicated <> 0
	begin
  select '1'
  end
ELSE 
begin
  SELECT '0'
  END
  END

  ELSE IF @Mode='AttributesCheck'
    BEGIN
SELECT ApplicationName,BusinessClusterName
   , COUNT(*) AS [Count]
FROM
    MAS.AppInventoryUpload
GROUP BY
    ApplicationName,BusinessClusterName
HAVING 
    COUNT(*) > 1
DECLARE @IsDuplicatedAttribute bigint
SET @IsDuplicatedAttribute=(SELECT @@ROWCOUNT )
	IF @IsDuplicatedAttribute <> 0
	begin
  select '1'
  end
ELSE 
begin
  SELECT '0'
  END
  END

  ELSE IF @Mode='HeirarchyValidation'
  BEGIN
		  DECLARE @Count BIGINT
		  SET @Count=(SELECT COUNT(*) FROM AVL.BusinessCluster WHERE CustomerId=@CustomerId)
		 	  IF @Count=3
	 BEGIN
			  UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy1 is null or Hierarchy1='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy2 is null or Hierarchy2='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy3 is null or Hierarchy3='') 
			IF EXISTS (SELECT 1 FROM ApplicationHierarchyTemp WHERE CustomerId =@CustomerId AND ApplicationName='N')                        
				SELECT '1'	
				ELSE 
			SELECT '0'
	 END

 Else IF @Count=4
	 BEGIN
			  UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy1 is null or Hierarchy1='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy2 is null or Hierarchy2='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy3 is null or Hierarchy3='') 
				 UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy4 is null or Hierarchy4='')
			IF EXISTS (SELECT 1 FROM ApplicationHierarchyTemp WHERE CustomerId =@CustomerId AND ApplicationName='N')                        
				SELECT '1'	
				ELSE 
			SELECT '0'
	 END
 Else IF @Count=5
	 BEGIN
			  UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy1 is null or Hierarchy1='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy2 is null or Hierarchy2='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy3 is null or Hierarchy3='') 
				 UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy4 is null or Hierarchy4='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy5 is null or Hierarchy5='')
			IF EXISTS (SELECT 1 FROM ApplicationHierarchyTemp WHERE CustomerId =@CustomerId AND ApplicationName='N')                        
				SELECT '1'	
				ELSE 
			SELECT '0'
	 END
	ELSE IF @Count=6
	 BEGIN
			  UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy1 is null or Hierarchy1='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy2 is null or Hierarchy2='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy3 is null or Hierarchy3='') 
				 UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy4 is null or Hierarchy4='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy5 is null or Hierarchy5='')
				UPDATE ApplicationHierarchyTemp SET ApplicationName='N'
			  where CustomerId =@CustomerId       
				and (Hierarchy6 is null or Hierarchy6='')
			IF EXISTS (SELECT 1 FROM ApplicationHierarchyTemp WHERE CustomerId =@CustomerId AND ApplicationName='N')                        
				SELECT '1'	
				ELSE 
			SELECT '0'
	 END
	
	
			

  END
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

	  
		EXEC AVL_InsertError '[AVL].[APP_INV_CheckDuplicateRowsforHierarchy]', @ErrorMessage, 0, @CustomerId 
	END CATCH  

END
