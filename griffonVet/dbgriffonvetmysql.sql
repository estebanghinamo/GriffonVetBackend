USE db_veterinaria;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS estudios_clinicos;
DROP TABLE IF EXISTS tratamientos;
DROP TABLE IF EXISTS medicamentos;
DROP TABLE IF EXISTS enfermedades_mascota;
DROP TABLE IF EXISTS enfermedades;
DROP TABLE IF EXISTS desparasitaciones_mascota;
DROP TABLE IF EXISTS desparasitaciones;
DROP TABLE IF EXISTS vacunas_mascota;
DROP TABLE IF EXISTS vacunas;
DROP TABLE IF EXISTS alergias_mascota;
DROP TABLE IF EXISTS alergias;
DROP TABLE IF EXISTS peso_mascota;
DROP TABLE IF EXISTS consultas_clinicas;
DROP TABLE IF EXISTS historias_clinicas;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS agenda_bloqueos;
DROP TABLE IF EXISTS informacion_home;
DROP TABLE IF EXISTS horarios_atencion;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS servicios_precios;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS mascotas;
DROP TABLE IF EXISTS tipo_especie;
DROP TABLE IF EXISTS usuarios_tokens;
DROP TABLE IF EXISTS usuarios;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(30) NULL,
    password_hash VARBINARY(255) NOT NULL,
    rol VARCHAR(20) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    email_verificado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_alta DATETIME NOT NULL DEFAULT NOW(),

    CONSTRAINT CK_usuarios_rol
        CHECK (rol IN ('CLIENTE', 'ADMIN'))
);

CREATE TABLE usuarios_tokens (
    id_token INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    fecha_expiracion DATETIME NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    fecha_creacion DATETIME DEFAULT NOW(),

    CONSTRAINT FK_tokens_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

CREATE TABLE tipo_especie (
    id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE mascotas (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    id_especie INT NOT NULL,
    raza VARCHAR(100) NULL,
    tamanio VARCHAR(20) NULL,
    fecha_nacimiento DATE NULL,
    sexo VARCHAR(20) NULL,
    tipo_pelaje VARCHAR(100) NULL,
    alergias_general VARCHAR(500) NULL,
    comportamiento VARCHAR(300) NULL,
    observaciones VARCHAR(1000) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT NOW(),
    castrado BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT FK_mascotas_usuarios
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),

    CONSTRAINT FK_mascotas_tipo_especie
        FOREIGN KEY (id_especie) REFERENCES tipo_especie(id_especie),

    CONSTRAINT CK_mascotas_tamanio
        CHECK (tamanio IN ('CHICO', 'MEDIANO', 'GRANDE', 'MUY GRANDE') OR tamanio IS NULL),

    CONSTRAINT CK_mascotas_sexo
        CHECK (sexo IN ('MACHO', 'HEMBRA') OR sexo IS NULL)
);

CREATE TABLE servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500) NULL,
    duracion_minutos INT NOT NULL,
    precio_base DECIMAL(12,2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE servicios_precios (
    id_servicio_precio INT AUTO_INCREMENT PRIMARY KEY,
    id_servicio INT NOT NULL,
    tamanio VARCHAR(20) NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    duracion_minutos INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT FK_servicios_precios_servicios
        FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),

    CONSTRAINT CK_servicios_precios_tamanio
        CHECK (tamanio IN ('CHICO', 'MEDIANO', 'GRANDE', 'MUY GRANDE'))
);

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(1000) NULL,
    precio DECIMAL(12,2) NOT NULL,
    id_categoria INT NOT NULL,
    imagen_url VARCHAR(500) NULL,
    stock INT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_alta DATETIME NOT NULL DEFAULT NOW(),

    CONSTRAINT FK_productos_categorias
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE horarios_atencion (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana INT NOT NULL,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    duracion_turno_minutos INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT CK_horarios_atencion_dia_semana
        CHECK (dia_semana BETWEEN 1 AND 7),

    CONSTRAINT CK_horarios_atencion_horas
        CHECK (hora_apertura < hora_cierre)
);

CREATE TABLE informacion_home (
    id_informacion INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(250) NOT NULL,
    id_categoria INT NOT NULL,
    fecha_publicacion DATETIME NULL DEFAULT NOW(),
    imagen_url VARCHAR(500) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT FK_infohome_categorias
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE agenda_bloqueos (
    id_bloqueo INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_desde TIME NULL,
    hora_hasta TIME NULL,
    motivo VARCHAR(300) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT CK_agenda_bloqueos_horas
        CHECK (
            (hora_desde IS NULL AND hora_hasta IS NULL)
            OR
            (hora_desde IS NOT NULL AND hora_hasta IS NOT NULL AND hora_desde < hora_hasta)
        )
);

CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    observaciones VARCHAR(1000) NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT NOW(),

    CONSTRAINT FK_reservas_usuarios
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),

    CONSTRAINT FK_reservas_servicios
        FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),

    CONSTRAINT CK_reservas_estado
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'ATENDIDA'))
);

CREATE TABLE historias_clinicas (
    id_historia_clinica INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL UNIQUE,
    fecha_apertura DATETIME NOT NULL DEFAULT NOW(),
    observaciones_generales VARCHAR(2000) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT FK_historias_clinicas_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota)
);

CREATE TABLE consultas_clinicas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_historia_clinica INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT NOW(),
    motivo_consulta VARCHAR(500) NULL,
    anamnesis LONGTEXT NULL,
    examen_general LONGTEXT NULL,
    diagnostico_presuntivo LONGTEXT NULL,
    diagnostico LONGTEXT NULL,
    tratamiento LONGTEXT NULL,
    observaciones LONGTEXT NULL,

    CONSTRAINT FK_consultas_clinicas_historias
        FOREIGN KEY (id_historia_clinica) REFERENCES historias_clinicas(id_historia_clinica)
);

CREATE TABLE peso_mascota (
    id_peso INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    fecha DATE NOT NULL DEFAULT (CURRENT_DATE),
    peso DECIMAL(10,2) NOT NULL,
    observaciones VARCHAR(500) NULL,

    CONSTRAINT FK_peso_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota)
);

CREATE TABLE alergias (
    id_alergia INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE alergias_mascota (
    id_alergia_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_alergia INT NOT NULL,
    severidad VARCHAR(20) NULL,
    observaciones VARCHAR(750) NULL,
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT FK_alergias_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota),

    CONSTRAINT FK_alergias_mascota_alergias
        FOREIGN KEY (id_alergia) REFERENCES alergias(id_alergia),

    CONSTRAINT CK_alergias_mascota_severidad
        CHECK (severidad IN ('LEVE', 'MODERADA', 'GRAVE') OR severidad IS NULL)
);

CREATE TABLE vacunas (
    id_vacuna INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE vacunas_mascota (
    id_vacuna_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_vacuna INT NOT NULL,
    fecha_aplicacion DATE NOT NULL,
    proxima_dosis DATE NULL,
    observaciones VARCHAR(500) NULL,

    CONSTRAINT FK_vacunas_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota),

    CONSTRAINT FK_vacunas_mascota_vacunas
        FOREIGN KEY (id_vacuna) REFERENCES vacunas(id_vacuna)
);

CREATE TABLE desparasitaciones (
    id_desparasitacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    tipo VARCHAR(50) NULL
);

CREATE TABLE desparasitaciones_mascota (
    id_desparasitacion_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_desparasitacion INT NOT NULL,
    fecha_aplicacion DATE NOT NULL,
    proxima_dosis DATE NULL,
    tipo VARCHAR(50) NULL,
    observaciones VARCHAR(500) NULL,

    CONSTRAINT FK_desparasitaciones_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota),

    CONSTRAINT FK_desparasitaciones_mascota_desparasitaciones
        FOREIGN KEY (id_desparasitacion) REFERENCES desparasitaciones(id_desparasitacion),

    CONSTRAINT CK_desparasitaciones_tipo
        CHECK (tipo IN ('INTERNO', 'EXTERNO') OR tipo IS NULL)
);

CREATE TABLE enfermedades (
    id_enfermedad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE enfermedades_mascota (
    id_enfermedad_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_enfermedad INT NOT NULL,
    fecha_diagnostico DATE NULL,
    estado VARCHAR(20) NULL,
    observaciones VARCHAR(500) NULL,

    CONSTRAINT FK_enfermedades_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota),

    CONSTRAINT FK_enfermedades_mascota_enfermedades
        FOREIGN KEY (id_enfermedad) REFERENCES enfermedades(id_enfermedad),

    CONSTRAINT CK_enfermedades_mascota_estado
        CHECK (estado IN ('ACTIVA', 'CURADA', 'CRONICA') OR estado IS NULL)
);

