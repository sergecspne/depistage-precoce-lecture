
-- Requête Hiver - Les entrées où le bulletin hiver devrait être coché "O" mais ne l'est pas
	SELECT
		SKL_SCHOOL_ID AS [ecole],
		ASM_GRADE_LEVEL_CODE AS [niveau],
		ASM_STD_OID AS [STD_OID],
		STD_NAME_VIEW AS [eleve], -- nom de l'eleve
		ASM_DATE AS [date],
		ASM_FIELDA_001 AS [complete], -- 0 = Non, 1 = Oui, 2 = S.O.
		ASM_FIELDA_002 AS [norme_atteinte], -- 0 = Non, 1 = Oui
		ASM_FIELDA_072 AS [hiver], -- 0 = Non, 1 = Oui
		ASM_FIELDA_073 AS [printemps] -- 0 = Non, 1 = Oui
	FROM STUDENT_ASSESSMENT
		INNER JOIN STUDENT AS STD ON ASM_STD_OID = STD_OID
		INNER JOIN SCHOOL ON ASM_SKL_OID = SKL_OID
		INNER JOIN DISTRICT_SCHOOL_YEAR_CONTEXT AS ctx ON ctx.CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM ORGANIZATION)
	WHERE ASM_DATE BETWEEN ctx.CTX_START_DATE AND DATEFROMPARTS(YEAR(ctx.CTX_START_DATE), 12, 31)  -- Sept 1 to Dec 31 (Hiver)
		AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
		AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
		AND (ASM_FIELDA_001 IS NOT NULL AND (ASM_FIELDA_072 <> '1' OR ASM_FIELDA_072 IS NULL))
	ORDER BY SKL_SCHOOL_ID, ASM_GRADE_LEVEL_CODE, STD_NAME_VIEW



-- Requête Printemps - Les entrées où le bulletin printemps devrait être coché "O" mais ne l'est pas
	SELECT
		SKL_SCHOOL_ID AS [ecole],
		ASM_GRADE_LEVEL_CODE AS [niveau],
		ASM_STD_OID AS [STD_OID],
		STD_NAME_VIEW AS [eleve], -- nom de l'eleve
		ASM_DATE AS [date],
		ASM_FIELDA_001 AS [complete], -- 0 = Non, 1 = Oui, 2 = S.O.
		ASM_FIELDA_002 AS [norme_atteinte], -- 0 = Non, 1 = Oui
		ASM_FIELDA_072 AS [hiver], -- 0 = Non, 1 = Oui
		ASM_FIELDA_073 AS [printemps] -- 0 = Non, 1 = Oui
	FROM STUDENT_ASSESSMENT
		INNER JOIN STUDENT AS STD ON ASM_STD_OID = STD_OID
		INNER JOIN SCHOOL ON ASM_SKL_OID = SKL_OID
		INNER JOIN DISTRICT_SCHOOL_YEAR_CONTEXT AS ctx ON ctx.CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM ORGANIZATION)
	WHERE ASM_DATE >= DATEFROMPARTS(YEAR(ctx.CTX_START_DATE) + 1, 1, 1)  -- Jan 1 onwards (Printemps)
		AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
		AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
		AND (ASM_FIELDA_001 IS NOT NULL AND (ASM_FIELDA_073 <> '1' OR ASM_FIELDA_073 IS NULL))
	ORDER BY SKL_SCHOOL_ID, ASM_GRADE_LEVEL_CODE, STD_NAME_VIEW



WITH dataCTE AS (
	SELECT
		SKL_SCHOOL_ID AS [ecole],
		ASM_GRADE_LEVEL_CODE AS [niveau],
		ASM_STD_OID AS [STD_OID],
		STD_NAME_VIEW AS [eleve], -- nom de l'eleve
		ASM_DATE AS [date],
		ASM_FIELDA_001 AS [complete], -- 0 = Non, 1 = Oui, 2 = S.O.
		ASM_FIELDA_002 AS [norme_atteinte], -- 0 = Non, 1 = Oui
		ASM_FIELDA_072 AS [hiver], -- 0 = Non, 1 = Oui
		ASM_FIELDA_073 AS [printemps] -- 0 = Non, 1 = Oui
	FROM STUDENT_ASSESSMENT
		INNER JOIN STUDENT ON ASM_STD_OID = STD_OID
		INNER JOIN SCHOOL ON ASM_SKL_OID = SKL_OID
		INNER JOIN [DISTRICT_SCHOOL_YEAR_CONTEXT] AS ctx ON ctx.CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM [ORGANIZATION])
	WHERE ASM_DATE >= ctx.CTX_START_DATE
		AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
		--AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
		--AND (ASM_FIELDA_072 = '1' OR ASM_FIELDA_073 <> '1')
	--ORDER BY SKL_SCHOOL_ID, ASM_GRADE_LEVEL_CODE, STD_NAME_VIEW
)


-- Élèves actifs sans données d'évaluation 'Dépistage précoce de la lecture / Early reading screening'
SELECT
	SKL_SCHOOL_ID AS [ecole],
	STD_GRADE_LEVEL AS [niveau],
	STD_OID AS [STD_OID],
	STD_NAME_VIEW AS [eleve], -- nom de l'eleve
	STD_ENROLLMENT_STATUS AS [statut]
FROM [STUDENT]
	INNER JOIN [SCHOOL] ON SKL_OID = STD_SKL_OID

WHERE STD_ENROLLMENT_STATUS = 'Active' -- Not PreReg
 	AND STD_GRADE_LEVEL IN ('SK', '01', '02')
	AND STD_SKL_OID != 'SKL000OnSISOOB'
	AND STD_OID NOT IN (SELECT STD_OID FROM dataCTE)



-- Norme atteinte lors de la première évaluation du dépistage et n'a pas un S.O. lors de la deuxième évaluation
SELECT *
FROM dataCTE
WHERE STD_OID IN (
	SELECT STD_OID FROM dataCTE
	WHERE [date] BETWEEN '2025-09-01' AND '2025-12-31' AND [norme_atteinte] = '1'
)
AND [date] > '2025-12-31'
AND [complete] <> '2'
ORDER BY [ecole], [niveau], [eleve]
