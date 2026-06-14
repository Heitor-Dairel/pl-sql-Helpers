CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY HEITOR_LIBRARY IS

FUNCTION BISSEXTOX(YEAR IN VARCHAR2)
RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: BISSEXTOX                                                                                                           ####
  ####  DATA CRIAÇÃO: 23/11/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função BISSEXTOX indica se o ano é bissexto ou não, passando o ano de parâmetro.                          ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/

  V_ANO      PLS_INTEGER;
  V_BISSEXTO VARCHAR2(1);

BEGIN

  V_ANO := TRUNC(ABS(YEAR));

IF V_ANO IS NULL
  THEN V_BISSEXTO := NULL;
  ELSE
  IF MOD(V_ANO, 4) = 0 AND (MOD(V_ANO, 100) != 0 OR MOD(V_ANO, 400) = 0) THEN
    V_BISSEXTO := 'S';
  ELSE
    V_BISSEXTO := 'N';
  END IF;
  END IF;

  RETURN V_BISSEXTO;

EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(-20024,
                            'Erro: O valor fornecido para o parâmetro year não é válido.');

END;


FUNCTION CHRONOS(DATA              IN DATE,                   -- DATA PRINCIPAL
                 SKIP_BUSINESS_DAY IN VARCHAR2 DEFAULT 2,     -- 1: SIM, PULA DIAS ÚTEIS.
                                                              -- 2: NÃO, PULA DIAS ÚTEIS.
                 SIGN              IN VARCHAR2 DEFAULT 1,     -- 1: "P" - POSITIVO.
                                                              -- 2: "N" - NEGATIVO.
                 DAYS              IN VARCHAR2 DEFAULT NULL   -- DIAS: POSTERGAR OU ANTECIPAR
                 )

 RETURN DATE IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: CHRONOS                                                                                                             ####
  ####  DATA CRIAÇÃO: 23/11/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função CHRONOS ajusta uma data específica para garantir que ela sempre caia em um dia útil,               ####
  ####  considerando feriados e finais de semana. O usuário pode configurar a função para mover a data para frente                  ####
  ####  ou para trás no calendário, com intervalos personalizados, como de 1 em 1 dia, de 3 em 3 dias, ou de 30 em 30 dias.         ####
  ####  Se a data resultante cair em um feriado ou final de semana, ela será automaticamente ajustada para o próximo                ####
  ####  ou o dia útil anterior, dependendo da configuração. Caso a data inicial já seja um dia útil, ela permanece inalterada.      ####
  ####  A função é flexível e útil para aplicações como agendamento, controle de prazos ou qualquer cenário que exija               ####
  ####  movimentação de datas com base em regras específicas, garantindo confiabilidade e eficiência no processo.                   ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


  V_DATE              DATE;
  V_PULAR_DIA_UTL     VARCHAR2(1);
  V_SINAL             VARCHAR2(1);
  V_DIAS              PLS_INTEGER;
  V_FD                PLS_INTEGER;
  V_SKIP_BUSINESS_DAY PLS_INTEGER;
  V_SIGN              PLS_INTEGER;

BEGIN

  V_SKIP_BUSINESS_DAY := TRUNC(ABS(NVL(SKIP_BUSINESS_DAY,2)));
  V_SIGN              := TRUNC(ABS(NVL(SIGN,1)));
  V_DATE              := TRUNC(DATA);
  V_PULAR_DIA_UTL     := CASE WHEN V_SKIP_BUSINESS_DAY = 1 THEN 'S' ELSE 'N' END;
  V_SINAL             := CASE WHEN V_SIGN = 1 THEN 'P' ELSE 'N' END;
  V_DIAS              := TRUNC(ABS(DAYS));


-- SE O VALOR NÃO FOR "1 = SIM" OU "2 = N", ELE ENVIARÁ UMA MENSAGEM DE ERRO PARA O USUÁRIO.

  IF SKIP_BUSINESS_DAY NOT IN (1, 2) THEN
    RAISE_APPLICATION_ERROR(-20025,
                            'Erro: O valor fornecido para o parâmetro skip_business_day não é válido. O use 1 para SIM e 2 para NÃO.');

-- SE O VALOR NÃO FOR "1 = POSITIVO" OU "2 = NEGATIVO", ELE ENVIARÁ UMA MENSAGEM DE ERRO PARA O USUÁRIO.

  ELSIF SIGN NOT IN (1, 2) THEN
    RAISE_APPLICATION_ERROR(-20024,
                            'Erro: O valor fornecido para o parâmetro sign não é válido. O use 1 para POSITIVO e 2 para NEGATIVO.');

  END IF;



  IF V_PULAR_DIA_UTL = 'S' AND V_DIAS IS NULL THEN

    V_DIAS := 1;

  END IF;

  IF V_PULAR_DIA_UTL = 'N' AND V_SINAL = 'P' THEN

    LOOP
      SELECT CASE
               WHEN EXISTS
                (SELECT 1 FROM TB_CALENDARIO_FERIADOS CF WHERE CF.DATA = V_DATE) OR
                    TO_CHAR(V_DATE, 'D') IN (1, 7) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;

      IF V_FD = 1 THEN

        V_DATE := V_DATE + 1;

      ELSE
        EXIT;

      END IF;

    END LOOP;

  ELSIF V_PULAR_DIA_UTL = 'N' AND V_SINAL = 'N' THEN

    LOOP
      SELECT CASE
               WHEN EXISTS
                (SELECT 1 FROM TB_CALENDARIO_FERIADOS CF WHERE CF.DATA = V_DATE) OR
                    TO_CHAR(V_DATE, 'D') IN (1, 7) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;

      IF V_FD = 1 THEN

        V_DATE := V_DATE - 1;

      ELSE
        EXIT;

      END IF;

    END LOOP;

  ELSIF V_PULAR_DIA_UTL = 'S' AND V_SINAL = 'P' AND V_DIAS IS NOT NULL THEN

    V_DATE := V_DATE + V_DIAS;

    LOOP
      SELECT CASE
               WHEN EXISTS (SELECT 1
                       FROM TB_CALENDARIO_FERIADOS CF
                      WHERE CF.DATA = V_DATE) OR
                    TO_CHAR(V_DATE, 'D') IN (1, 7) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;

      IF V_FD = 1 THEN

        V_DATE := V_DATE + 1;

      ELSE
        EXIT;

      END IF;

    END LOOP;

  ELSIF V_PULAR_DIA_UTL = 'S' AND V_SINAL = 'N' AND V_DIAS IS NOT NULL THEN

    V_DATE := V_DATE - V_DIAS;

    LOOP
      SELECT CASE
               WHEN EXISTS (SELECT 1
                       FROM TB_CALENDARIO_FERIADOS CF
                      WHERE CF.DATA = V_DATE) OR
                    TO_CHAR(V_DATE, 'D') IN (1, 7) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;

      IF V_FD = 1 THEN

        V_DATE := V_DATE - 1;

      ELSE
        EXIT;

      END IF;

    END LOOP;

  END IF;

  RETURN V_DATE;

EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(-20583,
                            'Erro: O valor fornecido para skip_business_day, sign ou days não é válido. Apenas números são permitidos.');

END;

FUNCTION PASCHALIS_CALCULUS(YEAR         IN VARCHAR2,              -- ANO DE BUSCA DA FUNÇÃO PARA ACHAR A DATA DO ANO INDICADO. ANOS QUE PODEM SER PASSADOS: 1d.C. a 9999d.C
                            HOLIDAY_TYPE IN VARCHAR2 DEFAULT NULL, -- IDENTIFICADOR DO FERIADO (1=CARNAVAL, 2=SEXTA-FEIRA SANTA, 3=CORPUS CHRISTI)
                            CARNIVAL_DAY IN VARCHAR2 DEFAULT 1     -- ESCOLHA DO DIA PARA FERIADOS COMO O CARNAVAL (1=PRIMEIRO DIA, 2=SEGUNDO DIA)
                            )
RETURN DATE IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: PASCHALIS_CALCULUS                                                                                                  ####
  ####  DATA CRIAÇÃO: 16/11/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função PASCHALIS_CALCULUS realiza cálculos avançados para determinar datas relacionadas à Páscoa nos      ####
  ####  calendários gregoriano e juliano, abrangendo anos de 1 a 9999. O usuário informa o ano como primeiro parâmetro e escolhe,   ####
  ####  no segundo parâmetro, qual evento deseja calcular: Carnaval, Sexta-feira Santa ou Corpus Christi.                           ####
  ####  Para o Carnaval, existe um terceiro parâmetro opcional que, por padrão, retorna o primeiro dia; ao passar o valor 2,        ####
  ####  retorna o segundo dia do Carnaval.                                                                                          ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


  V_DATE         DATE;
  V_YEAR         PLS_INTEGER;
  V_HOLIDAY_TYPE PLS_INTEGER;
  V_CARNIVAL_DAY PLS_INTEGER;



BEGIN


  -- TRANSFORMANDO PARA NUMBER
  V_YEAR         := TRUNC(ABS(YEAR));
  V_HOLIDAY_TYPE := TRUNC(ABS(HOLIDAY_TYPE));
  V_CARNIVAL_DAY := TRUNC(ABS(NVL(CARNIVAL_DAY,1)));


  -- VALIDAÇÕES DE ENTRADA

  IF V_YEAR NOT BETWEEN 1 AND 9999 THEN
      RAISE_APPLICATION_ERROR(-20325, 'Erro: O valor fornecido para o parâmetro year não é válido. O ano deve estar entre 1 e 9999.');

  ELSIF V_HOLIDAY_TYPE NOT IN (1, 2, 3) THEN
      RAISE_APPLICATION_ERROR(-20666, 'Erro: Identificador inválido para holiday_type! Use 1 para Carnaval, 2 para Sexta-feira Santa, ou 3 para Corpus Christi.');

  ELSIF V_CARNIVAL_DAY NOT IN (1, 2) THEN
      RAISE_APPLICATION_ERROR(-20030, 'Erro: Escolha de dia inválida para carnival_day! Use 1 para o Primeiro Dia ou 2 para o Segundo Dia do Carnaval.');

  END IF;

  IF V_YEAR <= 1582 THEN

  -- CALENDÁRIO JULIANO

      V_DATE := TO_DATE(LPAD(MOD(MOD(19 * MOD(V_YEAR, 19) + 15, 30) +
                                 MOD(2 * MOD(V_YEAR, 4) +
                                     4 * MOD(V_YEAR, 7) -
                                     MOD(19 * MOD(V_YEAR, 19) + 15, 30) + 34,
                                     7) + 114,
                                 31) + 1,
                             2,
                             0) ||
                        LPAD(TRUNC((MOD(19 * MOD(V_YEAR, 19) + 15, 30) +
                                   MOD(2 * MOD(V_YEAR, 4) +
                                        4 * MOD(V_YEAR, 7) -
                                        MOD(19 * MOD(V_YEAR, 19) + 15, 30) + 34,
                                        7) + 114) / 31),
                             2,
                             0) || LPAD(V_YEAR, 4, 0));



     ELSE

   -- CALENDÁRIO GREGORIANO

       V_DATE := TO_DATE(LPAD(MOD(MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) -
        TRUNC(TRUNC(V_YEAR / 100) / 4) - TRUNC((TRUNC(V_YEAR / 100) -
        TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) + MOD((32 + 2 *
        MOD(TRUNC(V_YEAR / 100), 4) + 2 *
        TRUNC(MOD(V_YEAR, 100) / 4) - MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) -
        TRUNC((TRUNC(V_YEAR / 100) - TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) - MOD(MOD(V_YEAR, 100), 4)), 7) - 7 *
        TRUNC((MOD(V_YEAR, 19) + 11 * MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) - TRUNC((TRUNC(V_YEAR / 100) -
        TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) + 22 *
        MOD((32 + 2 * MOD(TRUNC(V_YEAR / 100), 4) + 2 * TRUNC(MOD(V_YEAR, 100) / 4) - MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) -
        TRUNC(TRUNC(V_YEAR / 100) / 4) - TRUNC((TRUNC(V_YEAR / 100) - TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) - MOD(MOD(V_YEAR, 100), 4)), 7)) / 451) + 114, 31) + 1, 2, 0) ||
        LPAD(TRUNC((MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) - TRUNC((TRUNC(V_YEAR / 100) - TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) + MOD((32 + 2 *
        MOD(TRUNC(V_YEAR / 100), 4) + 2 * TRUNC(MOD(V_YEAR, 100) / 4) - MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) -
        TRUNC((TRUNC(V_YEAR / 100) - TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) - MOD(MOD(V_YEAR, 100), 4)), 7) - 7 * TRUNC((MOD(V_YEAR, 19) + 11 *
        MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) - TRUNC((TRUNC(V_YEAR / 100) - TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) + 22 * MOD((32 + 2 * MOD(TRUNC(V_YEAR / 100), 4) + 2 *
        TRUNC(MOD(V_YEAR, 100) / 4) - MOD((19 * MOD(V_YEAR, 19) + TRUNC(V_YEAR / 100) - TRUNC(TRUNC(V_YEAR / 100) / 4) -
        TRUNC((TRUNC(V_YEAR / 100) -
        TRUNC((TRUNC(V_YEAR / 100) + 8) / 25) + 1) / 3) + 15), 30) - MOD(MOD(V_YEAR, 100), 4)), 7)) / 451) + 114) / 31), 2, 0) || LPAD(V_YEAR, 4, 0));

        END IF;

                 IF V_HOLIDAY_TYPE = 1 AND V_CARNIVAL_DAY = 1 THEN V_DATE := V_DATE - 48; -- CARNAVAL (1º DIA)
                 ELSIF V_HOLIDAY_TYPE = 1 AND V_CARNIVAL_DAY = 2 THEN V_DATE := V_DATE - 47; -- CARNAVAL (2º DIA)
                 ELSIF V_HOLIDAY_TYPE = 2 THEN V_DATE := V_DATE - 2; -- SEXTA-FEIRA SANTA
                 ELSIF V_HOLIDAY_TYPE = 3 THEN V_DATE := V_DATE  + 60; -- CORPUS CHRISTI
                 END IF;
     -- SE NÃO CAIR EM NENHUMA CONDIÇÃO SERÁ PÁSCOA COMO PADRÃO

        RETURN V_DATE;

                EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20582, 'Erro: O valor fornecido para ano, tipo de feriado ou dia do carnaval não é válido. Apenas números são permitidos.');

        END;

FUNCTION TEMPUS_DOMINUS(START_DATE    IN DATE,               -- DATA INÍCIO
                        END_DATE      IN DATE,               -- DATA FIM
                        CALENDAR_RULE IN VARCHAR2 DEFAULT 1, -- ESQUEMA DE CALCULO. 1 PARA FERIADO E FINAL DE SEMANA, 2 PARA FERIADO, 3 PARA FINAL DE SEMANA E 4 DIAS CORRIDOS
                        FULLINTERVAL  IN VARCHAR2 DEFAULT 1  -- INTERVALO DE CALCULO. 1 NÃO INCLUI DATA INICIO, 2 INCLUI DATA INICIO E DATA FIM E O 3 EXCLUI DATA INICIO E DATA FIM.
                        )
RETURN NUMBER IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: TEMPUS_DOMINUS                                                                                                      ####
  ####  DATA CRIAÇÃO: 27/11/2024                                                                                                    ####
  ####  DATA MODIFICAÇÃO: 22/12/2024                                                                                                ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função TEMPUS_DOMINUS calcula a diferença de dias entre duas datas, ajustando o resultado com base em     ####
  ####  regras definidas pelo usuário. Ela pode excluir feriados, finais de semana ou ambos, dependendo do parâmetro CALENDAR_RULE, ####
  ####  e permite incluir ou excluir as datas de início e fim por meio do parâmetro FULLINTERVAL. Internamente, a função            ####
  ####  utiliza uma tabela de feriados e cálculos de dias da semana para determinar quais dias devem ser descontados,               ####
  ####  retornando o total de dias úteis ou corridos entre as datas. Caso os parâmetros sejam inválidos ou as datas                 ####
  ####  estejam invertidas, a função retorna erros claros para garantir o uso correto.                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/

  V_INI_DT   DATE;
  V_FIN_DT   DATE;
  V_CLA_RU   PLS_INTEGER;
  V_RESULT   PLS_INTEGER;
  V_SUB_DAYS PLS_INTEGER;
  V_INTERVAL PLS_INTEGER;

BEGIN

  V_INI_DT   := TRUNC(START_DATE);
  V_FIN_DT   := TRUNC(END_DATE);
  V_CLA_RU   := TRUNC(ABS(NVL(CALENDAR_RULE, 1)));
  V_INTERVAL := TRUNC(ABS(NVL(FULLINTERVAL, 1)));


  IF V_CLA_RU NOT IN (1, 2, 3, 4) THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro calendar_rule não é válido. O use 1 (feriado e final de semana), 2 (feriado), 3 (final de semana) ou 4 (dias corridos).');

  ELSIF V_INI_DT > V_FIN_DT THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O parâmetro start_date não pode ser maior que end_date.');

  ELSIF V_INTERVAL NOT IN (1, 2, 3) THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro fullinterval não é válido. O use 1 (exclui data início) ou 2 (inclui data início e data fim) ou 3 (exclui data início e data fim).');

END IF;


IF V_FIN_DT - V_INI_DT = 0 THEN

V_RESULT := 0;

ELSE

IF V_INTERVAL = 2 THEN

IF V_CLA_RU = 1 THEN

  SELECT COUNT(DISTINCT FD.DATA)
    INTO V_SUB_DAYS
    FROM (
  SELECT CF.DATA
    FROM TB_CALENDARIO_FERIADOS CF
   WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT
   UNION ALL
  SELECT V_INI_DT + (LEVEL - 1) AS DATA
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1) FD;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 2 THEN