CREATE TABLE medicamentos (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE tratamientos (
    id_tratamiento INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    id_medicamento INT NULL,
    dosis VARCHAR(100) NULL,
    frecuencia VARCHAR(100) NULL,
    duracion_dias INT NULL,
    indicaciones VARCHAR(1000) NULL,

    CONSTRAINT FK_tratamientos_consultas
        FOREIGN KEY (id_consulta) REFERENCES consultas_clinicas(id_consulta),

    CONSTRAINT FK_tratamientos_medicamentos
        FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

CREATE TABLE estudios_clinicos (
    id_estudio INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT NOT NULL,
    tipo_estudio VARCHAR(150) NOT NULL,
    resultado LONGTEXT NULL,
    fecha DATETIME NOT NULL DEFAULT NOW(),
    observaciones VARCHAR(1000) NULL,

    CONSTRAINT FK_estudios_clinicos_consultas
        FOREIGN KEY (id_consulta) REFERENCES consultas_clinicas(id_consulta)
);

INSERT INTO tipo_especie (nombre)
VALUES
    ('Canino'),
    ('Felino'),
    ('Ave'),
    ('Roedor'),
    ('Conejo'),
    ('Reptil'),
    ('Pez'),
    ('Equino'),
    ('Bovino'),
    ('Ovino'),
    ('Porcino'),
    ('Otro');
    

-- 🔐 USUARIOS
CREATE UNIQUE INDEX IX_usuarios_email ON usuarios(email);
CREATE INDEX IX_usuarios_apellido ON usuarios(apellido);
CREATE INDEX IX_usuarios_rol_activo ON usuarios(rol, activo);

-- 🐾 MASCOTAS
CREATE INDEX IX_mascotas_id_usuario ON mascotas(id_usuario);
CREATE INDEX IX_mascotas_usuario_activo ON mascotas(id_usuario, activo);
CREATE INDEX IX_mascotas_nombre ON mascotas(nombre);

-- 🛒 PRODUCTOS
CREATE INDEX IX_productos_categoria ON productos(id_categoria);
CREATE INDEX IX_productos_nombre ON productos(nombre);
CREATE INDEX IX_productos_activo ON productos(activo);

-- ✂️ SERVICIOS
CREATE INDEX IX_servicios_activo ON servicios(activo);

-- 📅 RESERVAS
CREATE INDEX IX_reservas_fecha_hora ON reservas(fecha, hora);
CREATE INDEX IX_reservas_id_usuario ON reservas(id_usuario);
CREATE INDEX IX_reservas_id_servicio ON reservas(id_servicio);
CREATE INDEX IX_reservas_estado ON reservas(estado);
CREATE INDEX IX_reservas_full ON reservas(fecha, hora, estado);

-- 🏥 HISTORIAS
CREATE INDEX IX_historias_clinicas_id_mascota ON historias_clinicas(id_mascota);

-- 🩺 CONSULTAS
CREATE INDEX IX_consultas_clinicas_historia_fecha 
ON consultas_clinicas(id_historia_clinica, fecha);

CREATE INDEX IX_consultas_clinicas_historia
ON consultas_clinicas(id_historia_clinica);

-- ⚖️ PESO
CREATE INDEX IX_peso_mascota_id_mascota_fecha
ON peso_mascota(id_mascota, fecha);

-- 🤧 ALERGIAS
CREATE INDEX IX_alergias_nombre ON alergias(nombre);
CREATE INDEX IX_alergias_mascota_id_mascota ON alergias_mascota(id_mascota);
CREATE INDEX IX_alergias_mascota_full ON alergias_mascota(id_mascota, id_alergia);

-- 💉 VACUNAS
CREATE UNIQUE INDEX UX_vacunas_nombre ON vacunas(nombre);
CREATE INDEX IX_vacunas_mascota_id_mascota ON vacunas_mascota(id_mascota);
CREATE INDEX IX_vacunas_mascota_full ON vacunas_mascota(id_mascota, id_vacuna);

-- 🦠 DESPARASITACIONES
CREATE INDEX IX_desparasitaciones_nombre ON desparasitaciones(nombre);
CREATE INDEX IX_desparasitaciones_mascota_id_mascota ON desparasitaciones_mascota(id_mascota);
CREATE INDEX IX_desparasitaciones_mascota_full 
ON desparasitaciones_mascota(id_mascota, id_desparasitacion);

-- 🧬 ENFERMEDADES
CREATE INDEX IX_enfermedades_nombre ON enfermedades(nombre);
CREATE INDEX IX_enfermedades_mascota_id_mascota ON enfermedades_mascota(id_mascota);
CREATE INDEX IX_enfermedades_mascota_full 
ON enfermedades_mascota(id_mascota, id_enfermedad);

-- 💊 MEDICAMENTOS
CREATE UNIQUE INDEX UX_medicamentos_nombre ON medicamentos(nombre);

-- 💊 TRATAMIENTOS
CREATE INDEX IX_tratamientos_id_consulta ON tratamientos(id_consulta);
CREATE INDEX IX_tratamientos_id_medicamento ON tratamientos(id_medicamento);

-- 🧪 ESTUDIOS
CREATE INDEX IX_estudios_clinicos_id_consulta ON estudios_clinicos(id_consulta);

-- ⛔ BLOQUEOS
CREATE INDEX IX_agenda_bloqueos_fecha ON agenda_bloqueos(fecha);

-- 🕒 HORARIOS
CREATE INDEX IX_horarios_dia ON horarios_atencion(dia_semana);

-- SERVICIOS PRECIOS
CREATE INDEX IX_servicios_precios_servicio_tamanio
ON servicios_precios(id_servicio, tamanio);

/*
update usuarios
--set rol='ADMIN'
set email_verificado=1
where id_usuario=1
*/



/*============================================================================0

  procedimientos de registrar y login


================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_registrar_usuario$$

CREATE PROCEDURE sp_registrar_usuario(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    DECLARE v_email VARCHAR(150);
    DECLARE v_telefono VARCHAR(50);
    DECLARE v_password VARCHAR(255);
    DECLARE v_rol VARCHAR(20);
    DECLARE v_token VARCHAR(255);
    DECLARE v_password_hash VARBINARY(64);
    DECLARE v_activo BOOLEAN DEFAULT TRUE;
    DECLARE v_email_verificado BOOLEAN DEFAULT TRUE;
    DECLARE v_id_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar usuario'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_apellido = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.apellido'));
    SET v_email = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.email'));
    SET v_telefono = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.telefono'));
    SET v_password = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.password'));
    SET v_rol = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.rol')), 'CLIENTE');
    SET v_token = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.token'));

    IF v_email IS NULL OR v_password IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email y contraseña son obligatorios';
    END IF;

    IF v_email NOT LIKE '%@gmail.com' AND v_email NOT LIKE '%@hotmail.com' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo Gmail o Hotmail';
    END IF;

    IF EXISTS (SELECT 1 FROM usuarios WHERE email = v_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email ya está registrado';
    END IF;

    SET v_password_hash = UNHEX(SHA2(v_password, 256));

    IF v_rol = 'CLIENTE' THEN
        SET v_activo = FALSE;
        SET v_email_verificado = FALSE;
    END IF;

    INSERT INTO usuarios (
        nombre, apellido, email, telefono,
        password_hash, rol, activo, fecha_alta, email_verificado
    )
    VALUES (
        v_nombre, v_apellido, v_email, v_telefono,
        v_password_hash, v_rol, v_activo, NOW(), v_email_verificado
    );

    SET v_id_usuario = LAST_INSERT_ID();

    IF v_rol = 'CLIENTE' THEN
        INSERT INTO usuarios_tokens (
            id_usuario,
            token,
            fecha_expiracion
        )
        VALUES (
            v_id_usuario,
            v_token,
            DATE_ADD(NOW(), INTERVAL 24 HOUR)
        );
    END IF;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Usuario registrado correctamente',
        'id_usuario', v_id_usuario,
        'rol', v_rol
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_login_usuario_json$$
CREATE PROCEDURE sp_login_usuario_json(IN p_json JSON)
BEGIN
    DECLARE v_email        VARCHAR(150);
    DECLARE v_password     VARCHAR(255);
    DECLARE v_rol          VARCHAR(50)  DEFAULT NULL;
    DECLARE v_email_out    VARCHAR(150) DEFAULT NULL;
    DECLARE v_id_usuario   INT          DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 0 AS login_valido, NULL AS rol, NULL AS email_out, NULL AS id_usuario;
    END;

    SET v_email    = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.email'));
    SET v_password = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.password'));

    IF v_email IS NULL OR v_password IS NULL THEN
        SELECT 0 AS login_valido, NULL AS rol, NULL AS email_out, NULL AS id_usuario;
    ELSE
        SELECT u.rol, u.email, u.id_usuario
        INTO   v_rol, v_email_out, v_id_usuario
        FROM   usuarios u
        WHERE  u.email         = v_email
          AND  u.password_hash = UNHEX(SHA2(v_password, 256))
          AND  u.activo        = TRUE
        LIMIT 1;

        IF v_rol IS NOT NULL THEN
            SELECT 1          AS login_valido,
                   v_rol      AS rol,
                   v_email_out AS email_out,
                   v_id_usuario AS id_usuario;
        ELSE
            SELECT 0 AS login_valido, NULL AS rol, NULL AS email_out, NULL AS id_usuario;
        END IF;
    END IF;
END$$



DROP PROCEDURE IF EXISTS sp_activar_usuario$$

CREATE PROCEDURE sp_activar_usuario(IN p_token VARCHAR(255))
BEGIN
    DECLARE v_id_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al activar usuario'
        ) AS resultado;
    END;

    START TRANSACTION;

    SELECT id_usuario
    INTO v_id_usuario
    FROM usuarios_tokens
    WHERE token = p_token
      AND usado = FALSE
      AND fecha_expiracion > NOW()
    LIMIT 1;

    IF v_id_usuario IS NULL THEN
        ROLLBACK;

        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Token inválido o expirado'
        ) AS resultado;
    ELSE
        UPDATE usuarios
        SET activo = TRUE,
            email_verificado = TRUE
        WHERE id_usuario = v_id_usuario;

        UPDATE usuarios_tokens
        SET usado = TRUE
        WHERE token = p_token;

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Cuenta activada'
        ) AS resultado;
    END IF;
END$$


DROP PROCEDURE IF EXISTS sp_insert_cliente_mascota_json;
DELIMITER $$
CREATE PROCEDURE sp_insert_cliente_mascota_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    DECLARE v_email VARCHAR(150);
    DECLARE v_telefono VARCHAR(50);
    DECLARE v_password VARCHAR(255);
    DECLARE v_password_hash VARBINARY(64);

    DECLARE v_nombre_mascota VARCHAR(100);
    DECLARE v_id_especie INT;
    DECLARE v_raza VARCHAR(100);
    DECLARE v_tamanio VARCHAR(20);
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_sexo VARCHAR(20);
    DECLARE v_tipo_pelaje VARCHAR(100);
    DECLARE v_observaciones VARCHAR(1000);
    DECLARE v_castrado BOOLEAN DEFAULT FALSE;

    DECLARE v_id_usuario INT;
    DECLARE v_data JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear cliente y mascota'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.cliente.nombre')));
    SET v_apellido = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.cliente.apellido')));
    SET v_email = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.cliente.email')));
    SET v_telefono = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.cliente.telefono')));
    SET v_password = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.cliente.password'));

    SET v_nombre_mascota = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.nombre')));
    SET v_id_especie = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.id_especie')) AS UNSIGNED);
    SET v_raza = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.raza')));
    SET v_tamanio = UPPER(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.tamanio'))));
    SET v_fecha_nacimiento = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.fecha_nacimiento')) AS DATE);
    SET v_sexo = UPPER(TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.sexo'))));
    SET v_tipo_pelaje = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.tipo_pelaje')));
    SET v_observaciones = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.observaciones')));
    SET v_castrado =
    CASE
        WHEN JSON_EXTRACT(p_json, '$.mascota.castrado') IS NULL THEN 0
        WHEN JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.castrado')) IN ('true', '1', 'TRUE') THEN 1
        ELSE 0
    END;
    IF COALESCE(v_email, '') = '' OR COALESCE(v_password, '') = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email y contraseña son obligatorios';
    END IF;

    IF COALESCE(v_nombre, '') = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del cliente es obligatorio';
    END IF;

    IF EXISTS (SELECT 1 FROM usuarios WHERE email = v_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email ya está registrado';
    END IF;

    IF COALESCE(v_nombre_mascota, '') <> '' THEN
        IF v_id_especie IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La especie de la mascota es obligatoria';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM tipo_especie
            WHERE id_especie = v_id_especie
              AND activo = TRUE
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La especie indicada no existe o está inactiva';
        END IF;
    END IF;

    SET v_password_hash = UNHEX(SHA2(v_password, 256));

    INSERT INTO usuarios (
        nombre,
        apellido,
        email,
        telefono,
        password_hash,
        rol,
        activo,
        email_verificado,
        fecha_alta
    )
    VALUES (
        v_nombre,
        v_apellido,
        v_email,
        v_telefono,
        v_password_hash,
        'CLIENTE',
        TRUE,
        TRUE,
        NOW()
    );

    SET v_id_usuario = LAST_INSERT_ID();

    IF COALESCE(v_nombre_mascota, '') <> '' THEN
        INSERT INTO mascotas (
            id_usuario,
            nombre,
            id_especie,
            raza,
            tamanio,
            fecha_nacimiento,
            sexo,
            tipo_pelaje,
            observaciones,
            castrado,
            activo,
            fecha_registro
        )
        VALUES (
            v_id_usuario,
            v_nombre_mascota,
            v_id_especie,
            v_raza,
            v_tamanio,
            v_fecha_nacimiento,
            v_sexo,
            v_tipo_pelaje,
            v_observaciones,
            v_castrado,
            TRUE,
            NOW()
        );
    END IF;

    SELECT JSON_OBJECT(
        'id_usuario', u.id_usuario,
        'nombre', u.nombre,
        'apellido', u.apellido,
        'nombre_completo', CONCAT(u.nombre, ' ', u.apellido),
        'email', u.email,
        'telefono', u.telefono,
        'rol', u.rol,
        'mascotas', COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_mascota', m.id_mascota,
                        'nombre', m.nombre,
                        'especie', te.nombre,
                        'id_especie', m.id_especie,
                        'raza', m.raza,
                        'castrado', m.castrado
                    )
                )
                FROM mascotas m
                INNER JOIN tipo_especie te
                    ON te.id_especie = m.id_especie
                WHERE m.id_usuario = u.id_usuario
                  AND m.activo = TRUE
            ),
            JSON_ARRAY()
        )
    )
    INTO v_data
    FROM usuarios u
    WHERE u.id_usuario = v_id_usuario;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Cliente y mascota creados correctamente',
        'data', v_data
    ) AS resultado;
END$$

DELIMITER ;

/*============================================================================0

  procedimientos de obtener, editar e insertar productos


================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_categorias$$
CREATE PROCEDURE sp_get_categorias()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener categorías'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'categorias',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_categoria', t.id_categoria,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT id_categoria, nombre
                    FROM categorias
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_categoria_json$$
CREATE PROCEDURE sp_insert_categoria_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_id_categoria INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear categoría'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre de la categoría es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(v_nombre);

    SELECT id_categoria
    INTO v_id_categoria
    FROM categorias
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_categoria IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'La categoría ya existía',
            'categoria',
            (
                SELECT JSON_OBJECT(
                    'id_categoria', c.id_categoria,
                    'nombre', c.nombre
                )
                FROM categorias c
                WHERE c.id_categoria = v_id_categoria
            )
        ) AS resultado;

    ELSE

        INSERT INTO categorias(nombre)
        VALUES(v_nombre_normalizado);

        SET v_id_categoria = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Categoría creada correctamente',
            'categoria',
            (
                SELECT JSON_OBJECT(
                    'id_categoria', c.id_categoria,
                    'nombre', c.nombre
                )
                FROM categorias c
                WHERE c.id_categoria = v_id_categoria
            )
        ) AS resultado;

    END IF;
END$$


DROP PROCEDURE IF EXISTS sp_get_productos_json$$
CREATE PROCEDURE sp_get_productos_json()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener productos'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'productos',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_producto', t.id_producto,
                        'nombre', t.nombre,
                        'descripcion', t.descripcion,
                        'precio', t.precio,
                        'id_categoria', t.id_categoria,
                        'categoria', t.categoria,
                        'imagen_url', t.imagen_url,
                        'stock', t.stock,
                        'activo', t.activo,
                        'fecha_alta', t.fecha_alta
                    )
                )
                FROM (
                    SELECT
                        p.id_producto,
                        p.nombre,
                        p.descripcion,
                        p.precio,
                        p.id_categoria,
                        c.nombre AS categoria,
                        p.imagen_url,
                        p.stock,
                        p.activo,
                        p.fecha_alta
                    FROM productos p
                    INNER JOIN categorias c
                        ON p.id_categoria = c.id_categoria
                    WHERE p.activo = TRUE
                    ORDER BY p.nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_producto_json$$
CREATE PROCEDURE sp_insert_producto_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(200);
    DECLARE v_descripcion LONGTEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_id_categoria INT;
    DECLARE v_imagen_url VARCHAR(500);
    DECLARE v_stock INT;
    DECLARE v_id_producto INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear producto'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descripcion'));
    SET v_precio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.precio')) AS DECIMAL(10,2));
    SET v_id_categoria = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_categoria')) AS UNSIGNED);
    SET v_imagen_url = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.imagen_url'));
    SET v_stock = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.stock')) AS SIGNED);

    IF v_nombre IS NULL OR v_precio IS NULL OR v_id_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Faltan datos obligatorios';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM categorias WHERE id_categoria = v_id_categoria
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe';
    END IF;

    INSERT INTO productos(
        nombre, descripcion, precio, id_categoria,
        imagen_url, stock, activo, fecha_alta
    )
    VALUES(
        v_nombre, v_descripcion, v_precio, v_id_categoria,
        v_imagen_url, v_stock, TRUE, NOW()
    );

    SET v_id_producto = LAST_INSERT_ID();

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Producto creado correctamente',
        'producto',
        (
            SELECT JSON_OBJECT(
                'id_producto', p.id_producto,
                'nombre', p.nombre,
                'descripcion', p.descripcion,
                'precio', p.precio,
                'id_categoria', p.id_categoria,
                'categoria', c.nombre,
                'imagen_url', p.imagen_url,
                'stock', p.stock,
                'activo', p.activo,
                'fecha_alta', p.fecha_alta
            )
            FROM productos p
            INNER JOIN categorias c
                ON p.id_categoria = c.id_categoria
            WHERE p.id_producto = v_id_producto
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_delete_producto_json$$
CREATE PROCEDURE sp_delete_producto_json(IN p_json JSON)
BEGIN
    DECLARE v_id_producto INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al eliminar producto'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_producto =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_producto')) AS UNSIGNED);

    IF v_id_producto IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_producto es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM productos WHERE id_producto = v_id_producto
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no existe';
    END IF;

    UPDATE productos
    SET activo = FALSE
    WHERE id_producto = v_id_producto;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Producto eliminado correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_update_producto_json$$
CREATE PROCEDURE sp_update_producto_json(IN p_json JSON)
BEGIN
    DECLARE v_id_producto INT;
    DECLARE v_nombre VARCHAR(200);
    DECLARE v_descripcion LONGTEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_id_categoria INT;
    DECLARE v_imagen_url VARCHAR(500);
    DECLARE v_stock INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al actualizar producto'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_producto =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_producto')) AS UNSIGNED);

    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descripcion'));
    SET v_precio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.precio')) AS DECIMAL(10,2));
    SET v_id_categoria = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_categoria')) AS UNSIGNED);
    SET v_imagen_url = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.imagen_url'));
    SET v_stock = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.stock')) AS SIGNED);

    IF NOT EXISTS (
        SELECT 1 FROM productos WHERE id_producto = v_id_producto
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Producto no existe';
    END IF;

    IF v_id_categoria IS NOT NULL
       AND NOT EXISTS (
            SELECT 1 FROM categorias WHERE id_categoria = v_id_categoria
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe';
    END IF;

    UPDATE productos
    SET
        nombre = COALESCE(v_nombre, nombre),
        descripcion = COALESCE(v_descripcion, descripcion),
        precio = COALESCE(v_precio, precio),
        id_categoria = COALESCE(v_id_categoria, id_categoria),
        imagen_url = COALESCE(v_imagen_url, imagen_url),
        stock = COALESCE(v_stock, stock)
    WHERE id_producto = v_id_producto;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Producto actualizado correctamente',
        'producto',
        (
            SELECT JSON_OBJECT(
                'id_producto', p.id_producto,
                'nombre', p.nombre,
                'descripcion', p.descripcion,
                'precio', p.precio,
                'id_categoria', p.id_categoria,
                'categoria', c.nombre,
                'imagen_url', p.imagen_url,
                'stock', p.stock,
                'activo', p.activo,
                'fecha_alta', p.fecha_alta
            )
            FROM productos p
            INNER JOIN categorias c
                ON p.id_categoria = c.id_categoria
            WHERE p.id_producto = v_id_producto
        )
    ) AS resultado;
END$$

DELIMITER ;
/*============================================================================0

  procedimientos para traer mascotas de clientes , insertarlas y editarlas


================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_mascotas_por_usuario_json$$
CREATE PROCEDURE sp_get_mascotas_por_usuario_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener mascotas'
        ) AS resultado;
    END;

    SET v_id_usuario =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_usuario es obligatorio';
    END IF;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'mascotas',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_mascota', t.id_mascota,
                        'nombre', t.nombre,
                        'id_especie', t.id_especie,
                        'especie', t.especie,
                        'raza', t.raza,
                        'sexo', t.sexo,
                        'tamanio', t.tamanio,
                        'fecha_nacimiento', t.fecha_nacimiento,
                        'comportamiento', t.comportamiento,
                        'observaciones', t.observaciones,
                        'tipo_pelaje', t.tipo_pelaje,
                        'castrado', t.castrado
                    )
                )
                FROM (
                    SELECT
                        m.id_mascota,
                        m.nombre,
                        m.id_especie,
                        UPPER(te.nombre) AS especie,
                        m.raza,
                        m.sexo,
                        m.tamanio,
                        m.fecha_nacimiento,
                        m.comportamiento,
                        m.observaciones,
                        m.tipo_pelaje,
                        m.castrado
                    FROM mascotas m
                    INNER JOIN tipo_especie te
                        ON te.id_especie = m.id_especie
                    WHERE m.id_usuario = v_id_usuario
                      AND m.activo = TRUE
                    ORDER BY m.nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_mascota_json$$
CREATE PROCEDURE sp_insert_mascota_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_id_especie INT;
    DECLARE v_raza VARCHAR(100);
    DECLARE v_tamanio VARCHAR(50);
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_sexo VARCHAR(20);
    DECLARE v_tipo_pelaje VARCHAR(50);
    DECLARE v_alergias_general LONGTEXT;
    DECLARE v_comportamiento LONGTEXT;
    DECLARE v_observaciones LONGTEXT;
    DECLARE v_castrado BOOLEAN DEFAULT FALSE;
    DECLARE v_id_mascota INT;

   
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    RESIGNAL;
END;

    START TRANSACTION;

    SET v_id_usuario =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_nombre =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_id_especie =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_especie')) AS UNSIGNED);
    SET v_raza =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.raza'));
    SET v_tamanio =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tamanio'));
    SET v_fecha_nacimiento =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_nacimiento')) AS DATE);
    SET v_sexo =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.sexo'));
    SET v_tipo_pelaje =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tipo_pelaje'));
    SET v_alergias_general =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.alergias_general'));
    SET v_comportamiento =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.comportamiento'));
    SET v_observaciones =
        JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));
    SET v_castrado =
    CASE
        WHEN JSON_EXTRACT(p_json, '$.mascota.castrado') IS NULL THEN 0
        WHEN JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.mascota.castrado')) IN ('true', '1', 'TRUE') THEN 1
        ELSE 0
    END;

    IF v_id_usuario IS NULL OR v_nombre IS NULL OR v_id_especie IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_usuario, nombre y id_especie son obligatorios';
    END IF;

    INSERT INTO mascotas (
        id_usuario,
        nombre,
        id_especie,
        raza,
        tamanio,
        fecha_nacimiento,
        sexo,
        tipo_pelaje,
        alergias_general,
        comportamiento,
        observaciones,
        castrado,
        activo,
        fecha_registro
    )
    VALUES (
        v_id_usuario,
        v_nombre,
        v_id_especie,
        v_raza,
        v_tamanio,
        v_fecha_nacimiento,
        v_sexo,
        v_tipo_pelaje,
        v_alergias_general,
        v_comportamiento,
        v_observaciones,
        v_castrado,
        TRUE,
        NOW()
    );

    SET v_id_mascota = LAST_INSERT_ID();

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Mascota registrada correctamente',
        'mascota',
        (
            SELECT JSON_OBJECT(
                'id_mascota', m.id_mascota,
                'nombre', m.nombre,
                'especie', te.nombre,
                'raza', m.raza,
                'tamanio', m.tamanio,
                'fecha_nacimiento', m.fecha_nacimiento,
                'sexo', m.sexo,
                'castrado', m.castrado
            )
            FROM mascotas m
            INNER JOIN tipo_especie te
                ON te.id_especie = m.id_especie
            WHERE m.id_mascota = v_id_mascota
        )
    ) AS resultado;
END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_recordatorios_mascotas_usuario_json$$
CREATE PROCEDURE sp_get_recordatorios_mascotas_usuario_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener recordatorios'
        ) AS resultado;
    END;

    SET v_id_usuario =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_usuario obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM usuarios WHERE id_usuario = v_id_usuario
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Recordatorios obtenidos correctamente',
        'mascotas',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_mascota', z.id_mascota,
                        'nombre', z.nombre,
                        'especie', z.especie,
                        'raza', z.raza,
                        'tamanio', z.tamanio,
                        'sexo', z.sexo,
                        'recordatorios', z.recordatorios
                    )
                )
                FROM (
                    SELECT
                        m.id_mascota,
                        m.nombre,
                        te.nombre AS especie,
                        m.raza,
                        m.tamanio,
                        m.sexo,

                        COALESCE(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'tipo', r.tipo,
                                        'id_registro', r.id_registro,
                                        'id_item', r.id_item,
                                        'nombre', r.nombre,
                                        'subtipo', r.subtipo,
                                        'fecha_proxima', r.fecha_proxima,
                                        'dias_restantes', r.dias_restantes,
                                        'estado', r.estado,
                                        'observaciones', r.observaciones
                                    )
                                )
                                FROM (
                                    SELECT
                                        'VACUNA' AS tipo,
                                        vm.id_vacuna_mascota AS id_registro,
                                        v.id_vacuna AS id_item,
                                        v.nombre,
                                        NULL AS subtipo,
                                        vm.proxima_dosis AS fecha_proxima,
                                        DATEDIFF(vm.proxima_dosis, CURDATE()) AS dias_restantes,
                                        CASE
                                            WHEN DATEDIFF(vm.proxima_dosis, CURDATE()) = 0 THEN 'HOY'
                                            WHEN DATEDIFF(vm.proxima_dosis, CURDATE()) BETWEEN 1 AND 7 THEN 'PROXIMO'
                                            ELSE 'PENDIENTE'
                                        END AS estado,
                                        vm.observaciones
                                    FROM vacunas_mascota vm
                                    INNER JOIN vacunas v
                                        ON v.id_vacuna = vm.id_vacuna
                                    WHERE vm.id_mascota = m.id_mascota
                                      AND vm.proxima_dosis IS NOT NULL
                                      AND vm.proxima_dosis >= CURDATE()

                                    UNION ALL

                                    SELECT
                                        'DESPARASITACION',
                                        dm.id_desparasitacion_mascota,
                                        d.id_desparasitacion,
                                        d.nombre,
                                        COALESCE(dm.tipo, d.tipo),
                                        dm.proxima_dosis,
                                        DATEDIFF(dm.proxima_dosis, CURDATE()),
                                        CASE
                                            WHEN DATEDIFF(dm.proxima_dosis, CURDATE()) = 0 THEN 'HOY'
                                            WHEN DATEDIFF(dm.proxima_dosis, CURDATE()) BETWEEN 1 AND 7 THEN 'PROXIMO'
                                            ELSE 'PENDIENTE'
                                        END,
                                        dm.observaciones
                                    FROM desparasitaciones_mascota dm
                                    INNER JOIN desparasitaciones d
                                        ON d.id_desparasitacion = dm.id_desparasitacion
                                    WHERE dm.id_mascota = m.id_mascota
                                      AND dm.proxima_dosis IS NOT NULL
                                      AND dm.proxima_dosis >= CURDATE()
                                ) r
                            ),
                            JSON_ARRAY()
                        ) AS recordatorios

                    FROM mascotas m
                    LEFT JOIN tipo_especie te
                        ON te.id_especie = m.id_especie
                    WHERE m.id_usuario = v_id_usuario
                      AND m.activo = TRUE
                    ORDER BY m.nombre
                ) z
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$

DELIMITER ;
/*============================================================================0

  procedimientos de administrador obtencion y modificacion de historias clinicas


================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_clientes_con_mascotas_json_filtrado$$
CREATE PROCEDURE sp_get_clientes_con_mascotas_json_filtrado(IN p_json JSON)
BEGIN
    DECLARE v_apellido VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener clientes'
        ) AS resultado;
    END;

    SET v_apellido = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.apellido'));

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'clientes',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_usuario', t.id_usuario,
                        'nombre', t.nombre,
                        'apellido', t.apellido,
                        'nombre_completo', t.nombre_completo,
                        'email', t.email,
                        'telefono', t.telefono,
                        'activo', t.activo,
                        'fecha_alta', t.fecha_alta,
                        'mascotas', t.mascotas
                    )
                )
                FROM (
                    SELECT
                        u.id_usuario,
                        u.nombre,
                        u.apellido,
                        CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
                        u.email,
                        u.telefono,
                        u.activo,
                        u.fecha_alta,
                        COALESCE(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'id_mascota', x.id_mascota,
                                        'nombre_mascota', x.nombre_mascota,
                                        'especie', x.especie,
                                        'raza', x.raza,
                                        'tamanio', x.tamanio,
                                        'fecha_nacimiento', x.fecha_nacimiento,
                                        'sexo', x.sexo,
                                        'tipo_pelaje', x.tipo_pelaje,
                                        'alergias_general', x.alergias_general,
                                        'comportamiento', x.comportamiento,
                                        'observaciones', x.observaciones,
                                        'activo', x.activo,
                                        'fecha_registro', x.fecha_registro,
                                        'castrado', x.castrado
                                    )
                                )
                                FROM (
                                    SELECT
                                        m.id_mascota,
                                        m.nombre AS nombre_mascota,
                                        te.nombre AS especie,
                                        m.raza,
                                        m.tamanio,
                                        m.fecha_nacimiento,
                                        m.sexo,
                                        m.tipo_pelaje,
                                        m.alergias_general,
                                        m.comportamiento,
                                        m.observaciones,
                                        m.activo,
                                        m.fecha_registro,
                                        m.castrado
                                    FROM mascotas m
                                    INNER JOIN tipo_especie te
                                        ON te.id_especie = m.id_especie
                                    WHERE m.id_usuario = u.id_usuario
                                      AND m.activo = TRUE
                                    ORDER BY m.nombre
                                ) x
                            ),
                            JSON_ARRAY()
                        ) AS mascotas
                    FROM usuarios u
                    WHERE u.rol = 'CLIENTE'
                      AND u.activo = TRUE
                      AND (
                          v_apellido IS NULL
                          OR TRIM(v_apellido) = ''
                          OR LOWER(u.apellido) LIKE CONCAT('%', LOWER(v_apellido), '%')
                      )
                    ORDER BY u.apellido, u.nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_clientes_con_mascotas_json$$
CREATE PROCEDURE sp_get_clientes_con_mascotas_json()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener clientes'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'clientes',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_usuario', t.id_usuario,
                        'nombre_completo', t.nombre_completo,
                        'email', t.email,
                        'telefono', t.telefono,
                        'activo', t.activo,
                        'mascotas', t.mascotas
                    )
                )
                FROM (
                    SELECT
                        u.id_usuario,
                        CONCAT(u.nombre, ' ', u.apellido) AS nombre_completo,
                        u.email,
                        u.telefono,
                        u.activo,
                        COALESCE(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'id_mascota', x.id_mascota,
                                        'nombre_mascota', x.nombre_mascota,
                                        'especie', x.especie,
                                        'sexo', x.sexo
                                    )
                                )
                                FROM (
                                    SELECT
                                        m.id_mascota,
                                        m.nombre AS nombre_mascota,
                                        te.nombre AS especie,
                                        m.sexo
                                    FROM mascotas m
                                    INNER JOIN tipo_especie te
                                        ON te.id_especie = m.id_especie
                                    WHERE m.id_usuario = u.id_usuario
                                      AND m.activo = TRUE
                                    ORDER BY m.nombre
                                ) x
                            ),
                            JSON_ARRAY()
                        ) AS mascotas
                    FROM usuarios u
                    WHERE u.rol = 'CLIENTE'
                      AND u.activo = TRUE
                    ORDER BY u.apellido, u.nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_informacioncompleta_mascota$$
CREATE PROCEDURE sp_get_informacioncompleta_mascota(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;

    SET v_id_usuario =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);

    SET v_id_mascota =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
    ) THEN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'La mascota no pertenece al usuario'
        ) AS json;
    ELSE
        SELECT JSON_OBJECT(
            'id_mascota', m.id_mascota,
            'nombre', m.nombre,
            'id_especie', m.id_especie,
            'especie', te.nombre,
            'raza', m.raza,
            'tamanio', m.tamanio,
            'fecha_nacimiento', m.fecha_nacimiento,
            'sexo', m.sexo,
            'tipo_pelaje', m.tipo_pelaje,
            'comportamiento', m.comportamiento,
            'observaciones', m.observaciones,
            'castrado', m.castrado,

            'pesos', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'fecha', p.fecha,
                            'peso', p.peso,
                            'observaciones', p.observaciones
                        )
                    )
                    FROM (
                        SELECT fecha, peso, observaciones
                        FROM peso_mascota
                        WHERE id_mascota = m.id_mascota
                        ORDER BY fecha DESC
                    ) p
                ),
                JSON_ARRAY()
            ),

            'alergias', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'nombre', a.nombre,
                            'severidad', am.severidad,
                            'observaciones', am.observaciones,
                            'fecha_registro', am.fecha_registro
                        )
                    )
                    FROM alergias_mascota am
                    INNER JOIN alergias a
                        ON a.id_alergia = am.id_alergia
                    WHERE am.id_mascota = m.id_mascota
                ),
                JSON_ARRAY()
            ),

            'vacunas', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'nombre', v.nombre,
                            'fecha_aplicacion', vm.fecha_aplicacion,
                            'proxima_dosis', vm.proxima_dosis,
                            'observaciones', vm.observaciones
                        )
                    )
                    FROM vacunas_mascota vm
                    INNER JOIN vacunas v
                        ON v.id_vacuna = vm.id_vacuna
                    WHERE vm.id_mascota = m.id_mascota
                ),
                JSON_ARRAY()
            ),

            'desparasitaciones', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'nombre', d.nombre,
                            'tipo', d.tipo,
                            'fecha_aplicacion', dm.fecha_aplicacion,
                            'proxima_dosis', dm.proxima_dosis,
                            'observaciones', dm.observaciones
                        )
                    )
                    FROM desparasitaciones_mascota dm
                    INNER JOIN desparasitaciones d
                        ON d.id_desparasitacion = dm.id_desparasitacion
                    WHERE dm.id_mascota = m.id_mascota
                ),
                JSON_ARRAY()
            ),

            'enfermedades', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'nombre', e.nombre,
                            'estado', em.estado,
                            'fecha_diagnostico', em.fecha_diagnostico,
                            'observaciones', em.observaciones
                        )
                    )
                    FROM enfermedades_mascota em
                    INNER JOIN enfermedades e
                        ON e.id_enfermedad = em.id_enfermedad
                    WHERE em.id_mascota = m.id_mascota
                ),
                JSON_ARRAY()
            ),

            'historia_clinica', COALESCE(
                (
                    SELECT JSON_OBJECT(
                        'id_historia_clinica', hc.id_historia_clinica,
                        'consultas', COALESCE(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'id_consulta', c.id_consulta,
                                        'fecha', c.fecha,
                                        'motivo_consulta', c.motivo_consulta,
                                        'diagnostico', c.diagnostico,
                                        'tratamiento', c.tratamiento,
                                        'anamnesis', c.anamnesis,
                                        'examen_general', c.examen_general,
                                        'diagnostico_presuntivo', c.diagnostico_presuntivo,
                                        'observaciones', c.observaciones,

                                        'tratamientos', COALESCE(
                                            (
                                                SELECT JSON_ARRAYAGG(
                                                    JSON_OBJECT(
                                                        'nombre', med.nombre,
                                                        'dosis', t.dosis,
                                                        'frecuencia', t.frecuencia,
                                                        'duracion_dias', t.duracion_dias
                                                    )
                                                )
                                                FROM tratamientos t
                                                LEFT JOIN medicamentos med
                                                    ON med.id_medicamento = t.id_medicamento
                                                WHERE t.id_consulta = c.id_consulta
                                            ),
                                            JSON_ARRAY()
                                        ),

                                        'estudios', COALESCE(
                                            (
                                                SELECT JSON_ARRAYAGG(
                                                    JSON_OBJECT(
                                                        'tipo_estudio', e.tipo_estudio,
                                                        'resultado', e.resultado,
                                                        'fecha', e.fecha
                                                    )
                                                )
                                                FROM estudios_clinicos e
                                                WHERE e.id_consulta = c.id_consulta
                                            ),
                                            JSON_ARRAY()
                                        )
                                    )
                                )
                                FROM (
                                    SELECT *
                                    FROM consultas_clinicas
                                    WHERE id_historia_clinica = hc.id_historia_clinica
                                    ORDER BY fecha DESC
                                ) c
                            ),
                            JSON_ARRAY()
                        )
                    )
                    FROM historias_clinicas hc
                    WHERE hc.id_mascota = m.id_mascota
                    LIMIT 1
                ),
                JSON_OBJECT()
            )
        ) AS json
        FROM mascotas m
        INNER JOIN tipo_especie te
            ON te.id_especie = m.id_especie
        WHERE m.id_mascota = v_id_mascota
          AND m.id_usuario = v_id_usuario;
    END IF;
END$$


DROP PROCEDURE IF EXISTS sp_editar_infogeneral_mascota$$
CREATE PROCEDURE sp_editar_infogeneral_mascota(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_id_especie INT;
    DECLARE v_raza VARCHAR(100);
    DECLARE v_tamanio VARCHAR(20);
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_sexo VARCHAR(20);
    DECLARE v_tipo_pelaje VARCHAR(100);
    DECLARE v_alergias_general VARCHAR(500);
    DECLARE v_comportamiento VARCHAR(300);
    DECLARE v_observaciones VARCHAR(1000);
    DECLARE v_castrado BOOLEAN;

    /*DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al actualizar mascota'
        ) AS resultado;
    END;*/
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    RESIGNAL;
END;

    START TRANSACTION;

    SET v_id_usuario =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_id_especie =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_especie')) AS UNSIGNED);
    SET v_raza = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.raza'));
    SET v_tamanio = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tamanio'));
    SET v_fecha_nacimiento =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_nacimiento')) AS DATE);
    SET v_sexo = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.sexo'));
    SET v_tipo_pelaje = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tipo_pelaje'));
    SET v_alergias_general = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.alergias_general'));
    SET v_comportamiento = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.comportamiento'));
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));
    SET v_castrado =
