USE MASTER
GO
DROP DATABASE IF EXISTS tarefa_procedure
GO
CREATE DATABASE tarefa_procedure
GO
USE tarefa_procedure
GO

CREATE TABLE clientes (
	cpf					CHAR(11)		NOT NULL	UNIQUE,
	nome				VARCHAR(100)	NOT NULL,
	email				VARCHAR(200)	NOT NULL	UNIQUE,
	limite_de_credito	DECIMAL(7,2)	NOT NULL,
	dt_nascimento		DATE			NOT NULL,

	PRIMARY KEY(cpf)
)
GO

INSERT INTO clientes (cpf, nome, email, limite_de_credito, dt_nascimento)
VALUES
	('60329896075', 'João Silva', 'joao.silva@gmail.com', 2000.00, '1990-05-15'),
	('01006477071', 'Maria Souza', 'maria.souza@gmail.com', 3500.00, '1985-07-24'),
	('23875707079', 'Carlos Santos', 'carlos.santos@gmail.com', 5000.00, '1982-01-10'),
	('52028579005', 'Juliana Lima', 'juliana.lima@gmail.com', 10000.00, '1978-11-03'),
	('73684002003', 'Pedro Costa', 'pedro.costa@gmail.com', 1500.00, '2000-03-25'),
	('42357148055', 'Renata Oliveira', 'renata.oliveira@gmail.com', 2500.00, '1992-09-17'),
	('05276851000', 'Fernando Almeida', 'fernando.almeida@gmail.com', 4000.00, '1989-02-12'),
	('56677562000', 'Leticia Martins', 'leticia.martins@gmail.com', 7000.00, '1980-08-08'),
	('80749408022', 'Roberto Pereira', 'roberto.pereira@gmail.com', 8000.00, '1975-12-18'),
	('83304938060', 'Ana Paula Ferreira', 'ana.ferreira@gmail.com', 6000.00, '1995-04-23')
GO

SELECT * FROM clientes
GO

/* Verifica se o CPF é válido e não tem 11 números repetidos  */
CREATE PROCEDURE sp_validar_cpf @cpf VARCHAR(11), @resultado VARCHAR(10) OUTPUT
AS
BEGIN
DECLARE @soma1 INT = 0, @soma2 INT = 0, 
		@digito1 INT, @digito2 INT, @i INT = 1

-- Verifica se o CPF tem todos os números iguais
IF @cpf = REPLICATE(LEFT(@cpf, 1), 11) BEGIN
    SET @resultado = 'Inválido'
    RETURN
END

-- Calcula o primeiro dígito verificador
WHILE @i <= 9 BEGIN
    SET @soma1 += CAST(SUBSTRING(@cpf, @i, 1) AS INT) * (11 - @i)
    SET @i += 1
END
SET @digito1 = 11 - (@soma1 % 11)
IF @digito1 > 9 SET @digito1 = 0

-- Calcula o segundo dígito verificador
SET @i = 1
WHILE @i <= 10 BEGIN
    SET @soma2 += CAST(SUBSTRING(@cpf, @i, 1) AS INT) * (12 - @i)
    SET @i += 1
END
SET @digito2 = 11 - (@soma2 % 11)
IF @digito2 > 9 SET @digito2 = 0

-- Verifica se o CPF é válido
SET @resultado = CASE WHEN @digito1 = CAST(SUBSTRING(@cpf, 10, 1) AS INT) 
					   AND @digito2 = CAST(SUBSTRING(@cpf, 11, 1) AS INT) 
					   THEN 'Válido' ELSE 'Inválido' END
END

GO

/* Insere um novo cliente na tabela clientes, verificando a validade do CPF */
CREATE PROCEDURE sp_inserir_cliente
@cpf CHAR(11),
@nome VARCHAR(100),
@email VARCHAR(200),
@limite_de_credito DECIMAL(7,2),
@dt_nascimento DATE,
@msg_retorno VARCHAR(100) OUTPUT
AS
BEGIN
DECLARE @resultado VARCHAR(10)
EXEC sp_validar_cpf @cpf, @resultado OUTPUT
IF @resultado = 'Válido' BEGIN
BEGIN TRY
INSERT INTO clientes (cpf, nome, email, limite_de_credito, dt_nascimento)
VALUES (@cpf, @nome, @email, @limite_de_credito, @dt_nascimento);
SET @msg_retorno = 'Cliente inserido com sucesso.'
END TRY
BEGIN CATCH
DECLARE @msg_erro VARCHAR(100)
SET @msg_erro = 'Erro ao inserir o cliente.'
RAISERROR (@msg_erro, 16, 1)
END CATCH
END
ELSE BEGIN
SET @msg_erro = 'CPF inválido.'
RAISERROR (@msg_erro, 16, 1)
END
END;
GO

/* Retorna todos os clientes da tabela clientes */
CREATE PROCEDURE sp_listar_clientes
    @msg_retorno VARCHAR(200) OUTPUT
AS
BEGIN
BEGIN TRY
SELECT cpf, nome, email, limite_de_credito, dt_nascimento
FROM clientes;
SET @msg_retorno = 'Clientes listados com sucesso.';
END TRY
BEGIN CATCH
DECLARE @msg_erro VARCHAR(100)
SET @msg_erro = 'Erro ao listar clientes.'
RAISERROR (@msg_erro, 16, 1)
END CATCH
END;
GO

/* Retorna um cliente específico da tabela clientes, baseado no CPF */
CREATE PROCEDURE sp_buscar_cliente
@cpf CHAR(11),
@msg_retorno VARCHAR(100) OUTPUT
AS
BEGIN
BEGIN TRY
SELECT cpf, nome, email, limite_de_credito, dt_nascimento
FROM clientes
WHERE cpf = @cpf;
SET @msg_retorno = 'Cliente encontrado.'
END TRY
BEGIN CATCH
DECLARE @msg_erro VARCHAR(100)
SET @msg_erro = 'Erro ao buscar o cliente.'
RAISERROR (@msg_erro, 16, 1)
END CATCH
END;
GO

/* Atualiza um cliente específico na tabela clientes, baseado no CPF */
CREATE PROCEDURE sp_atualizar_cliente
@cpf CHAR(11),
@nome VARCHAR(100),
@email VARCHAR(200),
@limite_de_credito DECIMAL(7,2),
@dt_nascimento DATE,
@msg_retorno VARCHAR(100) OUTPUT
AS
BEGIN
BEGIN TRY
UPDATE clientes
SET nome = @nome,
email = @email,
limite_de_credito = @limite_de_credito,
dt_nascimento = @dt_nascimento
WHERE cpf = @cpf;
SET @msg_retorno = 'Cliente atualizado com sucesso.'
END TRY
BEGIN CATCH
DECLARE @msg_erro VARCHAR(100)
SET @msg_erro = 'Erro ao atualizar o cliente.'
RAISERROR (@msg_erro, 16, 1)
END CATCH
END;
GO

/* Deleta um cliente específico na tabela clientes, baseado no CPF */
CREATE PROCEDURE sp_deletar_cliente
@cpf CHAR(11),
@msg_retorno VARCHAR(100) OUTPUT
AS
BEGIN
BEGIN TRY
DELETE FROM clientes
WHERE cpf = @cpf;
SET @msg_retorno = 'Cliente deletado com sucesso.'
END TRY
BEGIN CATCH
DECLARE @msg_erro VARCHAR(100)
SET @msg_erro = 'Erro ao atualizar o cliente.'
RAISERROR (@msg_erro, 16, 1)
END CATCH
END;
GO

