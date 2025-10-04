import { JSONFilePreset } from 'lowdb/node';
import { v4 as uuidv4 } from 'uuid';

type Data = {
  items: Item[];
};

export type Item = {
  id?: string;
  name: string;
  price: number;
};

const defaultData: Data = { items: [] };

export const getDb = async () => {
  return await JSONFilePreset<Data>(`db.json`, defaultData);
};

export const addItem = async (item: Item) => {
  const db = await getDb();
  const updatedItem: Item = { id: uuidv4(), ...item };
  db.data.items.push(updatedItem);
  await db.write();
};

export const getItems = async () => {
  return (await getDb()).data.items;
};
