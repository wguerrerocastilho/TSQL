USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDC341]    Script Date: 18/02/2020 17:57:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDC341](@tCode VARCHAR(20) )
/* ==========================================================================================
   Author      : Waldemar Guerrero
   Create date : 
   Description : Calculo do digito de controle para agencia e contas corrente 
                 do banco 341 Itaú

	Formato
	             AAAACCCCC

				 AAAA     - Quatro digitos para numero da agência
				 CCCCC    - Numero da conta corrente em 6 posições
                 D        - Digito de controle;
             
			 PRINT dbo.Fn_CalcDC341('070960662') + ' = ' + '8'
			 PRINT dbo.Fn_CalcDC341('883924996') + ' = ' + '1'

			 PRINT dbo.Fn_CalcDC341('254502366') + ' = ' + '1'
             
   ========================================================================================== */

   RETURNS CHAR(01)

AS
BEGIN
    -- Declare the return variable here
    DECLARE @tDC CHAR(01);

    DECLARE @nDgtM SMALLINT = 0;        -- Dígito multiplicado
    DECLARE @nMlt  SMALLINT = 2;        -- Multiplicador, Varia entre 1 e 2.
    DECLARE @nSoma SMALLINT = 0;
    DECLARE @nI    SMALLINT = 0;
    DECLARE @nDCalc SMALLINT = 0; 

    SET @tCode = TRIM(@tCode);
    SET @nI = LEN(@tCode);

    WHILE @nI > 0 
    BEGIN
	    
        SET @nDgtM = CAST(SUBSTRING(@tCode ,@nI, 1) AS SMALLINT) * @nMlt;

        IF @nDgtM > 9
		BEGIN
            -- Soma o dígito da dezena com o dígito da unidade.
            -- Exemplo: 15 --> 1 + 4 = 5
            SET @nDgtM -= 9;

            -- Para valores acima de 20 (Soma a Dezena com a unidade)
            --SET @nDgtM = floor(@nDgtM / 10) + (@nDgtM - floor((@nDgtM / 10) * 10));
            ----           |==== Dezena ====| + |------------ Unidade -------------|
        END
        SET @nSoma += @nDgtM;

        -- Calcula o próximo multiplicador
        SET @nMlt = 2 / @nMlt;       -- Alterna resultados entre 1 e 2;

        SET @nI -= 1;
    END

    -- Cálculo do DC;
	SET @nDCalc = 10 - (@nSoma % 10);
    IF @nDCalc > 9
	BEGIN
        SET @nDCalc = 0;
    END

	SET @tDC = CAST(@nDCalc AS CHAR(1));
	RETURN @tDC;
    
END
