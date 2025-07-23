CREATE PROCEDURE [MS].[SaveProjectBaseMeasures]
	@ProjectID INT,
	@UserID NVARCHAR(100)=NULL,
	@Basemeasuredata MS.BaseMeasureData_TVP READONLY
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;

	Update OBD set OBD.BaseMeasureValue=BD.BaseMeasureValue,OBD.ModifiedBy=@UserID,OBD.ModifiedDate=GETDATE()
	FROM MS.ProjectOutBoundEformData OBD 
	INNER JOIN MS.ServiceMetricBaseMeasureMapping (NOLOCK) SMD 
	ON OBD.ServiceMetricBaseMeasureId  = SMD.ServiceMetricBaseMeasureId AND SMD.isdeleted=0 AND OBD.ISDELETED=0
	Inner join @Basemeasuredata BD 
	ON BD.ServiceId =SMD.Serviceid AND BD.BaseMeasureId = SMD.BaseMeasureID 
	WHERE 
	OBD.ProjectID=@ProjectID  AND BD.BaseMeasureValue IS NOT NULL
	
	SELECT 'true' as Result
SET NOCOUNT OFF;   
COMMIT TRAN
END TRY  
BEGIN CATCH   
		SELECT 'false' as Result
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[MS].[SaveProjectBaseMeasures]', @ErrorMessage, @UserID
	END CATCH  

	END

