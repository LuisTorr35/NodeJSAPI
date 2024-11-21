const express = require('express');
const jwt = require('jsonwebtoken')
const app = express();
const mysql = require('mysql2');
app.use(express.json());

const db = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "YsoyRebelde01",
    database: "tiendalibro",
});

db.connect((err) => {
    if (err) {
        console.error("Error conectando a la base de datos: ", err);
        return;
    }
    console.log("Conectado a la base de datos MySQL");
});

app.get('/api', (req,res) =>{
    res.json({
        message:"esto es data"
    });
});

app.get('/api/libro', verifytoken, (req,res) => {
    jwt.verify(req.token, 'secretkey', (err,authData) =>{
        if(err){
            res.sendStatus(403);
        }else{
            db.query('CALL mostrar_libros_disponibles()', (err, result) =>{
                if (err) {
                    console.error('Error al ejecutar el procedimiento:', err);
                    return res.status(500).json({ message: 'Error al obtener los libros' });
                }
                res.json(result[0]);
            })
        }
    });
});

app.get('/api/compra', verifytoken, (req,res) => {
    const user = 73999505
    jwt.verify(req.token, 'secretkey', (err, authData) => {
        if (err) {
            res.sendStatus(403);
        }else{
            db.query('CALL ver_compras_usuario(?)', [user], (err,result) => {
                if (err) {
                    console.error('Error al llamar al procedimiento:', err);
                    return res.status(500).json({ message: 'Error en el servidor' });
                }
                res.json(result[0]);
            })
        }
    })
})

app.post('/api/login', (req,res) => {
    
    const user = {
        id: 73999505,
        pssw: 'holasoy'
    }
    db.query('CALL login(?, ?, @outnomb, @outpssw);', [user.id, user.pssw], (err, result) =>{
        if (err) {
            console.error('Error al llamar al procedimiento:', err);
            return res.status(500).json({ message: 'Error en el servidor' });
        }
        db.query('SELECT @outnomb as nombre, @outpssw as pssw', (err, result) =>{
            if (err){
                console.error('Error al llamar al procedimiento:', err);
                return res.status(500).json({ message: 'Error en el servidor' });
            }
            if(user.pssw === result[0].pssw && user.pssw != null){
                console.log("Aprobao")
                jwt.sign({user}, 'secretkey', {expiresIn: '2h'}, (err,token) =>{
                    res.json({
                        token
                    })
                });
            }
        })
    });
})

function verifytoken(req,res,next) {
    const bearerHeader = req.headers['authorization'];
    if (typeof bearerHeader !== 'undefined'){
        const bearer = bearerHeader.split(' ');
        const bearerToken = bearer[1];
        req.token = bearerToken;
        next();
    }else{
        res.sendStatus(403)
    }
}


app.listen(3200, () =>console.log("servidor en puerto 3200"));