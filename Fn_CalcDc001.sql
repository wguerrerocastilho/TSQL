USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDc001]    Script Date: 18/02/2020 17:57:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDc001] (@tNr VARCHAR(12))

RETURNS CHAR(01)
AS
/* ==========================================================================================
   Author:		Waldemar Guerrero
   Create date: 16/12/2019
   Description:	Calculo do Digito de controle de agencia / conta corrente do Banco do Brasil
                Parametro deve ser passado SEM formatação (pontos, traços, barras, etc) e
				somente numeros.

                PRINT FnDB.dbo.Fn_CalcDc001(' 30555 ')  + ' - ' + '3';
                PRINT FnDB.dbo.Fn_CalcDc001(' 15100 ')  + ' - ' + '9';
                PRINT FnDB.dbo.Fn_CalcDc001(' 25720 ')  + ' - ' + '6';
                PRINT FnDB.dbo.Fn_CalcDc001(' 15264 ')  + ' - ' + '1';
                PRINT FnDB.dbo.Fn_CalcDc001(' 21890 ')  + ' - ' + '1';
                PRINT FnDB.dbo.Fn_CalcDc001(' 52363 ')  + ' - ' + '1';
                PRINT FnDB.dbo.Fn_CalcDc001(' 14608 ')  + ' - ' + '0';

   ========================================================================================== */
BEGIN
	
	-- Declare the return variable here
	DECLARE @tDC CHAR(01) = NULL

	-- Add the T-SQL statements to compute the return value here
	DECLARE @nMlt     SMALLINT = 2;
	DECLARE @nSoma    SMALLINT = 0;
	DECLARE @nI       SMALLINT = 0;
	DECLARE @nDCalc   SMALLINT = 0;

    -- Cálcula o dígito da conta
	--SET @tNrCC = FnDB.dbo.Fn_SomenteNumeros(@tNrCC);                -- Remove pontos, traços etc.

	SET   @tNr = TRIM(@tNr);
    SET   @nI  = LEN(@tNr);

    WHILE @nI >= 1
    BEGIN
       
       SET @nSoma = @nSoma + CONVERT( SMALLINT, SUBSTRING( @tNr , @nI, 1)) * @nMlt;
       SET @nMlt  = @nMlt + 1;
       IF @nMlt > 9
          SET @nMlt = 2;
       
       SET @nI = @nI - 1;
    END
    
    -- Cálculo do dígito da conta
    SET @nDCalc = 11 - (@nSoma % 11)
    
    IF @nDCalc = 10
       SET @tDC = '0'             -- Set @tDCt = "X"
    ELSE IF @nDCalc = 11
       SET @tDC = '0'
    ELSE
       SET @tDC = CONVERT( CHAR(01), @nDCalc);      
    
	-- Return the result of the function
	RETURN @tDC
    
END