SELECT COUNT(CF.DATA)
  INTO V_SUB_DAYS
  FROM TB_CALENDARIO_FERIADOS CF
 WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 3 THEN

  SELECT COUNT(V_INI_DT + (LEVEL - 1))
    INTO V_SUB_DAYS
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 4 THEN

V_RESULT := (V_FIN_DT - V_INI_DT) + 1;

END IF;

ELSIF V_INTERVAL = 1 THEN

IF V_CLA_RU = 1 THEN

  SELECT COUNT(DISTINCT FD.DATA)
    INTO V_SUB_DAYS
    FROM (
  SELECT CF.DATA
    FROM TB_CALENDARIO_FERIADOS CF
   WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT
   UNION ALL
  SELECT V_INI_DT + (LEVEL - 1) AS DATA
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1) FD;

V_RESULT := (V_FIN_DT - V_INI_DT) - V_SUB_DAYS;

ELSIF V_CLA_RU = 2 THEN

SELECT COUNT(CF.DATA)
  INTO V_SUB_DAYS
  FROM TB_CALENDARIO_FERIADOS CF
 WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT;

V_RESULT := (V_FIN_DT - V_INI_DT) - V_SUB_DAYS;

ELSIF V_CLA_RU = 3 THEN

  SELECT COUNT(V_INI_DT + (LEVEL - 1))
    INTO V_SUB_DAYS
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1;

V_RESULT := (V_FIN_DT - V_INI_DT) - V_SUB_DAYS;

ELSIF V_CLA_RU = 4 THEN

V_RESULT := V_FIN_DT - V_INI_DT;

END IF;

ELSE


IF V_CLA_RU = 1 THEN

V_INI_DT := V_INI_DT + 1;
V_FIN_DT := V_FIN_DT - 1;

  SELECT COUNT(DISTINCT FD.DATA)
    INTO V_SUB_DAYS
    FROM (
  SELECT CF.DATA
    FROM TB_CALENDARIO_FERIADOS CF
   WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT
   UNION ALL
  SELECT V_INI_DT + (LEVEL - 1) AS DATA
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1) FD;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 2 THEN

V_INI_DT := V_INI_DT + 1;
V_FIN_DT := V_FIN_DT - 1;

SELECT COUNT(CF.DATA)
  INTO V_SUB_DAYS
  FROM TB_CALENDARIO_FERIADOS CF
 WHERE CF.DATA BETWEEN V_INI_DT AND V_FIN_DT;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 3 THEN

V_INI_DT := V_INI_DT + 1;
V_FIN_DT := V_FIN_DT - 1;

  SELECT COUNT(V_INI_DT + (LEVEL - 1))
    INTO V_SUB_DAYS
    FROM DUAL
   WHERE TO_CHAR(V_INI_DT + (LEVEL - 1), 'D') IN (1, 7)
 CONNECT BY LEVEL <= (V_FIN_DT - V_INI_DT) + 1;

V_RESULT := ((V_FIN_DT - V_INI_DT) - V_SUB_DAYS) + 1;

ELSIF V_CLA_RU = 4 THEN

V_RESULT := (V_FIN_DT - V_INI_DT) - 1;

END IF;

END IF;

END IF;

IF V_RESULT < 0 THEN

V_RESULT := 0;

END IF;

RETURN V_RESULT;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20583, 'Erro: O valor fornecido para calendar_rule ou fullinterval não é válido. Apenas números são permitidos.');

END;


FUNCTION BINAREON(MESSAGE IN VARCHAR2, -- BINÁRIO OU TEXTO
                                       -- OBS: PASSAR O VALOR BINÁRIO SEM ESPAÇO ATÉ 3552, COM ESPAÇO ATÉ 3995
                  ACTION  IN VARCHAR2  -- 1 PARA CODIFICAR E 2 PARA DECODIFICAR
                  )
RETURN VARCHAR2 IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: BINAREON                                                                                                            ####
  ####  DATA CRIAÇÃO: 30/11/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função BINAREON realiza a conversão entre texto e código binário de maneira simples e prática. O usuário  ####
  ####  pode escolher entre duas opções de operação, definidas pelo parâmetro ACTION: o valor 1 para converter texto em binário     ####
  ####  e o valor 2 para converter binário em texto. No parâmetro MESSAGE, o usuário coloca o conteúdo que deseja converter,        ####
  ####  seja texto ou código binário. A função suporta textos de até 444 caracteres e códigos binários de                           ####
  ####  até 3.995 caracteres (com espaços) ou 3.552 caracteres (sem espaços). É uma ferramenta eficiente para quem precisa          ####
  ####  fazer essas conversões rapidamente, sempre respeitando os limites especificados.                                            ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_PAYLOAD           VARCHAR2(4000);
V_RESULT_TEXT       VARCHAR2(4000);
V_RESULT_BINARY     VARCHAR2(4000);
V_RESULT_NULL       VARCHAR2(4000);
V_MODE              PLS_INTEGER;
V_BINARY            VARCHAR2(250);
V_TEXT              VARCHAR2(250);
V_BINARY_INPUT      VARCHAR2(3995);
V_TEXT_INPUT        VARCHAR2(444);
V_DECIMAL           NUMBER;

BEGIN

BEGIN V_MODE := TRUNC(ABS(ACTION));

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: O valor fornecido para action não é válido. Apenas números são permitidos.');

END;

IF V_MODE IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro action não pode ser null.');
ELSIF V_MODE NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o parâmetro action não é válido. O use 1 para codificar ou 2 para decodificar.');
END IF;

IF MESSAGE IS NULL THEN

V_RESULT_NULL := NULL;

ELSIF MESSAGE IS NOT NULL AND V_MODE = 1

THEN V_TEXT_INPUT := MESSAGE;


FOR TXT IN 1 .. LENGTH(V_TEXT_INPUT)
LOOP

 V_TEXT := SUBSTR(V_TEXT_INPUT,TXT,1);

IF V_TEXT = ' ' THEN V_DECIMAL := 32;
ELSIF V_TEXT = '!' THEN V_DECIMAL := 33;
ELSIF V_TEXT = '"' THEN V_DECIMAL := 34;
ELSIF V_TEXT = '#' THEN V_DECIMAL := 35;
ELSIF V_TEXT = '$' THEN V_DECIMAL := 36;
ELSIF V_TEXT = '%' THEN V_DECIMAL := 37;
ELSIF V_TEXT = '&' THEN V_DECIMAL := 38;
ELSIF V_TEXT = CHR(39) THEN V_DECIMAL := 39;
ELSIF V_TEXT = '(' THEN V_DECIMAL := 40;
ELSIF V_TEXT = ')' THEN V_DECIMAL := 41;
ELSIF V_TEXT = '*' THEN V_DECIMAL := 42;
ELSIF V_TEXT = '+' THEN V_DECIMAL := 43;
ELSIF V_TEXT = ',' THEN V_DECIMAL := 44;
ELSIF V_TEXT = '-' THEN V_DECIMAL := 45;
ELSIF V_TEXT = '.' THEN V_DECIMAL := 46;
ELSIF V_TEXT = '/' THEN V_DECIMAL := 47;
ELSIF V_TEXT = '0' THEN V_DECIMAL := 48;
ELSIF V_TEXT = '1' THEN V_DECIMAL := 49;
ELSIF V_TEXT = '2' THEN V_DECIMAL := 50;
ELSIF V_TEXT = '3' THEN V_DECIMAL := 51;
ELSIF V_TEXT = '4' THEN V_DECIMAL := 52;
ELSIF V_TEXT = '5' THEN V_DECIMAL := 53;
ELSIF V_TEXT = '6' THEN V_DECIMAL := 54;
ELSIF V_TEXT = '7' THEN V_DECIMAL := 55;
ELSIF V_TEXT = '8' THEN V_DECIMAL := 56;
ELSIF V_TEXT = '9' THEN V_DECIMAL := 57;
ELSIF V_TEXT = ':' THEN V_DECIMAL := 58;
ELSIF V_TEXT = ';' THEN V_DECIMAL := 59;
ELSIF V_TEXT = '<' THEN V_DECIMAL := 60;
ELSIF V_TEXT = '=' THEN V_DECIMAL := 61;
ELSIF V_TEXT = '>' THEN V_DECIMAL := 62;
ELSIF V_TEXT = '?' THEN V_DECIMAL := 63;
ELSIF V_TEXT = '@' THEN V_DECIMAL := 64;
ELSIF V_TEXT = 'A' THEN V_DECIMAL := 65;
ELSIF V_TEXT = 'B' THEN V_DECIMAL := 66;
ELSIF V_TEXT = 'C' THEN V_DECIMAL := 67;
ELSIF V_TEXT = 'D' THEN V_DECIMAL := 68;
ELSIF V_TEXT = 'E' THEN V_DECIMAL := 69;
ELSIF V_TEXT = 'F' THEN V_DECIMAL := 70;
ELSIF V_TEXT = 'G' THEN V_DECIMAL := 71;
ELSIF V_TEXT = 'H' THEN V_DECIMAL := 72;
ELSIF V_TEXT = 'I' THEN V_DECIMAL := 73;
ELSIF V_TEXT = 'J' THEN V_DECIMAL := 74;
ELSIF V_TEXT = 'K' THEN V_DECIMAL := 75;
ELSIF V_TEXT = 'L' THEN V_DECIMAL := 76;
ELSIF V_TEXT = 'M' THEN V_DECIMAL := 77;
ELSIF V_TEXT = 'N' THEN V_DECIMAL := 78;
ELSIF V_TEXT = 'O' THEN V_DECIMAL := 79;
ELSIF V_TEXT = 'P' THEN V_DECIMAL := 80;
ELSIF V_TEXT = 'Q' THEN V_DECIMAL := 81;
ELSIF V_TEXT = 'R' THEN V_DECIMAL := 82;
ELSIF V_TEXT = 'S' THEN V_DECIMAL := 83;
ELSIF V_TEXT = 'T' THEN V_DECIMAL := 84;
ELSIF V_TEXT = 'U' THEN V_DECIMAL := 85;
ELSIF V_TEXT = 'V' THEN V_DECIMAL := 86;
ELSIF V_TEXT = 'W' THEN V_DECIMAL := 87;
ELSIF V_TEXT = 'X' THEN V_DECIMAL := 88;
ELSIF V_TEXT = 'Y' THEN V_DECIMAL := 89;
ELSIF V_TEXT = 'Z' THEN V_DECIMAL := 90;
ELSIF V_TEXT = '[' THEN V_DECIMAL := 91;
ELSIF V_TEXT = '\' THEN V_DECIMAL := 92;
ELSIF V_TEXT = ']' THEN V_DECIMAL := 93;
ELSIF V_TEXT = '^' THEN V_DECIMAL := 94;
ELSIF V_TEXT = '_' THEN V_DECIMAL := 95;
ELSIF V_TEXT = '`' THEN V_DECIMAL := 96;
ELSIF V_TEXT = 'a' THEN V_DECIMAL := 97;
ELSIF V_TEXT = 'b' THEN V_DECIMAL := 98;
ELSIF V_TEXT = 'c' THEN V_DECIMAL := 99;
ELSIF V_TEXT = 'd' THEN V_DECIMAL := 100;
ELSIF V_TEXT = 'e' THEN V_DECIMAL := 101;
ELSIF V_TEXT = 'f' THEN V_DECIMAL := 102;
ELSIF V_TEXT = 'g' THEN V_DECIMAL := 103;
ELSIF V_TEXT = 'h' THEN V_DECIMAL := 104;
ELSIF V_TEXT = 'i' THEN V_DECIMAL := 105;
ELSIF V_TEXT = 'j' THEN V_DECIMAL := 106;
ELSIF V_TEXT = 'k' THEN V_DECIMAL := 107;
ELSIF V_TEXT = 'l' THEN V_DECIMAL := 108;
ELSIF V_TEXT = 'm' THEN V_DECIMAL := 109;
ELSIF V_TEXT = 'n' THEN V_DECIMAL := 110;
ELSIF V_TEXT = 'o' THEN V_DECIMAL := 111;
ELSIF V_TEXT = 'p' THEN V_DECIMAL := 112;
ELSIF V_TEXT = 'q' THEN V_DECIMAL := 113;
ELSIF V_TEXT = 'r' THEN V_DECIMAL := 114;
ELSIF V_TEXT = 's' THEN V_DECIMAL := 115;
ELSIF V_TEXT = 't' THEN V_DECIMAL := 116;
ELSIF V_TEXT = 'u' THEN V_DECIMAL := 117;
ELSIF V_TEXT = 'v' THEN V_DECIMAL := 118;
ELSIF V_TEXT = 'w' THEN V_DECIMAL := 119;
ELSIF V_TEXT = 'x' THEN V_DECIMAL := 120;
ELSIF V_TEXT = 'y' THEN V_DECIMAL := 121;
ELSIF V_TEXT = 'z' THEN V_DECIMAL := 122;
ELSIF V_TEXT = '{' THEN V_DECIMAL := 123;
ELSIF V_TEXT = '|' THEN V_DECIMAL := 124;
ELSIF V_TEXT = '}' THEN V_DECIMAL := 125;
ELSIF V_TEXT = '~' THEN V_DECIMAL := 126;
ELSIF V_TEXT = '€' THEN V_DECIMAL := 128;
ELSIF V_TEXT = '‚' THEN V_DECIMAL := 130;
ELSIF V_TEXT = 'ƒ' THEN V_DECIMAL := 131;
ELSIF V_TEXT = '„' THEN V_DECIMAL := 132;
ELSIF V_TEXT = '…' THEN V_DECIMAL := 133;
ELSIF V_TEXT = '†' THEN V_DECIMAL := 134;
ELSIF V_TEXT = '‡' THEN V_DECIMAL := 135;
ELSIF V_TEXT = 'ˆ' THEN V_DECIMAL := 136;
ELSIF V_TEXT = '‰' THEN V_DECIMAL := 137;
ELSIF V_TEXT = 'Š' THEN V_DECIMAL := 138;
ELSIF V_TEXT = '‹' THEN V_DECIMAL := 139;
ELSIF V_TEXT = 'Œ' THEN V_DECIMAL := 140;
ELSIF V_TEXT = 'Ž' THEN V_DECIMAL := 142;
ELSIF V_TEXT = '‘' THEN V_DECIMAL := 145;
ELSIF V_TEXT = '’' THEN V_DECIMAL := 146;
ELSIF V_TEXT = '“' THEN V_DECIMAL := 147;
ELSIF V_TEXT = '”' THEN V_DECIMAL := 148;
ELSIF V_TEXT = '•' THEN V_DECIMAL := 149;
ELSIF V_TEXT = '–' THEN V_DECIMAL := 150;
ELSIF V_TEXT = '—' THEN V_DECIMAL := 151;
ELSIF V_TEXT = '™' THEN V_DECIMAL := 153;
ELSIF V_TEXT = 'š' THEN V_DECIMAL := 154;
ELSIF V_TEXT = '›' THEN V_DECIMAL := 155;
ELSIF V_TEXT = 'œ' THEN V_DECIMAL := 156;
ELSIF V_TEXT = 'ž' THEN V_DECIMAL := 158;
ELSIF V_TEXT = 'Ÿ' THEN V_DECIMAL := 159;
ELSIF V_TEXT = '¡' THEN V_DECIMAL := 161;
ELSIF V_TEXT = '¢' THEN V_DECIMAL := 162;
ELSIF V_TEXT = '£' THEN V_DECIMAL := 163;
ELSIF V_TEXT = '¤' THEN V_DECIMAL := 164;
ELSIF V_TEXT = '¥' THEN V_DECIMAL := 165;
ELSIF V_TEXT = '¦' THEN V_DECIMAL := 166;
ELSIF V_TEXT = '§' THEN V_DECIMAL := 167;
ELSIF V_TEXT = '¨' THEN V_DECIMAL := 168;
ELSIF V_TEXT = '©' THEN V_DECIMAL := 169;
ELSIF V_TEXT = 'ª' THEN V_DECIMAL := 170;
ELSIF V_TEXT = '«' THEN V_DECIMAL := 171;
ELSIF V_TEXT = '¬' THEN V_DECIMAL := 172;
ELSIF V_TEXT = '®' THEN V_DECIMAL := 174;
ELSIF V_TEXT = '¯' THEN V_DECIMAL := 175;
ELSIF V_TEXT = '°' THEN V_DECIMAL := 176;
ELSIF V_TEXT = '±' THEN V_DECIMAL := 177;
ELSIF V_TEXT = '²' THEN V_DECIMAL := 178;
ELSIF V_TEXT = '³' THEN V_DECIMAL := 179;
ELSIF V_TEXT = '´' THEN V_DECIMAL := 180;
ELSIF V_TEXT = 'µ' THEN V_DECIMAL := 181;
ELSIF V_TEXT = '¶' THEN V_DECIMAL := 182;
ELSIF V_TEXT = '·' THEN V_DECIMAL := 183;
ELSIF V_TEXT = '¸' THEN V_DECIMAL := 184;
ELSIF V_TEXT = '¹' THEN V_DECIMAL := 185;
ELSIF V_TEXT = 'º' THEN V_DECIMAL := 186;
ELSIF V_TEXT = '»' THEN V_DECIMAL := 187;
ELSIF V_TEXT = '¼' THEN V_DECIMAL := 188;
ELSIF V_TEXT = '½' THEN V_DECIMAL := 189;
ELSIF V_TEXT = '¾' THEN V_DECIMAL := 190;
ELSIF V_TEXT = '¿' THEN V_DECIMAL := 191;
ELSIF V_TEXT = 'À' THEN V_DECIMAL := 192;
ELSIF V_TEXT = 'Á' THEN V_DECIMAL := 193;
ELSIF V_TEXT = 'Â' THEN V_DECIMAL := 194;
ELSIF V_TEXT = 'Ã' THEN V_DECIMAL := 195;
ELSIF V_TEXT = 'Ä' THEN V_DECIMAL := 196;
ELSIF V_TEXT = 'Å' THEN V_DECIMAL := 197;
ELSIF V_TEXT = 'Æ' THEN V_DECIMAL := 198;
ELSIF V_TEXT = 'Ç' THEN V_DECIMAL := 199;
ELSIF V_TEXT = 'È' THEN V_DECIMAL := 200;
ELSIF V_TEXT = 'É' THEN V_DECIMAL := 201;
ELSIF V_TEXT = 'Ê' THEN V_DECIMAL := 202;
ELSIF V_TEXT = 'Ë' THEN V_DECIMAL := 203;
ELSIF V_TEXT = 'Ì' THEN V_DECIMAL := 204;
ELSIF V_TEXT = 'Í' THEN V_DECIMAL := 205;
ELSIF V_TEXT = 'Î' THEN V_DECIMAL := 206;
ELSIF V_TEXT = 'Ï' THEN V_DECIMAL := 207;
ELSIF V_TEXT = 'Ð' THEN V_DECIMAL := 208;
ELSIF V_TEXT = 'Ñ' THEN V_DECIMAL := 209;
ELSIF V_TEXT = 'Ò' THEN V_DECIMAL := 210;
ELSIF V_TEXT = 'Ó' THEN V_DECIMAL := 211;
ELSIF V_TEXT = 'Ô' THEN V_DECIMAL := 212;
ELSIF V_TEXT = 'Õ' THEN V_DECIMAL := 213;
ELSIF V_TEXT = 'Ö' THEN V_DECIMAL := 214;
ELSIF V_TEXT = '×' THEN V_DECIMAL := 215;
ELSIF V_TEXT = 'Ø' THEN V_DECIMAL := 216;
ELSIF V_TEXT = 'Ù' THEN V_DECIMAL := 217;
ELSIF V_TEXT = 'Ú' THEN V_DECIMAL := 218;
ELSIF V_TEXT = 'Û' THEN V_DECIMAL := 219;
ELSIF V_TEXT = 'Ü' THEN V_DECIMAL := 220;
ELSIF V_TEXT = 'Ý' THEN V_DECIMAL := 221;
ELSIF V_TEXT = 'Þ' THEN V_DECIMAL := 222;
ELSIF V_TEXT = 'ß' THEN V_DECIMAL := 223;
ELSIF V_TEXT = 'à' THEN V_DECIMAL := 224;
ELSIF V_TEXT = 'á' THEN V_DECIMAL := 225;
ELSIF V_TEXT = 'â' THEN V_DECIMAL := 226;
ELSIF V_TEXT = 'ã' THEN V_DECIMAL := 227;
ELSIF V_TEXT = 'ä' THEN V_DECIMAL := 228;
ELSIF V_TEXT = 'å' THEN V_DECIMAL := 229;
ELSIF V_TEXT = 'æ' THEN V_DECIMAL := 230;
ELSIF V_TEXT = 'ç' THEN V_DECIMAL := 231;
ELSIF V_TEXT = 'è' THEN V_DECIMAL := 232;
ELSIF V_TEXT = 'é' THEN V_DECIMAL := 233;
ELSIF V_TEXT = 'ê' THEN V_DECIMAL := 234;
ELSIF V_TEXT = 'ë' THEN V_DECIMAL := 235;
ELSIF V_TEXT = 'ì' THEN V_DECIMAL := 236;
ELSIF V_TEXT = 'í' THEN V_DECIMAL := 237;
ELSIF V_TEXT = 'î' THEN V_DECIMAL := 238;
ELSIF V_TEXT = 'ï' THEN V_DECIMAL := 239;
ELSIF V_TEXT = 'ð' THEN V_DECIMAL := 240;
ELSIF V_TEXT = 'ñ' THEN V_DECIMAL := 241;
ELSIF V_TEXT = 'ò' THEN V_DECIMAL := 242;
ELSIF V_TEXT = 'ó' THEN V_DECIMAL := 243;
ELSIF V_TEXT = 'ô' THEN V_DECIMAL := 244;
ELSIF V_TEXT = 'õ' THEN V_DECIMAL := 245;
ELSIF V_TEXT = 'ö' THEN V_DECIMAL := 246;
ELSIF V_TEXT = '÷' THEN V_DECIMAL := 247;
ELSIF V_TEXT = 'ø' THEN V_DECIMAL := 248;
ELSIF V_TEXT = 'ù' THEN V_DECIMAL := 249;
ELSIF V_TEXT = 'ú' THEN V_DECIMAL := 250;
ELSIF V_TEXT = 'û' THEN V_DECIMAL := 251;
ELSIF V_TEXT = 'ü' THEN V_DECIMAL := 252;
ELSIF V_TEXT = 'ý' THEN V_DECIMAL := 253;
ELSIF V_TEXT = 'þ' THEN V_DECIMAL := 254;
ELSIF V_TEXT = 'ÿ' THEN V_DECIMAL := 255;
ELSE RAISE_APPLICATION_ERROR(-20025,
                             'Erro: O caracter fornecido não é válido, ou não está presente na tabela usada.');
