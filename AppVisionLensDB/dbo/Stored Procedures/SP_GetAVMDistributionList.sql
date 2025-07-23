CREATE PROCEDURE [dbo].[SP_GetAVMDistributionList]

AS

BEGIN

BEGIN TRY
SET NOCOUNT ON;
---To Get Associate details from CRS view

SELECT DISTINCT Associate_ID INTO #AVM_Associate from [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].[vw_CentralRepository_Associate_Details] A

join [CTSINTBMVPCRSR1].[CentralRepository_Report].[dbo].vw_CentralRepository_Department B on A.Dept_ID=B.Dept_ID

where  Dept_Desc like '%AVM%' and IsActive='A' ORDER BY Associate_ID


---To ADD Access to DL

SELECT DISTINCT Associate_ID INTO #AVM_Associate_Add FROM #AVM_Associate where Associate_ID NOT IN
(SELECT DISTINCT AssociateId FROM InsertDistributionList(NOLOCK))

INSERT INTO InsertDistributionList(AssociateId,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
SELECT Associate_ID,400433,GETDATE(),NULL,NULL FROM #AVM_Associate_Add

SELECT Associate_ID FROM #AVM_Associate_Add

---To Revoke Access to DL

SELECT DISTINCT AssociateId INTO #AVM_Associate_Revoke FROM InsertDistributionList(NOLOCK) where AssociateId NOT IN
(SELECT DISTINCT Associate_ID FROM #AVM_Associate) 

--SELECT AssociateId FROM #AVM_Associate_Revoke

--DELETE FROM InsertDistributionList WHERE AssociateId IN
--(SELECT DISTINCT AssociateId FROM #AVM_Associate_Revoke)

DROP TABLE #AVM_Associate
DROP TABLE #AVM_Associate_Add
DROP TABLE #AVM_Associate_Revoke

END TRY

BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    

		EXEC AVL_InsertError '[dbo].[SP_GetAVMDistributionList]', @ErrorMessage, 'DL_Addition_Job',0		

	END CATCH  

END