CASE
    WHEN JSON_EXTRACT(p_json, '$.castrado') IS NULL THEN NULL
    WHEN JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.castrado')) IN ('true', '1', 'TRUE') THEN 1
    ELSE 0
END;

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mascota no encontrada o no pertenece al usuario';
    END IF;

    UPDATE mascotas
    SET
        nombre = COALESCE(v_nombre, nombre),
        id_especie = COALESCE(v_id_especie, id_especie),
        raza = COALESCE(v_raza, raza),
        tamanio = COALESCE(v_tamanio, tamanio),
        fecha_nacimiento = COALESCE(v_fecha_nacimiento, fecha_nacimiento),
        sexo = COALESCE(v_sexo, sexo),
        tipo_pelaje = COALESCE(v_tipo_pelaje, tipo_pelaje),
        alergias_general = COALESCE(v_alergias_general, alergias_general),
        comportamiento = COALESCE(v_comportamiento, comportamiento),
        observaciones = COALESCE(v_observaciones, observaciones),
        castrado = COALESCE(v_castrado, castrado)
    WHERE id_mascota = v_id_mascota;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Mascota actualizada correctamente',
        'mascota',
        (
            SELECT JSON_OBJECT(
                'id_mascota', m.id_mascota,
                'id_usuario', m.id_usuario,
                'nombre', m.nombre,
                'especie', te.nombre,
                'raza', m.raza,
                'tamanio', m.tamanio,
                'fecha_nacimiento', m.fecha_nacimiento,
                'sexo', m.sexo,
                'tipo_pelaje', m.tipo_pelaje,
                'alergias_general', m.alergias_general,
                'comportamiento', m.comportamiento,
                'observaciones', m.observaciones,
                'activo', m.activo,
                'fecha_registro', m.fecha_registro,
                'castrado', m.castrado
            )
            FROM mascotas m
            INNER JOIN tipo_especie te
                ON te.id_especie = m.id_especie
            WHERE m.id_mascota = v_id_mascota
        )
    ) AS resultado;