END IF;

 SELECT LISTAGG(MOD(TRUNC(V_DECIMAL/POWER(2, LEVEL - 1)),2)) WITHIN GROUP(ORDER BY LEVEL DESC)
   INTO V_BINARY
   FROM DUAL
CONNECT BY LEVEL <= 8;


  V_RESULT_BINARY := V_RESULT_BINARY || V_BINARY || ' ';


END LOOP;


ELSE V_BINARY_INPUT := RTRIM(REGEXP_REPLACE(SUBSTR(REGEXP_REPLACE(MESSAGE, '\s'), 1,
                       FLOOR(LENGTH(REGEXP_REPLACE(MESSAGE, '\s')) / 8) * 8),'([01]{8})','\1 '));


FOR BI IN (SELECT REGEXP_SUBSTR(V_BINARY_INPUT, '[01]{8}', 1, LEVEL) AS BINARY_NUMBER
             FROM DUAL
          CONNECT BY LEVEL <= REGEXP_COUNT(V_BINARY_INPUT, '[01]{8}'))
LOOP


 SELECT SUM(SUBSTR(BI.BINARY_NUMBER, LEVEL, 1) *
        POWER(2, LENGTH(BI.BINARY_NUMBER) -LEVEL))
   INTO V_DECIMAL
   FROM DUAL
CONNECT BY LEVEL <= 8;

IF V_DECIMAL = 32 THEN V_TEXT := ' ';
ELSIF V_DECIMAL = 33 THEN V_TEXT := '!';
ELSIF V_DECIMAL = 34 THEN V_TEXT := '"';
ELSIF V_DECIMAL = 35 THEN V_TEXT := '#';
ELSIF V_DECIMAL = 36 THEN V_TEXT := '$';
ELSIF V_DECIMAL = 37 THEN V_TEXT := '%';
ELSIF V_DECIMAL = 38 THEN V_TEXT := '&';
ELSIF V_DECIMAL = 39 THEN V_TEXT := CHR(39);
ELSIF V_DECIMAL = 40 THEN V_TEXT := '(';
ELSIF V_DECIMAL = 41 THEN V_TEXT := ')';
ELSIF V_DECIMAL = 42 THEN V_TEXT := '*';
ELSIF V_DECIMAL = 43 THEN V_TEXT := '+';
ELSIF V_DECIMAL = 44 THEN V_TEXT := ',';
ELSIF V_DECIMAL = 45 THEN V_TEXT := '-';
ELSIF V_DECIMAL = 46 THEN V_TEXT := '.';
ELSIF V_DECIMAL = 47 THEN V_TEXT := '/';
ELSIF V_DECIMAL = 48 THEN V_TEXT := '0';
ELSIF V_DECIMAL = 49 THEN V_TEXT := '1';
ELSIF V_DECIMAL = 50 THEN V_TEXT := '2';
ELSIF V_DECIMAL = 51 THEN V_TEXT := '3';
ELSIF V_DECIMAL = 52 THEN V_TEXT := '4';
ELSIF V_DECIMAL = 53 THEN V_TEXT := '5';
ELSIF V_DECIMAL = 54 THEN V_TEXT := '6';
ELSIF V_DECIMAL = 55 THEN V_TEXT := '7';
ELSIF V_DECIMAL = 56 THEN V_TEXT := '8';
ELSIF V_DECIMAL = 57 THEN V_TEXT := '9';
ELSIF V_DECIMAL = 58 THEN V_TEXT := ':';
ELSIF V_DECIMAL = 59 THEN V_TEXT := ';';
ELSIF V_DECIMAL = 60 THEN V_TEXT := '<';
ELSIF V_DECIMAL = 61 THEN V_TEXT := '=';
ELSIF V_DECIMAL = 62 THEN V_TEXT := '>';
ELSIF V_DECIMAL = 63 THEN V_TEXT := '?';
ELSIF V_DECIMAL = 64 THEN V_TEXT := '@';
ELSIF V_DECIMAL = 65 THEN V_TEXT := 'A';
ELSIF V_DECIMAL = 66 THEN V_TEXT := 'B';
ELSIF V_DECIMAL = 67 THEN V_TEXT := 'C';
ELSIF V_DECIMAL = 68 THEN V_TEXT := 'D';
ELSIF V_DECIMAL = 69 THEN V_TEXT := 'E';
ELSIF V_DECIMAL = 70 THEN V_TEXT := 'F';
ELSIF V_DECIMAL = 71 THEN V_TEXT := 'G';
ELSIF V_DECIMAL = 72 THEN V_TEXT := 'H';
ELSIF V_DECIMAL = 73 THEN V_TEXT := 'I';
ELSIF V_DECIMAL = 74 THEN V_TEXT := 'J';
ELSIF V_DECIMAL = 75 THEN V_TEXT := 'K';
ELSIF V_DECIMAL = 76 THEN V_TEXT := 'L';
ELSIF V_DECIMAL = 77 THEN V_TEXT := 'M';
ELSIF V_DECIMAL = 78 THEN V_TEXT := 'N';
ELSIF V_DECIMAL = 79 THEN V_TEXT := 'O';
ELSIF V_DECIMAL = 80 THEN V_TEXT := 'P';
ELSIF V_DECIMAL = 81 THEN V_TEXT := 'Q';
ELSIF V_DECIMAL = 82 THEN V_TEXT := 'R';
ELSIF V_DECIMAL = 83 THEN V_TEXT := 'S';
ELSIF V_DECIMAL = 84 THEN V_TEXT := 'T';
ELSIF V_DECIMAL = 85 THEN V_TEXT := 'U';
ELSIF V_DECIMAL = 86 THEN V_TEXT := 'V';
ELSIF V_DECIMAL = 87 THEN V_TEXT := 'W';
ELSIF V_DECIMAL = 88 THEN V_TEXT := 'X';
ELSIF V_DECIMAL = 89 THEN V_TEXT := 'Y';
ELSIF V_DECIMAL = 90 THEN V_TEXT := 'Z';
ELSIF V_DECIMAL = 91 THEN V_TEXT := '[';
ELSIF V_DECIMAL = 92 THEN V_TEXT := '\';
ELSIF V_DECIMAL = 93 THEN V_TEXT := ']';
ELSIF V_DECIMAL = 94 THEN V_TEXT := '^';
ELSIF V_DECIMAL = 95 THEN V_TEXT := '_';
ELSIF V_DECIMAL = 96 THEN V_TEXT := '`';
ELSIF V_DECIMAL = 97 THEN V_TEXT := 'a';
ELSIF V_DECIMAL = 98 THEN V_TEXT := 'b';
ELSIF V_DECIMAL = 99 THEN V_TEXT := 'c';
ELSIF V_DECIMAL = 100 THEN V_TEXT := 'd';
ELSIF V_DECIMAL = 101 THEN V_TEXT := 'e';
ELSIF V_DECIMAL = 102 THEN V_TEXT := 'f';
ELSIF V_DECIMAL = 103 THEN V_TEXT := 'g';
ELSIF V_DECIMAL = 104 THEN V_TEXT := 'h';
ELSIF V_DECIMAL = 105 THEN V_TEXT := 'i';
ELSIF V_DECIMAL = 106 THEN V_TEXT := 'j';
ELSIF V_DECIMAL = 107 THEN V_TEXT := 'k';
ELSIF V_DECIMAL = 108 THEN V_TEXT := 'l';
ELSIF V_DECIMAL = 109 THEN V_TEXT := 'm';
ELSIF V_DECIMAL = 110 THEN V_TEXT := 'n';
ELSIF V_DECIMAL = 111 THEN V_TEXT := 'o';
ELSIF V_DECIMAL = 112 THEN V_TEXT := 'p';
ELSIF V_DECIMAL = 113 THEN V_TEXT := 'q';
ELSIF V_DECIMAL = 114 THEN V_TEXT := 'r';
ELSIF V_DECIMAL = 115 THEN V_TEXT := 's';
ELSIF V_DECIMAL = 116 THEN V_TEXT := 't';
ELSIF V_DECIMAL = 117 THEN V_TEXT := 'u';
ELSIF V_DECIMAL = 118 THEN V_TEXT := 'v';
ELSIF V_DECIMAL = 119 THEN V_TEXT := 'w';
ELSIF V_DECIMAL = 120 THEN V_TEXT := 'x';
ELSIF V_DECIMAL = 121 THEN V_TEXT := 'y';
ELSIF V_DECIMAL = 122 THEN V_TEXT := 'z';
ELSIF V_DECIMAL = 123 THEN V_TEXT := '{';
ELSIF V_DECIMAL = 124 THEN V_TEXT := '|';
ELSIF V_DECIMAL = 125 THEN V_TEXT := '}';
ELSIF V_DECIMAL = 126 THEN V_TEXT := '~';
ELSIF V_DECIMAL = 128 THEN V_TEXT := '€';
ELSIF V_DECIMAL = 130 THEN V_TEXT := '‚';
ELSIF V_DECIMAL = 131 THEN V_TEXT := 'ƒ';
ELSIF V_DECIMAL = 132 THEN V_TEXT := '„';
ELSIF V_DECIMAL = 133 THEN V_TEXT := '…';
ELSIF V_DECIMAL = 134 THEN V_TEXT := '†';
ELSIF V_DECIMAL = 135 THEN V_TEXT := '‡';
ELSIF V_DECIMAL = 136 THEN V_TEXT := 'ˆ';
ELSIF V_DECIMAL = 137 THEN V_TEXT := '‰';
ELSIF V_DECIMAL = 138 THEN V_TEXT := 'Š';
ELSIF V_DECIMAL = 139 THEN V_TEXT := '‹';
ELSIF V_DECIMAL = 140 THEN V_TEXT := 'Œ';
ELSIF V_DECIMAL = 142 THEN V_TEXT := 'Ž';
ELSIF V_DECIMAL = 145 THEN V_TEXT := '‘';
ELSIF V_DECIMAL = 146 THEN V_TEXT := '’';
ELSIF V_DECIMAL = 147 THEN V_TEXT := '“';
ELSIF V_DECIMAL = 148 THEN V_TEXT := '”';
ELSIF V_DECIMAL = 149 THEN V_TEXT := '•';
ELSIF V_DECIMAL = 150 THEN V_TEXT := '–';
ELSIF V_DECIMAL = 151 THEN V_TEXT := '—';
ELSIF V_DECIMAL = 153 THEN V_TEXT := '™';
ELSIF V_DECIMAL = 154 THEN V_TEXT := 'š';
ELSIF V_DECIMAL = 155 THEN V_TEXT := '›';
ELSIF V_DECIMAL = 156 THEN V_TEXT := 'œ';
ELSIF V_DECIMAL = 158 THEN V_TEXT := 'ž';
ELSIF V_DECIMAL = 159 THEN V_TEXT := 'Ÿ';
ELSIF V_DECIMAL = 161 THEN V_TEXT := '¡';
ELSIF V_DECIMAL = 162 THEN V_TEXT := '¢';
ELSIF V_DECIMAL = 163 THEN V_TEXT := '£';
ELSIF V_DECIMAL = 164 THEN V_TEXT := '¤';
ELSIF V_DECIMAL = 165 THEN V_TEXT := '¥';
ELSIF V_DECIMAL = 166 THEN V_TEXT := '¦';
ELSIF V_DECIMAL = 167 THEN V_TEXT := '§';
ELSIF V_DECIMAL = 168 THEN V_TEXT := '¨';
ELSIF V_DECIMAL = 169 THEN V_TEXT := '©';
ELSIF V_DECIMAL = 170 THEN V_TEXT := 'ª';
ELSIF V_DECIMAL = 171 THEN V_TEXT := '«';
ELSIF V_DECIMAL = 172 THEN V_TEXT := '¬';
ELSIF V_DECIMAL = 174 THEN V_TEXT := '®';
ELSIF V_DECIMAL = 175 THEN V_TEXT := '¯';
ELSIF V_DECIMAL = 176 THEN V_TEXT := '°';
ELSIF V_DECIMAL = 177 THEN V_TEXT := '±';
ELSIF V_DECIMAL = 178 THEN V_TEXT := '²';
ELSIF V_DECIMAL = 179 THEN V_TEXT := '³';
ELSIF V_DECIMAL = 180 THEN V_TEXT := '´';
ELSIF V_DECIMAL = 181 THEN V_TEXT := 'µ';
ELSIF V_DECIMAL = 182 THEN V_TEXT := '¶';
ELSIF V_DECIMAL = 183 THEN V_TEXT := '·';
ELSIF V_DECIMAL = 184 THEN V_TEXT := '¸';
ELSIF V_DECIMAL = 185 THEN V_TEXT := '¹';
ELSIF V_DECIMAL = 186 THEN V_TEXT := 'º';
ELSIF V_DECIMAL = 187 THEN V_TEXT := '»';
ELSIF V_DECIMAL = 188 THEN V_TEXT := '¼';
ELSIF V_DECIMAL = 189 THEN V_TEXT := '½';
ELSIF V_DECIMAL = 190 THEN V_TEXT := '¾';
ELSIF V_DECIMAL = 191 THEN V_TEXT := '¿';
ELSIF V_DECIMAL = 192 THEN V_TEXT := 'À';
ELSIF V_DECIMAL = 193 THEN V_TEXT := 'Á';
ELSIF V_DECIMAL = 194 THEN V_TEXT := 'Â';
ELSIF V_DECIMAL = 195 THEN V_TEXT := 'Ã';
ELSIF V_DECIMAL = 196 THEN V_TEXT := 'Ä';
ELSIF V_DECIMAL = 197 THEN V_TEXT := 'Å';
ELSIF V_DECIMAL = 198 THEN V_TEXT := 'Æ';
ELSIF V_DECIMAL = 199 THEN V_TEXT := 'Ç';
ELSIF V_DECIMAL = 200 THEN V_TEXT := 'È';
ELSIF V_DECIMAL = 201 THEN V_TEXT := 'É';
ELSIF V_DECIMAL = 202 THEN V_TEXT := 'Ê';
ELSIF V_DECIMAL = 203 THEN V_TEXT := 'Ë';
ELSIF V_DECIMAL = 204 THEN V_TEXT := 'Ì';
ELSIF V_DECIMAL = 205 THEN V_TEXT := 'Í';
ELSIF V_DECIMAL = 206 THEN V_TEXT := 'Î';
ELSIF V_DECIMAL = 207 THEN V_TEXT := 'Ï';
ELSIF V_DECIMAL = 208 THEN V_TEXT := 'Ð';
ELSIF V_DECIMAL = 209 THEN V_TEXT := 'Ñ';
ELSIF V_DECIMAL = 210 THEN V_TEXT := 'Ò';
ELSIF V_DECIMAL = 211 THEN V_TEXT := 'Ó';
ELSIF V_DECIMAL = 212 THEN V_TEXT := 'Ô';
ELSIF V_DECIMAL = 213 THEN V_TEXT := 'Õ';
ELSIF V_DECIMAL = 214 THEN V_TEXT := 'Ö';
ELSIF V_DECIMAL = 215 THEN V_TEXT := '×';
ELSIF V_DECIMAL = 216 THEN V_TEXT := 'Ø';
ELSIF V_DECIMAL = 217 THEN V_TEXT := 'Ù';
ELSIF V_DECIMAL = 218 THEN V_TEXT := 'Ú';
ELSIF V_DECIMAL = 219 THEN V_TEXT := 'Û';
ELSIF V_DECIMAL = 220 THEN V_TEXT := 'Ü';
ELSIF V_DECIMAL = 221 THEN V_TEXT := 'Ý';
ELSIF V_DECIMAL = 222 THEN V_TEXT := 'Þ';
ELSIF V_DECIMAL = 223 THEN V_TEXT := 'ß';
ELSIF V_DECIMAL = 224 THEN V_TEXT := 'à';
ELSIF V_DECIMAL = 225 THEN V_TEXT := 'á';
ELSIF V_DECIMAL = 226 THEN V_TEXT := 'â';
ELSIF V_DECIMAL = 227 THEN V_TEXT := 'ã';
ELSIF V_DECIMAL = 228 THEN V_TEXT := 'ä';
ELSIF V_DECIMAL = 229 THEN V_TEXT := 'å';
ELSIF V_DECIMAL = 230 THEN V_TEXT := 'æ';
ELSIF V_DECIMAL = 231 THEN V_TEXT := 'ç';
ELSIF V_DECIMAL = 232 THEN V_TEXT := 'è';
ELSIF V_DECIMAL = 233 THEN V_TEXT := 'é';
ELSIF V_DECIMAL = 234 THEN V_TEXT := 'ê';
ELSIF V_DECIMAL = 235 THEN V_TEXT := 'ë';
ELSIF V_DECIMAL = 236 THEN V_TEXT := 'ì';
ELSIF V_DECIMAL = 237 THEN V_TEXT := 'í';
ELSIF V_DECIMAL = 238 THEN V_TEXT := 'î';
ELSIF V_DECIMAL = 239 THEN V_TEXT := 'ï';
ELSIF V_DECIMAL = 240 THEN V_TEXT := 'ð';
ELSIF V_DECIMAL = 241 THEN V_TEXT := 'ñ';
ELSIF V_DECIMAL = 242 THEN V_TEXT := 'ò';
ELSIF V_DECIMAL = 243 THEN V_TEXT := 'ó';
ELSIF V_DECIMAL = 244 THEN V_TEXT := 'ô';
ELSIF V_DECIMAL = 245 THEN V_TEXT := 'õ';
ELSIF V_DECIMAL = 246 THEN V_TEXT := 'ö';
ELSIF V_DECIMAL = 247 THEN V_TEXT := '÷';
ELSIF V_DECIMAL = 248 THEN V_TEXT := 'ø';
ELSIF V_DECIMAL = 249 THEN V_TEXT := 'ù';
ELSIF V_DECIMAL = 250 THEN V_TEXT := 'ú';
ELSIF V_DECIMAL = 251 THEN V_TEXT := 'û';
ELSIF V_DECIMAL = 252 THEN V_TEXT := 'ü';
ELSIF V_DECIMAL = 253 THEN V_TEXT := 'ý';
ELSIF V_DECIMAL = 254 THEN V_TEXT := 'þ';
ELSIF V_DECIMAL = 255 THEN V_TEXT := 'ÿ';
ELSE RAISE_APPLICATION_ERROR(-20024,
                             'Erro: O valor binário fornecido não é válido, ou não está presente na tabela usada.');
