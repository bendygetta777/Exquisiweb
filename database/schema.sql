-- Database initialization 
CREATE DATABASE IF NOT EXISTS exquisiweb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE exquisiweb;

-- Drop existing tables in reverse dependency order
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS comprobante;
DROP TABLE IF EXISTS metodo_pago;
DROP TABLE IF EXISTS personalizacion;
DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS corte_caja;
DROP TABLE IF EXISTS platillo;
DROP TABLE IF EXISTS usuario;

SET FOREIGN_KEY_CHECKS = 1;

-- System users: clients, cashiers, and administrators
CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo_usuario ENUM('cliente', 'cajero', 'administrador') NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  contrasena VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product catalog with availability status
CREATE TABLE platillo (
  id_platillo INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  tipo ENUM('taco', 'burrito', 'mollete', 'extra') NOT NULL,
  precio DECIMAL(6,2) NOT NULL,
  tiempo_preparacion TINYINT NOT NULL,
  disponible BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_platillo_precio CHECK (precio > 0),
  CONSTRAINT chk_platillo_tiempo CHECK (tiempo_preparacion > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Daily cash register closing summary
CREATE TABLE corte_caja (
  id_corte INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATE NOT NULL UNIQUE,
  total_efectivo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_tarjeta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_transferencia DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_web DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_presencial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  pedidos_cancelados SMALLINT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Web and counter orders; id_pedido acts as sequential turn number
CREATE TABLE pedido (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NULL,
  id_corte INT NULL,
  fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  canal ENUM('web', 'presencial') NOT NULL,
  estado ENUM('pendiente', 'pagado', 'en_preparacion', 'listo', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
  total DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  tiempo_estimado TINYINT NOT NULL,
  motivo_cancelacion VARCHAR(255) NULL,
  CONSTRAINT fk_pedido_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pedido_corte
    FOREIGN KEY (id_corte) REFERENCES corte_caja(id_corte)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Line items associated with each order
CREATE TABLE detalle_pedido (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_platillo INT NOT NULL,
  cantidad TINYINT NOT NULL,
  subtotal DECIMAL(8,2) NOT NULL,
  CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
  CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detalle_platillo
    FOREIGN KEY (id_platillo) REFERENCES platillo(id_platillo)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Customizations and paid extras per order item
CREATE TABLE personalizacion (
  id_personalizacion INT AUTO_INCREMENT PRIMARY KEY,
  id_detalle INT NOT NULL,
  descripcion VARCHAR(150) NOT NULL,
  costo_extra DECIMAL(6,2) NOT NULL DEFAULT 0.00,
  tiempo_extra TINYINT NOT NULL DEFAULT 0,
  CONSTRAINT chk_personalizacion_costo CHECK (costo_extra >= 0),
  CONSTRAINT chk_personalizacion_tiempo CHECK (tiempo_extra >= 0),
  CONSTRAINT fk_personalizacion_detalle
    FOREIGN KEY (id_detalle) REFERENCES detalle_pedido(id_detalle)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment records per order
CREATE TABLE metodo_pago (
  id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  tipo ENUM('efectivo', 'tarjeta', 'transferencia') NOT NULL,
  monto DECIMAL(8,2) NOT NULL,
  CONSTRAINT chk_metodo_pago_monto CHECK (monto > 0),
  CONSTRAINT fk_metodo_pago_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bank transfer receipt for web pre-orders
CREATE TABLE comprobante (
  id_comprobante INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL UNIQUE,
  id_metodo_pago INT NULL UNIQUE,
  archivo_imagen VARCHAR(255) NOT NULL,
  estado ENUM('en_revision', 'validado', 'rechazado', 'expirado') NOT NULL DEFAULT 'en_revision',
  hora_subida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tiempo_limite TINYINT NOT NULL DEFAULT 5,
  tiempo_extra TINYINT NOT NULL DEFAULT 3,
  CONSTRAINT fk_comprobante_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_comprobante_metodo_pago
    FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;