END$$



DROP PROCEDURE IF EXISTS sp_insert_consulta_clinica_json$$
CREATE PROCEDURE sp_insert_consulta_clinica_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_motivo VARCHAR(500);
    DECLARE v_anamnesis LONGTEXT;
    DECLARE v_examen LONGTEXT;
    DECLARE v_diagnostico_presuntivo LONGTEXT;
    DECLARE v_diagnostico LONGTEXT;
    DECLARE v_tratamiento_general LONGTEXT;
    DECLARE v_observaciones LONGTEXT;

    DECLARE v_id_historia INT;
    DECLARE v_id_consulta INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;

    DECLARE v_id_medicamento INT;
    DECLARE v_dosis VARCHAR(100);
    DECLARE v_frecuencia VARCHAR(100);
    DECLARE v_duracion_dias INT;
    DECLARE v_indicaciones VARCHAR(1000);

    DECLARE v_tipo_estudio VARCHAR(150);
    DECLARE v_resultado LONGTEXT;
    DECLARE v_obs_estudio VARCHAR(1000);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar consulta'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_motivo = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.motivo_consulta'));
    SET v_anamnesis = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.anamnesis'));
    SET v_examen = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.examen_general'));
    SET v_diagnostico_presuntivo = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.diagnostico_presuntivo'));
    SET v_diagnostico = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.diagnostico'));
    SET v_tratamiento_general = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tratamiento'));
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    SELECT id_historia_clinica
    INTO v_id_historia
    FROM historias_clinicas
    WHERE id_mascota = v_id_mascota
    LIMIT 1;

    IF v_id_historia IS NULL THEN
        INSERT INTO historias_clinicas
        (id_mascota, observaciones_generales)
        VALUES
        (v_id_mascota, 'Inicio de historia clínica');

        SET v_id_historia = LAST_INSERT_ID();
    END IF;

    INSERT INTO consultas_clinicas (
        id_historia_clinica,
        motivo_consulta,
        anamnesis,
        examen_general,
        diagnostico_presuntivo,
        diagnostico,
        tratamiento,
        observaciones
    )
    VALUES (
        v_id_historia,
        v_motivo,
        v_anamnesis,
        v_examen,
        v_diagnostico_presuntivo,
        v_diagnostico,
        v_tratamiento_general,
        v_observaciones
    );

    SET v_id_consulta = LAST_INSERT_ID();

    SET v_total = JSON_LENGTH(JSON_EXTRACT(p_json, '$.tratamientos'));
    SET v_i = 0;

    WHILE v_i < COALESCE(v_total, 0) DO
        SET v_id_medicamento = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.tratamientos[', v_i, '].id_medicamento'))) AS UNSIGNED);
        SET v_dosis = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.tratamientos[', v_i, '].dosis')));
        SET v_frecuencia = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.tratamientos[', v_i, '].frecuencia')));
        SET v_duracion_dias = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.tratamientos[', v_i, '].duracion_dias'))) AS SIGNED);
        SET v_indicaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.tratamientos[', v_i, '].indicaciones')));

        IF v_id_medicamento IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1
                FROM medicamentos
                WHERE id_medicamento = v_id_medicamento
            ) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Uno o más medicamentos no existen';
            END IF;

            INSERT INTO tratamientos (
                id_consulta,
                id_medicamento,
                dosis,
                frecuencia,
                duracion_dias,
                indicaciones
            )
            VALUES (
                v_id_consulta,
                v_id_medicamento,
                v_dosis,
                v_frecuencia,
                v_duracion_dias,
                v_indicaciones
            );
        END IF;

        SET v_i = v_i + 1;
    END WHILE;

    SET v_total = JSON_LENGTH(JSON_EXTRACT(p_json, '$.estudios'));
    SET v_i = 0;

    WHILE v_i < COALESCE(v_total, 0) DO
        SET v_tipo_estudio = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].tipo_estudio')));
        SET v_resultado = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].resultado')));
        SET v_obs_estudio = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].observaciones')));

        IF v_tipo_estudio IS NOT NULL THEN
            INSERT INTO estudios_clinicos (
                id_consulta,
                tipo_estudio,
                resultado,
                observaciones
            )
            VALUES (
                v_id_consulta,
                v_tipo_estudio,
                v_resultado,
                v_obs_estudio
            );
        END IF;

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Consulta registrada correctamente',
        'id_consulta', v_id_consulta
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_update_consulta_clinica_json$$
CREATE PROCEDURE sp_update_consulta_clinica_json(IN p_json JSON)
BEGIN
    DECLARE v_id_consulta INT;
    DECLARE v_motivo VARCHAR(500);
    DECLARE v_anamnesis LONGTEXT;
    DECLARE v_examen LONGTEXT;
    DECLARE v_diagnostico_presuntivo LONGTEXT;
    DECLARE v_diagnostico LONGTEXT;
    DECLARE v_tratamiento LONGTEXT;
    DECLARE v_observaciones LONGTEXT;

    DECLARE v_i INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_tipo_estudio VARCHAR(150);
    DECLARE v_resultado LONGTEXT;
    DECLARE v_obs_estudio VARCHAR(1000);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al actualizar consulta'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_consulta = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_consulta')) AS UNSIGNED);
    SET v_motivo = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.motivo_consulta'));
    SET v_anamnesis = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.anamnesis'));
    SET v_examen = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.examen_general'));
    SET v_diagnostico_presuntivo = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.diagnostico_presuntivo'));
    SET v_diagnostico = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.diagnostico'));
    SET v_tratamiento = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tratamiento'));
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF v_id_consulta IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_consulta obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM consultas_clinicas
        WHERE id_consulta = v_id_consulta
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La consulta no existe';
    END IF;

    UPDATE consultas_clinicas
    SET
        motivo_consulta = COALESCE(v_motivo, motivo_consulta),
        anamnesis = COALESCE(v_anamnesis, anamnesis),
        examen_general = COALESCE(v_examen, examen_general),
        diagnostico_presuntivo = COALESCE(v_diagnostico_presuntivo, diagnostico_presuntivo),
        diagnostico = COALESCE(v_diagnostico, diagnostico),
        tratamiento = COALESCE(v_tratamiento, tratamiento),
        observaciones = COALESCE(v_observaciones, observaciones)
    WHERE id_consulta = v_id_consulta;

    IF JSON_LENGTH(JSON_EXTRACT(p_json, '$.estudios')) IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1
            FROM estudios_clinicos
            WHERE id_consulta = v_id_consulta
        ) THEN
            SET v_total = JSON_LENGTH(JSON_EXTRACT(p_json, '$.estudios'));
            SET v_i = 0;

            WHILE v_i < COALESCE(v_total, 0) DO
                SET v_tipo_estudio = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].tipo_estudio')));
                SET v_resultado = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].resultado')));
                SET v_obs_estudio = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.estudios[', v_i, '].observaciones')));

                IF v_tipo_estudio IS NOT NULL THEN
                    INSERT INTO estudios_clinicos (
                        id_consulta,
                        tipo_estudio,
                        resultado,
                        observaciones
                    )
                    VALUES (
                        v_id_consulta,
                        v_tipo_estudio,
                        v_resultado,
                        v_obs_estudio
                    );
                END IF;

                SET v_i = v_i + 1;
            END WHILE;
        END IF;
    END IF;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Consulta actualizada correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_delete_consulta_clinica_json$$
