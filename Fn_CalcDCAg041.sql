USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDCAg041]    Script Date: 18/02/2020 17:57:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDCAg041](@tCode VARCHAR(20) )
/* ==========================================================================================
   Author      : Waldemar Guerrero
   Create date : 
   Description : Calculo do digito de controle para agencia e contas corrente 
                 do banco 041 Banrisul

	Formato
	         AAAAnd PPCCCCCCnd
	            
	                  AAAA numero da agencia
	                  d    Primeiro DC calculado com base sobre a agencia ou conta.
	                  n    Segundo DC calculado com base sobre a agencia ou conta + d.
	                  
	         Atenção 
	                  * O calculo do segundo DC tem uma regra bem particular.
	                  * No cartão do banco, o DC da agencia não vem impresso em relevo.


			 PRINT dbo.Fn_CalcDC041('1102') + ' = ' + '48'    -- Pag. 35 Manual
			 PRINT dbo.Fn_CalcDC041('9000150') + ' = ' + '46'
             
			 PRINT dbo.Fn_CalcDC041('2948') + ' = ' + '88'
			 PRINT dbo.Fn_CalcDC041('2944') + ' = ' + '89'
			 
			 PRINT dbo.Fn_CalcDC041('9274') + ' = ' + '22'
			 PRINT dbo.Fn_CalcDC041('9194') + ' = ' + '38'

   ========================================================================================== */

   RETURNS CHAR(02)

AS
BEGIN
	-- Declare the return variable here
	DECLARE @tDC CHAR(02);

	DECLARE @nMlt  SMALLINT = 2;
    DECLARE @nSoma SMALLINT = 0;
    DECLARE @nI    SMALLINT = 0;
    DECLARE @nUn   SMALLINT = 0;    
    DECLARE @nDV1  SMALLINT = 0;        -- Primeiro digito de controle. Base 10;
    DECLARE @nDV2  SMALLINT = 11;       -- Segundo dígito de controle. Base 11; Iniciado com 11 para entrar no loop;
    DECLARE @tCodeExt VARCHAR(10) = '';

    -- Cálculo do primeiro dígito verificador. Base10
	SET @nI = LEN(@tCode)

	WHILE @nI > 0
	BEGIN

        SET @nUn = CAST( SUBSTRING(@tCode, @nI, 1) AS SMALLINT) * @nMlt;

        IF @nUn > 9
		BEGIN
            Set @nUn -= 9;
        END

        SET @nSoma += @nUn;
        SET @nMlt = 2 / @nMlt;      -- Multiplicador se alterna entre os valores 2 e 1;

        SET @nI -= 1; 
	
	END

    SET @nDV1 = 10 - (@nSoma % 10);
    IF @nDV1 = 10
	BEGIN
        SET @nDV1 = 0;
    END

    -- Loop para cálculo do segundo DC.
    -- Incorpora nDV1 ao corpo e calcula nDV2
    SET @nDV2 = 11;                                -- Força um valor para entrar no loop
    WHILE @nDV2 > 9
	BEGIN

        SET @nSoma = 0;
        SET @nMlt = 2;

        SET @tCodeExt = @tCode + CAST(@nDV1 AS VARCHAR);
		SET @nI = LEN(@tCodeExt);

		WHILE @nI > 0
		BEGIN

            SET @nUn = CAST(SUBSTRING(@tCodeExt,@nI, 1) AS SMALLINT) * @nMlt;
            SET @nSoma += @nUn;

            SET @nMlt += 1;
            IF @nMlt > 7
			BEGIN
                SET @nMlt = 2;
            END

			SET @nI -= 1;

        END

		-- Calcula @nDV2
        SET @nDV2 = 11 - (@nSoma % 11);

        IF @nDV2 > 9
		BEGIN
            -- Segundo digito não pode ser maior que 9. Incrementar nDC1 e persistir no loop
            SET @nDV1 += 1;

            if @nDV1 > 9
			BEGIN
                SET @nDV1 = 0;
            END
        END

    END                      -- WHILE @nDV2 > 9
    
	SET @tDC = CAST(@nDV1 AS CHAR(01)) + CAST(@nDV2 AS CHAR(01));
	RETURN @tDC;
    
END
