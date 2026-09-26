import express from 'express';
import {
    createCrud,
    getCrud,
    updateCrud,
    deleteCrud,
} from '../controllers/itemController.js';

const route = express.Router();

route.get('/', (req, res) => {
    res.send('API is running');
});

route.post('/ikokas', createCrud);
route.get('/ikokas', getCrud);
route.put('/ikokas/:id', updateCrud);
route.delete('/ikokas/:id', deleteCrud);

export default route;