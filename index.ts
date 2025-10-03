import express from 'express';
import { z } from 'zod';
import { addItem, getItems } from './src/data';
import type { Item } from './src/data';

const itemSchema = z.object({
  name: z.string().min(1),
  price: z.number().nonnegative(),
});

const app = express();
const PORT = Number(process.env.PORT || 3000);

app.use(express.json());

app.get('/', async (_req, res) => {
  res.json({ msg: 'Server is running...' });
});

app.get('/items', async (_req, res) => {
  try {
    const items = await getItems();
    res.json(items);
  } catch (err) {
    console.error('Failed to read items', err);
    res.status(500).json({ error: 'Failed to read items' });
  }
});

app.post('/items', async (req, res) => {
  try {
    const parsed = itemSchema.safeParse(req.body);
    if (!parsed.success) {
      return res
        .status(400)
        .json({ error: 'Invalid payload', details: parsed.error.format() });
    }

    const toAdd: Item = parsed.data;
    await addItem(toAdd);
    const items = await getItems();
    res.status(201).json(items);
  } catch (err) {
    console.error('Failed to add item', err);
    res.status(500).json({ error: 'Failed to add item' });
  }
});

app.get('/error', async () => {
  console.error('Terminating the application!');
  process.exit(1);
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
