use anyhow::Context;
use lazy_static_include::lazy_static_include_bytes;
use log::{debug, error};
use std::panic::catch_unwind;
use std::thread::LocalKey;
use tokio::runtime::Runtime;
use zcash_coldwallet::constants::LIGHTNODE_URL;
use zcash_coldwallet::sign::{sign_tx, sign_tx_with_bytes};
use zcash_coldwallet::transact::submit;
use zcash_coldwallet::{chain, Opt, Tx, ZECUnit};

// const SPEND_PARAMS: &[u8] = include_bytes!("sapling-spend.params");
// const OUTPUT_PARAMS: &[u8] = include_bytes!("sapling-output.params");

pub fn sync(database_path: &str, max_blocks: u32) -> u64 {
    let mut r = Runtime::new().unwrap();
    match r.block_on(chain::sync(database_path, LIGHTNODE_URL, max_blocks)) {
        Err(e) => {
            error!("{}", e);
            0u64
        }
        Ok(k) => k,
    }
}

pub fn get_balance(directory_path: &str) -> u64 {
    match zcash_coldwallet::account::get_balance(directory_path, ZECUnit::Zat) {
        Err(_) => 0u64,
        Ok(v) => v,
    }
}

pub async fn send_async(
    directory_path: &str,
    to_addr: &str,
    amount: u64,
    spending_key: &str,
    spending_params: &[u8],
    output_params: &[u8],
) -> anyhow::Result<()> {
    let opt = Opt::default();
    let tx = zcash_coldwallet::transact::prepare_tx(
        directory_path,
        to_addr,
        amount.to_string(),
        &ZECUnit::Zat,
    )?;
    let tx = sign_tx_with_bytes(spending_key, &tx, &opt, spending_params, output_params)?;
    submit(tx, &opt.lightnode_url).await?;

    Ok(())
}

pub fn send(
    directory_path: &str,
    address: &str,
    amount: u64,
    spending_key: &str,
    spending_params: &[u8],
    output_params: &[u8],
) {
    let mut r = Runtime::new().unwrap();
    match r.block_on(send_async(
        directory_path,
        address,
        amount,
        spending_key,
        spending_params,
        output_params,
    )) {
        Err(e) => {
            error!("{}", e);
        }
        Ok(_) => {
            debug!("Transaction sent");
        }
    }
}

pub fn prepare_tx(database_path: &str, address: &str, amount: u64) -> anyhow::Result<Vec<u8>> {
    let tx = zcash_coldwallet::transact::prepare_tx(
        database_path,
        address,
        amount.to_string(),
        &ZECUnit::Zat,
    )?;
    let tx = bincode::serialize(&tx)?;
    Ok(tx)
}

pub fn sign(
    secret_key: &str,
    tx: &str,
    spend_params: &[u8],
    output_params: &[u8],
) -> anyhow::Result<String> {
    let tx = base64::decode(tx).context("base64:decode")?;
    let tx = bincode::deserialize::<Tx>(&tx).context("tx:deser")?;
    let opt = Opt::default();
    let raw_tx = sign_tx_with_bytes(secret_key, &tx, &opt, spend_params, output_params)?;
    let raw_tx = base64::encode(raw_tx.data);
    Ok(raw_tx)
}

pub async fn broadcast_async(raw_tx: &str) -> anyhow::Result<String> {
    let data = base64::decode(raw_tx)?;
    let message = zcash_coldwallet::transact::submit_data(&data).await?;
    Ok(message)
}
