CREATE Proc [AVL].[KEDB_GetKTicketCancelOptions]
AS
BEGIN
SELECT OptionID,OptionName FROM [AVL].[MAS_KTicketCancelOptions]
WHERE Isdeleted=0
END
