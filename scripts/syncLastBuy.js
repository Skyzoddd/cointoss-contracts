require('dotenv').config();
const { ethers } = require('ethers');
const fetch = require('node-fetch');

const ABI = [
  'event BuyLogged(address indexed buyer, uint256 timestamp)'
];

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);

async function getTokenContracts() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/tokens?select=contract_address`, {
    headers: {
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`
    }
  });

  if (!res.ok) {
    console.error('❌ Failed to fetch contracts:', await res.text());
    return [];
  }

  const data = await res.json();
  return data.map((row) => row.contract_address).filter(Boolean);
}

async function updateLastBuy(buyer, timestamp) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/tokens?wallet=eq.${buyer.toLowerCase()}`, {
    method: 'PATCH',
    headers: {
      'apikey': SUPABASE_SERVICE_KEY,
      'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'resolution=merge-duplicates'
    },
    body: JSON.stringify({ last_buy: new Date(timestamp * 1000).toISOString() })
  });

  if (!res.ok) {
    console.error(`❌ Supabase update failed for ${buyer}`, await res.text());
  } else {
    console.log(`✅ Updated last_buy for ${buyer}`);
  }
}

async function main() {
  const addresses = await getTokenContracts();

  for (const token of addresses) {
    const contract = new ethers.Contract(token, ABI, provider);
    const logs = await contract.queryFilter('BuyLogged', -10000);

    for (const log of logs) {
      const buyer = log.args.buyer;
      const timestamp = log.args.timestamp;
      await updateLastBuy(buyer, timestamp);
    }
  }

  console.log('✅ Sync complete.');
}

main().catch(console.error);