END IF;

V_RESULT_TEXT := V_RESULT_TEXT || V_TEXT;

END LOOP;

END IF;


IF V_RESULT_TEXT IS NULL AND V_RESULT_NULL IS NULL AND V_RESULT_BINARY IS NULL THEN

V_PAYLOAD := V_RESULT_NULL;

ELSIF V_RESULT_TEXT IS NULL AND V_RESULT_BINARY IS NOT NULL THEN

V_PAYLOAD := RTRIM(V_RESULT_BINARY);

ELSE V_PAYLOAD := V_RESULT_TEXT;

END IF;

RETURN V_PAYLOAD;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20085, 'Erro: O valor é maior do que o tamanho permitido para a variável message.');

END;

FUNCTION ACENTLESS(TEXT IN VARCHAR2) -- RETIRA OS ACENTOS DA LETRAS
RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: ACENTLESS                                                                                                           ####
  ####  DATA CRIAÇÃO: 02/12/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função ACENTLESS, retira os acentos das letras do texto que o usuário passou no parâmetro TEXT.           ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/

V_TEXT VARCHAR2(4000);
R_TEXT VARCHAR2(4000);

BEGIN

V_TEXT := TEXT;


R_TEXT := TRANSLATE(V_TEXT,
                    'äáàâãëéêèïìîíöòóôõüûùúüÿýçñÄÁÀÂÃËÉÊÈÏÌÎÍÖÒÓÔÕÜÛÙÚÜÝÇÑ',
                    'aaaaaeeeeiiiiooooouuuuuyycnAAAAAEEEEIIIIOOOOOUUUUUYCN');

RETURN R_TEXT;

END;

FUNCTION MORSECODEX(MESSAGE IN VARCHAR2, -- CÓDIGO MORSE OU TEXTO
                    ACTION  IN VARCHAR2  -- 1 PARA CODIFICAR E 2 PARA DECODIFICAR
                    )
RETURN VARCHAR2 IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: MORSECODEX                                                                                                          ####
  ####  DATA CRIAÇÃO: 03/12/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função MORSECODEX codifica e decodifica mensagens entre texto e código Morse. Com base no parâmetro       ####
  ####  ACTION, ela converte texto para Morse (quando ACTION é 1) ou Morse para texto (quando ACTION é 2). A função valida          ####
  ####  os parâmetros de entrada, garantindo que sejam válidos e não nulos. Ela mapeia cada caractere do texto para seu             ####
  ####  equivalente em Morse e, na decodificação, faz a conversão inversa. Se algum erro ocorrer durante o processamento,           ####
  ####  a função gera mensagens de erro detalhadas.                                                                                 ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/



V_PAYLOAD       VARCHAR2(4000);
V_MODE          PLS_INTEGER;
V_MORSE         VARCHAR2(4000);
V_TEXT          VARCHAR2(4000);
V_MORSE_INPUT   VARCHAR2(4000);
V_TEXT_INPUT    VARCHAR2(4000);
V_RESULT_MORSE  VARCHAR2(4000);
V_RESULT_TEXT   VARCHAR2(4000);
V_RESULT_NULL   VARCHAR2(4000);

BEGIN

BEGIN

 V_MODE := TRUNC(ABS(ACTION));

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: O valor fornecido para action não é válido. Apenas números são permitidos.');

END;

IF V_MODE IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro action não pode ser null.');
ELSIF V_MODE NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o parâmetro action não é válido. O use 1 para codificar ou 2 para decodificar.');
END IF;

IF TRIM(UPPER(HEITOR_LIBRARY.ACENTLESS(MESSAGE))) IS NULL THEN

V_RESULT_NULL := NULL;

ELSIF TRIM(UPPER(HEITOR_LIBRARY.ACENTLESS(MESSAGE))) IS NOT NULL AND V_MODE = 1 THEN

V_TEXT_INPUT := TRIM(UPPER(HEITOR_LIBRARY.ACENTLESS(MESSAGE)));

FOR TXT IN 1 .. LENGTH(V_TEXT_INPUT)
LOOP

 V_TEXT := SUBSTR(V_TEXT_INPUT,TXT,1);

IF V_TEXT = 'A' THEN V_MORSE := '.-';
ELSIF V_TEXT = 'B' THEN V_MORSE := '-...';
ELSIF V_TEXT = 'C' THEN V_MORSE := '-.-.';
ELSIF V_TEXT = 'D' THEN V_MORSE := '-..';
ELSIF V_TEXT = 'E' THEN V_MORSE := '.';
ELSIF V_TEXT = 'F' THEN V_MORSE := '..-.';
ELSIF V_TEXT = 'G' THEN V_MORSE := '--.';
ELSIF V_TEXT = 'H' THEN V_MORSE := '....';
ELSIF V_TEXT = 'I' THEN V_MORSE := '..';
ELSIF V_TEXT = 'J' THEN V_MORSE := '.---';
ELSIF V_TEXT = 'K' THEN V_MORSE := '-.-';
ELSIF V_TEXT = 'L' THEN V_MORSE := '.-..';
ELSIF V_TEXT = 'M' THEN V_MORSE := '--';
ELSIF V_TEXT = 'N' THEN V_MORSE := '-.';
ELSIF V_TEXT = 'O' THEN V_MORSE := '---';
ELSIF V_TEXT = 'P' THEN V_MORSE := '.--.';
ELSIF V_TEXT = 'Q' THEN V_MORSE := '--.-';
ELSIF V_TEXT = 'R' THEN V_MORSE := '.-.';
ELSIF V_TEXT = 'S' THEN V_MORSE := '...';
ELSIF V_TEXT = 'T' THEN V_MORSE := '-';
ELSIF V_TEXT = 'U' THEN V_MORSE := '..-';
ELSIF V_TEXT = 'V' THEN V_MORSE := '...-';
ELSIF V_TEXT = 'W' THEN V_MORSE := '.--';
ELSIF V_TEXT = 'X' THEN V_MORSE := '-..-';
ELSIF V_TEXT = 'Y' THEN V_MORSE := '-.--';
ELSIF V_TEXT = 'Z' THEN V_MORSE := '--..';
ELSIF V_TEXT = '0' THEN V_MORSE := '-----';
ELSIF V_TEXT = '1' THEN V_MORSE := '.----';
ELSIF V_TEXT = '2' THEN V_MORSE := '..---';
ELSIF V_TEXT = '3' THEN V_MORSE := '...--';
ELSIF V_TEXT = '4' THEN V_MORSE := '....-';
ELSIF V_TEXT = '5' THEN V_MORSE := '.....';
ELSIF V_TEXT = '6' THEN V_MORSE := '-....';
ELSIF V_TEXT = '7' THEN V_MORSE := '--...';
ELSIF V_TEXT = '8' THEN V_MORSE := '---..';
ELSIF V_TEXT = '9' THEN V_MORSE := '----.';
ELSIF V_TEXT = '.' THEN V_MORSE := '.-.-.-';
ELSIF V_TEXT = ',' THEN V_MORSE := '--..--';
ELSIF V_TEXT = '?' THEN V_MORSE := '..--..';
ELSIF V_TEXT = CHR(39) THEN V_MORSE := '.----.';
ELSIF V_TEXT = '!' THEN V_MORSE := '-.-.--';
ELSIF V_TEXT = '/' THEN V_MORSE := '-..-.';
ELSIF V_TEXT = '(' THEN V_MORSE := '-.--.';
ELSIF V_TEXT = ')' THEN V_MORSE := '-.--.-';
ELSIF V_TEXT = '&' THEN V_MORSE := '.-...';
ELSIF V_TEXT = ':' THEN V_MORSE := '---...';
ELSIF V_TEXT = ';' THEN V_MORSE := '-.-.-.';
ELSIF V_TEXT = '=' THEN V_MORSE := '-...-';
ELSIF V_TEXT = '+' THEN V_MORSE := '.-.-.';
ELSIF V_TEXT = '-' THEN V_MORSE := '-....-';
ELSIF V_TEXT = '_' THEN V_MORSE := '..--.-';
ELSIF V_TEXT = '"' THEN V_MORSE := '.-..-.';
ELSIF V_TEXT = '$' THEN V_MORSE := '...-..-';
ELSIF V_TEXT = '@' THEN V_MORSE := '.--.-.';
ELSIF V_TEXT = ' ' THEN V_MORSE := '       ';
ELSE RAISE_APPLICATION_ERROR(-20024,
                             'Erro: O caracter fornecido não é válido, ou não está presente na tabela usada.');
END IF;


V_RESULT_MORSE := V_RESULT_MORSE || V_MORSE || ' ';

END LOOP;

ELSE

V_MORSE_INPUT := REGEXP_REPLACE(MESSAGE, '\s{7}','///////');

FOR MS IN (SELECT REGEXP_SUBSTR(V_MORSE_INPUT, '[\/]{7}|[-.]+', 1, LEVEL) AS CD_MORSE
             FROM DUAL
          CONNECT BY LEVEL <= REGEXP_COUNT(V_MORSE_INPUT, '[\/]{7}|[-.]+'))
LOOP

IF MS.CD_MORSE = '.-' THEN V_TEXT := 'A';
ELSIF MS.CD_MORSE = '-...' THEN V_TEXT := 'B';
ELSIF MS.CD_MORSE = '-.-.' THEN V_TEXT := 'C';
ELSIF MS.CD_MORSE = '-..' THEN V_TEXT := 'D';
ELSIF MS.CD_MORSE = '.' THEN V_TEXT := 'E';
ELSIF MS.CD_MORSE = '..-.' THEN V_TEXT := 'F';
ELSIF MS.CD_MORSE = '--.' THEN V_TEXT := 'G';
ELSIF MS.CD_MORSE = '....' THEN V_TEXT := 'H';
ELSIF MS.CD_MORSE = '..' THEN V_TEXT := 'I';
ELSIF MS.CD_MORSE = '.---' THEN V_TEXT := 'J';
ELSIF MS.CD_MORSE = '-.-' THEN V_TEXT := 'K';
ELSIF MS.CD_MORSE = '.-..' THEN V_TEXT := 'L';
ELSIF MS.CD_MORSE = '--' THEN V_TEXT := 'M';
ELSIF MS.CD_MORSE = '-.' THEN V_TEXT := 'N';
ELSIF MS.CD_MORSE = '---' THEN V_TEXT := 'O';
ELSIF MS.CD_MORSE = '.--.' THEN V_TEXT := 'P';
ELSIF MS.CD_MORSE = '--.-' THEN V_TEXT := 'Q';
ELSIF MS.CD_MORSE = '.-.' THEN V_TEXT := 'R';
ELSIF MS.CD_MORSE = '...' THEN V_TEXT := 'S';
ELSIF MS.CD_MORSE = '-' THEN V_TEXT := 'T';
ELSIF MS.CD_MORSE = '..-' THEN V_TEXT := 'U';
ELSIF MS.CD_MORSE = '...-' THEN V_TEXT := 'V';
ELSIF MS.CD_MORSE = '.--' THEN V_TEXT := 'W';
ELSIF MS.CD_MORSE = '-..-' THEN V_TEXT := 'X';
ELSIF MS.CD_MORSE = '-.--' THEN V_TEXT := 'Y';
ELSIF MS.CD_MORSE = '--..' THEN V_TEXT := 'Z';
ELSIF MS.CD_MORSE = '-----' THEN V_TEXT := '0';
ELSIF MS.CD_MORSE = '.----' THEN V_TEXT := '1';
ELSIF MS.CD_MORSE = '..---' THEN V_TEXT := '2';
ELSIF MS.CD_MORSE = '...--' THEN V_TEXT := '3';
ELSIF MS.CD_MORSE = '....-' THEN V_TEXT := '4';
ELSIF MS.CD_MORSE = '.....' THEN V_TEXT := '5';
ELSIF MS.CD_MORSE = '-....' THEN V_TEXT := '6';
ELSIF MS.CD_MORSE = '--...' THEN V_TEXT := '7';
ELSIF MS.CD_MORSE = '---..' THEN V_TEXT := '8';
ELSIF MS.CD_MORSE = '----.' THEN V_TEXT := '9';
ELSIF MS.CD_MORSE = '.-.-.-' THEN V_TEXT := '.';
ELSIF MS.CD_MORSE = '--..--' THEN V_TEXT := ',';
ELSIF MS.CD_MORSE = '..--..' THEN V_TEXT := '?';
ELSIF MS.CD_MORSE = '.----.' THEN V_TEXT := CHR(39);
ELSIF MS.CD_MORSE = '-.-.--' THEN V_TEXT := '!';
ELSIF MS.CD_MORSE = '-..-.' THEN V_TEXT := '/';
ELSIF MS.CD_MORSE = '-.--.' THEN V_TEXT := '(';
ELSIF MS.CD_MORSE = '-.--.-' THEN V_TEXT := ')';
ELSIF MS.CD_MORSE = '.-...' THEN V_TEXT := '&';
ELSIF MS.CD_MORSE = '---...' THEN V_TEXT := ':';
ELSIF MS.CD_MORSE = '-.-.-.' THEN V_TEXT := ';';
ELSIF MS.CD_MORSE = '-...-' THEN V_TEXT := '=';
ELSIF MS.CD_MORSE = '.-.-.' THEN V_TEXT := '+';
ELSIF MS.CD_MORSE = '-....-' THEN V_TEXT := '-';
ELSIF MS.CD_MORSE = '..--.-' THEN V_TEXT := '_';
ELSIF MS.CD_MORSE = '.-..-.' THEN V_TEXT := '"';
ELSIF MS.CD_MORSE = '...-..-' THEN V_TEXT := '$';
ELSIF MS.CD_MORSE = '.--.-.' THEN V_TEXT := '@';
ELSIF MS.CD_MORSE = '///////' THEN V_TEXT := ' ';
ELSE RAISE_APPLICATION_ERROR(-20024,
                             'Erro: O código morse fornecido não é válido, ou não está presente na tabela usada.');
