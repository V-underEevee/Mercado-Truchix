DROP DATABASE IF EXISTS mercado_truchix;
CREATE DATABASE mercado_truchix;
USE mercado_truchix;

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  dni VARCHAR(15) UNIQUE NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  fecha_alta DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('activo','suspendido','baja') DEFAULT 'activo'
);

CREATE TABLE cuenta (
  id_cuenta INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  cvu VARCHAR(22) UNIQUE NOT NULL,
  alias VARCHAR(50) UNIQUE,
  saldo DECIMAL(15,2) DEFAULT 0.00,
  moneda ENUM('ARS','USD') DEFAULT 'ARS',
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('activa','bloqueada','cerrada') DEFAULT 'activa',
  CONSTRAINT fk_cuenta_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_saldo CHECK (saldo >= 0)
);

CREATE TABLE tarjeta (
  id_tarjeta INT AUTO_INCREMENT PRIMARY KEY,
  id_cuenta INT NOT NULL,
  numero_enmascarado VARCHAR(20) NOT NULL,
  tipo ENUM('debito','credito') NOT NULL,
  marca VARCHAR(30),
  fecha_vencimiento DATE,
  estado ENUM('activa','vencida','bloqueada') DEFAULT 'activa',
  CONSTRAINT fk_tarjeta_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta(id_cuenta) ON DELETE CASCADE
);

CREATE TABLE comercio (
  id_comercio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  cuit VARCHAR(15) UNIQUE,
  rubro VARCHAR(80),
  id_cuenta INT,
  CONSTRAINT fk_comercio_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta(id_cuenta) ON DELETE SET NULL
);

CREATE TABLE transaccion (
  id_transaccion BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_cuenta_origen INT,
  id_cuenta_destino INT,
  tipo ENUM('transferencia','pago','carga','extraccion','reembolso') NOT NULL,
  monto DECIMAL(15,2) NOT NULL,
  moneda ENUM('ARS','USD') DEFAULT 'ARS',
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente','completada','rechazada','revertida') DEFAULT 'pendiente',
  descripcion VARCHAR(255),
  CONSTRAINT fk_tx_origen FOREIGN KEY (id_cuenta_origen)
    REFERENCES cuenta(id_cuenta) ON DELETE RESTRICT,
  CONSTRAINT fk_tx_destino FOREIGN KEY (id_cuenta_destino)
    REFERENCES cuenta(id_cuenta) ON DELETE RESTRICT,
  CONSTRAINT chk_monto CHECK (monto > 0)
);

CREATE TABLE pago_servicio (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_comercio INT,
  servicio VARCHAR(80) NOT NULL,
  monto DECIMAL(15,2) NOT NULL,
  fecha_vencimiento DATE,
  estado ENUM('pendiente','pagado','vencido') DEFAULT 'pendiente',
  CONSTRAINT fk_pago_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_pago_comercio FOREIGN KEY (id_comercio)
    REFERENCES comercio(id_comercio) ON DELETE SET NULL
);

CREATE TABLE auditoria_saldo (
  id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_cuenta INT NOT NULL,
  saldo_anterior DECIMAL(15,2),
  saldo_nuevo DECIMAL(15,2),
  operacion VARCHAR(50),
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  usuario_db VARCHAR(100),
  CONSTRAINT fk_auditoria_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta(id_cuenta) ON DELETE CASCADE
);

