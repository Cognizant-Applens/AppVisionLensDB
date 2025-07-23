CREATE TABLE [AVL].[Heal_EffortConfigureState] (
    [HealTypeId]       INT             IDENTITY (1, 1) NOT NULL,
    [HealType]         VARCHAR (50)    NULL,
    [HealValue]        DECIMAL (25, 2) NULL,
    [HealMasterId]     INT             NULL,
    [IsDeleted]        VARCHAR (50)    NULL,
    [ProjectID]        INT             NULL,
    [ModifiedBY]       VARCHAR (50)    NULL,
    [LastModifiedDate] DATETIME        NULL,
    [CreatedBY]        VARCHAR (50)    NULL,
    [CreateDateTime]   DATETIME        NULL,
    [IsAppOrInfra]     SMALLINT        CONSTRAINT [DF_Heal_EffortConfigureState_IsAppOrInfra] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Heal_EffortConfigureState] PRIMARY KEY CLUSTERED ([HealTypeId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NMISP14.3.1_Heal_EffortConfigureState_HealMasterId]
    ON [AVL].[Heal_EffortConfigureState]([HealMasterId] ASC, [ProjectID] ASC, [IsAppOrInfra] ASC);


GO
CREATE NONCLUSTERED INDEX [NMISP14.3_Heal_EffortConfigureState_ProjectID]
    ON [AVL].[Heal_EffortConfigureState]([ProjectID] ASC);

