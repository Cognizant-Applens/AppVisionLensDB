CREATE PROCEDURE [dbo].[InsertGeoMapping]
@InsertGeodata [dbo].[TVP_GeoMapping] readonly
AS
BEGIN
 	SET NOCOUNT ON  

BEGIN TRY 
CREATE TABLE #tempmap
(Id int identity (1,1),
ESA_AccountID varchar(20),
SBU_Delivery varchar(100),
Client_Practice  varchar(100))

insert into  #tempMap (ESA_AccountID,SBU_Delivery, Client_Practice)

select TEM.ESA_AccountID,TEM.SBU_Delivery, TEM.Client_Practice
FROM @InsertGeodata TEM
INNER JOIN [AVL].[Customer] CAM ON LTRIM(RTRIM(CAM.ESA_AccountID))=LTRIM(RTRIM(TEM.ESA_AccountID))
WHERE  CAM.IsDeleted = 0 AND TEM.SBU_Delivery IS NOT NULL AND TEM.SBU_Delivery !=''

--select * into #tempGeoMapping FROM (
--select ESA_AccountID,SBU_Delivery,Client_Practice FROM 
--(select ESA_AccountID,SBU_Delivery,Client_Practice,row_number() over ( partition by ESA_AccountID order by ID desc) as rn
--FROM #tempmap) AS #geotemp
--WHERE rn = 1) AS #tempGeoMapping

--MERGE [dbo].[GeoMapping] bi
--		USING #tempMap bo
--		ON LTRIM(RTRIM(bi.ESA_AccountID)) = LTRIM(RTRIM(bo.ESA_AccountID)) AND BI.IsDeleted = 0
--		WHEN MATCHED THEN
--		UPDATE
--		SET 
--		bi.SBU_Delivery=LTRIM(RTRIM(bo.SBU_Delivery)),bi.Client_Practice=LTRIM(RTRIM(bo.Client_Practice)),bi.ModifiedBy='System',bi.ModifiedDate=GETDATE()
--		WHEN NOT MATCHED BY TARGET THEN
--		INSERT (ESA_AccountID,SBU_Delivery,Client_Practice)
--		VALUES (bo.ESA_AccountID,bo.SBU_Delivery,bo.Client_Practice);

--DROP TABLE [#tempGeoMapping]

TRUNCATE TABLE dbo.GeoMapping

INSERT INTO dbo.GeoMapping (ESA_AccountID,SBU_Delivery,Client_Practice)
SELECT ESA_AccountID,SBU_Delivery,Client_Practice FROM #tempMap

DROP TABLE [#tempMap]

END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[InsertGeoMapping]', @ErrorMessage, '',0
END CATCH 

END