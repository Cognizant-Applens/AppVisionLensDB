/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SaveCauseCodeMapingDetails]  
    @Mode NVARCHAR(100),     
    @ProjectId BIGINT,
	@ResolutionMapIds [AVL].[SaveCauseCodeMapping] READONLY,
	@CreatedBy NVARCHAR(100)	       
AS         
BEGIN
BEGIN TRY                   
SET NOCOUNT ON;   

DECLARE @CauseCodeMap TABLE
(
    [ProjectID] BIGINT,
	CauseCodeId BIGINT,
	ResolutionCodeId NVARCHAR(MAX),
	[Source] NVARCHAR(50)
) 
IF @Mode = 'DD'
	BEGIN
		INSERT INTO @CauseCodeMap
		(ProjectID,CauseCodeId,ResolutionCodeId,[Source])
		SELECT @ProjectId,CauseID,ResolutionId,@Mode FROM @ResolutionMapIds
	END
ELSE
	BEGIN
		INSERT INTO @CauseCodeMap
		(ProjectID,CauseCodeId,ResolutionCodeId,[Source])
		SELECT @ProjectId,CauseID,LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS ResolutionId,@Mode
		FROM 
		( 
		SELECT CauseID,CAST('<XMLRoot><RowData>' + REPLACE(ResolutionId,',','</RowData><RowData>') + 
		'</RowData></XMLRoot>' AS XML) AS x 
		FROM @ResolutionMapIds
		 )t 
		CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)


			DECLARE @Count INT,@i INT=1
	SELECT @Count=Count(CauseCodeId) FROM @CauseCodeMap 

	UPDATE A SET A.IsDeleted=1,A.ModifiedBy=@CreatedBy,A.ModifiedDate=GETDATE() from AVL.CauseCodeResolutionCodeMapping A JOIN
	@CauseCodeMap B ON A.CauseCodeMapID=B.CauseCodeId AND A.ProjectID=B.ProjectID
	END



	MERGE AVL.CauseCodeResolutionCodeMapping AS TAR
	USING @CauseCodeMap AS SRC 
	ON (TAR.CauseCodeMapID = SRC.CauseCodeId AND TAR.ResolutionCodeMapID=SRC.ResolutionCodeId 
	AND TAR.ProjectID=SRC.ProjectID) 
	--When records are matched, update the records if there is any change
	WHEN MATCHED  
	THEN UPDATE SET TAR.IsDeleted=0,TAR.ModifiedBy=@CreatedBy,TAR.ModifiedDate=GETDATE()
	--When no records are matched, insert the incoming records from source table to target table
	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (ProjectID,CauseCodeMapID,ResolutionCodeMapID,[Source],IsDeleted,CreatedBy,CreatedDate) VALUES
	(SRC.ProjectID,SRC.CauseCodeId,SRC.ResolutionCodeId,SRC.Source,0,@CreatedBy,GETDATE());

SET NOCOUNT OFF;  
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);  
		SELECT @ErrorMessage = ERROR_MESSAGE()  
		EXEC AVL_InsertError '[AVL].[SaveCauseCodeMapping]', @ErrorMessage, 0,0  
END CATCH  
END
