const { response } = require('express');
const { cloudinary } = require('../config/cloudinary');
const Usuario = require('../models/usuario');
const Medico = require('../models/medico');
const Hospital = require('../models/hospital');

const fileUpload = async (req, res = response) => {
    try {
        const { tipo, id } = req.params;

        // Validar que se subió un archivo
        if (!req.file) {
            return res.status(400).json({
                ok: false,
                msg: 'No se subió ningún archivo'
            });
        }

        // Validar tipo
        const tiposValidos = ['hospitales', 'medicos', 'usuarios'];
        if (!tiposValidos.includes(tipo)) {
            return res.status(400).json({
                ok: false,
                msg: 'No es un médico, usuario u hospital (tipo no válido)'
            });
        }

        // Obtener el modelo según el tipo
        let modelo;
        switch (tipo) {
            case 'usuarios':
                modelo = Usuario;
                break;
            case 'medicos':
                modelo = Medico;
                break;
            case 'hospitales':
                modelo = Hospital;
                break;
        }

        // Buscar el documento en la base de datos
        const documento = await modelo.findById(id);
        if (!documento) {
            // Si subió una imagen pero no existe el documento, eliminar de Cloudinary
            const publicId = req.file.filename; // Cloudinary guarda el public_id aquí
            await cloudinary.uploader.destroy(publicId);
            
            return res.status(404).json({
                ok: false,
                msg: `No existe un ${tipo.slice(0, -1)} con el id ${id}`
            });
        }

        // Si el documento ya tenía una imagen anterior, eliminarla de Cloudinary
        if (documento.img) {
            // Extraer el public_id de la URL de Cloudinary
            const urlParts = documento.img.split('/');
            const filename = urlParts[urlParts.length - 1];
            const publicId = `hospital-mean/${filename.split('.')[0]}`;
            
            try {
                await cloudinary.uploader.destroy(publicId);
            } catch (error) {
                console.log('Error al eliminar imagen anterior:', error);
                // No detener el proceso si falla la eliminación
            }
        }

        // Actualizar el documento con la nueva URL de Cloudinary
        documento.img = req.file.path; // Cloudinary guarda la URL completa en req.file.path
        await documento.save();

        res.json({
            ok: true,
            msg: 'Archivo subido correctamente',
            img: documento.img
        });

    } catch (error) {
        console.log(error);
        res.status(500).json({
            ok: false,
            msg: 'Error al subir el archivo. Hable con el administrador'
        });
    }
};

const retornaImagen = async (req, res = response) => {
    const { tipo, foto } = req.params;

    // Con Cloudinary, esta función ya no es necesaria porque las imágenes
    // se sirven directamente desde Cloudinary. Pero la dejamos por compatibilidad.
    
    // Simplemente redirigir a una imagen por defecto o devolver 404
    const path = require('path');
    const fs = require('fs');
    
    const pathImagen = path.join(__dirname, `../uploads/no-img.jpg`);
    
    if (fs.existsSync(pathImagen)) {
        res.sendFile(pathImagen);
    } else {
        res.status(404).json({
            ok: false,
            msg: 'Imagen no encontrada'
        });
    }
};

module.exports = {
    fileUpload,
    retornaImagen
};