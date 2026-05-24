
CREATE TABLE Dim_Author (
    id_author SERIAL PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE Dim_Video (
    id_video SERIAL PRIMARY KEY,
    video_id_tiktok BIGINT NOT NULL UNIQUE,  
    video_url VARCHAR(500),
    description TEXT,
    hashtags TEXT,
    music VARCHAR(255)
);


CREATE TABLE Dim_Tiempo (
    id_date INT PRIMARY KEY,              
    fecha_completa DATE NOT NULL,
    anio INT NOT NULL,
    trimestre INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL    
);



CREATE TABLE Fact_TikTok_Metrics (

    id_video INT NOT NULL,
    id_author INT NOT NULL,
    id_create_date INT NOT NULL,           -- Rol: Fecha de creación del video
    id_fetch_date INT,                     -- Rol: Fecha de extracción de la métrica (puede ser NULL)
    id_posted_date INT,                    -- Rol: Fecha de publicación (puede ser NULL)
    
    -- Métricas / Hechos Cuantitativos (Aditivos para el cubo OLAP)
    likes INT DEFAULT 0,
    comments INT DEFAULT 0,
    shares INT DEFAULT 0,
    plays BIGINT DEFAULT 0,                -- BIGINT evita desbordamientos por alta viralidad
    views BIGINT DEFAULT 0,
    
    -- Llave Primaria Compuesta (Garantiza la unicidad granular de la tupla)
    CONSTRAINT PK_Fact_TikTok PRIMARY KEY (id_video, id_author, id_create_date),
    

    CONSTRAINT FK_Fact_Video FOREIGN KEY (id_video) 
        REFERENCES Dim_Video(id_video) ON DELETE RESTRICT,
        
    CONSTRAINT FK_Fact_Author FOREIGN KEY (id_author) 
        REFERENCES Dim_Author(id_author) ON DELETE RESTRICT,
        
    CONSTRAINT FK_Fact_Create_Date FOREIGN KEY (id_create_date) 
        REFERENCES Dim_Tiempo(id_date) ON DELETE RESTRICT,
        
    CONSTRAINT FK_Fact_Fetch_Date FOREIGN KEY (id_fetch_date) 
        REFERENCES Dim_Tiempo(id_date) ON DELETE RESTRICT,
        
    CONSTRAINT FK_Fact_Posted_Date FOREIGN KEY (id_posted_date) 
        REFERENCES Dim_Tiempo(id_date) ON DELETE RESTRICT
);

-- ============================================================================
-- 3. ÍNDICES DE RENDIMIENTO (Clave para acelerar consultas OLAP / JOINs)
-- ============================================================================
CREATE INDEX IX_Fact_TikTok_Video ON Fact_TikTok_Metrics(id_video);
CREATE INDEX IX_Fact_TikTok_Author ON Fact_TikTok_Metrics(id_author);
CREATE INDEX IX_Fact_TikTok_CreateDate ON Fact_TikTok_Metrics(id_create_date);