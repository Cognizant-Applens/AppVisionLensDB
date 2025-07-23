


CREATE PROCEDURE [BCS].[GetBriefcaseSolutionDetails]
@userId nvarchar(50),
@solutionName nvarchar(100),
@projectID int
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
SELECT top(1) [UserId],B.[SolutionName],[LicenseKey],[LicenseKeyExpiryDate],A.ESAProjectID FROM [BCS].[BriefcaseSolutionDetails] A (NOLOCK)
join [BCS].[SolutionMaster] B (NOLOCK) on A.SolutionId = B.Id  WHERE A.UserId = @userId AND B.SolutionName = @solutionName
AND A.ESAProjectID =@projectID ORDER BY
A.[CreatedDate] DESC
SET NOCOUNT OFF;
END TRY
BEGIN CATCH
DECLARE @errorMessage VARCHAR(MAX);

		SELECT @errorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[BCS].[GetBriefcaseSolutionDetails]',@errorMessage,'',0
END CATCH
END
