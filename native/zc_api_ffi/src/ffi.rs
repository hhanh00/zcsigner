use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::panic::catch_unwind;
use std::ptr::null;
use std::slice;
use tokio::runtime::Runtime;
use zcash_coldwallet::constants::LIGHTNODE_URL;
use zcash_coldwallet::ZECUnit;

#[repr(C)]
pub struct CKeys {
    phrase: *mut c_char,
    derivation_path: *mut c_char,
    spending_key: *mut c_char,
    viewing_key: *mut c_char,
    address: *mut c_char,
}

#[no_mangle]
pub extern "C" fn initialize(database_path: *mut c_char) -> bool {
    let database_path = unsafe { CStr::from_ptr(database_path) };

    crate::init::initialize(&database_path.to_string_lossy())
}

#[no_mangle]
pub extern "C" fn init_account(database_path: *mut c_char) -> CKeys {
    let database_path = unsafe { CStr::from_ptr(database_path) };

    let keys = crate::init::init_account(&database_path.to_string_lossy());
    let k = CKeys {
        phrase: CString::new(keys.phrase).unwrap().into_raw(),
        derivation_path: CString::new(keys.derivation_path).unwrap().into_raw(),
        spending_key: CString::new(keys.spending_key).unwrap().into_raw(),
        viewing_key: CString::new(keys.viewing_key).unwrap().into_raw(),
        address: CString::new(keys.address).unwrap().into_raw(),
    };
    k
}

#[no_mangle]
pub extern "C" fn sync(database_path: *mut c_char, max_blocks: u32) -> u64 {
    let database_path = unsafe { CStr::from_ptr(database_path) };
    crate::account::sync(&database_path.to_string_lossy(), max_blocks)
}

#[no_mangle]
pub extern "C" fn get_balance(database_path: *mut c_char) -> u64 {
    let database_path = unsafe { CStr::from_ptr(database_path) };
    crate::account::get_balance(&database_path.to_string_lossy())
}

#[no_mangle]
pub extern "C" fn send_tx(
    database_path: *mut c_char,
    address: *mut c_char,
    amount: u64,
    spending_key: *mut c_char,
    spend_params: *const c_char,
    len_spend_params: usize,
    output_params: *const c_char,
    len_output_params: usize,
) {
    let database_path = unsafe { CStr::from_ptr(database_path) };
    let address = unsafe { CStr::from_ptr(address) };
    let spending_key = unsafe { CStr::from_ptr(spending_key) };
    let spend_params =
        unsafe { slice::from_raw_parts(spend_params as *const u8, len_spend_params) };
    let output_params =
        unsafe { slice::from_raw_parts(output_params as *const u8, len_output_params) };

    crate::account::send(
        &database_path.to_string_lossy(),
        &address.to_string_lossy(),
        amount,
        &spending_key.to_string_lossy(),
        spend_params,
        output_params,
    );
}

#[no_mangle]
pub extern "C" fn check_address(address: *mut c_char) -> bool {
    let address = unsafe { CStr::from_ptr(address) };
    zcash_coldwallet::keys::check_address(&address.to_string_lossy())
}

#[no_mangle]
pub extern "C" fn get_address(viewing_key: *mut c_char) -> *const c_char {
    let viewing_key = unsafe { CStr::from_ptr(viewing_key) };
    let address = match zcash_coldwallet::keys::get_address(&viewing_key.to_string_lossy()) {
        Ok(a) => a,
        Err(e) => e.to_string(),
    };
    CString::new(address).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn get_key_type(key: *mut c_char) -> *const c_char {
    let key = unsafe { CStr::from_ptr(key) };
    let key_type = match zcash_coldwallet::keys::get_key_type(&key.to_string_lossy()) {
        zcash_coldwallet::keys::KeyType::UNKNOWN => "",
        zcash_coldwallet::keys::KeyType::SECRET_KEY => "secret",
        zcash_coldwallet::keys::KeyType::VIEWING_KEY => "viewing",
    };
    CString::new(key_type).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn init_account_with_viewing_key(
    database_path: *mut c_char,
    viewing_key: *mut c_char,
    height: u32,
) {
    let database_path = unsafe { CStr::from_ptr(database_path) };
    let viewing_key = unsafe { CStr::from_ptr(viewing_key) };
    let mut r = Runtime::new().unwrap();
    r.block_on(async {
        zcash_coldwallet::account::init_account(
            &database_path.to_string_lossy(),
            LIGHTNODE_URL,
            &viewing_key.to_string_lossy(),
            height as u64,
        )
        .await
        .unwrap();
    });
}

#[repr(C)]
pub struct CResult<T> {
    ok: T,
    err: *const c_char,
}

fn convert_result(r: anyhow::Result<String>) -> CResult<*const c_char> {
    match r {
        Ok(m) => CResult::<*const c_char> {
            ok: CString::new(m).unwrap().into_raw(),
            err: null(),
        },
        Err(e) => {
            let err = CString::new(e.to_string()).unwrap().into_raw();
            CResult::<*const c_char> { ok: null(), err }
        }
    }
}

#[no_mangle]
pub extern "C" fn prepare_tx(
    database_path: *mut c_char,
    address: *mut c_char,
    amount: u64,
) -> CResult<*const c_char> {
    let database_path = unsafe { CStr::from_ptr(database_path) };
    let address = unsafe { CStr::from_ptr(address) };
    let tx = crate::account::prepare_tx(
        &database_path.to_string_lossy(),
        &address.to_string_lossy(),
        amount,
    )
    .map(|tx| base64::encode(tx));
    convert_result(tx)
}

#[no_mangle]
pub extern "C" fn sign_tx(
    secret_key: *mut c_char,
    tx: *mut c_char,
    spend_params: *const c_char,
    len_spend_params: usize,
    output_params: *const c_char,
    len_output_params: usize,
) -> CResult<*const c_char> {
    let secret_key = unsafe { CStr::from_ptr(secret_key) }.to_string_lossy();
    let tx = unsafe { CStr::from_ptr(tx) }.to_string_lossy();
    let spend_params =
        unsafe { slice::from_raw_parts(spend_params as *const u8, len_spend_params) };
    let output_params =
        unsafe { slice::from_raw_parts(output_params as *const u8, len_output_params) };
    let tx = crate::account::sign(&secret_key, &tx, &spend_params, &output_params);
    convert_result(tx)
}

#[no_mangle]
pub extern "C" fn broadcast(raw_tx: *mut c_char) -> CResult<*const c_char> {
    let raw_tx = unsafe { CStr::from_ptr(raw_tx) }.to_string_lossy();
    let mut r = Runtime::new().unwrap();
    let message = r.block_on(async { crate::account::broadcast_async(&raw_tx).await });
    convert_result(message)
}

#[no_mangle]
pub extern "C" fn get_height(database_path: *mut c_char) -> u32 {
    let database_path = unsafe { CStr::from_ptr(database_path) }.to_string_lossy();
    zcash_coldwallet::chain::get_height(&database_path)
        .unwrap()
        .unwrap_or_default()
}
