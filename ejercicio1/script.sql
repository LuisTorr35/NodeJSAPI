CREATE DATABASE IF NOT EXISTS LibroHub;
USE LibroHub;

-- TABLA AUTORES
CREATE TABLE IF NOT EXISTS autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    biografia TEXT
);

-- TABLA GENEROS
CREATE TABLE IF NOT EXISTS generos (
    id_genero INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- TABLA LIBROS
CREATE TABLE IF NOT EXISTS libros (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    id_autor INT,
    id_genero INT,
    descripcion TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    fecha_publicacion DATE,
    imagen TEXT,
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES generos(id_genero) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TABLA CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ap_paterno VARCHAR(35) NOT NULL,
    ap_materno VARCHAR(35) NOT NULL,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contrasenia VARCHAR(255) NOT NULL,
    direccion VARCHAR(255)
);

-- TABLA PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido DATE NOT NULL,
    monto_total DECIMAL(10, 2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TABLA DETALLES_PEDIDO
CREATE TABLE IF NOT EXISTS detalles_pedido (
    id_detalle_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_libro INT,
    cantidad INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TABLA ADMINISTRADORES
CREATE TABLE IF NOT EXISTS administradores (
    id_administrador INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    ap_paterno VARCHAR(35) NOT NULL,
    ap_materno VARCHAR(35) NOT NULL,
    correo VARCHAR(50) UNIQUE NOT NULL,
    contrasenia VARCHAR(255) NOT NULL,
    rol VARCHAR(5) DEFAULT 'admin'
);

-- Eliminar la tabla libros (si es necesario)
DROP TABLE IF EXISTS libros;

-- Consultas
SELECT * FROM generos;
SELECT * FROM autores;
SELECT * FROM libros;

DELETE FROM libros WHERE id_libro IN (3, 4);

-- INSERCION DE DATOS
-- GENEROS
INSERT INTO generos(nombre) VALUES ('Aventura'), ('Fantasía');
INSERT INTO generos(nombre) VALUES ('Drama'), ('Novela');

-- AUTORES
INSERT INTO autores(nombre, biografia) VALUES
('Brown Peter', 'Peter Brown creció en Nueva Jersey.'),
('Hirsch Alex', 'Es el creador de la serie de Disney XD Gravity Falls'),
('C.S. Lewis', 'C. S. Lewis, fue un apologista cristiano anglicano, medievalista, y escritor británico'),
('Paolo Barbieri', NULL),
('Pablo Vierci', 'Pablo Vierci es un escritor, periodista y guionista uruguayo. Ha escrito 12 libros'),
('John Green', 'John Michael Green es un escritor estadounidense de literatura juvenil, blogger en YouTube y productor ejecutivo');

-- LIBROS
INSERT INTO libros(titulo, id_autor, id_genero, precio, descripcion, stock, fecha_publicacion, imagen) VALUES
('Robot Salvaje', 1, 1, 34.80, 'Libro de Aventura de una robot en una isla', 10, '2012-06-20', 'https://www.crisol.com.pe/media/catalog/product/cache/cf84e6047db2ba7f2d5c381080c69ffe/e/l/el-escape-de-la-robot-salvaje_thndc7v1lpaddvi1.jpg'),
('El libro de Bill', 2, 2, 79.90, 'Libro de Misterios y terror', 5, '2023-09-15', 'https://www.crisol.com.pe/media/catalog/product/cache/597531f9de47f5e5225ef01cbe4bbd93/9/7/9786123194330.jpg');

INSERT INTO libros(titulo, id_autor, id_genero, precio, descripcion, stock, fecha_publicacion, imagen) VALUES
('Las crónicas de Narnia', 3, 2, 139, 'Libro de aventura y de un leon en busca de los 3 reyes', 20, '2000-03-14', 'https://www.crisol.com.pe/media/catalog/product/cache/597531f9de47f5e5225ef01cbe4bbd93/9/7/9781400334780_idqowfcbemvm48yz.jpg'),
('The Wizard of Oz', 4, 1, 145, 'Un mago en una ciudad mágica', 6, '1990-11-20', 'https://www.crisol.com.pe/media/catalog/product/cache/597531f9de47f5e5225ef01cbe4bbd93/9/7/9788865279137_0tdalkhvyw8apkna.jpg'),
('La sociedad de la nieve', 5, 4, 69.90, 'Una novela que te hara llorar como nunca has llorado', 13, '2023-12-15', 'https://www.crisol.com.pe/media/catalog/product/cache/cf84e6047db2ba7f2d5c381080c69ffe/9/7/9786123199371_sflyja7ypcnsl4vl.jpg');

INSERT INTO libros(titulo, id_autor, id_genero, precio, descripcion, stock, fecha_publicacion, imagen) VALUES
('Bajo la misma estrella', 6, 3, 49, 'Una drama que te hara dramatizar como nunca haz dramatizado', 12, '2012-01-10', 'https://www.crisol.com.pe/media/catalog/product/cache/cf84e6047db2ba7f2d5c381080c69ffe/9/7/9786124262104_bsxrwk4l1xxqt5c0.jpg');

-- ADMINISTRADOR
INSERT INTO clientes(nombre, ap_paterno, ap_materno, correo, contrasenia, direccion) VALUES
('Fidel', 'Arias', 'Arias', 'fidelarias@gmail.com', '123456', 'Cerro colorado');

-- CREANDO PROCEDIMIENTOS ALMACENADOS
DELIMITER //

CREATE PROCEDURE devolver_libros()
BEGIN
    SELECT l.id_libro, l.titulo, a.nombre AS autor, g.nombre AS genero, l.descripcion, l.precio, l.stock, l.imagen
    FROM libros l
    INNER JOIN autores a ON l.id_autor = a.id_autor
    INNER JOIN generos g ON l.id_genero = g.id_genero;
END //

DELIMITER //

CREATE PROCEDURE detalle_libro(IN id INT)
BEGIN
    SELECT l.id_libro, l.titulo, a.nombre AS autor, g.nombre AS genero, l.descripcion, l.precio, l.stock, l.imagen
    FROM libros l
    INNER JOIN autores a ON l.id_autor = a.id_autor
    INNER JOIN generos g ON l.id_genero = g.id_genero
    WHERE l.id_libro = id;
END //

DELIMITER //

CREATE PROCEDURE ingresar_autor(IN nombre_autor VARCHAR(255), IN biografia_autor TEXT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, asigna -1 a la variable de salida y termina
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO autores(nombre, biografia) VALUES (nombre_autor, biografia_autor);
    COMMIT;
END //

DELIMITER //

CREATE PROCEDURE ingresar_categoria(IN categoria VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
    INSERT INTO generos(nombre) VALUES (categoria);
    COMMIT;
END //

DELIMITER //

CREATE PROCEDURE ingresar_libro(
    IN title VARCHAR(255),
    IN autor VARCHAR(255),
    IN biografia_autor TEXT,
    IN categoria VARCHAR(100),
    IN dscp TEXT,
    IN price DECIMAL(10,2),
    IN cant INT,
    IN fecha DATE,
    IN image TEXT,
    OUT result_libro INT
)
BEGIN
    DECLARE search_autor INT;
    DECLARE search_categoria INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, asigna -1 a la variable de salida y termina
        SET result_libro = -1;
        ROLLBACK;
    END;

    -- Iniciar la transacción
    START TRANSACTION;

    -- Intentar buscar el autor; si no existe, insertarlo
    SET search_autor = (SELECT id_autor FROM autores WHERE nombre = autor);
    IF search_autor IS NULL THEN
        CALL ingresar_autor(autor, biografia_autor);
        SET search_autor = (SELECT id_autor FROM autores WHERE nombre = autor);
    END IF;

    -- Intentar buscar la categoría; si no existe, insertarla
    SET search_categoria = (SELECT id_genero FROM generos WHERE nombre = categoria);
    IF search_categoria IS NULL THEN
        CALL ingresar_categoria(categoria);
        SET search_categoria = (SELECT id_genero FROM generos WHERE nombre = categoria);
    END IF;

    -- Intentar insertar el libro
    INSERT INTO libros(titulo, id_autor, id_genero, precio, descripcion, stock, fecha_publicacion, imagen)
    VALUES (title, search_autor, search_categoria, price, dscp, cant, fecha, image);

    -- Si todo es exitoso, asignar 1 a la variable de resultado
    SET result_libro = 1;

    -- Confirmar la transacción
    COMMIT;
END //

DELIMITER //

CREATE PROCEDURE eliminar_libro(IN id INT, OUT result_eliminar VARCHAR(6))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET result_eliminar = 'DENIED';
        ROLLBACK;
    END;

    START TRANSACTION;
    DELETE FROM libros WHERE id_libro = id;
    SET result_eliminar = 'OK';
END //

DELIMITER //

-- Llamadas de prueba
CALL ingresar_libro('Messi Peruano', 'Brown Peter', 'Es cojo', 'Aventura', 'Messi', 12.50, 2, '2015-10-23', 'https://123456', @result_libro);
SELECT @result_libro;
CALL eliminar_libro(7, @result_eliminar);
SELECT @result_eliminar;
