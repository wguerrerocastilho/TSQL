USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDC033]    Script Date: 18/02/2020 17:57:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDC033](@tCode VARCHAR(20) )
/* ==========================================================================================
   Author      : Waldemar Guerrero
   Create date : 
   Description : Calculo do digito de controle para contas correntes 
                 do banco 033 Santander

				 Fornecer conta no formato:
				     
				     AAAA00PPCCCCCC
                     
                     AAAA   - Quatro dígitos para número da agência
                     00     - Digitos fixos
                     PP     - Código da operação. 2 digitos. Pode assumir os valores
                              "01/02/03/05/07/09/13/27/35/37/43/45/46/48/50/53/60/92"
                     CCCCCC - Numero da conta corrente em 6 posições, sem digito de controle
                 
                     Teste
					 PRINT dbo.Fn_CalcDc033('46280013000622') + ' = 4'
                     PRINT dbo.Fn_CalcDc033('35120001071563') + ' = 8'
                     PRINT dbo.Fn_CalcDc033('17600001000688') + ' = 3'
                     PRINT dbo.Fn_CalcDc033('39230013000043') + ' = 4'
                     
   ========================================================================================== */

   RETURNS CHAR(01)

AS
BEGIN
	-- Declare the return variable here
    DECLARE @tDC CHAR(01);

    SET @tCode = TRIM(@tCode);

    -- Multiplicador
    DECLARE @tMlt VARCHAR(14) = '97310097131973';   -- Multiplicadores

    DECLARE @nSoma SMALLINT = 0;
    DECLARE @nI    SMALLINT = 1;
    DECLARE @nUn   SMALLINT = 0;
    DECLARE @nLen  SMALLINT = 0;
    DECLARE @tUn   CHAR(02) = '';    -- Unidade da soma
    DECLARE @nDCalc SMALLINT = 0;

	SET @nLen = LEN(@tCode);

	WHILE @nI <= @nLen 
	BEGIN
	    
        --  Multiplica o dígito e despreza a dezena
        SET @nUn = CAST(SUBSTRING(@tCode, @nI, 1) AS SMALLINT) * CAST(SUBSTRING(@tMlt, @nI, 1) AS SMALLINT);
        
		-- Depreza a dezena, se houver
		IF @nUn > 9
		BEGIN
		   SET @nUn = @nUn - FLOOR(@nUn/10) * 10;
        END
        
        SET @nSoma += @nUn;
        SET @nI += 1;
        
    END
    
	-- Da soma desprezar a dezena, considerar somente a unidade
	SET @nSoma = @nSoma - FLOOR(@nSoma/10) * 10;
    
	SET @nDCalc = 10 - @nSoma;
	IF  @nDCalc = 10
	BEGIN
	    SET @nDCalc = 0;
    END
    
	SET @tDC = CONVERT( CHAR(1), @nDCalc);
    
	RETURN @tDC;
    
END
