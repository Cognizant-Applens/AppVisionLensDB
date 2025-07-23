/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [AVL].[Effort_GetApplicationDetails_DD]  25758,75008,16233



CREATE PROCEDURE [AVL].[Effort_GetApplicationDetails_DD] 



(        



@projectid VARCHAR(200),



@ApplicationID int,



@PortfolioID int



 )        



AS        



BEGIN     



BEGIN TRY   



SET NOCOUNT ON;     







BEGIN    



DECLARE @CustomerID INT;



DECLARE @IsCognizantID INT;



SET @CustomerID=(SELECT top 1 CustomerID FROM [AVL].[MAS_ProjectMaster] WHERE ProjectId=@projectid AND IsDeleted=0)



SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)



print @IsCognizantID



IF @IsCognizantID=1



	BEGIN



		IF EXISTS(SELECT ID from [AVL].[Debt_MAS_ProjectDataDictionary] where ProjectID = @ProjectID and ApplicationID = @ApplicationID)



			BEGIN



				SELECT DISTINCT APM.ApplicationID,ApplicationName    



				  FROM AVL.APP_MAS_ApplicationDetails AD 



                  JOIN AVL.BusinessClusterMapping BS ON AD.SubBusinessClusterMapID=BS.BusinessClusterMapID



		          JOIN AVL.APP_MAP_ApplicationProjectMapping APM  ON APM.ApplicationID = AD.ApplicationID



				  WHERE APM.ProjectID=@projectid AND APM.IsDeleted=0 AND BS.IsDeleted=0 AND AD.IsActive=1



				   



				--FROM [AVL].[APP_MAP_ApplicationProjectMapping]



				--APM JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON  APM.ApplicationID=AD.ApplicationId 



				--where ProjectID=@projectid AND APM.IsDeleted=0



				----and AD.ApplicationID = @ApplicationID and ad.SubBusinessClusterMapID = @PortfolioID  AND APM.IsDeleted=0



			END



		ELSE



			BEGIN



				



				SELECT DISTINCT APM.ApplicationID,ApplicationName   



				into #temp_co



				  FROM AVL.APP_MAS_ApplicationDetails AD 



                  JOIN AVL.BusinessClusterMapping BS ON AD.SubBusinessClusterMapID=BS.BusinessClusterMapID



		          JOIN AVL.APP_MAP_ApplicationProjectMapping APM  ON APM.ApplicationID = AD.ApplicationID



				  WHERE APM.ProjectID=@projectid AND APM.IsDeleted=0 AND BS.IsDeleted=0 AND AD.IsActive=1







				--SELECT DISTINCT APM.ApplicationID,ApplicationName 



				--into #temp_co     



				--FROM [AVL].[APP_MAP_ApplicationProjectMapping]



				--APM JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON  APM.ApplicationID=AD.ApplicationId 



				--where ProjectID=@projectid  AND APM.IsDeleted=0



			----	and AD.ApplicationID = @ApplicationID and ad.SubBusinessClusterMapID = @PortfolioID  AND APM.IsDeleted=0



				INSERT into #temp_co VALUES('','ALL')







				select * from  #temp_co







			END



	 END



 ELSE



	 BEGIN



	 IF EXISTS(SELECT ID from [AVL].[Debt_MAS_ProjectDataDictionary] where ProjectID = @ProjectID and ApplicationID = @ApplicationID)



		BEGIN







		SELECT DISTINCT APM.ApplicationID,ApplicationName    



				  FROM AVL.APP_MAS_ApplicationDetails AD 



                  JOIN AVL.BusinessClusterMapping BS ON AD.SubBusinessClusterMapID=BS.BusinessClusterMapID



		          JOIN AVL.APP_MAP_ApplicationProjectMapping APM  ON APM.ApplicationID = AD.ApplicationID



				  WHERE APM.ProjectID=@projectid AND APM.IsDeleted=0 AND BS.IsDeleted=0 AND AD.IsActive=1







			--SELECT distinct AD.ApplicationID,AD.ApplicationName



			-- FROM [AVL].[APP_MAS_ApplicationDetails] AD



			--INNER JOIN AVL.BusinessClusterMapping BCM



			--ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0



			--WHERE BCM.CustomerID=@CustomerID and ad.IsActive=1







		--	--and AD.ApplicationID = @ApplicationID and ad.SubBusinessClusterMapID = @PortfolioID and ad.IsActive=1



		END



	ELSE



		BEGIN







		SELECT DISTINCT APM.ApplicationID,ApplicationName   



				 into #temp_cc



				  FROM AVL.APP_MAS_ApplicationDetails AD 



                  JOIN AVL.BusinessClusterMapping BS ON AD.SubBusinessClusterMapID=BS.BusinessClusterMapID



		          JOIN AVL.APP_MAP_ApplicationProjectMapping APM  ON APM.ApplicationID = AD.ApplicationID



				  WHERE APM.ProjectID=@projectid AND APM.IsDeleted=0 AND BS.IsDeleted=0 AND AD.IsActive=1







			--SELECT distinct AD.ApplicationID,AD.ApplicationName 



			--into #temp_cc



			--FROM [AVL].[APP_MAS_ApplicationDetails] AD



			--INNER JOIN AVL.BusinessClusterMapping BCM



			--ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0



			--WHERE BCM.CustomerID=@CustomerID and ad.IsActive=1











			----and AD.ApplicationID = @ApplicationID and ad.SubBusinessClusterMapID = @PortfolioID and ad.IsActive=1



			



			INSERT into #temp_cc VALUES('','ALL')



			



			select * from  #temp_cc



		END



	 END







END  



SET NOCOUNT OFF;        



END TRY  



BEGIN CATCH  







		DECLARE @ErrorMessage VARCHAR(MAX);







		SELECT @ErrorMessage = ERROR_MESSAGE()







		--INSERT Error    



		EXEC AVL_InsertError '[AVL].[Effort_GetApplicationDetails] ', @ErrorMessage, @projectid ,0



		



	END CATCH   



END