CREATE PROCEDURE sp_delete_consulta_clinica_json(IN p_json JSON)
BEGIN
    DECLARE v_id_consulta INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al eliminar consulta'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_consulta =
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_consulta')) AS UNSIGNED);

    IF v_id_consulta IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_consulta es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM consultas_clinicas
        WHERE id_consulta = v_id_consulta
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La consulta no existe';
    END IF;

    DELETE FROM tratamientos
    WHERE id_consulta = v_id_consulta;

    DELETE FROM estudios_clinicos
    WHERE id_consulta = v_id_consulta;

    DELETE FROM consultas_clinicas
    WHERE id_consulta = v_id_consulta;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Consulta eliminada correctamente'
    ) AS resultado;
END$$

DELIMITER ;
/*============================================================================0
  procedimientos de administrar medicamentos
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_medicamentos$$
CREATE PROCEDURE sp_get_medicamentos()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener medicamentos'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'medicamentos',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_medicamento', t.id_medicamento,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT
                        id_medicamento,
                        nombre
                    FROM medicamentos
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_medicamento$$
CREATE PROCEDURE sp_insert_medicamento(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_id_medicamento INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear medicamento'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre del medicamento es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(TRIM(v_nombre));

    SELECT id_medicamento
    INTO v_id_medicamento
    FROM medicamentos
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_medicamento IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'El medicamento ya existía',
            'medicamento',
            (
                SELECT JSON_OBJECT(
                    'id_medicamento', m.id_medicamento,
                    'nombre', m.nombre
                )
                FROM medicamentos m
                WHERE m.id_medicamento = v_id_medicamento
            )
        ) AS resultado;

    ELSE

        INSERT INTO medicamentos(nombre)
        VALUES(v_nombre_normalizado);

        SET v_id_medicamento = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Medicamento creado correctamente',
            'medicamento',
            (
                SELECT JSON_OBJECT(
                    'id_medicamento', m.id_medicamento,
                    'nombre', m.nombre
                )
                FROM medicamentos m
                WHERE m.id_medicamento = v_id_medicamento
            )
        ) AS resultado;

    END IF;
END$$

DELIMITER ;
/*============================================================================0
  procedimientos de administrar vacunas
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_insert_vacunacion_json$$
CREATE PROCEDURE sp_insert_vacunacion_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_id_vacuna INT;
    DECLARE v_fecha_aplicacion DATE;
    DECLARE v_proxima_dosis DATE;
    DECLARE v_observaciones VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar vacunación'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_id_vacuna = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_vacuna')) AS UNSIGNED);
    SET v_fecha_aplicacion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_aplicacion')) AS DATE);
    SET v_proxima_dosis = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.proxima_dosis')) AS DATE);
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM vacunas
        WHERE id_vacuna = v_id_vacuna
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La vacuna no existe';
    END IF;

    INSERT INTO vacunas_mascota (
        id_mascota,
        id_vacuna,
        fecha_aplicacion,
        proxima_dosis,
        observaciones
    )
    VALUES (
        v_id_mascota,
        v_id_vacuna,
        v_fecha_aplicacion,
        v_proxima_dosis,
        v_observaciones
    );

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Vacunación registrada correctamente',
        'vacunacion', JSON_OBJECT(
            'id_mascota', v_id_mascota,
            'id_vacuna', v_id_vacuna,
            'fecha_aplicacion', v_fecha_aplicacion,
            'proxima_dosis', v_proxima_dosis
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_vacunas$$
CREATE PROCEDURE sp_get_vacunas()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener vacunas'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'vacunas',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_vacuna', t.id_vacuna,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT id_vacuna, nombre
                    FROM vacunas
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_vacuna_json$$
CREATE PROCEDURE sp_insert_vacuna_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_id_vacuna INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear vacuna'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre de la vacuna es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(TRIM(v_nombre));

    SELECT id_vacuna
    INTO v_id_vacuna
    FROM vacunas
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_vacuna IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'La vacuna ya existía',
            'vacuna',
            (
                SELECT JSON_OBJECT(
                    'id_vacuna', v.id_vacuna,
                    'nombre', v.nombre
                )
                FROM vacunas v
                WHERE v.id_vacuna = v_id_vacuna
            )
        ) AS resultado;

    ELSE

        INSERT INTO vacunas(nombre)
        VALUES(v_nombre_normalizado);

        SET v_id_vacuna = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Vacuna creada correctamente',
            'vacuna',
            (
                SELECT JSON_OBJECT(
                    'id_vacuna', v.id_vacuna,
                    'nombre', v.nombre
                )
                FROM vacunas v
                WHERE v.id_vacuna = v_id_vacuna
            )
        ) AS resultado;

    END IF;
END$$

DELIMITER ;
/*============================================================================0
  procedimientos de administrar desparasitacion
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_insert_desparasitacion_mascota_json$$
CREATE PROCEDURE sp_insert_desparasitacion_mascota_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_id_desparasitacion INT;
    DECLARE v_fecha_aplicacion DATE;
    DECLARE v_proxima_dosis DATE;
    DECLARE v_observaciones VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar desparasitación'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_id_desparasitacion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_desparasitacion')) AS UNSIGNED);
    SET v_fecha_aplicacion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_aplicacion')) AS DATE);
    SET v_proxima_dosis = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.proxima_dosis')) AS DATE);
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM desparasitaciones
        WHERE id_desparasitacion = v_id_desparasitacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El desparasitante no existe';
    END IF;

    INSERT INTO desparasitaciones_mascota (
        id_mascota,
        id_desparasitacion,
        fecha_aplicacion,
        proxima_dosis,
        observaciones
    )
    VALUES (
        v_id_mascota,
        v_id_desparasitacion,
        v_fecha_aplicacion,
        v_proxima_dosis,
        v_observaciones
    );

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Desparasitación registrada correctamente',
        'desparasitacion', JSON_OBJECT(
            'id_mascota', v_id_mascota,
            'id_desparasitacion', v_id_desparasitacion,
            'fecha_aplicacion', v_fecha_aplicacion,
            'proxima_dosis', v_proxima_dosis
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_desparasitaciones$$
CREATE PROCEDURE sp_get_desparasitaciones()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener desparasitaciones'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'desparasitaciones',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_desparasitacion', t.id_desparasitacion,
                        'nombre', t.nombre,
                        'tipo', t.tipo
                    )
                )
                FROM (
                    SELECT
                        id_desparasitacion,
                        nombre,
                        tipo
                    FROM desparasitaciones
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_desparasitacion_catalogo_json$$
CREATE PROCEDURE sp_insert_desparasitacion_catalogo_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_tipo VARCHAR(50);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_tipo_normalizado VARCHAR(50);
    DECLARE v_id_desparasitacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear desparasitante'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));
    SET v_tipo = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tipo')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(v_nombre);

    IF v_tipo IS NOT NULL AND v_tipo <> '' THEN
        SET v_tipo_normalizado = UPPER(v_tipo);
    ELSE
        SET v_tipo_normalizado = NULL;
    END IF;

    IF v_tipo_normalizado IS NOT NULL
       AND v_tipo_normalizado NOT IN ('INTERNO', 'EXTERNO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo inválido (INTERNO / EXTERNO)';
    END IF;

    SELECT id_desparasitacion
    INTO v_id_desparasitacion
    FROM desparasitaciones
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_desparasitacion IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'El desparasitante ya existía',
            'desparasitacion',
            (
                SELECT JSON_OBJECT(
                    'id_desparasitacion', d.id_desparasitacion,
                    'nombre', d.nombre,
                    'tipo', d.tipo
                )
                FROM desparasitaciones d
                WHERE d.id_desparasitacion = v_id_desparasitacion
            )
        ) AS resultado;

    ELSE

        INSERT INTO desparasitaciones (
            nombre,
            tipo
        )
        VALUES (
            v_nombre_normalizado,
            v_tipo_normalizado
        );

        SET v_id_desparasitacion = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Desparasitante creado correctamente',
            'desparasitacion',
            (
                SELECT JSON_OBJECT(
                    'id_desparasitacion', d.id_desparasitacion,
                    'nombre', d.nombre,
                    'tipo', d.tipo
                )
                FROM desparasitaciones d
                WHERE d.id_desparasitacion = v_id_desparasitacion
            )
        ) AS resultado;

    END IF;
END$$



DROP PROCEDURE IF EXISTS sp_insert_peso_json$$
CREATE PROCEDURE sp_insert_peso_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_fecha DATE;
    DECLARE v_peso DECIMAL(5,2);
    DECLARE v_observaciones VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar peso'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_fecha = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha')) AS DATE);
    SET v_peso = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.peso')) AS DECIMAL(5,2));
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    SET v_fecha = COALESCE(v_fecha, CURDATE());

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    IF v_peso IS NULL OR v_peso <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Peso inválido';
    END IF;

    INSERT INTO peso_mascota (
        id_mascota,
        fecha,
        peso,
        observaciones
    )
    VALUES (
        v_id_mascota,
        v_fecha,
        v_peso,
        v_observaciones
    );

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Peso registrado correctamente',
        'peso', JSON_OBJECT(
            'id_mascota', v_id_mascota,
            'fecha', v_fecha,
            'peso', v_peso
        )
    ) AS resultado;
END$$

DELIMITER ;


/*============================================================================0
  procedimientos de administrar enfermedad
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_insert_enfermedad_json$$
CREATE PROCEDURE sp_insert_enfermedad_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_id_enfermedad INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_fecha_diagnostico DATE;
    DECLARE v_observaciones VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar enfermedad'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_id_enfermedad = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_enfermedad')) AS UNSIGNED);
    SET v_estado = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.estado'));
    SET v_fecha_diagnostico = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_diagnostico')) AS DATE);
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM enfermedades
        WHERE id_enfermedad = v_id_enfermedad
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La enfermedad no existe';
    END IF;

    SET v_estado = UPPER(TRIM(v_estado));

    IF v_estado IN ('CURADO', 'CURADA') THEN
        SET v_estado = 'CURADA';
    END IF;

    IF v_estado = 'CRÓNICA' THEN
        SET v_estado = 'CRONICA';
    END IF;

    IF v_estado NOT IN ('ACTIVA', 'CURADA', 'CRONICA') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado inválido (ACTIVA, CURADA, CRONICA)';
    END IF;

    INSERT INTO enfermedades_mascota (
        id_mascota,
        id_enfermedad,
        fecha_diagnostico,
        estado,
        observaciones
    )
    VALUES (
        v_id_mascota,
        v_id_enfermedad,
        v_fecha_diagnostico,
        v_estado,
        v_observaciones
    );

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Enfermedad registrada correctamente',
        'enfermedad', JSON_OBJECT(
            'id_mascota', v_id_mascota,
            'id_enfermedad', v_id_enfermedad,
            'fecha_diagnostico', v_fecha_diagnostico,
            'estado', v_estado
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_enfermedades$$
CREATE PROCEDURE sp_get_enfermedades()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener enfermedades'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'enfermedades',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_enfermedad', t.id_enfermedad,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT
                        id_enfermedad,
                        nombre
                    FROM enfermedades
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_enfermedad_catalogo_json$$
CREATE PROCEDURE sp_insert_enfermedad_catalogo_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_id_enfermedad INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear enfermedad'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre de la enfermedad es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(v_nombre);

    SELECT id_enfermedad
    INTO v_id_enfermedad
    FROM enfermedades
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_enfermedad IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'La enfermedad ya existía',
            'enfermedad',
            (
                SELECT JSON_OBJECT(
                    'id_enfermedad', e.id_enfermedad,
                    'nombre', e.nombre
                )
                FROM enfermedades e
                WHERE e.id_enfermedad = v_id_enfermedad
            )
        ) AS resultado;

    ELSE

        INSERT INTO enfermedades(nombre)
        VALUES(v_nombre_normalizado);

        SET v_id_enfermedad = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Enfermedad creada correctamente',
            'enfermedad',
            (
                SELECT JSON_OBJECT(
                    'id_enfermedad', e.id_enfermedad,
                    'nombre', e.nombre
                )
                FROM enfermedades e
                WHERE e.id_enfermedad = v_id_enfermedad
            )
        ) AS resultado;

    END IF;
END$$

DELIMITER ;

/*============================================================================0
  procedimientos de administrar alergia
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_insert_alergia_json$$
CREATE PROCEDURE sp_insert_alergia_json(IN p_json JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_mascota INT;
    DECLARE v_id_alergia INT;
    DECLARE v_severidad VARCHAR(20);
    DECLARE v_observaciones VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al registrar alergia'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_usuario')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);
    SET v_id_alergia = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_alergia')) AS UNSIGNED);
    SET v_severidad = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.severidad'));
    SET v_observaciones = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.observaciones'));

    IF NOT EXISTS (
        SELECT 1
        FROM mascotas
        WHERE id_mascota = v_id_mascota
          AND id_usuario = v_id_usuario
          AND activo = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no pertenece al usuario';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM alergias
        WHERE id_alergia = v_id_alergia
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La alergia no existe';
    END IF;

    SET v_severidad = UPPER(TRIM(v_severidad));

    IF v_severidad NOT IN ('LEVE', 'MODERADA', 'GRAVE') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Severidad inválida (LEVE, MODERADA, GRAVE)';
    END IF;

    INSERT INTO alergias_mascota (
        id_mascota,
        id_alergia,
        severidad,
        observaciones
    )
    VALUES (
        v_id_mascota,
        v_id_alergia,
        v_severidad,
        v_observaciones
    );

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Alergia registrada correctamente',
        'alergia', JSON_OBJECT(
            'id_mascota', v_id_mascota,
            'id_alergia', v_id_alergia,
            'severidad', v_severidad
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_alergias$$
CREATE PROCEDURE sp_get_alergias()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener alergias'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'alergias',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_alergia', t.id_alergia,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT
                        id_alergia,
                        nombre
                    FROM alergias
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_alergia_catalogo_json$$
CREATE PROCEDURE sp_insert_alergia_catalogo_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(150);
    DECLARE v_nombre_normalizado VARCHAR(150);
    DECLARE v_id_alergia INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear alergia'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre')));

    IF v_nombre IS NULL OR v_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre de la alergia es obligatorio';
    END IF;

    SET v_nombre_normalizado = UPPER(v_nombre);

    SELECT id_alergia
    INTO v_id_alergia
    FROM alergias
    WHERE UPPER(TRIM(nombre)) = v_nombre_normalizado
    LIMIT 1;

    IF v_id_alergia IS NOT NULL THEN
        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'La alergia ya existía',
            'alergia',
            (
                SELECT JSON_OBJECT(
                    'id_alergia', a.id_alergia,
                    'nombre', a.nombre
                )
                FROM alergias a
                WHERE a.id_alergia = v_id_alergia
            )
        ) AS resultado;

    ELSE

        INSERT INTO alergias(nombre)
        VALUES(v_nombre_normalizado);

        SET v_id_alergia = LAST_INSERT_ID();

        COMMIT;

        SELECT JSON_OBJECT(
            'success', 1,
            'mensaje', 'Alergia creada correctamente',
            'alergia',
            (
                SELECT JSON_OBJECT(
                    'id_alergia', a.id_alergia,
                    'nombre', a.nombre
                )
                FROM alergias a
                WHERE a.id_alergia = v_id_alergia
            )
        ) AS resultado;

    END IF;
END$$

DELIMITER ;
/*============================================================================0
  procedimientos de administrar servicios
================================================================================*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_servicios_json$$
CREATE PROCEDURE sp_get_servicios_json()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener servicios'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'servicios',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_servicio', s.id_servicio,
                        'nombre', s.nombre,
                        'descripcion', s.descripcion,
                        'precios',
                        COALESCE(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'tamanio', sp.tamanio,
                                        'precio', sp.precio,
                                        'duracion', sp.duracion_minutos
                                    )
                                )
                                FROM servicios_precios sp
                                WHERE sp.id_servicio = s.id_servicio
                            ),
                            JSON_ARRAY()
                        )
                    )
                )
                FROM servicios s
                WHERE s.activo = TRUE
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_insert_servicio_json$$
CREATE PROCEDURE sp_insert_servicio_json(IN p_json JSON)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion VARCHAR(500);
    DECLARE v_id_servicio INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;

    DECLARE v_tamanio VARCHAR(20);
    DECLARE v_precio DECIMAL(12,2);
    DECLARE v_duracion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear servicio'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descripcion'));

    IF v_nombre IS NULL OR TRIM(v_nombre) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nombre obligatorio';
    END IF;

    INSERT INTO servicios (
        nombre,
        descripcion,
        duracion_minutos,
        precio_base,
        activo
    )
    VALUES (
        v_nombre,
        v_descripcion,
        0,
        0,
        TRUE
    );

    SET v_id_servicio = LAST_INSERT_ID();

    SET v_total = JSON_LENGTH(JSON_EXTRACT(p_json, '$.precios'));

    WHILE v_i < COALESCE(v_total,0) DO

        SET v_tamanio = UPPER(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].tamanio'))));
        SET v_precio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].precio'))) AS DECIMAL(12,2));
        SET v_duracion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].duracion'))) AS SIGNED);

        INSERT INTO servicios_precios (
            id_servicio,
            tamanio,
            precio,
            duracion_minutos
        )
        VALUES (
            v_id_servicio,
            v_tamanio,
            v_precio,
            v_duracion
        );

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Servicio creado correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_update_servicio_json$$
CREATE PROCEDURE sp_update_servicio_json(IN p_json JSON)
BEGIN
    DECLARE v_id_servicio INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion VARCHAR(500);

    DECLARE v_i INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;

    DECLARE v_tamanio VARCHAR(20);
    DECLARE v_precio DECIMAL(12,2);
    DECLARE v_duracion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al actualizar servicio'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_servicio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_servicio')) AS UNSIGNED);
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descripcion'));

    IF v_id_servicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_servicio obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM servicios WHERE id_servicio = v_id_servicio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El servicio no existe';
    END IF;

    UPDATE servicios
    SET
        nombre = COALESCE(v_nombre, nombre),
        descripcion = COALESCE(v_descripcion, descripcion)
    WHERE id_servicio = v_id_servicio;

    DELETE FROM servicios_precios
    WHERE id_servicio = v_id_servicio;

    SET v_total = JSON_LENGTH(JSON_EXTRACT(p_json, '$.precios'));

    WHILE v_i < COALESCE(v_total,0) DO

        SET v_tamanio = UPPER(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].tamanio'))));
        SET v_precio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].precio'))) AS DECIMAL(12,2));
        SET v_duracion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.precios[',v_i,'].duracion'))) AS SIGNED);

        INSERT INTO servicios_precios (
            id_servicio,
            tamanio,
            precio,
            duracion_minutos
        )
        VALUES (
            v_id_servicio,
            v_tamanio,
            v_precio,
            v_duracion
        );

        SET v_i = v_i + 1;
    END WHILE;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Servicio actualizado correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_delete_servicio_json$$
CREATE PROCEDURE sp_delete_servicio_json(IN p_json JSON)
BEGIN
    DECLARE v_id_servicio INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al eliminar servicio'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_servicio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_servicio')) AS UNSIGNED);

    IF v_id_servicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_servicio obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM servicios
        WHERE id_servicio = v_id_servicio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El servicio no existe';
    END IF;

    UPDATE servicios
    SET activo = FALSE
    WHERE id_servicio = v_id_servicio;

    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Servicio eliminado correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_servicio_por_mascota$$
CREATE PROCEDURE sp_get_servicio_por_mascota(IN p_json JSON)
BEGIN
    DECLARE v_id_servicio INT;
    DECLARE v_id_mascota INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener servicio'
        ) AS resultado;
    END;

    SET v_id_servicio = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_servicio')) AS UNSIGNED);
    SET v_id_mascota = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_mascota')) AS UNSIGNED);

    IF v_id_servicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_servicio obligatorio';
    END IF;

    IF v_id_mascota IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_mascota obligatorio';
    END IF;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'servicio',
        (
            SELECT JSON_OBJECT(
                'id_servicio', s.id_servicio,
                'nombre', s.nombre,
                'precio', COALESCE(sp.precio, s.precio_base),
                'duracion', COALESCE(sp.duracion_minutos, s.duracion_minutos)
            )
            FROM servicios s
            LEFT JOIN mascotas m
                ON m.id_mascota = v_id_mascota
            LEFT JOIN servicios_precios sp
                ON sp.id_servicio = s.id_servicio
               AND sp.tamanio = m.tamanio
            WHERE s.id_servicio = v_id_servicio
              AND s.activo = TRUE
            LIMIT 1
        )
    ) AS resultado;
END$$

DELIMITER ;
/*--------------------------------------------------------------------*/
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_home_completo_json$$
CREATE PROCEDURE sp_get_home_completo_json()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success',0,
            'mensaje','Error al obtener home'
        ) AS json;
    END;

    SELECT JSON_OBJECT(
        'success',1,
        'mensaje','OK',
        'data', JSON_OBJECT(
            'servicios',
            COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'id_informacion',x.id_informacion,
                            'titulo',x.titulo,
                            'descripcion',x.descripcion,
                            'id_categoria',x.id_categoria,
                            'categoria',x.categoria,
                            'imagen_url',x.imagen_url
                        )
                    )
                    FROM (
                        SELECT
                            ih.id_informacion,
                            ih.titulo,
                            ih.descripcion,
                            ih.id_categoria,
                            c.nombre AS categoria,
                            ih.imagen_url
                        FROM informacion_home ih
                        INNER JOIN categorias c
                            ON c.id_categoria = ih.id_categoria
                        WHERE ih.fecha_publicacion IS NULL
                          AND ih.activo = TRUE
                        ORDER BY ih.id_informacion
                    ) x
                ),
                JSON_ARRAY()
            ),
            'noticias',
            COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'id_informacion',y.id_informacion,
                            'titulo',y.titulo,
                            'descripcion',y.descripcion,
                            'id_categoria',y.id_categoria,
                            'categoria',y.categoria,
                            'fecha_publicacion',y.fecha_publicacion,
                            'imagen_url',y.imagen_url
                        )
                    )
                    FROM (
                        SELECT
                            ih.id_informacion,
                            ih.titulo,
                            ih.descripcion,
                            ih.id_categoria,
                            c.nombre AS categoria,
                            ih.fecha_publicacion,
                            ih.imagen_url
                        FROM informacion_home ih
                        INNER JOIN categorias c
                            ON c.id_categoria = ih.id_categoria
                        WHERE ih.fecha_publicacion IS NOT NULL
                          AND ih.activo = TRUE
                        ORDER BY ih.fecha_publicacion DESC
                        LIMIT 4
                    ) y
                ),
                JSON_ARRAY()
            )
        )
    ) AS json;
