CREATE TABLE [BM].[SubOfferingMapping] (
    [Sub_offeringID] INT             NOT NULL,
    [ServiceId]      INT             NOT NULL,
    [Sub_Offering]   VARCHAR (80)    NOT NULL,
    [Min_Effort]     DECIMAL (18, 2) NOT NULL,
    [Max_Effort]     DECIMAL (18, 2) NOT NULL,
    [EffectiveDate]  DATETIME        NOT NULL,
    [CreatedBy]      VARCHAR (80)    NOT NULL,
    [CreatedDate]    DATETIME        NOT NULL
);