END IF;

V_RESULT_TEXT := V_RESULT_TEXT || V_TEXT;

END LOOP;

END IF;



IF V_RESULT_TEXT IS NULL AND V_RESULT_NULL IS NULL AND V_RESULT_MORSE IS NULL THEN

V_PAYLOAD := V_RESULT_NULL;

ELSIF V_RESULT_TEXT IS NULL AND V_RESULT_MORSE IS NOT NULL THEN

V_PAYLOAD := REGEXP_REPLACE(RTRIM(V_RESULT_MORSE),'\s{7,}','       ');

ELSE V_PAYLOAD := V_RESULT_TEXT;

END IF;

RETURN V_PAYLOAD;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20085, 'Erro: O valor é maior do que o tamanho permitido para a variável message.');

END;


FUNCTION DAMERAU_LEVENSHTEIN(TEXT1 IN VARCHAR2, -- TEXTO 1
                             TEXT2 IN VARCHAR2  -- TEXTO 2
                             )
RETURN NUMBER IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: DAMERAU_LEVENSHTEIN                                                                                                 ####
  ####  DATA CRIAÇÃO: 04/12/2024                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função DAMERAU_LEVENSHTEIN calcula a distância entre duas palavras, contando o número mínimo              ####
  ####  de operações necessárias para transformar uma na outra. As operações consideradas são inserir, remover ou substituir        ####
  ####  caracteres, além de trocar a posição de caracteres adjacentes. Ela compara as palavras e retorna um valor que indica        ####
  ####  o quão diferentes elas são, levando em conta erros comuns de digitação ou variações.                                        ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/



  TMH1     NUMBER;             -- TAMANHO DA PRIMEIRA STRING
  TMH2     NUMBER;             -- TAMANHO DA SEGUNDA STRING
  TABELA   SYS.ODCINUMBERLIST; -- MATRIZ VIRTUAL
  I        NUMBER;             -- ÍNDICE PARA A STRING 1
  J        NUMBER;             -- ÍNDICE PARA A STRING 2
  CUSTO    NUMBER;             -- CUSTO DE SUBSTITUIÇÃO
  DISTANCE NUMBER;             -- RESULTADO DA DISTÂNCIA

BEGIN

 TMH1   := LENGTH(TEXT1);
 TMH2   := LENGTH(TEXT2);
 TABELA := SYS.ODCINUMBERLIST();

  IF TEXT1 IS NULL OR TEXT2 IS NULL THEN

  DISTANCE := NULL;

  ELSE

  -- INICIALIZA A MATRIZ PARA (TMH1+1) X (TMH2+1)
  TABELA.EXTEND((TMH1 + 1) * (TMH2 + 1));


  -- PREENCHE AS BORDAS DA MATRIZ
  FOR I IN 0 .. TMH1 LOOP
      TABELA(I * (TMH2 + 1) + 1) := I; -- PRIMEIRA COLUNA
  END LOOP;


  FOR J IN 0 .. TMH2 LOOP
      TABELA(J + 1) := J; -- PRIMEIRA LINHA
  END LOOP;


  -- PREENCHE O RESTANTE DA MATRIZ
  FOR I IN 1 .. TMH1 LOOP
      FOR J IN 1 .. TMH2 LOOP


          -- CALCULA O CUSTO DE SUBSTITUIÇÃO
          CUSTO := CASE
                    WHEN SUBSTR(TEXT1, I, 1) = SUBSTR(TEXT2, J, 1) THEN 0
                    ELSE 1
                  END;


          -- CALCULA O MENOR CUSTO PARA A CÉLULA ATUAL
              TABELA(I * (TMH2 + 1) + J + 1) := LEAST(
              TABELA((I - 1) * (TMH2 + 1) + J + 1) + 1,  -- DELEÇÃO
              TABELA(I * (TMH2 + 1) + J) + 1,            -- INSERÇÃO
              TABELA((I - 1) * (TMH2 + 1) + J) + CUSTO   -- SUBSTITUIÇÃO
          );


          -- VERIFICA A POSSIBILIDADE DE TRANSPOSIÇÃO
          IF I > 1 AND J > 1 AND SUBSTR(TEXT1, I, 1) = SUBSTR(TEXT2, J - 1, 1)
             AND SUBSTR(TEXT1, I - 1, 1) = SUBSTR(TEXT2, J, 1) THEN
              TABELA(I * (TMH2 + 1) + J + 1) := LEAST(
                  TABELA(I * (TMH2 + 1) + J + 1),
                  TABELA((I - 2) * (TMH2 + 1) + J - 1) + CUSTO -- TRANSPOSIÇÃO
              );
          END IF;

      END LOOP;

  END LOOP;

  -- RETORNA A DISTÂNCIA FINAL
  DISTANCE := TABELA(TMH1 * (TMH2 + 1) + TMH2 + 1);

END IF;

  RETURN DISTANCE;

END;

FUNCTION DOCFORMAT(DOCNUMBER IN VARCHAR2, -- CPF OU CPNJ
                   ACTION    IN VARCHAR2  -- 1 PARA FORMATAR 2 PARA DESFORMATAR
                   )
RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: DOCFORMAT                                                                                                           ####
  ####  DATA CRIAÇÃO: 04/12/2024                                                                                                    ####
  ####  DATA MODIFICAÇÃO: 29/06/2025                                                                                                ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função DOCFORMAT recebe um número de documento (DOCNUMBER) e uma ação (ACTION), formatando ou             ####
  ####  desformatando o valor. Se a ação for 1, a função formata o CPF (formato XXX.XXX.XXX-XX) ou                                  ####
  ####  CNPJ (formato XX.XXX.XXX/XXXX-XX). Se for 2, ela remove qualquer formatação, retornando apenas os números.                  ####
  ####  Validações garantem que a entrada e os parâmetros estejam corretos, e erros específicos são retornados se                   ####
  ####  houver inconsistências.                                                                                                     ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_FORMATER  PLS_INTEGER;
V_CPF_CNPJ  VARCHAR2(14);
V_RESULT_FT VARCHAR2(18);

BEGIN

BEGIN

V_FORMATER := TRUNC(ABS(ACTION));

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: O valor fornecido para action não é válido. Apenas números são permitidos.');

END;

V_CPF_CNPJ := REGEXP_REPLACE(TRIM(DOCNUMBER),'[^[:alnum:]]');

IF V_FORMATER IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro action não pode ser null.');

ELSIF V_FORMATER NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o action não é válido. O use 1 para formatar ou 2 para desformatar.');

ELSIF REGEXP_REPLACE(V_CPF_CNPJ,'[^[:alpha:]]') IS NOT NULL THEN
  RAISE_APPLICATION_ERROR(-20002,
                          'Erro: O valor fornecido para o docnumber não é válido. Apenas números são permitidos.');

ELSIF LENGTH(V_CPF_CNPJ) NOT IN (11, 14) THEN
  RAISE_APPLICATION_ERROR(-20002,
                          'Erro: O tamanho fornecido para o docnumber não é válido.');

END IF;

IF V_CPF_CNPJ IS NOT NULL THEN

IF V_FORMATER = 1 THEN

IF LENGTH(V_CPF_CNPJ) = 11 THEN

V_RESULT_FT := REGEXP_REPLACE(V_CPF_CNPJ, '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');

ELSE

V_RESULT_FT := REGEXP_REPLACE(V_CPF_CNPJ, '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5');

END IF;

ELSE

V_RESULT_FT := V_CPF_CNPJ;

END IF;

ELSE

V_RESULT_FT := NULL;

END IF;

RETURN V_RESULT_FT;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20085, 'Erro: O valor é maior do que o tamanho permitido para a variável docnumber.');

END;

FUNCTION VALIDUSDOC(NUMDOC IN VARCHAR2, TIPODOC IN VARCHAR2)
RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: VALIDUSDOC                                                                                                          ####
  ####  DATA CRIAÇÃO: 04/12/2024                                                                                                    ####
  ####  DATA MODIFICAÇÃO: 29/06/2025                                                                                                ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função VALIDUSDOC valida documentos como CPF, CNPJ, CNH e RG. Ela remove caracteres inválidos, ajusta o   ####
  ####  tamanho e verifica se o número é válido usando cálculos específicos para cada tipo, como somas ponderadas                   ####
  ####  e dígitos verificadores. Se o documento for válido, retorna 'S'; caso contrário, 'N'. Além disso,                           ####
  ####  trata erros e valores inválidos com mensagens claras.                                                                       ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_RESULT_VLD VARCHAR2(1);
V_CPF_CNPJ   VARCHAR2(18);
DGT1         NUMBER;
DGT2         NUMBER;
SOMA         NUMBER;
PS1          PLS_INTEGER;
PS2          PLS_INTEGER;
FACTOR       NUMBER;
V_TIPODOC    VARCHAR2(4);
V_INCR_DGT2  NUMBER;
V_X          VARCHAR2(2);

BEGIN

V_TIPODOC  := UPPER(TIPODOC);
V_CPF_CNPJ := REGEXP_REPLACE(TRIM(NUMDOC),'[^[:alnum:]]');

IF V_TIPODOC IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro tipodoc não pode ser null.');

ELSIF V_TIPODOC NOT IN ('CPF', 'CNPJ', 'CNH', 'RG') THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o tipodoc não é válido. O use CPF, CNPJ, CNH ou RG.');

ELSIF REGEXP_REPLACE(V_CPF_CNPJ,'[^[:alpha:]]') IS NOT NULL THEN
  RAISE_APPLICATION_ERROR(-20084,
                          'Erro: O valor fornecido para o numdoc não é válido. Apenas números são permitidos.');

END IF;

IF V_TIPODOC IN ('CPF','CNH') THEN

V_CPF_CNPJ := LPAD(V_CPF_CNPJ,11,'0');

ELSIF V_TIPODOC IN ('CNPJ') THEN

V_CPF_CNPJ := LPAD(V_CPF_CNPJ,14,'0');

ELSIF V_TIPODOC IN ('RG') THEN

IF LENGTH(V_CPF_CNPJ) = 9 THEN

V_CPF_CNPJ := LPAD(V_CPF_CNPJ,9,'0');

ELSIF LENGTH(V_CPF_CNPJ) = 10 THEN

V_CPF_CNPJ := LPAD(V_CPF_CNPJ,10,'0');

END IF;

END IF;

IF V_CPF_CNPJ IS NULL THEN

V_RESULT_VLD := NULL;

ELSE

IF V_TIPODOC = 'CPF' THEN

IF LENGTH(V_CPF_CNPJ) <> 11 OR
   V_CPF_CNPJ IN ('00000000000', '11111111111', '22222222222',
                  '33333333333', '44444444444', '55555555555',
                  '66666666666', '77777777777', '88888888888',
                  '99999999999') THEN

V_RESULT_VLD := 'N';

ELSE

SOMA     := 0;
FACTOR   := 10;

FOR CPF IN 1..9 LOOP
        SOMA   := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CPF, 1)) * FACTOR;
        FACTOR := FACTOR - 1;
    END LOOP;

DGT1 := MOD(SOMA, 11);
DGT1 := CASE WHEN DGT1 < 2 THEN 0 ELSE 11 - DGT1 END;

SOMA   := 0;
FACTOR := 11;

FOR CPF IN 1..10 LOOP
        SOMA   := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CPF, 1)) * FACTOR;
        FACTOR := FACTOR - 1;
    END LOOP;

DGT2 := MOD(SOMA, 11);
DGT2 := CASE WHEN DGT2 < 2 THEN 0 ELSE 11 - DGT2 END;

IF DGT1 = TO_NUMBER(SUBSTR(V_CPF_CNPJ, 10, 1)) AND
   DGT2 = TO_NUMBER(SUBSTR(V_CPF_CNPJ, 11, 1)) THEN

V_RESULT_VLD := 'S';

ELSE

V_RESULT_VLD := 'N';

END IF;

END IF;

ELSIF V_TIPODOC = 'CNPJ' THEN

IF LENGTH(V_CPF_CNPJ) <> 14 OR
   V_CPF_CNPJ IN ('00000000000000', '11111111111111', '22222222222222',
                  '33333333333333', '44444444444444', '55555555555555',
                  '66666666666666', '77777777777777', '88888888888888',
                  '99999999999999') THEN

V_RESULT_VLD := 'N';

ELSE

SOMA     := 0;
PS1      := 5;

FOR CNPJ IN 1..12 LOOP
        SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CNPJ, 1)) * PS1;
        PS1  := CASE WHEN PS1 = 2 THEN 9 ELSE PS1 - 1 END;
    END LOOP;

DGT1 := MOD(SOMA, 11);
DGT1 := CASE WHEN DGT1 < 2 THEN 0 ELSE 11 - DGT1 END;

SOMA := 0;
PS2  := 6;

FOR CNPJ IN 1..13 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CNPJ, 1)) * PS2;
    PS2  := CASE WHEN PS2 = 2 THEN 9 ELSE PS2 - 1 END;
END LOOP;

DGT2 := MOD(SOMA, 11);
DGT2 := CASE WHEN DGT2 < 2 THEN 0 ELSE 11 - DGT2 END;


IF DGT1 = TO_NUMBER(SUBSTR(V_CPF_CNPJ, 13, 1)) AND DGT2 = TO_NUMBER(SUBSTR(V_CPF_CNPJ, 14, 1)) THEN

V_RESULT_VLD := 'S';

ELSE

V_RESULT_VLD := 'N';

END IF;

END IF;

ELSIF V_TIPODOC = 'CNH' THEN

IF LENGTH(V_CPF_CNPJ) <> 11 OR
  V_CPF_CNPJ IN ('00000000000', '11111111111', '22222222222',
                 '33333333333', '44444444444', '55555555555',
                 '66666666666', '77777777777', '88888888888',
                 '99999999999') THEN

V_RESULT_VLD := 'N';

ELSE

V_INCR_DGT2       := 0;
SOMA              := 0;
FACTOR            := 9;

-- ACHANDO PRIMEIRO DÍGITO
FOR CNH IN 1 .. 9 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CNH, 1)) * FACTOR;
    FACTOR := FACTOR - 1;
END LOOP;

DGT1 := MOD(SOMA, 11);

IF DGT1 = 10 THEN
   V_INCR_DGT2 := -2;
   DGT1        := 0;
END IF;

-- ACHANDO SEGUNDO DÍGITO
SOMA   := 0;
FACTOR := 1;
FOR CNH IN 1 .. 9 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ, CNH, 1)) * FACTOR;
    FACTOR := FACTOR + 1;
END LOOP;

IF (MOD(SOMA,11) + V_INCR_DGT2) < 0 THEN
DGT2 := 11 + (MOD(SOMA, 11) + V_INCR_DGT2);
ELSE
DGT2 := (MOD(SOMA, 11) + V_INCR_DGT2);
END IF;

IF DGT2 > 9 THEN
DGT2 := 0;
END IF;

IF DGT1 = SUBSTR(V_CPF_CNPJ, 10,1) AND SUBSTR(V_CPF_CNPJ, 11,1) = DGT2 THEN

V_RESULT_VLD := 'S';

ELSE

V_RESULT_VLD := 'N';

END IF;

END IF;

ELSIF V_TIPODOC = 'RG' THEN

IF LENGTH(V_CPF_CNPJ) NOT IN (9, 10) OR
  V_CPF_CNPJ IN ('000000000', '111111111', '222222222',
                 '333333333', '444444444', '555555555',
                 '666666666', '777777777', '888888888',
                 '999999999', '00000000X', '11111111X',
                 '22222222X', '33333333X', '44444444X',
                 '55555555X', '66666666X', '77777777X',
                 '88888888X', '99999999X', '0000000010',
                 '1111111110', '2222222210', '3333333310',
                 '4444444410', '5555555510', '6666666610',
                 '7777777710', '8888888810', '9999999910') THEN

V_RESULT_VLD := 'N';

ELSE

FACTOR            := 9;
SOMA              := 0;

-- ACHANDO PRIMEIRO DÍGITO
FOR RG IN 1 .. 8 LOOP
    SOMA := SOMA + (TO_NUMBER(SUBSTR(V_CPF_CNPJ, RG, 1)) * FACTOR);
    FACTOR := FACTOR - 1;
    END LOOP;

    DGT2 := CASE WHEN MOD(SOMA,11) <> 10 THEN MOD(SOMA,11) ELSE 10 END;

    V_X  := CASE WHEN DGT2 = 10 THEN 'X' ELSE TO_CHAR(DGT2) END;

IF ((SUBSTR(V_CPF_CNPJ, 9, 1) = 'X' OR SUBSTR(V_CPF_CNPJ, 9, 2) = '10') AND V_X = 'X') OR
   (SUBSTR(V_CPF_CNPJ, 9, 1) = V_X) THEN

V_RESULT_VLD := 'S';

