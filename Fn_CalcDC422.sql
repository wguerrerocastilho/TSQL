USE [FnDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_CalcDC422]    Script Date: 18/02/2020 17:57:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Fn_CalcDC422] ( @tCode VARCHAR(20) )
RETURNS CHAR(1)
AS
/* ===============================================================================
   Author        : Waldemar Guerrero
   Convertido em : 16/12/2019
   Description   : Calcula o DC de conta corrente Itau Banco 341
                
                Calculo efetuado sobre o bloco Agencia + Conta ('AAAACCCCCC')

                PRINT dbo.Fn_CalcDC422('0005580100') + ' = ' + '5'

   =============================================================================== */

BEGIN

    -- Declare the return variable here
    DECLARE @tNrDC    CHAR(01);
    DECLARE @nFator   SMALLINT = 2;   -- Fator que multiplicara cada dígito. Sequência de 2, 1, 2, 1, 2 ....
    DECLARE @nMlt     SMALLINT = 0;
    DECLARE @nSoma    SMALLINT = 0;
    DECLARE @nI       SMALLINT = 0;
    DECLARE @nDCalc   SMALLINT = 0;
    
    -- Conta no formato Ag + CC: 'AAAACCCCCC'
    SET @tCode = TRIM(@tCode);
    SET @nMlt  = 0;
    SET @nSoma = 0;
    SET @nI    = LEN(@tCode);
    
    WHILE @nI > 0  
    BEGIN 
       
       SET @nMlt = CONVERT(SMALLINT, SUBSTRING(@tCode, @nI, 1)) * @nFator;
       IF @nMlt > 9 -- Soma a dezena com a unidade. Ex. Se @nMlt = 25, resulta em 2+5 = 7 
          SET @nMlt = CONVERT(SMALLINT,(@nMlt / 10)) + (@nMlt - CONVERT(SMALLINT, (@nMlt / 10) * 10));
       
       SET @nSoma = @nSoma + @nMlt;
       SET @nFator = 2 / @nFator;     -- @nFator alterna entre 2, 1, 2, 1, 2, 1 ...
       SET @nI -= 1;
       
    END
    
    -- Calcula o dígito de controle da Agencia + Conta
    SET @nDCalc = 10 - (@nSoma % 10)
    
    IF @nDCalc > 9 
       SET @nDCalc = 0
    
    RETURN CONVERT(CHAR(1), @nDCalc)
    
    RETURN @tNrDC;

END