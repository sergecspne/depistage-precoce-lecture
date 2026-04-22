-- =============================================================================
-- Requête 1 : Hiver & Printemps combinés
-- Les entrées où le bulletin devrait être coché "O" mais ne l'est pas
-- =============================================================================
WITH ctx AS (
    SELECT
        CTX_START_DATE,
        DATEFROMPARTS(YEAR(CTX_START_DATE), 12, 31) AS hiver_fin
    FROM [DISTRICT_SCHOOL_YEAR_CONTEXT]
    WHERE CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM [ORGANIZATION])
)
SELECT
    SKL_SCHOOL_ID        AS [école],
    ASM_GRADE_LEVEL_CODE AS [niveau],
    ASM_STD_OID          AS [STD_OID],
    STD_NAME_VIEW        AS [élève],
    ASM_DATE             AS [date],
    ASM_FIELDA_001       AS [complète],        -- 0 = Non, 1 = Oui, 2 = S.O.
    ASM_FIELDA_002       AS [norme_atteinte],  -- 0 = Non, 1 = Oui
    ASM_FIELDA_072       AS [hiver],           -- 0 = Non, 1 = Oui
    ASM_FIELDA_073       AS [printemps],       -- 0 = Non, 1 = Oui
    CASE
        WHEN ASM_DATE <= ctx.hiver_fin THEN 'Hiver'
        ELSE 'Printemps'
    END                  AS [période]
FROM [STUDENT_ASSESSMENT]
    INNER JOIN [STUDENT] ON ASM_STD_OID = STD_OID
    INNER JOIN [SCHOOL]  ON ASM_SKL_OID = SKL_OID
    CROSS JOIN ctx
WHERE ASM_DATE >= ctx.CTX_START_DATE
    AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
    AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
    AND ASM_FIELDA_001 IS NOT NULL
    AND (
        -- Hiver : bulletin hiver devrait être coché "O" mais ne l'est pas (Sept 1 – Dec 31)
        (ASM_DATE <= ctx.hiver_fin AND ISNULL(ASM_FIELDA_072, '0') <> '1')
        OR
        -- Printemps : bulletin printemps devrait être coché "O" mais ne l'est pas (Jan 1+)
        (ASM_DATE > ctx.hiver_fin AND ISNULL(ASM_FIELDA_073, '0') <> '1')
    )
ORDER BY SKL_SCHOOL_ID, ASM_GRADE_LEVEL_CODE, STD_NAME_VIEW;