ELSE

V_RESULT_VLD := 'N';

END IF;

END IF;

END IF;

END IF;

RETURN V_RESULT_VLD;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20085, 'Erro: O valor é maior ou menor do que o tamanho permitido para a variável numdoc ou tipodoc.');

END;

FUNCTION CREATED_COMPLIANT_DOC(TIPODOC IN VARCHAR2,
                               ACTION  IN VARCHAR2 DEFAULT 2
                               )
RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: CREATED_COMPLIANT_DOC                                                                                               ####
  ####  DATA CRIAÇÃO: 05/12/2024                                                                                                    ####
  ####  DATA MODIFICAÇÃO: 06/12/2024                                                                                                ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função CREATED_COMPLIANT_DOC gera documentos válidos nos formatos CPF, CNPJ, CNH e RG, conforme os        ####
  ####  padrões oficiais. Com dois parâmetros, TIPODOC define o tipo de documento ("CPF", "CNPJ", "CNH" ou "RG")                    ####
  ####  e ACTION determina se será formatado (1) ou desformatado (2). Para CPF e CNPJ, a função cria os dígitos                     ####
  ####  iniciais, calcula os verificadores usando os algoritmos oficiais e aplica as máscaras "XXX.XXX.XXX-XX"                      ####
  ####  ou "XX.XXX.XXX/XXXX-XX" se solicitado. A CNH gera nove dígitos mais dois verificadores sem máscara adicional.               ####
  ####  O RG cria oito dígitos com verificador numérico ou "X", podendo retornar o formato "XX.XXX.XXX-X". A função                 ####
  ####  valida entradas, elimina sequências inválidas e aplica a máscara antes de retornar o documento.                             ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_CPF_CNPJ_CNH_RG          VARCHAR2(18);
V_RESULT_CPF_CNPJ_CNH_RG   VARCHAR2(18);
V_FORMATER                 PLS_INTEGER;
V_TIPODOC                  VARCHAR(4);
V_INCR_DGT2                NUMBER;
DGT1                       NUMBER;
DGT2                       NUMBER;
SOMA                       NUMBER;
PS1                        PLS_INTEGER;
PS2                        PLS_INTEGER;
FACTOR                     NUMBER;
RESTO                      NUMBER;
V_9                        NUMBER;
V_8                        NUMBER;
V_1                        NUMBER;
V_X                        VARCHAR2(2);
VALID_CPF                  BOOLEAN;
VALID_CNPJ                 BOOLEAN;
VALID_CNH                  BOOLEAN;
VALID_RG                   BOOLEAN;

BEGIN

V_TIPODOC  := UPPER(TIPODOC);

BEGIN

V_FORMATER := TRUNC(ABS(ACTION));

IF V_FORMATER NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o action não é válido. O use 1 para formatar ou 2 para desformatar.');
END IF;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20086, 'Erro: O valor fornecido para o action não é válido. O use 1 para formatar ou 2 para desformatar.');

END;

IF V_TIPODOC NOT IN ('CPF', 'CNPJ', 'CNH', 'RG') OR V_TIPODOC IS NULL THEN
   RAISE_APPLICATION_ERROR(-20016,
                           'Erro: O valor fornecido para o tipodoc não é válido. O use CPF, CNPJ, CNH ou RG para gerar um documento válido.');
END IF;






-- CPF
IF V_TIPODOC = 'CPF' THEN

VALID_CPF := FALSE;

WHILE NOT VALID_CPF LOOP

V_CPF_CNPJ_CNH_RG := NULL;

FOR CPF IN 1..9 LOOP

V_9 := V_9 || TRUNC(DBMS_RANDOM.VALUE(0, 10));

END LOOP;

IF LENGTH(V_9) < 9 THEN V_CPF_CNPJ_CNH_RG := LPAD(V_9, 9, '0');
ELSE V_CPF_CNPJ_CNH_RG := V_9;
END IF;


SOMA       := 0;
FACTOR     := 10;

-- ACHANDO PRIMEIRO DÍGITO
FOR CPF IN 1..9 LOOP
        SOMA   := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CPF, 1)) * FACTOR;
        FACTOR := FACTOR - 1;
    END LOOP;

DGT1 := MOD(SOMA, 11);
DGT1 := CASE WHEN DGT1 < 2 THEN 0 ELSE 11 - DGT1 END;

SOMA              := 0;
FACTOR            := 11;
V_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || DGT1;

-- ACHANDO SEGUNDO DÍGITO
FOR CPF IN 1..10 LOOP
        SOMA   := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CPF, 1)) * FACTOR;
        FACTOR := FACTOR - 1;
    END LOOP;

DGT2 := MOD(SOMA, 11);
DGT2 := CASE WHEN DGT2 < 2 THEN 0 ELSE 11 - DGT2 END;

V_RESULT_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || DGT2;

IF V_RESULT_CPF_CNPJ_CNH_RG NOT IN ('00000000000', '11111111111', '22222222222',
                                    '33333333333', '44444444444', '55555555555',
                                    '66666666666', '77777777777', '88888888888',
                                    '99999999999') THEN
                                    VALID_CPF := TRUE;
END IF;

END LOOP;

IF V_FORMATER = 1 THEN

V_RESULT_CPF_CNPJ_CNH_RG := REGEXP_REPLACE(V_CPF_CNPJ_CNH_RG || DGT2, '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');

END IF;






-- CNPJ

ELSIF V_TIPODOC = 'CNPJ' THEN

VALID_CNPJ := FALSE;

WHILE NOT VALID_CNPJ LOOP

V_CPF_CNPJ_CNH_RG := NULL;

FOR CNPJ IN 1..8 LOOP

V_8 := V_8 || TRUNC(DBMS_RANDOM.VALUE(0, 10));

END LOOP;

V_1 := TRUNC(DBMS_RANDOM.VALUE(0, 10));

IF LENGTH(V_8) < 8 THEN V_CPF_CNPJ_CNH_RG := LPAD(V_8, 8, '0') || '000' || V_1;
ELSE V_CPF_CNPJ_CNH_RG := V_8 || '000' || V_1;
END IF;

SOMA := 0;
PS1  := 5;

-- ACHANDO PRIMEIRO DÍGITO
FOR CNPJ IN 1..12 LOOP
        SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CNPJ, 1)) * PS1;
        PS1  := CASE WHEN PS1 = 2 THEN 9 ELSE PS1 - 1 END;
    END LOOP;

DGT1       := MOD(SOMA, 11);
DGT1       := CASE WHEN DGT1 < 2 THEN 0 ELSE 11 - DGT1 END;

V_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || DGT1;


-- ACHANDO SEGUNDO DÍGITO
SOMA := 0;
PS2  := 6;

FOR CNPJ IN 1..13 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CNPJ, 1)) * PS2;
    PS2  := CASE WHEN PS2 = 2 THEN 9 ELSE PS2 - 1 END;
END LOOP;

DGT2 := MOD(SOMA, 11);
DGT2 := CASE WHEN DGT2 < 2 THEN 0 ELSE 11 - DGT2 END;

V_RESULT_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || DGT2;

IF V_RESULT_CPF_CNPJ_CNH_RG NOT IN ('00000000000000', '11111111111111', '22222222222222',
                                    '33333333333333', '44444444444444', '55555555555555',
                                    '66666666666666', '77777777777777', '88888888888888',
                                    '99999999999999') THEN
                                VALID_CNPJ := TRUE;
END IF;

END LOOP;

IF V_FORMATER = 1 THEN

V_RESULT_CPF_CNPJ_CNH_RG := REGEXP_REPLACE(V_CPF_CNPJ_CNH_RG || DGT2, '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5');

END IF;






-- CNH
ELSIF V_TIPODOC = 'CNH' THEN

VALID_CNH := FALSE;

WHILE NOT VALID_CNH LOOP

V_CPF_CNPJ_CNH_RG := NULL;

FOR CNH IN 1..9 LOOP

V_9 := V_9 || TRUNC(DBMS_RANDOM.VALUE(0, 10));

END LOOP;

IF LENGTH(V_9) < 9 THEN V_CPF_CNPJ_CNH_RG := LPAD(V_9,9,'0');
ELSE V_CPF_CNPJ_CNH_RG := V_9;
END IF;

V_INCR_DGT2       := 0;
SOMA              := 0;
FACTOR            := 9;

-- ACHANDO PRIMEIRO DÍGITO
FOR CNH IN 1 .. 9 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CNH, 1)) * FACTOR;
    FACTOR := FACTOR - 1;
END LOOP;

DGT1 := MOD(SOMA, 11);

IF DGT1 = 10 THEN
   V_INCR_DGT2 := -2;
   DGT1        := 0;
END IF;

-- ACHANDO SEGUNDO DÍGITO
SOMA   := 0;
FACTOR := 1;
FOR CNH IN 1 .. 9 LOOP
    SOMA := SOMA + TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, CNH, 1)) * FACTOR;
    FACTOR := FACTOR + 1;
END LOOP;

IF (MOD(SOMA,11) + V_INCR_DGT2) < 0 THEN
DGT2 := 11 + (MOD(SOMA, 11) + V_INCR_DGT2);
ELSE
DGT2 := (MOD(SOMA, 11) + V_INCR_DGT2);
END IF;

IF DGT2 > 9 THEN
DGT2 := 0;
END IF;

V_RESULT_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || DGT1 || DGT2;

IF V_RESULT_CPF_CNPJ_CNH_RG NOT IN ('00000000000', '11111111111', '22222222222',
                                    '33333333333', '44444444444', '55555555555',
                                    '66666666666', '77777777777', '88888888888',
                                    '99999999999') THEN
                                    VALID_CNH := TRUE;
END IF;

END LOOP;







-- RG
ELSIF V_TIPODOC = 'RG' THEN

VALID_RG := FALSE;

WHILE NOT VALID_RG LOOP

V_CPF_CNPJ_CNH_RG := NULL;

FOR RG IN 1..8 LOOP
V_8 := V_8 || TRUNC(DBMS_RANDOM.VALUE(0, 10));

END LOOP;

IF LENGTH(V_8) < 8 THEN V_CPF_CNPJ_CNH_RG := LPAD(V_8,8,'0');
ELSE V_CPF_CNPJ_CNH_RG := V_8;
END IF;

FACTOR            := 9;
SOMA              := 0;

-- ACHANDO PRIMEIRO DÍGITO
FOR RG IN 1 .. 8 LOOP
    SOMA := SOMA + (TO_NUMBER(SUBSTR(V_CPF_CNPJ_CNH_RG, RG, 1)) * FACTOR);
    FACTOR := FACTOR - 1;
    END LOOP;

    DGT2 := CASE WHEN MOD(SOMA,11) <> 10 THEN MOD(SOMA,11) ELSE 10 END;

    V_X  := CASE WHEN DGT2 = 10 THEN 'X' ELSE TO_CHAR(DGT2) END;

V_RESULT_CPF_CNPJ_CNH_RG := V_CPF_CNPJ_CNH_RG || V_X;

IF V_RESULT_CPF_CNPJ_CNH_RG NOT IN ('000000000', '111111111', '222222222',
                                    '333333333', '444444444', '555555555',
                                    '666666666', '777777777', '888888888',
                                    '999999999', '00000000X', '11111111X',
                                    '22222222X', '33333333X', '44444444X',
                                    '55555555X', '66666666X', '77777777X',
                                    '88888888X', '99999999X') THEN
                                    VALID_RG := TRUE;
END IF;

END LOOP;

IF V_FORMATER = 1 THEN

V_RESULT_CPF_CNPJ_CNH_RG := REGEXP_REPLACE(V_CPF_CNPJ_CNH_RG || V_X,'([0-9]{2})([0-9]{3})([0-9]{3})([a-zA-Z0-9]{1})','\1.\2.\3-\4');

END IF;

END IF;

RETURN V_RESULT_CPF_CNPJ_CNH_RG;

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20085, 'Erro: O valor é maior do que o tamanho permitido para a variável tipodoc.');

END;

FUNCTION CRYPTIFY(TEXT   IN VARCHAR2,
                  KEY    IN VARCHAR2,
                  ACTION IN VARCHAR2)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: CRYPTIFY                                                                                                            ####
  ####  DATA CRIAÇÃO: 05/01/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função CRYPTIFY em PL/SQL criptografa e descriptografa mensagens com o algoritmo AES-256 em modo CBC e    ####
  ####  preenchimento PKCS5, usando uma chave transformada em hash SHA-256. O parâmetro ACTION determina                            ####
  ####  a operação: 1 para criptografar e 2 para descriptografar. Na criptografia, o texto é convertido,                            ####
  ####  criptografado, codificado em Base64 e alterado com caracteres aleatórios para ofuscação, enquanto                           ####
  ####  na descriptografia o processo é revertido, limpando os caracteres adicionados e decodificando o                             ####
  ####  texto para recuperar o original. A função inclui validações e tratamento de erros, garantindo                               ####
  ####  segurança e mensagens claras para entradas inválidas.                                                                       ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/



TEXT_CRIPT    VARCHAR2(4000);
TEXT_DRIPT    VARCHAR2(4000);
V_KEY         VARCHAR2(4000);
V_TEXT        VARCHAR2(4000);
KEY_32        RAW(32);
VETOR         RAW(16);
V_CRIPT       RAW(4000);
V_DRIPT       RAW(4000);
V_MODE        PLS_INTEGER;
RANDOM_CARACT VARCHAR2(30);
V_LENGTH      PLS_INTEGER;
V_POSIT       PLS_INTEGER;
V_CARACT      VARCHAR2(2);
V_FOR         PLS_INTEGER;

BEGIN

BEGIN

V_MODE := TRUNC(ABS(ACTION));

EXCEPTION
     WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: O valor fornecido para action não é válido. Apenas números são permitidos.');

END;

IF V_MODE IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro action não pode ser null.');
ELSIF V_MODE NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o parâmetro action não é válido. O use 1 para criptografar ou 2 para descriptografar.');
END IF;


IF V_MODE = 1 THEN

RANDOM_CARACT := TRIM(',!"#$%()*.:;<>?@{}|~±');
TEXT_CRIPT    := TEXT;
V_KEY         := KEY;
VETOR         := UTL_RAW.CAST_TO_RAW('1234567890ABCDEF');
KEY_32        := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(V_KEY), DBMS_CRYPTO.HASH_SH256);
V_CRIPT       := DBMS_CRYPTO.ENCRYPT(SRC => UTL_RAW.CAST_TO_RAW(TEXT_CRIPT),
                                     TYP => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
                                     KEY => KEY_32,
                                     IV  => VETOR);
V_TEXT        := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(V_CRIPT));
V_LENGTH      := LENGTH(V_TEXT);
V_FOR         := TRUNC(ABS(V_LENGTH / 4));

FOR CR IN 1..V_FOR LOOP

V_POSIT  := TRUNC(DBMS_RANDOM.VALUE(1, V_LENGTH + 1));

V_CARACT := SUBSTR(RANDOM_CARACT, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(RANDOM_CARACT) + 1)), 1);

V_TEXT   := SUBSTR(V_TEXT, 1, V_POSIT - 1) || V_CARACT || SUBSTR(V_TEXT, V_POSIT);

END LOOP;

V_TEXT   := REPLACE(REPLACE(V_TEXT,'/','_'),'+','-');

ELSE

TEXT_DRIPT := REPLACE(REPLACE(REGEXP_REPLACE(TEXT,'[\,]|[\!]|[\"]|[\#]|[\$]|[\%]|[\(]|[\)]|[\*]|[\.]|[\:]|[\;]|[\<]|[\>]|[\?]|[\@]|[\{]|[\}]|[\|]|[\~]|[\±]'),'_','/'),'-','+');
V_KEY      := KEY;
VETOR      := UTL_RAW.CAST_TO_RAW('1234567890ABCDEF');
KEY_32     := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(V_KEY), DBMS_CRYPTO.HASH_SH256);
V_CRIPT    := UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(TEXT_DRIPT));
V_DRIPT    := DBMS_CRYPTO.DECRYPT(SRC => V_CRIPT,
                                  TYP => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
                                  KEY => KEY_32,
                                  IV  => VETOR);
V_TEXT     := UTL_RAW.CAST_TO_VARCHAR2(V_DRIPT);

END IF;

RETURN V_TEXT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20024,
                            'Erro: O valor fornecido para os parâmetros text ou key, não são válidos.');

END;


FUNCTION IMPERIUMWORDS(VALUE IN VARCHAR2,
                       UNIT  IN VARCHAR2 DEFAULT 1)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: IMPERIUMWORDS                                                                                                       ####
  ####  DATA CRIAÇÃO: 25/05/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função IMPERIUMWORDS, escrita em PL/SQL, converte um número em seu valor por extenso em português,        ####
  ####  podendo retornar o valor por extenso de forma monetária (como "dois mil e cinquenta reais e vinte centavos")                ####
  ####  ou apenas numérica (como "dois mil e cinquenta"). Ela aceita dois parâmetros: o número a ser convertido e                   ####
  ####  uma opção indicando se o retorno deve ser monetário (1) ou numérico (2). A função trata números inteiros                    ####
  ####  e decimais, separando-os em grupos de três dígitos (centenas, milhares, milhões etc.) e montando a representação            ####
  ####  textual conforme as regras gramaticais do português. Além disso, lida com casos específicos como “cem”, “mil” sem “um”      ####
  ####  antes, pluralizações corretas e zero, e também trata os centavos quando a opção for monetária. A função possui tratamento   ####
  ####  de erros e validações para garantir entradas corretas e gerar mensagens apropriadas em caso de inconsistência.              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/



