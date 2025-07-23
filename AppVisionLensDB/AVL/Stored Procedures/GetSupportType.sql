/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetSupportType] --'10337'
	@ProjectID nvarchar(100)
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

		Declare @scopecount int,@projectscope int=0;
		CREATE TABLE #TempProjectScope(IsDevelopment BIT,ProjectID BIGINT)

		IF EXISTS (select ProjectID from pp.ProjectAttributeValues where ProjectID=@ProjectID and AttributeID=1 and IsDeleted=0)
		BEGIN 
		if exists (select ProjectID from PP.ProjectAttributeValues  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0)
		begin
		select @scopecount= Count(ProjectID) from PP.ProjectAttributeValues  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0

		if (@scopecount=2)
		begin
		select @projectscope=3;--IF BOTH MAINTANANCE & CIS HAD BEEN SELECTED
		end

		else if(@scopecount=1)
		Begin

		select @projectscope= case 
		when AttributeValueID = 2 Then 1 --IF MAINTANANCE WAS SELECTED
		when AttributeValueID = 3 Then 2 --IF CIS WAS SELECTED
		end 
		from PP.ProjectAttributeValues  where  AttributeID=1 and ProjectID=@ProjectID and AttributeValueID in (2,3) and IsDeleted=0
		end
		end

		else
		begin
		select @projectscope=4;-- IF DEVELOPMENT/TESTING HAD BEEN SELECTED
		end

		IF EXISTS (SELECT ProjectID FROM [AVL].[MAP_ProjectConfig] WHERE ProjectID = @ProjectID)
		BEGIN 
		UPDATE [AVL].[MAP_ProjectConfig] SET SupportTypeID = @projectscope  WHERE ProjectID = @ProjectID
		END

		ELSE
		BEGIN
		Insert into [AVL].[MAP_ProjectConfig] (ProjectID,SupportTypeId) values (@ProjectID,@projectscope)
		END

		END

		IF EXISTS (SELECT 1 FROM PP.ProjectAttributeValues where AttributeValueID IN (1,4) AND ProjectID=@ProjectID AND IsDeleted<>1)
		   BEGIN
		   INSERT INTO #TempProjectScope(IsDevelopment,ProjectID) VALUES (1,@ProjectID)
		   END
		ELSE
		   BEGIN
		    INSERT INTO #TempProjectScope(IsDevelopment,ProjectID) VALUES (0,@ProjectID)
		    END

			IF EXISTS (SELECT ProjectID FROM [AVL].[MAP_ProjectConfig] WHERE ProjectID = @ProjectID)
		    BEGIN 
			SELECT 
			ISNULL(SupportTypeId,0)  AS SupportTypeID, 			
			CASE WHEN COUNT(APM.ApplicationID)>0 THEN 1 ELSE 0 END AS AppSuppDisabled,
			CASE WHEN COUNT(TPM.TowerProjMapId)>0 
			THEN 1 ELSE 0 END
			 as InfraSuppDisabled ,
			 ISNULL(TMP.IsDevelopment,0) AS 'IsDevelopment'
			 FROM [AVL].[MAP_ProjectConfig] PC
			left JOIN AVL.APP_MAP_ApplicationProjectMapping APM on APM.ProjectID = pc.ProjectID and APM.IsDeleted = 0
			LEFT JOIN AVL.InfraTowerProjectMapping TPM ON TPM.ProjectID=PC.ProjectID AND TPM.IsDeleted=0 AND TPM.IsEnabled=1
			LEFT JOIN #TempProjectScope TMP ON TMP.ProjectID=@ProjectID
			WHERE PC.ProjectID = @ProjectID 
			GROUP by PC.SupportTypeId
			,TMP.IsDevelopment
			END

			ELSE
			BEGIN
			Select 0 as SupportTypeID,0 as AppSuppDisabled,0 as InfraSuppDisabled,0 AS IsDevelopment
			END

		DROP TABLE #TempProjectScope

END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError ' [AVL].[GetSupportType]', @ErrorMessage, @ProjectID, '0' 
		
	END CATCH  

END