END$$


DROP PROCEDURE IF EXISTS sp_insert_informacion_home_json$$
CREATE PROCEDURE sp_insert_informacion_home_json(IN p_json JSON)
BEGIN
    DECLARE v_titulo VARCHAR(50);
    DECLARE v_descripcion VARCHAR(250);
    DECLARE v_id_categoria INT;
    DECLARE v_fecha_publicacion DATETIME;
    DECLARE v_imagen_url VARCHAR(500);
    DECLARE v_id_informacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al crear información'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_titulo       = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.titulo')));
    SET v_descripcion  = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descripcion')));
    SET v_id_categoria = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id_categoria')) AS UNSIGNED);
    SET v_imagen_url   = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.imagen_url'));

    -- ← Fix: manejo seguro de fecha opcional
    SET v_fecha_publicacion = IF(
        JSON_EXTRACT(p_json, '$.fecha_publicacion') IS NULL
        OR JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_publicacion')) = 'null'
        OR TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_publicacion'))) = '',
        NULL,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fecha_publicacion')) AS DATETIME)
    );

    IF v_titulo IS NULL OR v_titulo = ''
       OR v_descripcion IS NULL OR v_descripcion = ''
       OR v_id_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo, descripcion y categoria son obligatorios';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM categorias WHERE id_categoria = v_id_categoria
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe';
    END IF;

    INSERT INTO informacion_home(
        titulo, descripcion, id_categoria,
        fecha_publicacion, imagen_url, activo
    )
    VALUES(
        v_titulo, v_descripcion, v_id_categoria,
        v_fecha_publicacion, v_imagen_url, TRUE
    );

    SET v_id_informacion = LAST_INSERT_ID();
    COMMIT;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Información creada correctamente',
        'informacion', (
            SELECT JSON_OBJECT(
                'id_informacion', ih.id_informacion,
                'titulo',         ih.titulo,
                'descripcion',    ih.descripcion,
                'id_categoria',   ih.id_categoria,
                'categoria',      c.nombre,
                'fecha_publicacion', ih.fecha_publicacion,
                'imagen_url',     ih.imagen_url
            )
            FROM informacion_home ih
            INNER JOIN categorias c ON c.id_categoria = ih.id_categoria
            WHERE ih.id_informacion = v_id_informacion
        )
    ) AS resultado;
