/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure PP.GetITSMSupportTypeID
(
@ProjectID INT
)
AS
BEGIN

		DECLARE @IsApp int=0
		DECLARE @AppScopecount int
		DECLARE @AppScope int
		DECLARE @AttributevalueScope int

		SET @AppScopecount = (SELECT COUNT( DISTINCT AttributeValueID) 
		FROM PP.ProjectAttributeValues 
		WHERE ProjectID=@ProjectID AND AttributeID=1 and IsDeleted=0 )

		IF(@AppScopecount = 4)
		BEGIN
				SET @IsApp=3;--IF BOTH MAINTANANCE & CIS HAD BEEN SELECTED
		END
		ELSE IF (@AppScopecount = 1)
		BEGIN
				SELECT @IsApp = CASE 
                   WHEN  AttributeValueID = 2 THEN 1
				   WHEN  AttributeValueID = 3 THEN 2
				WHEN AttributeValueID = 1  THEN 1
				WHEN AttributeValueID = 4  THEN 1	
				END
				FROM PP.ProjectAttributeValues  WHERE ProjectID=@ProjectID and AttributeID=1   and IsDeleted=0  
		END		 

		ELSE IF (@AppScopecount = 3)
		BEGIN		
				IF EXISTS (SELECT top 1 1 FROM PP.ProjectAttributeValues
						JOIN (
						SELECT count(AttributeValueID) as cnt FROM PP.ProjectAttributeValues
						WHERE ProjectID=@ProjectID and AttributeID=1  
						AND IsDeleted=0  and AttributeValueID in (1,2,4))AS C 
						ON c.cnt=3)	
				BEGIN 
						SET @IsApp=1
				END 
				ELSE IF EXISTS (SELECT top 1 1 FROM PP.ProjectAttributeValues
						JOIN (
						SELECT count(AttributeValueID) as cnt FROM PP.ProjectAttributeValues
						WHERE ProjectID=@ProjectID and AttributeID=1  
						AND IsDeleted=0  and AttributeValueID in (1,3,4))AS C 
						ON c.cnt=3)
                BEGIN
                    SET @IsApp=2
           
				END
                ELSE
                BEGIN
                    SET @IsApp=3
                END
					 
		END
		ELSE IF ( @AppScopecount = 2)
		BEGIN		
				IF EXISTS (SELECT top 1 1 FROM PP.ProjectAttributeValues
					join (
					select count(AttributeValueID) as cnt FROM PP.ProjectAttributeValues
					WHERE ProjectID=@ProjectID and AttributeID=1  
					and IsDeleted=0  and AttributeValueID in (2,3))AS C 
					ON c.cnt=2)	
				BEGIN 
						SET @IsApp=3
				END 
				ELSE IF EXISTS (SELECT top 1 1 FROM PP.ProjectAttributeValues
							WHERE ProjectID=@ProjectID and AttributeID=1  
						and IsDeleted=0  and AttributeValueID in (3))
                BEGIN
						SET @IsApp=2           
				END				
                ELSE
                BEGIN
						SET @IsApp=1
                END					 
		END

		ELSE
		BEGIN
			SET @IsApp = 0 
		
		END

		IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results

		CREATE TABLE #Results
		(
		Scope BIGINT NULL)
		insert into #Results  select @IsApp 
		select Scope from #Results
END