TYPE T_ARRAY IS TABLE OF VARCHAR2(150) INDEX BY PLS_INTEGER;
V_UNIDADES     T_ARRAY;
V_DEZ10_19     T_ARRAY;
V_DEZENAS      T_ARRAY;
V_CENTENAS     T_ARRAY;
V_SINGULAR     T_ARRAY;
V_PLURAL       T_ARRAY;
V_INTEIRO      NUMBER := TRUNC(VALUE);
V_CENTAVOS     NUMBER := ROUND(MOD(VALUE, 1) * 100);
V_GRUPOS       T_ARRAY;
V_TEXTO        VARCHAR2(4000);
V_TRECHO       VARCHAR2(4000);
V_POS          PLS_INTEGER := 1;
V_UNIT         PLS_INTEGER;

FUNCTION POREXTENSOGRUPO(N NUMBER)

RETURN VARCHAR2 IS

C   NUMBER := TRUNC(N / 100);
D   NUMBER := TRUNC(MOD(N, 100) / 10);
U   NUMBER := MOD(N, 10);
R   NUMBER := MOD(N, 100);
TXT VARCHAR2(4000);

BEGIN

IF N = 0 THEN
RETURN NULL;

ELSIF N = 100 THEN
RETURN 'cem';

ELSE

IF C > 0 THEN
TXT := V_CENTENAS(C);
END IF;

IF R > 0 THEN

IF TXT IS NOT NULL THEN
TXT := TXT || ' e ';
END IF;

IF R BETWEEN 10 AND 19 THEN
TXT := TXT || V_DEZ10_19(R);

ELSE

IF D > 0 THEN
TXT := TXT || V_DEZENAS(D);

IF U > 0 THEN
TXT := TXT || ' e ' || V_UNIDADES(U);
END IF;

ELSIF U > 0 THEN
TXT := TXT || V_UNIDADES(U);
END IF;

END IF;

END IF;

END IF;

RETURN TXT;

END;




BEGIN

BEGIN

V_UNIT := TRUNC(ABS(UNIT));

EXCEPTION
     WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: O valor fornecido para unit não é válido. Apenas números são permitidos.');

END;

IF V_UNIT IS NULL THEN
  RAISE_APPLICATION_ERROR(-20008,
                          'Erro: O parâmetro unit não pode ser null.');
ELSIF V_UNIT NOT IN (1, 2) THEN
  RAISE_APPLICATION_ERROR(-20016,
                          'Erro: O valor fornecido para o parâmetro unit não é válido. O use 1 para monetária ou 2 para numérica.');
END IF;

    -- DICIONÁRIOS
    V_UNIDADES(1) := 'um';
    V_UNIDADES(2) := 'dois';
    V_UNIDADES(3) := 'três';
    V_UNIDADES(4) := 'quatro';
    V_UNIDADES(5) := 'cinco';
    V_UNIDADES(6) := 'seis';
    V_UNIDADES(7) := 'sete';
    V_UNIDADES(8) := 'oito';
    V_UNIDADES(9) := 'nove';

    V_DEZ10_19(10) := 'dez';
    V_DEZ10_19(11) := 'onze';
    V_DEZ10_19(12) := 'doze';
    V_DEZ10_19(13) := 'treze';
    V_DEZ10_19(14) := 'quatorze';
    V_DEZ10_19(15) := 'quinze';
    V_DEZ10_19(16) := 'dezesseis';
    V_DEZ10_19(17) := 'dezessete';
    V_DEZ10_19(18) := 'dezoito';
    V_DEZ10_19(19) := 'dezenove';

    V_DEZENAS(2) := 'vinte';
    V_DEZENAS(3) := 'trinta';
    V_DEZENAS(4) := 'quarenta';
    V_DEZENAS(5) := 'cinquenta';
    V_DEZENAS(6) := 'sessenta';
    V_DEZENAS(7) := 'setenta';
    V_DEZENAS(8) := 'oitenta';
    V_DEZENAS(9) := 'noventa';

    V_CENTENAS(1) := 'cento';
    V_CENTENAS(2) := 'duzentos';
    V_CENTENAS(3) := 'trezentos';
    V_CENTENAS(4) := 'quatrocentos';
    V_CENTENAS(5) := 'quinhentos';
    V_CENTENAS(6) := 'seiscentos';
    V_CENTENAS(7) := 'setecentos';
    V_CENTENAS(8) := 'oitocentos';
    V_CENTENAS(9) := 'novecentos';

    V_SINGULAR(1) := NULL;
    V_SINGULAR(2) := 'mil';
    V_SINGULAR(3) := 'milhão';
    V_SINGULAR(4) := 'bilhão';
    V_SINGULAR(5) := 'trilhão';
    V_SINGULAR(6) := 'quatrilhão';
    V_SINGULAR(7) := 'quintilhão';
    V_SINGULAR(8) := 'sextilhão';
    V_SINGULAR(9) := 'septilhão';
    V_SINGULAR(10) := 'octilhão';
    V_SINGULAR(11) := 'nonilhão';
    V_SINGULAR(12) := 'decilhão';

    V_PLURAL(1) := NULL;
    V_PLURAL(2) := 'mil';
    V_PLURAL(3) := 'milhões';
    V_PLURAL(4) := 'bilhões';
    V_PLURAL(5) := 'trilhões';
    V_PLURAL(6) := 'quatrilhões';
    V_PLURAL(7) := 'quintilhões';
    V_PLURAL(8) := 'sextilhões';
    V_PLURAL(9) := 'septilhões';
    V_PLURAL(10) := 'octilhões';
    V_PLURAL(11) := 'nonilhões';
    V_PLURAL(12) := 'decilhões';

    -- DIVIDE NÚMERO EM GRUPOS DE 3 DÍGITOS
    WHILE V_INTEIRO > 0 LOOP
        V_GRUPOS(V_POS) := MOD(V_INTEIRO, 1000);
        V_INTEIRO := TRUNC(V_INTEIRO / 1000);
        V_POS := V_POS + 1;
    END LOOP;

    -- CONSTRÓI O EXTENSO DOS REAIS
    FOR I IN REVERSE 1 .. V_GRUPOS.COUNT LOOP
        IF V_GRUPOS.EXISTS(I) AND V_GRUPOS(I) > 0 THEN
            V_TRECHO := POREXTENSOGRUPO(V_GRUPOS(I));

            IF I > 1 THEN
               IF V_GRUPOS(I) = 1 THEN
                  IF I = 2 THEN
                     V_TRECHO := V_SINGULAR(I); -- APENAS "MIL", SEM "UM"
                     ELSE
                     V_TRECHO := 'um ' || V_SINGULAR(I);
                     END IF;
                     ELSE
                     V_TRECHO := V_TRECHO || ' ' || V_PLURAL(I);
                    END IF;
                 END IF;

            IF V_TEXTO IS NOT NULL THEN
               V_TEXTO := V_TEXTO || ' e ' || V_TRECHO;
            ELSE
                V_TEXTO := V_TRECHO;
            END IF;
        END IF;
    END LOOP;

IF V_UNIT = 1 THEN

-- TRATA ZERO
IF V_TEXTO IS NULL THEN
    -- Se não houver valor inteiro
    IF V_CENTAVOS > 0 THEN
        V_TEXTO := NULL; -- deixa nulo para montar só os centavos
    ELSE
        V_TEXTO := 'zero real';
    END IF;
ELSIF V_GRUPOS(1) = 1 AND V_GRUPOS.COUNT = 1 THEN
    V_TEXTO := V_TEXTO || ' real';
ELSE
    V_TEXTO := V_TEXTO || ' reais';
END IF;

-- CENTAVOS
IF V_CENTAVOS > 0 THEN
    V_TRECHO := POREXTENSOGRUPO(V_CENTAVOS);
    IF V_TEXTO IS NOT NULL THEN
        -- Já existe valor em reais, junta com centavos com ' e '
        IF V_CENTAVOS = 1 THEN
            V_TEXTO := V_TEXTO || ' e ' || V_TRECHO || ' centavo';
        ELSE
            V_TEXTO := V_TEXTO || ' e ' || V_TRECHO || ' centavos';
        END IF;
    ELSE
        -- Não tem valor inteiro, então só centavos
        IF V_CENTAVOS = 1 THEN
            V_TEXTO := V_TRECHO || ' centavo';
        ELSE
            V_TEXTO := V_TRECHO || ' centavos';
        END IF;
    END IF;
END IF;

ELSE

-- TRATA ZERO
IF V_TEXTO IS NULL THEN
    -- Se não houver valor inteiro
    IF V_CENTAVOS > 0 THEN
        V_TEXTO := NULL; -- deixa nulo para montar só os centavos
    ELSE
        V_TEXTO := 'zero';
    END IF;
ELSIF V_GRUPOS(1) = 1 AND V_GRUPOS.COUNT = 1 THEN
    V_TEXTO := V_TEXTO;
ELSE
    V_TEXTO := V_TEXTO;
END IF;

-- CENTAVOS
IF V_CENTAVOS > 0 THEN
    V_TRECHO := POREXTENSOGRUPO(V_CENTAVOS);
    IF V_TEXTO IS NOT NULL THEN
        -- Já existe valor em reais, junta com centavos com ' e '
        IF V_CENTAVOS = 1 THEN
            V_TEXTO := V_TEXTO || ' e ' || V_TRECHO;
        ELSE
            V_TEXTO := V_TEXTO || ' e ' || V_TRECHO;
        END IF;
    ELSE
        -- Não tem valor inteiro, então só centavos
        IF V_CENTAVOS = 1 THEN
            V_TEXTO := V_TRECHO;
        ELSE
            V_TEXTO := V_TRECHO;
        END IF;
    END IF;
END IF;
END IF;


    RETURN V_TEXTO;
END;

FUNCTION LUHN_VALIDATOR(CARD IN VARCHAR2)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: LUHN_VALIDATOR                                                                                                      ####
  ####  DATA CRIAÇÃO: 15/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função LUHN_VALIDATOR verifica se um número informado (como o de um cartão de crédito) é válido           ####
  ####  usando o algoritmo de Luhn, que é um método comum para detectar erros de digitação. Ela recebe                              ####
  ####  o número como texto, remove espaços e valida se ele tem pelo menos dois dígitos e não é negativo.                           ####
  ####  Em seguida, aplica o algoritmo de Luhn: multiplica alternadamente os dígitos, soma os resultados                            ####
  ####  conforme a regra do algoritmo e verifica se a soma total é divisível por 10. Se for, retorna 'S'                            ####
  ####  indicando que o número é válido; caso contrário, retorna 'N'.                                                               ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_CARD   NUMBER;
V_RESULT VARCHAR2(1);
V_MULTPL NUMBER;
V_IMPAR  NUMBER := 0;
V_PAR    NUMBER := 0;
V_DIV    NUMBER := 0;
V_10     NUMBER;


BEGIN

BEGIN

V_CARD := REGEXP_REPLACE(TRIM(CARD),'\s+');

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20583, 'Erro: O valor fornecido para card não é válido. Apenas números são permitidos.');

END;


IF LENGTH(V_CARD) < 2 THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro card não é válido. O dado deve ter mais do que 2 dígitos.');
ELSIF

  V_CARD < 2 THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro card não é válido. O número não pode ser negativo.');
END IF;


FOR P IN 1 .. LENGTH(V_CARD) LOOP

IF MOD(P, 2) = 0 THEN

V_PAR := V_PAR + SUBSTR(V_CARD, P, 1);

END IF;

END LOOP;



FOR I IN 1 .. LENGTH(V_CARD) LOOP

IF MOD(I, 2) = 1 THEN

V_MULTPL := TO_NUMBER(SUBSTR(V_CARD, I, 1)) * 2;

IF LENGTH(V_MULTPL) = 2 THEN

FOR D IN 1 .. 2 LOOP

V_DIV := V_DIV + TO_NUMBER(SUBSTR(V_MULTPL, D, 1));

END LOOP;

V_IMPAR := V_IMPAR + V_DIV;

V_DIV := 0;

ELSE

V_IMPAR := V_IMPAR + V_MULTPL;

END IF;

END IF;

END LOOP;


V_10 := MOD(V_PAR + V_IMPAR, 10);


IF V_10 = 0 THEN

V_RESULT := 'S';

ELSE

V_RESULT := 'N';

END IF;


RETURN V_RESULT;

END;

FUNCTION LUHN_CREATOR(BAND IN VARCHAR2)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: LUHN_CREATOR                                                                                                        ####
  ####  DATA CRIAÇÃO: 15/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função LUHN_CREATOR gera números de cartão de crédito válidos para testes, com base na bandeira           ####
  ####  informada (1 = Visa, 2 = MasterCard, 3 = Elo). Ela monta os primeiros 15 dígitos com prefixos reais                         ####
  ####  da bandeira e calcula o último dígito usando o algoritmo de Luhn, que garante que o número final seja válido.               ####
  ####  O retorno é um número de cartão formatado, útil para ambientes de desenvolvimento e homologação.                            ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_BAND   NUMBER;
V_RESULT VARCHAR(50);
V_VISA   NUMBER;
V_MASTER NUMBER;
V_ELO    NUMBER;
V_MULTPL NUMBER;
V_IMPAR  NUMBER := 0;
V_PAR    NUMBER := 0;
V_DIV    NUMBER := 0;
V_10     NUMBER;
V_CARD   VARCHAR(50);
V_VALIDA NUMBER;
V_N_ELO  NUMBER;


BEGIN

BEGIN

V_BAND := REGEXP_REPLACE(TRIM(BAND),'\s+');

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20583, 'Erro: O valor fornecido para band não é válido. Apenas números são permitidos.');

END;


IF V_BAND NOT IN (1, 2, 3) THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro band não é válido. O use 1 para visa, 2 para mastercard e 3 para elo.');
END IF;

--VISA
IF V_BAND = 1 THEN

V_CARD := '4' || TRUNC(DBMS_RANDOM.VALUE(100, 1000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(100, 1000));

V_VALIDA := REGEXP_REPLACE(V_CARD,'\s+');


--SOMA DOS PARES
FOR P IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(P, 2) = 0 THEN

V_PAR := V_PAR + SUBSTR(V_VALIDA, P, 1);

END IF;

END LOOP;


--SOMA E MULTIPLICAÇÃO DOS IMPARES
FOR I IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(I, 2) = 1 THEN

V_MULTPL := TO_NUMBER(SUBSTR(V_VALIDA, I, 1)) * 2;

IF LENGTH(V_MULTPL) = 2 THEN

FOR D IN 1 .. 2 LOOP

V_DIV := V_DIV + TO_NUMBER(SUBSTR(V_MULTPL, D, 1));

END LOOP;

V_IMPAR := V_IMPAR + V_DIV;

V_DIV := 0;

ELSE

V_IMPAR := V_IMPAR + V_MULTPL;

END IF;

END IF;

END LOOP;

V_10 := 10 - MOD(V_PAR + V_IMPAR, 10);

IF V_10 = 10 THEN

V_10 := 0;

END IF;

V_RESULT := V_CARD || V_10;

--MASTERCARD
ELSIF V_BAND = 2 THEN

V_CARD := TRUNC(DBMS_RANDOM.VALUE(51, 56)) || TRUNC(DBMS_RANDOM.VALUE(10, 100)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(100, 1000));

V_VALIDA := REGEXP_REPLACE(V_CARD,'\s+');


--SOMA DOS PARES
FOR P IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(P, 2) = 0 THEN

V_PAR := V_PAR + SUBSTR(V_VALIDA, P, 1);

END IF;

END LOOP;


--SOMA E MULTIPLICAÇÃO DOS IMPARES
FOR I IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(I, 2) = 1 THEN

V_MULTPL := TO_NUMBER(SUBSTR(V_VALIDA, I, 1)) * 2;

IF LENGTH(V_MULTPL) = 2 THEN

FOR D IN 1 .. 2 LOOP

V_DIV := V_DIV + TO_NUMBER(SUBSTR(V_MULTPL, D, 1));

END LOOP;

V_IMPAR := V_IMPAR + V_DIV;

V_DIV := 0;

ELSE

V_IMPAR := V_IMPAR + V_MULTPL;

END IF;

END IF;

END LOOP;

V_10 := 10 - MOD(V_PAR + V_IMPAR, 10);

IF V_10 = 10 THEN

V_10 := 0;

END IF;

V_RESULT := V_CARD || V_10;


--ELO
ELSIF V_BAND = 3 THEN

V_N_ELO := TRUNC(DBMS_RANDOM.VALUE(1, 4));

IF V_N_ELO = 1 THEN

   V_N_ELO := 4011;

ELSIF V_N_ELO = 2 THEN

   V_N_ELO := 4312;

ELSIF V_N_ELO = 3 THEN

   V_N_ELO := 4389;

END IF;

V_CARD := V_N_ELO || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) || ' ' ||
          TRUNC(DBMS_RANDOM.VALUE(100, 1000));

V_VALIDA := REGEXP_REPLACE(V_CARD,'\s+');


--SOMA DOS PARES
FOR P IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(P, 2) = 0 THEN

V_PAR := V_PAR + SUBSTR(V_VALIDA, P, 1);

END IF;

END LOOP;


--SOMA E MULTIPLICAÇÃO DOS IMPARES
FOR I IN 1 .. LENGTH(V_VALIDA) LOOP

IF MOD(I, 2) = 1 THEN

V_MULTPL := TO_NUMBER(SUBSTR(V_VALIDA, I, 1)) * 2;

IF LENGTH(V_MULTPL) = 2 THEN

FOR D IN 1 .. 2 LOOP

V_DIV := V_DIV + TO_NUMBER(SUBSTR(V_MULTPL, D, 1));

END LOOP;

V_IMPAR := V_IMPAR + V_DIV;

V_DIV := 0;

ELSE

V_IMPAR := V_IMPAR + V_MULTPL;

END IF;

END IF;

END LOOP;

V_10 := 10 - MOD(V_PAR + V_IMPAR, 10);

IF V_10 = 10 THEN

V_10 := 0;

END IF;

V_RESULT := V_CARD || V_10;

END IF;

RETURN V_RESULT;

END;

FUNCTION FIBONACCI_SERIE(POS IN VARCHAR2)