END$$




DROP PROCEDURE IF EXISTS sp_update_informacion_home_json$$
CREATE PROCEDURE sp_update_informacion_home_json(IN p_json JSON)
BEGIN
    DECLARE v_id_informacion INT;
    DECLARE v_titulo VARCHAR(50);
    DECLARE v_descripcion VARCHAR(250);
    DECLARE v_id_categoria INT;
    DECLARE v_fecha_publicacion DATETIME;
    DECLARE v_imagen_url VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success',0,
            'mensaje','Error al actualizar información'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_informacion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.id_informacion')) AS UNSIGNED);
    SET v_titulo = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.titulo')));
    SET v_descripcion = TRIM(JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.descripcion')));
    SET v_id_categoria = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.id_categoria')) AS UNSIGNED);
    SET @fecha_str = JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.fecha_publicacion'));

SET v_fecha_publicacion = 
    CASE 
        WHEN @fecha_str IS NULL OR @fecha_str = '' THEN NULL
        ELSE CAST(@fecha_str AS DATETIME)
    END;
    SET v_imagen_url = JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.imagen_url'));

    IF v_id_informacion IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_informacion es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM informacion_home WHERE id_informacion = v_id_informacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La información no existe';
    END IF;

    IF v_id_categoria IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM categorias WHERE id_categoria = v_id_categoria
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe';
    END IF;

    UPDATE informacion_home
    SET
        titulo = COALESCE(v_titulo,titulo),
        descripcion = COALESCE(v_descripcion,descripcion),
        id_categoria = COALESCE(v_id_categoria,id_categoria),
        fecha_publicacion = v_fecha_publicacion,
        imagen_url = COALESCE(v_imagen_url,imagen_url)
    WHERE id_informacion = v_id_informacion;

    COMMIT;

    SELECT JSON_OBJECT(
        'success',1,
        'mensaje','Información actualizada correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_delete_informacion_home_json$$
CREATE PROCEDURE sp_delete_informacion_home_json(IN p_json JSON)
BEGIN
    DECLARE v_id_informacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'success',0,
            'mensaje','Error al eliminar información'
        ) AS resultado;
    END;

    START TRANSACTION;

    SET v_id_informacion = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json,'$.id_informacion')) AS UNSIGNED);

    IF v_id_informacion IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'id_informacion es obligatorio';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM informacion_home WHERE id_informacion = v_id_informacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La información no existe';
    END IF;

    UPDATE informacion_home
    SET activo = FALSE
    WHERE id_informacion = v_id_informacion;

    COMMIT;

    SELECT JSON_OBJECT(
        'success',1,
        'mensaje','Información eliminada correctamente'
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_noticias_json$$
CREATE PROCEDURE sp_get_noticias_json()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success',0,
            'mensaje','Error al obtener noticias'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success',1,
        'mensaje','OK',
        'data',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_informacion',x.id_informacion,
                        'titulo',x.titulo,
                        'descripcion',x.descripcion,
                        'id_categoria',x.id_categoria,
                        'categoria',x.categoria,
                        'fecha_publicacion',x.fecha_publicacion,
                        'imagen_url',x.imagen_url
                    )
                )
                FROM (
                    SELECT
                        ih.id_informacion,
                        ih.titulo,
                        ih.descripcion,
                        ih.id_categoria,
                        c.nombre AS categoria,
                        ih.fecha_publicacion,
                        ih.imagen_url
                    FROM informacion_home ih
                    INNER JOIN categorias c
                        ON c.id_categoria = ih.id_categoria
                    WHERE ih.fecha_publicacion IS NOT NULL
                      AND ih.activo = TRUE
                    ORDER BY ih.fecha_publicacion DESC
                ) x
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_especies$$
CREATE PROCEDURE sp_get_especies()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener especies'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'OK',
        'especies',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_especie', t.id_especie,
                        'nombre', t.nombre
                    )
                )
                FROM (
                    SELECT id_especie, nombre
                    FROM tipo_especie
                    WHERE activo = TRUE
                    ORDER BY nombre
                ) t
            ),
            JSON_ARRAY()
        )
    ) AS resultado;
