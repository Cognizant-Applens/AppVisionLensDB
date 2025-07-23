/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetUCBUDetails]
	@ID NVARCHAR(50),
	@Text NVARCHAR(100),
	@DropFlag VARCHAR(20)
AS
BEGIN
BEGIN TRY	
	SET NOCOUNT ON;

	DECLARE @IsDeleted INT = 0

	--FETCH BU details
	IF(@DropFlag='BU')
		BEGIN
				SELECT DISTINCT B.BUID AS ID,C.BUName AS [Name] FROM
				ESA.ProjectAssociates A
				JOIN ESA.BUAccounts B ON A.ACCOUNT_ID=B.AccountID
				JOIN ESA.BusinessUnits C ON B.BUID=C.BUID
				WHERE A.AssociateID=@ID ORDER BY BUName
		END
	ELSE IF (@DropFlag = 'Account')
		BEGIN			
				SELECT CS.CustomerID AS ID,CS.CustomerName AS [Name] FROM
				ESA.ProjectAssociates A
				JOIN ESA.BUAccounts B ON A.ACCOUNT_ID=B.AccountID
				JOIN ESA.BusinessUnits C ON B.BUID=C.BUID
				JOIN [ESA].[BUAccounts]  BUA ON BUA.BUID = B.BUID AND BUA.IsActive = 1 
				JOIN AVL.Customer CS ON CS.BUID = BUA.BUID AND CS.ESA_AccountID = BUA.AccountID
				AND A.ACCOUNT_ID = CS.ESA_AccountID AND  CS.IsDeleted = @IsDeleted
				WHERE A.AssociateID=@ID AND BUA.BUID = @Text ORDER BY CustomerName

		END
	ELSE IF (@DropFlag = 'APP')
		BEGIN
			SELECT DISTINCT
				AL.ApplicationID AS ID,
				AL.ApplicationName AS [Name]
			FROM 
				AVL.APP_MAS_ApplicationDetails AL WITH(NOLOCK) 
				JOIN AVL.BusinessClusterMapping BS WITH(NOLOCK)
				ON AL.SubBusinessClusterMapID=bs.BusinessClusterMapID 
				AND CAST(BS.CustomerID AS VARCHAR(50))=@ID --AND BS.IsHavingSubBusinesss = 0
				AND AL.IsActive = 1 AND BS.IsDeleted = @IsDeleted ORDER BY ApplicationName;
		END
	ELSE IF (@DropFlag = 'TECH')
		BEGIN			
			SELECT DISTINCT 
				PrimaryTechnologyID  AS ID,
				PrimaryTechnologyName AS [Name]
			FROM AVL.APP_MAS_PrimaryTechnology(NOLOCK)
			WHERE	IsDeleted = @IsDeleted ORDER BY PrimaryTechnologyName
		END
	ELSE IF (@DropFlag = 'BP')
		BEGIN
			SELECT DISTINCT
				BPM.BusinessProcessId AS ID,
				BPM.BusinessProcessName AS [Name]
			FROM 
				BusinessOutCome.[MAP].[BUServiceTracks] BST
				JOIN BusinessOutCome.[MAS].[LOBMaster] LM ON BST.ServiceTrackID = LM.ServiceTrackID
				JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM ON BPM.LobId = LM.LOBId
			WHERE LM.IsActive = 1 AND BPM.IsActive = 1 AND BPM.BusinessProcessParentId IS NULL
			AND CAST(BST.BUID AS VARCHAR(10)) = @ID
			and LM.IsDecommisioned = 0
			ORDER BY BPM.BusinessProcessName
		END
	ELSE IF (@DropFlag = 'SBP')
		BEGIN
		--@Id --BUISNESSPROCESSID
			SELECT DISTINCT
                    MP.BusinessProcessId AS ID,
                    MP.BusinessProcessName AS [Name]
            FROM 
                    BusinessOutCome.[MAP].[BUServiceTracks] BST
                    JOIN BusinessOutCome.[MAS].[LOBMaster] LM ON BST.ServiceTrackID = LM.ServiceTrackID
                    JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM ON BPM.LobId = LM.LOBId
                   LEFT JOIN BusinessOutCome.mas.BusinessProcessMaster MP ON mp.BusinessProcessParentId = bpm.BusinessProcessId                        
            WHERE LM.IsActive = 1 AND BPM.IsActive = 1 and mp.IsActive = 1
                    AND MP.BusinessProcessParentId = @ID   
            ORDER BY MP.BusinessProcessName

		END
		ELSE IF (@DropFlag = 'TOOL')
		BEGIN
			SELECT SolutionTypeID AS ID,
			SolutionTypeName AS [Name]
			FROM avl.TK_MAS_SolutionType WHERE IsDeleted=0 ORDER BY SolutionTypeName
		END
		ELSE IF (@DropFlag = 'CATEGORY')
		BEGIN
			SELECT ServiceID AS ID,
			ServiceName AS [Name]
			FROM avl.TK_MAS_Service WHERE IsDeleted=0 ORDER BY ServiceName
		END
		ELSE IF (@DropFlag = 'SUPPORT')
		BEGIN
			SELECT ServiceLevelID AS ID ,
			ServiceLevelName AS [Name]
			FROM avl.MAS_ServiceLevel WHERE IsDeleted=0 AND ServiceLevelID NOT IN (6) ORDER BY ServiceLevelName
		END
END TRY

BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'AVL.GetUCBUDetails',@ErrorMessage,'system',GETDATE())
	
END CATCH

END
