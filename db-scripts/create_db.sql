-- =========================|Schemas|============================
-- Cascade garante que apagará o schema e as tabelas dentro deles
DROP SCHEMA IF EXISTS db CASCADE;
CREATE SCHEMA db;
-- ================|Tabelas Sem Relacionamento|===================
CREATE TABLE IF NOT EXISTS db.tb_cor (
    id_cor SERIAL PRIMARY KEY,
    cor VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS db.tb_material (
    id_material SERIAL PRIMARY KEY,
    material VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS db.tb_tamanho (
    id_tamanho SERIAL PRIMARY KEY,
    tamanho VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS db.tb_categoria (
    id_categoria SERIAL PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS db.tb_status_pedidos (
    id_status SERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS db.tb_fornecedor (
    id_fornecedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL CHECK (length(cnpj) = 14)
);

CREATE TABLE IF NOT EXISTS db.tb_nota (
    id_nota SERIAL PRIMARY KEY,
    nota INTEGER NOT NULL CHECK (nota >= 0 AND nota <= 5)
);
-- ===============|Tabelas com Relacionamento|==================
CREATE TABLE IF NOT EXISTS db.tb_enderecos (
    id_endereco SERIAL PRIMARY KEY,
    cep VARCHAR(8) NOT NULL CHECK (length(cep) = 8),
    logradouro VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(100),
    estado VARCHAR(2) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    id_endereco_cobranca INTEGER,

    CONSTRAINT fk_endereco_cobranca
        FOREIGN KEY (id_endereco_cobranca)
        REFERENCES db.tb_enderecos(id_endereco),
    
    CONSTRAINT chk_endereco_self
        CHECK (id_endereco_cobranca IS NULL OR id_endereco_cobranca <> id_endereco)
);


CREATE TABLE IF NOT EXISTS db.tb_clientes (
    id_cliente SERIAL PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL CHECK (length(cpf) = 11),
    nome VARCHAR(100) NOT NULL,
    dt_nascimento DATE,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    id_endereco INTEGER NOT NULL,

    CONSTRAINT fk_cliente_endereco FOREIGN KEY (id_endereco) 
        REFERENCES db.tb_enderecos(id_endereco)
);


CREATE TABLE IF NOT EXISTS db.tb_produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL CHECK (valor_unitario > 0),
    id_cor INTEGER NOT NULL,
    id_material INTEGER NOT NULL,
    id_tamanho INTEGER NOT NULL,
    id_categoria INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,

    CONSTRAINT fk_produto_cor FOREIGN KEY (id_cor) 
        REFERENCES db.tb_cor(id_cor),

    CONSTRAINT fk_produto_material FOREIGN KEY (id_material) 
        REFERENCES db.tb_material(id_material),

    CONSTRAINT fk_produto_tamanho FOREIGN KEY (id_tamanho) 
        REFERENCES db.tb_tamanho(id_tamanho),

    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) 
        REFERENCES db.tb_categoria(id_categoria),

    CONSTRAINT fk_produto_fornecedor FOREIGN KEY (id_fornecedor) 
        REFERENCES db.tb_fornecedor(id_fornecedor)
);


CREATE TABLE IF NOT EXISTS db.tb_pedidos (
    id_pedido SERIAL PRIMARY KEY,
    valor_total NUMERIC(10,2) NOT NULL CHECK (valor_total >= 0),
    id_cliente INTEGER NOT NULL,
    id_status INTEGER NOT NULL,

    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES db.tb_clientes(id_cliente),

    CONSTRAINT fk_pedido_status FOREIGN KEY (id_status)
        REFERENCES db.tb_status_pedidos(id_status)
);


CREATE TABLE IF NOT EXISTS db.tb_itens_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),

    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) 
        REFERENCES db.tb_pedidos(id_pedido),

    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) 
        REFERENCES db.tb_produtos(id_produto),
    
    CONSTRAINT uk_item UNIQUE (id_pedido, id_produto)
);


CREATE TABLE IF NOT EXISTS db.tb_avaliacao_produto (
    id_avaliacao SERIAL PRIMARY KEY,
    comentario VARCHAR(500),
    id_pedido INTEGER UNIQUE NOT NULL,
    id_nota INTEGER NOT NULL,

    CONSTRAINT fk_avaliacao_pedido FOREIGN KEY (id_pedido)
        REFERENCES db.tb_pedidos(id_pedido),

    CONSTRAINT fk_avaliacao_nota FOREIGN KEY (id_nota)
        REFERENCES db.tb_nota(id_nota)
);