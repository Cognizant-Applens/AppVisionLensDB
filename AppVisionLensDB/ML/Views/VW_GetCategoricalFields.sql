
CREATE VIEW [ML].[VW_GetCategoricalFields]    
AS            
 select CTG.MLTransactionid,FLM.FieldMappingId,    
 CASE     
 WHEN FLM.ITSMColumn = 'Assignment Group' THEN 'AssignmentGroup'     
 WHEN FLM.ITSMColumn = 'Resolution Remarks' THEN 'ResolutionRemarks'    
 WHEN FLM.ITSMColumn = 'Cause Code' THEN 'CauseCodeMapID'     
 WHEN FLM.ITSMColumn = 'KEDB Available Indicator' THEN 'KEDBAvailableIndicatorMapID'     
 WHEN FLM.ITSMColumn = 'Release Type' THEN 'ReleaseTypeMapID'     
 WHEN FLM.ITSMColumn = 'Ticket Source' THEN 'TicketSourceMapID'     
 WHEN FLM.ITSMColumn = 'Ticket Type' THEN 'TicketTypeMapID'     
 WHEN FLM.ITSMColumn = 'Resolution Code' THEN 'ResolutionCodeMapID'     
 ELSE FLM.ITSMColumn     
 END AS ITSMColumn    
 FROM [ML].[TRN_TransactionCategorical] CTG inner join ml.trn_mltransaction TRN ON CTG.MLtransactionid = TRN.transactionid     
 inner join MAS.ML_Prerequisite_FieldMapping FLM ON CTG.categoricalfieldid = FLM.FieldMappingId    
 WHERE CTG.Isdeleted = 0 AND TRN.Isdeleted = 0 AND FLM.Isdeleted = 0
