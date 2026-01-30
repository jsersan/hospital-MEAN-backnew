/*
    Ruta de búsqueda: /api/uploads/
*/

const { Router } = require('express');
const { fileUpload, retornaImagen } = require('../controllers/uploads');
const { validarJWT } = require('../middlewares/validar-jwt');
const multer = require('multer');
const { storage } = require('../config/cloudinary');

const router = Router();

// Configurar multer con Cloudinary storage
const upload = multer({ storage: storage });

// Rutas
router.use(validarJWT); // Proteger todas las rutas con JWT

// Subir imagen (POST)
router.put('/:tipo/:id', upload.single('imagen'), fileUpload);

// Obtener imagen (GET) - Esta ruta ya no es necesaria con Cloudinary
// porque las imágenes se sirven directamente desde Cloudinary
router.get('/:tipo/:foto', retornaImagen);

module.exports = router;