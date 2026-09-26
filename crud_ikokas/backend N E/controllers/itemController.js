import Crud from '../models/itemModel.js';

export const createCrud = async (req, res) => {
  try {
    const item = await Crud.create(req.body);
    res.status(201).json(item);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

export const getCrud = async (req, res) => {
  try {
    const items = await Crud.find({});
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


export const updateCrud = async (req, res) => {
  try {
    const item = await Crud.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json(item);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

export const deleteCrud = async (req, res) => {
  try {
    const item = await Crud.findByIdAndDelete(req.params.id);
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json({ message: 'Item deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
