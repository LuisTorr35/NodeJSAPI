create table usuario( id INT(4) Primary key AUTO_INCREMENT, nomb VARCHAR(50) NOT NULL, pssw VARCHAR(20) NOT NULL );
DELIMITER $$
CREATE PROCEDURE login(IN input_id INTEGER, IN input_pssw VARCHAR(20), OUT output_id INTEGER, OUT output_pssw VARCHAR(20)) BEGIN SELECT id, pssw INTO output_id, output_pssw FROM usuario WHERE id = input_id AND pssw = input_pssw; END $$

USE tiendalibro;
CREATE TABLE libro(
	id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0
);
INSERT INTO libro (titulo, autor, precio, stock) VALUES
    ('Cien Años de Soledad', 'Gabriel García Márquez', 19.99, 100),
    ('1984', 'George Orwell', 14.50, 150),
    ('El Gran Gatsby', 'F. Scott Fitzgerald', 10.99, 80),
    ('Don Quijote de la Mancha', 'Miguel de Cervantes', 22.95, 120),
    ('Matar a un ruiseñor', 'Harper Lee', 18.75, 90),
    ('Fahrenheit 451', 'Ray Bradbury', 12.99, 200),
    ('La sombra del viento', 'Carlos Ruiz Zafón', 25.00, 50),
    ('Harry Potter y la piedra filosofal', 'J.K. Rowling', 29.99, 300),
    ('El código Da Vinci', 'Dan Brown', 19.95, 140),
    ('Orgullo y prejuicio', 'Jane Austen', 16.50, 60);
DELIMITER $$
CREATE PROCEDURE login(
    IN input_id INTEGER,
    IN input_pssw VARCHAR(20),
    OUT output_nomb VARCHAR(50),
    OUT output_pssw VARCHAR(20)
)
BEGIN
    -- Seleccionamos solo el nombre del usuario si la contraseña es correcta
    SELECT nomb, pssw
    INTO output_nomb, output_pssw
    FROM usuario
    WHERE id = input_id AND pssw = input_pssw;
    
    -- Si no se encuentra el usuario, establecemos output_nomb como NULL
    IF output_nomb IS NULL THEN
        SET output_nomb = NULL, output_pssw = NULL;
    END IF;
END $$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE mostrar_libros_disponibles()
BEGIN
	SELECT id, titulo, autor, precio, stock FROM libro
    WHERE stock > 0;
END $$

CALL mostrar_libros_disponibles();


SHOW TABLES;
CALL login(73999505, 'holanosoy', @outnomb, @outpssw);
SELECT @outnomb as nombre, @outpssw as pssw;
SELECT * from usuario;

CREATE TABLE compra (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_libro INT,
    id_usuario INT,
    cantidad INT DEFAULT 1,
    precio_total DECIMAL(10, 2),
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_libro) REFERENCES libro(id),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

DELIMITER $$

CREATE PROCEDURE realizar_compra(
    IN input_id_libro INT,
    IN input_id_usuario INT,
    IN input_cantidad INT
)
BEGIN
    DECLARE stock_actual INT;
    DECLARE precio_libro DECIMAL(10, 2);
    DECLARE precio_total DECIMAL(10, 2);

    -- Obtener el stock actual y el precio del libro
    SELECT stock, precio INTO stock_actual, precio_libro
    FROM libro
    WHERE id = input_id_libro;

    -- Verificar si hay suficiente stock
    IF stock_actual < input_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente stock para completar la compra';
    ELSE
        -- Calcular el precio total
        SET precio_total = precio_libro * input_cantidad;

        -- Insertar la compra
        INSERT INTO compra (id_libro, id_usuario, cantidad, precio_total)
        VALUES (input_id_libro, input_id_usuario, input_cantidad, precio_total);

        -- Actualizar el stock del libro
        UPDATE libro
        SET stock = stock - input_cantidad
        WHERE id = input_id_libro;
    END IF;
END $$

DELIMITER ;

CALL realizar_compra(1, '73999505', 3);

DELIMITER $$

CREATE PROCEDURE ver_compras_usuario(IN input_id_usuario INT)
BEGIN
    -- Seleccionar todas las compras realizadas por el usuario
    SELECT 
        c.id AS id_compra,
        c.id_libro,
        l.titulo AS libro_titulo,
        c.cantidad,
        c.precio_total,
        c.fecha_compra
    FROM 
        compra c
    INNER JOIN 
        libro l ON c.id_libro = l.id
    WHERE 
        c.id_usuario = input_id_usuario;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS tiendalibro.actualizar_stock_compra;

DROP TABLE compra;
DELIMITER ;
