contract;

mod src20;

use src20::SRC20;
use std::{
    u128::U128,
    hash::sha256,
    asset::transfer,
    hash::Hash,
    asset_id::AssetId,
    asset::{
        burn,
        mint_to,
    },
    call_frames::{
        contract_id,
        msg_asset_id,
    },
    context::msg_amount,
    string::String,
};

abi ConstantProductAMM {
    #[storage(read, write), payable]
    fn deposit();

    #[storage(read, write)]
    fn withdraw(recipient: Identity, asset: AssetId);

    #[storage(read)]
    fn get_pool(asset_a: AssetId) -> Option<Pool>;

    #[storage(read, write), payable]
    fn add_liquidity(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> u64;

    #[storage(read, write), payable]
    fn remove_liquidity(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> (u64, u64);

    #[storage(read, write), payable]
    fn swap(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> u64;
}

struct Pool {
    reserve_a: u64,
    reserve_b: u64,
    total_supply: u64
}

storage {
    total_pools: u64 = 0,
    pools: StorageMap<AssetId, Pool> = StorageMap {},
    deposits: StorageMap<(Identity, AssetId), u64> = StorageMap {},
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_pools.try_read().unwrap_or(0)
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        let pool = storage.pools.get(asset).try_read();
        
        match pool {
            Some(x) => Some(x.total_supply),
            None => None,
        }
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        Some(String::from_ascii_str(from_str_array(__to_str_array("ConstantSumAMM"))))
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        Some(String::from_ascii_str(from_str_array(__to_str_array("AMMLP"))))
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        Some(9)
    }
}

#[storage(read, write), payable]
fn deposit_or_call(asset: AssetId) -> u64 {
    match msg_amount() > 0 {
        true => {
            require(msg_asset_id() == asset, "invalid called asset id");

            msg_amount()
        },
        false => {
            let owner = msg_sender().unwrap();
            let amount = storage.deposits.get((owner, asset)).try_read().unwrap_or(0);

            amount
        }
    }
}

fn big(value: u64) -> U128 {
    U128::from((0, value))
}

fn min(value_a: U128, value_b: U128) -> U128 {
    if value_a > value_b {
        value_b
    } else {
        value_a
    }
}

impl ConstantProductAMM for Contract {
    #[storage(read, write), payable]
    fn deposit() {
        require(msg_amount() >= 0, "Incorrect amount provided");

        let owner = msg_sender().unwrap();
        let asset_id = msg_asset_id();
        let amount = storage.deposits.get((owner, asset_id)).try_read().unwrap_or(0);

        storage.deposits.insert((owner, asset_id), amount + msg_amount());
    }

    #[storage(read, write)]
    fn withdraw(recipient: Identity, asset_id: AssetId) {
        let owner = msg_sender().unwrap();
        let balance = storage.deposits.get((owner, asset_id)).try_read().unwrap_or(0);

        transfer(recipient, asset_id, balance);

        storage.deposits.remove((owner, asset_id));
    }

    #[storage(read, write), payable]
    fn swap(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> u64 {
        require(msg_amount() >= 0, "Incorrect amount provided");

        let owner = msg_sender().unwrap();
        let amount = deposit_or_call(asset_a);

        require(asset_a == asset_b, "invalid token");

        let sub_id = sha256((asset_a, asset_b));
        let pool_id = AssetId::new(contract_id(), sub_id);
        let pool = storage.pools.get(pool_id).try_read().unwrap();
        
        let amount_in = ((big(amount) * big(997)) / big(1000)).as_u64().unwrap();
        let amount_out = ((big(pool.reserve_b) * big(amount_in))
            / (big(pool.reserve_a) + big(amount_in))).as_u64().unwrap();

        storage.pools.insert(pool_id, Pool {
            reserve_a: pool.reserve_a + amount_in,
            reserve_b: pool.reserve_b - amount_out,
            total_supply: pool.total_supply
        });
        
        if recipient == Identity::ContractId(contract_id()) {
            let deposit_amount = storage.deposits.get((owner, asset_a)).try_read().unwrap_or(0);
            storage.deposits.insert((owner, asset_a), deposit_amount + amount_out);
        } else {
            transfer(recipient, asset_b, amount_out);
        }
        
        amount_out
    }

    #[storage(read, write), payable]
    fn add_liquidity(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> u64 {
        let owner = msg_sender().unwrap();
        let amount_a = deposit_or_call(asset_a);

        let amount_b = storage.deposits.get((owner, asset_b)).try_read().unwrap_or(0);
        let sub_id = sha256((asset_a, asset_b));
        let pool_id = AssetId::new(contract_id(), sub_id);
        let pool = match storage.pools.get(pool_id).try_read() {
            Some(x) => {
                x
            },
            None => {
                let total_pools = storage.total_pools.try_read().unwrap_or(0);
                storage.total_pools.write(total_pools + 1);
                Pool { total_supply: 0, reserve_a: 0, reserve_b: 0 }
            }
        };
        let mut shares = 0;

        if (pool.reserve_a > 0 || pool.reserve_b > 0) {
            require(
                big(pool.reserve_a) * big(amount_a) == big(pool.reserve_b) * big(amount_b), "x / y != dx / dy"
            );
        }

        if (pool.total_supply == 0) {
            shares = (big(amount_a) * big(amount_b)).sqrt().as_u64().unwrap();
        } else {
            shares = min(
                (big(amount_a) * big(pool.total_supply)) / big(pool.reserve_a),
                (big(amount_b) * big(pool.total_supply)) / big(pool.reserve_b)
            ).as_u64().unwrap();
        }

        require(shares > 0, "shares = 0");

        if recipient == Identity::ContractId(contract_id()) {
            let deposit_amount = storage.deposits.get((owner, pool_id)).try_read().unwrap_or(0);
            storage.deposits.insert((owner, pool_id), deposit_amount + shares);
        }
        
        mint_to(owner, sub_id, shares);

        storage.pools.insert(pool_id, Pool {
            reserve_a: amount_a + pool.reserve_a,
            reserve_b: amount_b - pool.reserve_b,
            total_supply: pool.total_supply + shares
        });

        shares
    }

    #[storage(read, write), payable]
    fn remove_liquidity(asset_a: AssetId, asset_b: AssetId, recipient: Identity) -> (u64, u64) {
        let owner = msg_sender().unwrap();
        let sub_id = sha256((asset_a, asset_b));
        let pool_id = AssetId::new(contract_id(), sub_id);

        let shares = deposit_or_call(pool_id);
        let pool = storage.pools.get(pool_id).try_read().unwrap();
        let amount_a = ((big(shares) * big(pool.reserve_a)) / big(pool.total_supply)).as_u64().unwrap();
        let amount_b = ((big(shares) * big(pool.reserve_b)) / big(pool.total_supply)).as_u64().unwrap();

        require(amount_a > 0 && amount_b > 0, "amount0 or amount1 = 0");

        burn(sub_id, shares);

        storage.pools.insert(pool_id, Pool {
            reserve_a: pool.reserve_a - amount_a,
            reserve_b: pool.reserve_b - amount_b,
            total_supply: pool.total_supply - shares
        });

        if (amount_a > 0) {
            if recipient == Identity::ContractId(contract_id()) {
                let deposit_amount = storage.deposits.get((owner, asset_a)).try_read().unwrap_or(0);
                storage.deposits.insert((owner, asset_a), deposit_amount + amount_a);
            } else {
                transfer(recipient, asset_a, amount_a);
            }
        }
        if (amount_b > 0) {
            if recipient == Identity::ContractId(contract_id()) {
                let deposit_amount = storage.deposits.get((owner, asset_b)).try_read().unwrap_or(0);
                storage.deposits.insert((owner, asset_b), deposit_amount + amount_b);
            } else {
                transfer(recipient, asset_b, amount_b);
            }
        }
        
        (amount_a, amount_b)
    }

    #[storage(read)]
    fn get_pool(asset_id: AssetId) -> Option<Pool> {
        storage.pools.get(asset_id).try_read()
    }
}
