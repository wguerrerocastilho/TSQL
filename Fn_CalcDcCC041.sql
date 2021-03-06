USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDcCC041]    Script Date: 18/02/2020 17:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDcCC041](@tCode VARCHAR(20) )
/* ==========================================================================================
   Author      : Waldemar Guerrero
   Create date : 
   Description : Calculo do digito de controle para a CONTA CORRENTE HSBC para 
                 o banco 041 Banrisul

	Formato
	         TTCCCCCCd
	                  
	                  TT         Tipo da conta corrente

	                  CCCCCCC    Numero da conta corrente com 7 digitos
					  
					  d          Digito de controle conforme calculo abaixo.
	                  

			 PRINT dbo.Fn_CalcDcCC041('358507670') + ' = ' + '6'    -- Pag. 35 Manual 

   ========================================================================================== */

RETURNS CHAR(01)

AS
BEGIN
	-- Declare the return variable here
	DECLARE @tDC CHAR(01);
    
	DECLARE @tMlt  VARCHAR(15) = '324765432';
    
    DECLARE @nSoma SMALLINT = 0;
    DECLARE @nI    SMALLINT = 0;
    DECLARE @nUn   SMALLINT = 0;
    DECLARE @nDV   SMALLINT = 0;
    
    -- Loop de cálculo do dígito verificador.
	SET @nI = LEN(@tCode)

	WHILE @nI > 0
	BEGIN
        SET @nSoma += CAST(SUBSTRING(@tCode, @nI, 1) AS SMALLINT) * CAST(SUBSTRING(@tMlt, @nI, 1) AS SMALLINT)
        SET @nI -= 1; 
	END

	SET @nDV = (@nSoma % 11);

    IF @nDV = 1
	BEGIN
        SET @nDV = 6;
    END
	ELSE IF @nDV <> 0
	BEGIN
	    SET @nDV = 11 - @nDV;
    END

	SET @tDC = CAST(@nDV AS CHAR(01));
	RETURN @tDC;
    
END
