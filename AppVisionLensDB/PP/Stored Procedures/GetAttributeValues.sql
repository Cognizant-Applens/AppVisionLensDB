CREATE Procedure [PP].[GetAttributeValues]
(
@Tvp_Attributes as [PP].[TVP_AttributeNames] Readonly
)

AS BEGIN


Select PAV.AttributeValueID as Id,
       PAV.AttributeValueName as [Name],
	   CASE WHEN PAV.ParentId is not null THEN PAV1.AttributeValueName ELSE PA.AttributeName END as [ParentKey]
	   FROM MAS.PPAttributeValues PAV 
	   INNER JOIN MAS.PPAttributes PA ON PAV.AttributeID = PA.AttributeID AND PA.IsDeleted=0 AND PAV.IsDeleted=0
	   LEFT JOIN  MAS.PPAttributeValues PAV1 ON PAV1.AttributeValueID = PAV.ParentID
	   INNER JOIN @Tvp_Attributes tvp ON tvp.AttributeName = PA.AttributeName

END
