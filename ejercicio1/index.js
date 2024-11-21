var express = require('express');
var app = express();
var mysql = require('mysql2');
var bodyParser = require('body-parser');

var connection = mysql.createConnection({
    host: 'localhost',
    database: 'barbershop',
    user: 'root',
    password: '',
});

connection.connect(function(err) {
    if (err) throw err;
    console.log("Se conectó a la BD");
});

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// Creación del servidor
var server = app.listen(3000, "127.0.0.1", function() {
    var host = server.address().address;
    var port = server.address().port;
});

// API que me traerá todos los BOOKS
app.get('/books', function(req, res) {
    connection.query('SELECT * FROM books', function(error, results) {
        if (error) throw error;
        res.end(JSON.stringify(results));
    });
});

// API que me traerá un BOOK por su ID
app.get('/books/:id', function(req, res) {
    console.log("Requested ID:", req.params.id);
    connection.query('SELECT * FROM books WHERE id = ?', [req.params.id], function(error, results) {
        if (error) throw error;
        res.end(JSON.stringify(results));
    });
});