END$$


DROP PROCEDURE IF EXISTS sp_get_dashboard_admin_json$$
CREATE PROCEDURE sp_get_dashboard_admin_json(IN p_json JSON)
BEGIN
    DECLARE v_hoy DATE DEFAULT CURDATE();
    DECLARE v_maniana3 DATE DEFAULT DATE_ADD(CURDATE(), INTERVAL 3 DAY);
    DECLARE v_inicio_mes DATE DEFAULT DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE()) - 1 DAY);
    DECLARE v_inicio_mes_siguiente DATE DEFAULT DATE_ADD(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE()) - 1 DAY), INTERVAL 1 MONTH);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'success', 0,
            'mensaje', 'Error al obtener dashboard'
        ) AS resultado;
    END;

    SELECT JSON_OBJECT(
        'success', 1,
        'mensaje', 'Dashboard obtenido correctamente',

        'resumen', JSON_OBJECT(
            'total_clientes',
            (
                SELECT COUNT(*)
                FROM usuarios u
                WHERE u.rol = 'CLIENTE'
                  AND u.activo = TRUE
            ),

            'total_mascotas',
            (
                SELECT COUNT(*)
                FROM mascotas m
                WHERE m.activo = TRUE
            ),

            'clientes_nuevos_mes',
            (
                SELECT COUNT(*)
                FROM usuarios u
                WHERE u.rol = 'CLIENTE'
                  AND u.activo = TRUE
                  AND u.fecha_alta >= v_inicio_mes
                  AND u.fecha_alta < v_inicio_mes_siguiente
            ),

            'mascotas_nuevas_mes',
            (
                SELECT COUNT(*)
                FROM mascotas m
                WHERE m.activo = TRUE
                  AND m.fecha_registro >= v_inicio_mes
                  AND m.fecha_registro < v_inicio_mes_siguiente
            ),

            'consultas_mes',
            (
                SELECT COUNT(*)
                FROM consultas_clinicas c
                WHERE c.fecha >= v_inicio_mes
                  AND c.fecha < v_inicio_mes_siguiente
            )
        ),

        'mascotas_por_especie',
        COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_especie', x.id_especie,
                        'especie', x.especie,
                        'cantidad', x.cantidad
                    )
                )
                FROM (
                    SELECT
                        te.id_especie,
                        te.nombre AS especie,
                        COUNT(*) AS cantidad
                    FROM mascotas m
                    INNER JOIN tipo_especie te
                        ON te.id_especie = m.id_especie
                    WHERE m.activo = TRUE
                    GROUP BY te.id_especie, te.nombre
                    ORDER BY cantidad DESC, te.nombre
                ) x
            ),
            JSON_ARRAY()
        ),

        'alertas', JSON_OBJECT(
            'vacunas_proximas',
            COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'id_usuario', x.id_usuario,
                            'cliente', x.cliente,
                            'id_mascota', x.id_mascota,
                            'mascota', x.mascota,
                            'id_vacuna', x.id_vacuna,
                            'vacuna', x.vacuna,
                            'proxima_dosis', x.proxima_dosis,
                            'dias_restantes', x.dias_restantes
                        )
                    )
                    FROM (
                        SELECT
                            u.id_usuario,
                            CONCAT(u.nombre, ' ', u.apellido) AS cliente,
                            m.id_mascota,
                            m.nombre AS mascota,
                            v.id_vacuna,
                            v.nombre AS vacuna,
                            vm.proxima_dosis,
                            DATEDIFF(vm.proxima_dosis, v_hoy) AS dias_restantes
                        FROM vacunas_mascota vm
                        INNER JOIN mascotas m
                            ON m.id_mascota = vm.id_mascota
                        INNER JOIN usuarios u
                            ON u.id_usuario = m.id_usuario
                        INNER JOIN vacunas v
                            ON v.id_vacuna = vm.id_vacuna
                        WHERE m.activo = TRUE
                          AND u.activo = TRUE
                          AND vm.proxima_dosis IS NOT NULL
                          AND vm.proxima_dosis >= v_hoy
                          AND vm.proxima_dosis <= v_maniana3
                        ORDER BY vm.proxima_dosis, cliente, mascota
                    ) x
                ),
                JSON_ARRAY()
            ),

            'desparasitaciones_proximas',
            COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'id_usuario', x.id_usuario,
                            'cliente', x.cliente,
                            'id_mascota', x.id_mascota,
                            'mascota', x.mascota,
                            'id_desparasitacion', x.id_desparasitacion,
                            'desparasitacion', x.desparasitacion,
                            'tipo', x.tipo,
                            'proxima_dosis', x.proxima_dosis,
                            'dias_restantes', x.dias_restantes
                        )
                    )
                    FROM (
                        SELECT
                            u.id_usuario,
                            CONCAT(u.nombre, ' ', u.apellido) AS cliente,
                            m.id_mascota,
                            m.nombre AS mascota,
                            d.id_desparasitacion,
                            d.nombre AS desparasitacion,
                            COALESCE(dm.tipo, d.tipo) AS tipo,
                            dm.proxima_dosis,
                            DATEDIFF(dm.proxima_dosis, v_hoy) AS dias_restantes
                        FROM desparasitaciones_mascota dm
                        INNER JOIN mascotas m
                            ON m.id_mascota = dm.id_mascota
                        INNER JOIN usuarios u
                            ON u.id_usuario = m.id_usuario
                        INNER JOIN desparasitaciones d
                            ON d.id_desparasitacion = dm.id_desparasitacion
                        WHERE m.activo = TRUE
                          AND u.activo = TRUE
                          AND dm.proxima_dosis IS NOT NULL
                          AND dm.proxima_dosis >= v_hoy
                          AND dm.proxima_dosis <= v_maniana3
                        ORDER BY dm.proxima_dosis, cliente, mascota
                    ) x
                ),
                JSON_ARRAY()
            )
        ),

        'extras', JSON_OBJECT(
            'clientes_con_multiples_mascotas',
            (
                SELECT COUNT(*)
                FROM (
                    SELECT m.id_usuario
                    FROM mascotas m
                    WHERE m.activo = TRUE
                    GROUP BY m.id_usuario
                    HAVING COUNT(*) > 1
                ) x
            ),

            'especie_mas_registrada',
            COALESCE(
                (
                    SELECT JSON_OBJECT(
                        'id_especie', x.id_especie,
                        'especie', x.especie,
                        'cantidad', x.cantidad
                    )
                    FROM (
                        SELECT
                            te.id_especie,
                            te.nombre AS especie,
                            COUNT(*) AS cantidad
                        FROM mascotas m
                        INNER JOIN tipo_especie te
                            ON te.id_especie = m.id_especie
                        WHERE m.activo = TRUE
                        GROUP BY te.id_especie, te.nombre
                        ORDER BY COUNT(*) DESC, te.nombre
                        LIMIT 1
                    ) x
                ),
                JSON_OBJECT()
            ),

            'ultima_consulta_fecha',
            (
                SELECT MAX(c.fecha)
                FROM consultas_clinicas c
            ),

            'proximo_vencimiento',
            COALESCE(
                (
                    SELECT JSON_OBJECT(
                        'tipo', x.tipo,
                        'cliente', x.cliente,
                        'mascota', x.mascota,
                        'nombre_item', x.nombre_item,
                        'proxima_dosis', x.proxima_dosis,
                        'dias_restantes', x.dias_restantes
                    )
                    FROM (
                        SELECT
                            'VACUNA' AS tipo,
                            CONCAT(u.nombre, ' ', u.apellido) AS cliente,
                            m.nombre AS mascota,
                            v.nombre AS nombre_item,
                            vm.proxima_dosis,
                            DATEDIFF(vm.proxima_dosis, v_hoy) AS dias_restantes
                        FROM vacunas_mascota vm
                        INNER JOIN mascotas m
                            ON m.id_mascota = vm.id_mascota
                        INNER JOIN usuarios u
                            ON u.id_usuario = m.id_usuario
                        INNER JOIN vacunas v
                            ON v.id_vacuna = vm.id_vacuna
                        WHERE m.activo = TRUE
                          AND u.activo = TRUE
                          AND vm.proxima_dosis IS NOT NULL
                          AND vm.proxima_dosis >= v_hoy

                        UNION ALL

                        SELECT
                            'DESPARASITACION' AS tipo,
                            CONCAT(u.nombre, ' ', u.apellido) AS cliente,
                            m.nombre AS mascota,
                            d.nombre AS nombre_item,
                            dm.proxima_dosis,
                            DATEDIFF(dm.proxima_dosis, v_hoy) AS dias_restantes
                        FROM desparasitaciones_mascota dm
                        INNER JOIN mascotas m
                            ON m.id_mascota = dm.id_mascota
                        INNER JOIN usuarios u
                            ON u.id_usuario = m.id_usuario
                        INNER JOIN desparasitaciones d
                            ON d.id_desparasitacion = dm.id_desparasitacion
                        WHERE m.activo = TRUE
                          AND u.activo = TRUE
                          AND dm.proxima_dosis IS NOT NULL
                          AND dm.proxima_dosis >= v_hoy

                        ORDER BY proxima_dosis, cliente, mascota
                        LIMIT 1
                    ) x
                ),
                JSON_OBJECT()
            )
        )
    ) AS resultado;
END$$

DELIMITER ;