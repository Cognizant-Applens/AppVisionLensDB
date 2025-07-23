CREATE TYPE [AVL].[TVP_BMSubOfferingMapping] AS TABLE (
    [Sub_offeringID] INT          NOT NULL,
    [ServiceId]      INT          NOT NULL,
    [Sub_Offering]   VARCHAR (80) NOT NULL);