CREATE TABLE historial_estado_transaccion (
  id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_transaccion BIGINT,
  estado_anterior VARCHAR(20),
  estado_nuevo VARCHAR(20),
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE servicio_propio (
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('streaming','marketplace','inversion','pago','otros') NOT NULL,
  descripcion VARCHAR(255),
  precio_mensual DECIMAL(15,2) DEFAULT 0.00,
  comision_porcentaje DECIMAL(5,2) DEFAULT 0.00,
  fecha_lanzamiento DATE,
  estado ENUM('activo','inactivo') DEFAULT 'activo'
);

CREATE TABLE plan_servicio (
  id_plan INT AUTO_INCREMENT PRIMARY KEY,
  id_servicio INT NOT NULL,
  nombre_plan VARCHAR(80) NOT NULL,
  precio DECIMAL(15,2) NOT NULL,
  duracion_dias INT DEFAULT 30,
  limite_uso INT DEFAULT 0,
  descripcion VARCHAR(255),
  estado ENUM('activo','inactivo') DEFAULT 'activo',
  CONSTRAINT fk_plan_servicio FOREIGN KEY (id_servicio)
    REFERENCES servicio_propio(id_servicio) ON DELETE CASCADE
);

CREATE TABLE suscripcion_servicio (
  id_suscripcion INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_plan INT NOT NULL,
  fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
  fecha_fin DATETIME,
  estado ENUM('activa','pausada','cancelada','vencida') DEFAULT 'activa',
  renovacion_automatica BOOLEAN DEFAULT TRUE,
  CONSTRAINT fk_suscripcion_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_suscripcion_plan FOREIGN KEY (id_plan)
    REFERENCES plan_servicio(id_plan) ON DELETE RESTRICT
);

CREATE TABLE consumo_servicio (
  id_consumo BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_suscripcion INT NOT NULL,
  descripcion VARCHAR(255),
  monto DECIMAL(15,2) DEFAULT 0.00,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_consumo_suscripcion FOREIGN KEY (id_suscripcion)
    REFERENCES suscripcion_servicio(id_suscripcion) ON DELETE CASCADE
);

CREATE TABLE tipo_inversion (
  id_tipo_inversion INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  riesgo ENUM('bajo','medio','alto') NOT NULL,
  tasa_anual DECIMAL(5,2) NOT NULL,
  descripcion VARCHAR(255),
  estado ENUM('activo','inactivo') DEFAULT 'activo'
);

CREATE TABLE inversion (
  id_inversion BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_tipo_inversion INT NOT NULL,
  monto_invertido DECIMAL(15,2) NOT NULL,
  fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
  fecha_vencimiento DATETIME,
  rendimiento_acumulado DECIMAL(15,2) DEFAULT 0.00,
  estado ENUM('activa','finalizada','cancelada') DEFAULT 'activa',
  CONSTRAINT fk_inversion_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_inversion_tipo FOREIGN KEY (id_tipo_inversion)
    REFERENCES tipo_inversion(id_tipo_inversion) ON DELETE RESTRICT,
  CONSTRAINT chk_monto_invertido CHECK (monto_invertido > 0)
);

CREATE TABLE movimiento_inversion (
  id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_inversion BIGINT NOT NULL,
  tipo ENUM('aporte','retiro','rendimiento') NOT NULL,
  monto DECIMAL(15,2) NOT NULL,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_movimiento_inversion FOREIGN KEY (id_inversion)
    REFERENCES inversion(id_inversion) ON DELETE CASCADE
);

INSERT INTO usuario (nombre, apellido, dni, email, telefono) VALUES
('Juan','Pérez','30111222','juan.perez@mail.com','1145550001'),
('María','Gómez','28999888','maria.gomez@mail.com','1145550002'),
('Lucas','Fernández','33444555','lucas.f@mail.com','1145550003'),
('Sofía','Rodríguez','31222333','sofia.r@mail.com','1145550004'),
('Diego','Martínez','27666777','diego.m@mail.com','1145550005'),
('Carla','López','34555666','carla.l@mail.com','1145550006'),
('Pablo','Sánchez','29888777','pablo.s@mail.com','1145550007'),
('Ana','Torres','32333444','ana.t@mail.com','1145550008'),
('Martín','Ruiz','35555666','martin.r@mail.com','1145550009'),
('Laura','Díaz','26777888','laura.d@mail.com','1145550010');

INSERT INTO cuenta (id_usuario, cvu, alias, saldo, moneda) VALUES
(1,'0000003100010000000001','juan.perez.mp',15000.00,'ARS'),
(2,'0000003100010000000002','maria.gomez.mp',25000.50,'ARS'),
(3,'0000003100010000000003','lucas.f.mp',8000.00,'ARS'),
(4,'0000003100010000000004','sofia.r.mp',50000.00,'ARS'),
(5,'0000003100010000000005','diego.m.mp',1200.00,'ARS'),
(6,'0000003100010000000006','carla.l.mp',33000.00,'ARS'),
(7,'0000003100010000000007','pablo.s.mp',0.00,'ARS'),
(8,'0000003100010000000008','ana.t.mp',17500.00,'ARS'),
(9,'0000003100010000000009','martin.r.mp',9200.00,'ARS'),
(10,'0000003100010000000010','laura.d.mp',41000.00,'ARS');

INSERT INTO comercio (nombre, cuit, rubro, id_cuenta) VALUES
('Kiosco El Trucho','30-11111111-1','Kiosco',3),
('Pizzería Don Luca','30-22222222-2','Gastronomía',4),
('Farmacia Central','30-33333333-3','Salud',6),
('Supermercado Norte','30-44444444-4','Supermercado',8),
('Librería Saber','30-55555555-5','Librería',9),
('Estación YPF','30-66666666-6','Combustible',2),
('Café Martínez','30-77777777-7','Gastronomía',1),
('Gimnasio Fit','30-88888888-8','Deportes',10),
('Verdulería Verde','30-99999999-9','Alimentos',5),
('Cine Star','30-10101010-0','Entretenimiento',7);

INSERT INTO transaccion (id_cuenta_origen, id_cuenta_destino, tipo, monto, estado, descripcion) VALUES
(1,2,'transferencia',1500.00,'completada','Pago de alquiler'),
(2,3,'transferencia',800.00,'completada','Cena'),
(4,5,'transferencia',2000.00,'completada','Préstamo'),
(6,7,'transferencia',300.00,'pendiente','Compra online'),
(8,9,'transferencia',1200.00,'completada','Regalo'),
(10,1,'transferencia',500.00,'rechazada','Sin fondos'),
(3,4,'pago',2500.00,'completada','Pago comercio'),
(5,6,'carga',1000.00,'completada','Carga de saldo'),
(7,8,'extraccion',700.00,'completada','Extracción cajero'),
(9,10,'reembolso',400.00,'completada','Devolución');

INSERT INTO tarjeta (id_cuenta, numero_enmascarado, tipo, marca, fecha_vencimiento) VALUES
(1,'**** **** **** 1234','debito','Visa','2027-05-31'),
(2,'**** **** **** 5678','credito','Mastercard','2026-11-30'),
(3,'**** **** **** 9012','debito','Visa','2025-08-31'),
(4,'**** **** **** 3456','credito','Amex','2028-01-31'),
(5,'**** **** **** 7890','debito','Mastercard','2027-03-31'),
(6,'**** **** **** 2345','credito','Visa','2026-06-30'),
(7,'**** **** **** 6789','debito','Visa','2025-12-31'),
(8,'**** **** **** 0123','credito','Mastercard','2029-02-28'),
(9,'**** **** **** 4567','debito','Visa','2027-09-30'),
(10,'**** **** **** 8901','credito','Amex','2026-04-30');

INSERT INTO pago_servicio (id_usuario, id_comercio, servicio, monto, fecha_vencimiento, estado) VALUES
(1,6,'Nafta',3000.00,'2025-07-15','pagado'),
(2,3,'Farmacia',1500.00,'2025-07-20','pendiente'),
(3,1,'Kiosco',500.00,'2025-07-10','pagado'),
(4,2,'Pizza',2200.00,'2025-07-18','pagado'),
(5,9,'Verduras',800.00,'2025-07-12','vencido'),
(6,4,'Supermercado',5500.00,'2025-07-22','pendiente'),
(7,10,'Cine',1800.00,'2025-07-25','pagado'),
(8,8,'Gimnasio',4000.00,'2025-07-30','pendiente'),
(9,5,'Librería',1200.00,'2025-07-14','pagado'),
(10,7,'Café',600.00,'2025-07-16','pagado');

INSERT INTO servicio_propio (nombre, tipo, descripcion, precio_mensual, comision_porcentaje, fecha_lanzamiento) VALUES
('Truchix Play','streaming','Plataforma de streaming de video',2500.00,0.00,'2024-01-15'),
('Truchix Market','marketplace','Marketplace de compras online',0.00,8.50,'2023-06-01'),
('Truchix Rendimientos','inversion','Fondo comun de inversion',0.00,1.25,'2024-03-10'),
('Truchix Pagos','pago','Servicio de pagos y cobros',0.00,2.00,'2022-11-20'),
('Truchix Musica','streaming','Plataforma de musica',1800.00,0.00,'2024-05-05'),
('Truchix Envios','otros','Servicio de envios y logistica',0.00,5.00,'2023-09-12'),
('Truchix Seguros','otros','Seguros para celulares y autos',3500.00,3.00,'2024-07-01'),
('Truchix Cloud','otros','Almacenamiento en la nube',1200.00,0.00,'2024-02-18'),
('Truchix Cripto','inversion','Compra y venta de criptomonedas',0.00,2.50,'2024-08-22'),
('Truchix Viajes','marketplace','Reserva de vuelos y hoteles',0.00,10.00,'2023-12-01');

INSERT INTO plan_servicio (id_servicio, nombre_plan, precio, duracion_dias, limite_uso, descripcion) VALUES
(1,'Play Basico',2500.00,30,1,'1 pantalla en HD'),
(1,'Play Estandar',3800.00,30,2,'2 pantallas en HD'),
(1,'Play Premium',5200.00,30,4,'4 pantallas en 4K'),
(2,'Market Free',0.00,30,0,'Compras sin costo fijo'),
(2,'Market Plus',1500.00,30,0,'Envios gratis y descuentos'),
(3,'Rendimientos Conservador',0.00,30,0,'Inversion de bajo riesgo'),
(3,'Rendimientos Equilibrado',0.00,30,0,'Inversion de riesgo medio'),
(5,'Musica Individual',1800.00,30,1,'1 cuenta individual'),
(5,'Musica Familiar',3000.00,30,6,'Hasta 6 cuentas'),
(7,'Seguro Celular',3500.00,30,0,'Cobertura total de celular');

INSERT INTO suscripcion_servicio (id_usuario, id_plan, fecha_fin, estado, renovacion_automatica) VALUES
(1,1,'2025-08-15','activa',TRUE),
(2,3,'2025-08-20','activa',TRUE),
(3,4,'2025-08-10','activa',FALSE),
(4,5,'2025-09-01','activa',TRUE),
(5,7,'2025-08-25','pausada',FALSE),
(6,8,'2025-08-30','activa',TRUE),
(7,9,'2025-09-05','activa',TRUE),
(8,10,'2025-09-10','activa',TRUE),
(9,6,'2025-08-28','cancelada',FALSE),
(10,2,'2025-08-18','activa',TRUE);

INSERT INTO consumo_servicio (id_suscripcion, descripcion, monto) VALUES
(1,'Pelicula alquilada',500.00),
(1,'Suscripcion mensual',2500.00),
(2,'Suscripcion mensual',5200.00),
(3,'Compra en Market',3500.00),
(4,'Suscripcion mensual',1500.00),
(5,'Recarga de saldo',2000.00),
(6,'Suscripcion mensual',1800.00),
(7,'Suscripcion mensual',3000.00),
(8,'Suscripcion mensual',3500.00),
(9,'Aporte a inversion',10000.00);

INSERT INTO tipo_inversion (nombre, riesgo, tasa_anual, descripcion) VALUES
('Fondo Conservador','bajo',35.00,'Inversion de bajo riesgo'),
('Fondo Equilibrado','medio',55.00,'Inversion de riesgo medio'),
('Fondo Agresivo','alto',85.00,'Inversion de alto riesgo'),
('Plazo Fijo Truchix','bajo',40.00,'Plazo fijo a 30 dias'),
('Cripto Truchix','alto',120.00,'Inversion en criptomonedas'),
('Bonos Truchix','medio',60.00,'Bonos del tesoro trucho'),
('Acciones Truchix','alto',95.00,'Acciones de empresas'),
('Fondo Mixto','medio',50.00,'Combinacion de activos'),
('Fondo Liquidez','bajo',30.00,'Dinero disponible en 24hs'),
('Fondo Premium','alto',110.00,'Inversion exclusiva');

INSERT INTO inversion (id_usuario, id_tipo_inversion, monto_invertido, fecha_vencimiento, rendimiento_acumulado, estado) VALUES
(1,1,10000.00,'2025-12-31',250.00,'activa'),
(2,2,25000.00,'2025-12-31',800.00,'activa'),
(3,3,5000.00,'2025-12-31',300.00,'activa'),
(4,4,50000.00,'2025-12-31',1200.00,'activa'),
(5,5,2000.00,'2025-12-31',150.00,'activa'),
(6,6,15000.00,'2025-12-31',500.00,'activa'),
(7,7,8000.00,'2025-12-31',400.00,'activa'),
(8,8,12000.00,'2025-12-31',350.00,'finalizada'),
(9,9,3000.00,'2025-12-31',80.00,'activa'),
(10,10,30000.00,'2025-12-31',1500.00,'activa');

INSERT INTO movimiento_inversion (id_inversion, tipo, monto) VALUES
(1,'aporte',10000.00),
(1,'rendimiento',250.00),
(2,'aporte',25000.00),
(2,'rendimiento',800.00),
(3,'aporte',5000.00),
(4,'aporte',50000.00),
(5,'aporte',2000.00),
(6,'aporte',15000.00),
(7,'aporte',8000.00),
(8,'retiro',12000.00);

CREATE VIEW v_usuarios_saldos AS
SELECT u.id_usuario, CONCAT(u.nombre,' ',u.apellido) AS cliente,
       u.email, c.alias, c.cvu, c.saldo, c.moneda, c.estado
FROM usuario u
JOIN cuenta c ON c.id_usuario = u.id_usuario;

CREATE VIEW v_transacciones_por_usuario AS
SELECT u.id_usuario, CONCAT(u.nombre,' ',u.apellido) AS cliente,
       COUNT(t.id_transaccion) AS cant_transacciones,
       SUM(t.monto) AS monto_total,
       t.tipo
FROM usuario u
JOIN cuenta c ON c.id_usuario = u.id_usuario
JOIN transaccion t ON t.id_cuenta_origen = c.id_cuenta
GROUP BY u.id_usuario, cliente, t.tipo;

CREATE VIEW v_top_comercios AS
SELECT co.id_comercio, co.nombre, co.rubro,
       COUNT(p.id_pago) AS cant_pagos,
       SUM(p.monto) AS total_facturado
FROM comercio co
JOIN pago_servicio p ON p.id_comercio = co.id_comercio
WHERE p.estado = 'pagado'
GROUP BY co.id_comercio, co.nombre, co.rubro
ORDER BY total_facturado DESC;

CREATE VIEW v_transacciones_alerta AS
SELECT t.id_transaccion, t.tipo, t.monto, t.estado, t.fecha,
       co.alias AS cuenta_origen, cd.alias AS cuenta_destino
FROM transaccion t
LEFT JOIN cuenta co ON co.id_cuenta = t.id_cuenta_origen
LEFT JOIN cuenta cd ON cd.id_cuenta = t.id_cuenta_destino
WHERE t.estado IN ('pendiente','rechazada');

CREATE VIEW v_auditoria_saldos AS
SELECT a.id_auditoria, c.alias, a.saldo_anterior, a.saldo_nuevo,
       (a.saldo_nuevo - a.saldo_anterior) AS diferencia,
       a.operacion, a.fecha, a.usuario_db
FROM auditoria_saldo a
JOIN cuenta c ON c.id_cuenta = a.id_cuenta;

CREATE VIEW v_servicios_contratados AS
SELECT u.id_usuario, CONCAT(u.nombre,' ',u.apellido) AS cliente,
       sp.nombre AS servicio, ps.nombre_plan, ps.precio,
       s.estado, s.fecha_inicio, s.fecha_fin
FROM suscripcion_servicio s
JOIN usuario u ON u.id_usuario = s.id_usuario
JOIN plan_servicio ps ON ps.id_plan = s.id_plan
JOIN servicio_propio sp ON sp.id_servicio = ps.id_servicio;

CREATE VIEW v_ingresos_por_servicio AS
SELECT sp.id_servicio, sp.nombre, sp.tipo,
       COUNT(c.id_consumo) AS cant_consumos,
       SUM(c.monto) AS total_facturado,
       AVG(c.monto) AS promedio_consumo
FROM servicio_propio sp
JOIN plan_servicio ps ON ps.id_servicio = sp.id_servicio
JOIN suscripcion_servicio s ON s.id_plan = ps.id_plan
JOIN consumo_servicio c ON c.id_suscripcion = s.id_suscripcion
GROUP BY sp.id_servicio, sp.nombre, sp.tipo
HAVING total_facturado > 0;

CREATE VIEW v_inversiones_por_usuario AS
SELECT u.id_usuario, CONCAT(u.nombre,' ',u.apellido) AS cliente,
       ti.nombre AS tipo_inversion, ti.riesgo, ti.tasa_anual,
       SUM(i.monto_invertido) AS total_invertido,
       SUM(i.rendimiento_acumulado) AS total_rendimiento,
       COUNT(i.id_inversion) AS cant_inversiones
FROM usuario u
JOIN inversion i ON i.id_usuario = u.id_usuario
JOIN tipo_inversion ti ON ti.id_tipo_inversion = i.id_tipo_inversion
GROUP BY u.id_usuario, cliente, ti.nombre, ti.riesgo, ti.tasa_anual;

CREATE VIEW v_ranking_inversiones AS
SELECT ti.id_tipo_inversion, ti.nombre, ti.riesgo, ti.tasa_anual,
       COUNT(i.id_inversion) AS cant_inversiones,
       SUM(i.monto_invertido) AS capital_total,
       AVG(i.rendimiento_acumulado) AS rendimiento_promedio
FROM tipo_inversion ti
JOIN inversion i ON i.id_tipo_inversion = ti.id_tipo_inversion
GROUP BY ti.id_tipo_inversion, ti.nombre, ti.riesgo, ti.tasa_anual
HAVING capital_total > 0
ORDER BY capital_total DESC;

CREATE VIEW v_servicios_mas_consumidos AS
SELECT sp.nombre AS servicio, ps.nombre_plan,
       COUNT(c.id_consumo) AS cant_consumos,
       SUM(c.monto) AS total_gastado
FROM servicio_propio sp
JOIN plan_servicio ps ON ps.id_servicio = sp.id_servicio
JOIN suscripcion_servicio s ON s.id_plan = ps.id_plan
JOIN consumo_servicio c ON c.id_suscripcion = s.id_suscripcion
GROUP BY sp.nombre, ps.nombre_plan
HAVING cant_consumos > 0
ORDER BY total_gastado DESC;

DELIMITER //

CREATE PROCEDURE sp_alta_usuario_cuenta(
  IN p_nombre VARCHAR(100), IN p_apellido VARCHAR(100),
  IN p_dni VARCHAR(15), IN p_email VARCHAR(150),
  IN p_alias VARCHAR(50), IN p_cvu VARCHAR(22)
)
BEGIN
  DECLARE v_id_usuario INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Error: se revirtió el alta' AS mensaje;
  END;
  START TRANSACTION;
    INSERT INTO usuario (nombre, apellido, dni, email)
    VALUES (p_nombre, p_apellido, p_dni, p_email);
    SET v_id_usuario = LAST_INSERT_ID();
    INSERT INTO cuenta (id_usuario, cvu, alias, saldo)
    VALUES (v_id_usuario, p_cvu, p_alias, 0.00);
  COMMIT;
  SELECT 'Alta exitosa' AS mensaje, v_id_usuario AS id_usuario;
END //

CREATE PROCEDURE sp_transferir(
  IN p_id_origen INT, IN p_id_destino INT,
  IN p_monto DECIMAL(15,2), IN p_descripcion VARCHAR(255)
)
BEGIN
  DECLARE v_saldo DECIMAL(15,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Error en transferencia' AS mensaje;
  END;
  START TRANSACTION;
    SELECT saldo INTO v_saldo FROM cuenta WHERE id_cuenta = p_id_origen FOR UPDATE;
    IF v_saldo < p_monto THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;
    UPDATE cuenta SET saldo = saldo - p_monto WHERE id_cuenta = p_id_origen;
    UPDATE cuenta SET saldo = saldo + p_monto WHERE id_cuenta = p_id_destino;
    INSERT INTO transaccion (id_cuenta_origen, id_cuenta_destino, tipo, monto, estado, descripcion)
    VALUES (p_id_origen, p_id_destino, 'transferencia', p_monto, 'completada', p_descripcion);
  COMMIT;
  SELECT 'Transferencia realizada' AS mensaje;
END //

CREATE PROCEDURE sp_cargar_saldo(
  IN p_id_cuenta INT, IN p_monto DECIMAL(15,2)
)
BEGIN
  START TRANSACTION;
    UPDATE cuenta SET saldo = saldo + p_monto WHERE id_cuenta = p_id_cuenta;
    INSERT INTO transaccion (id_cuenta_destino, tipo, monto, estado, descripcion)
    VALUES (p_id_cuenta, 'carga', p_monto, 'completada', 'Carga de saldo');
  COMMIT;
  SELECT 'Carga exitosa' AS mensaje;
END //

CREATE PROCEDURE sp_pagar_servicio(
  IN p_id_pago INT, IN p_id_cuenta INT
)
BEGIN
  DECLARE v_monto DECIMAL(15,2);
  DECLARE v_saldo DECIMAL(15,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Error al pagar servicio' AS mensaje;
  END;
  START TRANSACTION;
    SELECT monto INTO v_monto FROM pago_servicio WHERE id_pago = p_id_pago;
    SELECT saldo INTO v_saldo FROM cuenta WHERE id_cuenta = p_id_cuenta FOR UPDATE;
    IF v_saldo < v_monto THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;
    UPDATE cuenta SET saldo = saldo - v_monto WHERE id_cuenta = p_id_cuenta;
    UPDATE pago_servicio SET estado = 'pagado' WHERE id_pago = p_id_pago;
    INSERT INTO transaccion (id_cuenta_origen, tipo, monto, estado, descripcion)
    VALUES (p_id_cuenta, 'pago', v_monto, 'completada', CONCAT('Pago servicio #', p_id_pago));
  COMMIT;
  SELECT 'Servicio pagado' AS mensaje;
END //

CREATE PROCEDURE sp_saldo_total_usuario(IN p_id_usuario INT)
BEGIN
  SELECT u.id_usuario, CONCAT(u.nombre,' ',u.apellido) AS cliente,
         SUM(c.saldo) AS saldo_total
  FROM usuario u
  JOIN cuenta c ON c.id_usuario = u.id_usuario
  WHERE u.id_usuario = p_id_usuario
  GROUP BY u.id_usuario, cliente;
END //

CREATE FUNCTION fn_calcular_rendimiento(
  p_monto DECIMAL(15,2),
  p_tasa DECIMAL(5,2),
  p_dias INT
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
  DECLARE v_rendimiento DECIMAL(15,2);
  SET v_rendimiento = p_monto * (p_tasa / 100) * (p_dias / 365);
  RETURN v_rendimiento;
END //

CREATE PROCEDURE sp_suscribir_servicio(
  IN p_id_usuario INT,
  IN p_id_plan INT,
  IN p_dias INT
)
BEGIN
  DECLARE v_precio DECIMAL(15,2);
  DECLARE v_id_suscripcion INT;
  DECLARE v_fecha_fin DATETIME;
  DECLARE v_error BOOLEAN DEFAULT FALSE;
  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    SET v_error = TRUE;
  END;
  
  START TRANSACTION;
    SELECT precio INTO v_precio FROM plan_servicio WHERE id_plan = p_id_plan;
    SET v_fecha_fin = DATE_ADD(NOW(), INTERVAL p_dias DAY);
    
    INSERT INTO suscripcion_servicio (id_usuario, id_plan, fecha_fin, estado, renovacion_automatica)
    VALUES (p_id_usuario, p_id_plan, v_fecha_fin, 'activa', TRUE);
    
    SET v_id_suscripcion = LAST_INSERT_ID();
    
    INSERT INTO consumo_servicio (id_suscripcion, descripcion, monto)
    VALUES (v_id_suscripcion, 'Alta de suscripcion', v_precio);
  COMMIT;
  
  IF v_error THEN
    SELECT -1 AS codigo, 'Error al suscribir servicio' AS mensaje;
  ELSE
    SELECT 0 AS codigo, 'Suscripcion creada' AS mensaje, v_id_suscripcion AS id_suscripcion;
  END IF;
END //

CREATE PROCEDURE sp_cancelar_suscripcion(IN p_id_suscripcion INT)
BEGIN
  DECLARE v_existe INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Error al cancelar suscripcion' AS mensaje;
  END;
  
  SELECT COUNT(*) INTO v_existe FROM suscripcion_servicio WHERE id_suscripcion = p_id_suscripcion;
  
  IF v_existe = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La suscripcion no existe';
  END IF;
  
  START TRANSACTION;
    UPDATE suscripcion_servicio
    SET estado = 'cancelada', renovacion_automatica = FALSE
    WHERE id_suscripcion = p_id_suscripcion;
  COMMIT;
  
  SELECT 'Suscripcion cancelada' AS mensaje;
END //

CREATE PROCEDURE sp_crear_inversion(
  IN p_id_usuario INT,
  IN p_id_tipo INT,
  IN p_monto DECIMAL(15,2),
  IN p_dias INT
)
BEGIN
  DECLARE v_tasa DECIMAL(5,2);
  DECLARE v_rendimiento DECIMAL(15,2);
  DECLARE v_fecha_vencimiento DATETIME;
  DECLARE v_id_inversion BIGINT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Error al crear inversion' AS mensaje;
  END;
  
  START TRANSACTION;
    SELECT tasa_anual INTO v_tasa FROM tipo_inversion WHERE id_tipo_inversion = p_id_tipo;
    SET v_rendimiento = fn_calcular_rendimiento(p_monto, v_tasa, p_dias);
    SET v_fecha_vencimiento = DATE_ADD(NOW(), INTERVAL p_dias DAY);
    
    INSERT INTO inversion (id_usuario, id_tipo_inversion, monto_invertido, fecha_vencimiento, rendimiento_acumulado, estado)
    VALUES (p_id_usuario, p_id_tipo, p_monto, v_fecha_vencimiento, v_rendimiento, 'activa');
    
    SET v_id_inversion = LAST_INSERT_ID();
    
    INSERT INTO movimiento_inversion (id_inversion, tipo, monto)
    VALUES (v_id_inversion, 'aporte', p_monto);
    
    INSERT INTO movimiento_inversion (id_inversion, tipo, monto)
    VALUES (v_id_inversion, 'rendimiento', v_rendimiento);
  COMMIT;
  
  SELECT 'Inversion creada' AS mensaje, v_id_inversion AS id_inversion, v_rendimiento AS rendimiento_estimado;
END //

CREATE PROCEDURE sp_aplicar_rendimiento_a_todas()
BEGIN
  DECLARE v_id_inversion BIGINT;
  DECLARE v_monto DECIMAL(15,2);
  DECLARE v_tasa DECIMAL(5,2);
  DECLARE v_rendimiento DECIMAL(15,2);
  DECLARE v_final INT DEFAULT 0;
  
  DECLARE cursor_inversiones CURSOR FOR
    SELECT i.id_inversion, i.monto_invertido, ti.tasa_anual
    FROM inversion i
    JOIN tipo_inversion ti ON ti.id_tipo_inversion = i.id_tipo_inversion
    WHERE i.estado = 'activa';
  
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_final = 1;
  
  OPEN cursor_inversiones;
  
  loop_inversiones: LOOP
    FETCH cursor_inversiones INTO v_id_inversion, v_monto, v_tasa;
    
    IF v_final = 1 THEN
      LEAVE loop_inversiones;
    END IF;
    
    SET v_rendimiento = fn_calcular_rendimiento(v_monto, v_tasa, 30);
    
    UPDATE inversion
    SET rendimiento_acumulado = rendimiento_acumulado + v_rendimiento
    WHERE id_inversion = v_id_inversion;
    
    INSERT INTO movimiento_inversion (id_inversion, tipo, monto)
    VALUES (v_id_inversion, 'rendimiento', v_rendimiento);
  END LOOP;
  
  CLOSE cursor_inversiones;
  
  SELECT 'Rendimientos aplicados' AS mensaje;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tr_auditoria_saldo_update
AFTER UPDATE ON cuenta
FOR EACH ROW
BEGIN
  IF OLD.saldo <> NEW.saldo THEN
    INSERT INTO auditoria_saldo (id_cuenta, saldo_anterior, saldo_nuevo, operacion, usuario_db)
    VALUES (NEW.id_cuenta, OLD.saldo, NEW.saldo, 'UPDATE_SALDO', USER());
  END IF;
END //

CREATE TRIGGER tr_saldo_no_negativo
BEFORE UPDATE ON cuenta
FOR EACH ROW
BEGIN
  IF NEW.saldo < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El saldo no puede ser negativo';
  END IF;
END //

CREATE TRIGGER tr_validar_transferencia
BEFORE INSERT ON transaccion
FOR EACH ROW
BEGIN
  IF NEW.tipo = 'transferencia' AND NEW.id_cuenta_origen = NEW.id_cuenta_destino THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Origen y destino no pueden ser iguales';
  END IF;
END //

CREATE TRIGGER tr_historial_estado_tx
AFTER UPDATE ON transaccion
FOR EACH ROW
BEGIN
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO historial_estado_transaccion (id_transaccion, estado_anterior, estado_nuevo)
    VALUES (NEW.id_transaccion, OLD.estado, NEW.estado);
  END IF;
END //

CREATE TRIGGER tr_prevenir_borrado_cuenta
BEFORE DELETE ON cuenta
FOR EACH ROW
BEGIN
  IF OLD.saldo > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una cuenta con saldo';
  END IF;
END //

DELIMITER //

CREATE TRIGGER tr_validar_suscripcion_duplicada
BEFORE INSERT ON suscripcion_servicio
FOR EACH ROW
BEGIN
  DECLARE v_existe INT DEFAULT 0;
  
  SELECT COUNT(*) INTO v_existe
  FROM suscripcion_servicio
  WHERE id_usuario = NEW.id_usuario
    AND id_plan = NEW.id_plan
    AND estado = 'activa';
  
  IF v_existe > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario ya tiene una suscripcion activa a este plan';
  END IF;
END //

CREATE TRIGGER tr_historial_suscripcion
AFTER UPDATE ON suscripcion_servicio
FOR EACH ROW
BEGIN
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO historial_estado_transaccion (id_transaccion, estado_anterior, estado_nuevo)
    VALUES (NEW.id_suscripcion, OLD.estado, NEW.estado);
  END IF;
END //

CREATE TRIGGER tr_validar_monto_inversion
BEFORE INSERT ON inversion
FOR EACH ROW
BEGIN
  IF NEW.monto_invertido < 1000 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto minimo de inversion es 1000';
  END IF;
END //

CREATE TRIGGER tr_auditoria_rendimiento
AFTER UPDATE ON inversion
FOR EACH ROW
BEGIN
  IF OLD.rendimiento_acumulado <> NEW.rendimiento_acumulado THEN
    INSERT INTO auditoria_saldo (id_cuenta, saldo_anterior, saldo_nuevo, operacion, usuario_db)
    VALUES (0, OLD.rendimiento_acumulado, NEW.rendimiento_acumulado, 'RENDIMIENTO_INVERSION', USER());
  END IF;
END //

CREATE TRIGGER tr_prevenir_borrado_inversion_activa
BEFORE DELETE ON inversion
FOR EACH ROW
BEGIN
  IF OLD.estado = 'activa' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar una inversion activa';
  END IF;
END //

DELIMITER ;

CREATE INDEX idx_cuenta_alias ON cuenta(alias);
CREATE INDEX idx_cuenta_cvu ON cuenta(cvu);
CREATE INDEX idx_usuario_dni ON usuario(dni);
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_transaccion_origen ON transaccion(id_cuenta_origen);
CREATE INDEX idx_transaccion_destino ON transaccion(id_cuenta_destino);
CREATE INDEX idx_transaccion_fecha ON transaccion(fecha);
CREATE INDEX idx_suscripcion_usuario ON suscripcion_servicio(id_usuario);
CREATE INDEX idx_suscripcion_estado ON suscripcion_servicio(estado);
CREATE INDEX idx_inversion_usuario ON inversion(id_usuario);
CREATE INDEX idx_inversion_estado ON inversion(estado);
CREATE INDEX idx_movimiento_inversion ON movimiento_inversion(id_inversion);