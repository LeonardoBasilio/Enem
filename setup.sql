--USE master;
--GO
--
--CREATE TABLE Exemplo (
--    ID INT PRIMARY KEY,
--    Nome NVARCHAR(50)
--);

CREATE DATABASE DockerEnem;
GO

USE DockerEnem;

GO

CREATE TABLE Exemplo (
    ID INT PRIMARY KEY,
    Nome NVARCHAR(50)
);


-- Modifique o tamanho do arquivo de dados primário para 50GB
ALTER DATABASE [DockerEnem] MODIFY FILE (NAME = 'DockerEnem', SIZE = 50GB);

-- Modifique o tamanho do arquivo de log para 10GB
ALTER DATABASE [DockerEnem] MODIFY FILE (NAME = 'DockerEnem_log', SIZE = 2GB);