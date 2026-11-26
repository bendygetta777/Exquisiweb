-- Initial seed data for Exquisiweb
USE exquisiweb;

-- Reset base tables before inserting test records
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE platillo;
TRUNCATE TABLE usuario;
SET FOREIGN_KEY_CHECKS = 1;

-- Test users for each system role (passwords use placeholder hash strings)
INSERT INTO usuario (nombre, tipo_usuario, telefono, correo, contrasena) VALUES
  ('Cliente Prueba', 'cliente', '4491000001', 'cliente@exquisiweb.com', '$2b$10$placeholderhashcliente000000000000000000000000000'),
  ('Cajero Prueba', 'cajero', '4491000002', 'cajero@exquisiweb.com', '$2b$10$placeholderhashcajero0000000000000000000000000000'),
  ('Administrador Prueba', 'administrador', '4491000003', 'admin@exquisiweb.com', '$2b$10$placeholderhashadmin00000000000000000000000000000');

-- Initial product catalog matching menu categories
INSERT INTO platillo (nombre, tipo, precio, tiempo_preparacion, disponible) VALUES
  ('Taco de guisado', 'taco', 18.00, 3, TRUE),
  ('Taco de carne', 'taco', 22.00, 4, TRUE),
  ('Orden de tacos', 'taco', 55.00, 5, TRUE),
  ('Burrito sencillo', 'burrito', 45.00, 6, TRUE),
  ('Burrito especial', 'burrito', 60.00, 8, TRUE),
  ('Mollete sencillo', 'mollete', 30.00, 4, TRUE),
  ('Mollete especial', 'mollete', 42.00, 6, TRUE),
  ('Bebida', 'extra', 20.00, 3, TRUE),
  ('Acompanamiento', 'extra', 25.00, 4, TRUE);