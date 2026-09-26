import express from 'express';
import connectDb from './db/connectdb.js';
import route from './routes/route.js';

const app = express();
const port = process.env.PORT || 6000;

app.use(express.json());

app.use('/', route);

const DATABASE_URL = process.env.DATABASE_URL || 'mongodb://localhost:27017';

connectDb(DATABASE_URL)
    .then(() => {
        app.listen(port, () => {
            console.log(`Server running on port ${port}`);
        });
    })
    .catch((err) => {
        console.error('Failed to start server', err);
    });