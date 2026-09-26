import mongoose from 'mongoose';

const crudSchema = new mongoose.Schema({
  name: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String },
}, { timestamps: true });

const Crud = mongoose.model('Crud', crudSchema);
export default Crud;
