import mongoose from 'mongoose';

const connectDb = async (DATABASE_URL) => {
    try {
        const data = await mongoose.connect(DATABASE_URL, { dbName: 'crud' });
        if (data.connection && data.connection.readyState === 1) {
            console.log('connection Successful!');
        }
    } catch (error) {
        console.log(error.message);
        process.exit(1);
    }
};

export default connectDb;