RETURN SYS.ODCINUMBERLIST IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: FIBONACCI_SERIE                                                                                                     ####
  ####  DATA CRIAÇÃO: 28/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função FIBONACCI_SERIE recebe como parâmetro uma string representando um número e retorna uma             ####
  ####  lista (SYS.ODCINUMBERLIST) contendo os termos da sequência de Fibonacci até a posição informada.                            ####
  ####  Ela valida o valor de entrada, convertendo-o para número positivo e inteiro, e trata possíveis erros                        ####
  ####  como entrada inválida ou valores fora do intervalo permitido (acima de 606). A sequência é construída                       ####
  ####  iterativamente, armazenando cada termo como elemento da lista. Se o valor for nulo ou inválido, a                           ####
  ####  função retorna uma lista vazia.                                                                                             ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_SERIE SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
V_ANT   NUMBER := 0;
V_POST  NUMBER := 1;
TEMP    NUMBER;
V_N     PLS_INTEGER;

BEGIN

BEGIN

V_N := TRUNC(ABS(POS));

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20086, 'Erro: O valor fornecido para o parâmetro pos não é válido. Apenas números são permitidos.');

END;

IF V_N > 606 THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro pos não é válido. O dado deve estar entre 0 e 606.');
END IF;

IF V_N IS NULL THEN

RETURN V_SERIE;

END IF;


FOR I IN 1 .. V_N LOOP

V_SERIE.EXTEND;

V_SERIE(V_SERIE.COUNT) := V_ANT;

TEMP := V_ANT + V_POST;

V_ANT  := V_POST;
V_POST := TEMP;

END LOOP;

RETURN V_SERIE;

END;

FUNCTION GENPASS(RANGE IN VARCHAR2 DEFAULT 10)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: GENPASS                                                                                                             ####
  ####  DATA CRIAÇÃO: 28/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função GENPASS gera uma senha aleatória de tamanho variável (padrão 10 caracteres),                       ####
  ####  combinando letras maiúsculas, letras minúsculas, números e caracteres especiais definidos na função.                        ####
  ####  Ela valida o parâmetro de tamanho para garantir que seja um número válido, e para cada caractere da                         ####
  ####  senha seleciona aleatoriamente um tipo (maiúscula, minúscula, número ou especial), concatenando-os                          ####
  ####  até formar a senha completa, que é então retornada como uma string.                                                         ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


RANDOM_CARACT_ESPC      VARCHAR2(32);
RANDOM_CARACT_ALFA_MAIS VARCHAR2(26);
RANDOM_CARACT_ALFA_MINI VARCHAR2(26);
RANDOM_CARACT_NUMBER    PLS_INTEGER;
V_INI_TEXT              PLS_INTEGER;
V_SENHA                 VARCHAR2(4000);
V_TM_SH                 PLS_INTEGER;
V_CARACT                VARCHAR2(2);


BEGIN

RANDOM_CARACT_ALFA_MAIS := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
RANDOM_CARACT_ALFA_MINI := LOWER('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
RANDOM_CARACT_ESPC      := TRIM(',!"#$%()*.:;<>?@{}|~±/_');

BEGIN

V_TM_SH := NVL(TRUNC(ABS(RANGE)),10);

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20086, 'Erro: O valor fornecido para o parâmetro range não é válido. Apenas números são permitidos.');

END;

FOR TXT IN 1..V_TM_SH

LOOP

V_INI_TEXT := TRUNC(DBMS_RANDOM.VALUE(1, 5));

IF V_INI_TEXT = 1 THEN

V_CARACT   := SUBSTR(RANDOM_CARACT_ALFA_MAIS, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(RANDOM_CARACT_ALFA_MAIS) + 1)), 1);

ELSIF V_INI_TEXT = 2 THEN

V_CARACT   := SUBSTR(RANDOM_CARACT_ALFA_MINI, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(RANDOM_CARACT_ALFA_MINI) + 1)), 1);

ELSIF V_INI_TEXT = 3 THEN

V_CARACT   := SUBSTR(RANDOM_CARACT_ESPC, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(RANDOM_CARACT_ESPC) + 1)), 1);

ELSE

RANDOM_CARACT_NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, 10));

V_CARACT   := RANDOM_CARACT_NUMBER;

END IF;

V_SENHA    := V_SENHA || V_CARACT;

END LOOP;

RETURN V_SENHA;

END;

FUNCTION HUMAN_DELTA(START_DATE IN DATE,
                     END_DATE   IN DATE DEFAULT SYSDATE)

RETURN VARCHAR2 IS

/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: HUMAN_DELTA                                                                                                         ####
  ####  DATA CRIAÇÃO: 28/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função HUMAN_DELTA calcula a diferença entre duas datas no Oracle e retorna o resultado em formato        ####
  ####  legível para humanos, expressando o intervalo em anos, meses e dias (por exemplo: "2 anos e 3 meses e 5 dias").             ####
  ####  Ela trunca as datas para ignorar o horário, trata valores nulos no parâmetro final assumindo SYSDATE como padrão,           ####
  ####  valida se a data inicial é menor ou igual à final e, em seguida, computa o total de meses, convertendo esse                 ####
  ####  valor em anos, meses restantes e dias residuais. Se a diferença for zero, retorna "0 dias".                                 ####
  ####  Em caso de erro (como START_DATE maior que END_DATE), a função dispara uma exceção                                          ####
  ####  com mensagem personalizada.                                                                                                 ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_START  DATE;
V_END    DATE;
V_YEARS  NUMBER;
V_MONTHS NUMBER;
V_DAYS   NUMBER;
V_STR    VARCHAR2(4000);

BEGIN

V_START := TRUNC(START_DATE);
V_END   := TRUNC(NVL(END_DATE, SYSDATE));

IF V_START > V_END THEN

   RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O parâmetro start_date não pode ser maior que end_date.');
END IF;



V_MONTHS := FLOOR(MONTHS_BETWEEN(V_END, V_START));

V_YEARS  := FLOOR(V_MONTHS / 12);

V_MONTHS := MOD(V_MONTHS, 12);

V_DAYS   := V_END - ADD_MONTHS(V_START, V_YEARS * 12 + V_MONTHS);


IF V_YEARS > 0 THEN
   V_STR := V_STR || V_YEARS || ' ano' || CASE WHEN V_YEARS > 1 THEN 's' END;
END IF;

IF V_MONTHS > 0 THEN
  IF V_STR IS NOT NULL THEN V_STR := V_STR || ' e '; END IF;
  V_STR := CASE WHEN V_MONTHS > 1 THEN V_STR || V_MONTHS || ' meses' ELSE V_STR || V_MONTHS || ' mês' END;
END IF;

IF V_DAYS > 0 THEN
   IF V_STR IS NOT NULL THEN V_STR := V_STR || ' e '; END IF;
   V_STR := V_STR || V_DAYS || ' dia' || CASE WHEN V_DAYS > 1 THEN 's' END;
END IF;

IF V_STR IS NULL THEN
   V_STR := '0 dias';
END IF;

RETURN V_STR;

END;

FUNCTION PRIMARY_TARGET(NUM IN VARCHAR2)

RETURN VARCHAR2 IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: PRIMARY_TARGET                                                                                                      ####
  ####  DATA CRIAÇÃO: 28/06/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função PRIMARY_TARGET recebe um valor numérico em formato texto, valida sua conversão para número         ####
  ####  inteiro positivo, e verifica se esse número é primo, retornando 'S' para sim e 'N' para não.                                ####
  ####  Números menores ou iguais a 1 retornam 'N', enquanto 2 e 3 retornam 'S'. A função elimina múltiplos                         ####
  ####  de 2 e 3 e, em seguida, aplica uma otimização baseada no algoritmo 6k ± 1 para testar divisores até                         ####
  ####  a raiz quadrada do número, garantindo eficiência na verificação de primalidade. Se nenhum divisor                           ####
  ####  for encontrado, o número é considerado primo. Caso o valor informado não seja numérico, é gerado um                         ####
  ####  erro customizado.                                                                                                           ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


V_NUMBER NUMBER;
INI      NUMBER := 5;
LIMIT    NUMBER;

BEGIN

BEGIN

V_NUMBER := TRUNC(ABS(NUM));

EXCEPTION
WHEN VALUE_ERROR THEN RAISE_APPLICATION_ERROR(-20086, 'Erro: O valor fornecido para o parâmetro num não é válido. Apenas números são permitidos.');

END;

IF V_NUMBER IS NULL OR V_NUMBER <= 1 THEN

   RETURN 'N';

ELSIF V_NUMBER IN (2, 3) THEN

   RETURN 'S';

ELSIF MOD(V_NUMBER, 2) = 0 OR MOD(V_NUMBER, 3) = 0 THEN

   RETURN 'N';

END IF;


LIMIT := FLOOR(SQRT(V_NUMBER));

WHILE INI <= LIMIT LOOP

IF MOD(V_NUMBER, INI) = 0 OR MOD(V_NUMBER, INI + 2) = 0 THEN

RETURN 'N';

END IF;

INI := INI + 6;

END LOOP;

RETURN 'S';

END;

FUNCTION CALCULUS_HORARIUM(START_DATE       IN DATE,
                           END_DATE         IN DATE,
                           ENTRY_TIME       IN VARCHAR2,
                           EXIT_TIME        IN VARCHAR2,
                           LUNCH_START_TIME IN VARCHAR2,
                           LUNCH_END_TIME   IN VARCHAR2,
                           CALENDAR_ROLL    IN VARCHAR2 DEFAULT 1)

RETURN NUMBER IS


/*######################################################################################################################################
  ######################################################################################################################################
  ####                                                                                                                              ####
  ####  FUNÇÃO: CALCULUS_HORARIUM                                                                                                   ####
  ####  DATA CRIAÇÃO: 05/07/2025                                                                                                    ####
  ####  AUTOR: HEITOR DAIREL GONZAGA TAVARES                                                                                        ####
  ####                                                                                                                              ####
  ####  SOBRE A FUNÇÃO: A função CALCULUS_HORARIUM calcula a quantidade total de horas úteis entre duas datas e horários            ####
  ####  informados, considerando o expediente diário (horário de entrada e saída), intervalo de almoço                              ####
  ####  e um parâmetro que define se devem ser desconsiderados feriados, finais de semana ou ambos.                                 ####
  ####  Para cada dia no intervalo, ela verifica se o dia é válido conforme a regra escolhida,                                      ####
  ####  calcula o período efetivamente trabalhado nesse dia e subtrai o tempo de almoço sobreposto.                                 ####
  ####  O resultado final é a soma das horas úteis, arredondada com duas casas decimais. A função                                   ####
  ####  também realiza validações nos parâmetros e retorna mensagens de erro claras em casos de                                     ####
  ####  valores inválidos.                                                                                                          ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ####                                                                                                                              ####
  ######################################################################################################################################
  ######################################################################################################################################*/


    V_START_DATE        DATE;
    V_END_DATE          DATE;
    V_ENTRY_TIME        DATE;
    V_HOURS_DAY         NUMBER := 0;
    V_TOTAL_HOURS       NUMBER := 0;
    V_CALENDAR_ROLL     PLS_INTEGER;
    V_FD                PLS_INTEGER;


    V_WORK_START_TIME    DATE;
    V_WORK_END_TIME      DATE;
    V_LUNCH_START_TIME   DATE;
    V_LUNCH_END_TIME     DATE;


    V_WORK_START         DATE;
    V_WORK_END           DATE;
    V_LUNCH_START        DATE;
    V_LUNCH_END          DATE;
    V_REAL_START         DATE;
    V_REAL_END           DATE;


FUNCTION LUNCH_TIME(START_DATE DATE, END_DATE DATE, START_DATE2 DATE, END_DATE2 DATE)
RETURN NUMBER IS
        V_START DATE := GREATEST(START_DATE, START_DATE2);
        V_END   DATE := LEAST(END_DATE, END_DATE2);
    BEGIN
        IF V_START >= V_END THEN
            RETURN 0;
        ELSE
            RETURN (V_END - V_START) * 24;
        END IF;
    END;

BEGIN

BEGIN

    V_WORK_START_TIME  := TO_DATE(ENTRY_TIME, 'HH24:MI');
    V_WORK_END_TIME    := TO_DATE(EXIT_TIME, 'HH24:MI');
    V_LUNCH_START_TIME := TO_DATE(LUNCH_START_TIME, 'HH24:MI');
    V_LUNCH_END_TIME   := TO_DATE(LUNCH_END_TIME, 'HH24:MI');

EXCEPTION
     WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: o valor fornecido não é válido. Apenas horas e minutos são permitidos (ex: 15:30 ou 09).');

END;

BEGIN

V_CALENDAR_ROLL := TRUNC(ABS(CALENDAR_ROLL));

EXCEPTION
     WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20084, 'Erro: o valor fornecido não é válido. Apenas números são permitidos.');

END;

IF START_DATE > END_DATE THEN

  RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O parâmetro start_date não pode ser maior que end_date.');

ELSIF CALENDAR_ROLL NOT IN (1, 2, 3) THEN

      RAISE_APPLICATION_ERROR(-20090,
                          'Erro: O valor fornecido para o parâmetro calendar_roll não é válido. O use 1 (feriado e final de semana), 2 (feriado), 3 (final de semana).');

END IF;

    V_START_DATE := TRUNC(START_DATE);


IF V_CALENDAR_ROLL = 1 THEN

    WHILE V_START_DATE <= TRUNC(END_DATE) LOOP

        SELECT CASE
               WHEN EXISTS
                (SELECT 1 FROM TB_CALENDARIO_FERIADOS CF WHERE CF.DATA = V_START_DATE) OR
                    TO_CHAR(V_START_DATE, 'D') IN (1, 7) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;


        IF V_FD = 0 THEN


            V_WORK_START  := V_START_DATE + (V_WORK_START_TIME - TRUNC(V_WORK_START_TIME));
            V_WORK_END    := V_START_DATE + (V_WORK_END_TIME - TRUNC(V_WORK_END_TIME));
            V_LUNCH_START := V_START_DATE + (V_LUNCH_START_TIME - TRUNC(V_LUNCH_START_TIME));
            V_LUNCH_END   := V_START_DATE + (V_LUNCH_END_TIME - TRUNC(V_LUNCH_END_TIME));


            V_REAL_START := GREATEST(V_WORK_START, START_DATE);
            V_REAL_END    := LEAST(V_WORK_END, END_DATE);

            IF V_REAL_START < V_REAL_END THEN
                V_HOURS_DAY := (V_REAL_END - V_REAL_START) * 24;


                V_HOURS_DAY := V_HOURS_DAY - LUNCH_TIME(V_REAL_START, V_REAL_END, V_LUNCH_START, V_LUNCH_END);

                V_TOTAL_HOURS := V_TOTAL_HOURS + V_HOURS_DAY;
            END IF;

        END IF;

        V_START_DATE := V_START_DATE + 1;
    END LOOP;

    RETURN ROUND(V_TOTAL_HOURS, 2);

ELSIF V_CALENDAR_ROLL = 2 THEN

    WHILE V_START_DATE <= TRUNC(END_DATE) LOOP

        SELECT CASE
               WHEN EXISTS
                (SELECT 1 FROM TB_CALENDARIO_FERIADOS CF WHERE CF.DATA = V_START_DATE) THEN
                1
               ELSE
                0
             END
        INTO V_FD
        FROM DUAL;


        IF V_FD = 0 THEN


            V_WORK_START  := V_START_DATE + (V_WORK_START_TIME - TRUNC(V_WORK_START_TIME));
            V_WORK_END    := V_START_DATE + (V_WORK_END_TIME - TRUNC(V_WORK_END_TIME));
            V_LUNCH_START := V_START_DATE + (V_LUNCH_START_TIME - TRUNC(V_LUNCH_START_TIME));
            V_LUNCH_END   := V_START_DATE + (V_LUNCH_END_TIME - TRUNC(V_LUNCH_END_TIME));


            V_REAL_START := GREATEST(V_WORK_START, START_DATE);
            V_REAL_END    := LEAST(V_WORK_END, END_DATE);

            IF V_REAL_START < V_REAL_END THEN
                V_HOURS_DAY := (V_REAL_END - V_REAL_START) * 24;


                V_HOURS_DAY := V_HOURS_DAY - LUNCH_TIME(V_REAL_START, V_REAL_END, V_LUNCH_START, V_LUNCH_END);

                V_TOTAL_HOURS := V_TOTAL_HOURS + V_HOURS_DAY;
            END IF;

        END IF;

        V_START_DATE := V_START_DATE + 1;
    END LOOP;

    RETURN ROUND(V_TOTAL_HOURS, 2);

ELSE

WHILE V_START_DATE <= TRUNC(END_DATE) LOOP

      IF TO_CHAR(V_START_DATE, 'D') NOT IN ('1','7') THEN


            V_WORK_START  := V_START_DATE + (V_WORK_START_TIME - TRUNC(V_WORK_START_TIME));
            V_WORK_END    := V_START_DATE + (V_WORK_END_TIME - TRUNC(V_WORK_END_TIME));
            V_LUNCH_START := V_START_DATE + (V_LUNCH_START_TIME - TRUNC(V_LUNCH_START_TIME));
            V_LUNCH_END   := V_START_DATE + (V_LUNCH_END_TIME - TRUNC(V_LUNCH_END_TIME));


            V_REAL_START := GREATEST(V_WORK_START, START_DATE);
            V_REAL_END    := LEAST(V_WORK_END, END_DATE);

            IF V_REAL_START < V_REAL_END THEN
                V_HOURS_DAY := (V_REAL_END - V_REAL_START) * 24;


                V_HOURS_DAY := V_HOURS_DAY - LUNCH_TIME(V_REAL_START, V_REAL_END, V_LUNCH_START, V_LUNCH_END);

                V_TOTAL_HOURS := V_TOTAL_HOURS + V_HOURS_DAY;
            END IF;

        END IF;

        V_START_DATE := V_START_DATE + 1;
    END LOOP;

    RETURN ROUND(V_TOTAL_HOURS, 2);

END IF;

END;

END;