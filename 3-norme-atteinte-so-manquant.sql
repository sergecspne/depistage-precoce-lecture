-- =============================================================================
-- Requête 3 : Norme atteinte lors de la première évaluation (Hiver)
-- et n'a pas un S.O. lors de la deuxième évaluation (Printemps)
-- =============================================================================
WITH ctx AS (
    SELECT
        CTX_START_DATE,
        DATEFROMPARTS(YEAR(CTX_START_DATE), 12, 31) AS hiver_fin
    FROM [DISTRICT_SCHOOL_YEAR_CONTEXT]
    WHERE CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM [ORGANIZATION])
),
depistage AS (
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
        ctx.hiver_fin
    FROM [STUDENT_ASSESSMENT]
        INNER JOIN [STUDENT] ON ASM_STD_OID = STD_OID
        INNER JOIN [SCHOOL]  ON ASM_SKL_OID = SKL_OID
        CROSS JOIN ctx
    WHERE ASM_DATE >= ctx.CTX_START_DATE
        AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
        AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
)
SELECT
    [école], [niveau], [STD_OID], [élève], [date], [complète], [norme_atteinte], [hiver], [printemps]
FROM depistage AS d
WHERE d.[complète] <> '2'
    AND d.[date] > d.hiver_fin -- Évaluation Printemps
    AND EXISTS (
        SELECT 1 FROM depistage AS hiver_eval
        WHERE hiver_eval.STD_OID = d.STD_OID
            AND hiver_eval.[date] <= hiver_eval.hiver_fin -- Évaluation Hiver
            AND hiver_eval.[norme_atteinte] = '1'
    )
ORDER BY [école], [niveau], [élève];
