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
-- Author      : Shankar Ganesh V
-- Create date : May 25, 2020
-- Description : Get the Project based Best Practice detail       
-- Revision    :
-- Revised By  :
-- =========================================================================================
-- [PP].[GetBestPracticeDetail] 10337
CREATE PROCEDURE [PP].[GetBestPracticeDetail] --'10337'
@ProjectID BIGINT
AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;
			
			--GET THE ATTRIBUTES FOR THE UI ENABLE DISABLE (RequirementsCaptured,IsRequirementsBaselined,External KEDB Tool,IsScopeChangeControlPlaced,HowAreServicesIntegrated,StatusReport) 
			SELECT  AttributeID
				   ,AttributeName
				   ,SourceID
				   ,ScopeID
				   ,IsPrepopulate
				   ,IsCognizant	
				   ,IsMandatory
					FROM MAS.PPAttributes(NOLOCK) PPA 
					WHERE PPA.IsDeleted = 0 and AttributeName in ('RequirementsCaptured','IsRequirementsBaselined','DoYouOwnKEDB?','IsScopeChangeControlPlaced','HowAreServicesIntegrated','StatusReport')
			
			--GET ALL THE ATTRIBUTE VALUES (RequirementsCaptured,IsRequirementsBaselined,External KEDB Tool,IsScopeChangeControlPlaced,HowAreServicesIntegrated,StatusReport) 
			SELECT  AttributeValueID
                   ,AttributeValueName
                   ,PPAV.AttributeID 
                    FROM mas.PPAttributeValues(NOLOCK) PPAV
					INNER JOIN mas.PPAttributes PPA ON PPA.AttributeID = PPAV.AttributeID
					WHERE PPAV.IsDeleted = 0 and PPA.AttributeName in ('RequirementsCaptured','RequirementsStored','DoYouOwnKEDB?','IsScopeChangeControlPlaced','HowAreServicesIntegrated','StatusReport')
					ORDER BY PPAV.AttributeID,AttributeValueID

			--GET ALL ATTRIBUTE VALUES SAVED FOR BEST PRACTICE AGAINST THE PROJECT
			
			SELECT pav.ProjectID,pav.AttributeID,pa.AttributeName,pav.AttributeValueID as AttributeValue,pv.AttributeValueName
			FROM [PP].[ProjectAttributeValues] pav
			INNER JOIN MAS.PPAttributes pa ON pa.AttributeID = pav.AttributeID
			INNER JOIN mas.PPAttributeValues pv ON pv.AttributeValueID = pav.AttributeValueID
			WHERE pav.ProjectID=@ProjectID AND pav.IsDeleted = 0  and pv.IsDeleted = 0 and pa.AttributeName in ('RequirementsCaptured','RequirementsStored')


			--GET OTHER FIELD VALUES BASED ON PROJECTID
			
			select OT.AttributeValueID,OT.OtherFieldValue  from pp.OtherAttributeValues ot
			inner join mas.PPAttributeValues pv on pv.AttributeValueID = ot.AttributeValueID
			inner join mas.PPAttributes PPA ON PPA.AttributeID = pv.AttributeID
			where ot.ProjectID=@ProjectID and ot.IsDeleted=0 
			
			

			--GET  BEST PRACTICE DETAILS BASED ON PROJECTID  (Class 'BestPracticeDetails' is used for this)
			SELECT 
			 BP.KEDBOwnedId
			,BP.ExternalKEDB
			,BP.IsApplensAsKEDB
			,BP.IsReqBaselined
			,BP.IsAcceptanceDefined
			,BP.ScopeChangeControlId
			,BP.IsVelocityMeasured
			,BP.UOM
			,BP.IsDevOrMainByCog
			,BP.IntegratedServiceId
			,BP.StatusReportId
			,BP.ExplicitRisks			
			FROM PP.BestPractices BP 
			WHERE BP.ProjectID = @ProjectID and BP.IsDeleted =0

	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[GetBestPracticeDetail]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
